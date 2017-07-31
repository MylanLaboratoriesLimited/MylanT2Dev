PresentationFileManager = require 'common/presentation-managers/presentations-file-manager'
ZipManager = require 'common/presentation-managers/zip-manager'
SforceDataContext = require 'models/bll/sforce-data-context'

class PresentationLoader
  @states:
    INITED: 0
    DOWNLOAD: 1
    UNZIP: 2
    REPLACING: 3
    FINISHED: 4

  errorHandler: (error)=>
    @onFailLoad? error
    @_cleanup()
    console.log "File transfer error handler called: #{error}"

  _cleanup: =>
    PresentationFileManager.removeArchive @presentationId
    PresentationFileManager.removeFolder @presentationId

  _onDownloadSuccess: (entry)=>
    @onStateChange? @state, {current: @loadedSize, total: @fileSize}
    @_unzip entry.fullPath

  _onUnzipSuccess: =>
    @state = PresentationLoader.states.REPLACING
    @onStateChange? @state
    PresentationFileManager.replacePresentation @presentationId, =>
      @state = PresentationLoader.states.FINISHED
      @onStateChange? @state
      @onSuccessLoad?()
      PresentationFileManager.removeArchive @presentationId
    , @errorHandler

  _unzip: (source)=>
    @state = PresentationLoader.states.UNZIP
    @onStateChange? @state
    destination = "#{@temporaryDirectory}/#{@presentationId}"
    @zipManager = new ZipManager source, destination
    @zipManager.unzip (=> @_onUnzipSuccess(destination)), @errorHandler

  constructor: (@presentationId)->
    @status = PresentationLoader.states.INITED
    @fileSize = 0
    @loadedSize = 0
    @temporaryDirectory = PresentationFileManager.getPathToTemporaryDir()
    @temporaryFile = "#{@temporaryDirectory}/#{@presentationId}.zip"

  _buildUrl: (baseUrl)=>
    SforceDataContext.getAuthCredentials()
    .then (credentials) =>
      $.when "#{baseUrl}&accessToken=#{credentials.accessToken}&instanceUrl=#{credentials.instanceUrl}"

  download: (baseUrl)=>
    @state = PresentationLoader.states.DOWNLOAD
    @_buildUrl(baseUrl)
    .then (url)=>
      @fileTransfer = new FileTransfer
      @fileTransfer.onprogress = (progress)=>
        @fileSize = progress.total
        @loadedSize = progress.loaded
        @onStateChange? @state, {current: @loadedSize, total: @fileSize}
      @fileTransfer.download url, @temporaryFile, @_onDownloadSuccess, @errorHandler, true

  abort: =>
    @fileTransfer.abort() if @canStop()

  canStop: =>
    @state is PresentationLoader.states.DOWNLOAD or @state is PresentationLoader.states.FINISHED

module.exports = PresentationLoader