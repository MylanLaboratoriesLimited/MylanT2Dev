Spine = require 'spine'
DateTimePicker = require 'controls/datepicker/date-time-picker'

class DateTimePickerExtended extends DateTimePicker
  constructor: (@baseDate)->
    super

  getStartDate: ->
    date = if @baseDate then new Date(@baseDate) else new Date()
    date.setDate(date.getDate() - @daysBefore)
    date

  getEndDate: ->
    date = @getStartDate()
    date.setDate(date.getDate() + @daysAfter)
    date

module.exports = DateTimePickerExtended