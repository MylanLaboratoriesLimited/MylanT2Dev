TableController = require 'controls/table/card-table'
PromotionTaskAccount = require 'models/promotion-task-account'
CommonInput = require 'controls/common-input/common-input'
FloatCommonInput = require 'controls/common-input/float-common-input'

class PromotionTasksTableCell extends Spine.Controller
  tag: 'tr'

  elements:
    '.name': 'elName'
    '.value': 'elValue'

  MAX_TEXT_LENGTH: 255
  MAX_NUMBER_LENGTH: 18

  constructor: (@promotionTaskAccount, @taskAdjustment) ->
    super {}

  template: ->
    require('views/trade-module/promotion-details/promotion-tasks/promotion-tasks-table-cell')()

  render: ->
    @html @template()
    @elName.text @promotionTaskAccount.taskName
    @elValue.html @_getControl()
    @_processRecurrency()
    @

  _processRecurrency: =>
    if @promotionTaskAccount.isRecurrent and (@promotionTaskAccount.plannedRecurrency <= @promotionTaskAccount.actualCallReports)
      @el.addClass('disabled')
      @elValue.find('>*').attr 'readonly', 'readonly'

  _getControl: ->
    switch @promotionTaskAccount.taskType
      when PromotionTaskAccount.TASK_TYPE_NUMERIC then @_input 'tel', @taskAdjustment.numberRealValue
      when PromotionTaskAccount.TASK_TYPE_TEXT then @_input 'text', @taskAdjustment.stringRealValue
      when PromotionTaskAccount.TASK_TYPE_PICKLIST then @_select @taskAdjustment.stringRealValue

  _input: (type, value) ->
    input = $('<input/>')
    input.attr { type:type, class:'promotion-input', value:value, 'data-placeholder':'. . .' }
    maxInputLength = if type is 'text' then @MAX_TEXT_LENGTH else @MAX_NUMBER_LENGTH
    controlType = if type is 'tel' then FloatCommonInput else CommonInput
    new controlType($('.trade-scroll-content')[0], input, maxInputLength)
    input.on 'input', @_onValueChange
    input

  _onValueChange: (event) =>
    @trigger 'valueChanged', @taskAdjustment, @promotionTaskAccount, event.target.value

  _select: (value) =>
    button = $('<div class="btn-select"/>')
    button.text value or Locale.value('common:defaultSelectValue')
    button.on 'tap', => @trigger 'selected', button, @promotionTaskAccount, @taskAdjustment
    button

module.exports = PromotionTasksTableCell