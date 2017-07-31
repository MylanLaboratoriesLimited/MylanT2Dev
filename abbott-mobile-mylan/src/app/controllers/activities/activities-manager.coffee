Spine = require 'spine'
Appointments = require 'controllers/activities/appointments/appointments'
AppointmentsToday = require 'controllers/activities/appointments/appointments-today'
AppointmentsPast = require 'controllers/activities/appointments/appointments-past'
AppointmentsTomorrow = require 'controllers/activities/appointments/appointments-tomorrow'
Calls = require 'controllers/activities/calls/calls'
CallsToday = require 'controllers/activities/calls/calls-today'
PharmaEvents = require 'controllers/activities/pharma-events/pharma-events'

class ActivitiesManager extends Spine.Stack
  controllers:
    appointmentsToday: AppointmentsToday
    appointments: Appointments
    appointmentsPast: AppointmentsPast
    appointmentsTomorrow: AppointmentsTomorrow
    calls: Calls
    callsToday: CallsToday
    pharmaEvents: PharmaEvents

  activeController: null

  constructor: ->
    super
    @activeController = @defaultController()

  setContext: (context) =>
    @_applyForAll (controller) -> controller.context = context

  _applyForAll: (predicate) =>
    predicate @[controllerName] for controllerName of @controllers

  activeControllerWithSearch: (controller, searchValue) =>
    params = { search: searchValue }
    @activeController = controller
    @activeController.active params

  filterCurrentBy: (value) =>
    @activeController.filterBy value

  resetCurrent: =>
    @activeController.reset()

  reloadCurrent: =>
    @activeController.reload()

  resetAll: =>
    @_applyForAll (controller) -> controller.reset()

  activeCurrent: =>
    @activeController.active()

  activateCurrent: =>
    @activeController.activate()

  release: =>
    @_applyForAll (controller) -> controller.release()
    super

  defaultController: =>
    @appointmentsToday

module.exports = ActivitiesManager