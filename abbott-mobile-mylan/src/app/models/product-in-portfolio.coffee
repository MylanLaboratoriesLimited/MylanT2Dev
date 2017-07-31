Entity = require 'models/entity'

class ProductInPortfolio extends Entity
  @table: 'ProductInPortfolio'
  @sfdcTable: 'Product_in_Porfolio__c'
  @description: 'Product In Portfolio'

  @schema: ->
    [
      {local:'id',                    sfdc:'Id'}
      {local:'productSfId',           sfdc:'Pharma_Product__c'}
      {local:'portfolioSfId',         sfdc:'Product_Portfolio__c'}
      {local:'startDate',             sfdc:'Start_Date__c'}
      {local:'endDate',               sfdc:'End_Date__c'}
      {local:'brandName',             sfdc:'Global_Brand_Name__c'}
    ]

module.exports = ProductInPortfolio