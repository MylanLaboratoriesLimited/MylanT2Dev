CallReportsCollection = require 'models/bll/call-reports-collection/call-reports-collection'

class CallsCollection extends CallReportsCollection
  _dataType: ->
    fieldValue = {}
    fieldValue[@model.sfdc.type] = @model.TYPE_ONE_TO_ONE
    fieldValue

module.exports = CallsCollection