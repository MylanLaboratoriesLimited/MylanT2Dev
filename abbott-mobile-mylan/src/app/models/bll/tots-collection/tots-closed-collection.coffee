TotsCollection = require 'models/bll/tots-collection/tots-collection'

class TotsClosedCollection extends TotsCollection
  _dataType: ->
    fieldValue = {}
    fieldValue[@model.sfdc.type] = @model.TYPE_CLOSED
    fieldValue

module.exports = TotsClosedCollection