Entity = require 'models/entity'

class BuTeamPersonProfile extends Entity
  @table: 'BuTeamPersonProfile'
  @sfdcTable: 'BU_Team_Person_Profile__c'
  @description: 'Bu Team Person Profile'

  @schema: ->
    [
      {local:'id',              sfdc:'Id'}
      {local:'organizationSfid',sfdc:'Account__c', indexWithType:'string'}
      {local:'businessUnit',    sfdc:'Business_Unit__c', indexWithType:'string'}
      {local:'priority',        sfdc:'Priority__c'}
      {local:'specialty',       sfdc:'Specialty__c', toLabel:true}
    ]

module.exports = BuTeamPersonProfile