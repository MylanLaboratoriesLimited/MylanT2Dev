SkusTableCellValue = require 'controllers/trade-module/promotion-details/skus/skus-table-cell-value'

class SkusTableCell extends Spine.Controller
  tag: 'div'

  className: 'skus-table-cell row'

  constructor: (@sku, @tasks, @taskAdjustments) ->
    super {}

  render: ->
    docFragment = $ document.createDocumentFragment()
    docFragment.append @_initProductName()
    docFragment.append @_initValues()
    @html docFragment
    @

  _productNameTemplate: ->
    require('views/trade-module/promotion-details/skus/skus-table-cell')()

  _initProductName: ->
    docFragment = $ document.createDocumentFragment()
    template = $ @_productNameTemplate()
    template.find('p').text @sku.productItemName
    docFragment.append template

  _initValues: ->
    docFragment = $ document.createDocumentFragment()
    @tasks.forEach (task, index) =>
      skusTableCellValue = new SkusTableCellValue task, @taskAdjustments[index]
      skusTableCellValue.on 'selected', (sender, promotionTask, taskAdjustment) =>
        @trigger 'selected', sender, promotionTask, taskAdjustment
      skusTableCellValue.on 'valueChanged', (taskAdjustment, value, promotionTask) =>
        @trigger 'valueChanged', taskAdjustment, value, promotionTask
      docFragment.append skusTableCellValue.el
    docFragment

module.exports = SkusTableCell