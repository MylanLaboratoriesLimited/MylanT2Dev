EntitiesCollection = require 'models/bll/entities-collection'
TaskAdjustment = require 'models/task-adjustment'
Query = require 'common/query'
ConfigurationManager = require 'db/configuration-manager'
PromotionFilterSFQueryBuilder = require 'common/sf-query-builders/promotion-filter-sf-query-builder'
CallreportFilterSFQueryBuilder = require 'common/sf-query-builders/callreport-filter-sf-query-builder'

class TaskAdjustmentsCollection extends EntitiesCollection
  model: TaskAdjustment

  prepareServerConfig: (configPromise) =>
    configPromise.then (config) =>
      ConfigurationManager.getConfig()
      .then (clmConfig) ->
        config.query += PromotionFilterSFQueryBuilder.buildWhereFilter('PromotionTask_Account__r.PromotionAccount__r.Promotion__r', clmConfig)
        config.query += ' AND'
        config.query += CallreportFilterSFQueryBuilder.buildWhereFilter('CallReport__r', true)
        config

  getAllTaskAdjustmentsBySkusAndTasks: (skus, tasks) =>
    skuProductIds = skus.map (sku) -> sku.productItemSfId
    taskIds = tasks.map (task) -> task.promotionTaskSfId
    query = @_fetchAllQuery().whereIn(@model.sfdc.productItemSfId, skuProductIds).and().whereIn('promotionTaskSfId', taskIds)
    @fetchWithQuery(query).then @getAllEntitiesFromResponse

  getAllTaskAdjustmentsByCallReportAndTaskAccounts: (callReport, promotionTaskAccountSfIds) =>
    query = new Query().selectFrom(@model.table)
    .whereIn(@model.sfdc.callReportSfId, [callReport.id, @_attributesFromEntity(callReport)._soupEntryId]).and()
    .whereIn(@model.sfdc.promotionTaskAccountSfId, promotionTaskAccountSfIds)
    @fetchWithQuery(query).then(@getAllEntitiesFromResponse)

  getAdjustmentsByCallReport: (callReport) =>
    callReportIdValue = {}
    callReportIdValue[@model.sfdc.callReportSfId] = @_attributesFromEntity(callReport)._soupEntryId
    @fetchAllWhere(callReportIdValue)
    .then @getAllEntitiesFromResponse

  didStartUploading: (records) ->
    splitBrokenAdjustments = _.groupBy records, (record) -> (record.isModifiedInTrade is true) or (record.isModifiedInCall is true)
    brokenAdjustments = splitBrokenAdjustments.true ? []
    adjustmentsToUpload = splitBrokenAdjustments.false ? []
    @removeEntities brokenAdjustments
    .then -> adjustmentsToUpload
    .then (entities) =>
      CallReportsCollection = require 'models/bll/call-reports-collection/call-reports-collection'
      сallReportsCollection = new CallReportsCollection()
      сallReportsCollection.linkEntitiesToEntity entities, 'callReportSfId'

  didPageFinishDownloading: (records) ->
    @_updateTasksAdjustments records

  _updateTasksAdjustments: (taskAdjustments) ->
    updatedTaskAdjustments = taskAdjustments.map (taskAdjustment) ->
      taskAdjustment.promotionTaskSfId = taskAdjustment.PromotionTask_Account__r?.Promotion_Task__c ? ''
      taskAdjustment
    @cache.saveAll updatedTaskAdjustments

module.exports = TaskAdjustmentsCollection