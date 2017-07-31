Spine = require 'spine'

NotificationsModule =
  shouldDeferNotification: (notification) ->
    throw 'Should be overridden'

  executeDeferredNotificationCallbacks: ->
    while not _.isEmpty @deferredNotificationCallbacks
      notification = @deferredNotificationCallbacks.pop() 
      notification.callback(notification.args...)
    true

  postNotification: (notification, args...) ->
    Spine.trigger notification, args...

  subscribeOnNotification: (notification, callback) ->
    Spine.bind notification, (args...) =>
      if @shouldDeferNotification notification
        @deferredNotificationCallbacks = [] if _.isEmpty @deferredNotificationCallbacks
        unless _.any @deferredNotificationCallbacks, _.matches { callback: callback }
          @deferredNotificationCallbacks.push { callback: callback, args: args }
      else
        callback(args...)

module.exports = NotificationsModule