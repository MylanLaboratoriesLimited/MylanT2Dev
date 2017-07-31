PicklistDatasourceManager = require 'db/picklist-managers/picklist-datasource-manager'
CallReport = require 'models/call-report'

class CallReportPickListManager extends PicklistDatasourceManager
  targetModel: ->
    CallReport

  fieldNames: ->
    [CallReport.sfdc.type, CallReport.sfdc.jointVisit, CallReport.sfdc.typeOfVisit]

module.exports = CallReportPickListManager