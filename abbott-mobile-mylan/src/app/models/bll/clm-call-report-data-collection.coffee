EntitiesCollection = require 'models/bll/entities-collection'
CLMCallReportData = require 'models/clm-call-report-data'

class CLMCallReportDataCollection extends EntitiesCollection
  model: CLMCallReportData

  fetchAllWhere: (fieldsValues, ignoreDeleted=true) =>
    query = @_fetchAllQuery().where(fieldsValues)
    @fetchWithQuery query, ignoreDeleted

  didStartUploading: (entities) =>
    CallReportsCollection = require 'models/bll/call-reports-collection/call-reports-collection'
    сallReportsCollection = new CallReportsCollection()
    сallReportsCollection.linkEntitiesToEntity entities, 'callReportId'

module.exports = CLMCallReportDataCollection