Spine = require 'spine'

class PageControlItem extends Spine.Controller
  tag: 'li'
  className: 'page-control-item'

  events:
    'tap': '_onPageControlItemTap'

  constructor: (@index) ->
    super {}

  _onPageControlItemTap: =>
    @trigger 'pageControlItemTap', @

module.exports = PageControlItem