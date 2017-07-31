PanelScreen = require 'controllers/base/panel/panel-screen'
OrganizationsCollection = require 'models/bll/organizations-collection'
OrganizationCardReferencesTable = require 'controllers/organization-card/organization-card-references-table'
OrganizationCardReferencesTableCell = require 'controllers/organization-card/organization-card-references-table-cell'
OrganizationCardActivitiesTable = require 'controllers/organization-card/organization-card-activities-table'
OrganizationCardActivitiesTableCell = require 'controllers/organization-card/organization-card-activities-table-cell'
CallReport = require 'models/call-report'
SforceDataContext = require 'models/bll/sforce-data-context'
HeaderBaseControl = require 'controls/header-controls/header-base-control'
Header = require 'controls/header/header'
ContactCard = require 'controllers/contact-card/contact-card'
AppointmentCard = require 'controllers/appointment-card/appointment-card'
AppointmentCardEdit = require 'controllers/appointment-card/appointment-card-edit'
CallReportCard = require 'controllers/call-report-card/call-report-card'
CallReportCardView = require 'controllers/call-report-card/call-report-card-view'

class OrganizationCard extends PanelScreen
  className: 'organization-card'

  elements:
    '.organization-card-name':          'elName'
    '.organization-card-record-type':   'elRecordType'
    '.organization-card-address':       'elAddress'
    '.speciality':                      'elSpeciality'
    '.organization-card-juridic-group': 'elJuridicGroup'
    '.organization-card-status':        'elStatus'
    '.organization-card-speciality':    'elSpeciality'
    '.references-table-container':      'elReferencesTable'
    '.activities-table-container':      'elActivitiesTable'

  organization: null
  organizationId: null
  references: null
  referencesTable: null
  activities: null
  activitiesTable: null

  template: =>
    require('views/organization-card/organization-card')(organization: @organization)

  constructor: (@organizationId) ->
    super
    @subscribeOnNotification 'appointmentChanged', @_reloadActivities
    @subscribeOnNotification 'callReportCreated', @_reloadActivities

  active: (params) ->
    super
    collection = new OrganizationsCollection
    collection.fetchEntityById(@organizationId)
    .done((@organization) => @render())
    .fail((err) => alert "Error fetching records:\n #{JSON.stringify err}")

  render: ->
    @html @template()
    @_initHeader()
    @_fillgeneralInfo()
    @_initTables()
    .then => Locale.localize @el
    @

  _reloadActivities: =>
    @_getActivities()
    .then => Locale.localize @el

  _fillgeneralInfo: ->
    @elName.html @organization.name
    @elRecordType.html @organization.recordType
    @elAddress.html @organization.fullAddress()
    @elJuridicGroup.html @organization.juridicGroup
    @elStatus.html @organization.status
    @elSpeciality.html @organization.specialty1

  _createReferencesTable: ->
    @referencesTable = new OrganizationCardReferencesTable
    @referencesTable.datasource = @
    @elReferencesTable.html @referencesTable.render().el

  _createActivitiesTable: ->
    @activitiesTable = new OrganizationCardActivitiesTable
    @activitiesTable.datasource = @
    @elActivitiesTable.html @activitiesTable.render().el

  _getReferences: ->
    @organization.getReferences()
    .then (@references) => @_createReferencesTable()

  _getActivities: =>
    SforceDataContext.currentMarketingCycle()
    .then(@organization.getActivitiesInMarketingCycle)
    .then((@activities) => @_createActivitiesTable())

  _initTables: ->
    $.when.apply $, [
      @_getReferences(),
      @_getActivities()
    ]

  _initHeader: =>
    @tourPlanningBtn = new HeaderBaseControl Locale.value('card.Organization.TourPlanningBtn'), 'ctrl-btn'
    @tourPlanningBtn.bind 'tap', @_onTourPlanningTap
    organizationHeader = new Header "#{Locale.value('card.Organization.HeaderTitle')} #{@organization.name}"
    organizationHeader.render()
    organizationHeader.addRightControlElement @tourPlanningBtn.el
    @setHeader organizationHeader

  _onTourPlanningTap: =>
    @organization.hasAnyTargetReferences()
    .then (hasAnyReferences) =>
      unless hasAnyReferences then $.fn.dpToast Locale.value('card.Organization.ToastMessage.HasNoTargetReferences')
      else
        TourPlanningOrganization = require 'controllers/tour-planning-organization/tour-planning-organization'
        @stage.push(new TourPlanningOrganization @organization.id)

  numberOfRowsForTable: (table) ->
    if table is @referencesTable then @references.length
    else if table is @activitiesTable then @activities.length

  cellForRowAtIndexForTable: (index, table) ->
    if table is @referencesTable then @_createReferencesTableCellAtIndex index
    else if table is @activitiesTable then @_createActivitiesTableCellAtIndex index

  _createReferencesTableCellAtIndex: (index) ->
    contactCardReferencesTableCell = new OrganizationCardReferencesTableCell @references[index]
    contactCardReferencesTableCell.on 'apptTap', @_onApptTap
    contactCardReferencesTableCell.on 'callReportTap', @_onCallReportTap
    contactCardReferencesTableCell.on 'customerTap', @_onCustomerTap
    contactCardReferencesTableCell

  _createActivitiesTableCellAtIndex: (index) ->
    organizationCardActivitiesTableCell = new OrganizationCardActivitiesTableCell @activities[index]
    organizationCardActivitiesTableCell.on 'customerTap', @_onActivityCustomerTap
    organizationCardActivitiesTableCell.on 'activityTap', @_onActivityEditTap

  _onActivityCustomerTap: (cell) =>
    @stage.push(new ContactCard cell.activity.contactSfid)

  _onApptTap: (cell) =>
    @stage.push(new AppointmentCard cell.reference.id)

  _onCallReportTap: (cell) =>
    @stage.push(new CallReportCard cell.reference.id)

  _onCustomerTap: (cell) =>
    @stage.push(new ContactCard cell.reference.contactSfId)

  _onActivityEditTap: (cell) =>
    if cell.activity.type is CallReport.TYPE_APPOINTMENT then @stage.push(new AppointmentCardEdit cell.activity.id)
    else if cell.activity.type is CallReport.TYPE_ONE_TO_ONE then @stage.push(new CallReportCardView cell.activity.id)

module.exports = OrganizationCard