EntitiesCollection = require 'models/bll/entities-collection'
PromotionTaskAccount = require 'models/promotion-task-account'
ConfigurationManager = require 'db/configuration-manager'
PromotionFilterSFQueryBuilder = require 'common/sf-query-builders/promotion-filter-sf-query-builder'

class PromotionTaskAccountsCollection extends EntitiesCollection
  model: PromotionTaskAccount

  prepareServerConfig: (configPromise) =>
    configPromise.then (config) =>
      ConfigurationManager.getConfig()
      .then (clmConfig) ->
        config.query += PromotionFilterSFQueryBuilder.buildWhereFilter('PromotionAccount__r.Promotion__r', clmConfig)
        config

  parseModel: (result) ->
    result[@model.sfdc.promotionEndDate] = result.Promotion_Task__r.PromotionEndDate__c
    result[@model.sfdc.promotionName] = result.Promotion_Task__r.PromotionName__c
    result[@model.sfdc.promotionStartDate] = result.Promotion_Task__r.PromotionStartDate__c
    result[@model.sfdc.taskSfId] = result.Promotion_Task__r.Task__c
    result[@model.sfdc.taskName] = result.Promotion_Task__r.TaskName__c
    result[@model.sfdc.taskType] = result.Promotion_Task__r.TaskType__c
    result[@model.sfdc.taskRecordType] = result.Promotion_Task__r.Task__r.RecordType.Name
    result[@model.sfdc.taskPicklistValues] = result.Promotion_Task__r.Task__r.Picklist__c
    super result

  getBothRelatedAndNotRelatedToSkusTasks: (promoAccountId) =>
    promoIdValue = {}
    promoIdValue[@model.sfdc.promotionAccountSfId] = promoAccountId
    @fetchAllWhere(promoIdValue).then @getAllEntitiesFromResponse

  getAllTasksForPromotionAccountWithId: (promoAccountId) =>
    @_getAllTasksForPromotionWithIdAndAreRelatedToSKUs promoAccountId, false

  getAllTasksRelatedToSKUsForPromotionAccountWithId: (promoAccountId) =>
    @_getAllTasksForPromotionWithIdAndAreRelatedToSKUs promoAccountId, true

  _getAllTasksForPromotionWithIdAndAreRelatedToSKUs: (promoAccountId, areRelated) =>
    promoIdValue = {}
    promoIdValue[@model.sfdc.promotionAccountSfId] = promoAccountId
    promoIdValue.relatedToSku = areRelated
    @fetchAllWhere(promoIdValue).then @getAllEntitiesFromResponse

  didPageFinishDownloading: (records) ->
    @_updateTaskAccounts records

  _updateTaskAccounts: (taskAccounts) ->
    updatedTaskAccounts = taskAccounts.map (taskAccount) ->
      taskAccount.promotionSfId = taskAccount.PromotionAccount__r?.Promotion__c
      taskAccount.relatedToSku = taskAccount.Promotion_Task__r?.RelatedToSKU__c
      taskAccount
    @cache.saveAll updatedTaskAccounts

module.exports = PromotionTaskAccountsCollection