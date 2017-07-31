AttachmentLoader = require 'common/attachment-managers/attachment-loader'

class AttachmentLoadManager
  @_queue: {}

  @getLoaderForAttachment: (attachment)=>
    return null unless attachment
    loader = @_queue[attachment.id]
    if(loader) then loader else null

  @getQueuedPresentations: =>
    Object.keys @_queue

  @queue: (attachment, callbacks, fileManager)=>
    loader = null
    unless @_queue[attachment.id]
      loader = new AttachmentLoader attachment, fileManager
      ['onStateChange', 'onFail', 'onSuccess'].forEach (callbackName)=>
        if callbacks and callbacks[callbackName]
          loader[callbackName] = callbacks[callbackName]
        if callbackName isnt 'onStateChange'
          loader["#{callbackName}Load"] = =>
            @dequeue attachment
            if loader[callbackName]
              loader[callbackName].apply loader[callbackName], arguments

      @_queue[attachment.id] = loader
    else
      console.log "AttachmentLoader #{attachment.id} already queued!"
    loader

  @queueInvoke: (attachment, callbacks, fileManager)=>
    loader = @queue attachment, callbacks, fileManager
    loader.download() if loader
    loader

  @dequeue: (attachment)=>
    loader = @_queue[attachment.id]
    delete @_queue[attachment.id]
    loader

  @dequeueInvoke: (attachment)=>
    loader = @dequeue attachment
    return null unless loader
    loader.abort() if loader
    loader

module.exports = AttachmentLoadManager