SettingsManager = require 'db/settings-manager'

class DurationFilter
  @mapFilterItems: (settings)=>
    minutes = settings.duration
    indexOfDefault = minutes.indexOf settings['callDuration'].minutes()
    indexOfDefault = 0 if indexOfDefault is -1
    durations = minutes.map (minute, index)=>
      {
        id: index
        value: minute
        description: "#{minute} " + Locale.value('card.DurationPopup.TimeUnits')
      }
    durations.defaultValue = durations[indexOfDefault]
    durations

  @resources: ->
    SettingsManager.getTourPlanningSettings().then @mapFilterItems

module.exports = DurationFilter