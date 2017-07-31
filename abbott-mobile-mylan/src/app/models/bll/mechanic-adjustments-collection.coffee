EntitiesCollection = require 'models/bll/entities-collection'
MechanicAdjustment = require 'models/mechanic-adjustment'
Query = require 'common/query'
ConfigurationManager = require 'db/configuration-manager'
PromotionFilterSFQueryBuilder = require 'common/sf-query-builders/promotion-filter-sf-query-builder'
CallreportFilterSFQueryBuilder = require 'common/sf-query-builders/callreport-filter-sf-query-builder'

class MechanicAdjustmentsCollection extends EntitiesCollection
  model: MechanicAdjustment

  prepareServerConfig: (configPromise) =>
    configPromise.then (config) =>
      ConfigurationManager.getConfig()
      .then (clmConfig) ->
        config.query += PromotionFilterSFQueryBuilder.buildWhereFilter('MechanicEvaluation_Account__r.PromotionAccount__r.Promotion__r', clmConfig)
        config.query += ' AND'
        config.query += CallreportFilterSFQueryBuilder.buildWhereFilter('CallReport__r', true)
        config

  getAdjustmentsForMechanicEvaluationsWidthIds: (evaluationSfIds) =>
    @fetchAllWhereIn(@model.sfdc.mechanicEvaluationAccountSfId, evaluationSfIds).then @getAllEntitiesFromResponse

  getAdjustmentsByCallReportAndMechanicEvaluationAccounts: (callReport, evaluationsSfIds) =>
    query = new Query().selectFrom(@model.table)
    .whereIn(@model.sfdc.callReportSfId, [callReport.id, @_attributesFromEntity(callReport)._soupEntryId]).and()
    .whereIn(@model.sfdc.mechanicEvaluationAccountSfId, evaluationsSfIds)
    @fetchWithQuery(query).then @getAllEntitiesFromResponse

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

module.exports = MechanicAdjustmentsCollection