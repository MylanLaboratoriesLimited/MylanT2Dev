Spine = require 'spine'
ModalControllerModule = require 'controls/popups/modal-controller-module'

class BasePopup extends Spine.Controller
  @include ModalControllerModule

  className: 'popup'

  elements:
    '.popup-container': 'elPopup'
    '.popup-wrapper': 'elOverflow'
    'header': 'elHeader'
    '.content-container': 'elContent'
    '.buttons-section': 'elButtonSection'

  constructor: (@caption)->
    super

  show: =>
    $(document.body).addClass 'showing-popup'
    app.mainController.append @
    @render()
    @_bindEvents()
    @didShow @

  hide: =>
    document.removeEventListener 'backbutton', @hide, false
    @willHide @
    @el.remove()
    setTimeout =>
      $(document.body).removeClass 'showing-popup'
      @didHide @
      @release()
    , 400

  template: ->
    require('views/controls/popups/base-popup')()

  render: =>
    @html @template()
    @_renderHead()
    @_renderContent()
    @_renderButtons()
    Locale.localize @el

  _renderHead: =>
    @elHeader.text @caption if @caption
    @elHeader.hide() unless @caption

  _renderContent: =>

  _renderButtons: =>
    @elButtonSection.hide()

  _bindEvents: =>
    document.addEventListener 'backbutton', @hide, false
    @elPopup.bind 'tap', (event) -> event.stopPropagation()
    @elOverflow.bind 'touchmove', @_preventDefault
    @elOverflow.bind 'tap', => @hide()
    @scrollElements = @el.find '.scroll-container *'
    @elScrollContent = @el.find '.scroll-content'
    @elScrollContainer = @el.find '.scroll-container'

  _preventDefault: (event) =>
    if jQuery.inArray(event.target, @scrollElements) is -1 or
       @elScrollContent.height() is @elScrollContainer.height()
      event.preventDefault()

  customStyleClass: (className) =>
    @el.addClass className

module.exports = BasePopup
