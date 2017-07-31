class ActivityIndicator
  settings:
    lines: 13
    length: 6
    width: 2
    radius: 7
    corners: 1
    rotate: 0
    direction: 1
    color: '#000'
    speed: 1
    trail: 60
    shadow: false
    hwaccel: false
    className: 'spinner'
    zIndex: 2e9
    top: 'auto'
    left: 'auto'

  constructor: (@container=@_defaultContainer()) ->
    @spinner = new Spinner @settings
    @overlayContainer = document.createElement 'div'
    @overlayContainer.className = 'overlay-container'
    @overlay = document.createElement 'div'
    @overlay.className = 'overlay'
    @spinnerContainer = document.createElement 'div'
    @spinnerContainer.className = 'spinner-container'

  _defaultContainer: ->
    document.getElementsByClassName('app')[0]

  _preventDefault: (event) ->
    event.preventDefault()

  show: ->
    @overlayContainer.appendChild @overlay
    @overlayContainer.appendChild @spinnerContainer
    @container.appendChild @overlayContainer
    @spinner.spin @spinnerContainer
    @overlayContainer.addEventListener 'touchmove', @_preventDefault

  hide: ->
    @spinner.stop()
    @overlayContainer.parentNode?.removeChild @overlayContainer

module.exports = ActivityIndicator