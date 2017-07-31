Spine = require 'spine'
CallReportCard = require 'controllers/call-report-card/call-report-card'
AppointmentsCollection = require 'models/bll/call-reports-collection/appointments-collection'
Utils = require 'common/utils'
DurationFilter = require 'controls/filters/duration-filters/duration-filter'
CallReport = require 'models/call-report'
CallsCollection = require 'models/bll/call-reports-collection/calls-collection'
ReferencesCollection = require 'models/bll/references/references-collection'
AlarmManager = require 'common/alarm/alarm-manager'
TaskAdjustmentsCollection = require 'models/bll/task-adjustments-collection'
PhotoAdjustmentsCollection = require 'models/bll/photo-adjustments-collection'
MechanicAdjustmentsCollection = require 'models/bll/mechanic-adjustments-collection'

class ConvertCallReport extends CallReportCard
  className: 'call-report card convert-mode'

  events:
    'tap .call-report-card-customer': '_onCustomerTap'
    'tap .call-report-card-organization': '_onOrganizationTap'

  constructor: (@callReportId) ->
    super
    @collection = new AppointmentsCollection
    @subscribeOnNotification 'appointmentChanged', @reload

  reload: =>
    @_fetchCallReportById(@callReportId)
    .then (callReport) =>
      if callReport then @active()
      else
        delayTime = if Utils.isIOS() then @effectDefaults.duration else @effectDefaults.duration+100
        _.delay @onBack, delayTime

  _fetchCallReportById: (callReportId) =>
    keyValue = {}
    keyValue[CallReport.sfdc.id] = callReportId
    @collection.fetchAllWhere(keyValue)
    .then (response) =>
      @collection.getEntityFromResponse response

  shouldDeferNotification: (notification) =>
    true

  _init: =>
    @collection.fetchEntityById(@callReportId)
    .then (@callReport) => @_removeTrashDataIfExists()
    .then =>
      @_startTime = (new Date).getTime()
      @render()
      @_bindEvents()
      @_initTypeOfVisitPickList()
      @_clearSignature()
      @_applyConfig()
      @_initSignature()

  _removeTrashDataIfExists: =>
    @_removeTrashTaskAdjustments()
    .then @_removeTrashMechanicAdjustments
    .then @_removeTrashPhotoAdjustments

  _removeTrashAdjustmentsForCollection: (adjustmentsCollection) =>
    adjustmentsCollection.getAdjustmentsByCallReport(@callReport)
    .then adjustmentsCollection.removeEntities

  _removeTrashTaskAdjustments: =>
    @_removeTrashAdjustmentsForCollection new TaskAdjustmentsCollection

  _removeTrashMechanicAdjustments: =>
    @_removeTrashAdjustmentsForCollection new PhotoAdjustmentsCollection

  _removeTrashPhotoAdjustments: =>
    @_removeTrashAdjustmentsForCollection new MechanicAdjustmentsCollection

  _headerTitle: ->
    Locale.value('card.CallReport.ConvertHeaderTitle')

  _onCustomerTap: =>
    ContactCard = require 'controllers/contact-card/contact-card'
    @stage.push(new ContactCard @callReport.contactSfid)

  _onOrganizationTap: =>
    OrganizationCard = require 'controllers/organization-card/organization-card'
    @stage.push(new OrganizationCard @callReport.organizationSfId)

  _organizationIdForTradeModule: ->
    @callReport.organizationSfId

  _fillGeneralInfo: ->
    @_initGeneralInfoControls()
    .then @_setActiveUser

  _initGeneralInfoControls: =>
    unless @callReport then $.when()
    else
      @elCustomer.html "#{@callReport.contactFullName()} <br/> #{@callReport.contactRecordType}"
      @elOrganization.html @callReport.organizationNameAndAddress()
      @_initDateTime()
      @_initDurationFilter()
      .then =>
        @_initJointVisitPickList()
        @_jointVisitUser()
        @_initComment @callReport.generalComments ? ''
        @_initObjective ''
        @callReport.getSpecialty()
        .then (specialty) =>
          @elSpecialty.html @callReport.specialty

  _initDateTime: ->
    @originDateTime = Utils.originalDateTimeObject @callReport.dateTimeOfVisit
    @elDateTime.html Utils.formatDateTime @callReport.dateTimeOfVisit

  _initDurationFilter: ->
    if @callReport.duration?.length isnt 0
      DurationFilter.resources()
      .then (resources)=>
        @durationFilter = resources.filter((item) => item.value is parseInt @callReport.duration)[0]
        @duration = @durationFilter?.value ? resources.defaultValue
        @elDuration.html @duration
        $.when()
    else
      $.when()

  # TODO: REFACTOR TO PICKLISTS !!!
  # _initJointFilter: ->
  #  if @callReport.jointVisit
  #    @jointVisitFilter = @_jointVisits.filter((item) => item.id is @callReport.jointVisit)[0]
  #    @jointVisit = @_jointVisitFilterValue()
  #  else
  #    @jointVisitFilter = @_defaultJointVisitFilter()
  #    @jointVisit = null
  #  @elJointVisit.html @_jointVisitFilterValue()

  _jointVisitUser: ->
    @jointVisitUser = null
    @callReport.getJointVisitUser()
    .then (@jointVisitUser) =>
      @elJointVisitUser.html @jointVisitUser?.fullName()

  _save: =>
    @callReport.isSandbox = false
    @callReport.createdOffline = true
    @callReport.createdFromMobile = true
    @callReport.callWithIPad = true
    @callReport.realCallDuration = Utils.getDuration @_startTime, (new Date).getTime()
    @callReport.dateTimeOfVisit = Utils.originalDateTime @originDateTime
    @callReport.dateOfVisit = Utils.originalDate @originDateTime
    @callReport.recordTypeId = @config.callReportRecordTypeId
    @callReport.signatureDate = @signatureDate
    @callReport.duration = @duration
    @callReport.type = CallReport.TYPE_ONE_TO_ONE
    @callReport.jointVisit = @_jointVisitValue()
    @callReport.jointVisitUserSfid = @_jointVisitUserId()
    @callReport.generalComments = @elComment[0].getValue()
    @callReport.nextCallObjective = @elObjective[0].getValue()
    @callReport.signature = @signatureBase64
    @callReport.typeOfVisit = @_typeOfVisitValue()
    if @isPortfolioSellingModuleEnabled then @_assignPortfolioPrios() else @_assignProducts()
    callsCollection = new CallsCollection
    callsCollection.updateEntity(@callReport)
    .then (callReport) =>
      callReportEntity = callsCollection.parseEntity callReport
      callReportEntity.getContact()
      .then (contact) =>
        @_updateTargetFrequencies(callReportEntity, contact)
        .then =>
          callReportId = callReportEntity.attributes._soupEntryId
          @_saveCallData callReportId
          @callPromoAdjustmentsCollection.callReportSave()
          AlarmManager.scheduleNextVisits()
          @postNotification 'appointmentChanged'
          @postNotification 'callReportCreated'
          @_navigateToView callReportEntity.id

  _assignPortfolioPrios: =>
    portfolioPrios = @portfolio.getPortfolioPrios()
    portfolioPrios.forEach (prio,index) =>
      return unless prio.patientProfileId
      productNumber = index + 1
      @callReport['patientProfile' + productNumber] = prio.patientProfileId
      @callReport['prio' + productNumber + 'ProductSfid'] = prio.productId
      @callReport['noteForPrio' + productNumber] = prio.noteForProduct
      @callReport['prio' + productNumber + 'MarketingMessage1'] = prio.productMessage1
      @callReport['prio' + productNumber + 'MarketingMessage2'] = prio.productMessage2
      @callReport['prio' + productNumber + 'MarketingMessage3'] = prio.productMessage3
      @callReport['prio' + productNumber + 'Classification'] = prio.classification
      @callReport['promotionalItemsPrio' + productNumber] = prio.isPromotional
    summaryEntity = @portfolio.getPortfolioSummary()
    @callReport.patientSupportProgram = summaryEntity.patientSupportProgram
    @callReport.patientSupportProgramComments = summaryEntity.patientSupportProgramComments
    @callReport.portfolioFeedback = summaryEntity.portfolioFeedback
    @callReport.fullPortfolioPresentationReminder = summaryEntity.fullPortfolioPresentationReminder

  _assignProducts: =>
    products = @productsTable.getProducts()
    products.forEach (product, index) =>
      return unless product.productId
      productNumber = index + 1
      @callReport['prio' + productNumber + 'ProductSfid'] = product.productId
      @callReport['noteForPrio' + productNumber] = product.productComment
      @callReport['prio' + productNumber + 'MarketingMessage1'] = product.productMessage1
      @callReport['prio' + productNumber + 'MarketingMessage2'] = product.productMessage2
      @callReport['prio' + productNumber + 'MarketingMessage3'] = product.productMessage3
      @callReport['promotionalItemsPrio' + productNumber] = product.isPromotional

  _updateTargetFrequencies: (callReport, contact) =>
    @_updateTargetFrequency(contact, callReport)
    .then(@_fetchReferenceForContact)
    .then((reference) => if reference? then @_updateTargetFrequencyForReference(reference, callReport) else $.when())
    .then => callReport

  _fetchReferenceForContact: (contact) =>
    fieldsValues = {}
    refsCollection = new ReferencesCollection
    fieldsValues[refsCollection.model.sfdc.contactSfId] = contact.id
    refsCollection.fetchAllWhere(fieldsValues)
    .then (response) =>
      filteredRefs = response.records.filter (reference) ->
        reference.organizationSfId is contact.organizationSfId
      _.first(filteredRefs) ? refsCollection.getEntityFromResponse response

module.exports = ConvertCallReport