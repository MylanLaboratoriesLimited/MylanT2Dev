Entity = require 'models/entity'

class MarketingMessage extends Entity
  @table: 'MarketingMessage'
  @sfdcTable: 'Pharma_Product_Messages__c'
  @description: 'Marketing Message'

  @schema: ->
    [
      {local:'id',                  sfdc:'Id'}
      {local:'name',                sfdc:'Name'}
      {local:'produtSfId',          sfdc:'Pharma_Product__c'}
      {local:'status',              sfdc:'Status__c'}
      {local:'currencyIsoCode',     sfdc:'CurrencyIsoCode'}
    ]

module.exports = MarketingMessage