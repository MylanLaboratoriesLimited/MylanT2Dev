EntitiesCollection = require 'models/bll/entities-collection'
PromotionAccount = require 'models/promotion-account'
ConfigurationManager = require 'db/configuration-manager'
PromotionFilterSFQueryBuilder = require 'common/sf-query-builders/promotion-filter-sf-query-builder'
Utils = require 'common/utils'
Query = require 'common/query'

class PromotionAccountsCollection extends EntitiesCollection
  model: PromotionAccount

  parseModel: (result) ->
    result[@model.sfdc.name] = result.Promotion__r.Name
    result[@model.sfdc.numberOfPharmacies] = result.Promotion__r.NumberOfPharmacies__c
    result[@model.sfdc.contractNumber] = result.Promotion__r.ContractNumber__c
    result[@model.sfdc.description] = result.Promotion__r.Description__c
    result[@model.sfdc.objectives] = result.Promotion__r.Objectives__c
    result[@model.sfdc.status] = result.Promotion__r.Status__c
    result[@model.sfdc.recordType] = result.Promotion__r.RecordType.Name
    result[@model.sfdc.recordTypeId] = result.Promotion__r.RecordType.Id
    super result

  prepareServerConfig: (configPromise) =>
    configPromise.then (config) =>
      ConfigurationManager.getConfig()
      .then (clmConfig) ->
        config.query += PromotionFilterSFQueryBuilder.buildWhereFilter('Promotion__r', clmConfig)
        config

  getAllPromotionsForAccount: (accountId) =>
    accountIdValue = {}
    accountIdValue[@model.sfdc.accountSfId] = accountId
    @fetchAllWhere(accountIdValue).then @getAllEntitiesFromResponse

  getActualPromotionsForAccount: (accountId, date) =>
    accountValue = {}
    startDateValue = {}
    endDateValue = {}
    accountValue[@model.sfdc.accountSfId] = accountId
    startDateValue.startDate = Utils.currentDate(date)
    endDateValue.endDate = Utils.currentDate(date)
    query = new Query().selectFrom(@model.table).where(accountValue, Query.EQ).and().where(startDateValue, Query.LRE).and().where(endDateValue, Query.GRE)
    @fetchWithQuery(query).then @getAllEntitiesFromResponse

  didPageFinishDownloading: (records) ->
    @_updateAccounts records

  _updateAccounts: (accounts) ->
    updatedAccount = accounts.map (account) ->
      account.promotionTaskSfId = account.PromotionTask_Account__r?.Promotion_Task__c
      account.globalPriority = account.Account__r?.GlobalPriority__c
      account.startDate = account.Promotion__r.PromotionStartDate__c
      account.endDate = account.Promotion__r.PromotionEndDate__c
      account
    @cache.saveAll updatedAccount

module.exports = PromotionAccountsCollection