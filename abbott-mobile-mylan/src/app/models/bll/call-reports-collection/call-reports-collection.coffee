EntitiesCollection = require 'models/bll/entities-collection'
CallReport = require 'models/call-report'
Query = require 'common/query'
Utils = require 'common/utils'
SettingsManager = require 'db/settings-manager'
ConfigurationManager = require 'db/configuration-manager'

class CallReportsCollection extends EntitiesCollection
  model: CallReport
  ALL_TYPES: 'ALL_TYPES'

  _dataType: ->
    @ALL_TYPES

  _fetchAllQuery: ->
    query = new Query().selectFrom(@model.table)
    dataType = @_dataType()
    if dataType is @ALL_TYPES then query else query.where(dataType)

  constructor: ->
    super
    @cache.noMerge = false
    @cache.mergeMode = Force.MERGE_MODE.MERGE_ACCEPT_YOURS

  prepareServerConfig: (configPromise) =>
    configPromise.then (config) =>
      minVisitDate = Utils.toSalesForceDateTimeFormat moment().subtract('months', 2)
      @_mapFieldsList()
      .then (fields) -> ConfigurationManager.getConfig('callReportProductsSettings').then (configs) -> [fields, configs]
      .then ([fields, callReportProductsSettings]) =>
        fields = @_fieldsWithExcludeProductFieldsByConfig fields, callReportProductsSettings
        config.query = "SELECT #{fields.join(',')} FROM #{@model.sfdcTable} "
        config.query += "WHERE #{@model.sfdc.dateTimeOfVisit} > #{minVisitDate} AND Contact1__r.Id != Null AND Organisation__r.Id != Null"
        config

  _fieldsWithExcludeProductFieldsByConfig: (fields, config) =>
    numberOfProducts = config.numberOfPromotedProducts+1
    if numberOfProducts >= @model.MAX_PRODUCTS_NUMBER then fields
    else
      fieldsToExclude = []
      [numberOfProducts .. @model.MAX_PRODUCTS_NUMBER].forEach (i) ->
        fieldsToExclude.push "Prio_#{i}_Product__c"
        fieldsToExclude.push "Note_for_Prio_#{i}__c"
        fieldsToExclude.push "Prio_#{i}_Marketing_Message_1__c"
        fieldsToExclude.push "Prio_#{i}_Marketing_Message_2__c"
        fieldsToExclude.push "Prio_#{i}_Marketing_Message_3__c"
      _.difference fields, fieldsToExclude

  parseModel: (result) =>
    if result.User__r
      result[@model.sfdc.userFirstName] = result.User__r.FirstName
      result[@model.sfdc.userLastName] = result.User__r.LastName
    if result.Contact1__r
      result[@model.sfdc.contactRecordType] = result.Contact1__r.Account?.RecordType.Name
    if result.Organisation__r
      result[@model.sfdc.organizationName] = result.Organisation__r.Name
      result[@model.sfdc.organizationCity] = result.Organisation__r.BillingCity
      result[@model.sfdc.organizationAddress] = result.Organisation__r.BillingStreet
    super result

  didPageFinishDownloading: (records) ->
    @_updateCallReports records

  _updateCallReports: (callReports) ->
    updatedCallReports = callReports.map (callReport) ->
      if callReport.Contact1__r
        callReport.contactFirstName = callReport.Contact1__r.FirstName
        callReport.contactLastName = callReport.Contact1__r.LastName
      else
        callReport.contactFirstName = ''
        callReport.contactLastName = ''
      if callReport.Organisation__r
        callReport.organizationName = callReport.Organisation__r.Name
      callReport
    @cache.saveAll updatedCallReports

  didStartUploading: (records) ->
    brokenCalls = []
    callsToUpload = []
    @_removeEmptyProducts(records)
    .then (records) =>
      splitBrokenCalls = _.groupBy records, (record) -> record.isSandbox is true
      brokenCalls = splitBrokenCalls.true ? []
      callsToUpload = splitBrokenCalls.false ? []
      @_applyForTradeModuleAndEdetailingIfAnyEnabled brokenCalls, @_cleanBrokenCallReportData, (records) =>
        $.when @_cleanBrokenAdjustments(@_createPhotoAdjustmentsCollection(), records),
          @_cleanBrokenAdjustments(@_createTaskAdjustmentsCollection(), records),
          @_cleanBrokenAdjustments(@_createMechanicAdjustmentsCollection(), records)
    .then => @removeEntities brokenCalls
    .then -> callsToUpload

  _removeEmptyProducts: (records) =>
    ProductsCollection = require 'models/bll/products-collection'
    productsCollection = new ProductsCollection
    callReportsWithEmptyProducts = []
    callReportsWithEmptyProductsForDelete = []
    callReportsWithEmptyProductsForUpdate = []
    productsCollection.fetchAll()
    .then productsCollection.getAllEntitiesFromResponse
    .then (products) =>
      # TODO REFACTOR!!!
      productsMapped = products.map (product) -> product.id
      records.forEach (record) =>
        [1..10].forEach (index) =>
          if (productsMapped.indexOf(record["prio#{index}ProductSfid"]) is -1) and (record["prio#{index}ProductSfid"])
            callReportsWithEmptyProducts.push record if callReportsWithEmptyProducts.indexOf(record) is -1
      callReportsWithEmptyProducts.forEach (record) =>
        emptyProdCount = [1..10].filter (index) =>
          (productsMapped.indexOf(record["prio#{index}ProductSfid"]) is -1) and (record["prio#{index}ProductSfid"])
        totalProdCount = [1..10].filter (index) => record["prio#{index}ProductSfid"]
        if emptyProdCount.length is totalProdCount.length
          callReportsWithEmptyProductsForDelete.push record
        else
          updateIndexes = [1..10].filter (index) =>
            (productsMapped.indexOf(record["prio#{index}ProductSfid"]) isnt -1) and (record["prio#{index}ProductSfid"])
          productsMessages = []
          updateIndexes.forEach (updateIndex) =>
            productsMessages.push {
              "prioProductSfid": record["prio#{updateIndex}ProductSfid"]
              "noteForPrio": record["noteForPrio#{updateIndex}"]
              "prioMarketingMessage1":  record["prio#{updateIndex}MarketingMessage1"]
              "prioMarketingMessage2":  record["prio#{updateIndex}MarketingMessage2"]
              "prioMarketingMessage3":  record["prio#{updateIndex}MarketingMessage3"]
              "patientProfile": record["patientProfile#{updateIndex}"]
              "prioClassification":  record["prio#{updateIndex}Classification"]
            }
          [1..10].forEach (updateIndex, index) =>
            if productsMessages[index]
              record["prio#{updateIndex}ProductSfid"] = productsMessages[index]["prioProductSfid"]
              record["noteForPrio#{updateIndex}"] = productsMessages[index]["noteForPrio"]
              record["prio#{updateIndex}MarketingMessage1"] = productsMessages[index]["prioMarketingMessage1"]
              record["prio#{updateIndex}MarketingMessage2"] = productsMessages[index]["prioMarketingMessage2"]
              record["prio#{updateIndex}MarketingMessage3"] = productsMessages[index]["prioMarketingMessage3"]
              record["patientProfile#{updateIndex}"] = productsMessages[index]["patientProfile"]
              record["prio#{updateIndex}Classification"] = productsMessages[index]["prioClassification"]
            else
              record["prio#{updateIndex}ProductSfid"] = undefined
              record["noteForPrio#{updateIndex}"] = undefined
              record["prio#{updateIndex}MarketingMessage1"] = undefined
              record["prio#{updateIndex}MarketingMessage2"] = undefined
              record["prio#{updateIndex}MarketingMessage3"] = undefined
              record["patientProfile#{updateIndex}"] = undefined
              record["prio#{updateIndex}Classification"] = undefined
          callReportsWithEmptyProductsForUpdate.push record
      Utils.runSimultaneously callReportsWithEmptyProductsForUpdate.map (record) =>
        @updateEntity record
    .then =>
      @removeEntities callReportsWithEmptyProductsForDelete
    .then =>
      shouldIgnoreDeleted = false
      @fetchWithQuery(new Query().selectFrom(@model.table).where(__local__: true), shouldIgnoreDeleted)
      .then(@getAllEntitiesFromResponse)

  _cleanBrokenAdjustments: (collection, callReports) =>
    @_cleanCollectionByCallsWithQueryFields collection, callReports, collection.model.sfdc.callReportSfId

  _cleanBrokenCallReportData: (callReports) =>
    callReportDataCollection = @_createCallReportDataCollection()
    @_cleanCollectionByCallsWithQueryFields callReportDataCollection, callReports, callReportDataCollection.model.sfdc.callReportId

  _cleanCollectionByCallsWithQueryFields: (collection, callReports, callReportIdField) =>
    @_runSimultaneouslyForCollectionByEachCallWithQueryField collection, callReports, callReportIdField, (entities, _) -> collection.removeEntities entities

  _updateAdjustments: (collection, callReports) =>
     @_updateCollectionByCallsWithQueryFields collection, callReports, collection.model.sfdc.callReportSfId

  _updateCallReportsData: (callReports) =>
    callReportDataCollection = @_createCallReportDataCollection()
    @_updateCollectionByCallsWithQueryFields callReportDataCollection, callReports, callReportDataCollection.model.sfdc.callReportId

  _updateCollectionByCallsWithQueryFields: (collection, callReports, callReportIdField) =>
    @_runSimultaneouslyForCollectionByEachCallWithQueryField collection, callReports, callReportIdField, (entities, callReport) =>
      entities = entities.map (entity) =>
        entity.attributes[callReportIdField] = callReport[@model.sfdc.id]
        entity
      collection.upsertEntitiesSilently entities

  _applyForTradeModuleAndEdetailingIfAnyEnabled: (records, applyForEdetailing, applyForTradeModule) =>
    SettingsManager.getValueByKey('isTradeModuleEnabled')
    .then (isTradeModuleEnabled) =>
      unless isTradeModuleEnabled then $.when(records)
      else applyForTradeModule records
    .then =>
      SettingsManager.getValueByKey('isEdetailingEnabled')
      .then (isEdetailingEnabled) => applyForEdetailing records if isEdetailingEnabled

  _runSimultaneouslyForCollectionByEachCallWithQueryField: (collection, callReports, callReportIdField, forEach) =>
    Utils.runSimultaneously _(callReports).map (callReport) =>
      return unless callReport
      queryFields = {}
      queryFields[callReportIdField] = @_attributesFromEntity(callReport)._soupEntryId
      collection.fetchAllWhere(queryFields)
      .then collection.getAllEntitiesFromResponse
      .then (entities) -> forEach entities, callReport

  _createPhotoAdjustmentsCollection: =>
    PhotoAdjustmentsCollection = require 'models/bll/photo-adjustments-collection'
    new PhotoAdjustmentsCollection

  _createTaskAdjustmentsCollection: =>
    TaskAdjustmentsCollection = require 'models/bll/task-adjustments-collection'
    new TaskAdjustmentsCollection

  _createMechanicAdjustmentsCollection: =>
    MechanicAdjustmentsCollection = require 'models/bll/mechanic-adjustments-collection'
    new MechanicAdjustmentsCollection

  _createCallReportDataCollection: =>
    CallReportDataCollection = require 'models/bll/clm-call-report-data-collection'
    new CallReportDataCollection

# TODO: make receiving products with messages
#    "
#    SELECT {Pharma_Product_Messages__c:_soup}, {Pharma_Product__c:_soup}
#    FROM {Pharma_Product_Messages__c}, {Pharma_Product__c}
#    WHERE {Pharma_Product_Messages__c:Pharma_Product__c} = {Pharma_Product__c:Id}"

module.exports = CallReportsCollection