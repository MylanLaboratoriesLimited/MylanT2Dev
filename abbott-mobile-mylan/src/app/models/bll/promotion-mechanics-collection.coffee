EntitiesCollection = require 'models/bll/entities-collection'
PromotionMechanic = require 'models/promotion-mechanic'
ConfigurationManager = require 'db/configuration-manager'
PromotionFilterSFQueryBuilder = require 'common/sf-query-builders/promotion-filter-sf-query-builder'

class PromotionMechanicsCollection extends EntitiesCollection
  model: PromotionMechanic

  prepareServerConfig: (configPromise) =>
    configPromise.then (config) =>
      ConfigurationManager.getConfig()
      .then (clmConfig) ->
        config.query += PromotionFilterSFQueryBuilder.buildWhereFilter('Promotion__r', clmConfig)
        config

  parseModel: (result) ->
    result[@model.sfdc.mechanicRecordType] = result.Mechanic__r.RecordType.Name
    result[@model.sfdc.mechanicPicklistValues] = result.Mechanic__r.Picklist__c
    super result

  getAllMechanicsForPromotionWithId: (promoId) =>
    promoIdValue = {}
    promoIdValue[@model.sfdc.promotionSfId] = promoId
    @fetchAllWhere(promoIdValue).then @getAllEntitiesFromResponse

module.exports = PromotionMechanicsCollection