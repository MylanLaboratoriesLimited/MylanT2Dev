EntitiesCollection = require 'models/bll/entities-collection'
MechanicEvaluationAccount = require 'models/mechanic-evaluation-account'
Query = require 'common/query'
ConfigurationManager = require 'db/configuration-manager'
PromotionFilterSFQueryBuilder = require 'common/sf-query-builders/promotion-filter-sf-query-builder'

class MechanicEvaluationAccountsCollection extends EntitiesCollection
  model: MechanicEvaluationAccount

  prepareServerConfig: (configPromise) =>
    configPromise.then (config) =>
      ConfigurationManager.getConfig()
      .then (clmConfig) ->
        config.query += PromotionFilterSFQueryBuilder.buildWhereFilter('PromotionAccount__r.Promotion__r', clmConfig)
        config

  getAllEvaluationsForPromoMechanics: (promoAccount, mechanics) =>
    promoAccountValue = {}
    promoAccountValue[@model.sfdc.promotionAccountSfId] = promoAccount.id
    query = new Query().selectFrom(@model.table)
    .whereIn('promotionMechanicSfId', mechanics.map (mechanic) -> mechanic.id).and()
    .where(promoAccountValue).and()
    .where(globalPriority: promoAccount.globalPriority)
    @fetchWithQuery(query).then @getAllEntitiesFromResponse

  parseModel: (result) ->
    result[@model.sfdc.externalId] = result.MechanicEvaluation__r.ExternalId__c
    result[@model.sfdc.isUsed] = result.MechanicEvaluation__r.isUsed__c
    result[@model.sfdc.mechanicName] = result.MechanicEvaluation__r.MechanicName__c
    result[@model.sfdc.mechanicType] = result.MechanicEvaluation__r.MechanicType__c
    result[@model.sfdc.numberEtalonValue] = result.MechanicEvaluation__r.NumberEtalonValue__c
    result[@model.sfdc.promotionEndDate] = result.MechanicEvaluation__r.PromotionEndDate__c
    result[@model.sfdc.promotionName] = result.MechanicEvaluation__r.Promotion_Name__c
    result[@model.sfdc.promotionStartDate] = result.MechanicEvaluation__r.PromotionStartDate__c
    result[@model.sfdc.skuName] = result.MechanicEvaluation__r.SkuName__c
    result[@model.sfdc.stringEtalonValue] = result.MechanicEvaluation__r.StringEtalonValue__c
    result[@model.sfdc.promotionMechanicPicklistValues] = result.MechanicEvaluation__r.MechanicPromotion__r.Mechanic__r.Picklist__c
    super result

  didPageFinishDownloading: (records) ->
    @_updateMechanicEvaluationAccounts records

  _updateMechanicEvaluationAccounts: (mechanicEvaluations) ->
    updatedMechanicEvaluations = mechanicEvaluations.map (mechanicEvaluation) ->
      mechanicEvaluation.organizationSfId = mechanicEvaluation.PromotionAccount__r?.Account__c
      if mechanicEvaluation.MechanicEvaluation__r
        mechanicEvaluation.promotionMechanicSfId = mechanicEvaluation.MechanicEvaluation__r.MechanicPromotion__c
        mechanicEvaluation.skuPromotionSfId = mechanicEvaluation.MechanicEvaluation__r.SkuPromotion__c
        mechanicEvaluation.globalPriority = mechanicEvaluation.MechanicEvaluation__r.GlobalPriority__c
      mechanicEvaluation
    @cache.saveAll updatedMechanicEvaluations

module.exports = MechanicEvaluationAccountsCollection