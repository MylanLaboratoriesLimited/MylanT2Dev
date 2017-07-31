class Switcher

  constructor: (@scrollElement, @hiddenElement) ->
    @_scrollWidth = @hiddenElement.outerWidth(true)
    @_sx = @_ex = @_dx = 0
    @_sy = 0
    @zIndex = 0
    @_bindEvents()

  _bindEvents: =>
    @scrollElement.on touchy.events.start, @_onStart
    @scrollElement.on touchy.events.move, @_onMove
    @scrollElement.on touchy.events.end, @_onEnd
    @scrollElement.on 'touchcancel', @_onEnd

  _onStart: (event) =>
    @_isStart = true
    @isMove = false
    @_isPrevented = false
    @_sx = event.originalEvent.changedTouches[0].pageX + @_ex;
    @_sy = event.originalEvent.changedTouches[0].pageY
    @scrollElement.css "webkitTransition", "all linear 0"

  _onMove: (event) =>
    return unless @_isStart
    @_dx = @_sx - event.originalEvent.changedTouches[0].pageX
    dy = @_sy - event.originalEvent.changedTouches[0].pageY
    if Math.abs(@_dx) > Math.abs(dy)
      event.preventDefault()
      @_isPrevented = true
    else
      return @_onEnd() unless @_isPrevented
    @_dx = @_scrollWidth if @_dx > @_scrollWidth
    @_dx = 0 if @_dx < 0
    @scrollElement.css "webkitTransform", "translate3d(-" + @_dx + "px, 0, 0)"
    @isMove = true

  _onEnd: =>
    @_isStart = false
    if @isMove
      @scrollElement.css("webkitTransition", "all linear 200ms") if @_dx / @_scrollWidth < 1 and @_dx / @_scrollWidth > 0
      if @_dx / @_scrollWidth > 0.5
        @show()
      else
        @hide()

  show: =>
    @scrollElement.css "webkitTransition", "all linear 200ms"
    @scrollElement.css "webkitTransform", "translate3d(-#{@_scrollWidth}px, 0, #{@zIndex}px)"
    @_ex = @_scrollWidth
    @scrollElement.trigger 'onSwitcherShow', @

  hide: =>
    @scrollElement.css "webkitTransition", "all linear 200ms"
    @scrollElement.css "webkitTransform", "translate3d(0, 0, #{@zIndex}px)"
    @_ex = 0
    @scrollElement.trigger 'onSwitcherHide', @

module.exports = Switcher
