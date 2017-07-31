PanelScreen = require 'controllers/base/panel/panel-screen'
Header = require 'controls/header/header'
ContactsCollection = require 'models/bll/contacts-collection'
SforceDataContext = require 'models/bll/sforce-data-context'
TableDatasource = require 'controls/table/table-data-source'
ContactCardReferencesTable = require 'controllers/contact-card/contact-card-references-table'
ContactCardReferencesTableCell = require 'controllers/contact-card/contact-card-references-table-cell'
ContactCardActivitiesTable = require 'controllers/contact-card/contact-card-activities-table'
ContactCardActivitiesTableCell = require 'controllers/contact-card/contact-card-activities-table-cell'
CallReport = require 'models/call-report'
AppointmentCard = require 'controllers/appointment-card/appointment-card'
AppointmentCardEdit = require 'controllers/appointment-card/appointment-card-edit'
CallReportCard = require 'controllers/call-report-card/call-report-card'
CallReportCardView = require 'controllers/call-report-card/call-report-card-view'
ConfigurationManager = require 'db/configuration-manager'

class ContactCard extends PanelScreen
  className: 'contact-card'

  elements:
    '.contact-card-full-name':        'elFullname'
    '.contact-card-status':           'elStatus'
    '.contact-card-target-customer':  'elTargetCustomer'
    '.contact-card-record-type':      'elRecordType'
    '.contact-card-abbott-specialty': 'elAbbottSpecialty'
    '.contact-card-priority':         'elPriority'
    '.contact-card-specialty':        'elSpecialty'
    '.contact-card-mobile-phone':     'elMobilePhone'
    '.contact-card-email':            'elEmail'
    '.contact-card-kol':              'elKol'
    '.contact-card-description':      'elDescription'
    '.references-table-container':    'elReferencesTable'
    '.activities-table-container':    'elActivitiesTable'
    '.comment-block':                 'elCommentBlock'

  contact: null
  contactId: null
  referencesTable: null
  references: null
  activitiesTable: null
  activities: null

  template: ->
    require('views/contact-card/contact-card')()

  constructor: (@contactId) ->
    super
    @subscribeOnNotification 'appointmentChanged', @_reloadActivities
    @subscribeOnNotification 'callReportCreated', @_reloadActivities

  active: ->
    super
    collection = new ContactsCollection
    collection.fetchEntityById(@contactId)
    .done((@contact) => @render())
    .fail((err) => alert "Error fetching records:\n #{JSON.stringify err}")

  render: ->
    @html @template()
    @_initHeader()
    @_fillGeneralInfo()
    @_initTables().then =>
      ConfigurationManager.getConfig()
      .then (config) =>
        @elCommentBlock.hide() if config.showContactDescription is false and not @contact.description
        Locale.localize @el
    @

  _reloadActivities: =>
    @_getActivities()
    .then => Locale.localize @el

  _fillGeneralInfo: ->
    @elFullname.html @contact.fullName()
    @elRecordType.html @contact.recordType
    @elTargetCustomer.html @contact.targetCustomer()
    @elPriority.html @contact.priority
    @elAbbottSpecialty.html @contact.abbottSpecialty
    @elMobilePhone.html @contact.mobilePhone
    @elEmail.html @contact.email
    @elKol.html @contact.kol
    @elDescription.html @contact.description
    @elDescription.elastic()
    @contact.getOrganization()
    .then (organization) =>
      @elStatus.html organization.status
      @elSpecialty.html organization.specialty1

  _createReferencesTable: ->
    @referencesTable = new ContactCardReferencesTable
    @referencesTable.datasource = @
    @elReferencesTable.html @referencesTable.render().el

  _createActivitiesTable: ->
    @activitiesTable = new ContactCardActivitiesTable
    @activitiesTable.datasource = @
    @elActivitiesTable.html @activitiesTable.render().el

  _getReferences: ->
    @contact.getReferences()
    .then (@references) => @_createReferencesTable()

  _getActivities: =>
    SforceDataContext.currentMarketingCycle()
    .then(@contact.getActivitiesInMarketingCycle)
    .then((@activities) => @_createActivitiesTable())

  _initTables: ->
    $.when.apply $, [
      @_getReferences()
      @_getActivities()
    ]

  _initHeader: ->
    contactHeader = new Header "#{Locale.value('card.Contact.HeaderTitle')} #{@contact.fullName()}"
    contactHeader.render()
    @setHeader contactHeader

  numberOfRowsForTable: (table) ->
    if table is @referencesTable then @references.length
    else if table is @activitiesTable then @activities.length

  cellForRowAtIndexForTable: (index, table) ->
    if table is @referencesTable then @_createReferencesTableCellAtIndex index
    else if table is @activitiesTable then @_createActivitiesTableCellAtIndex index

  _createReferencesTableCellAtIndex: (index) ->
    contactCardReferencesTableCell = new ContactCardReferencesTableCell @references[index]
    contactCardReferencesTableCell.on 'apptTap', @_onApptTap
    contactCardReferencesTableCell.on 'callReportTap', @_onCallReportTap
    contactCardReferencesTableCell.on 'organizationTap', @_onOrganizationTap
    contactCardReferencesTableCell

  _createActivitiesTableCellAtIndex: (index) ->
    contactCardActivitiesTableCell = new ContactCardActivitiesTableCell @activities[index]
    contactCardActivitiesTableCell.on 'tap', @_onApptEditTap
    contactCardActivitiesTableCell

  _onApptEditTap: (cell) =>
    if cell.activity.type is CallReport.TYPE_APPOINTMENT then @stage.push(new AppointmentCardEdit cell.activity.id)
    else if cell.activity.type is CallReport.TYPE_ONE_TO_ONE then @stage.push(new CallReportCardView cell.activity.id)

  _onApptTap: (cell) =>
    @stage.push(new AppointmentCard cell.reference.id)

  _onCallReportTap: (cell) =>
    @stage.push(new CallReportCard cell.reference.id)

  _onOrganizationTap: (cell) =>
    OrganizationCard = require 'controllers/organization-card/organization-card'
    @stage.push(new OrganizationCard cell.reference.organizationSfId)

module.exports = ContactCard