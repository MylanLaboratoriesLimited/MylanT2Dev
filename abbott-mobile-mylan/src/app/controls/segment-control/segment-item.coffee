Spine = require 'spine'

class SegmentItem extends Spine.Controller
  tag: 'button'
  className: 'segment-item'

  events:
    'tap': '_onSegmentItemTap'

  name: null
  title: null
  controller: null

  constructor: ->
    super
    @wasControllerRendered = false

  _onSegmentItemTap: (event) ->
    @trigger 'segmentItemTap', @

  active: ->
    super
    @render()
    # TODO: might think of a better approach
    unless @wasControllerRendered  
      @wasControllerRendered = true
      @controller.active()
    else
      @activate()

  activate: ->
    super
    @controller.activate()

  deactivate: ->
    super
    @controller.deactivate()

  render: ->
    @setTitle @title
    @

  setTitle: (@title) ->
    @html @title

module.exports = SegmentItem