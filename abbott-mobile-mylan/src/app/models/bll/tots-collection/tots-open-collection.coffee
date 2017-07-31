TotsCollection = require 'models/bll/tots-collection/tots-collection'

class TotsOpenCollection extends TotsCollection
  _dataType: ->
    fieldValue = {}
    fieldValue[@model.sfdc.type] = @model.TYPE_OPEN
    fieldValue

module.exports = TotsOpenCollection