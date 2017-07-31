EntitiesCollection = require 'models/bll/entities-collection'
ProductInPortfolio = require 'models/product-in-portfolio'
SforceDataContext = require 'models/bll/sforce-data-context'
TargetsCollection = require 'models/bll/targets-collection'
Utils = require 'common/utils'

class ProductInPortfoliosCollection extends EntitiesCollection
  model: ProductInPortfolio

  prepareServerConfig: (configPromise) =>
    configPromise.then (config) =>
      SforceDataContext.activeUser()
      .then (user) -> new TargetsCollection().getTargetByUser user
      .then (target) =>
        config.query += " " +
          "WHERE #{@model.sfdc.portfolioSfId} IN " +
          "(SELECT ProductPortfolio__c " +
          "FROM ProductPortfolioAssignment__c " +
          "WHERE Target__c = '#{target.id}') "
        config

module.exports = ProductInPortfoliosCollection