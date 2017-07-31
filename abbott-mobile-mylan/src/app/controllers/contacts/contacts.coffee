RootPanelScreen = require 'controllers/base/panel/root-panel-screen'
LazyTableController = require 'controllers/lazy-table-controller'
TargetReferencesCollection = require 'models/bll/references/target-references-collection'
NonTargetReferencesCollection = require 'models/bll/references/non-target-references-collection'
ContactsTableCell = require 'controllers/contacts/contacts-table-cell'
ListPopup = require 'controls/popups/list-popup'
TableHeaderItem = require 'controls/table/table-header/table-header-item'
SortingTableHeaderItem = require 'controls/table/table-header/sorting-table-header-item'
BaseHeader = require 'controls/header/base-header'
HeaderBaseControl = require 'controls/header-controls/header-base-control'
ContactsFilter = require 'controllers/contacts/contacts-filter'
Search = require 'controls/search/search'
ContactCard = require 'controllers/contact-card/contact-card'
OrganizationCard = require 'controllers/organization-card/organization-card'
AppointmentCard = require 'controllers/appointment-card/appointment-card'
CallReportCard = require 'controllers/call-report-card/call-report-card'
Controller = require 'controllers/lazy-table-controller'

class Contacts extends RootPanelScreen
  className: 'table-view contacts'

  tableController: null
  popupDatasource: null

  TYPE_APPOINTMENT: 'appointment'
  TYPE_CALL_REPORT: 'callReport'

  constructor: ->
    super
    @popupDatasource = [
      {id: @TYPE_APPOINTMENT, description: Locale.value('createActivityPopup.Appointment')}
      {id: @TYPE_CALL_REPORT, description: Locale.value('createActivityPopup.CallReport')}
    ]
    @subscribeOnNotification 'callReportCreated', @reload

  active: ->
    super
    @_initHeader()
    @_initContent()

  _initHeader: ->
    @currentFilter = _.first ContactsFilter.resources()
    headerFilterBtn = new HeaderBaseControl @currentFilter.description, 'select-btn'
    headerFilterBtn.bind 'tap', @_onFilterTap
    @search = new Search()
    @search.bind 'searchChanged', @_onSearchChanged
    @search.bind 'searchClear', @_resetSearch
    contactsHeader = new BaseHeader @_headerTitle()
    contactsHeader.render()
    contactsHeader.addRightControlElement @search.render().el
    contactsHeader.addLeftControlElement headerFilterBtn.el
    @setHeader contactsHeader

  _headerTitle: =>
    Locale.value('contacts.HeaderTitle')

  # TODO: check panels with filters (_onFilterTap is almost the same in different panels)
  _onFilterTap: (headerFilterBtn) =>
    filterPopup = new ListPopup ContactsFilter.resources(), @currentFilter
    filterPopup.bind 'onPopupItemSelected', (selectedItem) =>
      @currentFilter = selectedItem.model
      headerFilterBtn.updateTitle @currentFilter.description
      @dismissModalController()
      @_resetTable()
    @presentModalController filterPopup

  reload: =>
    @tableController?.reload()

  _resetTable: =>
    @tableController.resetAndActive { search: @search.getValue() }

  _onSearchChanged: (value) =>
    @tableController.filterBy value

  _resetSearch: =>
    @tableController.resetAndActive()

  _initContent: ->
    @tableController = new LazyTableController datasource: @
    @html @tableController.render().el

  _displayContactsCount: (collection) =>
    return unless collection
    collection.count()
    .then (count) => @headerControl.setTitle "#{@_headerTitle()} (#{count})"

  createCollection: =>
    collection = switch @currentFilter?.id
      when ContactsFilter.targetContacts().id then new TargetReferencesCollection
      when ContactsFilter.nonTargetContacts().id then new NonTargetReferencesCollection
      else new TargetReferencesCollection
    @_displayContactsCount(collection)
    collection

  createTableHeaderItemsForModel: (model) ->
    [
      new SortingTableHeaderItem Locale.value('common:names.Contact'), model.sfdc.contactLastName, model.sfdc.contactFirstName
      new SortingTableHeaderItem Locale.value('common:names.Priority'), 'priority'
      new SortingTableHeaderItem Locale.value('common:names.Specialty'), 'specialty'
      new SortingTableHeaderItem Locale.value('common:names.BU_Specialty'), 'abbottSpecialty'
      new SortingTableHeaderItem Locale.value('common:names.AtCalls'), 'atCalls'
      new SortingTableHeaderItem Locale.value('common:names.LastCall'), 'lastCall'
      new SortingTableHeaderItem Locale.value('common:names.Organization'), model.sfdc.organizationName, model.sfdc.id
      new TableHeaderItem Locale.value('common:names.Appt')
      new TableHeaderItem Locale.value('common:names.Call')
    ]

  cellForObjectOnTable: (object, table) =>
    contactsTableCell = new ContactsTableCell object
    contactsTableCell.on 'cellTap', @_onCellTap
    contactsTableCell.on 'cellHold', @_onCellHold
    contactsTableCell.on 'organizationCellTap', @_onOrganizationCellTap
    contactsTableCell.on 'apptTap', @_onApptTap
    contactsTableCell.on 'callReportTap', @_onCallReportTap
    contactsTableCell

  _onOrganizationCellTap: (cell) =>
    @stage.push(new OrganizationCard cell.reference.organizationSfId)

  _onCellTap: (cell) =>
    @stage.push(new ContactCard cell.reference.contactSfId)

  _onCellHold: (cell) =>
    listPopup = new ListPopup @popupDatasource, null, Locale.value('createActivityPopup.Caption')
    listPopup.customStyleClass 'no-checkbox'
    listPopup.on 'onPopupItemSelected', (selectedItem) =>
      if selectedItem.id is @TYPE_APPOINTMENT
        @stage.push(new AppointmentCard cell.reference.id)
      else
        @stage.push(new CallReportCard cell.reference.id)
      @dismissModalController()
    @presentModalController listPopup

  _onApptTap: (cell) =>
    @stage.push(new AppointmentCard cell.reference.id)

  _onCallReportTap: (cell) =>
    @stage.push(new CallReportCard cell.reference.id)

module.exports = Contacts
