FullscreenPanel = require 'controllers/base/panel/fullscreen-panel'
Header = require 'controls/header/header'
HeaderBaseControl = require 'controls/header-controls/header-base-control'
NavigationPromotions = require 'controllers/trade-module/navigation-promotions'
PromotionScreen = require 'controllers/trade-module/promotion-screen'
ConfirmationPopup = require 'controls/popups/confirmation-popup'
Iterator = require 'common/iterator'
PromotionAccountsCollection = require 'models/bll/promotion-accounts-collection'
PromoAdjustmentEntity = require 'db/trade-module-managers/promo-adjustment-entity'
Stage = require 'controllers/base/stage/stage'
SimplePopup = require 'controls/popups/simple-popup'
AlertPopup = require 'controls/popups/alert-popup'
Utils = require 'common/utils'

class TradeModule extends FullscreenPanel
  className: 'trade-module'

  elements:
    '.trade-module-promotion-header': 'elHeader'
    '.promotion-name': 'elPromotion'
    '.trade-scroll-content': 'elTradeScrollContent'

  events:
    'tap': '_blurInputs'
    'tap .main-data': '_onShowSimplePopup'

  constructor: (@organizationId, @callReport, @promoAdjustmentCollection, @isReadOnly) ->
    super
    @promotionsIterator = null
    @promoAdjustmentCollection.setCallReport @callReport

  active: ->
    super
    @render()

  activate: ->
    super
    @_activateReadOnlyMode() if @isReadOnly

  _blurInputs: =>
    $input = @el.find('.scroll-container input')
    $input.blur() if $input.is(':focus')

  _onShowSimplePopup: (event) =>
    if @isReadOnly
      target = $(event.currentTarget)
      text = target.find('input').val() or target.find('.btn-select').text()
      new SimplePopup(text).show() if text and text.length > 5

  render: =>
    @_initHeader()
    @_fetchPromotionsForOrganizationWithId(@organizationId)
    .then (@promotionAccounts) => @_addPromotionsToCallAdjustmentsCollection()
    .then =>
      @_initIterator()
      @_renderPromotion()
      @_resetChangeFlags()
      @_setContentSize();

  _setContentSize: =>
    unless Utils.isIOS()
      @elTradeScrollContent.height(@elTradeScrollContent.height())

  _activateReadOnlyMode: ->
    @el.addClass('read-only-mode')
    Stage.globalStage().el.removeClass 'fullscreen-panel-mode'

  _initHeader: ->
    scenariosHeader = new Header Locale.value('tradeModule.HeaderTitle')
    scenariosHeader.render()
    unless @isReadOnly
      saveBtn = new HeaderBaseControl Locale.value('common:buttons.SaveBtn'), 'ctrl-btn'
      saveBtn.bind 'tap', @_onSaveTap
      scenariosHeader.addRightControlElement saveBtn.el
    @setHeader scenariosHeader

  _onSaveTap: =>
    unless @promoAdjustmentCollection.areAllPromoAdjustmentsFilled()
      @_showWarning()
    else
      @_save()

  _showWarning: ->
    confirm = new ConfirmationPopup (caption:Locale.value('tradeModule.SaveWarningTitle'), message: Locale.value('tradeModule.AreYouShureSaveAndExit'))
    confirm.bind 'yesClicked', @_yesClickHandle
    confirm.bind 'noClicked', @_noClickHandle
    @presentModalController confirm

  _yesClickHandle: =>
    @dismissModalController()
    @_save()

  _noClickHandle: =>
    @dismissModalController()

  _save: =>
    @promoAdjustmentCollection.tradeSave()
    @_resetChangeFlags()
    @onBack()

  _resetChangeFlags: =>
    @isChanged = false

  onBack: =>
    if @isReadOnly or !@isChanged then super
    else
      confirm = new ConfirmationPopup {caption: Locale.value('card.ConfirmationPopup.SaveChanges.Caption')}
      confirm.bind 'yesClicked', =>
        @dismissModalController()
        @_onSaveTap()
      confirm.bind 'noClicked', =>
        @dismissModalController()
        @_resetData()
        @_resetChangeFlags()
        super
      @presentModalController confirm

  _resetData: =>
    @promoAdjustmentCollection.resetTradeData()

  _fetchPromotionsForOrganizationWithId: (orgId) ->
    new PromotionAccountsCollection().getActualPromotionsForAccount(orgId)

  _addPromotionsToCallAdjustmentsCollection: =>
    unless @promoAdjustmentCollection.hasPromo()
      @promotionAccounts.forEach (promotionAccount) =>
        promoAdjustmentEntity = new PromoAdjustmentEntity
        promoAdjustmentEntity.promoId = promotionAccount.promotionSfId
        promoAdjustmentEntity.promotionAccount = promotionAccount
        promoAdjustmentEntity.callReport = @callReport
        promoAdjustmentEntity.isReadOnly = @isReadOnly
        @promoAdjustmentCollection.add promoAdjustmentEntity
    else $.when()

  _initIterator: ->
    @promotionsIterator = new Iterator @promotionAccounts

  _renderPromotion: ->
    promotion = @promotionsIterator.currentItem()
    return unless promotion
    @html @template()
    @elPromotion.text promotion.name
    @_initNavPromotionsControl()
    @_initPromotionScreen()
    Locale.localize @el
    @_setContentSize()

  template: ->
    require('views/trade-module/trade-module')()

  _initNavPromotionsControl: ->
    navigationPromotions = new NavigationPromotions @promotionsIterator.currentIndex(), @promotionAccounts.length
    navigationPromotions.on 'prevBtnTap', @_goToPrevPromotion
    navigationPromotions.on 'nextBtnTap', @_goToNextPromotion
    @elHeader.append navigationPromotions.el
    navigationPromotions.render()

  _goToPrevPromotion: =>
    return unless @promotionsIterator.hasPrev()
    @promotionsIterator.prev()
    @_renderPromotion()

  _goToNextPromotion: =>
    return unless @promotionsIterator.hasNext()
    @promotionsIterator.next()
    @_renderPromotion()

  _initPromotionScreen: ->
    promotionAccount = @promotionsIterator.currentItem()
    promotionModel = @promoAdjustmentCollection.getPromoModel promotionAccount.promotionSfId
    @promotionScreen = new PromotionScreen(promotionAccount, promotionModel)
    @promotionScreen.on 'presentModalController', @_onPresentModalController
    @promotionScreen.on 'dismissModalController', @dismissModalController
    @promotionScreen.on 'dataChanged', @_dataChanged
    @elTradeScrollContent.append @promotionScreen.render().el

  _onPresentModalController: (mediaController) =>
    @presentModalController mediaController

  _dataChanged: =>
    @trigger 'dataChanged'
    @isChanged = true

module.exports = TradeModule