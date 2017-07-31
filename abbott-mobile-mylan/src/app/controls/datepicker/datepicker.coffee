Spine = require 'spine'
Utils = require("common/utils")
SforceDataContext = require 'models/bll/sforce-data-context'
ConfigurationManager = require 'db/configuration-manager'
ModalControllerModule = require 'controls/popups/modal-controller-module'

class DatePicker extends Spine.Controller
  @include ModalControllerModule

  className:"date-picker"

  daysAfter: 30
  daysBefore: 14
  right: 'right'
  center: 'center'

  constructor: (@date = new Date(), @limitation = null) ->
    super {}

  show: ->
    @date = if @date instanceof Date then @date else new Date @date
    if @limitation?
      @_setLimitation(@limitation).then @_configureAndOpen
    else
      @_configureAndOpen()
    document.addEventListener('backbutton', @cancel, true)
    $(document.body).addClass('popup-mode')

  hide: =>
    @cancel()

  _configureAndOpen: =>
    @setConfig()
    @showOverflow()
    SpinningWheel.open(@className)

  result: ->
    results = SpinningWheel.getSelectedValues()
    yyyy = @getYearFromResult results.values[0]
    dd = @getDateWithoutYearFromResult results.values[0]
    moment("#{dd}, #{yyyy}", 'dd MMM D, YYYY').toDate()

  getYearFromResult: (result) ->
    indexOfYear = result.lastIndexOf(' ') + 1
    result.substring(indexOfYear)

  getDateWithoutYearFromResult: (result) ->
    indexOfYear = result.lastIndexOf(' ')
    result.substring(0, indexOfYear)

  done: =>
    $(document.body).removeClass('popup-mode')
    res = @result()
    @trigger 'onDonePressed', res
    # @cancel()

  _setLimitation: (newLmitation) =>
    SforceDataContext.activeUser().then (user)=>
      return $.when() unless user
      unless user.callReportValidationExcempted
        ConfigurationManager.getConfig('callReportValidationSettings').then (dateRangeConfig)=>
          deltaBefore = if newLmitation['beforeKey']? then dateRangeConfig[newLmitation['beforeKey']] else newLmitation['beforeDays']
          deltaAfter = if newLmitation['afterKey']? then dateRangeConfig[newLmitation['afterKey']] else newLmitation['afterDays']
          @setDaysLimitations deltaBefore, deltaAfter
      else
        @setDaysLimitations newLmitation['beforeDays'], newLmitation['afterDays']

  setDaysLimitations: (daysBefore, daysAfter) =>
    @daysBefore = Math.floor(daysBefore) if daysBefore?
    @daysAfter = Math.floor(daysAfter) if daysAfter?

  cancel: =>
    $(document.body).removeClass('popup-mode')
    document.removeEventListener 'backbutton', @cancel, true
    @willHide @
    SpinningWheel.destroy()
    @hideOverflow()

  showOverflow: =>
    @overflow = $("<div class='popup-overflow'/>")
    app.mainController.append @overflow
    @didShow @

  hideOverflow: ->
    @overflow.remove()

  setConfig: ->
    SpinningWheel.addSlot( @days(), @center, @defaultMonthIndex)
    SpinningWheel.setCancelAction(@cancel)
    SpinningWheel.setDoneAction(@done)

  getStartDate: ->
    date = new Date()
    date.setHours(0,0,0,0)
    date.setDate(date.getDate() - @daysBefore)
    date

  getEndDate: ->
    date = new Date()
    date.setDate(date.getDate() + @daysAfter)
    date

  getDaysBetween:(startDate, endDate) ->
    days = {}
    index = 1
    #getting date with out time
    endDate = new Date endDate.getFullYear(), endDate.getMonth(), endDate.getDate()
    dateStep = new Date startDate.getFullYear(), startDate.getMonth(), startDate.getDate()

    selectedDate = if @date < startDate then new Date else @date
    selectedDate = new Date selectedDate.getFullYear(), selectedDate.getMonth(), selectedDate.getDate()
    while dateStep <= endDate
      year = dateStep.getFullYear()
      month = Utils.monthByIndex dateStep.getMonth()
      dayNumber = if dateStep.getDate() < 10 then '0' + dateStep.getDate() else dateStep.getDate()
      dayOfWeek = Utils.dayOfWeekByIndex dateStep.getDay()
      days[index] = "#{dayOfWeek} #{month} #{dayNumber} #{year}"
      if Number(dateStep) == Number(selectedDate) then @defaultMonthIndex = index
      index++
      dateStep.setDate(dateStep.getDate() + 1)
    days

  _dateWithoutTime: (date) ->
    

  days: ->
    startDate = @getStartDate()
    endDate = @getEndDate()
    days = @getDaysBetween startDate, endDate
    days

module.exports = DatePicker