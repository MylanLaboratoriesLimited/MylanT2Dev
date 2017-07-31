TableController = require 'controls/table/table-controller'
TableCell = require 'controls/table/table-cell'
PromotionSkusCollection = require 'models/bll/promotion-skus-collection'

class SkusPopupTable extends TableController
  className: "#{@::className} skus-popup-table"

  constructor: ->
    super @
    @skusCollection = new PromotionSkusCollection
    @skus = []

  refreshTableByPromoId: (promoId) ->
    @skusCollection.getAllSkusForPromotionWithId promoId
    .then (@skus) =>
      if _.isEmpty(@skus) then @_renderEmptyTable(@el, Locale.value('tradeModule.Skus.NoSkus') )
      else @render().el.removeClass 'empty-table'

  _renderEmptyTable: (tableElement, text) ->
    tableElement.addClass 'empty-table'
    .html "<p>#{text}</p>"

  numberOfRowsForTable: (table) -> @skus?.length ? 0

  cellForRowAtIndexForTable: (index, table) -> @_createTableCell @skus[index]

  _createTableCell: (sku) ->
    new TableCell sku.productItemName


module.exports = SkusPopupTable