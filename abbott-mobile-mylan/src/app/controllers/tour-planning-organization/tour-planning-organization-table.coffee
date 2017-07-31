TourPlanningTableController = require 'controllers/tour-planning/tour-planning-table'

class TourPlanningOrganizationTableController extends TourPlanningTableController
  organizationById: =>
    organizationValue = {}
    organizationValue[@collection.model.sfdc.organizationSfId] = @datasource.organizationId
    organizationValue

  _fetchAll: =>
    @collection.fetchAllWhere @organizationById()

  _sortBy: (fields, isAsc) =>
    @collection.fetchAllWhereAndSortBy @organizationById(), fields, isAsc

module.exports = TourPlanningOrganizationTableController