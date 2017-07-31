ListPopup = require 'controls/popups/list-popup'
SettingsManager = require 'db/settings-manager'
AlarmManager = require 'common/alarm/alarm-manager'
AlarmSettings =require 'common/alarm/alarm-settings-source'

class Alarm
  @currentAlarm: null
  @popup: null

  @selectedItemHandler: (selectedItem) =>
    @currentAlarm = selectedItem.model
    managerAction = if @currentAlarm.value then AlarmManager.scheduleNextVisits else AlarmManager.cancelNotification
    SettingsManager.setValueByKey('alarm', @currentAlarm.value).then managerAction
    @popup.hide()

  @showSettingsPopup: =>
    @popup = new ListPopup @settings, @currentAlarm, Locale.value('alarmSettingsPopup.Title')
    @popup.bind 'onPopupItemSelected', @selectedItemHandler
    @popup.show()

  @setup: ->
    @settings = AlarmSettings.resources()
    unless @currentAlarm
      SettingsManager.getValueByKey('alarm')
      .then (value) =>
        @currentAlarm = if value then AlarmSettings.getItem parseInt(value) else @settings[0]
        @showSettingsPopup()
    else
      @showSettingsPopup()


module.exports = Alarm