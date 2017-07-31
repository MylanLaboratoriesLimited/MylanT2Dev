Entity = require 'models/entity'

class PEAbbottAttendee extends Entity
  @table: 'PEAbbottAttendee'
  @sfdcTable: 'Pharma_Event_Abbott_Attendees__c'
  @description: 'PE Abbott Attendee'

  @schema: ->
    [
      {local:'id',              sfdc:'Id'}
      {local:'pharmaEventSfId', sfdc:'Pharma_Event__c',         upload: true,  search:true,  indexWithType:'string'}
      {local:'attendeeSfId',    sfdc:'AbbottAttendeeName__c',   upload: true,  search:true,  indexWithType:'string'}
      {local:'clmToolId',       sfdc:'CLM_Tool_Id__c',          upload: true}
    ]

module.exports = PEAbbottAttendee