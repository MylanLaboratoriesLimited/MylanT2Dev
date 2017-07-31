BasePopup = require '/controls/popups/base-popup'
StringFormator = require 'common/string-formator'

class PromotionNotePopup extends BasePopup

  className: "promotion-note-popup popup"

  constructor: (@note) ->
    super

  _headTemplate: ->
    require('views/controls/popups/promotion-note-popup/promotion-note-popup-header')()

  _contentTemplate: ->
    require('views/controls/popups/promotion-note-popup/promotion-note-popup-content')()

  _renderHead: =>
    @elHeader.html @_headTemplate()
    @elCloseBtn = @elHeader.find '.cross'
    @elNoteTitle = @elHeader.find '.note-title'
    @elNoteTitle.text @note?.title ? ""

  _renderContent: =>
    @elContent.html @_contentTemplate()
    @elScrollContent = @elContent.find '.scroll-content'
    @elScrollContent[0].innerText = @note?.body or ''

  _bindEvents: =>
    super
    @elCloseBtn.bind 'tap', @hide

module.exports = PromotionNotePopup