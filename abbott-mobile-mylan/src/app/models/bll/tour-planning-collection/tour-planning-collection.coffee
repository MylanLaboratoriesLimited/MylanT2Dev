TourPlanningEntity = require 'models/tour-planning-entity'
ReferencesCollection = require 'models/bll/references/references-collection'
TargetFrequenciesCollection = require 'models/bll/target-frequencies-collection'
Query = require 'common/query'

class TourPlanningCollection extends ReferencesCollection
  model: TourPlanningEntity

  _fetchByBricksForUserQuery: (brickIds, userId) ->
    tfsCollection = new TargetFrequenciesCollection
    tfs = tfsCollection.model.table
    tfsContactId = tfsCollection.model.sfdc.customerSfId
    tfsMedrepId = tfsCollection.model.sfdc.medrepId
    references = @model.table
    refsContactId = @model.sfdc.contactSfId
    refsOrgBrickId = @model.sfdc.organizationBrick
    refsStatus = @model.sfdc.status
    query = new Query(@model.table)
    brickIds = brickIds.map((brickId)=>query.valueOf(brickId)).join(', ')
    query.customQuery(
      "SELECT {#{references}:#{Query.ALL}} FROM {#{references}}, {#{tfs}} " +
      "WHERE {#{references}:#{refsContactId}} = {#{tfs}:#{tfsContactId}} " +
      "AND {#{references}:#{refsOrgBrickId}} in (#{brickIds}) " +
      "AND {#{references}:#{refsStatus}} = #{query.valueOf(@model.STATUS_ACTIVE)} " +
      "AND {#{tfs}:#{tfsMedrepId}} = #{query.valueOf(userId)}"
    )

  fetchAllByBrickIdsForUser: (brickIds, userId) ->
    @fetchWithQuery @_fetchByBricksForUserQuery(brickIds, userId).orderBy([@model.sfdc.contactFirstName], Query.ASC)

  fetchAllByBrickIdsForUserSortedBy: (bricksId, userId, fields, isAsc) ->
    order = if isAsc then Query.ASC else Query.DESC
    query = @_fetchByBricksForUserQuery(bricksId, userId).orderBy(fields, order)
    @fetchWithQuery query

module.exports = TourPlanningCollection