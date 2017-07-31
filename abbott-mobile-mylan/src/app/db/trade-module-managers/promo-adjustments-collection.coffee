PromoAdjustmentTradeManager = require 'db/trade-module-managers/promo-adjustment-trade-manager'
PromoAdjustmentCallManager = require 'db/trade-module-managers/promo-adjustment-call-manager'

class CallPromoAdjustmentsCollection
  constructor: ->
    @callReport = null
    @promoAdjustments = {}

  setCallReport: (@callReport) =>

  areAllPromoAdjustmentsFilled: =>
    promoAjustmentsEntities = _.values @promoAdjustments
    _.every promoAjustmentsEntities, (promoAdjustment) -> promoAdjustment.areAllAdjustmentsFilled()

  hasPromo: =>
    Object.keys(@promoAdjustments).length > 0

  add: (promoAdjustment) =>
    @promoAdjustments[promoAdjustment.promoId] = promoAdjustment

  getPromoModel: (promoId) =>
    @promoAdjustments[promoId]

  remove: (promoId) =>
    delete @promoAdjustments[promoId]

  tradeSave: =>
    @_saveChangesInContextOf PromoAdjustmentTradeManager

  callReportSave: =>
    @_saveChangesInContextOf PromoAdjustmentCallManager

  resetTradeData: =>
    @_resetChangesInContextOf PromoAdjustmentTradeManager

  resetCallReportData: =>
    @_resetChangesInContextOf PromoAdjustmentCallManager

  _saveChangesInContextOf: (context) =>
    @_applyForEachPromotionInContextOf context, (contextInstance) -> contextInstance.saveChanges()

  _resetChangesInContextOf: (context) =>
    @_applyForEachPromotionInContextOf context, (contextInstance) -> contextInstance.resetChanges()

  _applyForEachPromotionInContextOf: (context, forEach) =>
    @_runSimultaneouslyForEachPromotionId (promotionId) =>
      promoAdjustmentManager = new context @promoAdjustments[promotionId]
      forEach(promoAdjustmentManager)

  _runSimultaneouslyForEachPromotionId: (promoStep) =>
    Utils = require 'common/utils'
    Utils.runSimultaneously _.map @_getAllPromotionsIds(), promoStep

  _getAllPromotionsIds: =>
    Object.keys(@promoAdjustments)

module.exports = CallPromoAdjustmentsCollection