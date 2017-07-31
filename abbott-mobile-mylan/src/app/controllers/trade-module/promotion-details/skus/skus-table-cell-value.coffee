Spine = require 'spine'
CommonInput = require 'controls/common-input/common-input'
FloatCommonInput = require 'controls/common-input/float-common-input'
PromotionTaskAccount = require 'models/promotion-task-account'

class SkusTableCellValue extends Spine.Controller
  tag: 'div'

  className: 'skus col'

  elements:
    '.main-data span': 'elAdjustmentValue'

  MAX_TEXT_LENGTH: 255
  MAX_NUMBER_LENGTH: 18

  constructor: (@task, @taskAdjustment) ->
    super {}
    @render()

  template: ->
    require('views/trade-module/promotion-details/skus/skus-table-cell-value')()

  render: ->
    @html @template()
    @elAdjustmentValue.html @_getControl()
    @
    
  _getControl: ->
    switch @task.taskType
      when PromotionTaskAccount.TASK_TYPE_NUMERIC then @_input 'tel'
      when PromotionTaskAccount.TASK_TYPE_TEXT then @_input 'text'
      when PromotionTaskAccount.TASK_TYPE_PICKLIST then @_select()

  _getTaskAdjustmentValue: ->
    switch @task.taskType
      when PromotionTaskAccount.TASK_TYPE_NUMERIC then @taskAdjustment.numberRealValue
      when PromotionTaskAccount.TASK_TYPE_TEXT, PromotionTaskAccount.TASK_TYPE_PICKLIST then @taskAdjustment.stringRealValue
      else @taskAdjustment.realValue

  _input: (type) ->
    input = $('<input/>')
    input.attr { type:type, class:'promotion-input', value:@_getTaskAdjustmentValue(), 'data-placeholder':'. . .' }
    maxInputLength = if type is 'text' then @MAX_TEXT_LENGTH else @MAX_NUMBER_LENGTH
    controlType = if type is 'tel' then FloatCommonInput else CommonInput
    new controlType($('.trade-scroll-content')[0], input, maxInputLength)
    input.on 'input', @_onValueChange
    input

  _onValueChange: (event) =>
    @trigger 'valueChanged', @taskAdjustment, @task, event.target.value

  _select: ->
    button = $('<div class="btn-select"/>')
    button.text @_getTaskAdjustmentValue() or Locale.value('common:defaultSelectValue')
    button.on 'tap', => @trigger 'selected', button, @task, @taskAdjustment
    button

module.exports = SkusTableCellValue
