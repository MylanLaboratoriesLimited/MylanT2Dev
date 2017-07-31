Spine = require 'spine'
HeaderBaseControl = require 'controls/header-controls/header-base-control'

class HeaderDateTimeControl extends Spine.Controller

  className: 'ctrl-date-time'

  events:
    'tap': '_tap'

  elements:
    '.header-date-time-title': 'elTitle'
    '.header-date-time-value': 'elValue'

  constructor: (title, value) ->
    super {}
    @html require 'views/controls/header-controls/header-date-time-control'
    @updateTitle title
    @updateValue value

  _tap: ->
    @trigger 'tap', @

  updateTitle: (title) ->
    @elTitle.html title

  updateValue: (value) ->
    @elValue.html value

module.exports = HeaderDateTimeControl