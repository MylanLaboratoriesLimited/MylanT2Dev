Spine = require 'spine'
Appointments = require 'controllers/activities/appointments/appointments'
AppointmentsTodayCollection = require 'models/bll/call-reports-collection/appointments-today-collection'
AppointmentsTodayTableCell = require 'controllers/activities/appointments/appointments-today-table-cell'
TableHeaderItem = require 'controls/table/table-header/table-header-item'
SettingsManager = require 'db/settings-manager'

class AppointmentsToday extends Appointments
  className: 'table-view appointments today'

  active: (params) ->
    super params
    SettingsManager.getValueByKey('isTradeModuleEnabled')
    .then (isTradeEnabled) => if isTradeEnabled then @el.removeClass 'trade-off' else @el.addClass 'trade-off'

  createCollection: =>
    new AppointmentsTodayCollection

  getAppointmentsTableCell: (appointment) => new AppointmentsTodayTableCell appointment

  createTableHeaderItemsForModel: (model)=>
    headerIteritems = super(model)
    headerIteritems.push(new TableHeaderItem Locale.value('common:names.Promo'))
    headerIteritems

module.exports = AppointmentsToday