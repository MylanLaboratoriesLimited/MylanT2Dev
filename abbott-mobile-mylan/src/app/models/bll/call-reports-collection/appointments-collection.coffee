CallReportsCollection = require 'models/bll/call-reports-collection/call-reports-collection'
Utils = require 'common/utils'
Query = require 'common/query'

class AppointmentsCollection extends CallReportsCollection
  _dataType: ->
    fieldValue = {}
    fieldValue[@model.sfdc.type] = @model.TYPE_APPOINTMENT
    fieldValue

  getAllAppointmentsFor: (reference, date) =>
    keyValue = @_dataType()
    keyValue[@model.sfdc.contactSfid] = reference.contactSfId
    keyValue[@model.sfdc.organizationSfId] = reference.organizationSfId
    startDate = Utils.originalStartOfDate date
    endDate = Utils.originalEndOfDate date
    startOfTodayCondition = {}
    startOfTodayCondition[@model.sfdc.dateTimeOfVisit] = startDate
    endOfTodayCondition = {}
    endOfTodayCondition[@model.sfdc.dateTimeOfVisit] = endDate
    query = new Query().selectFrom(@model.table)
    .where(keyValue).and()
    .where(startOfTodayCondition, Query.GRE).and()
    .where(endOfTodayCondition, Query.LRE)
    @fetchUnparsedWithQuery(query)
    .then @getAllUnparsedEntitiesFromResponse

  fetchUnparsedWhere: (keyValue) =>
    query = new Query().selectFrom(@model.table).where(keyValue)
    @fetchUnparsedWithQuery(query)

  fetchClosest: =>
    @fetchWithQuery @_closestQuery()

  _closestQuery: =>
    whereCondition = {}
    whereCondition[@model.sfdc.dateTimeOfVisit] = Utils.originalDateTime(new Date)
    query = new Query
    query.selectFrom(@model.table).where(@_dataType()).where(whereCondition, Query.GR).orderBy([@model.sfdc.dateTimeOfVisit])

module.exports = AppointmentsCollection