PresentationsFileManager = require 'common/presentation-managers/presentations-file-manager'
Spine = require 'spine'

class PresentationViewer extends Spine.Module
  @include Spine.Events

  PLUGIN_NAME: 'PresentationViewer'
  ENTRY_FILENAME: 'index.html'
  EVENT_DID_LOAD: 'DID_LOAD'
  EVENT_ON_COMPLETE: 'ON_COMPLETE'

  constructor: (@presentationId) ->

  openPresentation: =>
    presentationIndexPath = @_pathWithPathComponent PresentationsFileManager.getPathToPresentation(@presentationId), @ENTRY_FILENAME
    cordova.exec @_presentationViewingHandler, @_presentationViewingErrorHandler, @PLUGIN_NAME, 'openPresentation', [presentationIndexPath]

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

module.exports = PresentationViewer