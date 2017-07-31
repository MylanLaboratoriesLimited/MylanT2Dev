Spine = require 'spine'
Stage = require 'controllers/base/stage/stage'
LazyTableController = require 'controllers/lazy-table-controller'
AppointmentsCollection = require 'models/bll/call-reports-collection/appointments-collection'
AppointmentsTableCell = require 'controllers/activities/appointments/appointments-table-cell'
TableHeaderItem = require 'controls/table/table-header/table-header-item'
SortingTableHeaderItem = require 'controls/table/table-header/sorting-table-header-item'
AppointmentCardEdit = require 'controllers/appointment-card/appointment-card-edit'
ContactCard = require 'controllers/contact-card/contact-card'
OrganizationCard = require 'controllers/organization-card/organization-card'
NotificationsModule = require 'common/notifications-module'

class Appointments extends Spine.Controller
  @include NotificationsModule

  className: 'table-view appointments'

  isRendered: false
  context: null
  tableController: null

  constructor: ->
    super
    @tableController = new LazyTableController datasource: @
    @subscribeOnNotification 'appointmentChanged', @reload
    @subscribeOnNotification 'callReportCreated', @reload
    document.addEventListener('resume', @refreshIfTimeChange, false)

  activate: (params = {}) =>
    super params
    @executeDeferredNotificationCallbacks()

  shouldDeferNotification: (notification) =>
    not Stage.globalStage().isActive() or not @context.stage.isActive() or not @context.isActive() or not @isActive()

  active: (params) ->
    super
    @render() unless @isRendered
    @tableController.active params

  render: ->
    @lastRenderTime = (new Date).getTime()
    @html @tableController.el
    @isRendered = true
    @

  refreshIfTimeChange: =>
    date = (new Date).getTime()
    @reload() if @el.hasClass('active') and Math.abs(@lastRenderTime - date) / (1000 * 3600) >= 1
    @lastRenderTime = date

  createCollection: ->
    new AppointmentsCollection

  createTableHeaderItemsForModel: (model) ->
    dateTimeOfVisitHeader = new SortingTableHeaderItem Locale.value('common:names.DateTimeOfVisit'), model.sfdc.dateTimeOfVisit
    @tableController.defaultSortingHeader = dateTimeOfVisitHeader
    [
      dateTimeOfVisitHeader
      new SortingTableHeaderItem Locale.value('common:names.Customer'), 'contactLastName', 'contactFirstName'
      new TableHeaderItem Locale.value('common:names.Specialty')
      new TableHeaderItem Locale.value('common:names.Priority')
      new TableHeaderItem Locale.value('common:names.Organization')
      new TableHeaderItem Locale.value('common:names.User')
      new TableHeaderItem Locale.value('common:names.AtCalls')
    ]

  getAppointmentsTableCell: (appointment) => new AppointmentsTableCell appointment

  cellForObjectOnTable: (appointment, table) =>
    appointmentsTableCell = @getAppointmentsTableCell appointment
    appointmentsTableCell.on 'cellTap', @_onCellTap
    appointmentsTableCell.on 'appointmentsContactCellTap', @_onAppointmentsContactCellTap
    appointmentsTableCell.on 'appointmentsOrganizationCellTap', @_onAppointmentsOrganizationCellTap
    appointmentsTableCell

  filterBy: (value) =>
    @tableController.filterBy value

  reset: =>
    @tableController.reset()

  reload: =>
    timeout = setTimeout =>
      @tableController.reload()
      clearTimeout timeout
    , 0

  _onCellTap: (cell) =>
    @context.stage.push(new AppointmentCardEdit cell.appointment.id)

  _onAppointmentsContactCellTap: (cell) =>
    @context.stage.push(new ContactCard cell.appointment.contactSfid)

  _onAppointmentsOrganizationCellTap: (cell) =>
    @context.stage.push(new OrganizationCard cell.appointment.organizationSfId)

module.exports = Appointments