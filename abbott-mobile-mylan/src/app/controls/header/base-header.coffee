Spine = require 'spine'

class BaseHeader extends Spine.Controller
  tag: 'header'
  className: 'ordinary-header'

  elements:
    '.title': 'elTitle'
    '.left-controls': 'elLeftControls'
    '.right-controls': 'elRightControls'

  constructor: (@title) ->
    super {}

  template: ->
    require 'views/controls/header/base-header'

  render: ->
    @html @template()
    @setTitle @title
    Locale.localize @el
    @

  setTitle: (title) =>
    @elTitle.html title

  addLeftControlElement: (element) ->
    @elLeftControls.append element
    @elLeftControls.addClass 'show'

  addRightControlElement: (element) ->
    @elRightControls.append element
    @elRightControls.addClass 'show'

module.exports = BaseHeader
