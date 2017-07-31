EntitiesCollection = require 'models/bll/entities-collection'
PharmaEvent = require 'models/pharma-event'
Utils = require 'common/utils'
Query = require 'common/query'

class PharmaEventsCollection extends EntitiesCollection
  model: PharmaEvent

  constructor: ->
    super
    @cache.noMerge = false
    @cache.mergeMode = Force.MERGE_MODE.MERGE_ACCEPT_YOURS

  didPageFinishDownloading: (records) ->
    @_updateOwner records

  _updateOwner: (pharmaEvents) ->
    updatedPharmaEvents = pharmaEvents.map (pharmaEvent) ->
      if pharmaEvent.Owner
        pharmaEvent.ownerFirstName = pharmaEvent.Owner.FirstName
        pharmaEvent.ownerLastName = pharmaEvent.Owner.LastName
      else
        pharmaEvent.ownerFirstName = ''
        pharmaEvent.ownerLastName = ''
      pharmaEvent
    @cache.saveAll updatedPharmaEvents

  didStartUploading: (records) =>
    @_removeEmptyProducts(records)

  _removeEmptyProducts: (records) =>
    ProductsCollection = require 'models/bll/products-collection'
    productsCollection = new ProductsCollection
    peWithEmptyProducts = []
    peWithEmptyProductsForDelete = []
    peWithEmptyProductsForUpdate = []
    productsCollection.fetchAll()
    .then productsCollection.getAllEntitiesFromResponse
    .then (products) =>
      # TODO REFACTOR!!!
      productsMapped = products.map (product) -> product.id
      records.forEach (record) =>
        [1..4].forEach (index) =>
          if (productsMapped.indexOf(record["productPrio#{index}SfId"]) is -1) and (record["productPrio#{index}SfId"])
            peWithEmptyProducts.push record if peWithEmptyProducts.indexOf(record) is -1
      peWithEmptyProducts.forEach (record) =>
        emptyProdCount = [1..4].filter (index) =>
          (productsMapped.indexOf(record["productPrio#{index}SfId"]) is -1) and (record["productPrio#{index}SfId"])
        totalProdCount = [1..4].filter (index) => record["productPrio#{index}SfId"]
        if emptyProdCount.length is totalProdCount.length
          peWithEmptyProductsForDelete.push record
        else
          updateIndexes = [1..4].filter (index) =>
            (productsMapped.indexOf(record["productPrio#{index}SfId"]) isnt -1) and (record["productPrio#{index}SfId"])
          productsMessages = []
          updateIndexes.forEach (index) =>
            productsMessages.push {
              "prioProductSfid": record["productPrio#{index}SfId"]
            }
          [1..4].forEach (updateIndex, index) =>
            if productsMessages[index]
              record["productPrio#{updateIndex}SfId"] = productsMessages[index]["prioProductSfid"]
            else
              record["productPrio#{updateIndex}SfId"] = undefined
          peWithEmptyProductsForUpdate.push record
      Utils.runSimultaneously peWithEmptyProductsForUpdate.map (record) =>
        @updateEntity record
    .then =>
      @removeEntities peWithEmptyProductsForDelete
    .then =>
      shouldIgnoreDeleted = false
      @fetchWithQuery(new Query().selectFrom(@model.table).where(__local__: true), shouldIgnoreDeleted)
      .then(@getAllEntitiesFromResponse)

module.exports = PharmaEventsCollection