Spine = require 'spine'
CommonInput = require 'controls/common-input/common-input'
FloatCommonInput = require 'controls/common-input/float-common-input'
PromotionMechanic = require 'models/promotion-mechanic'
SimplePopup = require 'controls/popups/simple-popup'

class TacticsTableCellItem extends Spine.Controller
  tag: 'div'

  className: 'tactic col'

  elements:
    '.border-value': 'elBorderValueHolder'
    '.main-data': 'elAdjustmentHolder'
    '.border-value p': 'elBorderValue'
    '.main-data p': 'elAdjustmentValue'

  MAX_TEXT_LENGTH: 254
  MAX_NUMBER_LENGTH: 18

  constructor: (@evaluationWithAdjustment) ->
    super {}
    @selectButton = null

  render: ->
    @html @template()
    @elBorderValue.text @evaluationWithAdjustment.evaluation.realValue()
    @elAdjustmentValue.html @_getControl()
    @_processRecurrency()
    @_bindEvents()
    @_displayColorStatusWithValue(@_adjustmentValue())
    @

  template: ->
    require('views/trade-module/promotion-details/tactics/tactics-table-cell-tactic')()

  _displayColorStatusWithValue: (adjustmentValue) =>
    evaluationValue = @evaluationWithAdjustment.evaluation.realValue()
    if !adjustmentValue or adjustmentValue is Locale.value('common:defaultSelectValue')
      @_displayColorStatusDefault()
    else if evaluationValue?.toString().trim().toLowerCase() is adjustmentValue.toString().trim().toLowerCase()
      @_displayColorStatusMatch()
    else @_displayColorStatusNotMatch()

  _displayColorStatusDefault: =>
    transparent = 'rgba(255, 255, 255, 0.0)'
    @elBorderValueHolder.css 'background-color', transparent
    @elAdjustmentHolder.css 'background-color', transparent

  _displayColorStatusMatch: =>
    lightGreen = 'rgba(204, 255, 204, 0.3)'
    @elBorderValueHolder.css 'background-color', lightGreen
    @elAdjustmentHolder.css 'background-color', lightGreen

  _displayColorStatusNotMatch: =>
    lightRed = 'rgba(255, 204, 204, 0.3)'
    @elBorderValueHolder.css 'background-color', lightRed
    @elAdjustmentHolder.css 'background-color', lightRed

  _processRecurrency: =>
    evaluation = @evaluationWithAdjustment.evaluation
    if evaluation.isDisabled()
      @el.addClass('disabled')
      @elAdjustmentValue.find('>*').attr 'readonly', 'readonly'

  _bindEvents: ->
    @elBorderValueHolder.on 'tap', @_onBorderValueTap

  _onBorderValueTap: (event) =>
    text = $(event.currentTarget).find('p').text()
    new SimplePopup(text).show() if text and text.length > 5

  _getControl: ->
    adjustmentValue = @_adjustmentValue()
    switch @evaluationWithAdjustment.evaluation.mechanicType
      when PromotionMechanic.MECHANIC_TYPE_NUMERIC then @_input 'tel', adjustmentValue
      when PromotionMechanic.MECHANIC_TYPE_TEXT then @_input 'text', adjustmentValue
      when PromotionMechanic.MECHANIC_TYPE_PICKLIST then @_select adjustmentValue
      else adjustmentValue

  _adjustmentValue: ->
    adjustment = @evaluationWithAdjustment.adjustment
    switch @evaluationWithAdjustment.evaluation.mechanicType
      when PromotionMechanic.MECHANIC_TYPE_NUMERIC then adjustment.numberRealValue
      when PromotionMechanic.MECHANIC_TYPE_TEXT then adjustment.stringRealValue
      when PromotionMechanic.MECHANIC_TYPE_PICKLIST then adjustment.stringRealValue
      else adjustment.realValue

  _input: (type, value) ->
    input = $('<input/>')
    input.attr { type:type, class:'promotion-input', value:value, 'data-placeholder':'. . .' }
    maxInputLength = if type is 'text' then @MAX_TEXT_LENGTH else @MAX_NUMBER_LENGTH
    inputControl = if type is 'tel' then FloatCommonInput else CommonInput
    new inputControl($('.trade-scroll-content')[0], input, maxInputLength)
    input.on 'input', @_onValueChange
    input

  _onValueChange: (event) =>
    value = event.target.value
    parsedValue = parseFloat(event.target.value)
    if @evaluationWithAdjustment.evaluation.mechanicType is PromotionMechanic.MECHANIC_TYPE_NUMERIC and parsedValue
      value = parsedValue.toString()
    @_displayColorStatusWithValue value
    @trigger 'valueChanged', @evaluationWithAdjustment, event.target.value

  _select: (value) =>
    @selectButton = $('<div class="btn-select"/>')
    @selectButton.text value or Locale.value('common:defaultSelectValue')
    @selectButton.on 'tap', => @trigger 'selected', @, @evaluationWithAdjustment
    @selectButton

  didSelectValue: (value) =>
    @selectButton.text value
    @_displayColorStatusWithValue value

module.exports = TacticsTableCellItem