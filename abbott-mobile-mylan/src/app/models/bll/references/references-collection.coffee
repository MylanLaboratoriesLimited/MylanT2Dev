EntitiesCollection = require 'models/bll/entities-collection'
Reference = require 'models/reference'
Contact = require 'models/contact'
Query = require 'common/query'
ContactsCollection = require 'models/bll/contacts-collection'
TargetFrequenciesCollection = require 'models/bll/target-frequencies-collection'

class ReferencesCollection extends EntitiesCollection
  model: Reference

  prepareServerConfig: (configPromise) =>
    configPromise.then (config) =>
      config.query += " WHERE Customer__r.Id != Null AND Organisation__r.Id != Null AND Customer__r.#{Contact.sfdc.status} = '#{Contact.STATUS_ACTIVE}'"
      config

  parseModel: (result) ->
    result[@model.sfdc.organizationName] = result.Organisation__r.Name
    result[@model.sfdc.organizationCity] = result.Organisation__r.BillingCity
    result[@model.sfdc.organizationAddress] = result.Organisation__r.BillingStreet
    result[@model.sfdc.organizationBrick] = result.Organisation__r.Brick__c
    result[@model.sfdc.contactRecordType] = result.Customer__r.Account?.RecordType.Name
    result[@model.sfdc.contactFirstName] = result.Customer__r.FirstName
    result[@model.sfdc.contactLastName] = result.Customer__r.LastName
    result.priority ?= ''
    result.abbottSpecialty ?= ''
    result.atCalls ?= ''
    result.lastCall ?= ''
    super result

  _queryWithTargetFilter: (isTarget) =>
    references = @model.table
    query = new Query(references)
    query.customQuery("SELECT {#{references}:#{Query.ALL}} " + @_queryFromRefsWithTargetFilter(isTarget).toString())

  _queryFromRefsWithTargetFilter: (isTarget) =>
    contacts = Contact.table
    contactsId = Contact.sfdc.id
    references = @model.table
    refsContactId = @model.sfdc.contactSfId
    query = new Query(references)
    query.customQuery(
      "FROM {#{references}}, {#{contacts}} " +
      "WHERE {#{references}:#{refsContactId}} = {#{contacts}:#{contactsId}} " +
      "AND {#{contacts}:isTargetCustomer} = #{query.valueOf(isTarget)}"
    )

  _countWithTargetFilter: (isTarget) =>
    references = @model.table
    query = new Query(references)
    query.customQuery("SELECT COUNT(*) " + @_queryFromRefsWithTargetFilter(isTarget).toString())
    querySpec = Force.smartstoreClient.impl.buildSmartQuerySpec(query.toString(), 1)
    Force.smartstoreClient.runSmartQuery(querySpec)
    .then (count) -> _.chain(count.currentPageOrderedEntries).flatten().first().value()

  didPageFinishDownloading: (records) ->
    @_updateAtCalls records

  _updateAtCalls: (references) ->
    refsByContactIds = @_referencesByContactIds references
    contactsCollection = new ContactsCollection
    contactsCollection.fetchForContactIds(Object.keys(refsByContactIds))
    .then (contacts) =>
      @_updateReferencesByContactsIdsForContacts(refsByContactIds, contacts)

  _referencesByContactIds: (references) =>
    refsByContactIds = {}
    references.forEach (reference) =>
      contactId = reference[@model.sfdc.contactSfId]
      refsByContactIds[contactId] = [] unless refsByContactIds[contactId]
      refsByContactIds[contactId].push reference
    refsByContactIds

  _updateReferencesByContactsIdsForContacts: (refsByContactIds, contacts) =>
    updatedReferences = []
    contacts.forEach (contact) =>
      references = refsByContactIds[contact.id]
      if references and references.length
        references.forEach (reference)=>
          updatedReference = @_updateAtCallForReference reference, contact
          updatedReference = @_updatePriorityForReference updatedReference, contact
          updatedReference = @_updateAbbottSpecialtyForReference updatedReference, contact
          updatedReferences.push updatedReference
      delete refsByContactIds[contact.id]
    leftRefsIds = Object.keys refsByContactIds
    updatedReferences = leftRefsIds.reduce ((container, refId)->container.concat(refsByContactIds[refId])), updatedReferences
    @cache.saveAll updatedReferences

  _updateAtCallForReference: (reference, contact) ->
    if contact?.lastDateTargetFrequency
      lastDateTargetFrequency = contact.lastDateTargetFrequency
      reference.atCalls = lastDateTargetFrequency.atCalls()
      reference.lastCall = lastDateTargetFrequency.lastCall()
    else
      reference.atCalls = ''
      reference.lastCall = ''
    reference

  _updatePriorityForReference: (reference, contact) ->
    reference.priority = contact.priority if contact?.priority
    reference

  _updateAbbottSpecialtyForReference: (reference, contact) ->
    reference.abbottSpecialty = contact.abbottSpecialty if contact?.abbottSpecialty
    reference.specialty = contact.specialty if contact?.specialty
    reference

module.exports = ReferencesCollection