Spine = require 'spine'
PromotionGeneralInfo = require 'controllers/trade-module/promotion-general-info'
PromotionDetails = require 'controllers/trade-module/promotion-details/promotion-details'

class PromotionScreen extends Spine.Controller
  tag: 'div'
  className: 'promotion-screen'

  constructor: (@promotionAccount, @promoAdjustmentEntity) ->
    super {}

  active: ->
    super
    @render()

  render: ->
    @_initPromotionGeneralInfo()
    @_initPromotionDetails()
    @

  _initPromotionGeneralInfo: ->
    @append new PromotionGeneralInfo(@promotionAccount).render().el

  _initPromotionDetails: ->
    @promoDetails = new PromotionDetails @promotionAccount, @promoAdjustmentEntity
    @promoDetails.on 'fullScreenTap', @_toggleFullScreen
    @promoDetails.on 'presentModalController', @_onPresentModalController
    @promoDetails.on 'dismissModalController', @_onDismissModalController
    @promoDetails.on 'dataChanged', @_dataChanged
    @append @promoDetails.render().el

  _dataChanged: =>
    @trigger 'dataChanged'

  _toggleFullScreen: (promoDetails) =>
    @el.toggleClass 'full-screen-mode'
    promoDetails.refresh() unless @el.hasClass('full-screen-mode')

  _onPresentModalController: (modalController) =>
    @trigger 'presentModalController', modalController

  _onDismissModalController: =>
    @trigger 'dismissModalController'

module.exports = PromotionScreen
