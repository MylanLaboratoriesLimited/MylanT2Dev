Entity = require 'models/entity'

class Product extends Entity
  @table: 'Product'
  @sfdcTable: 'Pharma_Product__c'
  @description: 'Product'

  @TYPE_LOCAL: 'Local'

  @schema: ->
    [
      {local:'id',              sfdc:'Id'}
      {local:'name',            sfdc:'Name'}
      {local:'atcClass',        sfdc:'ATC_Class__c', indexWithType:'string'}
      {local:'presentationId',  sfdc:'Presentation__c'}
    ]

module.exports = Product