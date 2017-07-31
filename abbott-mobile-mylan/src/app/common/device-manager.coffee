Spine = require 'spine'

class DeviceManager
  @device = window.device

  window.plugins.appVersion (versionInfo)=>
    @_appVersion = versionInfo.appVersion

  @deviceModel: ->
    return @device.model if @device
    'Mobile device'

  @osVersion: ->
    return "#{@device.platform} #{@device.version}" if @device
    '1.0'

  @appVersion: ->
    return @_appVersion if @_appVersion
    '1.0'

  @deviceId: ->
    return @device.uuid if @device
    '40:F3:08:62:D4:2D'

module.exports = DeviceManager