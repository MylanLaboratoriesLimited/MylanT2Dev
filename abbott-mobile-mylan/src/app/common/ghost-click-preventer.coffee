class GhostClickPreventer

  PREVENT_TIMEOUT: 300

  constructor: ->
    @element = $("<div class='ghostclick-preventer'></div>")
    $(document.body).append @element
    $(document).on 'touchend', @onTouchEnd

  onTouchEnd: (event) =>
    reservedTags = ['SELECT', 'INPUT', 'TEXTAREA']
    return if (event.target.className is 'ghostclick-preventer') or (event.target.tagName in reservedTags)
    @element.css {pointerEvents: 'all'}
    @timeoutId = setTimeout @removePointerEvents, @PREVENT_TIMEOUT

  onBlur: (event) =>
    @element.css {pointerEvents: 'all'}
    @timeoutId = setTimeout @removePointerEvents, @PREVENT_TIMEOUT

  removePointerEvents: =>
    @element.css {pointerEvents: 'none'}

module.exports = GhostClickPreventer
