TotsCollection = require 'models/bll/tots-collection/tots-collection'

class TotsSubmitCollection extends TotsCollection
  _dataType: ->
    fieldValue = {}
    fieldValue[@model.sfdc.type] = @model.TYPE_SUBMIT
    fieldValue

module.exports = TotsSubmitCollection