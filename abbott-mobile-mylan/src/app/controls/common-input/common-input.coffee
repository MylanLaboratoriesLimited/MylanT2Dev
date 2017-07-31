Utils = require 'common/utils'
AndroidViewResizer = require 'common/android-view-resizer'

class CommonInput
  # todo CommonInput like control
  # separate logics of textarea and input(ask RomaN.)

  constructor: (wrapper, element, maxLength=32000, blurEvent = 'tap') ->
    @element = jQuery element
    @element.elastic()
    @element.on 'focus', @onFocus
    @element.on 'blur', @onBlur
    @element.attr 'maxlength', maxLength
    @placeholder = @element.attr 'data-placeholder'
    @onBlur()
    @androidViewResizer = new AndroidViewResizer wrapper, element unless Utils.isIOS()
    jQuery(wrapper).bind blurEvent, =>
      @element.blur() if @element.is(":focus")
    @element[0].getValue = @_getValue
    @element[0].setValue = @setValue

  _getValue: ->
    if @classList.contains 'placeholder-mode' then '' else @value

  setValue: (value) ->
    if value?.length
      @element.val value
      @element.removeClass 'placeholder-mode'

  onFocus: =>
    if @element.hasClass 'placeholder-mode'
      @element.val ''
      @element.removeClass 'placeholder-mode'

  onBlur: =>
    if @element.val().length is 0
      @element.val @placeholder
      @element.addClass 'placeholder-mode'

module.exports = CommonInput