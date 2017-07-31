Entity = require 'models/entity'

class PromotionSku extends Entity
  @table: 'PromotionSku'
  @sfdcTable: 'TM_Sku_Promotion__c'
  @description: 'Promotion SKU'

  @schema: ->
    [
      {local:'id',              sfdc:'Id'}
      {local:'name',            sfdc:'Name'}
      {local:'productItemSfId', sfdc:'SKU__c', indexWithType:'string'}
      {local:'productItemName', sfdc:'SKU__r.Name'}
      {local:'promotionSfId',   sfdc:'Promotion__c', indexWithType:'string'}
    ]

module.exports = PromotionSku