Entity = require 'models/entity'

class Target extends Entity
  @table: 'Target'
  @sfdcTable: 'Target__c'
  @description: 'Target'

  @schema: ->
    [
      {local:'id',                 sfdc:'Id'}
      {local:'medrepSfId',         sfdc:'MedRep__c', indexWithType: 'string'}
      {local:'medrepBusinessUnit', sfdc:'MedRep__r.Business_Unit__c'}
    ]

module.exports = Target