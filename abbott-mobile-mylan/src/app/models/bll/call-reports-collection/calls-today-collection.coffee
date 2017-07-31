CallsCollection = require 'models/bll/call-reports-collection/calls-collection'
Utils = require 'common/utils'
Query = require 'common/query'

class CallsTodayCollection extends CallsCollection

  _fetchAllQuery: ->
    startOfToday = Utils.originalStartOfToday()
    endOfToday = Utils.originalEndOfToday()
    startOfTodayCondition = {}
    startOfTodayCondition[@model.sfdc.dateTimeOfVisit] = startOfToday
    endOfTodayCondition = {}
    endOfTodayCondition[@model.sfdc.dateTimeOfVisit] = endOfToday
    super()
    .where(startOfTodayCondition, Query.GRE)
    .and()
    .where(endOfTodayCondition, Query.LRE)

module.exports = CallsTodayCollection