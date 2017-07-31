PickListDatasource = require 'controllers/call-report-card/picklist-datasource'
PharmaEvent = require 'models/pharma-event'
PePicklistManager = require 'db/picklist-managers/pe-picklist-manager'

class EventTypePicklistDatasource extends PickListDatasource

  pickListName: ->
    PharmaEvent.sfdc.eventType

  pickListManager: ->
    new PePicklistManager

module.exports = EventTypePicklistDatasource