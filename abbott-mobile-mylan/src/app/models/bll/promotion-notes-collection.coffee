EntitiesCollection = require 'models/bll/entities-collection'
PromotionNote = require 'models/promotion-note'
ConfigurationManager = require 'db/configuration-manager'
PromotionFilterSFQueryBuilder = require 'common/sf-query-builders/promotion-filter-sf-query-builder'

class PromotionNotesCollection extends EntitiesCollection
  model: PromotionNote

  prepareServerConfig: (configPromise) =>
    configPromise.then (config) =>
      ConfigurationManager.getConfig()
      .then (clmConfig) =>
        config.query += " WHERE #{@model.sfdc.parentId} IN (SELECT Id FROM TM_Promotion__c"
        config.query += PromotionFilterSFQueryBuilder.buildWhereFilter('', clmConfig)
        config.query += ')'
        config

  parseModel: (result) ->
    result[@model.sfdc.attachedByName] = result.CreatedBy?.Name
    super result

  getAllNotesForPromotionWithId: (promotionId) =>
    promotionIdValue = {}
    promotionIdValue[@model.sfdc.parentId] = promotionId
    @fetchAllWhere(promotionIdValue).then @getAllEntitiesFromResponse

module.exports = PromotionNotesCollection