Entity = require 'models/entity'

class Brick extends Entity
  @table: 'Brick'
  @sfdcTable: 'Account'
  @description: 'Brick'

  @schema: -> 
    [
      {local:'id',    sfdc:'Id'}
      {local:'name',  sfdc:'Name', indexWithType:'string'}
      {local:'shortDescription',  sfdc:'Short_Description__c'}
    ]

module.exports = Brick