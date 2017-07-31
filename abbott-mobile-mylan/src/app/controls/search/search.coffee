Spine = require 'spine'
Rx = require 'rx/dist/rx.lite'

class Search extends Spine.Controller
  className: "search"

  elements:
    '.placeholder': 'elPlaceholder'
    'input': 'elInput'
    'button': 'elClear'

  events:
    'input input': '_checkInput'
    'tap button': '_clearSearch'
    # fix bluring on android
    'tap': '_stopEvent'
    'touchstart input': '_stopEvent'

  constructor: (@placeholder = Locale.value 'searchView.Placeholder' ) ->
    super {}

  _template: ->
    require('views/search/search')()

  render: ->
    @append @_template()
    @elPlaceholder.html @placeholder
    @_subscribeObservable()
    @elInput.on 'focus', @_focusInput
    @

  _blurInput: (event) =>
    @elInput.blur()
    document.removeEventListener 'touchstart', @_blurInput

  _focusInput: (event) =>
    document.addEventListener 'touchstart', @_blurInput

  _checkInput: (event) =>
    @_refreshPlaceholder event.target.value

  _search: (value) =>
    if value then @trigger 'searchChanged', value else @trigger 'searchClear'

  _clearSearch: =>
    if @getValue()
      @elInput.val ''
      @_refreshPlaceholder()
      @trigger 'searchClear'

  _refreshPlaceholder: (value) ->
    if value then @elPlaceholder.addClass 'hidden' else @elPlaceholder.removeClass 'hidden'

  _subscribeObservable: ->
    Rx.Observable.fromEvent(@elInput, 'input')
    .map (event) -> event.target.value
    .throttle 1000
    .distinctUntilChanged()
    .subscribe @_search

  _stopEvent: (event) ->
    event.stopPropagation()

  getValue: ->
    @elInput.val()

module.exports = Search