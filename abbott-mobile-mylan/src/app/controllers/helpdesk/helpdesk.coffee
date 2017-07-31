Spine = require 'spine'
DeviceManager = require 'common/device-manager'
DatabaseManager = require 'db/database-manager'
ConfirmationPopup = require 'controls/popups/confirmation-popup'
AlertPopup = require 'controls/popups/alert-popup'
PendingPopup = require 'controls/popups/pending-popup'
LogManager = require 'common/log-manager'
Header = require 'controls/header/header'
ViewLog = require 'controllers/helpdesk/view-log'
PresentationFileManager = require 'common/presentation-managers/presentations-file-manager'

class Helpdesk extends Spine.Controller
  className: 'helpdesk stack-page flex-box'

  elements:
    '.data-container': 'dataContainer'
    '.helpdesk-container': 'helpdeskContainer'

  events:
    'tap .call': '_makeCall'
    'tap .clear-data': '_dropDatabase'
    'tap .action.view-log': '_viewLog'
    'tap .send-log': '_sendLog'

  template: ->
    require('views/helpdesk/helpdesk')()

  active: ->
    super
    document.addEventListener('backbutton', @_onBackButton, false)
    @render()

  deactivate: ->
    super
    document.removeEventListener('backbutton', @_onBackButton, false)

  render: ->
    @phoneNumber = Locale.value('helpdesk.PhoneNumber')
    @_renderHeader()
    @append @template()
    @_renderDeviceInfo()
    @_initViewLog()
    Locale.localize @el
    @

  _renderHeader: ->
    @header = new Header Locale.value('helpdesk.HeaderTitle')
    @header.on 'backbutton', @_onBackButton
    @html @header
    @header.render()

  _onBackButton: =>
    @navigate '/home'

  _getDeviceData: ->
    {
      id: DeviceManager.deviceId()
      appVersion: DeviceManager.appVersion()
      osVersion: DeviceManager.osVersion()
      model: DeviceManager.deviceModel()
    }

  _renderInformationPanel: ->
    deviceInfo = @_getDeviceData()
    informationTemplate = require('views/helpdesk/information-panel')(device: deviceInfo)
    @append informationTemplate
    @

  _renderDeviceInfo: ->
    deviceInfo = @_getDeviceData()
    deviceInfoTemplate = require('views/helpdesk/device-info')(device: deviceInfo)
    @dataContainer.append deviceInfoTemplate

  _initViewLog: ->
    @viewLog = new ViewLog()
    @dataContainer.append @viewLog.el

  _makeCall: =>
    if window.device
      if window.device.platform.toLowerCase() is 'android'
        document.location.href = "tel:#{@phoneNumber}"
      else
        window.plugins.phoneDialer.dial @phoneNumber, (resultCode) ->
          alertPopup = new AlertPopup(caption: Locale.value("helpdesk.NotSupportedPopup.Caption"), message: Locale.value("helpdesk.NotSupportedPopup.Message"))
          alertPopup.bind 'yesClicked', alertPopup.hide
          alertPopup.show()
    else
      console.log "Make call to: #{@phoneNumber}"

  _dropDatabase: =>
    dropConfirm = new ConfirmationPopup {caption: Locale.value('helpdesk.ConfirmationPopup.Caption'), message: Locale.value('helpdesk.ConfirmationPopup.Question')}
    dropConfirm.bind 'noClicked', (popup) =>
      popup.hide()
    dropConfirm.bind 'yesClicked', (popup) =>
      popup.hide()
      @_onDropDatabase()
    dropConfirm.show()

  _onDropDatabase: ->
    pendingPopup = new PendingPopup Locale.value('helpdesk.ClearingDatabaseMessage')
    pendingPopup.show()
    setTimeout =>
      dbManager = new DatabaseManager
      dbManager.clearDatabase()
      .then =>
        pendingPopup.hide()
        Spine.trigger 'databaseCleared'
    , 400

  _viewLog: =>
    @helpdeskContainer.toggleClass 'view-log-active'

  _sendLog: =>
    LogManager.sendLogToSf()

module.exports = Helpdesk