RootPanelScreen = require 'controllers/base/panel/root-panel-screen'
LazyTableController = require 'controllers/lazy-table-controller'
OrganizationsCollection = require 'models/bll/organizations-collection'
OrganizationsTableCell = require 'controllers/organizations/organizations-table-cell'
TableHeaderItem = require 'controls/table/table-header/table-header-item'
SortingTableHeaderItem = require 'controls/table/table-header/sorting-table-header-item'
BaseHeader = require 'controls/header/base-header'
Search = require 'controls/search/search'
OrganizationCard = require 'controllers/organization-card/organization-card'

class Organizations extends RootPanelScreen
  className: 'table-view organizations'

  tableController: null

  active: ->
    super
    @_initHeader()
    @_initContent()

  _initHeader: ->
    search = new Search()
    search.bind 'searchChanged', @_onSearchChanged
    search.bind 'searchClear', @_resetSearchingFilter
    orgsHeader = new BaseHeader Locale.value('organizations.HeaderTitle')
    orgsHeader.render()
    orgsHeader.addRightControlElement search.render().el
    @setHeader orgsHeader

  _onSearchChanged: (value) =>
    @tableController.filterBy value

  _resetSearchingFilter: =>
    @tableController.resetAndActive()

  _initContent: ->
    @tableController = new LazyTableController datasource: @
    @html @tableController.render().el

  createCollection: ->
    new OrganizationsCollection

  createTableHeaderItemsForModel: (model) ->
    [
      new SortingTableHeaderItem Locale.value('common:names.AccountName'), model.sfdc.name
      new SortingTableHeaderItem Locale.value('common:names.AccountRecordType'), model.sfdc.recordType
      #new SortingTableHeaderItem Locale.value('common:names.Specialty'), model.sfdc.specialty1
      new SortingTableHeaderItem Locale.value('common:names.GlobalPriority'), model.sfdc.globalPriority
      new SortingTableHeaderItem Locale.value('common:names.City'), model.sfdc.city
      new SortingTableHeaderItem Locale.value('common:names.BillingAddress'), model.sfdc.address
      new TableHeaderItem Locale.value('common:names.Phone')
    ]

  cellForObjectOnTable: (object, table) =>
    organizationsTableCell = new OrganizationsTableCell object
    organizationsTableCell.on 'cellTap', @_onCellTap
    organizationsTableCell

  _onCellTap: (cell) =>
    @stage.push(new OrganizationCard cell.organization.id)

module.exports = Organizations