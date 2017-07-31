PickListDatasource = require 'controllers/call-report-card/picklist-datasource'
PharmaEvent = require 'models/pharma-event'
PePicklistManager = require 'db/picklist-managers/pe-picklist-manager'

class StagePicklistDatasource extends PickListDatasource

  pickListName: ->
    PharmaEvent.sfdc.stage

  pickListManager: ->
    new PePicklistManager

module.exports = StagePicklistDatasource