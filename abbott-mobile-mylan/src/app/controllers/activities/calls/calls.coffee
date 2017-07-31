Spine = require 'spine'
Stage = require 'controllers/base/stage/stage'
LazyTableController = require 'controllers/lazy-table-controller'
CallsCollection = require 'models/bll/call-reports-collection/calls-collection'
CallsTableCell = require 'controllers/activities/calls/calls-table-cell'
TableHeaderItem = require 'controls/table/table-header/table-header-item'
SortingTableHeaderItem = require 'controls/table/table-header/sorting-table-header-item'
ContactCard = require 'controllers/contact-card/contact-card'
CallReportCardView = require 'controllers/call-report-card/call-report-card-view'
NotificationsModule = require 'common/notifications-module'

class Calls extends Spine.Controller
  @include NotificationsModule

  className: 'table-view calls'

  isRendered: false
  context: null
  tableController: null

  constructor: ->
    super
    @tableController = new LazyTableController datasource: @
    @subscribeOnNotification 'callReportCreated', @reload
    document.addEventListener('resume', @refreshIfTimeChange, false)

  active: (params) ->
    super
    @render() unless @isRendered
    @tableController.active params

  activate: (params = {}) =>
    super params
    @executeDeferredNotificationCallbacks()

  shouldDeferNotification: (notification) =>
    not Stage.globalStage().isActive() or not @context.stage.isActive() or not @context.isActive() or not @isActive()

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
    new CallsCollection

  createTableHeaderItemsForModel: (model) ->
    dateTimeOfVisitHeader = new SortingTableHeaderItem Locale.value('common:names.DateTimeOfVisit'), model.sfdc.dateTimeOfVisit
    @tableController.defaultSortingHeader = dateTimeOfVisitHeader
    [
      dateTimeOfVisitHeader
      new SortingTableHeaderItem Locale.value('common:names.Customer'), 'contactLastName', 'contactFirstName'
      new TableHeaderItem Locale.value('common:names.Specialty')
      new TableHeaderItem Locale.value('common:names.Priority')
      new TableHeaderItem Locale.value('common:names.User')
      new TableHeaderItem Locale.value('common:names.AtCalls')
    ]

  cellForObjectOnTable: (call, table) =>
    appointmentsTableCell = new CallsTableCell call
    appointmentsTableCell.on 'cellTap', @_onCellTap
    appointmentsTableCell.on 'callsContactCellTap', @_onCallsContactCellTap
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
    @context.stage.push(new CallReportCardView cell.call.id)

  _onCallsContactCellTap: (cell) =>
    @context.stage.push(new ContactCard cell.call.contactSfid)


module.exports = Calls