SettingsManager = require 'db/settings-manager'

class PinManager
  @isPinMatch: (pin, callback)->
    @getPin (value) =>
      callback(value isnt '' and value is pin)

  @isPinExists: (callback)->
    @getPin (value) =>
      isExists=(value? and value isnt '')
      callback(isExists)

  @removePin: (callback)->
    @setPin "", callback

  @setPin: (pin, callback)->
    SettingsManager.setValueByKey('pin', pin)
    .then callback

  @getPin: (callback)->
    SettingsManager.getValueByKey('pin')
    .then callback

  @setPinAttempts: (attempts, callback)->
    SettingsManager.setValueByKey('attempts', attempts)
    .then callback

  @getPinAttempts: (callback)->
    SettingsManager.getValueByKey('attempts')
    .then callback

module.exports = PinManager