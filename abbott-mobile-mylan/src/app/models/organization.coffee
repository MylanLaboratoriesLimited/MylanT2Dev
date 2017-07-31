Entity = require 'models/entity'
ReferencesCollection = require 'models/bll/references/references-collection'
TargetReferencesCollection = require 'models/bll/references/target-references-collection'
CallReportsCollection = require 'models/bll/call-reports-collection/call-reports-collection'
ContactsCollection = require 'models/bll/contacts-collection'
Query = require 'common/query'
Utils = require 'common/utils'

class Organization extends Entity
  @table: 'Organization'
  @sfdcTable: 'Account'
  @description: 'Organization'

  references: null
  targetReferences: null
  activities: null

  @schema: ->
    [
      {local:'id',              sfdc:'Id'}
      {local:'name',            sfdc:'Name', search:true, indexWithType:'string'}
      {local:'brickSfId',       sfdc:'Brick__c'}
      {local:'status',          sfdc:'Status__c'}
      {local:'recordType',      sfdc:'RecordType.Name', search:true, indexWithType:'string'}
      {local:'country',         sfdc:'BillingCountry', search:true, indexWithType:'string'}
      {local:'city',            sfdc:'BillingCity', search:true, indexWithType:'string'}
      {local:'address',         sfdc:'BillingStreet', search:true, indexWithType:'string'}
      {local:'postalCode',      sfdc:'BillingPostalCode'}
      {local:'phone',           sfdc:'Phone', search:true, indexWithType:'string'}
      {local:'specialty1',      sfdc:'C_Specialty_1__c', indexWithType:'string', toLabel:true, search:true}
      {local:'specialty2',      sfdc:'C_Specialty_2__c', toLabel:true}
      {local:'isPersonAccount', sfdc:'IsPersonAccount', indexWithType:'string'}
      {local:'juridicGroup',    sfdc:'C_Juridic_Group__c', toLabel:true, include: 'isJuridicGroupEnabled'}
      {local:'globalPriority',  sfdc:'GlobalPriority__c', search:true, indexWithType:'string', exclude:'isTradeModuleEnabled'}
    ]

  nameAndAddress: ->
    "#{@name ? ''} <br/> #{@fullAddress()}"

  fullAddress: ->
    "#{@address ? ''} #{@city ? ''}"

  getReferences: ->
    if @references then $.when @references
    else
      collection = new ReferencesCollection
      fieldsWithValues = {}
      fieldsWithValues[collection.model.sfdc.organizationSfId] = @id
      collection.fetchAllWhere(fieldsWithValues)
      .then((response) => collection.getAllEntitiesFromResponse response)
      .then((@references) => @references)

  getActivitiesInMarketingCycle: (marketingCycle) =>
    ConfigurationManager = require 'db/configuration-manager'
    ConfigurationManager.getConfig('numberOfMonthsForCalls')
    .then (numberOfMonthsForCalls) =>
      if numberOfMonthsForCalls is 0
        @_getActivitiesByStartEndDate marketingCycle.startDate, marketingCycle.endDate
      else
        @_getActivitiesByStartEndDate moment().add(-numberOfMonthsForCalls, 'month'), moment()

  _getActivitiesByStartEndDate: (startDate, endDate) =>
    collection = new CallReportsCollection
    organisationValue = {}
    startDateValue = {}
    endDateValue = {}
    organisationValue[collection.model.sfdc.organizationSfId] = @id
    startDateValue[collection.model.sfdc.dateTimeOfVisit] = Utils.originalStartOfDate startDate
    endDateValue[collection.model.sfdc.dateTimeOfVisit] = Utils.originalEndOfDate endDate
    query = new Query().selectFrom(collection.model.table).where(organisationValue).and().where(startDateValue, Query.GRE).and().where(endDateValue, Query.LRE).orderBy([collection.model.sfdc.dateTimeOfVisit])
    collection.fetchWithQuery(query).then collection.getAllEntitiesFromResponse

  getActivities: =>
    if @activities then $.when @activities
    else
      collection = new CallReportsCollection
      fieldsWithValues = {}
      fieldsWithValues[collection.model.sfdc.organizationSfId] = @id
      collection.fetchAllWhere(fieldsWithValues)
      .then((response) => collection.getAllEntitiesFromResponse response)
      .then((@activities) => @activities)

  getTargetReferences: =>
    if @targetReferences then $.when @targetReferences
    else
      collection = new TargetReferencesCollection
      organisationValue = {}
      organisationValue[collection.model.sfdc.organizationSfId] = @id
      collection.fetchAllWhere(organisationValue)
      .then(collection.getAllEntitiesFromResponse)
      .then((@targetReferences) => @targetReferences)

  hasAnyTargetReferences: =>
    @getTargetReferences().then (@targetReferences) => @targetReferences?.length > 0

module.exports = Organization