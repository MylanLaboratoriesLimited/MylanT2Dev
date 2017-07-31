Utils = require("common/utils")
EntitiesCollection = require 'models/bll/entities-collection'
DeviceManager = require 'common/device-manager'
SyncLogManager = require 'common/log-manager'
Device = require 'models/device'

class DeviceCollection extends EntitiesCollection
  model: Device

  _fillDeviceData: (device) =>
    device.deviceId = DeviceManager.deviceId()
    device.lastSyncronisation = Utils.originalDateTime(new Date)
    device.lastUserSfid = Force.userId
    device.model = DeviceManager.deviceModel()
    device.osVersion = DeviceManager.osVersion()
    device.version = DeviceManager.appVersion()
    device.lastDebugLog = SyncLogManager.log
    device.erased = false
    $.when(device)

  registerDevice: =>
    device = new @model
    @_fillDeviceData(device)
    .then @createEntity

  updateDevice: (device) =>
    @_fillDeviceData(device)
    .then @updateEntity

  getDevice: =>
    deviceId = DeviceManager.deviceId()
    whereQuery = {}
    whereQuery[@model.sfdc.deviceId] = deviceId
    @fetchAllWhere(whereQuery)
    .then (response) =>
      device = if response.records.length then @parseEntity(response.records[0]) else null
      $.when(device)

  updateDeviceInfo: =>
    @getDevice().then (device)=>
      unless device
        @registerDevice()
      else
        @updateDevice(device)

module.exports = DeviceCollection