Entity = require 'models/entity'
PEAttendeesCollection = require 'models/bll/pe-attendees-collection'
PEAbbottAttendeesCollection = require 'models/bll/pe-abbott-attendees-collection'
UsersCollection = require 'models/bll/users-collection'
SforceDataContext = require 'models/bll/sforce-data-context'

class PharmaEvent extends Entity
  @table: 'PharmaEvent'
  @sfdcTable: 'Events__c'
  @description: 'Pharma Event'

  @peAttendeesCollection: new PEAttendeesCollection
  @peAbbottAttendeesCollection: new PEAbbottAttendeesCollection
  @usersCollection: new UsersCollection

  @schema: ->
    [
      {local:'id',                      sfdc:'Id'}
      {local:'ownerSfid',               sfdc:'OwnerId',            upload: true}
      {local:'createdOffline',          sfdc:'Created_Offline__c', upload: true}
      {local:'remoteOwnerFirstName',    sfdc:'Owner.FirstName'}
      {local:'remoteOwnerLastName',     sfdc:'Owner.LastName'}
      {local:'ownerFirstName',                                                      search:true,  indexWithType:'string'}
      {local:'ownerLastName',                                                       search:true,  indexWithType:'string'}
      {local:'eventName',               sfdc:'Name',                upload: true,   search:true,  indexWithType:'string'}
      {local:'eventType',               sfdc:'Type_of_Event__c',    upload: true,   search:true,  indexWithType:'string'}
      {local:'location',                sfdc:'Location__c',         upload: true,   search:true,  indexWithType:'string'}
      {local:'startDate',               sfdc:'Start_Date__c',       upload: true,                 indexWithType:'string'}
      {local:'endDate',                 sfdc:'End_Date__c',         upload: true}
      {local:'stage',                   sfdc:'Stage__c',            upload: true,   search:true,  indexWithType:'string'}
      {local:'status',                  sfdc:'Status__c',           upload: true,   search:true,  indexWithType:'string'}
      {local:'businessUnit',            sfdc:'Business_Unit__c',    upload: true}
      {local:'objectives',              sfdc:'Objectives__c',       upload: true}
      {local:'agenda',                  sfdc:'Agenda__c',           upload: true}
      {local:'speakers',                sfdc:'Speaker_s__c',        upload: true}
      {local:'evaluation',              sfdc:'Evaluation__c',       upload: true}
      {local:'productPrio1SfId',        sfdc:'Product_Prio1__c',    upload: true}
      {local:'productPrio2SfId',        sfdc:'Product_Prio2__c',    upload: true}
      {local:'productPrio3SfId',        sfdc:'Product_Prio3__c',    upload: true}
      {local:'productPrio4SfId',        sfdc:'Product_Prio_4__c',   upload: true}
      {local:'clmToolId',               sfdc:'CLM_Tool_Id__c',      upload: true}
    ]

  _user: null

  ownerFullName: =>
    "#{@ownerLastName ? ''} #{@ownerFirstName ? ''}"

  _relatedCriteria: (model, field) ->
    relationField = model.sfdc[field]
    relationCriteria = {}
    relationCriteria[relationField] = @id
    relationCriteria

  _relatedPEAttendeesCriteria: ->
    @_relatedCriteria PharmaEvent.peAttendeesCollection.model, 'pharmaEventSfId'

  _relatedPEAbbottAttendeesCriteria: ->
    @_relatedCriteria PharmaEvent.peAbbottAttendeesCollection.model, 'pharmaEventSfId'

  _fetchAttendees: (collection, criteria) =>
    collection.fetchAllWhere criteria, false

  _fetchNotDeletedAttendees: (collection, criteria) =>
    collection.fetchAllWhere criteria

  getOwner: =>
    if @_user then $.when @_user else PharmaEvent.usersCollection.fetchEntityById(@ownerSfid).then (@_user) => @_user

  fetchAllPEAttendees: =>
    @_fetchAttendees PharmaEvent.peAttendeesCollection, @_relatedPEAttendeesCriteria()

  fetchAllPEAbbottAttendees: =>
    @_fetchAttendees PharmaEvent.peAbbottAttendeesCollection, @_relatedPEAbbottAttendeesCriteria()

  fetchNotDeletedPEAttendees: =>
    @_fetchNotDeletedAttendees PharmaEvent.peAttendeesCollection, @_relatedPEAttendeesCriteria()

  fetchNotDeletedPEAbbottAttendees: =>
    @_fetchNotDeletedAttendees PharmaEvent.peAbbottAttendeesCollection, @_relatedPEAbbottAttendeesCriteria()

  isEditable: =>
    SforceDataContext.activeUser()
    .then (activeUser) => @ownerSfid is activeUser.id

module.exports = PharmaEvent