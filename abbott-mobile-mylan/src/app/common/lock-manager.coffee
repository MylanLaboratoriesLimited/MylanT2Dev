SettingsManager = require 'db/settings-manager'

class LockManager

  @init: (@context) ->
    @isActive = false
    @document = $ document
    @lockTime = 1000 * 1000

  @initialize: ->
    @_events 'bind'
    @_startTimer()

  @_clearTimer: ->
    clearTimeout @timer

  @destroy: ->
    @_clearTimer()
    @_events 'unbind'
    @timer = null

  @_events: (action)->
    @document[action] 'touchend', @_startTimer

  @start: ->
    @isActive = true
    @initialize()

  @stop: ->
    @isActive = false
    @destroy()

  @_startTimer: =>
    @_clearTimer()
    @timeStamp = new Date

    @timer = @_executeAsync =>
      @lock()
    , @lockTime

  @_executeAsync: (callback, timeout = 10) =>
    setTimeout(callback, timeout) if callback?

  @lock: =>
    @stop()
    @_setIsLocked true, =>
      @context.pin.active()

  @unlock: =>
    @start()
    @_setIsLocked false, =>
      @context.main.active()

  @_setIsLocked:(value, callback) ->
    SettingsManager.setValueByKey('IsLocked', value)
    .then callback

  @_getIsLocked:(callback) ->
    SettingsManager.getValueByKey('IsLocked')
    .then callback

  @isLocked:(callback) ->
    @_getIsLocked callback

module.exports = LockManager