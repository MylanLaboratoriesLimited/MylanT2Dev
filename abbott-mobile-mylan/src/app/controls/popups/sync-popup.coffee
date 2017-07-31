Spine = require 'spine'
BasePopup = require 'controls/popups/base-popup'
ProgressBar = require 'controls/progress-bar/progress-bar'

class SyncPopup extends BasePopup
  className: 'popup sync'

  constructor: ->
    super Locale.value('synchronizationPopup.Title')
    @progressBar = new ProgressBar

  _renderContent: =>
    @elContent.html @progressBar.el

  _bindEvents: =>
    @elOverflow.bind 'touchmove', @_preventDefault

  updateMessage: (message, percentage = 0) ->
    @progressBar.setValue percentage
    @elHeader.html "#{Locale.value('synchronizationPopup.Title')} #{message}"

module.exports = SyncPopup