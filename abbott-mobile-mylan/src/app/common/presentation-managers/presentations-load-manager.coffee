PresentationLoader = require 'common/presentation-managers/presentation-loader'

class PresentationsLoadManager
  @_queue: {}

  @getLoaderForId: (presentationId)=>
    loader = @_queue[presentationId]
    if(loader) then loader else null

  @getQueuedPresentations: =>
    Object.keys @_queue

  @queue: (presentationId, callbacks)=>
    loader = null
    unless @_queue[presentationId]
      loader = new PresentationLoader presentationId
      ['onStateChange', 'onFail', 'onSuccess'].forEach (callbackName)=>
        if callbacks and callbacks[callbackName]
          loader[callbackName] = callbacks[callbackName]
        if callbackName isnt 'onStateChange'
          loader["#{callbackName}Load"] = =>
            @dequeue presentationId
            if loader[callbackName]
              loader[callbackName].apply loader[callbackName], arguments

      @_queue[presentationId] = loader
    else
      console.log "Presentation #{presentationId} already queued!"
    loader

  @queueInvoke: (presentationId, remotePath, callbacks)=>
    loader = @queue presentationId, callbacks
    loader.download remotePath if loader
    loader

  @dequeue: (presentationId)=>
    loader = @_queue[presentationId]
    return null unless loader.canStop()
    delete @_queue[presentationId]
    loader

  @dequeueInvoke: (presentationId)=>
    loader = @dequeue presentationId
    return null unless loader
    loader.abort() if loader
    loader

module.exports = PresentationsLoadManager