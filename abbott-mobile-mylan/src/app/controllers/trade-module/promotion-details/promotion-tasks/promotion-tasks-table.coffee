TableController = require 'controls/table/card-table'

class PromotionTasksTable extends TableController

  elements:
    '.scroll-content tbody': 'elTbody'

  template: ->
    require('views/trade-module/promotion-details/promotion-tasks/promotion-tasks-table')()

module.exports = PromotionTasksTable