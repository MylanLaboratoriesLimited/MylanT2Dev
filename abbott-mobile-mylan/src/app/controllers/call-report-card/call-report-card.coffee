Spine = require 'spine'
FullscreenPanel = require 'controllers/base/panel/fullscreen-panel'
ReferencesCollection = require 'models/bll/references/references-collection'
CommentView = require 'controls/comment-view/comment-view'
ListPopup = require 'controls/popups/list-popup'
ListPopupWithBackBtn = require 'controls/popups/list-popup-with-back-btn'
JointVisitPickListDatasource = require 'controllers/call-report-card/joint-visit-picklist-datasource'
TypeOfVisitPickListDatasource = require 'controllers/call-report-card/type-of-visit-picklist-datasource'
DurationFilter = require 'controls/filters/duration-filters/duration-filter'
CallReportCardProductsTable = require 'controllers/call-report-card/call-report-card-products-table'
DateTimePicker = require 'controls/datepicker/date-time-picker'
Utils = require 'common/utils'
ConfirmationPopup = require 'controls/popups/confirmation-popup'
Users = require 'controllers/users/users'
CallReport = require 'models/call-report'
CallsCollection = require 'models/bll/call-reports-collection/calls-collection'
Query = require 'common/query'
ConfigurationManager = require 'db/configuration-manager'
PickList = require 'controls/pick-list/pick-list'
ContactsCollection = require 'models/bll/contacts-collection'
TargetFrequency = require 'models/target-frequency'
CommonInput = require 'controls/common-input/common-input'
HeaderBaseControl = require 'controls/header-controls/header-base-control'
Header = require 'controls/header/header'
SignatureView = require 'controllers/signature-view/signature-view'
AlertPopup = require 'controls/popups/alert-popup'
PresentationsFileManager = require 'common/presentation-managers/presentations-file-manager'
CallReportDataCollection = require 'models/bll/clm-call-report-data-collection'
PresentationViewer = require 'controllers/presentation-viewer/presentation-viewer'
Scenarios = require 'controllers/agenda/scenarios'
TradeModule = require 'controllers/trade-module/trade-module'
JSON2KPI = require 'common/json2kpi'
KpiHandler = require 'common/kpi-handler'
ScenariosCollection = require 'models/bll/scenarios-collection'
PresentationScenarioViewer = require 'controllers/presentation-viewer/presentation-scenario-viewer'
PromotionAccountsCollection = require 'models/bll/promotion-accounts-collection'
SettingsManager = require 'db/settings-manager'
PromoAdjustmentsCollection = require 'db/trade-module-managers/promo-adjustments-collection'
SforceDataContext = require 'models/bll/sforce-data-context'
Portfolio = require 'controllers/call-report-card/portfolio/portfolio'
Locale = require 'common/localization/locale'
ProductsCollection = require 'models/bll/products-collection'

