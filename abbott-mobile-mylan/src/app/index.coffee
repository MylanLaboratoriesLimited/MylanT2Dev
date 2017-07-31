require('lib/setup')

Spine = require 'spine'
Touchy = require 'common/touchy'
GhostClickPreventer = require 'common/ghost-click-preventer'
Main = require 'controllers/main'
Pin = require 'controllers/pin/pin'
ProvidePin = require 'controllers/pin/provide-pin'
Utils = require 'common/utils'
PinManager = require 'common/pin-manager'
LockManager = require 'common/lock-manager'

class App extends Spine.Stack
  controllers:
    main: Main
    pin: Pin
    providePin: ProvidePin

  routes:
    '/main': 'main'
    '/pin': 'pin'
    '/provide-pin': 'providePin'

  default: 'main'

  constructor: ->
    super
    window.touchy = new Touchy()
    window.ghostClickPreventer = new GhostClickPreventer() unless Utils.isIOS()
    Spine.Route.setup()
    @_setDeviceType()
    @_setDeviceSize()
    LockManager.init @
    @_showActualScreen()

  _showActualScreen: ->
    @navigate '/home'
    PinManager.isPinExists (isExists) =>
      if isExists
        LockManager.isLocked (isLocked)=>
          if isLocked
            LockManager.lock()
          else
            LockManager.start()
            @main.active()
      else
        @providePin.active()

  _setDeviceType: ->
    typeOS = if Utils.isIOS() then 'ios' else 'android'
    $(document.body).addClass(typeOS)

  _setDeviceSize: ->
    $(document.body).width($(window).width())
    $(document.body).height($(window).height())

module.exports = App