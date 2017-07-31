PicklistDatasourceManager = require 'db/picklist-managers/picklist-datasource-manager'

class Promotion
  @sfdcTable: 'TM_Promotion__c'
  @table: 'Promotion'
  @status: 'Status__c'

class PromotionPickListManager extends PicklistDatasourceManager
  targetModel: ->
    Promotion

  fieldNames: ->
    [Promotion.status]

  getStatusLabelByValue: (value) ->
    @getPickLists()
    .then => @getLabelByValue Promotion.status, value

module.exports = PromotionPickListManager