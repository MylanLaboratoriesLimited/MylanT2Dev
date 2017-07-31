SFQueryBuilder = require 'common/sf-query-builders/sf-query-builder'
CallReport = require 'models/call-report'
Utils = require 'common/utils'

class CallreportFilterSFQueryBuilder extends SFQueryBuilder
  @buildWhereFilter: (callReportField, alreadyHasWhere = false) =>
    minVisitDate = Utils.toSalesForceDateTimeFormat moment().subtract('months', 2)
    " #{@where(alreadyHasWhere)} #{@fieldDotConnection(callReportField)}#{CallReport.sfdc.dateTimeOfVisit} > #{minVisitDate}" +
    " AND #{@fieldDotConnection(callReportField)}Contact1__r.Id != Null" +
    " AND #{@fieldDotConnection(callReportField)}Organisation__r.Id != Null"

module.exports = CallreportFilterSFQueryBuilder