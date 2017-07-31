Spine = require 'spine'
DatePicker = require 'controls/datepicker/datepicker'

class DatePickerExtended extends DatePicker
  getStartDate: ->
    startDate = if @date then new Date(@date) else new Date()
    startDate.setDate(startDate.getDate() - @daysBefore)
    startDate

  getEndDate: ->
    endDate = @getStartDate()
    endDate.setDate(endDate.getDate() + @daysAfter)
    endDate

module.exports = DatePickerExtended