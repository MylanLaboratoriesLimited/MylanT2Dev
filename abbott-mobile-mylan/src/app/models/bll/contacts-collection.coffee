EntitiesCollection = require 'models/bll/entities-collection'
Contact = require 'models/contact'
SforceDataContext = require 'models/bll/sforce-data-context'
BuTeamPersonProfilesCollection = require 'models/bll/bu-team-person-profiles-collection'
Utils = require 'common/utils'

class ContactsCollection extends EntitiesCollection
  model: Contact

  parseModel: (result) ->
    TargetFrequenciesCollection = require 'models/bll/target-frequencies-collection'
    result[@model.sfdc.recordType] = result.Account?.RecordType.Name
    tfsCollection = new TargetFrequenciesCollection
    if result.TMF1__r
      lastDateTargetFrequency = tfsCollection.parseModel result.TMF1__r
      result.lastDateTargetFrequency = lastDateTargetFrequency
      delete result.TMF1__r
    else if result.lastDateTargetFrequency
      result.lastDateTargetFrequency = tfsCollection.parseModel result.lastDateTargetFrequency
    super result

  prepareServerConfig: (configPromise) =>
    TargetFrequenciesCollection = require 'models/bll/target-frequencies-collection'
    configPromise
    .then((config) => SforceDataContext.activeUser().then (activeUser) -> [config, activeUser])
    .then ([config, activeUser]) =>
      MarketingCycle = require 'models/marketing-cycle'
      today = Utils.currentDate()
      tfsCollection = new TargetFrequenciesCollection
      isActive = tfsCollection.model.sfdc.isActive
      mcr = 'Marketing_Cycle__r'
      mcStartDate = MarketingCycle.sfdc.startDate
      mcEndDate = MarketingCycle.sfdc.endDate
      mcCurrency = MarketingCycle.sfdc.currencyIsoCode
      @_mapFieldsList()
      .then (fields) =>
        config.query =
          "SELECT #{fields.join(',')}, (SELECT #{tfsCollection.model.sfdcFields.join(',')} " +
          "FROM TMF1__r " +
          "WHERE #{isActive} = true AND #{mcr}.#{mcStartDate} <= #{today} AND #{mcr}.#{mcEndDate} >= #{today} AND #{mcr}.#{mcCurrency} = '#{activeUser.currency}') " +
          "FROM #{@model.sfdcTable} " +
          "WHERE #{@model.sfdc.status} = '#{@model.STATUS_ACTIVE}'"
        config

  didPageFinishDownloading: (records) =>
    @_updateContacts(records)

  _updateContacts: (contacts) =>
    teamCollection = new BuTeamPersonProfilesCollection
    contactOrganisationIds = contacts.map (contact)=>contact[@model.sfdc.organizationSfId]
    SforceDataContext.activeUser()
    .then((activeUser) => teamCollection.fetchForUserUnitAndContacts activeUser.businessUnit, contactOrganisationIds)
    .then (profiles) =>
      Utils.runSimultaneously _(contacts).map (contact) =>
        @_updateContactAsNonTarget contact
        @_updateContactTargetFrequency contact
        @_updateContactAbbottSpecialtyAndPriority contact, @_profilesByOrganisationIds(profiles)
      .then => @cache.saveAll contacts

  _updateContactAsNonTarget: (contact) =>
    contact.isTargetCustomer = false

  _updateContactTargetFrequency: (contact) =>
    contact.TMF1__r = @_getTargetFrequencyInMarketingCycle(contact.TMF1__r.records) if contact.TMF1__r

  _getTargetFrequencyInMarketingCycle: (tfs) ->
    TargetFrequency = require 'models/target-frequency'
    lastCallDate = TargetFrequency.sfdc.lastCallReportDate
    lastTf = null
    tfs.forEach (currentTf) => lastTf = currentTf if (lastTf is null) or (currentTf? and lastTf[lastCallDate]? and lastTf[lastCallDate] < currentTf[lastCallDate])
    lastTf

  _updateContactAbbottSpecialtyAndPriority: (contact, profilesByOrgIds) =>
    profile = profilesByOrgIds[contact[@model.sfdc.organizationSfId]]
    contact.abbottSpecialty = profile?.specialty ? ''
    contact.priority = profile?.priority ? ''

  _profilesByOrganisationIds: (profiles) =>
    profilesByOrgIds = {}
    profiles.forEach (profile) => profilesByOrgIds[profile.organizationSfid] = profile
    profilesByOrgIds

  fetchForContactIds: (contactIds)=>
    query = @_fetchAllQuery().whereIn(@model.sfdc.id, contactIds)
    @fetchWithQuery(query)
    .then(@getAllEntitiesFromResponse)

module.exports = ContactsCollection