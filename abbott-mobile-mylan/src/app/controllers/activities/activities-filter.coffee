class ActivitiesFilter
  @appointmentsToday: ->
    {id: 0, description: Locale.value('activities.FilterPopup.AppointmentsToday')}

  @appointments: ->
    {id: 1, description: Locale.value('activities.FilterPopup.Appointments')}

  @appointmentsPast: ->
    {id: 2, description: Locale.value('activities.FilterPopup.AppointmentsPast')}

  @appointmentsTomorrow: ->
    {id: 3, description: Locale.value('activities.FilterPopup.AppointmentsTomorrow')}

  @calls: ->
      {id: 4, description: Locale.value('activities.FilterPopup.1To1Calls')}

  @callsToday: ->
    {id: 5, description: Locale.value('activities.FilterPopup.1To1CallsToday')}

  @pharmaEvents: ->
    {id: 6, description: Locale.value('activities.FilterPopup.PharmaEvents')}

  @resources: ->
    [@appointmentsToday(), @appointments(),@appointmentsPast(),@appointmentsTomorrow(), @calls(), @callsToday(), @pharmaEvents()]

module.exports = ActivitiesFilter
