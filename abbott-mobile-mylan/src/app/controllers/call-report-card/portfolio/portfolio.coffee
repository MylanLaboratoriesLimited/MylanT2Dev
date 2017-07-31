Profiles = require 'controllers/call-report-card/portfolio/profiles'
Summary = require 'controllers/call-report-card/portfolio/summary'
ProductsCollection = require 'models/bll/products-collection'
MarketingMessagesCollection = require 'models/bll/marketing-messages-collection'
SforceDataContext = require 'models/bll/sforce-data-context'
ProfileProductInPortfoliosCollection = require 'models/bll/profile-product-in-portfolios-collection'
SummaryEntity = require 'controllers/call-report-card/portfolio/summary-entity'
Locale = require 'common/localization/locale'
Utils = require 'common/utils'

class Portfolio extends Spine.Controller
  className: 'portfolio'

  events:
    'tap .full-screen-btn': '_onFullScreenTap'

  elements:
    '.scroll-content':'elScrollContent'

  constructor: (@productCount, @callReport)->
    super {}
    @profiles = null

  refresh: ->
    @profiles.refresh()

  render: (date) ->
    @html @template()
    Locale.localize @el
    date or= Utils.currentDate()
    @_renderProfilesByDate(date)
    .then(@_renderSummary)
    @

  resetProfiles: (date)->
    @profiles.release()
    @_renderProfilesByDate(date)

  template: ->
    require('views/call-report-card/portfolio/portfolio')()

  _renderProfilesByDate: (date)=>
    @_getProfileProductsWithMessagesByDate(date)
    .then (profileProductsWithMessages) =>
      profileProducts = profileProductsWithMessages.map (profileProductsWithMessage) -> profileProductsWithMessage.profileProduct
      @profiles = new Profiles @productCount, profileProducts, profileProductsWithMessages, @callReport
      @profiles.on 'presentModalController', @_onPresentModalController
      @profiles.on 'dismissModalController', @_onDismissModalController
      @elScrollContent.prepend @profiles.el
      @profiles.render()
      $.when()

  _renderSummary: =>
    summaryEntity = if @_isViewMode() then @_getSummaryEntityFromCallReport() else new SummaryEntity
    @summary = new Summary summaryEntity
    @summary.on 'presentModalController', @_onPresentModalController
    @summary.on 'dismissModalController', @_onDismissModalController
    @elScrollContent.append @summary.el
    @summary.render()

  _getProfileProductsWithMessagesByDate: (date)=>
    profileProducts = []
    marketingMessagesCollection = new MarketingMessagesCollection()
    @_fetchProfileProductsByDate(date)
    .then (portfolioProfileProducts) ->
      profileProducts = portfolioProfileProducts
      marketingMessagesCollection.fetchAll()
    .then marketingMessagesCollection.getAllEntitiesFromResponse
    .then (messages) => @_prepareProfileProductsWithMessages profileProducts, messages

  _fetchProfileProductsByDate: (date)=>
    profileProductInPortfoliosCollection = new ProfileProductInPortfoliosCollection
    if @_isViewMode()
      profileProductInPortfoliosCollection.fetchAll()
      .then profileProductInPortfoliosCollection.getAllEntitiesFromResponse
    else
      profileProductInPortfoliosCollection.fetchPortfolioProfilesByDate(date)

  _isViewMode: =>
    !!@callReport

  _prepareProfileProductsWithMessages: (profileProducts, messages)=>
    profileProductsWithMessages = []
    profileProducts.forEach (profileProduct) =>
      if profileProduct and profileProduct.id
        profileProductWithMessages = {}
        profileProductWithMessages.profileProduct = profileProduct
        profileProductWithMessages.messages = messages.filter (message) -> message.produtSfId is profileProduct.productSfId
        profileProductsWithMessages.push profileProductWithMessages
    profileProductsWithMessages

  _getSummaryEntityFromCallReport: ->
    summaryEntity = new SummaryEntity
    summaryEntity.patientSupportProgram = @callReport.patientSupportProgram
    summaryEntity.patientSupportProgramComments = @callReport.patientSupportProgramComments
    summaryEntity.portfolioFeedback = @callReport.portfolioFeedback
    summaryEntity.fullPortfolioPresentationReminder = @callReport.fullPortfolioPresentationReminder
    summaryEntity

  _onPresentModalController: (popup)=>
    @trigger 'presentModalController', popup

  _onDismissModalController: =>
    @trigger 'dismissModalController'

  _onFullScreenTap: =>
    @trigger 'fullScreenTap', @

  isFirstPationProfileSelected: ->
    @profiles.isFirstPationProfileSelected()

  isProductsSelectedForEachChoosenProfiles: ->
    @profiles.isProductsSelectedForEachChoosenProfiles()

  isClassificationSelectedForEachChoosenProduct: ->
    @profiles.isClassificationSelectedForEachChoosenProduct()

  isFirstMessageSelected: ->
    @profiles.isFirstMessageSelected()

  getPortfolioPrios: ->
    @profiles.getPrios()

  getPortfolioSummary: ->
    @summary.summaryEntity

  isChanged: ->
    @profiles.isChanged() or @summary.isChanged

  isProfilesChanged: ->
    @profiles.isChanged()


module.exports = Portfolio