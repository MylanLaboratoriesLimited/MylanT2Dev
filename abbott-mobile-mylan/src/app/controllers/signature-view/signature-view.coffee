FullscreenPanel = require 'controllers/base/panel/fullscreen-panel'
ActivityIndicator = require 'common/activity-indicator'
HeaderBaseControl = require 'controls/header-controls/header-base-control'
Header = require 'controls/header/header'

class SignatureView extends FullscreenPanel
  className: 'signature-view full-screen'

  elements:
    '.signature': 'elSignature'

  active: ->
    super
    @render()

  render: ->
    @_initHeader()
    @html @template @content.width(), @content.height()
    Locale.localize @el
    @drawController = new DrawController(@elSignature[0], '', null)
    @elSignature.bind touchy.events.start, @enableSaveBtn

  _initHeader: ->
    @saveBtn = new HeaderBaseControl Locale.value('common:buttons.SaveBtn'), 'ctrl-btn'
    @saveBtn.bind 'tap', @_onSaveTap
    clearBtn = new HeaderBaseControl Locale.value('common:buttons.ClearBtn'), 'ctrl-btn'
    clearBtn.bind 'tap', @_onClearTap
    signatureHeader = new Header Locale.value('signature.HeaderTitle')
    signatureHeader.render()
    signatureHeader.addRightControlElement clearBtn.el
    signatureHeader.addRightControlElement @saveBtn.el
    @setHeader signatureHeader
    @disableSaveBtn()

  enableSaveBtn: =>
    @saveBtn.el.removeClass 'disabled'

  disableSaveBtn: =>
    @saveBtn.el.addClass 'disabled'

  template: (width, height) ->
    require('views/signature-view/signature-view')(width: width, height: height)

  _resizeSignature: (signatureBase64) =>
    deferred = new $.Deferred
    scaledWidth = 400
    scaledHeight = 200
    canvas = document.createElement 'canvas'
    canvas.width = scaledWidth
    canvas.height = scaledHeight
    context = canvas.getContext '2d'
    image = new Image
    image.onload = =>
      context.fillStyle = 'white'
      context.fillRect 0, 0, scaledWidth, scaledHeight
      context.drawImage image, 0, 0, @content.width(), @content.height(), 0, 0, scaledWidth, scaledHeight
      encoder = new JPEGEncoder();
      imageData = encoder.encode context.getImageData(0, 0, canvas.width, canvas.height), 1
      imageData = imageData.replace 'data:image/jpeg;base64,', ''
      deferred.resolve imageData
    image.src = signatureBase64
    deferred.promise()

  _onSaveTap: =>
    originSignature = @drawController.save()
    spinner = new ActivityIndicator @el[0]
    spinner.show()
    @_resizeSignature(originSignature)
    .then (signatureImgBase64) =>
      spinner.hide()
      @trigger 'saveTap', signatureImgBase64
      @onBack()

  _onClearTap: =>
    @disableSaveBtn()
    @drawController.clear()

module.exports = SignatureView