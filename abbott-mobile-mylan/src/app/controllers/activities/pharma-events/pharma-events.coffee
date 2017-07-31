Spine = require 'spine'
Stage = require 'controllers/base/stage/stage'
LazyTableController = require 'controllers/lazy-table-controller'
PharmaEventsTableCell = require 'controllers/activities/pharma-events/pharma-events-table-cell'
SortingTableHeaderItem = require 'controls/table/table-header/sorting-table-header-item'
PharmaEventsCollection = require 'models/bll/pharma-events-collection'
PeCardView = require 'controllers/pe-card/pe-card-view'
PeCardEdit = require 'controllers/pe-card/pe-card-edit'
NotificationsModule = require 'common/notifications-module'

class PharmaEvents extends Spine.Controller
  @include NotificationsModule

  className: 'table-view pharma-events'

  isRendered: false
  context: null
  tableController: null

  constructor: ->
    super
    @tableController = new LazyTableController datasource: @

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
    @html @tableController.el
    @isRendered = true
    @

  createCollection: ->
    new PharmaEventsCollection

  createTableHeaderItemsForModel: (model) ->
    dateTimeOfStartDateHeader = new SortingTableHeaderItem Locale.value('common:names.StartDate'), model.sfdc.startDate
    @tableController.defaultSortingHeader = dateTimeOfStartDateHeader
    [
      new SortingTableHeaderItem Locale.value('common:names.Status'), model.sfdc.status
      new SortingTableHeaderItem Locale.value('common:names.Owner'), 'ownerLastName', 'ownerFirstName'
      new SortingTableHeaderItem Locale.value('common:names.EventName'), model.sfdc.eventName
      new SortingTableHeaderItem Locale.value('common:names.TypeOfEvent'), model.sfdc.eventType
      new SortingTableHeaderItem Locale.value('common:names.Stage'), model.sfdc.stage
      dateTimeOfStartDateHeader
      new SortingTableHeaderItem Locale.value('common:names.Location'), model.sfdc.location
    ]

  cellForObjectOnTable: (pharmaEvent, table) =>
    appointmentsTableCell = new PharmaEventsTableCell pharmaEvent
    appointmentsTableCell.on 'cellTap', @_onCellTap
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
    cell.pharmaEvent.isEditable()
    .then (isEditable) =>
      if isEditable
        peCard = new PeCardEdit cell.pharmaEvent.id
        peCard.on 'pharmaEventChanged', => @reload()
        @context.stage.push(peCard)
      else
        @context.stage.push(new PeCardView cell.pharmaEvent.id)

module.exports = PharmaEvents