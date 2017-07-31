Query = require 'common/query'

class PicklistManager
  @_restPath: '/picklist'
  @_soupName: 'PickList'
  @_identityKey: 'objectFieldName'

  @_indexSpec = [
    {
      path: @_identityKey
      type: 'string'
    }
  ]

  @_initSoup: () ->
    Force.smartstoreClient.soupExists(@_soupName).then (soupExist) =>
      unless soupExist then Force.smartstoreClient.registerSoup @_soupName, @_indexSpec else $.when()

  @_getRequestParams: (objectType, fieldNames) ->
    params = {
      'sobjectType': objectType
      'pickListFieldAPINames': fieldNames
    }
    JSON.stringify params

  @_composeIdentityKey: (keyComponents = []) ->
    keyComponents.join ':'

  @_processBeforeSave: (pickListObject) ->
    _.map pickListObject.picklists, (listItem) =>
      listItem[@_identityKey] = @_composeIdentityKey [ pickListObject['objectName'], listItem['fieldName'] ]
      listItem

  @_generateSearchCriterias: (objectType, fieldNames) ->
    _.map fieldNames, (fieldName) =>
      @_composeIdentityKey [ objectType, fieldName ]

  @_generateFetchQuery: (objectType, fieldNames) ->
    criterias = @_generateSearchCriterias objectType, fieldNames
    query = new Query @_soupName
    query.selectFrom(@_soupName).whereIn @_identityKey, criterias
    navigator.smartstore.buildSmartQuerySpec(query.toString())

  @_processResult: (pickListCollection) ->
    result = {}
    _.each pickListCollection['currentPageOrderedEntries'], (group) ->
      _.each group, (pickListGroup) ->
        result[pickListGroup['fieldName']] = pickListGroup['picklistOptions']
    result

  @loadPicklist: (objectType, fieldNames = []) =>
    @_initSoup().then =>
      fieldParams = @_getRequestParams objectType, fieldNames
      Force.forcetkClient.apexrest(@_restPath, 'POST', fieldParams, {}).then (pickListObject) =>
        pickListObject = @_processBeforeSave pickListObject
        Force.smartstoreClient.upsertSoupEntriesWithExternalId @_soupName, pickListObject, @_identityKey

  @getPicklist: (objectType, fieldNames = []) =>
    Force.smartstoreClient.soupExists(@_soupName).then (soupExist) =>
      if soupExist
        searchQuery = @_generateFetchQuery objectType, fieldNames
        Force.smartstoreClient.runSmartQuery(searchQuery).then (pickListCollection) =>
          pickListCollection = @_processResult pickListCollection
          $.when pickListCollection
      else
        $.when []

  @clearData: ->
    Force.smartstoreClient.soupExists(@_soupName)
    .then((soupExists) => Force.smartstoreClient.removeSoup @_soupName if soupExists)
    .done => @_initSoup

module.exports = PicklistManager