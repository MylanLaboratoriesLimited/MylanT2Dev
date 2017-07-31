Spine = require 'spine'

class TableController extends Spine.Controller
  className: 'tbody-holder scroll-container'
  elements:
    '.tbody': 'elTableController'

  constructor: (@datasource) ->
    super {}
    infinity.config.PAGE_TO_SCREEN_RATIO = 3
    infinity.config.SCROLL_THROTTLE = 350

  template: ->
    require('views/controls/table/table-controller')()

  render: ->
    @html @template()
    @_initializeTable()
    @refresh()
    @

  refresh: ->
    @_renderTableView()

  _initializeTable: =>
    @rowIndex = 0
    @listView?.remove()
    @listView = new infinity.ListView @elTableController, @el

  _renderTableView: =>
    return if @_numberOfRows() <= 0
    @_emptyCurrentCells()
    @fragment = document.createDocumentFragment()
    @_renderTableRow() while @rowIndex < @_numberOfRows()
    @_appendFragmentWithCells()
    @_bindCellsEvents()

  _renderTableRow: ->
    cell = @_cellForRowAtIndex @rowIndex
    @fragment.appendChild cell.el[0]
    cell.render()
    @currentCells.push cell
    ++@rowIndex

  _appendFragmentWithCells: ->
    container = document.createElement('div')
    container.appendChild @fragment
    @listView.append $(container)

  _bindCellsEvents: ->
    cell.bindEvents() for cell in @currentCells
    @_emptyCurrentCells()

  _emptyCurrentCells: ->
    @currentCells = []

  _numberOfRows: ->
    @datasource.numberOfRowsForTable @

  _cellForRowAtIndex: (index) ->
    @datasource.cellForRowAtIndexForTable index, @

module.exports = TableController