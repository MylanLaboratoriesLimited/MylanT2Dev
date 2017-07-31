Spine = require 'spine'

class TableCell extends Spine.Controller
  className: 'table-cell'
  elements:
    '.title': 'elTitle'
    'td.cell-container': 'elContainer'

  constructor: (@title) ->
    super {}

  template: ->
    require('views/controls/table/table-cell')()

  render: ->
    @html @template()
    @elTitle.html @title ? ''
    @

  bindEvents: ->
    # Cand be overridden

module.exports = TableCell