EntitiesCollection = require 'models/bll/entities-collection'
ProductItem = require 'models/product-item'

class ProductItemsCollection extends EntitiesCollection
  model: ProductItem

module.exports = ProductItemsCollection