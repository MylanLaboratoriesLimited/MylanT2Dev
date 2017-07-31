class DragAndDrop

  START_DELAY: 500
  SCROLL_DIFF: 10
  AUTO_SCROLL_DELAY: 30
  timerId: null
  scrollTimerId: null

  constructor: (@cellObject, @areaElement, @callbacks)->
    #@callbacks -> {onStart, onMove, onEnd}
    @element = @cellObject.el
    @scrollWrapper = @areaElement.parent()
    @_bindEvents()
    @reset()

  _bindEvents: =>
    @element.bind touchy.events.start, @_start.bind @
    @element.bind touchy.events.move, @_move.bind @
    @element.bind touchy.events.end, @_end.bind @
    @element.bind "touchcancel", @_end.bind @
    @_bindOnScrollEvent()

  _bindOnScrollEvent: =>
    $parent = @areaElement.parent()
    $parent.bind 'scroll', @_clearStartTimerId

  _clearStartTimerId: =>
    clearTimeout @timerId

  _stopEvent: (event) =>
    event.preventDefault()

  _scrollDown: =>
    maxScroll = @scrollWrapper.prop("scrollHeight") - @limitHeight
    clearTimeout @scrollTimerId
    if @scrollWrapper.scrollTop() < maxScroll
      limitDistance = maxScroll - @scrollWrapper.scrollTop()
      scrollDiff = if limitDistance < @SCROLL_DIFF then limitDistance else @SCROLL_DIFF
      @scrollWrapper.scrollTop(@scrollWrapper.scrollTop() + scrollDiff)
      @startPosition.y = @startPosition.y - scrollDiff
      @movePosition.y = @limitHeight - @elBottom  + @scrollWrapper.scrollTop()
      @_checkRightBottom();
      @scrollTimerId = setTimeout @_checkLimitAndRefresh, @AUTO_SCROLL_DELAY

  _scrollTop: =>
    clearTimeout @scrollTimerId
    if @scrollWrapper.scrollTop() > 0
      scrollDiff = if @scrollWrapper.scrollTop() < @SCROLL_DIFF then @scrollWrapper.scrollTop() else @SCROLL_DIFF
      @scrollWrapper.scrollTop(@scrollWrapper.scrollTop() - scrollDiff)
      @startPosition.y = @startPosition.y + scrollDiff
      @movePosition.y = @scrollWrapper.scrollTop() - @elTop
      @_checkLeftTop();
      @scrollTimerId = setTimeout @_checkLimitAndRefresh, @AUTO_SCROLL_DELAY

  _checkLeftTop: =>
    #check limit left top
    diffX = @elLeft + @movePosition.x
    diffY = @elTop + @movePosition.y
    @movePosition.x = -@elLeft if diffX < 0
    @movePosition.y = -@elTop if diffY < 0

  _checkRightBottom: =>
    #check limit right bottom
    diffX = @elRight + @movePosition.x
    diffY = @elBottom + @movePosition.y
    @movePosition.x = @areaWidth - @elRight if diffX > @areaWidth
    @movePosition.y = @areaHeight - @elBottom if diffY > @areaHeight

  _checkLimitAndRefresh: =>
    @_checkLeftTop();
    @_checkRightBottom();
    @_scrollTop() if (@elTop - @scrollWrapper.scrollTop() + @movePosition.y) <= 0
    @_scrollDown() if (@elBottom - @scrollWrapper.scrollTop() + @movePosition.y) >= @limitHeight
    @refresh(2)

  _setSizes: =>
    @areaWidth = @areaElement.outerWidth()
    @areaHeight = @areaElement.outerHeight()
    @elLeft = @element.prop('offsetLeft')
    @elTop = @element.prop('offsetTop')
    @elRight = @elLeft + @element.outerWidth()
    @elBottom = @elTop + @element.outerHeight()
    @limitHeight = @areaElement.parent().outerHeight()

  _start: (event) =>
    return if @isBlocked or event.originalEvent.touches.length > 1
    $parent = @areaElement.parent()
    @startPosition =
      x: event.originalEvent.changedTouches[0].pageX
      y: event.originalEvent.changedTouches[0].pageY
    @timerId = setTimeout (=>
      @isStart = true
      @_setSizes()
      @callbacks?.onStart @
    ), @START_DELAY

  _move: (event) =>
    diffX = event.originalEvent.changedTouches[0].pageX - @startPosition.x
    diffY = event.originalEvent.changedTouches[0].pageY - @startPosition.y
    @_clearStartTimerId() if Math.abs(diffX) > 15 or Math.abs(diffY) > 15
    return if (!@isStart) or (event.originalEvent.touches.length > 1)
    @_stopEvent event
    @movePosition =
      x: diffX
      y: diffY
    @_checkLimitAndRefresh()
    @callbacks?.onMove @

  _end: (event) =>
    @_stopEvent event
    clearTimeout @timerId
    clearTimeout @scrollTimerId
    if @isStart
      @refresh()
      @elementPosition = @_elementPosition
    @isStart = false
    @callbacks?.onEnd @

  refresh: (zIndex)=>
    @_elementPosition =
      x: @movePosition.x + @elementPosition.x
      y: @movePosition.y + @elementPosition.y
    @element.css
      "webkitTransform": "translate3d(#{@_elementPosition.x}px, #{@_elementPosition.y}px, #{zIndex or 0}px)"
      "zIndex": zIndex or 1

  _addTransition: (duration) =>
    @element.css 'webkitTransition', "-webkit-transform linear #{duration}ms"
    @element.bind 'webkitTransitionEnd', @_removeTransition
    @isBlocked = true

  _removeTransition: =>
    @element.css 'webkitTransition', ''
    @element.unbind 'webkitTransitionEnd', @_removeTransition
    @isBlocked = false
    @refresh()

  reset: (duration)=>
    @movePosition = @elementPosition =
      x: 0
      y: 0
    if duration
      @_addTransition(duration)
      @refresh(2)
    else
      @refresh()
    @isBlocked = false

module.exports = DragAndDrop