Spine = require 'spine'

# TODO: refactor to combine segment with tabview
class SegmentControl extends Spine.Stack
  className: 'segment-control'

  constructor: (segmentItems) ->
    super
    segmentItems.forEach (segmentItem, index) =>
      segmentItem.on 'segmentItemTap', (sender) =>
        unless sender.isActive()
          sender.active()
          @trigger 'segmentItemTap', sender
      segmentItem.stack = @
      @[segmentItem.name] = segmentItem
      @add segmentItem.render()
    _.first(segmentItems).active()

  resetControllers: =>
    controller.reset() for controller in @manager.controllers

module.exports = SegmentControl