CallReportCard = require 'controllers/call-report-card/call-report-card'
Utils = require 'common/utils'
CallsCollection = require 'models/bll/call-reports-collection/calls-collection'
CallReportCardProductsTable = require 'controllers/call-report-card/call-report-card-products-table'
ProductsCollection = require 'models/bll/products-collection'
MarketingMessagesCollection = require 'models/bll/marketing-messages-collection'
Query = require 'common/query'
CallReport = require 'models/call-report'
CallReportPickListManager = require 'db/picklist-managers/callreport-picklist-manager'
HeaderBaseControl = require 'controls/header-controls/header-base-control'
Header = require 'controls/header/header'
TradeModule = require 'controllers/trade-module/trade-module'
SettingsManager = require 'db/settings-manager'
Portfolio = require 'controllers/call-report-card/portfolio/portfolio'

class CallReportCardView extends CallReportCard
  className: 'call-report card view-mode'

  ANY_COMMENTS: 'Any comments.'

  constructor: (@callReportId) ->
    super
    @callReportPickListManager = new CallReportPickListManager

  enableFullScreenMode: ->

  disableFullScreenMode: ->

  _onCustomerTap: =>
    ContactCard = require 'controllers/contact-card/contact-card'
    @stage.push(new ContactCard @callReport.contactSfid)

  _onOrganizationTap: =>
    OrganizationCard = require 'controllers/organization-card/organization-card'
    @stage.push(new OrganizationCard @callReport.organizationSfId)

  _onSignatureTap: ->

  _init: =>
    callsCollection = new CallsCollection
    keyValue = {}
    keyValue[CallReport.sfdc.id] = @callReportId
    callsCollection.fetchAllWhere(keyValue)
    .then (response) =>
      @callReport = callsCollection.getEntityFromResponse response
    .then =>
      @render()
      @_applyConfig()

  _headerTitle: ->
    Locale.value('card.CallReport.ViewHeaderTitle')

  _initHeader: ->
    callReportHeader = new Header @_headerTitle()
    callReportHeader.render()
    SettingsManager.getValueByKey('isTradeModuleEnabled')
    .then (isTradeEnabled) =>
      @_addTradeBtnToHeader callReportHeader if isTradeEnabled
      @setHeader callReportHeader

  _showTradeModule: =>
    @stage.push(new TradeModule @_organizationIdForTradeModule(), @callReport, @callPromoAdjustmentsCollection, true)

  _organizationIdForTradeModule: ->
    @callReport.organizationSfId

  template: ->
    require('views/call-report-card/call-report-card-view')()

  _addComment: (comment, element) ->
    if comment and comment.replace(/\n/gim, '').length > 0
      element[0].innerText = comment
    else
      element.addClass 'placeholder'
      element.html @ANY_COMMENTS

  _fillJointVisit: ->
    @callReportPickListManager.getLabelByValue(CallReport.sfdc.jointVisit, @callReport.jointVisit)
    .then (label) => @elJointVisit.html label

  _fillTypeOfVisit: ->
    @callReportPickListManager.getLabelByValue(CallReport.sfdc.typeOfVisit, @callReport.typeOfVisit)
    .then (label) => @elTypeOfVisit.html label

  _fillGeneralInfo: ->
    @elDateTime.html Utils.formatDateTime @callReport.dateTimeOfVisit
    @elOrganization.html @callReport.organizationNameAndAddress()
    @elCustomer.html "#{@callReport.contactFullName()} <br/> #{@callReport.contactRecordType}"
    @callReport.getSpecialty()
    .then (specialty) => @elSpecialty.html specialty
    @elType.html @callReport.type
    @elUser.html @callReport.userFullName()
    @callReport.getIsTargetCustomer()
    .then (isTargetCustomer) => @elTargetCustomer.html isTargetCustomer
    @callReport.getContact()
    .then (contact) => @elTargetPriority.html contact.priority
    @_fillJointVisit()
    @_fillTypeOfVisit()
    @callReport.getJointVisitUser()
    .then => @elJointVisitUser.html @callReport.jointVisitUser?.fullName()
    if @callReport.signatureDate
      @elSignatureDate.html Utils.formatDateTime @callReport.signatureDate
    @_addComment @callReport.generalComments, @elComment
    @_addComment @callReport.nextCallObjective, @elObjective

  _initProducts: ->
    @productsTable = new CallReportCardProductsTable @_productCount, @productsWithMessages
    @elScrollContent.append @productsTable.el
    @productsTable.render @callReport

  _initPortfolio: ->
    @el.addClass "portfolio-mode"
    @portfolio = new Portfolio @_productCount, @callReport
    @portfolio.on 'presentModalController', @_onPresentModalController
    @portfolio.on 'dismissModalController', @dismissModalController
    @portfolio.on 'fullScreenTap', @_toggleFullScreen
    @elScrollContent.append @portfolio.el
    @portfolio.render()

module.exports = CallReportCardView