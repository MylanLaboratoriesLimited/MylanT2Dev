TableCell = require 'controls/table/table-cell'
AttachmentFileManager = require 'common/attachment-managers/attachment-file-manager'
AttachmentLoadManager = require 'common/attachment-managers/attachment-load-manager'
AttachmentLoader = require 'common/attachment-managers/attachment-loader'
ProgressBar = require 'controls/progress-bar/progress-bar'


class AttachmentsTableCell extends TableCell
  elProgressBarHolder: null
  elLoadedCheck: null

  constructor: (@attachment) ->
    super {}

  render: ->
    filePath = AttachmentFileManager.getFilePath(@attachment.body, @attachment.title)
    AttachmentFileManager.fileExist filePath
    .done =>
      @attachment.loaded = true
      @_renderContent()
    .fail @_renderContent
    @

  addProgress: =>
    @progressBar = new ProgressBar
    @elProgressBarHolder.addClass 'in-progress'
    .append @progressBar.el

  _renderContent: =>
    # 'should be rewritten'

  _checkLoadState: =>
    loader = AttachmentLoadManager.getLoaderForAttachment @attachment
    switch loader?.status
      when AttachmentLoader.states.DOWNLOAD then @_loadResume(loader)
      when AttachmentLoader.states.FINISHED then @onLoadSuccess()
      when AttachmentLoader.states.ERROR then @onLoadFail()
    @elLoadedCheck.addClass('checked') if @attachment.loaded

  _loadResume: (loader)=>
    @progressBar or= new ProgressBar
    @elProgressBarHolder.addClass 'in-progress'
    .append @progressBar.el
    loader.onStateChange = @onLoadStateChange
    loader.onSuccess = @onLoadSuccess
    loader.onFail = @onLoadFail
    @onLoadStateChange loader.status, {current: loader.loadedSize, total: loader.fileSize}

  onLoadStateChange: (state, progress)=>
    @progressBar.setValue Math.round(progress.current / progress.total * 100)

  onLoadSuccess: =>
    @attachment.loaded = true
    @progressBar and @progressBar.el.remove()
    @elProgressBarHolder.removeClass 'in-progress'
    @progressBar = null
    @elLoadedCheck.addClass 'checked'
    $.fn.dpToast "#{Locale.value("AttachmentsPopup.Success")} #{@attachment.title}"

  onLoadFail: (error)=>
    @attachment.loaded = false
    @progressBar and @progressBar.el.remove()
    @elProgressBarHolder.removeClass 'in-progress'
    @elLoadedCheck.removeClass "checked"
    if error.code is FileTransferError.FILE_NOT_FOUND_ERR and error.http_status is 401
      $.fn.dpToast Locale.value 'AttachmentsPopup.Unauthorized'
    else if error.http_status is 404
      $.fn.dpToast Locale.value 'AttachmentsPopup.Deleted'
    else if error.code is FileTransferError.CONNECTION_ERR
      $.fn.dpToast Locale.value 'AttachmentsPopup.LoadFail'
    else
      $.fn.dpToast "#{Locale.value("AttachmentsPopup.Error")} #{@attachment.title}"

  bindEvents: =>
    @el.on 'tap', @_onCellTap

  _onCellTap: =>
    @trigger 'attachmentCellTap', @


module.exports = AttachmentsTableCell