class Touchy
  constructor: (@root = document, @eventTarget = null, @preventDefault = true) ->
    @touchEvents =
      start: 'touchstart'
      move: 'touchmove'
      end: 'touchend'

    @mouseEvents =
      start: 'mousedown'
      move: 'mousemove'
      end: 'mouseup'

    @isTouch = 'ontouchstart' of window

    @HOLD_TIMEOUT = 700
    @TAP_TIMEOUT = 600
    @SWIPE_TIMEOUT = 400

    @doubleTap = false
    @doubleTapTimerId = null

    @startScrollY = 0
    @endScrollY = 0

    @events = if @isTouch then @touchEvents else @mouseEvents
    @root.addEventListener @events.start, @onStart, false

  _preventDefault: (event, element) =>
    if @preventDefault
      reservedTags = ['SELECT', 'INPUT', 'TEXTAREA']
      event.preventDefault() unless ((element.tagName in reservedTags) or @scrolableElement)

  onStart: (event) =>
    @startEle = event.target
    @scrolableElement = @getScrollableElement(@startEle)
    @_preventDefault event, @startEle #todo: this is hack for Android 3.x + to listen move events
    @startTime = new Date().getTime()
    startTouch = if @isTouch then event.touches[0] else event
    @nrOfFingers = if @isTouch then event.touches.length else 1
    @moveX = @startX = startTouch.clientX
    @moveY = @startY = startTouch.clientY
    @endScrollY = @startScrollY = @scrolableElement.scrollTop if @scrolableElement
    @timeId = setTimeout @onHold, @HOLD_TIMEOUT
    @addListeners()

  onMove: (event) =>
    @_preventDefault event, @startEle #todo: this is hack for Android 3.x + to listen move events
    moveTouch = if @isTouch then event.touches[0] else event
    @moveX = moveTouch.clientX
    @moveY = moveTouch.clientY
    @nrOfFingers = if @isTouch then event.touches.length else 1

  onEnd: (event, isScroll) =>
    clearTimeout @timeId
    endEle = event.target
    @_preventDefault event, endEle
    @removeListeners()
    return if @nrOfFingers > 1 or isScroll
    endTime = new Date().getTime()
    timeDiff = endTime - @startTime
    endTouch = if @isTouch then event.changedTouches[0] else event
    endX = endTouch.clientX
    endY = endTouch.clientY
    targetElement = @eventTarget or endEle
    targetElement = jQuery targetElement unless targetElement instanceof jQuery
    diffX = @getAbsDiff @startX, endX
    diffY = @getAbsDiff @startY, endY
    if (diffX >= 15 or diffY >= 15) and (timeDiff < @SWIPE_TIMEOUT)
      if diffX > diffY
        direction = if @startX > endX then 'right' else 'left'
      else
        direction = if @startY > endY then 'up' else 'down'
      targetElement.trigger 'swipe' + direction
    else if endEle is @startEle
      if timeDiff > @TAP_TIMEOUT
        targetElement.trigger 'longTap'
      else
        if @doubleTap and @firstEle is @startEle
          targetElement.trigger 'doubleTap', [endX, endY]
          @doubleTap = false
          @firstEle = null
          clearTimeout @doubleTapTimerId
        else
          targetElement.trigger 'tap'
          @firstEle = @startEle
          @doubleTap = true
        @resetDoubleTap()


  addListeners: =>
    @startEle.addEventListener @events.move, @onMove, false
    @startEle.addEventListener @events.end, @onEnd, false
    @scrolableElement.addEventListener 'scroll', @onScroll, false if @scrolableElement

  removeListeners: =>
    @startEle.removeEventListener @events.move, @onMove, false
    @startEle.removeEventListener @events.end, @onEnd, false
    @scrolableElement.removeEventListener 'scroll', @onScroll, false if @scrolableElement

  getScrollableElement: (element) =>
    elements = []
    while element.tagName != 'BODY'
      element = element.parentNode
      elements.push element
    result = elements.filter (el) -> (el.scrollHeight isnt el.clientHeight) and jQuery(el).css('overflow-y') is 'auto'
    result[0]

  getAbsDiff: (startValue, endValue) =>
    Math.abs(endValue - startValue)

  onScroll: (event) =>
    @endScrollY = @scrolableElement.scrollTop if @scrolableElement
    if @getAbsDiff(@startScrollY, @endScrollY) > 15
      @onEnd event, true

  onHold: =>
    if @getAbsDiff(@startX, @moveX) < 15 and
      @getAbsDiff(@startY, @moveY) < 15 and
      @nrOfFingers is 1
        jQuery(@startEle).trigger 'hold'

  resetDoubleTap: =>
    @doubleTapTimerId = setTimeout (=>
      @doubleTap = false
      @firstEle = null
    ), @TAP_TIMEOUT

module.exports = Touchy
