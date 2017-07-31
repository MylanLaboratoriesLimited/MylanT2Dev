Spine = require 'spine'
BasePopup = require 'controls/popups/base-popup'

class PendingPopup extends BasePopup
  className: 'popup pending'

  _renderContent: =>
    @elContent.html require('views/controls/popups/pending-popup')()

  _bindEvents: =>
    @elOverflow.bind 'touchmove', @_preventDefault

module.exports = PendingPopup