class AndroidViewResizer

  TIMEOUT_DELAY: 100
  RESET_TIMEOUT: 100

  resetTimeoutId: null
  updateTimeoutId: null
  blurTimeoutId: null
  screenScale: null

  constructor: (content, element) ->
    @screenScale = innerWidth / outerWidth
    @outerHeight = outerHeight
    $elements = jQuery element
    @content = jQuery content
    #@content.height @screenScale * outerHeight
    $elements.bind 'blur', @_onBlur
    $elements.bind 'focus', @_onFocus
    $elements.bind 'input', @_updateContentTopOffset
    $elements.bind 'elasticUpdate', @_updateContentTopOffset #center on elastic Update
    $elements.bind 'tap', @_onTap

  _getScrollableElement: (element) =>
    elements = []
    while element.tagName != 'BODY'
      element = element.parentNode
      elements.push element
    result = elements.filter (el) -> (el.scrollHeight isnt el.clientHeight) and jQuery(el).css('overflow-y') is 'auto'
    result[0]

  _onTap: (event)=>
    event.stopPropagation()
    @_refreshScreen()

  _isLessAndroid: =>
    @content.attr('data-strict-height') and parseFloat(device.version) < 4.4

  _refreshScreen: =>
    #android fix
    if @_isLessAndroid()
      @refreshTimeoutId = setTimeout (=>
        document.body.style.display = 'none'
        setTimeout (=>
          document.body.style.display = ''
          @isCentered = false
        ), 0
      ), 600
    else
      @_refreshCenter()

  _refreshCenter: =>
    @refreshTimeoutId = setTimeout (=>
      @isCentered = false
    ), 100

  _onFocus: (event) =>
    @el = jQuery event.target
    @_refreshCenter() if @_isLessAndroid()
    clearTimeout @blurTimeoutId
    clearTimeout @resetTimeoutId
    @_updateViewHeight()
    window.ar = @

  _onBlur: =>
    @el = null
    @isCentered = null
    @resetTimeoutId = setTimeout @_resetViewHeight, @RESET_TIMEOUT
    clearTimeout @updateTimeoutId
    clearTimeout @refreshTimeoutId
    ghostClickPreventer.onBlur()

  _updateContentTopOffset: =>
    @scrollWrapper.scrollTop @_getContentTopOffset() if @scrollWrapper and @scrollWrapper[0]

  _getContentTopOffset: =>
    centerOffset = if @el[0].tagName is 'TEXTAREA' then @el.textareaHelper('caretPos').top else @el.outerHeight() / 2
    @scrollWrapper.scrollTop() + @el.offset().top  - @scrollWrapper.height() / 2  + centerOffset - @scrollWrapper.offset().top

  _adaptWrapperSize: (availViewHeight) =>
    if @el
      wrapper = @content.parent()
      unless wrapper.hasClass 'android-resized-wrapper'
        wrapper.addClass 'android-resized-wrapper'
        wrapper.height @screenScale * (availViewHeight * 0.85)
        @content.addClass 'android-resized-content'
      unless @isCentered
        if @content.attr('data-strict-height')
          @scrollWrapper = jQuery @_getScrollableElement @content[0]
        else
          @scrollWrapper = jQuery @_getScrollableElement @el[0].parentNode
        @_updateContentTopOffset()
        @isCentered = true

  _updateViewHeight: =>
    plugins.softKeyboard.getAvailScreenHeight (availViewHeight) =>
      @updateTimeoutId = setTimeout @_updateViewHeight, @TIMEOUT_DELAY
      if availViewHeight < @outerHeight
        @_adaptWrapperSize(availViewHeight)
      else
        @_resetViewHeight()

  _refresh: =>
    unless @content.attr('data-strict-height')
      @content.css 'height', @content.height() + 'px'
      setTimeout (=> @content.css 'height', ''), 0

  _resetViewHeight: =>
    wrapper = @content.parent()
    if wrapper.hasClass 'android-resized-wrapper'
      @el?.blur()
      @_refresh() #refresh screen
      wrapper.removeClass 'android-resized-wrapper'
      wrapper.height ''
      @content.removeClass 'android-resized-content'

module.exports = AndroidViewResizer