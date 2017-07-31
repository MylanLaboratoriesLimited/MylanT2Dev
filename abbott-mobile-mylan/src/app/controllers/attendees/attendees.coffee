PanelScreen = require 'controllers/base/panel/panel-screen'
AttendeesTableCell = require 'controllers/attendees/attendees-table-cell'
ContactsCollection = require 'models/bll/contacts-collection'
TableDatasource = require 'controls/table/table-data-source'
AttendeesTableController = require 'controllers/attendees/attendees-table'
TableHeaderItem = require 'controls/table/table-header/table-header-item'
HeaderBaseControl = require 'controls/header-controls/header-base-control'
Header = require 'controls/header/header'
Search = require 'controls/search/search'
ContactCard = require 'controllers/contact-card/contact-card'

class Attendees extends PanelScreen
  className: 'table-view attendees'

  elements:
    'input': 'elInput'

  # fix bluring on android
  events:
    'tap header':'_searchBlur'
    'tap .tables-holder':'_searchBlur'
  # end offix bluring on android

  selectedContactIds: []
  cardTypeComeFrom: null

  deactivate: ->
    super
    @_searchBlur()

  _searchBlur: =>
    @elInput.blur()

  constructor: (@selectedContactIds, @cardTypeComeFrom) ->
    super
    @tableController = new AttendeesTableController datasource: @

  active: ->
    super
    Locale.localize @el
    @_initHeader()
    @_initContent()

  _initHeader: ->
    search = new Search()
    search.bind 'searchChanged', @_onSearchChanged
    search.bind 'searchClear', @_resetSearchingFilter
    attendeesHeader = new Header (Locale.value 'card.PharmaEvent.AttendeesHeaderTitle')
    attendeesHeader.render()
    attendeesHeader.addRightControlElement search.render().el
    @setHeader attendeesHeader

  _onSearchChanged: (value) =>
    @tableController.filterBy value

  _resetSearchingFilter: =>
    @tableController.resetAndActive()

  onBack: =>
    super
    @trigger 'attendeesSelected', @selectedContactIds

  _initContent: ->
    @html @tableController.render().el

  createCollection: ->
    new ContactsCollection

  createTableHeaderItemsForModel: (model) ->
    [
      new TableHeaderItem ''
      new TableHeaderItem Locale.value('common:names.Specialty')
      new TableHeaderItem Locale.value('common:names.Contact')
    ]

  cellForObjectOnTable: (attendee, table) =>
    attendeesTableCell = new AttendeesTableCell attendee
    attendeesTableCell.on 'cellTap', @_onCellTap
    attendeesTableCell.on 'contactTap', @_onContactTap
    @selectedContactIds.forEach (contactId) ->
      attendeesTableCell.isChecked = true if contactId is attendeesTableCell.contact.id
    attendeesTableCell

  _onCellTap: (cell) =>
    if cell.isChecked
      @selectedContactIds.push cell.contact.id
    else
      @selectedContactIds = @selectedContactIds.filter (contactId) -> contactId isnt cell.contact.id

  _onContactTap: (cell) =>
    @stage.push(new ContactCard cell.contact.id)

module.exports = Attendees