# TODO: REFACTOR !!!
class CallReportCard extends FullscreenPanel
  className: 'call-report card'

  events:
    'tap .call-report-card-customer': '_onCustomerTap'
    'tap .call-report-card-organization': '_onOrganizationTap'
    'tap .call-report-card-signature': '_onSignatureTap'
    'tap': '_blurInputs'

  elements:
    '.call-report-card-customer': 'elCustomer'
    '.call-report-card-organization': 'elOrganization'
    '.call-report-card-speciality': 'elSpecialty'
    '.call-report-card-user': 'elUser'
    '.call-report-card-date-time': 'elDateTime'
    '.call-report-card-duration ': 'elDuration'
    '.call-comments': 'elComment'
    '.call-objectives': 'elObjective'
    '.call-report-card-joint-visit': 'elJointVisit'
    '.call-report-card-type-of-visit': 'elTypeOfVisit'
    '.call-report-card-joint-visit-user': 'elJointVisitUser'
    '.call-report-card-signature': 'elSignature'
    '.signature': 'elSignatureWrapper'
    '.signature-taken': 'elSignatureTakenWrapper'
    '.type-of-visit': 'elTypeOfVisitWrapper'
    '.call-report-card-type': 'elType'
    '.call-report-card-target-customer': 'elTargetCustomer'
    '.call-report-card-target-prority': 'elTargetPriority'
    '.call-report-card-signature-date': 'elSignatureDate'
    '.products-table': 'elProductsTable'
    '.wrapper': 'elWrapper'
    '.wrapper>.scroll-content': 'elScrollContent'
    '.comment-block.left': 'elCallCommentsSection'
    '.comment-block.right': 'elNextCallObjectiveSection'
    '.comments-group': 'elCommentsGroup'

  _productCount: 6
  _maxProductCount: 10
  maxCommentStringLength: 32000

  constructor: (@referenceId) ->
    super
    @productsCallData = {}
    @activeUser = null
    @callReport = null
    @callPromoAdjustmentsCollection = new PromoAdjustmentsCollection

  active: ->
    super
    @_resetChangeFlags()
    ConfigurationManager.getConfig()
    .then (@config) => @_initProductsPickList()
    .then @_init

  _blurInputs: =>
    @el.find(':focus').blur()

  _initProductsPickList: ->
    @_getActiveUser()
    .then @_fetchAllProductsByAtc

  _getActiveUser: =>
    SforceDataContext.activeUser()
    .then (@activeUser) => @activeUser

  _fetchAllProductsByAtc: =>
    @_productsDataSource = []
    productsCollection = new ProductsCollection()
    atcClassArray = @activeUser.pinCode.split ' '
    productsCollection.fetchAllWhereIn(productsCollection.model.sfdc.atcClass, atcClassArray)
    .then (response) =>
      @_products = response.records
      @_products.forEach (product) =>
        if product and product.id
          @_productsDataSource.push { id: product.id, description: product.name, presentationId: product.presentationId }

  _resetChangeFlags: =>
    @productsTable?.resetChangeFlags()
    @isChanged = false

  _init: =>
    @_getSandboxCallReport()
    .then (@callReport) =>
      @_startTime = new Date().getTime()
      @render()
      @_bindEvents()
      @_initJointVisitPickList()
      @_initDurationFilter()
      .then =>
        @_initTypeOfVisitPickList()
        @originDateTime = new Date
        @jointVisitUser = null
        @isFirstProduct = false
        @_clearSignature()
        @_applyConfig()

  render: ->
    @html @template()
    @_initHeader()
    unless @_isCallCommentShown() and @_isNextCallObjectiveShown()
      @elCallCommentsSection.hide() unless @_isCallCommentShown()
      @elNextCallObjectiveSection.hide()  unless @_isNextCallObjectiveShown()
      @elCommentsGroup.addClass('single')
    else
      @elCommentsGroup.removeClass('single')
    @_applyProductConfig()
    Locale.localize @el
    SettingsManager.getValueByKey('isPortfolioSellingModuleEnabled')
    .then (@isPortfolioSellingModuleEnabled) =>
      if @isPortfolioSellingModuleEnabled then @_initPortfolio() else @_initProducts()
      @_fillGeneralInfo()
    @

  template: ->
    require('views/call-report-card/call-report-card')()

  _initHeader: ->
    callReportHeader = new Header @_headerTitle()
    callReportHeader.render()
    SettingsManager.getValueByKey('isTradeModuleEnabled')
    .then (isTradeEnabled) =>
      @_addTradeBtnToHeader callReportHeader if isTradeEnabled
      SettingsManager.getValueByKey('isDynamicAgendaEnabled')
    .then (@isAgendaEnabled) =>
      @_addDynamicAgendaBtnToHeader callReportHeader if @isAgendaEnabled
      SettingsManager.getValueByKey('isEdetailingEnabled')
    .then (@isEdetailingEnabled) =>
      @_addPresentationsBtnToHeader callReportHeader if @isEdetailingEnabled
      @_addSaveBtnToHeader callReportHeader
      @setHeader callReportHeader

  _addDynamicAgendaBtnToHeader: (callReportHeader)->
    dynamicAgendaBtn = new HeaderBaseControl '', 'dynamic-agenda-btn'
    dynamicAgendaBtn.bind 'tap', @_openDynamicAgenda
    callReportHeader.addRightControlElement dynamicAgendaBtn.el

  _addPresentationsBtnToHeader: (callReportHeader)->
    presentationsBtn = new HeaderBaseControl Locale.value('common:buttons.Presentations'), 'ctrl-btn'
    presentationsBtn.bind 'tap', @_presentationsBtnTap
    callReportHeader.addRightControlElement presentationsBtn.el

  _addTradeBtnToHeader: (callReportHeader) ->
    tradeModuleBtn = new HeaderBaseControl Locale.value('common:buttons.TradeModule'), 'ctrl-btn'
    tradeModuleBtn.bind 'tap', @_openTradeModule
    callReportHeader.addRightControlElement tradeModuleBtn.el

  _addSaveBtnToHeader: (callReportHeader)->
    @saveBtn = new HeaderBaseControl Locale.value('common:buttons.SaveBtn'), 'ctrl-btn'
    @saveBtn.bind 'tap', @_saveCallReport
    callReportHeader.addRightControlElement @saveBtn.el

  _openTradeModule: =>
    promotionAccountsCollection = new PromotionAccountsCollection pageSize: 1
    promotionAccountsCollection.getActualPromotionsForAccount @_organizationIdForTradeModule(), moment()
    .then (promotionAccounts) =>
      unless promotionAccounts.length then @_showNoPromotionsToast()
      else @_showTradeModule()

  _showTradeModule: =>
    parsedCallReport = new CallsCollection().parseEntity @callReport
    tradeModule = new TradeModule @_organizationIdForTradeModule(), parsedCallReport, @callPromoAdjustmentsCollection
    tradeModule.on 'dataChanged', @_callReportChanged
    @stage.push tradeModule

  _organizationIdForTradeModule: ->
    @reference.organizationSfId

  _showNoPromotionsToast: ->
    $.fn.dpToast Locale.value("card.CallReport.ToastMessage.NoPromosForOrganization")

  _openDynamicAgenda: =>
    @stage.push(new Scenarios)

  _headerTitle: ->
    Locale.value('card.CallReport.HeaderTitle')

  _applyProductConfig: ->
    if @config.callReportProductsSettings
      productSettings = @config.callReportProductsSettings
      limit = if productSettings.numberOfPromotedProducts then productSettings.numberOfPromotedProducts else @_productCount
      @_productCount = Math.min @_maxProductCount, limit

  _initProducts: ->
    @productsTable = new CallReportCardProductsTable @_productCount
    @productsTable.on 'presentModalController', @_onPresentModalController
    @productsTable.on 'dismissModalController', @dismissModalController
    @elScrollContent.append @productsTable.el
    @productsTable.render()

  _initPortfolio: ->
    @el.addClass "portfolio-mode"
    @portfolio = new Portfolio @_productCount
    @portfolio.on 'presentModalController', @_onPresentModalController
    @portfolio.on 'dismissModalController', @dismissModalController
    @portfolio.on 'fullScreenTap', @_toggleFullScreen
    @elScrollContent.append @portfolio.el
    @portfolio.render(Utils.currentDate @originDateTime)

  _toggleFullScreen: =>
    @_blurInputs()
    @el.toggleClass 'full-screen-mode'
    @portfolio.refresh()

  _onPresentModalController: (filterPopup) =>
    @presentModalController filterPopup

  _fillGeneralInfo: ->
    @_initComment ''
    @_initObjective ''
    collection = new ReferencesCollection
    collection.fetchEntityById(@referenceId)
    .then (@reference) =>
      @elCustomer.html "#{@reference.contactFullName()} <br/> #{@reference.contactRecordType}"
      @elOrganization.html @reference.organizationNameAndAddress()
      @elDateTime.html Utils.currentDateTime @originDateTime
      @reference.getContact()
    .then (contact) =>
      @elSpecialty.html contact.abbottSpecialty
    .then @_setActiveUser

  _initComment: (value) ->
    # TODO: CommonInput like control
    @elComment.val value
    new CommonInput @elWrapper[0], @elComment[0]
    @elComment.on 'change', @_callReportChanged

  _initObjective: (value)->
    # TODO: CommonInput like control
    @elObjective.val value
    new CommonInput @elWrapper[0], @elObjective[0]
    @elObjective.on 'change', @_callReportChanged

  _callReportChanged: =>
    @isChanged = true

  _setActiveUser: =>
    @elUser.html @activeUser?.fullName()

  _presentationsBtnTap: =>
    if @isAgendaEnabled then @_showPresentationsPopup() else @_showProductsPopup()

  _showPresentationsPopup: =>
    #TODO create
    @_mediaDataSource = [
      {id: "scenarios", description: Locale.value('common:names.Scenarios')},
      {id: "products", description: Locale.value('common:names.Products')}
    ]
    presentationsPopup = new ListPopup @_mediaDataSource, @_mediaDataSource[0], ''
    presentationsPopup.customStyleClass 'no-checkbox call-report-presentations'
    presentationsPopup.bind 'onPopupItemSelected', @_onPresentationPopupSelected
    @presentModalController presentationsPopup

  _onPresentationPopupSelected: (item)=>
    @dismissModalController()
    switch item.id
      when "scenarios" then @_getScenarios().then(@_showScenariosPopup)
      when "products" then @_showProductsPopup()

  _getScenarios: =>
    scenariosCollection = new ScenariosCollection()
    scenariosCollection.fetchAll()
    .then (response) =>
      @_scenariosDataSource = response.records.map (entity) => {id: entity._soupEntryId, description: entity.name, entity: entity}

  _showScenariosPopup: =>
    if @_scenariosDataSource.length
      scenariosPopup = new ListPopupWithBackBtn @_scenariosDataSource, @_scenariosDataSource[0], ''
      scenariosPopup.customStyleClass 'no-checkbox call-report-presentations'
      scenariosPopup.bind 'onPopupItemSelected', @_showScenario
      scenariosPopup.bind 'backbutton', => setTimeout @_showPresentationsPopup, 0
      @presentModalController scenariosPopup

  _showScenario: (item) =>
    presentationScenarioViewer = new PresentationScenarioViewer(item.entity)
    presentationScenarioViewer.on 'complete', =>
      @_collectKPI(presentationScenarioViewer)
      .then -> presentationScenarioViewer.closePresentation()
    presentationScenarioViewer.openPresentation()
    @dismissModalController()

  _showProductsPopup: =>
    presentationsPopup = new ListPopupWithBackBtn @_productsDataSource, @_productsDataSource[0], ''
    presentationsPopup.customStyleClass 'no-checkbox call-report-presentations'
    presentationsPopup.bind 'onPopupItemSelected', @_showProductPresentation
    presentationsPopup.bind 'backbutton', =>
      if @isAgendaEnabled
        setTimeout @_showPresentationsPopup, 0
      else
        @dismissModalController()
    @presentModalController presentationsPopup

  _showProductPresentation: (product) =>
    @_showOpenPresentationError 'PresentationNotExist' unless product.presentationId
    PresentationsFileManager.presentationExist(product.presentationId)
    .done =>
      @_callReportChanged()
      @_openPresentation product
    .fail =>
      @dismissModalController()
      @_showOpenPresentationError 'PresentationNotLoaded'

  _openPresentation: (displayProduct) =>
    presentationViewer = new PresentationViewer(displayProduct.presentationId)
    presentationViewer.on 'didLoad', @dismissModalController
    presentationViewer.on 'complete', =>
      @_collectKPI(presentationViewer, displayProduct)
      .then -> presentationViewer.closePresentation()
    presentationViewer.openPresentation()

  _collectKPI: (presentationViewer, displayProduct) =>
    presentationViewer.getKPI()
    .then (kpiJsonString) => @_mergeScenarioProducts kpiJsonString, displayProduct

  _addProductKpi: (product, callData) =>
    _.extend callData, {productId: product.id}
    @productsCallData[callData.productId] = callData

  _mergeScenarioProducts: (kpiJsonString, displayProduct) =>
    return unless kpiJsonString
    @_products.forEach (product) =>
      kpiJson = JSON.parse kpiJsonString
      callData = @productsCallData[product.id]
      if callData
        kpiSaved = JSON.parse callData.kpiSrcJson
        productKpi = KpiHandler.getKPIByProduct(kpiJson, kpiSaved, product, displayProduct)
        @_addProductKpi(product, JSON2KPI.parse(KpiHandler.mergeKPI kpiSaved, productKpi)) if productKpi.slides.length
      else
        productKpi = KpiHandler.getKPIByProduct(kpiJson, null, product, displayProduct)
        @_addProductKpi(product, JSON2KPI.parse(JSON.stringify productKpi)) if productKpi.slides.length

  _showOpenPresentationError: (errorKey) =>
    alertPopup = new AlertPopup {
      caption: Locale.value("card.CallReport.Alerts.#{errorKey}.caption")
      message: Locale.value("card.CallReport.Alerts.#{errorKey}.message")
    }
    alertPopup.on 'yesClicked', @dismissModalController
    @presentModalController alertPopup

  _bindEvents: ->
    @elDuration.on 'tap', @_onDurationTap
    @elDateTime.on 'tap', @_showDateTimePicker
    @elJointVisitUser.on 'tap', @_onJointVisitUserTap

  _onDurationTap: =>
    DurationFilter.resources()
    .then (resources)=>
      datasource = resources
      filterPopup = new ListPopup datasource, @durationFilter, Locale.value('card.DurationPopup.Title')
      filterPopup.bind 'onPopupItemSelected', (selectedItem) =>
        @durationFilter = selectedItem.model
        @elDuration.html @durationFilter.value
        @dismissModalController()
        @duration = @durationFilter.value
        @_callReportChanged()
      @presentModalController filterPopup

  _showDateTimePicker: =>
    unless @originDateTime then @originDateTime = new Date()
    dateTimePicker = new DateTimePicker @originDateTime, { beforeKey: 'daysCallReport', afterDays: 0 }
    dateTimePicker.on 'onDonePressed', (result) =>
      @dismissModalController()
      if @isPortfolioSellingModuleEnabled
        @_setDateTimeForPortfolioMode result
      else
        @_setDateTimeForProductMode result
    @presentModalController dateTimePicker

  _setDateTimeForPortfolioMode: (result) ->
    if @portfolio.isProfilesChanged()
      @_showApplyResultConfirmation result
    else
      @_setDateTime result
      @portfolio.resetProfiles(Utils.currentDate @originDateTime)

  _showApplyResultConfirmation: (result) ->
    confirm = new ConfirmationPopup {message: Locale.value('card.CallReport.Portfolio.DateApplyConfirmation')}
    confirm.bind 'yesClicked', =>
      @dismissModalController()
      @_setDateTime result
      @portfolio.resetProfiles(Utils.currentDate @originDateTime)
    confirm.bind 'noClicked', =>
        @dismissModalController()
    @presentModalController confirm

  _setDateTimeForProductMode: (result)->
    @_setDateTime(result)

  _setDateTime: (result) =>
    @originDateTime = result
    @elDateTime.html Utils.currentDateTime result
    @_callReportChanged()

  _onJointVisitUserTap: =>
    users = new Users @jointVisitUser
    users.on 'onClose', (user) =>
      if user
        @elJointVisitUser.html user.fullName()
        @jointVisitUser = user
        @elJointVisitUser.removeClass 'placeholder'
      else
        @elJointVisitUser.html Locale.value('card.GeneralInfoFields.JointVisitUserPlaceholder')
        @jointVisitUser = null
        @elJointVisitUser.addClass 'placeholder'
      @_callReportChanged()
    @stage.push users

  _onCustomerTap: =>
    ContactCard = require 'controllers/contact-card/contact-card'
    @stage.push(new ContactCard @reference.contactSfId)

  _onOrganizationTap: =>
    OrganizationCard = require 'controllers/organization-card/organization-card'
    @stage.push(new OrganizationCard @reference.organizationSfId)

  _initJointVisitPickList: =>
    @jointVisitPickList = new PickList @, @elJointVisit, new JointVisitPickListDatasource, @callReport?.jointVisit or null
    @jointVisitPickList.bind 'onPickListItemSelected', => @_callReportChanged()

  _initDurationFilter: =>
    DurationFilter.resources()
    .then (resources)=>
      @durationFilter = resources.defaultValue
      @elDuration.html @durationFilter.value
      @duration = @durationFilter.value

  _initTypeOfVisitPickList: =>
    @typeOfVisitPickList = new PickList @, @elTypeOfVisit, new TypeOfVisitPickListDatasource, @callReport?.typeOfVisit or null
    @typeOfVisitPickList.bind 'onPickListItemSelected', => @_callReportChanged()

  _clearSignature: ->
    @signatureBase64 = null
    @signatureDate = null

  _applyConfig: ->
    if @config.sampleManagementSettings
      @_isRequireSignature = @config.sampleManagementSettings.signatureRequired
      @_isFirstMessageRequired = @config.sampleManagementSettings.firstMarketingMessageRequired
      unless (@config.sampleManagementSettings.signature or @_isRequireSignature)
        @elSignatureTakenWrapper.hide()
        @elSignatureWrapper.hide()
      @elProductsTable.addClass 'hide-comment' unless @config.sampleManagementSettings.note
      @elProductsTable.addClass 'hide-messages' unless @config.sampleManagementSettings.prioMarketingMessage
      @elProductsTable.addClass 'hide-promotion' unless @config.sampleManagementSettings.promotinalItems
      @elProductsTable.addClass 'hide-expand' unless (@config.sampleManagementSettings.promotinalItems or @config.sampleManagementSettings.prioMarketingMessage)
      @elTypeOfVisitWrapper.addClass 'hide-record-type' unless @config.sampleManagementSettings.callReportType

  # TODO: maybe should check if trade-module is enabled before clearing adjustmnets
  onBack: =>
    anyChanges = if @isPortfolioSellingModuleEnabled then @portfolio.isChanged() else @productsTable.isAnyProductChanged()
    @isChanged or= anyChanges
    unless @isChanged
      @_resetCallReport()
      .then => super
    else
      confirm = new ConfirmationPopup {caption: Locale.value('card.ConfirmationPopup.SaveChanges.Caption')}
      confirm.bind 'yesClicked', =>
        @dismissModalController()
        @_saveCallReport()
      confirm.bind 'noClicked', =>
        @dismissModalController()
        @_resetCallReport()
        .then => super
      @presentModalController confirm

  _resetCallReport: =>
    @_removeSandboxCallReport()
    @callPromoAdjustmentsCollection.resetCallReportData()

  _saveCallReport: =>
    # TODO: REFACTOR !!! As it is done on _onSaveTap in pe-card-create
    @_save() if @_validData()

  _validData: ->
    toastHeader = Locale.value('card.ToastMessage.RequiredFieldsHeader') + ":<br/>"
    toastBody = ""
    toastBody += "#{Locale.value('card.CallReport.ToastMessage.RequiredCallComments')}<br/>" if @_isCallCommentRequired() and @elComment[0].getValue().length is 0
    toastBody += "#{Locale.value('card.CallReport.ToastMessage.RequiredNextCallObjectives')}<br/>" if @_isNextCallObjectiveRequired() and @elObjective[0].getValue().length is 0
    toastBody += if @isPortfolioSellingModuleEnabled then @_validatePortfolioSection() else @_validateProductsSection()
    toastBody += "#{Locale.value('card.ToastMessage.RequiredJointVisitUser')}<br/>" if not @jointVisitUser and @_jointVisitSelected()
    toastBody += "#{Locale.value('card.ToastMessage.RequiredJointVisit')}<br/>" if @jointVisitUser and not @_jointVisitSelected()
    toastBody += "#{Locale.value('card.ToastMessage.RequiredSignature')}<br/>" if @_isRequireSignature and !@signatureBase64
    isDataValid = toastBody.length is 0
    toastMessage = toastHeader + toastBody
    $.fn.dpToast toastMessage unless isDataValid
    isDataValid

  _validatePortfolioSection: =>
    toastBody = ""
    toastBody += "#{Locale.value('card.CallReport.Portfolio.ToastMessage.PatientProfileRequirement')}<br/>" unless @portfolio.isFirstPationProfileSelected()
    toastBody += "#{Locale.value('card.CallReport.Portfolio.ToastMessage.ProductForProfileRequirement')}<br/>" unless @portfolio.isProductsSelectedForEachChoosenProfiles()
    toastBody += "#{Locale.value('card.CallReport.Portfolio.ToastMessage.ClassificationForProductRequirement')}<br/>" unless @portfolio.isClassificationSelectedForEachChoosenProduct()
    if @_isFirstMessageRequired and not @portfolio.isFirstMessageSelected()
      toastBody += "#{Locale.value('card.CallReport.ToastMessage.RequiredFirstMessage')}<br/>"
    toastBody

  _validateProductsSection: =>
    toastBody = ""
    toastBody += "#{Locale.value('card.CallReport.ToastMessage.RequiredFirstProduct')}<br/>" unless @productsTable.isFirstProductSelected()
    products = @productsTable.getProducts()
    if @_isFirstMessageRequired and (products.some (product) => if(product.productId) then product.productMessage1 is null else false)
      toastBody += "#{Locale.value('card.CallReport.ToastMessage.RequiredFirstMessage')}<br/>"
    toastBody

  _isCallCommentRequired: ->
    @config.sampleManagementSettings?.callCommentsMandatory and @_isCallCommentShown()

  _isNextCallObjectiveRequired: ->
    @config.sampleManagementSettings?.nextCallObjectiveRequired and @_isNextCallObjectiveShown()

  _isCallCommentShown: ->
    !@config.sampleManagementSettings or @config.sampleManagementSettings.showCallComments

  _isNextCallObjectiveShown: ->
    !@config.sampleManagementSettings or @config.sampleManagementSettings.showNextCallObjective

  _jointVisitSelected: ->
    @_jointVisitValue() isnt null

  _jointVisitValue: ->
    @jointVisitPickList.selectedValue

  _typeOfVisitValue: ->
    @typeOfVisitPickList.selectedValue

  _jointVisitUserId: ->
    @jointVisitUser?.id ? null

  _onSignatureTap: ->
    signatureView = new SignatureView
    signatureView.on 'saveTap', @_onSignatureSaveBtnTap
    @stage.push(signatureView)

  _onSignatureSaveBtnTap: (@signatureBase64) =>
    @signatureDate = Utils.originalDateTime(new Date)
    @_callReportChanged()
    @_initSignature()

  _initSignature: ->
    @elSignature.attr('src', 'data:image/jpeg;base64,' + @signatureBase64) if @signatureBase64

  _getSandboxCallReport: =>
    @callReport = {}
    @callReport.isSandbox = true
    @callReport['attributes'] = {type: CallReport.table}
    new CallsCollection().createEntity @callReport

  _removeSandboxCallReport: =>
    if @callReport.isSandbox then new CallsCollection().removeEntity @callReport else $.when()

  _save: =>
    @callReport.isSandbox = false
    @callReport[CallReport.sfdc.createdOffline] = true
    @callReport[CallReport.sfdc.createdFromMobile] = true
    @callReport[CallReport.sfdc.callWithIPad] = true
    @callReport[CallReport.sfdc.realCallDuration] = Utils.getDuration @_startTime, (new Date).getTime()
    @callReport[CallReport.sfdc.dateTimeOfVisit] = Utils.originalDateTime @originDateTime
    @callReport[CallReport.sfdc.dateOfVisit] = Utils.originalDate @originDateTime
    @callReport[CallReport.sfdc.organizationSfId] = @reference.organizationSfId
    @callReport[CallReport.sfdc.remoteOrganizationName] = @reference.organizationName
    @callReport.organizationName = @reference.organizationName
    @callReport[CallReport.sfdc.organizationCity] = @reference.organizationCity
    @callReport[CallReport.sfdc.organizationAddress] = @reference.organizationAddress
    @callReport[CallReport.sfdc.contactSfid] = @reference.contactSfId
    @callReport[CallReport.sfdc.remoteContactFirstName] = @reference.contactFirstName
    @callReport[CallReport.sfdc.remoteContactLastName] = @reference.contactLastName
    @callReport.contactFirstName = @reference.contactFirstName
    @callReport.contactLastName = @reference.contactLastName
    @callReport[CallReport.sfdc.contactRecordType] = @reference.contactRecordType
    @callReport[CallReport.sfdc.userFirstName] = @activeUser.firstName
    @callReport[CallReport.sfdc.userLastName] = @activeUser.lastName
    @callReport[CallReport.sfdc.userSfid] = @activeUser.id
    @callReport[CallReport.sfdc.duration] = @duration
    @callReport[CallReport.sfdc.type] = CallReport.TYPE_ONE_TO_ONE
    @callReport[CallReport.sfdc.recordTypeId] = @config.callReportRecordTypeId
    @callReport[CallReport.sfdc.jointVisit] = @_jointVisitValue()
    @callReport[CallReport.sfdc.jointVisitUserSfid] = @_jointVisitUserId()
    @callReport[CallReport.sfdc.generalComments] = @elComment[0].getValue()
    @callReport[CallReport.sfdc.nextCallObjective] = @elObjective[0].getValue()
    @callReport[CallReport.sfdc.signature] = @signatureBase64
    @callReport[CallReport.sfdc.signatureDate] = @signatureDate
    @callReport[CallReport.sfdc.typeOfVisit] = @_typeOfVisitValue()
    if @isPortfolioSellingModuleEnabled then @_assignPortfolioPrios() else @_assignProducts()
    @_assignPriority()
    .then(=> new CallsCollection().updateEntity @callReport)
    .then(@_updateTargetFrequencies)
    .then (callReport) =>
      callReportId = callReport.attributes._soupEntryId
      @_saveCallData(callReportId)
      .then => @callPromoAdjustmentsCollection.callReportSave()
      .then => @reference.getContact()
      .then (contact) =>
        @_navigateToView callReport.id
        @postNotification('callReportCreated')

  _saveCallData: (callReportId) =>
    callReportDataCollection = new CallReportDataCollection
    callDataKeys = Object.keys @productsCallData
    Utils.runSimultaneously _.map callDataKeys, (callDataKey) =>
      callData = @productsCallData[callDataKey]
      callData.callReportId = callReportId
      callReportDataCollection.createEntity callData

  _assignPortfolioPrios: =>
    portfolioPrios = @portfolio.getPortfolioPrios()
    portfolioPrios.forEach (prio,index) =>
      return unless prio.patientProfileId
      productNumber = index + 1
      @callReport[CallReport.sfdc['patientProfile' + productNumber]] = prio.patientProfileId
      @callReport[CallReport.sfdc['prio' + productNumber + 'ProductSfid']] = prio.productId
      @callReport[CallReport.sfdc['noteForPrio' + productNumber]] = prio.noteForProduct
      @callReport[CallReport.sfdc['prio' + productNumber + 'MarketingMessage1']] = prio.productMessage1
      @callReport[CallReport.sfdc['prio' + productNumber + 'MarketingMessage2']] = prio.productMessage2
      @callReport[CallReport.sfdc['prio' + productNumber + 'MarketingMessage3']] = prio.productMessage3
      @callReport[CallReport.sfdc['prio' + productNumber + 'Classification']] = prio.classification
      @callReport[CallReport.sfdc['promotionalItemsPrio' + productNumber]] = prio.isPromotional
    summaryEntity = @portfolio.getPortfolioSummary()
    @callReport[CallReport.sfdc.patientSupportProgram] = summaryEntity.patientSupportProgram
    @callReport[CallReport.sfdc.patientSupportProgramComments] = summaryEntity.patientSupportProgramComments
    @callReport[CallReport.sfdc.portfolioFeedback] = summaryEntity.portfolioFeedback
    @callReport[CallReport.sfdc.fullPortfolioPresentationReminder] = summaryEntity.fullPortfolioPresentationReminder

  _assignProducts: =>
    products = @productsTable.getProducts()
    products.forEach (product, index) =>
      return unless product.productId
      productNumber = index + 1
      @callReport[CallReport.sfdc['prio' + productNumber + 'ProductSfid']] = product.productId
      @callReport[CallReport.sfdc['noteForPrio' + productNumber]] = product.productComment
      @callReport[CallReport.sfdc['prio' + productNumber + 'MarketingMessage1']] = product.productMessage1
      @callReport[CallReport.sfdc['prio' + productNumber + 'MarketingMessage2']] = product.productMessage2
      @callReport[CallReport.sfdc['prio' + productNumber + 'MarketingMessage3']] = product.productMessage3
      @callReport[CallReport.sfdc['promotionalItemsPrio' + productNumber]] = product.isPromotional

  _assignPriority: =>
    @reference.getContact()
    .then (contact) => @callReport[CallReport.sfdc.targetPriority] = contact.priority

  _updateTargetFrequencies: (callReport) =>
    callReportsCollection = new CallsCollection
    callReportEntity = callReportsCollection.parseEntity callReport
    @reference.getContact()
    .then((contact) => @_updateTargetFrequency contact, callReportEntity)
    .then(=> @_updateTargetFrequencyForReference @reference, callReportEntity)
    .then(=> callReportEntity)

  _updateTargetFrequency: (contact, callReport) =>
    unless contact.lastDateTargetFrequency then $.when contact
    else
      atCalls = contact.lastDateTargetFrequency.actualCallsCount ? 0
      contact.lastDateTargetFrequency.actualCallsCount = ++atCalls
      contact.lastDateTargetFrequency.lastCallReportDate = callReport.dateTimeOfVisit
      contactsCollection = new ContactsCollection
      contactsCollection.updateEntity(contact)
      .then contactsCollection.parseEntity

  _updateTargetFrequencyForReference: (reference, callReport) =>
    atCalls = reference.atCalls.split '/'
    actualCallsCount = 0
    targetCycleFrequency = 0
    if atCalls.length > 1
      actualCallsCount = parseInt atCalls[0]
      targetCycleFrequency = parseInt atCalls[1]
    actualCallsCount++
    reference.atCalls = "#{actualCallsCount}/#{targetCycleFrequency}"
    reference.lastCall = "#{Utils.dotFormatDate(callReport.dateTimeOfVisit)} <br/> #{callReport.userFullName()}"
    refsCollection = new ReferencesCollection
    refsCollection.updateEntity(reference)
    .then refsCollection.parseEntity

  _navigateToView: (callReportId) =>
    CallReportCardView = require 'controllers/call-report-card/call-report-card-view'
    @stage.popAndPush(new CallReportCardView callReportId)

module.exports = CallReportCard