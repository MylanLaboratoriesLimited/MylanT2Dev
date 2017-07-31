PicklistDatasourceManager = require 'db/picklist-managers/picklist-datasource-manager'
Tot = require 'models/tot'

class TotPicklistManager extends PicklistDatasourceManager
  targetModel: ->
    Tot

  fieldNames: ->
    [Tot.sfdc.firstQuarterEvent, Tot.sfdc.type]

module.exports = TotPicklistManager