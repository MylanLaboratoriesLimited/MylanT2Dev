Entity = require 'models/entity'
Query = require 'common/query'
BuTeamPersonProfilesCollection = require 'models/bll/bu-team-person-profiles-collection'
Utils = require 'common/utils'

class Contact extends Entity
  @table: 'Contact'
  @sfdcTable: 'Contact'
  @description: 'Contact'

  @STATUS_ACTIVE: 'Active'

  organization: null
  references: null
  activities: null

  @schema: ->
    [
      {local:'id',              sfdc:'Id'}
      {local:'firstName',       sfdc:'FirstName', search:true, indexWithType:'string'}
      {local:'lastName',        sfdc:'LastName', search:true, indexWithType:'string'}
      {local:'jobTitle',        sfdc:'C_Job_Title__c', toLabel:true}
      {local:'recordType',      sfdc:'Account.RecordType.Name'}
      {local:'status',          sfdc:'Account.Status__c'}
      {local:'organizationSfId',sfdc:'AccountId'}
      {local:'gender',          sfdc:'Gender__c'}
      {local:'yearOfGraduation',sfdc:'Year_of_Graduation__c'}
      {local:'mobilePhone',     sfdc:'MobilePhone'}
      {local:'homePhone',       sfdc:'HomePhone'}
      {local:'email',           sfdc:'Email'}
      {local:'kol',             sfdc:'KOL__c'}
      {local:'specialty',       sfdc:'Account.C_Specialty_1__c'}
      {local:'description',     sfdc:'Description'}
      {local:'priority'}
      {local:'isTargetCustomer',indexWithType:'string'}
      {local:'lastDateTargetFrequency'}
      {local:'abbottSpecialty', indexWithType:'string', search:true}
    ]

  fullName: ->
    "#{@lastName ? ''} #{@firstName ? ''}"

  targetCustomer: ->
    if @isTargetCustomer then 'yes' else 'no'

  # TODO: assign on 'didFinishDownloading'
  getOrganization: ->
    if @organization then $.when @organization
    else
      OrganizationsCollection = require 'models/bll/organizations-collection'
      collection = new OrganizationsCollection
      collection.fetchEntityById(@organizationSfId)
      .then (@organization) => @organization

  getReferences: ->
    if @references then $.when @references
    else
      ReferencesCollection = require 'models/bll/references/references-collection'
      collection = new ReferencesCollection
      fieldsWithValues = {}
      fieldsWithValues[collection.model.sfdc.contactSfId] = @id
      collection.fetchAllWhere(fieldsWithValues)
      .then collection.getAllEntitiesFromResponse
      .then (@references) => @references

  getActivitiesInMarketingCycle: (marketingCycle) =>
    ConfigurationManager = require 'db/configuration-manager'
    ConfigurationManager.getConfig('numberOfMonthsForCalls')
    .then (numberOfMonthsForCalls) =>
      if numberOfMonthsForCalls is 0
        @_getActivitiesByStartEndDate marketingCycle.startDate, marketingCycle.endDate
      else
        @_getActivitiesByStartEndDate moment().add(-numberOfMonthsForCalls, 'month'), moment()

  _getActivitiesByStartEndDate: (startDate, endDate) =>
    CallReportsCollection = require 'models/bll/call-reports-collection/call-reports-collection'
    collection = new CallReportsCollection
    contactValue = {}
    startDateValue = {}
    endDateValue = {}
    contactValue[collection.model.sfdc.contactSfid] = @id
    startDateValue[collection.model.sfdc.dateTimeOfVisit] = Utils.originalStartOfDate startDate
    endDateValue[collection.model.sfdc.dateTimeOfVisit] = Utils.originalEndOfDate endDate
    query = new Query().selectFrom(collection.model.table).where(contactValue).and().where(startDateValue, Query.GRE).and().where(endDateValue, Query.LRE).orderBy([collection.model.sfdc.dateTimeOfVisit])
    collection.fetchWithQuery(query).then collection.getAllEntitiesFromResponse

  getActivities: ->
    if @activities then $.when @activities
    else
      CallReportsCollection = require 'models/bll/call-reports-collection/call-reports-collection'
      collection = new CallReportsCollection
      fieldsWithValues = {}
      fieldsWithValues[collection.model.sfdc.contactSfid] = @id
      collection.fetchAllWhere(fieldsWithValues)
      .then collection.getAllEntitiesFromResponse
      .then (@activities) => @activities

module.exports = Contact