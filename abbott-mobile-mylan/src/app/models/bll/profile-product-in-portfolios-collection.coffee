EntitiesCollection = require 'models/bll/entities-collection'
ProfileProductInPortfolio = require 'models/profile-product-in-portfolio'
ProductInPortfoliosCollection = require 'models/bll/product-in-portfolios-collection'
Utils = require 'common/utils'
Query = require 'common/query'

class ProfileProductInPortfoliosCollection extends EntitiesCollection
  model: ProfileProductInPortfolio

  parseModel: (result) ->
    result[@model.sfdc.productSfId] = result.Product_in_Porfolio__r?.Pharma_Product__c
    if result.Patient_Profile__r
      result[@model.sfdc.patientProfileName] = result.Patient_Profile__r.Name
      result[@model.sfdc.age] = result.Patient_Profile__r.Age__c
      result[@model.sfdc.gender] = result.Patient_Profile__r.Gender__c
      result[@model.sfdc.generalHealth] = result.Patient_Profile__r.General_Health__c
      result[@model.sfdc.occupation] = result.Patient_Profile__r.Occupation_Social__c
      result[@model.sfdc.bmi] = result.Patient_Profile__r.BMI__c
    super result

  prepareServerConfig: (configPromise) =>
    configPromise.then (config) =>
      productInPortfoliosCollection = new ProductInPortfoliosCollection
      productInPortfoliosCollection.fetchAll()
      .then productInPortfoliosCollection.getAllEntitiesFromResponse
      .then (productInPortfolios) =>
        productInPortfolioIds = productInPortfolios.map (productInPortfolio) -> "'#{productInPortfolio.id}'"
        if _.isEmpty(productInPortfolioIds) then productInPortfolioIds = null
        config.query += " WHERE #{@model.sfdc.productInPortfolioSfId} IN (#{productInPortfolioIds ? 'Null'})"
        config

  didPageFinishDownloading: (records) ->
    @_updateProfileProductInPortfolios records

  _updateProfileProductInPortfolios: (portfolioProfiles) ->
    updatedPortfolioProfiles = portfolioProfiles.map (portfolioProfile) ->
      if portfolioProfile.Product_in_Porfolio__r
        portfolioProfile.portfolioStartDate = portfolioProfile.Product_in_Porfolio__r.Start_Date__c
        portfolioProfile.portfolioEndDate = portfolioProfile.Product_in_Porfolio__r.End_Date__c
      portfolioProfile
    @cache.saveAll updatedPortfolioProfiles

  fetchPortfolioProfilesByDate: (date)=>
    startDateValue = { portfolioStartDate: date }
    endDateValue = { portfolioEndDate: date }
    query = new Query()
    .selectFrom(@model.table)
    .where(startDateValue, Query.LRE)
    .and().where(endDateValue, Query.GRE)
    @fetchWithQuery(query)
    .then @getAllEntitiesFromResponse

module.exports = ProfileProductInPortfoliosCollection