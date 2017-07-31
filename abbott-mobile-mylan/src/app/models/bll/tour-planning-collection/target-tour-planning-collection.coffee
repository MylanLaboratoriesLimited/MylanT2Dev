TourPlanningEntity = require 'models/tour-planning-entity'
TargetReferencesCollection = require 'models/bll/references/target-references-collection'

class TargetTourPlanningCollection extends TargetReferencesCollection
  model: TourPlanningEntity

  _fetchAllQuery: ->
    isStatusActive = {}
    isStatusActive[@model.sfdc.status] = @model.STATUS_ACTIVE
    super().where isStatusActive

module.exports = TargetTourPlanningCollection