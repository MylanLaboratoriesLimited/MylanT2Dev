Entity = require 'models/entity'

class Reference extends Entity
  @table: 'Reference'
  @sfdcTable: 'Reference__c'
  @description: 'Reference'
  @STATUS_ACTIVE: '3'

  contact: null

  @schema: ->
    [
      {local:'id',                  sfdc:'Id'}
      {local:'contactSfId',         sfdc:'Customer__c', indexWithType:'string'}
      {local:'organizationSfId',    sfdc:'Organisation__c', indexWithType:'string'}
      {local:'contactRecordType',   sfdc:'Customer__r.Account.RecordType.Name', indexWithType:'string', search:true}
      {local:'isPrimary',           sfdc:'Primary__c'}
      {local:'status',              sfdc:'C_Status_Reference__c', indexWithType:'string'}
      {local:'organizationName',    sfdc:'Organisation__r.Name', indexWithType:'string', search:true}
      {local:'organizationCity',    sfdc:'Organisation__r.BillingCity', indexWithType:'string', search:true}
      {local:'organizationPhone',   sfdc:'Organisation__r.Phone', indexWithType:'string', search:true}
      {local:'organizationCountry', sfdc:'Organisation__r.BillingCountry', indexWithType:'string', search:true}
      {local:'organizationAddress', sfdc:'Organisation__r.BillingStreet',indexWithType:'string', search:true}
      {local:'organizationBrick',   sfdc:'Organisation__r.Brick__c', indexWithType:'string'}
      {local:'contactFirstName',    sfdc:'Customer__r.FirstName', indexWithType:'string', search:true}
      {local:'contactLastName',     sfdc:'Customer__r.LastName', indexWithType:'string', search:true}
      {local:'priority', indexWithType:'string', search:true}
      {local:'abbottSpecialty', indexWithType:'string', search:true}
      {local:'atCalls', indexWithType:'string'}
      {local:'lastCall', indexWithType:'string'}
    ]

  organizationNameAndAddress: ->
    "#{@organizationName ? ''} <br/> #{@organizationAddress ? ''} #{@organizationCity ? ''}"

  contactFullName: ->
    "#{@contactLastName ? ''} #{@contactFirstName ? ''}"

  isActive: ->
    @status is Reference.STATUS_ACTIVE

  getStatus: ->
    ReferencePicklistManager = require 'db/picklist-managers/reference-picklist-manager'
    new ReferencePicklistManager().getStatusLabelByValue @status

  # TODO: assign on 'didFinishDownloading'
  getContact: ->
    unless @contact
      ContactsCollection = require 'models/bll/contacts-collection'
      contactsCollection = new ContactsCollection
      contactsCollection.fetchEntityById @contactSfId
    else
      $.when @contact

module.exports = Reference