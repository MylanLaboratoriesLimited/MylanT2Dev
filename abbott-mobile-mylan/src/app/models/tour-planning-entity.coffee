Reference = require 'models/reference'

class TourPlanningEntity extends Reference
  @description: 'Tour planning entity'

  visitOrderNumber: 0
  visitStartTime: null
  visitEndTime: null
  isChecked: false

  constructor: ->
    super

module.exports = TourPlanningEntity