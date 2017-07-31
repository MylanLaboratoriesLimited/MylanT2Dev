Spine = require 'spine'
PinManager = require 'common/pin-manager'
AlertPopup = require 'controls/popups/alert-popup'
LockManager = require 'common/lock-manager'
Utils = require 'common/utils'
AndroidViewResizer = require 'common/android-view-resizer'

class ProvidePin extends Spine.Controller
  className: 'pin-page provide-pin stack-page active'
  passwordLength: 4

  elements:
    '.new-pin': 'elNewPin'
    '.confirm-pin': 'elConfirmPin'

  events:
    'tap .confirm': '_onConfirmTab'
    'keyup .pin': '_checkPin'
    'input .pin': '_checkPin'

  active: ->
    super
    @caption = Locale.value('pin.AlertCaption')
    @render()
    @elNewPin.val ''
    @elConfirmPin.val ''

  render: ->
    @html require('views/pin/provide-pin')()
    Locale.localize @el
    new AndroidViewResizer @el[0], @elNewPin[0] unless Utils.isIOS()
    new AndroidViewResizer @el[0], @elConfirmPin[0] unless Utils.isIOS()
    @

  _checkPin: (event)->
    input = event.target
    input.value = @_validatePin input.value
    @_checkData event
    @_onConfirmTab() if event and event.keyCode is 13

  _validatePin: (value)->
    value.replace /\D/g, ''

  _onConfirmTab: =>
    @elNewPin.blur()
    @elConfirmPin.blur()

    if @elNewPin.val().length < @passwordLength
      alertPopup = new AlertPopup caption: @caption, message: @_pinLengthError()
      alertPopup.customStyleClass 'pin-alert'
      alertPopup.show()
      alertPopup.bind "yesClicked", =>
        alertPopup.hide()
    else if @elNewPin.val() is @elConfirmPin.val()
      PinManager.setPin @elNewPin.val()
      LockManager.unlock()
    else
      alertPopup = new AlertPopup caption: @caption, message: @_pinConfirmError()
      alertPopup.customStyleClass 'pin-alert'
      alertPopup.show()
      alertPopup.bind "yesClicked", =>
        alertPopup.hide()

  _pinLengthError: -> Locale.value('pin.ErrorMessage.PinLength', {count: @passwordLength})

  _pinConfirmError: -> Locale.value('pin.ErrorMessage.PinsAreNotEqual')

  _checkData: (event)->
    input = event.target
    parent = input.parentElement
    if input.value then parent.classList.remove('placeholder') else parent.classList.add('placeholder')

module.exports = ProvidePin