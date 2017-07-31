EntitiesCollection = require 'models/bll/entities-collection'
Brick = require 'models/brick'
ConfigurationManager = require 'db/configuration-manager'

class BricksCollection extends EntitiesCollection
  model: Brick

  prepareServerConfig: (configPromise) =>
    configPromise.then (config) ->
      ConfigurationManager.getConfig('brickRecordTypeId')
      .then (brickRecordTypeId) ->
        config.query += " where RecordTypeId = '#{brickRecordTypeId}'"
        config

module.exports = BricksCollection