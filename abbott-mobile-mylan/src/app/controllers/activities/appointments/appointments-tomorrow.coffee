Spine = require 'spine'
Appointments = require 'controllers/activities/appointments/appointments'
AppointmentsTomorrowCollection = require 'models/bll/call-reports-collection/appointments-tomorrow-collection'

class AppointmentsTomorrow extends Appointments
  className: 'table-view appointments tomorrow'

  createCollection: =>
    new AppointmentsTomorrowCollection

module.exports = AppointmentsTomorrow