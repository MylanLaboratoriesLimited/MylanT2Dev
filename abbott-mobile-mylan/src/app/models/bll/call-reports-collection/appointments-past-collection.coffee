AppointmentsCollection = require 'models/bll/call-reports-collection/appointments-collection'
Utils = require 'common/utils'
Query = require 'common/query'

class AppointmentsPastCollection extends AppointmentsCollection

  _fetchAllQuery: ->
    today = Utils.originalStartOfToday()
    todayCondition = {}
    todayCondition[@model.sfdc.dateTimeOfVisit] = today
    super()
    .where(todayCondition, Query.LR)

module.exports = AppointmentsPastCollection