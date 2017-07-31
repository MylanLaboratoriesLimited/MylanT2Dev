Spine = require 'spine'
BasePopup = require 'controls/popups/base-popup'

class PhotoPreview extends BasePopup
  className: 'popup preview'

  events:
    'tap': '_onPhotoTap'

  constructor: (@imageUrl) ->
    super
    @render()

  _renderContent: ->
    img = document.createElement('img')
    img.src = @imageUrl
    @html img

  _onPhotoTap: =>
    @trigger "onPhotoPreviewTap"

module.exports = PhotoPreview