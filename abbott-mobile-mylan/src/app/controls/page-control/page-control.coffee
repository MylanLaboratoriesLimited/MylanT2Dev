Spine = require 'spine'
PageControlItem = require 'controls/page-control/page-control-item'

class PageControl extends Spine.Controller
  tag: 'ul'
  className: 'page-control'

  constructor: (@pagesCount) ->
    super {}
    @items = []
    @render()

  render: ->
    @pagesCount is 1 and @el.hide()
    _(@pagesCount).times =>
      item = new PageControlItem @items.length
      item.on 'pageControlItemTap', => @trigger 'pageControlItemTap', item
      @items.push item
      @append item

  refreshByActivePageIndex: (index) =>
    _.each @items, (item) -> item.deactivate()
    @items[index].activate() if @items[index]

module.exports = PageControl