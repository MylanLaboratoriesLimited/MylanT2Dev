RootPanelScreen = require 'controllers/base/panel/root-panel-screen'
PresentationsCollection = require 'models/bll/presentations-collection'
HeaderBaseControl = require 'controls/header-controls/header-base-control'
BaseHeader = require 'controls/header/base-header'
AlertPopup = require 'controls/popups/alert-popup'
LazyTableController = require 'controllers/lazy-table-controller'
MediaTableCell = require 'controllers/media/media-table-cell'
PresentationsLoadManager = require 'common/presentation-managers/presentations-load-manager'
PresentationsFileManager = require 'common/presentation-managers/presentations-file-manager'
PresentationViewer = require 'controllers/presentation-viewer/presentation-viewer'
Utils = require 'common/utils'

class Media extends RootPanelScreen
  className: 'media table-view'

  active: ->
    super
    @_initHeader()
    @_initContent()

  _initHeader: ->
    downloadAllBtn = new HeaderBaseControl Locale.value('common:buttons.DownloadAll'), 'ctrl-btn'
    downloadAllBtn.bind 'tap', @_downloadAll
    mediaHeader = new BaseHeader Locale.value('Media.HeaderTitle')
    mediaHeader.render()
    mediaHeader.addRightControlElement downloadAllBtn.el
    @setHeader mediaHeader

  _downloadAll: =>
    unless Utils.deviceIsOnline() then @_showErrorPopup {caption: Locale.value('home.AlertPopup.Caption'), message: Locale.value('home.AlertPopup.Message')}
    else
      @tableController.getAllEntities()
      .then (presentations) =>
        for presentation in presentations
          if presentation.hasUpdate() or not presentation.wasDownloaded()
            PresentationsLoadManager.queueInvoke presentation.id, presentation.url
        @tableController.reload()

  _initContent: ->
    @tableController = new LazyTableController datasource: @
    @html @tableController.render().el

  createCollection: ->
    new PresentationsCollection

  createTableHeaderItemsForModel: (model) ->
    null

  cellForObjectOnTable: (presentation, table) =>
    presentationTableCell = new MediaTableCell presentation
    presentationTableCell.on 'сellError', @_showErrorPopup
    presentationTableCell.on 'willOpenPresentation', @_openPresentation
    presentationTableCell

  _showErrorPopup: (error) =>
    alertPopup = new AlertPopup { caption: error.caption, message: error.message }
    alertPopup.bind 'yesClicked', @dismissModalController
    alertPopup.bind 'hide', @dismissModalController
    @presentModalController alertPopup

  _openPresentation: (presentationId) =>
    PresentationsFileManager.presentationExist(presentationId)
    .then -> 
      presentationViewer = new PresentationViewer(presentationId)
      presentationViewer.on 'complete', -> presentationViewer.closePresentation()
      presentationViewer.openPresentation()

module.exports = Media