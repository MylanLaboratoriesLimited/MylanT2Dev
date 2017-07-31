TotsCollection = require '/models/bll/tots-collection/tots-collection'
Utils = require 'common/utils'
SforceDataContext = require 'models/bll/sforce-data-context'
TotCardView = require 'controllers/tot-card/tot-card-view'
DatePicker = require 'controls/datepicker/datepicker'
DatePickerExtended = require 'controls/datepicker/datepicker-extended'
ConfirmationPopup = require 'controls/popups/confirmation-popup'
ListPopup = require 'controls/popups/list-popup'
CommentView = require 'controls/comment-view/comment-view'
Tot = require 'models/tot'
TotEventsPickListDatasource = require 'controllers/tot-card/tot-events-picklist-datasource'
PickList = require 'controls/pick-list/pick-list'
CommonInput = require 'controls/common-input/common-input'
HeaderBaseControl = require 'controls/header-controls/header-base-control'
Header = require 'controls/header/header'

# TODO: REFACTOR - Think of isChanged flag here (may be move its logic to edit card)
class TotCardCreate extends TotCardView
  className: 'tot card create-mode'
  activeUser: null
  eventsArray: null
  daysMax: 13
  daysAfter: 90

  events:
    'tap .tot-card-start-date': '_editStartDate'
    'tap .tot-card-end-date': '_editEndDate'
    'change .check-all-day': '_editAllDay'

  active: ->
    @_resetChangeFlags()
    super
    @placeholder = Locale.value 'card.Tot.Placeholder'

  _resetChangeFlags: =>
    @isChanged = false

  _init: ->
    SforceDataContext.activeUser()
    .then (@activeUser) =>
      @render()

  _initHeader: ->
    @saveBtn = new HeaderBaseControl Locale.value('common:buttons.SaveBtn'), 'ctrl-btn'
    @saveBtn.bind 'tap', @_saveTot
    totHeader = new Header Locale.value('card.Tot.HeaderTitle')
    totHeader.render()
    totHeader.addRightControlElement @saveBtn.el
    @setHeader totHeader

  _fillDefaultInfo: ->
    @elUserFullName.html @activeUser?.fullName()
    @_initDefaultStartDate()
    @_initDefaultEndDate()
    @_initFirstQuarter()
    @_initThirdQuarter()
    if @_hasQuarters
      @_initSecondQuarter()
      @_initFourthQuarter()
    else
      @el.addClass 'morning-afternoon'
      @morningLabel.text Locale.value('card.Tot.Morning')
      @afternoonLabel.text Locale.value('card.Tot.Afternoon')
    @_initDefaultAllDay()
    @_initDefaultDescription()

  _initDefaultStartDate: ->
    @startDate = Utils.getDateByStr(Utils.currentDate())
    @elStartDate.html Utils.dotFormatDate @startDate

  _initDefaultEndDate: ->
    @endDate = Utils.getDateByStr(Utils.currentDate())
    @elEndDate.html Utils.dotFormatDate @endDate

  _initFirstQuarter: ->
    @firstQuarterPickList = new PickList @, @elFirstQuarter, new TotEventsPickListDatasource, @tot?.firstQuarterEvent or null
    @firstQuarterPickList.bind 'onPickListItemSelected', => @isChanged = true

  _initSecondQuarter: ->
    @secondQuarterPickList = new PickList @, @elSecondQuarter, new TotEventsPickListDatasource, @tot?.secondQuarterEvent or null
    @secondQuarterPickList.bind 'onPickListItemSelected', => @isChanged = true

  _initThirdQuarter: ->
    @thirdQuarterPickList = new PickList @, @elThirdQuarter, new TotEventsPickListDatasource, @tot?.thirdQuarterEvent or null
    @thirdQuarterPickList.bind 'onPickListItemSelected', => @isChanged = true

  _initFourthQuarter: ->
    @fourthQuarterPickList = new PickList @, @elFourthQuarter, new TotEventsPickListDatasource, @tot?.fourthQuarterEvent or null
    @fourthQuarterPickList.bind 'onPickListItemSelected', => @isChanged = true

  _initDefaultAllDay: ->
    @allDay = false
    @elAllDay[0].checked = @allDay
    @_refreshQuarters()

  _refreshQuarters: ->
    if @allDay
      @el.addClass 'all-day-checked'
      @thirdQuarterPickList.setValue null
      if @_hasQuarters
        @secondQuarterPickList.setValue null
        @fourthQuarterPickList.setValue null
    else
      @el.removeClass 'all-day-checked'

  _initDefaultDescription: ->
    @_initDescription ''

  _editStartDate: ->
    @_showStartDatePicker @startDate, @_setStartDate

  _showStartDatePicker: (date, handler) =>
    datePicker = new DatePicker date, {beforeKey: 'daysTimeOff', afterDays: @daysAfter}
    datePicker.on 'onDonePressed', (selectedDate) =>
      @_handleStartDateEntered selectedDate, handler
    @presentModalController datePicker

  _setStartDate: (value) =>
    @startDate = value
    @elStartDate.html Utils.dotFormatDate value
    @isChanged = true if value
    daysBetween = Utils.getDaysBetween(@startDate, @endDate)
    if daysBetween < 0
      @_setEndDate(value)
    if daysBetween > @daysMax
      latestDate = new Date(value)
      latestDate.setDate(latestDate.getDate() + @daysMax)
      @_setEndDate(latestDate)

  _handleStartDateEntered: (date, handler) ->
    day = @_getDayOffByDate date
    unless day?
      @dismissModalController()
      handler date
    else
      toastMessage = "#{day} " + Locale.value('card.Tot.UserDayOff')
      $.fn.dpToast toastMessage

  _editEndDate: ->
    @_showEndDatePicker @_setEndDate

  _showEndDatePicker: (handler) =>
    startDate = Utils.dateWithoutTime @startDate
    daysBetween = Utils.getDaysBetween(startDate, @endDate)
    datePicker = new DatePickerExtended @endDate, { beforeDays: daysBetween, afterDays: @daysMax }
    datePicker.on 'onDonePressed', (selectedDate) =>
      @_handleEndDateEntered selectedDate, handler
    @presentModalController datePicker

  _setEndDate: (value) =>
    @endDate = value
    @elEndDate.html Utils.dotFormatDate value
    @isChanged = true if value

  _handleEndDateEntered: (date, handler) ->
    daysOff = @_getUserDaysOffFromInterval(@startDate, date)
    unless daysOff.length > 0
      @dismissModalController()
      handler date
    else
      toastMessage = "#{daysOff.join(', ').toString()} " + Locale.value('card.Tot.UserDaysOff')
      $.fn.dpToast toastMessage

  _editAllDay: (event) ->
    @isChanged = true
    @allDay = event.target.checked
    @_refreshQuarters()

  _getUserDaysOffFromInterval: (startDate, endDate) ->
    daysOff = []
    startDate = Utils.dateWithoutTime startDate
    endDate = Utils.dateWithoutTime endDate
    while startDate <= endDate
      day = @_getDayOffByDate startDate
      if day and not _.contains(daysOff, day) then daysOff.push day
      startDate = new Date startDate.setDate(startDate.getDate() + 1)
    return daysOff

  _getDayOffByDate: (date) ->
    day = @activeUser.getDayOffByIndex(date.getDay())
    if day in [@activeUser.DayOff1, @activeUser.DayOff2] then day else null

  onBack: =>
    unless @isChanged then super
    else
      confirm = new ConfirmationPopup {caption: Locale.value('card.ConfirmationPopup.SaveChanges.Caption')}
      confirm.bind 'yesClicked', =>
        @dismissModalController()
        @_saveTot()
      confirm.bind 'noClicked', =>
        @dismissModalController()
        @_resetChangeFlags()
        super
      @presentModalController confirm

  _saveTot: =>
    # TODO: REFACTOR !!! As it is done on _onSaveTap in pe-card-create
    if @_validData()
      @_save()
      .then(@_resetChangeFlags)
      .then(=> @trigger 'totChanged')
      .then(@onBack)

  _validData: ->
    toastHeader = "#{Locale.value('card.Tot.ToastMessage.ToastHeader')} <br/>"
    toastBody = ''

    if @allDay and not @_isQuarterValid(@firstQuarterPickList.selectedValue)
      toastBody += if @_hasQuarters then "#{Locale.value('card.Tot.ToastMessage.FirstPart')} <br/>" else "#{Locale.value('card.Tot.ToastMessage.Morning')} <br/>"

    if not @allDay and not @_isOneOfFieldsFilled()
      if @_hasQuarters
        toastBody += "#{Locale.value('card.Tot.ToastMessage.FirstPart')} <br/>"
        toastBody += "#{Locale.value('card.Tot.ToastMessage.SecondPart')} <br/>"
        toastBody += "#{Locale.value('card.Tot.ToastMessage.ThirdPart')} <br/>"
        toastBody += "#{Locale.value('card.Tot.ToastMessage.ForthPart')} <br/>"
      else
        toastBody += "#{Locale.value('card.Tot.ToastMessage.Morning')} <br/>"
        toastBody += "#{Locale.value('card.Tot.ToastMessage.Afternoon')} <br/>"

    toastBody += "#{Locale.value('card.Tot.ToastMessage.DateRange')} <br/>" if @endDate < @startDate

    daysOff = @_getUserDaysOffFromInterval(@startDate, @endDate)
    if daysOff.length
      toastHeader = "" if toastBody.length is 0
      toastBody+= "#{daysOff.join(', ').toString()} " + Locale.value('card.Tot.UserDaysOff')

    isDataValid = toastBody.length is 0
    toastMessage = toastHeader + toastBody
    $.fn.dpToast toastMessage unless isDataValid
    isDataValid

  _isQuarterValid: (quarter) ->
    quarter and quarter isnt null

  _isOneOfFieldsFilled: ->
    @_isQuarterValid(@firstQuarterPickList.selectedValue) or
    @_isQuarterValid(@thirdQuarterPickList.selectedValue) or
    if @_hasQuarters
      @_isQuarterValid(@secondQuarterPickList.selectedValue) or
      @_isQuarterValid(@fourthQuarterPickList.selectedValue)

  _save: =>
    tot = {}
    tot[Tot.sfdc.createdOffline] = true
    tot[Tot.sfdc.userSfId] = @activeUser?.id
    tot[Tot.sfdc.userLastName] = @activeUser?.lastName
    tot[Tot.sfdc.userFirstName] = @activeUser?.firstName
    tot[Tot.sfdc.allDay] = @allDay
    tot[Tot.sfdc.startDate] = Utils.currentDate @startDate
    tot[Tot.sfdc.endDate] = Utils.currentDate @endDate
    tot[Tot.sfdc.firstQuarterEvent] = @firstQuarterPickList.selectedValue
    tot[Tot.sfdc.secondQuarterEvent] = @secondQuarterPickList?.selectedValue or null
    tot[Tot.sfdc.thirdQuarterEvent] = @thirdQuarterPickList.selectedValue
    tot[Tot.sfdc.fourthQuarterEvent] = @fourthQuarterPickList?.selectedValue or null
    tot[Tot.sfdc.type] = Tot.TYPE_OPEN
    tot[Tot.sfdc.description] = @description
    tot[Tot.sfdc.isSubmittedForApproval] = false
    tot['attributes'] = {type: Tot.table}
    collection = new TotsCollection
    collection.createEntity tot

module.exports = TotCardCreate