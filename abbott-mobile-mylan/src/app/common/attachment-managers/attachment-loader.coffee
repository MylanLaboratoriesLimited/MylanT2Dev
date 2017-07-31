SforceDataContext = require 'models/bll/sforce-data-context'
AttachmentFileManager = require 'common/attachment-managers/attachment-file-manager'
Utils = require 'common/utils'

class AttachmentLoader
  @states:
    ERROR: -1
    INITED: 0
    DOWNLOAD: 1
    FINISHED: 2

  constructor: (@attachment, @fileManager = AttachmentFileManager) ->
    @status = AttachmentLoader.states.INITED
    @fileSize = @attachment.bodyLength or 0
    @loadedSize = 0
    @sourceUrl = @attachment.body
    @destPath = @fileManager.getFilePath(@attachment.body, @attachment.title, false)
    @locationPath = @fileManager.getFilePath(@attachment.body, @attachment.title)

  _getRequestHeaders: (credentials) =>
    {
      headers: {
        "Authorization": "OAuth #{credentials.accessToken}"
      }
    }

  _progressChanged: (progress) =>
    @fileSize = progress.total if progress.total > 0
    @loadedSize = progress.loaded
    @onStateChange? @status, {current: @loadedSize, total: @fileSize}

  _errorHandler: (error) =>
    @status = AttachmentLoader.states.ERROR
    @fileManager.removeFile(@destPath)
    error = {code: FileTransferError.CONNECTION_ERR} unless Utils.deviceIsOnline()
    @onFailLoad? error

  _successHandler: (entry) =>
    @fileManager.moveToPersistent(entry.fullPath)
    .then (entry) =>
      @status = AttachmentLoader.states.FINISHED
      @loadedSize = @fileSize
      @onStateChange? @status, {current: @loadedSize, total: @fileSize}
      @onSuccessLoad? entry
    .fail @_errorHandler

  download: =>
    @fileTransfer = new FileTransfer()
    SforceDataContext.getAuthCredentials()
    .then (credentials) =>

      headers = @_getRequestHeaders(credentials)
      url = credentials.instanceUrl + @sourceUrl
      @status = AttachmentLoader.states.DOWNLOAD

      @fileTransfer.onprogress = @_progressChanged
      @fileTransfer.download(url, @destPath, @_successHandler, @_errorHandler, true, headers)

  abort: =>
    @fileTransfer.abort()

module.exports = AttachmentLoader