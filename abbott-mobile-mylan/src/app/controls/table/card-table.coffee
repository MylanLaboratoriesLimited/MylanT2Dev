Spine = require 'spine'

class CardTableController extends Spine.Controller
  elements:
    '.tbody': 'elTbody'

  constructor: (@datasource) ->
    super {}

  template: ->
    require('views/controls/table/table-controller')()

  render: ->
    @html @template()
    Locale.localize @el
    @refresh()
    @

  refresh: ->
    @_renderTableView()

  _renderTableView: =>
    return if @_numberOfRows() <= 0
    @rowIndex = 0
    @_renderTableRow() while @rowIndex < @_numberOfRows()

  _renderTableRow: ->
    cell = @_cellForRowAtIndex @rowIndex
    @elTbody.append cell.el[0]
    cell.render()
    ++@rowIndex

  _numberOfRows: ->
    @datasource.numberOfRowsForTable @

  _cellForRowAtIndex: (index) ->
    @datasource.cellForRowAtIndexForTable index, @

module.exports = CardTableController