LazyTableController = require 'controllers/lazy-table-controller'

class TourPlanningTableController extends LazyTableController
  reloadTable: =>
    @tableHeader.reset()
    @tableView.render()

  moveEntitiesToBeginning: (entities) =>
    @fetchResponse.records = entities.concat _.without(@fetchResponse.records, entities...)

  _fetchAll: =>
    @collection.fetchAllByBrickIdsForUser @datasource.brickIds(), @datasource.userId()

  _sortBy: (fields, isAsc) =>
    @collection.fetchAllByBrickIdsForUserSortedBy @datasource.brickIds(), @datasource.userId(), fields, isAsc

module.exports = TourPlanningTableController