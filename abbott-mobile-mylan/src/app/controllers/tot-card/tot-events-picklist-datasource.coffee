PickListDatasource = require 'controllers/call-report-card/picklist-datasource'
TotPicklistManager = require 'db/picklist-managers/tot-picklist-manager'
Tot = require 'models/tot'

class TotEventsPickListDatasource extends PickListDatasource

  pickListName: ->
    Tot.sfdc.firstQuarterEvent

  pickListManager: ->
    new TotPicklistManager

module.exports = TotEventsPickListDatasource