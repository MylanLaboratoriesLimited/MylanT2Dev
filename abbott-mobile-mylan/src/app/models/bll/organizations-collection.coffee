EntitiesCollection = require 'models/bll/entities-collection'
Organization = require 'models/organization'
Query = require 'common/query'
ConfigurationManager = require 'db/configuration-manager'

class OrganizationsCollection extends EntitiesCollection
  model: Organization

  parseModel: (result) ->
    result[@model.sfdc.recordType] = result.RecordType?.Name
    super result

  prepareServerConfig: (configPromise) =>
    configPromise.then (config) =>
      ConfigurationManager.getConfig('brickRecordTypeId')
      .then (brickRecordTypeId) ->
        config.query += " where RecordTypeId <> '#{brickRecordTypeId}'"
        config

  _fetchAllQuery: ->
    fieldValue = {}
    fieldValue[@model.sfdc.isPersonAccount] = false
    new Query().selectFrom(@model.table).where(fieldValue)

module.exports = OrganizationsCollection