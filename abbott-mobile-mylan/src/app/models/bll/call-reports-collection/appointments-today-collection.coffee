AppointmentsCollection = require 'models/bll/call-reports-collection/appointments-collection'
Utils = require 'common/utils'
Query = require 'common/query'

class AppointmentsTodayCollection extends AppointmentsCollection
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

module.exports = AppointmentsTodayCollection