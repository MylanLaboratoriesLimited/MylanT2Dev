ProfileItem = require 'controllers/call-report-card/portfolio/profile-item'
ProfileItemEntity = require 'controllers/call-report-card/portfolio/profile-item-entity'
ProductsCollection = require 'models/bll/products-collection'

class Profiles extends Spine.Controller
  className: 'profiles'

  constructor: (@_productCount, @profileProducts, @profileProductsWithMessages, @callReport) ->
    super {}
    @_profileItems = []
    @productsCollection = new ProductsCollection

  refresh: =>
    #hack TODO need find a correct solution
    @el.addClass "hide"
    timeout = setTimeout =>
        @el.removeClass "hide"
        clearTimeout timeout
      , 0

  render: ->
    if @_isViewMode() then @_renderProfileItems() else @_initProfileItems()
    @

  _isViewMode: =>
    !!@callReport

  _renderProfileItems: ->
    forEach = (xs, fn) => unless _.isEmpty(xs) then $.when(fn(xs.shift())).then(-> forEach xs, fn)
    forEach [1..@_productCount], (patientProfileNumber) =>
      if @_callReportPatientProfileIdWinthIndex @callReport, patientProfileNumber
        profileItemEntity = @_createProfileItemEntityByPatientProfileNumber patientProfileNumber
        @_renderNewProfileItemForProfileItemEntity profileItemEntity
      else if @_callReportProductId @callReport, patientProfileNumber
        @_createDefaultProfileItemEntityByPatientProfileNumber patientProfileNumber
        .then @_renderNewProfileItemForProfileItemEntity

  _callReportPatientProfileIdWinthIndex: (callReport, index) ->
    callReport['patientProfile' + index]

  _callReportProductId: (callReport, index) ->
    callReport['prio' + index + 'ProductSfid']

  _createProfileItemEntityByPatientProfileNumber: (patientProfileNumber) =>
    profileItemEntity = new ProfileItemEntity
    profileItemEntity.patientProfileId = @_callReportPatientProfileIdWinthIndex @callReport, patientProfileNumber
    profileProduct = @_getProfileProductByPatientProfileId profileItemEntity.patientProfileId
    profileItemEntity.patientProfileName = profileProduct?.patientProfileName
    profileItemEntity.productId = @_callReportProductId @callReport, patientProfileNumber
    profileProduct = @_getProfileProductByProductId profileItemEntity.productId
    profileItemEntity.productName = profileProduct?.productName
    profileItemEntity.noteForProduct = @callReport['noteForPrio' + patientProfileNumber]
    profileItemEntity.productMessage1 = @callReport['prio' + patientProfileNumber + 'MarketingMessage1']
    profileItemEntity.productMessage2 = @callReport['prio' + patientProfileNumber + 'MarketingMessage2']
    profileItemEntity.productMessage3 = @callReport['prio' + patientProfileNumber + 'MarketingMessage3']
    profileItemEntity.isPromotional = @callReport['promotionalItemsPrio' + patientProfileNumber]
    profileItemEntity.classification = @callReport['prio' + patientProfileNumber + 'Classification']
    profileItemEntity

  _createDefaultProfileItemEntityByPatientProfileNumber: (patientProfileNumber) =>
    profileItemEntity = new ProfileItemEntity
    profileItemEntity.patientProfileId = null
    profileItemEntity.patientProfileName = Locale.value('card.CallReport.Portfolio.PatientProfile')
    profileItemEntity.productId = @_callReportProductId @callReport, patientProfileNumber
    profileItemEntity.noteForProduct = @callReport['noteForPrio' + patientProfileNumber]
    profileItemEntity.productMessage1 = @callReport['prio' + patientProfileNumber + 'MarketingMessage1']
    profileItemEntity.productMessage2 = @callReport['prio' + patientProfileNumber + 'MarketingMessage2']
    profileItemEntity.productMessage3 = @callReport['prio' + patientProfileNumber + 'MarketingMessage3']
    profileItemEntity.isPromotional = @callReport['promotionalItemsPrio' + patientProfileNumber]
    profileItemEntity.classification = null
    @productsCollection.fetchEntityById profileItemEntity.productId
    .then (product) ->
     profileItemEntity.productName = product.name
     profileItemEntity

  _getProfileProductByPatientProfileId: (patientProfileId) ->
    _.find @profileProducts, (profileProduct) -> profileProduct.patientProfileSfId is patientProfileId

  _getProfileProductByProductId: (productId) ->
    _.find @profileProducts, (profileProduct) -> profileProduct.productSfId is productId

  _renderNewProfileItemForProfileItemEntity: (profileItemEntity) =>
    profileTitle = profileItemEntity.patientProfileName
    productTitle = profileItemEntity.productName
    profileItem = new ProfileItem profileTitle, productTitle, @, profileItemEntity
    @append profileItem
    profileItem.render()

  _initProfileItems: ->
    _(@_productCount).times (index) =>
      profileTitle = Locale.value('card.CallReport.Portfolio.PatientProfile')
      productTitle = "#{Locale.value('card.CallReport.Portfolio.PatientProduct')} #{index+1}"
      profileItem = new ProfileItem profileTitle, productTitle, @, new ProfileItemEntity
      profileItem.on 'presentModalController', @_onPresentModalController
      profileItem.on 'dismissModalController', @_onDismissModalController
      @_profileItems.push profileItem
      @append profileItem
      profileItem.render()

  _onPresentModalController: (popup) =>
    @trigger 'presentModalController', popup

  _onDismissModalController: =>
    @trigger 'dismissModalController'

  isFirstPationProfileSelected: =>
    @_profileItems[0].profileItemEntity.patientProfileId?

  isProductsSelectedForEachChoosenProfiles: =>
    profileCellsWithOutSelectedProducts = _.find @_profileItems, (profileItem) -> profileItem.profileItemEntity.patientProfileId? and profileItem.profileItemEntity.productId is null
    !profileCellsWithOutSelectedProducts?

  isClassificationSelectedForEachChoosenProduct: ->
    profileCellsWithOutSelectedClassification = _.find @_profileItems, (profileItem) -> profileItem.profileItemEntity.productId? and profileItem.profileItemEntity.classification is null
    !profileCellsWithOutSelectedClassification?

  isFirstMessageSelected: ->
    return false unless @_profileItems[0].profileItemEntity.patientProfileId
    @_profileItems[0].profileItemEntity.productMessage1?

  getPrios: ->
    @_profileItems.map (profileItem) =>
      {
        productId: profileItem.profileItemEntity.productId,
        noteForProduct: profileItem.profileItemEntity.noteForProduct,
        patientProfileId: profileItem.profileItemEntity.patientProfileId,
        productMessage1: profileItem.profileItemEntity.productMessage1,
        productMessage2: profileItem.profileItemEntity.productMessage2,
        productMessage3: profileItem.profileItemEntity.productMessage3,
        isPromotional: profileItem.profileItemEntity.isPromotional,
        classification: profileItem.profileItemEntity.classification,
      }

  getAvaibleProductsForProfileItem: (profileItemEntity)->
    avaibleProducts = []
    @profileProducts.forEach (profileProduct) =>
      if profileProduct.patientProfileSfId is profileItemEntity.patientProfileId and not @_isProfileProductAlreadySelected(profileProduct)
        avaibleProducts.push @_createProductFromProfileProduct(profileProduct)
    avaibleProducts

  _isProfileProductAlreadySelected: (profileProduct)->
    profileProducts =_.find @_profileItems, (profileItem) =>
      profileItemEntity = profileItem.profileItemEntity
      profileItemEntity.patientProfileId is profileProduct.patientProfileSfId and profileItemEntity.productId is profileProduct.productSfId
    profileProducts?

  _createProductFromProfileProduct: (profileProduct)->
    id: profileProduct.productSfId
    description: profileProduct.productName

  isChanged: ->
    isChanged = _.find @_profileItems, (profileItem) => profileItem.isChanged()
    !!isChanged

module.exports = Profiles