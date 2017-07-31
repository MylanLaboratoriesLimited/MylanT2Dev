PicklistDatasourceManager = require 'db/picklist-managers/picklist-datasource-manager'
PharmaEvent = require 'models/pharma-event'

class PePicklistManager extends PicklistDatasourceManager
  targetModel: ->
    PharmaEvent

  fieldNames: ->
    [PharmaEvent.sfdc.stage, PharmaEvent.sfdc.eventType, PharmaEvent.sfdc.status]

module.exports = PePicklistManager