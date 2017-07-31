Spine = require 'spine'
ListPopup = require 'controls/popups/list-popup'
Utils = require 'common/utils'

class ListPopupWithBackBtn extends ListPopup

  _renderHead: =>
    if Utils.isIOS()
      @elHeader.html require("views/controls/popups/header-with-back-button")
    else
      @elHeader.hide()

  _bindEvents: =>
    document.addEventListener 'backbutton', @_onBackButton
    super
    @elHeader.find('.back').bind 'tap', @_onBackButton

  _onBackButton: =>
    @trigger 'backbutton', @
    @hide()

  hide: =>
    document.removeEventListener 'backbutton', @_onBackButton
    super

module.exports = ListPopupWithBackBtn