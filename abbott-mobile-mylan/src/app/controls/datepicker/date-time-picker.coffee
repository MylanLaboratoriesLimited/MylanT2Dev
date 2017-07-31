Spine = require 'spine'
Utils = require 'common/utils'
DatePicker = require 'controls/datepicker/datepicker'

class DateTimePicker extends DatePicker
  className: 'date-time-picker'

  MAX_HOURS_IN_DAY: 23
  MAX_MINUTES_IN_HOUR: 59

  result: =>
    results = SpinningWheel.getSelectedValues()
    yyyy = @getYearFromResult results.values[0]
    dd = @getDateWithoutYearFromResult results.values[0]
    hh = results.values[2]
    min = results.values[4]
    moment("#{dd}, #{yyyy} #{hh}:#{min}", 'dd MMM D, YYYY HH:mm').toDate()

  setConfig: =>
    SpinningWheel.addSlot( @days(), @right, @defaultMonthIndex)
    SpinningWheel.addSlot({ separator: '.' }, 'readonly shrink')
    SpinningWheel.addSlot( @hours(), @right, @date.getHours())
    SpinningWheel.addSlot({ separator: ':' }, 'readonly shrink')
    SpinningWheel.addSlot( @minutes(), @right, @date.getMinutes())
    SpinningWheel.setCancelAction(@cancel)
    SpinningWheel.setDoneAction(@done)

  getKeyValues: (start, end) =>
    keyValue = {}
    for index in [start..end]
      val = if index < 10 then '0' + index else index.toString()
      keyValue[index] = val
    keyValue

  hours: =>
    @getKeyValues 0, @MAX_HOURS_IN_DAY

  minutes: =>
    @getKeyValues 0, @MAX_MINUTES_IN_HOUR

module.exports = DateTimePicker