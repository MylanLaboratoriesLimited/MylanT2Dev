EntitiesCollection = require 'models/bll/entities-collection'
ContactsCollection = require 'models/bll/contacts-collection'
MarketingCyclesCollection = require 'models/bll/marketing-cycles-collection'
SforceDataContext = require 'models/bll/sforce-data-context'
TargetFrequency = require 'models/target-frequency'
Query = require 'common/query'
Utils = require 'common/utils'

class TargetFrequenciesCollection extends EntitiesCollection
  model: TargetFrequency

  parseModel: (result) ->
    if result.Target__r?.MedRep__r
      result[@model.sfdc.medrepId] = result.Target__r.MedRep__r.Id
      result[@model.sfdc.medrepFirstName] = result.Target__r.MedRep__r.FirstName
      result[@model.sfdc.medrepLastName] = result.Target__r.MedRep__r.LastName
    super result

  prepareServerConfig: (configPromise) =>
    configPromise
    .then((config) => SforceDataContext.activeUser().then (currentUser) -> [config, currentUser])
    .then ([config, currentUser]) =>
      today = Utils.currentDate()
      mcsCollection = new MarketingCyclesCollection
      mcr = 'Marketing_Cycle__r'
      mcStartDate = mcsCollection.model.sfdc.startDate
      mcEndDate = mcsCollection.model.sfdc.endDate
      mcCurrency = mcsCollection.model.sfdc.currencyIsoCode
      config.query += " where #{@model.sfdc.isActive} = true and #{mcr}.#{mcStartDate} <= #{today} and #{mcr}.#{mcEndDate} >= #{today} and #{mcr}.#{mcCurrency} = '#{currentUser.currency}'"
      config

  didPageFinishDownloading: (records) =>
    super(records)
    .then =>@_updateTargetContacts records

  _updateTargetContacts: (targetFrequencies) =>
    @fetchUnparsedWithQuery(@_queryForCurrentMCTFsContacts())
    .then(@getAllUnparsedEntitiesFromResponse)
    .then((contacts) => SforceDataContext.activeUser().then (activeUser) -> [contacts, activeUser])
    .then ([contacts, activeUser]) =>
      tfsByCustomerIds = @_targetFrequenciesByCustomerIds(@_filterTargetFrequenciesByMedrep targetFrequencies, activeUser)
      contactsCollection = new ContactsCollection
      updatedContacts = contacts.map (contact) =>
        @_updateContactAsTarget contact
        @_updateContactPriorities contact, tfsByCustomerIds
        contact
      contactsCollection.upsertEntitiesSilently updatedContacts

  _queryForCurrentMCTFsContacts: =>
    contactsCollection = new ContactsCollection
    mcsCollection = new MarketingCyclesCollection
    contacts = contactsCollection.model.table
    mcs = mcsCollection.model.table
    tfs = @model.table
    contactsId = contactsCollection.model.sfdc.id
    mcsId = mcsCollection.model.sfdc.id
    tfsCustomerId = @model.sfdc.customerSfId
    tfsMCId = @model.sfdc.marketingCycleSfId
    mcStartDate = mcsCollection.model.sfdc.startDate
    mcEndDate = mcsCollection.model.sfdc.endDate
    today = Utils.currentDate()
    query = new Query(@model.table)
    query.customQuery(
      "SELECT {#{contacts}:#{Query.ALL}} " +
      "FROM {#{contacts}}, {#{tfs}}, {#{mcs}} " + 
      "WHERE {#{tfs}:#{tfsCustomerId}} = {#{contacts}:#{contactsId}} " + 
      "AND {#{tfs}:#{tfsMCId}} = {#{mcs}:#{mcsId}} AND {#{mcs}:#{mcStartDate}} <= #{query.valueOf(today)} AND {#{mcs}:#{mcEndDate}} >= #{query.valueOf(today)}"
    )

  _targetFrequenciesByCustomerIds: (tfs) =>
    tfsByCustomerIds = {}
    tfs.forEach (tf) => tfsByCustomerIds[tf[@model.sfdc.customerSfId]] = tf
    tfsByCustomerIds

  _filterTargetFrequenciesByMedrep: (tfs, medrep) =>
    _(tfs).filter (tf) => tf[@model.sfdc.medrepId] is medrep.id

  _updateContactAsTarget: (contact) =>
    contact.isTargetCustomer = true

  _updateContactPriorities: (contact, tfsByCustomerIds) =>
    tf = tfsByCustomerIds[contact[@model.sfdc.id]]
    contact.priority = tf[@model.sfdc.priority] if tf

module.exports = TargetFrequenciesCollection