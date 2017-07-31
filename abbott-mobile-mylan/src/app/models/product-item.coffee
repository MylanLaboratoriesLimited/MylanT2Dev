Entity = require 'models/entity'

class ProductItem extends Entity
  @table: 'ProductItem'
  @sfdcTable: 'Product_Items__c'
  @description: 'Product Item'

  @schema: ->
    [
      {local:'id',                sfdc:'Id'}
      {local:'description',       sfdc:'Description__c'}
      {local:'imsSkuCode',        sfdc:'IMS_sku_code__c'}
      {local:'parallelImport',    sfdc:'Parallel_Import__c'}
      {local:'productBrandName',  sfdc:'Product_Brand_Name__c'}
      {local:'productDetailCode', sfdc:'Product_Detail_Code__c'}
      {local:'productTypeDetect', sfdc:'Product_Type_detect__c'}
    ]

module.exports = ProductItem