PickListDatasource = require 'controllers/call-report-card/picklist-datasource'
CallReport = require 'models/call-report'
CallReportPickListManager = require 'db/picklist-managers/callreport-picklist-manager'

class JointVisitPickListDatasource extends PickListDatasource

  pickListName: ->
    CallReport.sfdc.jointVisit

  pickListManager: ->
    new CallReportPickListManager

module.exports = JointVisitPickListDatasource