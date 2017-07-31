class Utils
  @runSimultaneously: (functionsList) ->
    $.when.apply @, functionsList

  @isIOS: ->
    /iphone|ipod|ipad/.test(window.navigator.userAgent.toLowerCase())

  @deviceIsOnline: ->
    deviceConnection = cordova.require 'salesforce/util/bootstrap'
    deviceConnection.deviceIsOnline()

  @formatDateTime: (timeString) ->
    moment(moment.utc(timeString).toDate()).format("DD.MM.YYYY HH:mm")

  @dotFormatDate: (timeString) ->
    moment(timeString).format("DD.MM.YYYY")

  @slashFormatDate: (timeString) ->
    moment(timeString).format("DD/MM/YYYY")

  @formatTime: (timeString) ->
    moment(timeString).format("HH:mm")

  @formatDateVisit: (date) ->
    moment(date).format("YYYY-MM-DD")

  @generateUID: =>
    'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g, (c) =>
      r = Math.random() * 16 | 0
      v = if c is 'x' then r else (r &0x3 | 0x8)
      v.toString(16)
    )

  @originalStartOfDate: (date) ->
    startOfDay = moment date
    startOfDay.hours 0
    startOfDay.minutes 0
    startOfDay.seconds 0
    startOfDay.milliseconds 0
    startOfDay.utc().format("YYYY-MM-DDTHH:mm:ss.SSSZZ")

  @originalDate: (dateTime) ->
    date = moment dateTime
    date.utc()
    date.format 'YYYY-MM-DD'

  @originalTime: (dateTime) ->
    time = moment dateTime
    time.utc()
    time.format 'HH:mm'

  @originalEndOfDate: (date) ->
    endOfDay = moment date
    endOfDay.hours 23
    endOfDay.minutes 59
    endOfDay.seconds 59
    endOfDay.milliseconds 999
    endOfDay.utc().format("YYYY-MM-DDTHH:mm:ss.SSSZZ")

  @originalStartOfToday: ->
    @originalStartOfDate(new Date)

  @originalEndOfToday: ->
    @originalEndOfDate(new Date)

  @originalStartOfTomorrow: ->
    date = new Date
    date.setDate(date.getDate() + 1)
    @originalStartOfDate(date)

  @originalEndOfTomorrow: ->
    date = new Date
    date.setDate(date.getDate() + 1)
    @originalEndOfDate(date)

  @originalDateTime: (date) ->
    dateString = @currentDate date
    hh = date.getHours()
    mm = date.getMinutes()
    hh = '0' + hh if hh < 10
    mm = '0' + mm if mm < 10
    moment("#{dateString}T#{hh}:#{mm}:00").utc().format("YYYY-MM-DDTHH:mm:ss.SSSZZ")

  @getDateByStr: (dateStr) ->
    moment(dateStr).toDate()

  @originalDateTimeObject: (timeString) ->
    moment(moment.utc(timeString).toDate()).toDate()

  @formatDateTimeWithBreak: (timeString) =>
    @formatDateTime(timeString).replace ' ', '<br/>'

  @currentDateTime: (dateStr) ->
    @formatDateTime dateStr ? new Date()

  @currentDate: (dateStr) ->
    today = if dateStr then new Date(dateStr) else new Date()
    moment(today).format('YYYY-MM-DD')

  @monthByIndex:(index) ->
    moment.monthsShort("-MMM-",index)

  @dayOfWeekByIndex:(index) ->
    moment.weekdaysMin(index)

  @toSalesForceDateTimeFormat: (date) ->
    moment(date).format("YYYY-MM-DDTHH:mm:ss.SSS") + 'Z'

  @isDevice: ->
    userAgent = window.navigator.userAgent.toLowerCase()
    userAgent.match /(iphone|ipod|ipad|android)/

  @minutesOfDay: (date) ->
    date.minutes() + date.hours() * 60

  @isIntervalBefore: (intervalTimeStart, intervalTimeEnd, limitTime) ->
    limitTimeMinutes = @minutesOfDay(limitTime)
    @minutesOfDay(intervalTimeStart) < limitTimeMinutes and @minutesOfDay(intervalTimeEnd) <= limitTimeMinutes

  @isTimeBefore: (timeToCheck, limitTime) ->
    @minutesOfDay(timeToCheck) <= @minutesOfDay(limitTime)

  @isTimeAfter: (timeToCheck, limitTime) ->
    @minutesOfDay(timeToCheck) >= @minutesOfDay(limitTime)

  @getDaysBetween:(startDate, endDate) ->
    datediff = endDate.getTime() - startDate.getTime()
    datediff / (24 * 60 * 60 * 1000)

  @getDuration:(startTime, endTime) ->
    Math.round((endTime - startTime) / 1000)

  @dateWithoutTime: (date) ->
    new Date date.getFullYear(), date.getMonth(), date.getDate()

  @dateTimeWithoutSeconds: (date) ->
    new Date date.getFullYear(), date.getMonth(), date.getDate(), date.getHours(), date.getMinutes()

  @timeFromString: (timeString)->
    timeParts = timeString.split ':'
    moment({hours: parseInt(timeParts[0]), minutes: parseInt(timeParts[1])})

module.exports = Utils