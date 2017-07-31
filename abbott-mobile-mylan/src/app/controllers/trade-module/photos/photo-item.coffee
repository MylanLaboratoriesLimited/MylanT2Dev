Spine = require 'spine'
PhotoAttachmentFileManager = require 'common/attachment-managers/photo-attachment-file-manager'
AttachmentLoadManager = require 'common/attachment-managers/attachment-load-manager'
AttachmentLoader = require 'common/attachment-managers/attachment-loader'
ProgressBar = require 'controls/progress-bar/progress-bar'
PhotoAdjustmentsCollection = require 'models/bll/photo-adjustments-collection'

class NullImage
  constructor: ->
    @path = ''
    @thumbnailPath = ''

class PhotoItem extends Spine.Controller
  tag: 'li'
  className: 'photo-item'

  elements:
    '.progress-holder': 'elProgressHolder'
    '.remove-photo-item': 'elRemovePhoto'

  constructor: (localImage, @photoAdjustmentEntity) ->
    super {}
    @image = localImage or new NullImage
    @photoAdjustmentsCollection = new PhotoAdjustmentsCollection

  render: ->
    @html @template()
    @photoAdjustmentsCollection.getAttachmentByPhotoAdjustmentId(@photoAdjustmentEntity.id)
    .then (@attachment) => @refreshPhoto()
    @_bindEvents()
    @

  _bindEvents: ->
    @el.on('tap', @_onItemTap)
    @el.on('hold', @_onItemHold)
    @elRemovePhoto.on('tap', @_onRemoveTap)

  refreshPhoto: =>
    PhotoAttachmentFileManager.fileExist(@image.path)
    .done => @el.css('background-image', "url('#{@image.thumbnailPath}')")
    .fail => @el.css('background-color', 'grey')
    .then => @_checkLoadingState()

  template: ->
    require('views/trade-module/photo-item')()

  _checkLoadingState: =>
    loader = AttachmentLoadManager.getLoaderForAttachment(@attachment)
    switch loader?.status
      when AttachmentLoader.states.DOWNLOAD then @_resumeLoading(loader)
      when AttachmentLoader.states.FINISHED then @_finishLoading()
      when AttachmentLoader.states.ERROR then @_dropLoading()

  _resumeLoading: (loader) =>
    @progressBar or= new ProgressBar
    @elProgressHolder.append @progressBar.el
    @el.addClass 'in-progress'
    loader.onStateChange = @_changeLoadingState
    loader.onSuccess = @_finishLoading
    loader.onFail = @_dropLoading
    @_changeLoadingState loader.status, { current: loader.loadedSize, total: loader.fileSize }

  _finishLoading: (entry) =>
    @progressBar and @progressBar.el.remove()
    @progressBar = null
    @el.removeClass 'in-progress'
    @photoAdjustmentsCollection.saveDownloadedImageWithThumbnail(@attachment, entry.fullPath)
    .then (@image) =>
      @refreshPhoto()
      $.fn.dpToast Locale.value('PhotoAttachmentsPopup.Success')

  _dropLoading: (error) =>
    @image = new NullImage
    @progressBar and @progressBar.el.remove()
    @el.removeClass 'in-progress'
    switch error.code
      when FileTransferError.CONNECTION_ERR then @trigger 'errorOffline', @
      when FileTransferError.FILE_NOT_FOUND_ERR then @trigger 'errorUnauthorized', @
      else $.fn.dpToast Locale.value('PhotoAttachmentsPopup.Error')

  _changeLoadingState: (state, progress) =>
    @progressBar.setValue Math.round(progress.current / progress.total * 100)

  _onItemTap: =>
    unless @attachment then @trigger 'errorAttachment', @
    else if @image.path then @trigger 'itemTap', @
    else @_loadStart()

  _loadStart: =>
    unless AttachmentLoadManager.getLoaderForAttachment(@attachment)
      @progressBar = new ProgressBar
      @elProgressHolder.append @progressBar.el
      @el.addClass('in-progress')
      @attachment.title += '.jpg'
      AttachmentLoadManager.queueInvoke(@attachment, {
        onStateChange: @_changeLoadingState
        onSuccess: @_finishLoading
        onFail: @_dropLoading
      }, PhotoAttachmentFileManager)

  _onRemoveTap: (event) =>
    event.stopPropagation()
    @trigger 'removeTap', @

  _onItemHold: =>
    @trigger 'itemHold', @

module.exports = PhotoItem