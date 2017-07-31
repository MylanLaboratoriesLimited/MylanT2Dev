RootPanelScreen = require 'controllers/base/panel/root-panel-screen'
LazyTableController = require 'controllers/lazy-table-controller'
TotsCollection = require 'models/bll/tots-collection/tots-collection'
TotsClosedCollection = require 'models/bll/tots-collection/tots-closed-collection'
TotsOpenCollection = require 'models/bll/tots-collection/tots-open-collection'
TotsSubmitCollection = require 'models/bll/tots-collection/tots-submit-collection'
TableController = require 'controls/table/table-controller'
TotsTableCell = require 'controllers/tots/tots-table-cell'
TableHeaderItem = require 'controls/table/table-header/table-header-item'
SortingTableHeaderItem = require 'controls/table/table-header/sorting-table-header-item'
Tot = require 'models/tot'
ConfigurationManager = require 'db/configuration-manager'
HeaderBaseControl = require 'controls/header-controls/header-base-control'
BaseHeader = require 'controls/header/base-header'
Search = require 'controls/search/search'
TotsFilter = require 'controllers/tots/tots-filter'
ListPopup = require 'controls/popups/list-popup'
TotCardView = require 'controllers/tot-card/tot-card-view'
TotCardCreate = require 'controllers/tot-card/tot-card-create'
TotCardEdit = require 'controllers/tot-card/tot-card-edit'
Utils = require 'common/utils'

class TotsAll extends RootPanelScreen
  className: 'table-view tots'
  
  _hasQuarters: true

  tableController: null

  active: ->
    super
    @_initHeader()
    ConfigurationManager.getConfig('countryAndCurrencySettings')
    .then (currencySettings) =>
      @_hasQuarters = currencySettings.isQuarter if currencySettings
      @_initContent()

  _initHeader: ->
    @currentFilter = TotsFilter.resources()[0]
    headerFilterBtn = new HeaderBaseControl @currentFilter.description, 'select-btn'
    headerFilterBtn.bind 'tap', @_onFilterTap
    @search = new Search()
    @search.bind 'searchChanged', @_onSearchChanged
    @search.bind 'searchClear', @_resetSearch
    addTotsEventButton = new HeaderBaseControl '', 'ctrl-add-button'
    addTotsEventButton.bind 'tap', @_onAddTotTap
    totsHeader = new BaseHeader Locale.value('tots.HeaderTitle')
    totsHeader.render()
    totsHeader.addLeftControlElement headerFilterBtn.el
    totsHeader.addLeftControlElement addTotsEventButton.el
    totsHeader.addRightControlElement @search.render().el
    @setHeader totsHeader

  _onFilterTap: (headerFilterBtn) =>
    filterPopup = new ListPopup TotsFilter.resources(), @currentFilter
    filterPopup.bind 'onPopupItemSelected', (selectedItem) =>
      @currentFilter = selectedItem.model
      headerFilterBtn.updateTitle @currentFilter.description
      @dismissModalController()
      @reload()
    @presentModalController filterPopup

  reload: ->
    @tableController.resetAndActive { search: @search.getValue() }

  _onSearchChanged: (value) =>
    @tableController.filterBy value

  _resetSearch: =>
    @tableController.resetAndActive()

  _onAddTotTap: =>
    totCard = new TotCardCreate
    totCard.on 'totChanged', => @tableController.reload()
    @stage.push(totCard)

  _initContent: ->
    @tableController = new LazyTableController datasource: @
    @html @tableController.render().el

  createCollection: ->
    switch @currentFilter?.id
      when TotsFilter.totsAll().id
        new TotsCollection
      when TotsFilter.totsClosed().id
        new TotsClosedCollection
      when TotsFilter.totsOpen().id
        new TotsOpenCollection
      when TotsFilter.totsSubmit().id
        new TotsSubmitCollection
      else
        new TotsCollection

  createTableHeaderItemsForModel: (model) ->
    [
      new TableHeaderItem Locale.value('common:names.MedRep')
      new SortingTableHeaderItem Locale.value('common:names.Type'), model.sfdc.type
      new TableHeaderItem Locale.value('common:names.AllDay')
      new SortingTableHeaderItem Locale.value('common:names.StartDate'),  model.sfdc.startDate
      new SortingTableHeaderItem Locale.value('common:names.EndDate'),  model.sfdc.endDate
      new TableHeaderItem Locale.value('common:names.Events')
    ]

  cellForObjectOnTable: (object, table) =>
    totsTableCell = new TotsTableCell object, @_hasQuarters
    totsTableCell.on 'cellTap', @_onCellTap
    totsTableCell

  _onCellTap: (cell) =>
    if cell.tot.type is Tot.TYPE_OPEN and not cell.tot.isSubmittedForApproval
      @_isTotValidForEditing(cell.tot)
      .then (isTotValidForEditing) =>
        totCard = if isTotValidForEditing then new TotCardEdit(cell.tot.id) else new TotCardView(cell.tot.id, true)
        totCard.on 'totChanged', => @tableController.reload()
        @stage.push(totCard)
    else
      @stage.push(new TotCardView cell.tot.id)

  _isTotValidForEditing: (tot) ->
    ConfigurationManager.getConfig('callReportValidationSettings')
    .then (dateRangeConfig) =>
      daysTimeOff = dateRangeConfig.daysTimeOff
      today = Utils.getDateByStr Utils.originalDate(new Date)
      totStartDate = Utils.getDateByStr tot.startDate
      Utils.getDaysBetween(totStartDate, today) <= daysTimeOff

module.exports = TotsAll