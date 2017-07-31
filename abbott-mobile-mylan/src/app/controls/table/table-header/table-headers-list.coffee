Spine = require 'spine'

class TableHeadersList extends Spine.Stack
  className: 'thead'
  elements:
    '.row': 'elContainer'

  activeController: null

  constructor: (tableHeaderItems, defaultSortingHeader = null) ->
    super
    @render()
    tableHeaderItems.forEach (tableHeaderItem) =>
      @add tableHeaderItem
      if tableHeaderItem.isSortable
        tableHeaderItem.el.on 'tap', (event) =>
          @_onHeaderItemTap tableHeaderItem
      if defaultSortingHeader and tableHeaderItem.title is defaultSortingHeader.title
        tableHeaderItem.isAsc = defaultSortingHeader.isAsc
        @_activateHeader(tableHeaderItem)

  _onHeaderItemTap: (headerItem) ->
   @_activateHeader(headerItem)

  _activateHeader: (headerItem) ->
    headerItem.active()
    @activeController = headerItem
    @trigger 'headerItemTap', headerItem

  add: (controller) ->
    @manager.add controller
    @elContainer.append controller.el

  reset: ->
    @activeController?.deactivate()
    @activeController = null

  template: ->
    require('views/controls/table/table-header')()

  render: ->
    @html @template()
    @

module.exports = TableHeadersList