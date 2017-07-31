EntitiesCollection = require 'models/bll/entities-collection'
PromotionSku = require 'models/promotion-sku'
ConfigurationManager = require 'db/configuration-manager'
PromotionFilterSFQueryBuilder = require 'common/sf-query-builders/promotion-filter-sf-query-builder'

class PromotionSkusCollection extends EntitiesCollection
  model: PromotionSku

  prepareServerConfig: (configPromise) =>
    configPromise.then (config) =>
      ConfigurationManager.getConfig()
      .then (clmConfig) ->
        config.query += PromotionFilterSFQueryBuilder.buildWhereFilter('Promotion__r', clmConfig)
        config

  parseModel: (result) ->
    result[@model.sfdc.productItemName] = result.SKU__r.Name
    super result

  getAllSkusForPromotionWithId: (promoId) =>
    promoIdValue = {}
    promoIdValue[@model.sfdc.promotionSfId] = promoId
    @fetchAllWhere(promoIdValue).then @getAllEntitiesFromResponse

module.exports = PromotionSkusCollection