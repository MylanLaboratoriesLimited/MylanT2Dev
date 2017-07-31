Locale = require 'common/localization/locale'
CommonInput = require 'controls/common-input/common-input'
ListPopup = require 'controls/popups/list-popup'
PatientProfilesPopup = require 'controls/popups/patient-profiles-popup/patient-profiles-popup'
ConfirmationPopup = require 'controls/popups/confirmation-popup'
ProfileProductInPortfoliosCollection = require 'models/bll/profile-product-in-portfolios-collection'
PatientDiseasesCollection = require 'models/bll/patient-diseases-collection'
PatientDisease = require 'models/patient-disease'
CallReport = require 'models/call-report'

class ProfileItem extends Spine.Controller
  className: 'profile-item'

  elements:
    '.call-report-card-product-comment': 'elProductComment'
    '.profile-table': 'elProductsTable'
    '.table-wrapper': 'elProductsTableWrapper'
    '.title .profile-title': 'elProfileTitle'
    '.title .product-title': 'elProductTitle'
    '.call-report-card-patient-profile-list-btn': 'elChoosePatientProfile'
    '.choose-product':'elChooseProduct'
    '.select-btn.message-1': 'elChooseProductMessage1'
    '.select-btn.message-2': 'elChooseProductMessage2'
    '.select-btn.message-3': 'elChooseProductMessage3'
    '.call-report-card-classification': 'elChooseClassification'
    '.call-report-card-contact-info-wrapper': 'elInfoWrapper'
    '.call-report-card-contact-info-age': 'elAge'
    '.call-report-card-contact-info-gender': 'elGender'
    '.call-report-card-contact-info-general-health': 'elGeneralHealth'
    '.call-report-card-contact-info-occupation': 'elOccupation'
    '.call-report-card-contact-info-bmi': 'elBMI'
    '.call-report-card-contact-info-diseases': 'elDiseases'
    '.promotion-item': 'elPromotionItem'

  events:
    'tap .expand-btn': '_onExpandTap'
    'tap .call-report-card-patient-profile-list-btn': '_onChoosePatientProfileTap'
    'tap .choose-product':'_onChooseProductTap'
    'tap .call-report-card-classification': '_onChooseClassificationTap'
    'tap .select-btn.message-1': '_onChoosenProductMessage1Tap'
    'tap .select-btn.message-2': '_onChoosenProductMessage2Tap'
    'tap .select-btn.message-3': '_onChoosenProductMessage3Tap'
    'change .promotion-item': '_onPromotiontemChange'
    'elasticUpdate .call-report-card-product-comment':'_refreshHeightWithoutAnimation'

  constructor: (@profileTitle, @productTitle, @datasource, @profileItemEntity) ->
    super {}
    @_resetChangeFlags()
    @_products = null
    @_messages = null
    @selectedPatientProfile = null
    @diseasesCollection = new PatientDiseasesCollection
    @chosenProduct = null
    @chosenClassification = null
    @chosenMessage1 = null
    @chosenMessage2 = null
    @chosenMessage3 = null

  _resetChangeFlags: =>
    @_isChanged = false

  isChanged: ->
    @_isChanged or @selectedPatientProfile

  render: ->
   	@html @template()
    Locale.localize @el
    @_initTitle()
    @_initGeneralInfo()
    @_initPatientProfile()
    @_initProducts()
    @_initMessages()
    @_initNoteForProduct()
    @_initClassifications()
    @_initPromotionItem()
    @

  template: ->
   	require('views/call-report-card/portfolio/profile-item')()

  _initTitle: ->
    @elProfileTitle.html @profileTitle
    @elProductTitle.html @productTitle

  _initGeneralInfo: ->
    savedProfileProduct = _.find @datasource.profileProducts, (profileProduct) => profileProduct.patientProfileSfId is @profileItemEntity.patientProfileId
    if savedProfileProduct
      @elAge.text savedProfileProduct.age
      @elGender.text savedProfileProduct.gender
      @elGeneralHealth.text savedProfileProduct.generalHealth
      @elOccupation.text savedProfileProduct.occupation
      @elBMI.text savedProfileProduct.bmi
      @diseasesCollection.fetchByPatientProfileId savedProfileProduct.patientProfileSfId
      .then (patientDiseases) =>
        @elDiseases.text @_diseasesNames patientDiseases
        @elInfoWrapper.show()
        @_refreshHeight()

  _diseasesNames: (patientDiseases) ->
    patientDiseases?.map((patientDisease)-> patientDisease.diseaseName).join(", ")

  _refreshHeight: =>
    height = 0
    height = @elProductsTable.height() if @el.hasClass 'expanded'
    @elProductsTableWrapper.css 'height', "#{height}px"

  _setDefaultElementFontStyle: (element)->
    element.addClass "call-report-empty-font-style"

  _initPatientProfile: ->
    patientProfileName = @profileItemEntity.patientProfileName
    @elChoosePatientProfile.text patientProfileName if patientProfileName
    defaultName = Locale.value('card.CallReport.Portfolio.PatientProfile')
    @_setDefaultElementFontStyle @elChoosePatientProfile if patientProfileName is defaultName

  _initProducts: ->
    productName = @profileItemEntity.productName
    if productName then @elChooseProduct.text productName else @_setDefaultElementFontStyle @elChoosePatientProfile
    @_products = [@_noneValue()]

  _noneValue: ->
    @_filterResource(null, Locale.value('common:defaultSelectValue'))

  _filterResource: (id, description) =>
    id: id
    description: description

  _initNoteForProduct: ->
    # TODO: CommonInput like control
    @elProductComment.val @profileItemEntity.noteForProduct or ''
    @_setDefaultElementFontStyle @elProductComment unless @profileItemEntity.noteForProduct
    new CommonInput $('.call-report .wrapper'), @elProductComment[0]
    @elProductComment.on 'change', @_noteForProductChanged

  _noteForProductChanged: =>
    @profileItemEntity.noteForProduct = @elProductComment.val()
    @_isChanged = true

  _initMessages: =>
    @_messages = [@_noneValue()]
    [1..CallReport.MESSAGES_IN_PRODUCT_NUMBER].forEach (number) =>
      message = @_profileItemEntityProductMessageWithIndex(number)
      element = @_elChooseProductMessageWithIndex(number)
      @_setDefaultElementFontStyle element unless message
      message = message or @_defaultMessageWithIndexCaption number
      element.text message


  _profileItemEntityProductMessageWithIndex: (index) =>
    @profileItemEntity["productMessage#{index}"]

  _setProfileItemEntityProductMessageWithIndex: (index, value) =>
    @profileItemEntity["productMessage#{index}"] = value

  _elChooseProductMessageWithIndex: (index) =>
    @["elChooseProductMessage#{index}"]

  _initClassifications: =>
    if @profileItemEntity.classification
      @elChooseClassification.text @profileItemEntity.classification
    else
      @_setDefaultElementFontStyle @elChooseClassification
    @_classifcations = [@_noneValue()]

  _initPromotionItem: ->
    @elPromotionItem[0].checked = @profileItemEntity.isPromotional

  _onExpandTap: =>
    @el.toggleClass 'expanded'
    @_refreshElProductComment()
    @_refreshHeight()

  _refreshElProductComment: ->
    @elProductComment[0].readOnly = !@el.hasClass 'expanded'

  _onChoosePatientProfileTap: =>
    if @datasource.profileProducts.length
      @_showPatientProfilesPopup()
    else @_showNoPatientProfileToast()

  _showPatientProfilesPopup: ->
    profileProducts = @_filterProfileProducts @datasource.profileProducts
    @_pairedDiseasesForProduct(profileProducts)
    .then (patientProfiles) =>
      popup = new PatientProfilesPopup patientProfiles, @selectedPatientProfile
      popup.on 'didChosePatientProfile', (patientProfile)=>
        popup.on 'didHide', =>
          @_onDidChoseNewPatientProfile(patientProfile) if @_isNewPatientProfile(patientProfile)
        @trigger 'dismissModalController'
      @trigger 'presentModalController', popup

  _isNewPatientProfile: (patientProfile)->
    selectedPatientProfileSfId = if @selectedPatientProfile then @selectedPatientProfile.profileProduct.patientProfileSfId else null
    patientProfile.profileProduct.patientProfileSfId != selectedPatientProfileSfId

  _filterProfileProducts: (profileProducts) ->
    _.uniq profileProducts, (item) -> item.patientProfileSfId

  _pairedDiseasesForProduct: (entities) =>
    patientProfiles = []
    recursion = (source, output) =>
      if _.isEmpty(source) then $.when output
      else
        profileProduct = source.shift()
        @diseasesCollection.fetchByPatientProfileId(profileProduct.patientProfileSfId)
        .then (patientDiseases) ->
          output.push { 'profileProduct': profileProduct, 'patientDiseases': patientDiseases }
          recursion source, output
    recursion entities, patientProfiles

  _onDidChoseNewPatientProfile: (patientProfile) =>
    if @_isChanged
      @_showClearConfirmation patientProfile
    else
      @_resetEnteredValues()
      @_applyChosenProfile patientProfile

  _showClearConfirmation: (patientProfile) ->
    confirm = new ConfirmationPopup(caption: Locale.value("card.CallReport.Portfolio.ClearDataConfirmation.Caption"), message: Locale.value("card.CallReport.Portfolio.ClearDataConfirmation.Message"))
    confirm.bind 'yesClicked', =>
      @_resetChangeFlags()
      @_resetEnteredValues()
      @_applyChosenProfile patientProfile
      @trigger 'dismissModalController'
    confirm.bind 'noClicked', =>
      @trigger 'dismissModalController'
    @trigger 'presentModalController', confirm

  _resetEnteredValues: ->
    @_initTitle()
    @_resetEntity()
    @_resetGeneralInfo()
    @_resetProduct()
    @_resetPromotionItem()
    @_resetClassifications()
    @_initNoteForProduct()

  _resetEntity: ->
    @profileItemEntity.productId = null
    @profileItemEntity.productName = null
    @profileItemEntity.noteForProduct = null
    @profileItemEntity.patientProfileId = null
    @profileItemEntity.patientProfileName = null
    @profileItemEntity.isPromotional = false
    @profileItemEntity.classification = null
    @_resetMarketingMessageEntity()

  _resetMarketingMessageEntity: ->
    @profileItemEntity.productMessage1 = null
    @profileItemEntity.productMessage2 = null
    @profileItemEntity.productMessage3 = null

  _resetGeneralInfo: ->
    @elAge.text ''
    @elGender.text ''
    @elGeneralHealth.text ''
    @elOccupation.text ''
    @elBMI.text ''
    @elDiseases.text ''

  _resetProduct: ->
    @elChooseProduct.text @_defaultProductCaption()
    @chosenProduct = null
    @_updateMessages()

  _updateMessages: ->
    @_resetMessages()
    @_messages = [@_noneValue()].concat(
      @_getMessagesForProductWithId(@profileItemEntity.productId)
      .map (message) => @_filterResource(message.id, message.name)
    )

  _resetMessages: ->
    @_resetMarketingMessageEntity()
    [1..CallReport.MESSAGES_IN_PRODUCT_NUMBER].forEach (number) =>
      @_elChooseProductMessageWithIndex(number).text @_defaultMessageWithIndexCaption number
      @_setChosenMessageWithIndex number

  _getMessagesForProductWithId: (productId) =>
    productWithMessage = _.find @datasource.profileProductsWithMessages, (profileProductWithMessage) =>
      profileProductWithMessage.profileProduct.productSfId is productId
    productWithMessage?.messages or []

  _resetPromotionItem: ->
    @elPromotionItem[0].checked = false

  _resetClassifications: ->
    @elChooseClassification.text @_defaultClassificationCaption()
    @chosenClassification = null

  _applyChosenProfile: (@selectedPatientProfile) ->
    if @selectedPatientProfile.isNone
      @_applyNoneChosenProfile()
    else @_applyRealChosenProfile()

  _applyNoneChosenProfile: ->
    @profileItemEntity.patientProfileId = null
    @elInfoWrapper.hide()
    @elChoosePatientProfile.text Locale.value("card.CallReport.Portfolio.ChoosePatientProfile")
    @_initClassifications()

  _applyRealChosenProfile: ->
    @profileItemEntity.patientProfileId = @selectedPatientProfile.profileProduct.patientProfileSfId
    @profileItemEntity.patientProfileName = @selectedPatientProfile.profileProduct.patientProfileName
    @elChoosePatientProfile.text @profileItemEntity.patientProfileName
    @elProfileTitle.html @profileItemEntity.patientProfileName
    @_updateGeneralInfo()
    @_updateClassifications()

  _updateProducts: ->
    @_initProducts()
    @_products.push(@chosenProduct) if @profileItemEntity.productId
    @_products = _.union @_products, @datasource.getAvaibleProductsForProfileItem(@profileItemEntity)

  _updateGeneralInfo: =>
    profileProduct = @selectedPatientProfile.profileProduct
    @elAge.text profileProduct.age
    @elGender.text profileProduct.gender
    @elGeneralHealth.text profileProduct.generalHealth
    @elOccupation.text profileProduct.occupation
    @elBMI.text profileProduct.bmi
    @elDiseases.text @_diseasesNames @selectedPatientProfile.patientDiseases
    @elInfoWrapper.show()
    @_refreshHeight()

  _updateClassifications: ->
    @_classifcations = [@_noneValue()]
    @_classifcations.push @_filterResource(1, Locale.value('card.CallReport.Portfolio.Classifications.Detailed'))
    @_classifcations.push @_filterResource(2, Locale.value('card.CallReport.Portfolio.Classifications.Reminder'))

  _showNoPatientProfileToast: ->
    $.fn.dpToast Locale.value("card.CallReport.Portfolio.ToastMessage.NoActiveProductPortfolio")

  _onChooseProductTap: =>
    @_updateProducts()
    @_onChooseItemTap @_products, @chosenProduct, (@chosenProduct) =>
      @profileItemEntity.productId = @chosenProduct.id
      @elProductTitle.text @_popupModelDescription @chosenProduct, @productTitle
      @elChooseProduct.text @_popupModelDescription @chosenProduct, @_defaultProductCaption()
      @_updateMessages()

  _onChooseClassificationTap: =>
    @_onChooseItemTap @_classifcations, @chosenClassification, (@chosenClassification) =>
      @profileItemEntity.classification = @_popupModelDescription @chosenClassification, null
      @elChooseClassification.text @_popupModelDescription(@chosenClassification, @_defaultClassificationCaption())

  _onChoosenProductMessage1Tap: =>
    @_onChoosenProductMessageWithIndexTap 1

  _onChoosenProductMessage2Tap: =>
    @_onChoosenProductMessageWithIndexTap 2

  _onChoosenProductMessage3Tap: =>
    @_onChoosenProductMessageWithIndexTap 3

  _onChoosenProductMessageWithIndexTap: (index) =>
    @_onChooseItemTap @_messages, @_chosenMessageWithIndex(index), (selectedModel) =>
      @_setChosenMessageWithIndex index, selectedModel
      @_setProfileItemEntityProductMessageWithIndex index, @_popupModelDescription(selectedModel, null)
      @_elChooseProductMessageWithIndex(index).text @_popupModelDescription(selectedModel, @_defaultMessageWithIndexCaption index)

  _chosenMessageWithIndex: (index) =>
    @["chosenMessage#{index}"]

  _setChosenMessageWithIndex: (index, value) =>
    @["chosenMessage#{index}"] = value

  _onChooseItemTap: (itemsList, chosenItem, onSelectedItemHandler=null) =>
    filterPopup = new ListPopup itemsList, chosenItem
    filterPopup.bind 'onPopupItemSelected', (selectedItem) =>
      @_isChanged = true
      onSelectedItemHandler?(selectedItem.model)
      @trigger 'dismissModalController'
    @trigger 'presentModalController', filterPopup

  _popupModelDescription: (model, defaultDescription) =>
    if model.id then model.description else defaultDescription

  _defaultProductCaption: ->
    Locale.value('card.CallReport.Portfolio.ChooseProduct')

  _defaultClassificationCaption: ->
    Locale.value('card.CallReport.Portfolio.Classification')

  _defaultMessageWithIndexCaption: (index) ->
    "#{Locale.value('card.CallReport.Portfolio.DefaultSelectMessage')} #{index}"

  _onPromotiontemChange: =>
    @profileItemEntity.isPromotional = @elPromotionItem[0].checked
    @_isChanged = true

  _refreshHeightWithoutAnimation: =>
    @elProductsTableWrapper.css 'webkitTransition', 'none'
    setTimeout =>
      @elProductsTableWrapper.css 'webkitTransition', ''
    ,0
    @_refreshHeight()

module.exports = ProfileItem