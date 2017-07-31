Spine = require 'spine'
TacticsTableCellItem = require 'controllers/trade-module/promotion-details/tactics/tactics-table-cell-item'
CommonInput = require 'controls/common-input/common-input'

class TacticsTableCell extends Spine.Controller
  tag: 'div'

  className: 'tactics-table-cell row'

  elements:
    '.tactic': 'elTactic'

  constructor: (@promoSku, @evaluationsWithAdjustments) ->
    super {}

  render: ->
    docFragment = $ document.createDocumentFragment()
    docFragment.append @_initProductName @promoSku.productItemName
    docFragment.append @_initTactics @evaluationsWithAdjustments
    @html docFragment
    @

  _productNameTemplate: ->
    require('views/trade-module/promotion-details/tactics/tactics-table-cell-product')()

  _initProductName: (name) ->
    docFragment = $ document.createDocumentFragment()
    template = $ @_productNameTemplate()
    template.find('span').text name
    docFragment.append template

  _initTactics: (evaluationsWithAdjustments) ->
    docFragment = $ document.createDocumentFragment()
    evaluationsWithAdjustments.forEach (evalWithAdj, index) =>
      cell = new TacticsTableCellItem evalWithAdj
      cell.on 'selected', (sender, evalWithAdj) => @trigger 'selected', sender, evalWithAdj
      cell.on 'valueChanged', (evalWithAdj, value) => @trigger 'valueChanged', evalWithAdj, value
      docFragment.append cell.render().el
    docFragment

module.exports = TacticsTableCell