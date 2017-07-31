FullscreenPanel = require 'controllers/base/panel/fullscreen-panel'
UsersTableCell = require 'controllers/users/users-table-cell'
UsersCollection = require 'models/bll/users-collection'
TableDatasource = require 'controls/table/table-data-source'
ActivityIndicator = require 'common/activity-indicator'
UsersTableController = require 'controllers/users/users-table'
HeaderBaseControl = require 'controls/header-controls/header-base-control'
TableHeaderItem = require 'controls/table/table-header/table-header-item'
SortingTableHeaderItem = require 'controls/table/table-header/sorting-table-header-item'
Header = require 'controls/header/header'
Search = require 'controls/search/search'

class Users extends FullscreenPanel
  className: 'table-view users full-screen'

  elements:
    'input': 'elInput'

  # fix bluring on android
  events:
    'tap header':'_searchBlur'
    'tap .tables-holder':'_searchBlur'
  # end offix bluring on android

  constructor: (@chosenUser) ->
    super

  deactivate: ->
    super
    @_searchBlur()

  _searchBlur: =>
    @elInput.blur()

  active: ->
    super
    Locale.localize @el
    @_initHeader()
    @_initContent()

  _initHeader: ->
    search = new Search()
    search.bind 'searchChanged', @_onSearchChanged
    search.bind 'searchClear', @_resetSearchingFilter
    usersHeader = new Header Locale.value('card.UsersHeaderTitle')
    usersHeader.render()
    usersHeader.addRightControlElement search.render().el
    @setHeader usersHeader

  _onSearchChanged: (value) =>
    @tableController.filterBy value

  _resetSearchingFilter: =>
    @tableController.resetAndActive()

  onBack: =>
    @trigger 'onClose', @chosenUser
    super

  _initContent: ->
    @tableController = new UsersTableController datasource: @
    @html @tableController.render().el

  createCollection: ->
    new UsersCollection

  createTableHeaderItemsForModel: (model) ->
    [
      new TableHeaderItem
      new SortingTableHeaderItem Locale.value('common:names.Name'), model.sfdc.lastName, model.sfdc.firstName
      new SortingTableHeaderItem Locale.value('common:names.Email'), model.sfdc.email
    ]

  cellForObjectOnTable: (user, table) =>
    usersTableCell = new UsersTableCell user
    usersTableCell.on 'cellTap', @_onCellTap
    if @chosenUser? and @chosenUser.id is user.id
      usersTableCell.isChecked = true
    usersTableCell

  _onCellTap: (cell) =>
    @chosenUser = if cell.isChecked then cell.user else null

module.exports = Users