LazyTableController = require 'controllers/lazy-table-controller'

class UsersTableController extends LazyTableController
  _fetchAll: ->
    @collection.fetchAllSortedBy [@collection.model.sfdc.lastName], true

  _filterBy: (@searchString) ->
    fieldsValues = {}
    for field in @collection.model.searchFields
      fieldsValues[field] = @searchString
    @collection.fetchAllLikeAndSortBy fieldsValues, [@collection.model.sfdc.lastName], true

module.exports = UsersTableController