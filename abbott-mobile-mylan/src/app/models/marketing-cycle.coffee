Entity = require 'models/entity'

class MarketingCycle extends Entity
  @table: 'MarketingCycle'
  @sfdcTable: 'Marketing_Cycle__c'
  @description: 'Marketing Cycle'

  @schema: ->
    [
      {local:'id',              sfdc:'Id'}
      {local:'planingCycleName',sfdc:'Name'}
      {local:'cycleName',       sfdc:'Marketing_Cycle_Name__c'}
      {local:'startDate',       sfdc:'Start_Date__c', indexWithType:'string'}
      {local:'endDate',         sfdc:'End_Date__c', indexWithType:'string'}
      {local:'currencyIsoCode', sfdc:'CurrencyIsoCode', indexWithType:'string'}
    ]

module.exports = MarketingCycle