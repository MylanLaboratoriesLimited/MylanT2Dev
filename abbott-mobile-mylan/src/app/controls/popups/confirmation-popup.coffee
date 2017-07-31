Spine = require 'spine'
AlertPopup = require 'controls/popups/alert-popup'

class ConfirmationPopup extends AlertPopup
  className: 'popup alert confirm'

  _renderButtons: =>
    @elButtonSection.html require('views/controls/popups/partial-controls/confirm-buttons')();

  _bindEvents: =>
    super
    @elButtonSection.find('.btn.no').bind 'tap', @_btnNoClicked

  _btnNoClicked: =>
    @trigger 'noClicked', @


module.exports = ConfirmationPopup