Spine = require 'spine'
MediaButtonsStack = require 'controllers/media/media-buttons-stack'
PresentationsLoadManager = require 'common/presentation-managers/presentations-load-manager'
ProgressBar = require 'controls/progress-bar/progress-bar'
PresentationLoader = require 'common/presentation-managers/presentation-loader'
PresentationsCollection = require 'models/bll/presentations-collection'
PresentationsFileManager = require 'common/presentation-managers/presentations-file-manager'
Utils = require 'common/utils'

class MediaTableCell extends Spine.Controller
  className: 'row'
  elements:
    '.buttons-panel': 'elButtons'
    '.progress-bar': 'elProgress'
    '.current-size': 'elCurrentSize'
    '.total-size': 'elTotalSize'
    '.icon': 'elIcon'
    '.currentVersion': 'elCurrentVersion'

  states:
    INITED: 0
    DOWNLOADING: 1
    DOWNLOADED: 2

  constructor: (@presentation) ->
    super {}
    @collection = new PresentationsCollection

  render: ->
    @html @template()
    @_initButtons()
    @_fillData()

  template: ->
    require('views/media/media-table-cell')(presentation:@presentation)

  _initButtons: ->
    @mediaButtonsStack = new MediaButtonsStack
    @elButtons.append @mediaButtonsStack.el
    @mediaButtonsStack.render()

  _fillData: ->
    @loader = PresentationsLoadManager.getLoaderForId @presentation.id
    if @loader
      @_showLoaderProgress()
    else
      @_showState()

  bindEvents: =>
    @el.on 'tap', @_rowTap
    @mediaButtonsStack.on 'download', @_download
    @mediaButtonsStack.on 'update', @_download
    @mediaButtonsStack.on 'cancel', @_cancel
    @mediaButtonsStack.bindStackControllersEvents()

  _rowTap: =>
    @trigger 'willOpenPresentation', @presentation.id

  _setState:(state) ->
    @state = state
    @el.attr('class', @className)
    switch @state
      when @states.INITED
        @el.addClass 'inited'
        @_resetProgressValues()
        @mediaButtonsStack.activateDownloadBtn()
      when @states.DOWNLOADING then @el.addClass 'downloading'
      when @states.DOWNLOADED
        @el.addClass 'downloaded'
        @mediaButtonsStack.activateDoneIcon()

  _showProgressBar: ->
    @progressBar = new ProgressBar
    @elProgress.html @progressBar.el
    @mediaButtonsStack.activateCancelBtn()

  _showDownloadingProgress: ->
    @_showProgressBar()
    @_setState @states.DOWNLOADING

  _showState: ->
    if @presentation.wasDownloaded()
      @_setState @states.DOWNLOADED
      @mediaButtonsStack.activateUpdateBtn() if @presentation.hasUpdate()
    else
      @_setState @states.INITED

  _showLoaderProgress: ->
    switch @loader.state
      when PresentationLoader.states.DOWNLOAD then @_continueDownload()
      when PresentationLoader.states.UNZIP then @_unzip()
      when PresentationLoader.states.FINISHED then @_setState @states.DOWNLOADED

  _unzip: ->
    @_showDownloadingProgress()
    @progressBar.setValue 100
    @elCurrentSize.html (Math.round(@loader.fileSize/1024/1024*10)/10).toFixed(1)
    @elTotalSize.html (Math.round(@loader.fileSize/1024/1024*10)/10).toFixed(1)
    @loader.onSuccess = @_onSuccess
    @loader.onFail = @_onFail

  _continueDownload: ->
    @_showDownloadingProgress()
    @progressBar.setValue Math.round(@loader.loadedSize / @loader.fileSize * 100), true
    @loader.onStateChange = @_onStateChange
    @loader.onSuccess = @_onSuccess
    @loader.onFail = @_onFail

  _download: =>
    if Utils.deviceIsOnline()
      @_resetProgressValues()
      PresentationsLoadManager.queueInvoke(@presentation.id, @presentation.url, {
        onStateChange: @_onStateChange
        onSuccess: @_onSuccess
        onFail: @_onFail
      })
      @_showDownloadingProgress()
    else
      @_throwError Locale.value('home.AlertPopup.Caption'), Locale.value('home.AlertPopup.Message')

  _resetProgressValues: =>
    @elCurrentSize.html '0.0'
    @elTotalSize.html ''

  _cancel: =>
    if PresentationsLoadManager.dequeueInvoke @presentation.id
      @_fillData()

  _onSuccess: =>
    @presentation.currentVersion = @presentation.availableVersion
    iconPath = PresentationsFileManager.getPathToPresentation(@presentation.id) + "/" + @presentation.iconName
    PresentationsFileManager.pathExist "#{@presentation.id}/#{@presentation.iconName}"
    .done =>
      @presentation.iconPath = iconPath
      @_updatePresentationState()
    .fail @_updatePresentationState

  _updatePresentationState: =>
    @elIcon.attr('src', @presentation.iconPath)
    @collection.updateEntity(@presentation)
    @elCurrentVersion.html @presentation.currentVersion
    @_setState @states.DOWNLOADED

  # TODO need to implement correct handle errors
  _onFail: (error) =>
    switch error.code
      when FileTransferError.CONNECTION_ERR
        console.log 'Error whle downloading presentation'
        @_throwError Locale.value('Media.DownloadPresentationErrorCaption'), Locale.value('Media.DownloadPresentationErrorMessage')
      when FileTransferError.ABORT_ERR
        console.log 'abort'
    @_fillData()

  _throwError: (caption, message)->
    error =
      caption: caption
      message: message
    @trigger 'сellError', error

  _onStateChange: (state, progress)=>
    if state is PresentationLoader.states.DOWNLOAD
      @progressBar.setValue Math.round(progress.current / progress.total * 100)
      @elCurrentSize.html (Math.round(progress.current/1024/1024*10)/10).toFixed(1)
      @elTotalSize.html (Math.round(progress.total/1024/1024*10)/10).toFixed(1)

module.exports = MediaTableCell