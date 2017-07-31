EntitiesCollection = require 'models/bll/entities-collection'
Product = require 'models/product'
SforceDataContext = require 'models/bll/sforce-data-context'
Query = require 'common/query'

class ProductsCollection extends EntitiesCollection
  model: Product

  prepareServerConfig: (configPromise) =>
    configPromise.then (config) =>
      config.query += " WHERE Local_Type__c = '#{@model.TYPE_LOCAL}'"
      config

  didStartDownloading: =>
    @fetchAll()
    .then @getAllEntitiesFromResponse
    .then @removeEntities

  getPromotedProducts: =>
    SforceDataContext.activeUser()
    .then (activeUser) =>
      atcClassArray = activeUser.pinCode.split ' '
      @fetchAllWhereIn(@model.sfdc.atcClass, atcClassArray)
      .then (response) => response.records

  getProductsByIds: (productsIds) =>
    @fetchAllWhereIn(@model.sfdc.id, productsIds)
    .then (response) => response.records

module.exports = ProductsCollection