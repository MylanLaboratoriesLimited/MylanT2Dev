PickListDatasource = require 'controllers/call-report-card/picklist-datasource'
CallReport = require 'models/call-report'
CallReportPickListManager = require 'db/picklist-managers/callreport-picklist-manager'

class TypeOfVisitPickListDatasource extends PickListDatasource

  pickListName: ->
    CallReport.sfdc.typeOfVisit

  pickListManager: ->
    new CallReportPickListManager

module.exports = TypeOfVisitPickListDatasource