EntitiesCollection = require 'models/bll/entities-collection'
Scenario = require 'models/scenario'

class ScenariosCollection extends EntitiesCollection
  model: Scenario

module.exports = ScenariosCollection