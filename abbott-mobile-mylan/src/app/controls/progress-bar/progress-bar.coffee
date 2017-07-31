Spine = require 'spine'

class ProgressBar extends Spine.Controller
  className: 'progress-bar'

  elements:
    '.progress-fill': 'elFill'
    '.progress-value': 'elValue'

  _template: ->
    require('views/controls/progress-bar/progress-bar')

  constructor: (@value = 0, withoutTransition = false)->
    super {}
    @render()
    @setValue @value, withoutTransition

  render: ->
    @html @_template()

  setValue: (value, withoutTransition = false)=>
    @value = value
    @elFill.addClass 'no-transition' if withoutTransition
    @elFill.css 'width', "#{@value}%"
    @elValue.html "#{@value}%"
    @elFill.removeClass 'no-transition' if withoutTransition

module.exports = ProgressBar