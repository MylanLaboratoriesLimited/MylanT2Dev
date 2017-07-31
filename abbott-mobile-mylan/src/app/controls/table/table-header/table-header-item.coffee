Spine = require 'spine'

class TableHeaderItem extends Spine.Controller
  className: 'col'
  title: ''

  constructor: (@title='') ->
    super {}
    @render()

  render: ->
    @html @title
    @

module.exports = TableHeaderItem