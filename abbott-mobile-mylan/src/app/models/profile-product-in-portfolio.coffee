Entity = require 'models/entity'

class ProfileProductInPortfolio extends Entity
  @table: 'ProfileProductInPortfolio'
  @sfdcTable: 'Products_on_Patient_Profile__c'
  @description: 'Profile Product In Portfolio'

  @schema: ->
    [
      {local:'id',                        sfdc:'Id'}
      {local:'patientProfileSfId',        sfdc:'Patient_Profile__c'}
      {local:'portfolioName',             sfdc:'PortfolioName__c'}
      {local:'productName',               sfdc:'Product__c'}
      {local:'productInPortfolioSfId',    sfdc:'Product_in_Porfolio__c'}
      {local:'productSfId',               sfdc:'Product_in_Porfolio__r.Pharma_Product__c'}
      {local:'patientProfileName',        sfdc:'Patient_Profile__r.Name'}
      {local:'age',                       sfdc:'Patient_Profile__r.Age__c'}
      {local:'gender',                    sfdc:'Patient_Profile__r.Gender__c'}
      {local:'generalHealth',             sfdc:'Patient_Profile__r.General_Health__c'}
      {local:'occupation',                sfdc:'Patient_Profile__r.Occupation_Social__c'}
      {local:'bmi',                       sfdc:'Patient_Profile__r.BMI__c'}
      {local:'remotePortfolioStartDate',  sfdc:'Product_in_Porfolio__r.Start_Date__c'}
      {local:'remotePortfolioEndDate',    sfdc:'Product_in_Porfolio__r.End_Date__c'}
      {local:'portfolioStartDate',              indexWithType:'string'}
      {local:'portfolioEndDate',                indexWithType:'string'}
    ]

module.exports = ProfileProductInPortfolio