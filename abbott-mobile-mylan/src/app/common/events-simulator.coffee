class EventsSimulator

  constructor: (@srcElement) ->
    @target = null
    Object.keys(touchy.events).forEach (eventType) =>
      @srcElement.on touchy.events[eventType], @trigger

  getElementByCooridantes: (event) =>
    evt = if touchy.isTouch then event.changedTouches[0] else event
    el = document.elementFromPoint(evt.clientX, evt.clientY)
    while el.tagName is 'IFRAME'
      el = el.contentWindow.document.elementFromPoint(evt.clientX, evt.clientY)
    el

  getProp: (event, prop, target) =>
    touchList = _.map event[prop], (propItem)=>
     document.createTouch(window, target, propItem.identifier, propItem.pageX, propItem.pageY, propItem.screenX, propItem.screenY, propItem.clientX, propItem.clientY)
    document.createTouchList.apply document, touchList

  createTouchEvent: (eventType, originalEvent, target) =>
    evt = document.createEvent('TouchEvent')
    touches = @getProp(originalEvent, 'touches', target)
    targetTouches = @getProp(originalEvent, 'targetTouches', target)
    changedTouches = @getProp(originalEvent, 'changedTouches', target)
    evt.initTouchEvent(touches, targetTouches, changedTouches,
      eventType, window,
      evt.clientX, evt.clientY, evt.clientX, evt.clientY
      false, false, false, false);
    evt.clientX = originalEvent.clientX
    evt.clientY = originalEvent.clientY
    evt.pageX = originalEvent.pageX
    evt.pageY = originalEvent.pageY
    evt

  onEnd: =>
    reservedTags = ['SELECT', 'INPUT', 'TEXTAREA']
    @target.focus() if @target.tagName in reservedTags

  trigger: (event) =>
    event = event.originalEvent
    @srcElement.hide()
    if event.type is touchy.events.start
      @target = @getElementByCooridantes(event)
    return unless @target
    evt = @createTouchEvent(event.type, event, @target)
    @onEnd() if event.type is touchy.events.end
    @target.dispatchEvent(evt);
    @srcElement.show()

module.exports = EventsSimulator
