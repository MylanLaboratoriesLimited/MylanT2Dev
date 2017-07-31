Stage = require 'controllers/base/stage/stage'
Panel = require 'controllers/base/panel/panel'
NotificationsModule = require 'common/notifications-module'
Utils = require 'common/utils'

class PanelScreen extends Panel
  @include NotificationsModule

  modalController: null

  constructor: ->
    super
    @subscribeOnBackButton()
    @headerControl = null

  activate: (params = {}) =>
    super params
    @executeDeferredNotificationCallbacks()

  shouldDeferNotification: (notification) =>
    not Stage.globalStage().isActive() or not @stage.isActive() or not @isActive()

  subscribeOnBackButton: =>
    document.addEventListener 'backbutton', @onBackButton, false

  unsubscribeFromBackButton: =>
    document.removeEventListener 'backbutton', @onBackButton, false

  presentModalController: (controller) =>
    unless @modalController
      @modalController = controller
      @modalController.bind 'didShow', @unsubscribeFromBackButton
      @modalController.bind 'willHide', =>
        @modalController = null
        @subscribeOnBackButton()
      @modalController.show()

  dismissModalController: =>
    @modalController?.hide()

  onBackButton: =>
    @onBack() if @stage.isActive() and @isActive()

  onBack: =>
    @unsubscribeFromBackButton()
    @stage.pop()

  setHeader: (newHeader) ->
    newHeader.on 'backbutton', @onBackButton
    @header.replaceWith newHeader.el
    @header = newHeader.el
    @headerControl = newHeader

module.exports = PanelScreen