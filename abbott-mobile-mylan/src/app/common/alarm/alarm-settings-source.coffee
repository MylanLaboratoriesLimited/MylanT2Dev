class AlarmSettings
  @off: ->
    {id: 0, description: Locale.value('alarmSettingsPopup.Off'), value: -1}

  @minutes15: ->
    {id: 1, description: Locale.value('alarmSettingsPopup.InFifteenMinutes'), value: 15}

  @minutes30: ->
    {id: 2, description: Locale.value('alarmSettingsPopup.InThirtyMinutes'), value: 30}

  @hour1: ->
    {id: 3, description: Locale.value('alarmSettingsPopup.InOneHour'), value: 60}

  @hour1_5: ->
    {id: 4, description: Locale.value('alarmSettingsPopup.InOneHourThirtyMinutes'), value: 90}

  @hour2: ->
    {id: 5, description: Locale.value('alarmSettingsPopup.InTwoHours'), value: 120}

  @resources: ->
    [@off(), @minutes15(), @minutes30(), @hour1(), @hour1_5(), @hour2()]

  @getItem: (value)->
    filteredItems = @resources().filter (item)->
      item.value == value
    filteredItems[0]

module.exports = AlarmSettings