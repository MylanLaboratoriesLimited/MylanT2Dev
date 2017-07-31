PresentationsFileManager = require 'common/presentation-managers/presentations-file-manager'
Spine = require 'spine'
PresentationStructureGenerator = require 'controllers/agenda/presentation-structure-generator'
PresentationsCollection = require 'models/bll/presentations-collection'
Query = require 'common/query'
PresentationViewer = require 'controllers/presentation-viewer/presentation-viewer'
Utils = require 'common/utils'
FileProcessor = require 'common/file-processor/file-processor'

class PresentationScenarioViewer extends Spine.Module
  @include Spine.Events

  PLUGIN_NAME: 'PresentationViewer'
  ENTRY_FILENAME: 'index.html'
  ANDROID_ENTRY_FILENAME: 'file:///android_asset/www/engine/index.html'
  IOS_ENTRY_FILENAME: 'engine/index.html'
  EVENT_DID_LOAD: 'DID_LOAD'
  EVENT_ON_COMPLETE: 'ON_COMPLETE'

  constructor: (@scenario) ->

  openPresentation: =>
    PresentationStructureGenerator.generate(@scenario)
    .then (structurePath) =>
      indexWithStructure = "#{@ENTRY_FILENAME}"
      #TODO: check WTF cant extends from presentationView
      if Utils.isIOS()
        presentationIndexPath = @IOS_ENTRY_FILENAME
        #presentationIndexPath = @_pathWithPathComponent PresentationsFileManager.getPathToPresentation(presentationEntity.id), indexWithStructure
        # use ios path
      else
        presentationIndexPath = @ANDROID_ENTRY_FILENAME
        structurePath = structurePath.replace('file://', '')
      cordova.exec @_presentationViewingHandler, @_presentationViewingErrorHandler, @PLUGIN_NAME, 'openPresentation', [presentationIndexPath, structurePath]

  _pathWithPathComponent: (path, pathComponent) ->
    "#{path}/#{pathComponent}"

  _presentationViewingHandler: (message) =>
    switch message
      when @EVENT_DID_LOAD then @trigger 'didLoad', @
      when @EVENT_ON_COMPLETE then @trigger 'complete', @
      else @trigger 'didLoad', @

  _presentationViewingErrorHandler: (message) =>
    @trigger 'error', @

  closePresentation: =>
    deferred = new $.Deferred()
    cordova.exec (-> deferred.resolve()), ((error)-> deferred.reject error), @PLUGIN_NAME, 'closePresentation', []
    deferred.promise()

  getKPI: =>
    deferred = new $.Deferred()
    cordova.exec ((kpi)-> deferred.resolve kpi), ((error)-> deferred.reject error), @PLUGIN_NAME, 'getKPI', []
    deferred.promise()

module.exports = PresentationScenarioViewer