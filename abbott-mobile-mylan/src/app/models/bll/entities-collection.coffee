Entity = require 'models/entity'
Query = require 'common/query'
ConfigurationManager = require 'db/configuration-manager'
Utils = require 'common/utils'

class EntitiesCollection extends Force.SObjectCollection
  @TYPE_WARNING: 'Warning'

  model: Entity
  pageSize: 1000
  loadBatchSize: 10000
  METHOD_CREATE: 'create'
  METHOD_UPDATE: 'update'
  METHOD_UPSERT: 'upsert'
  METHOD_DELETE: 'delete'

  constructor: ->
    super
    @cache = new Force.StoreCache @model.table, null

  ### SERVER ###

  serverConfig: =>
    @_mapFieldsList()
    .then (fields) =>
      soql = "SELECT #{fields.join(',')} FROM #{@model.sfdcTable}"
      config =
        type: 'soql'
        query: soql
        closeCursorImmediate: false
      @prepareServerConfig $.when(config)

  prepareServerConfig: (configPromise) =>
    configPromise

  _mapFieldsList: =>
    ConfigurationManager.getConfig()
    .then (configs) =>
      _.chain(@model.sfdcFields)
      .map (field) =>
        if @_shouldExcludeFieldForConfigs(field, configs) then null
        else if @_hasFieldIncludeSettings(field) then @_includedFieldForConfigs(field, configs)
        else if @model.isToLabel[field] then "toLabel(#{field})"
        else field
      .compact()
      .value()

  _shouldExcludeFieldForConfigs: (field, configs) =>
    fields = _.keys @model.excludableFields
    if _.contains fields, field
      not configs[@model.excludableFields[field]]
    else
      false

  _hasFieldIncludeSettings: (field) =>
    fields = _.keys @model.includableFields
    _.contains fields, field

  _includedFieldForConfigs: (field, configs) =>
    if configs[@model.includableFields[field]]
      field
    else
      null

  _onDownloadingStarted: ->
    @entitiesIdsForDelete = []
    $.when @didStartDownloading()

  didStartDownloading: ->
    # Can be overridden to perform some action

  _removeUnmodifiedEntitiesNotInScope: (recordsIds) ->
    if not recordsIds or recordsIds.length <= 0 then $.when()
    else
      @fetchUnparsedWithQuery(new Query().selectFrom(@model.table).where(__local__: false).and().whereNotIn(@model.sfdc.id, recordsIds))
      .then((response) => @getAllUnparsedEntitiesFromResponse response)
      .then @removeEntities

  _onDownloadingFinished: (records) =>
    @_removeUnmodifiedEntitiesNotInScope @entitiesIdsForDelete
    .then =>
      @entitiesIdsForDelete = []
      $.when(@didFinishDownloading())
      .then(-> records)

  _onPageDownloadFinished: (records)=>
    entitiesIds = records.map (record) => record[@model.sfdc.id]
    @entitiesIdsForDelete = @entitiesIdsForDelete.concat entitiesIds
    $.when(@didPageFinishDownloading(records))
    .then(->records)

  didPageFinishDownloading: (records) ->
    @cache.saveAll(records)

  didFinishDownloading: (records) ->
    # Can be overridden to perform some action

  _onUploadingStarted: (entities) =>
    $.when @didStartUploading(entities)

  didStartUploading: (entities) ->
    entities
    # Can be overridden to perform some action but should return (un-)modified entities to be uploaded !

  _onUploadingFinished: (records) =>
    $.when(@didFinishUploading records)
    .then -> records

  didFinishUploading: (records) ->
    # Can be overridden to perform some action

  sync: (method, model, options) ->
    deferred = new $.Deferred()
    options ?= {}
    if method is @METHOD_UPSERT
      options.success = (records) => @_onUploadingFinished(records).then deferred.resolve
      @_upsertEntitiesToServer options
    else
      options.success = (records) => @_onDownloadingFinished(records).then deferred.resolve
      options.error = (error) -> deferred.reject(error)
      @_onDownloadingStarted()
      .then => super method, model, options
    deferred.promise()

  _upsertEntitiesToServer: (options) =>
    shouldIgnoreDeleted = false
    @fetchWithQuery(new Query().selectFrom(@model.table).where(__local__: true), shouldIgnoreDeleted)
    .then(@getAllEntitiesFromResponse)
    .then((entities) => @_onUploadingStarted(entities))
    .then((entities) => @_upsertEntitiesToServerRecursively entities, options.each)
    .then(options.success)

  _upsertEntitiesToServerRecursively: (entities, eachStep) =>
    syncedEntities = []
    recursion = (entities, index) =>
      unless index < entities.length then $.when syncedEntities
      else
        @upsertEntityToServer(entities[index])
        .then (entity, errorObj) =>
          unless errorObj
            syncedEntities.push entity
            recursion entities, index+1
          else
            @_handleEntityUploadingErrorStep(entities[index], errorObj, eachStep)
            .then ->
              entities = _.without entities, entity
              recursion entities, index
    recursion entities, 0

  _handleEntityUploadingErrorStep: (entity, errorObj, step) =>
    error = @_errorFromResponse errorObj
    $.when(@handleErrorForEntity(error, entity))
    .then =>
      errorCode = error.details.errorCode
      if not _.contains @ignoreErrorCodes(), errorCode
        error.type = EntitiesCollection.TYPE_WARNING if _.contains @warningErrorCodes(), errorCode
        step(entity, error) if step

  _errorFromResponse: (response) ->
    error = response
    unless _.isObject response
      errors = JSON.parse(response)
      error = if _.isArray errors then _.first errors else errors
    new Force.Error error

  handleErrorForEntity: (error, entity) =>
    @removeEntity entity if error.details.errorCode is 'ENTITY_IS_DELETED'

  ignoreErrorCodes: ->
    ['ENTITY_IS_DELETED']

  warningErrorCodes: ->
    []

  _updateClmToolId: (entity, isForce) =>
    if (not entity.clmToolId) or isForce
      entity.clmToolId = Utils.generateUID()
      @updateEntity entity
      .then @parseEntity
    else
      $.when entity

  _checkExistingEntityOnServer: (method, entity, options) =>
    if (options.fieldlist.indexOf("CLM_Tool_Id__c") isnt -1) and (method isnt @METHOD_DELETE)
      @_updateClmToolId entity
      .then (record) =>
        onSuccess = (response) =>
          if response.totalSize
            record.id = response.records[0][@model.sfdc.id]
            record.attributes = _.extend record.attributes, {__local__: false, __locally_created__: false, __locally_updated__: false, __locally_deleted__: false}
            options.success record
          else
            record.sync method, record, options
        Force.forcetkClient.query "SELECT Id FROM #{@model.sfdcTable} WHERE #{@model.sfdc.clmToolId} = '#{record.clmToolId}'"
        .then onSuccess, options.error
    else
      entity.sync method, entity, options

  _beforeCheckExistingEntityOnServer: (entity, method) =>
    if method is @METHOD_UPDATE
      @_updateClmToolId entity, true
    else
      $.when true

  upsertEntityToServer: (entity) =>
    deferred = new $.Deferred()
    method = @_syncMethodForEntity entity
    options = {}
    options.cache = null
    options.cacheForOriginals = null
    options.cacheMode = Force.CACHE_MODE.SERVER_ONLY
    options.mergeMode = Force.MERGE_MODE.OVERWRITE
    options.fieldlist = @model.uploadableFields
    options.success = (record) =>
      promise = switch method
        when @METHOD_CREATE then @updateEntity record, false
        when @METHOD_UPDATE then @updateEntity record, false
        when @METHOD_DELETE then @removeEntity record, false
      promise.then (record) -> deferred.resolve record, null
    options.error = (jqXHR, textStatus, errorThrown) -> deferred.resolve(entity, jqXHR)
    @_beforeCheckExistingEntityOnServer entity, method
    .then => @_checkExistingEntityOnServer method, entity, options
    deferred.promise()

  _syncMethodForEntity: (entity) =>
    attributes = entity.attributes
    if attributes.__locally_deleted__ then @METHOD_DELETE
    else if attributes.__locally_created__ then @METHOD_CREATE
    else if attributes.__locally_updated__ and not attributes.__locally_deleted__ then @METHOD_UPDATE

  fetchRemoteObjectsFromServer: (config) =>
    Force.fetchSObjectsFromServer(config)
    .then @_loadNextBatchRecursively

  _loadNextBatchRecursively: (response) =>
    if response.hasMore()
      response.getMore(@loadBatchSize)
      .then @_onPageDownloadFinished
      .then => @_loadNextBatchRecursively(response)
    else
      response.closeCursor()
      .then => @_onPageDownloadFinished(response.records)
      .then => response

  ### CACHE ###

  mapMoreUnparsedEntitiesFromResponse: (response, step) =>
    step ?= (response, records) -> response
    unless response.hasMore() then $.when response
    else
      response.getMore()
      .then (records) => step(response, records)

  getMoreUnparsedEntitiesFromResponse: (response) =>
    @mapMoreUnparsedEntitiesFromResponse response

  getMoreEntitiesFromResponse: (response) =>
    @mapMoreUnparsedEntitiesFromResponse response, @_responseWithParsedRecords

  mapAllUnparsedEntitiesFromResponse: (response, step) =>
    step ?= (response, records) -> response
    recursion = (response, step) ->
      unless response.hasMore() then response.records
      else
        response.getMore()
        .then((records) -> $.when(step response, records))
        .then -> recursion response, step
    $.when(step response, response.records)
    .then -> recursion response, step

  getAllUnparsedEntitiesFromResponse: (response) =>
    @mapAllUnparsedEntitiesFromResponse response

  getAllEntitiesFromResponse: (response) =>
    @mapAllUnparsedEntitiesFromResponse response, @_responseWithParsedRecords

  _responseWithParsedRecords: (response, records) =>
    records = @parse records
    length = response.records.length
    response.records.splice.apply response.records, [length-records.length, records.length].concat(records)
    response

  parse: (records, options) =>
    records.map (result) => @parseEntity result, options

