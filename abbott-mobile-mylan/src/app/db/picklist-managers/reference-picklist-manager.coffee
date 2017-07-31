PicklistDatasourceManager = require 'db/picklist-managers/picklist-datasource-manager'
Reference = require 'models/reference'

class ReferencePicklistManager extends PicklistDatasourceManager
  targetModel: ->
    Reference

  fieldNames: ->
    [Reference.sfdc.status]

  getStatusLabelByValue: (value) ->
    @.getPickLists()
    .then => @getLabelByValue Reference.sfdc.status, value

module.exports = ReferencePicklistManager