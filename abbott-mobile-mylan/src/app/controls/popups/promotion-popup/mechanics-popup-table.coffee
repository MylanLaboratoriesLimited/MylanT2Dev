TableController = require 'controls/table/table-controller'
TableCell = require 'controls/table/table-cell'
PromotionMechanicsCollection = require 'models/bll/promotion-mechanics-collection'


class mechanicsPopupTable extends TableController
  className: "#{@::className} mechanics-popup-table"

  constructor: ->
    super @
    @mechanicsCollection = new PromotionMechanicsCollection
    @mechanics = []

  refreshTableByPromoId: (promoId) ->
    @mechanicsCollection.getAllMechanicsForPromotionWithId(promoId)
    .then (@mechanics) =>
      if _.isEmpty(@mechanics) then @_renderEmptyTable(@el, Locale.value('tradeModule.Tactics.NoMechanics') )
      else @render().el.removeClass 'empty-table'

  _renderEmptyTable: (tableElement, text) ->
    tableElement.addClass 'empty-table'
    .html "<p>#{text}</p>"

  numberOfRowsForTable: (table) -> @mechanics?.length ? 0

  cellForRowAtIndexForTable: (index, table) -> @_createTableCell @mechanics[index]

  _createTableCell: (mechanic) ->
    new TableCell mechanic.mechanicName


module.exports = mechanicsPopupTable