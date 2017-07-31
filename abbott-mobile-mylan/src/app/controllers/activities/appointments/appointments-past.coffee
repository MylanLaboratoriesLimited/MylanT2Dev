Spine = require 'spine'
Appointments = require 'controllers/activities/appointments/appointments'
AppointmentsPastCollection = require 'models/bll/call-reports-collection/appointments-past-collection'

class AppointmentsPast extends Appointments
  className: 'table-view appointments past'

  createCollection: =>
    new AppointmentsPastCollection

module.exports = AppointmentsPast