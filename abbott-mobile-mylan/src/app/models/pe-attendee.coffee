Entity = require 'models/entity'

class PEAttendee extends Entity
  @table: 'PEAttendee'
  @sfdcTable: 'Event_Attendee__c'
  @description: 'PE Attendee'

  @schema: ->
    [
      {local:'id',              sfdc:'Id'}
      {local:'pharmaEventSfId', sfdc:'Pharma_Event__c',   upload: true,  search:true,  indexWithType:'string'}
      {local:'attendeeSfId',    sfdc:'Attendee__c',       upload: true,  search:true,  indexWithType:'string'}
      {local:'clmToolId',       sfdc:'CLM_Tool_Id__c',    upload: true}
    ]

module.exports = PEAttendee