Spine = require 'spine'
BasePopup = require 'controls/popups/base-popup'

class AlertPopup extends BasePopup
  className: 'popup alert single-button'

  constructor: (options) ->
    super options.caption
    @message = options.message

  _renderContent: =>
    @elContent.text @message if @message
    @elContent.hide() unless @message

  _renderButtons: =>
    @elButtonSection.html require('views/controls/popups/partial-controls/alert-buttons')();

  _bindEvents: =>
    super
    @elButtonSection.find('.btn.yes').bind 'tap', @_btnYesClicked

  _btnYesClicked: =>
    @trigger 'yesClicked', @

module.exports = AlertPopup