#  TODO: extract 'parseEntity' into 'Entity' class as 'parse' method (may be class method)
  parseEntity: (record, options) =>
    if @_isEntityParsed(record) then record
    else
      sobject = @parseModel record
      sobject.sobjectType = @model.sfdcTable
      sobject

  parseModel: (result) =>
    new @model result

  fetchUnparsedWithQuery: (query, ignoreDeleted=true) =>
    smartSql = @_createSmartSqlQuery query, @model.table, @pageSize
    @fetchRemoteObjectsFromCache(@cache, smartSql, ignoreDeleted)

  fetchWithQuery: (query, ignoreDeleted=true) =>
    @fetchUnparsedWithQuery(query, ignoreDeleted)
    .then (response) =>
      response.records = @parse response.records
      response

  _createSmartSqlQuery: (query, soup, pageSize) ->
    query = query.toString()
    queryType: 'smart'
    soupName: soup
    smartSql: query
    pageSize: pageSize

  fetchEntityById: (id) =>
    idFieldValue = {}
    idFieldValue[@model.sfdc.id] = id
    query = new Query().selectFrom(@model.table).where(idFieldValue)
    @fetchWithQuery(query)
    .then (response) =>
      record = @getEntityFromResponse response
      response.closeCursor()
      record

  getEntityFromResponse: (response) ->
    _.first(response.records) ? null

  _fetchAllQuery: =>
    new Query().selectFrom(@model.table)

  fetchAll: =>
    query = @_fetchAllQuery()
    @fetchWithQuery query

  fetchAllSortedBy: (fields, isAsc) =>
    order = if isAsc then Query.ASC else Query.DESC
    query = @_fetchAllQuery().orderBy(fields, order)
    @fetchWithQuery query

  fetchAllWhere: (fieldsValues) =>
    query = @_fetchAllQuery().where(fieldsValues)
    @fetchWithQuery query

  fetchAllWhereIn: (field, values) =>
    query = @_fetchAllQuery().whereIn(field, values)
    @fetchWithQuery query

  fetchAllLike: (fieldsValues) =>
    query = @_fetchAllQuery().whereLike(fieldsValues)
    @fetchWithQuery query

  fetchAllWhereLike: (whereFieldsValues, likeFieldsValues) =>
    query = @_fetchAllQuery().where(whereFieldsValues).and().whereLike(likeFieldsValues)
    @fetchWithQuery query

  fetchAllWhereAndSortBy: (fieldsValues, sortFields, isAsc) =>
    order = if isAsc then Query.ASC else Query.DESC
    query = @_fetchAllQuery().where(fieldsValues).orderBy(sortFields, order)
    @fetchWithQuery query

  fetchAllLikeAndSortBy: (fieldsValues, sortFields, isAsc) =>
    order = if isAsc then Query.ASC else Query.DESC
    query = @_fetchAllQuery().whereLike(fieldsValues).orderBy(sortFields, order)
    @fetchWithQuery query

  fetchAllWhereLikeAndSortBy: (whereFieldsValues, likeFieldsValues, sortFields, isAsc) =>
    order = if isAsc then Query.ASC else Query.DESC
    query = @_fetchAllQuery().where(whereFieldsValues).and().whereLike(likeFieldsValues).orderBy(sortFields, order)
    @fetchWithQuery query

  upsertEntitiesSilently: (entities) =>
    @_recursiveForEachBy entities, @pageSize, (entitiesBatch) =>
      Force.smartstoreClient.upsertSoupEntries @model.table, entitiesBatch

  markEntityAsNotModified: (entity) =>
    nonModifiedValues = {__local__: false, __locally_created__: false, __locally_updated__: false, __locally_deleted__: false}
    if @_isEntityParsed entity
      entity.attributes = _.extend entity.attributes, nonModifiedValues
    else
      entity = _.extend entity, nonModifiedValues
    Force.smartstoreClient.upsertSoupEntries @model.table, [entity]

  _recursiveForEachBy: (collection, stepBy, callback, index = 0) =>
    if index >= collection.length then $.when()
    else
      nextIndex = index + stepBy
      $.when(callback(collection.slice index, nextIndex))
      .then => @_recursiveForEachBy collection, stepBy, callback, nextIndex

  createEntity: (entity, localAction = true) =>
    attributes = @_attributesFromEntity(entity)
    Force.syncRemoteObjectWithCache @METHOD_CREATE, attributes[@model.sfdc.id], attributes, null, @cache, localAction

  updateEntity: (entity, localAction = true) =>
    attributes = @_attributesFromEntity(entity)
    Force.syncRemoteObjectWithCache @METHOD_UPDATE, attributes[@model.sfdc.id], attributes, null, @cache, localAction

  removeEntity: (entity, localAction = true) =>
    attributes = @_attributesFromEntity(entity)
    Force.syncRemoteObjectWithCache @METHOD_DELETE, attributes[@model.sfdc.id], null, null, @cache, localAction

  removeEntities: (entities) =>
    Force.smartstoreClient.removeFromSoup @model.table, entities.map (entity) => @_attributesFromEntity(entity)._soupEntryId

  _attributesFromEntity: (entity) =>
    if @_isEntityParsed entity then entity.attributes else entity

  _isEntityParsed: (entity) =>
    entity?.hasOwnProperty 'cid'

  linkEntitiesToEntity: (entities, field) =>
    soupEntryIds = _.uniq entities.map (entity) => entity[field]
    @fetchAllWhereIn "_soupEntryId", soupEntryIds
    .then @getAllEntitiesFromResponse
    .then (records) =>
      entitiesMap = {}
      records.forEach (record) =>
        entitiesMap[record.attributes._soupEntryId] = record.id
      entities = entities.map (entity) =>
        unless entity.attributes.__locally_deleted__
          entity[field] = entitiesMap[entity[field]] if entitiesMap[entity[field]]
        entity
      entities

module.exports = EntitiesCollection