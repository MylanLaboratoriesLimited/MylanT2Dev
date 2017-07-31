CommonInput = require 'controls/common-input/common-input'

class FloatCommonInput extends CommonInput
  # todo CommonInput like control
  # separate logics of textarea and input(ask RomaN.)

  constructor: (wrapper, element, maxLength) ->
    super wrapper, element, maxLength
    @_validate()

  _validate: (value)=>
    @element.on 'input', (event)=>
      newValue = event.target.value
      if newValue is '' or /^\d+(?:\.\d*)?$/ig.test(newValue)
        value = newValue
      else
        value = '' unless value
      event.target.value = value
    @element.on 'blur', ->
      @value = @value.replace /(\d+)\.$/ig, '$1'

module.exports = FloatCommonInput