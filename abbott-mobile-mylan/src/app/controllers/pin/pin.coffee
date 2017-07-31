Spine = require 'spine'
AlertPopup = require 'controls/popups/alert-popup'
PinManager = require 'common/pin-manager'
LockManager = require 'common/lock-manager'
Utils = require 'common/utils'
AndroidViewResizer = require 'common/android-view-resizer'

class Pin extends Spine.Controller
  className: 'pin-page stack-page'
  allAttempts: 3
  elements:
    '.pin': 'elPin'

  constructor: ->
    super    
    PinManager.getPinAttempts (@remainingAttempts) =>
      @_resetPinAttempts() unless @remainingAttempts

  active: ->
    super
    @caption = Locale.value('pin.AlertCaption')
    @render()
    PinManager.getPinAttempts (@remainingAttempts)=>
      console.log "pin attempts ", @remainingAttempts
      @elPin.focus()
      @elPin.blur()
      @_cleanInput @elPin

  events:
    'tap .confirm': '_onConfirmTab'
    'input .pin': '_checkPin'
    'keyup .pin': '_checkPin'

  _checkPin: (event)=>
    input = event.target
    input.value = @_validatePin input.value
    @_checkData event
    @_onConfirmTab() if event and event.keyCode is 13

  _validatePin: (value)->
    value.replace /\D/g, ''

  _cleanInput: (el)->
    el.val ''
    el.parent().addClass 'placeholder'

  render: ->
    @html require('views/pin/pin')()
    Locale.localize @el
    new AndroidViewResizer @el[0], @elPin[0] unless Utils.isIOS()
    @

  _onConfirmTab: =>
    @elPin.blur()
    PinManager.isPinMatch @elPin.val(), (isMatch) =>
      @_cleanInput @elPin
      if isMatch
        @_resetPinAttempts()
        LockManager.unlock()
      else
        @remainingAttempts--
        PinManager.setPinAttempts @remainingAttempts
        if @remainingAttempts
          alertPopup = new AlertPopup caption: @caption, message: @_pinMismatchError()
          alertPopup.customStyleClass 'pin-alert'
          alertPopup.show()
          alertPopup.bind "yesClicked", =>
            alertPopup.hide()
        else
          alertPopup = new AlertPopup caption: @caption, message: @_msgPinWillBeReset()
          alertPopup.customStyleClass 'pin-alert'
          alertPopup.show()
          alertPopup.bind "yesClicked", =>
            alertPopup.hide()
            PinManager.removePin () =>
              @_logout()

  _resetPinAttempts: ->
    PinManager.setPinAttempts @allAttempts

  _logout: ->
    sfOAuthPlugin = cordova.require("salesforce/plugin/oauth")
    sfOAuthPlugin.logout();

  _pinMismatchError: -> Locale.value('pin.ErrorMessage.IncorrectPin', {count: @remainingAttempts})

  _msgPinWillBeReset: -> Locale.value('pin.ErrorMessage.PinWillBeReset')

  _checkData: (event)->
    input = event.target
    parent = input.parentElement
    if input.value then parent.classList.remove 'placeholder' else parent.classList.add 'placeholder'

module.exports = Pin