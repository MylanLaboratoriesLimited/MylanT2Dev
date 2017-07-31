TableController = require 'controls/table/table-controller'
TableCell = require 'controls/table/table-cell'
PromotionTaskAccountsCollection = require 'models/bll/promotion-task-accounts-collection'


class TasksPopupTable extends TableController
  className: "#{@::className} tasks-popup-table"

  constructor: ->
    super @
    @tasksCollection = new PromotionTaskAccountsCollection
    @tasks = []

  refreshTableByPromoId: (promoId) ->
    @tasksCollection.getBothRelatedAndNotRelatedToSkusTasks promoId
    .then (@tasks) =>
      if _.isEmpty(@tasks) then @_renderEmptyTable(@el, Locale.value('tradeModule.PromotionTasks.NoPromotionTasks') )
      else @render().el.removeClass 'empty-table'

  _renderEmptyTable: (tableElement, text) ->
    tableElement.addClass 'empty-table'
    .html "<p>#{text}</p>"

  numberOfRowsForTable: (table) -> @tasks?.length ? 0

  cellForRowAtIndexForTable: (index, table) -> @_createTableCell @tasks[index]

  _createTableCell: (task) ->
    new TableCell task.taskName


module.exports = TasksPopupTable