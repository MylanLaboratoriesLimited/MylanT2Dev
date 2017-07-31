Spine = require 'spine'
Utils = require 'common/utils'
CallReport = require 'models/call-report'
CallReportPickListManager = require 'db/picklist-managers/callreport-picklist-manager'


class OrganizationCardActivitiesTableCell extends Spine.Controller
  tag: 'tr'

  events:
    'tap .customer': '_onCustomerTap'
    'tap': '_onActivityTap'

  elements:
    '.date': 'elDate'
    '.time': 'elTime'
    '.customer': 'elCustomer'
    '.type': 'elType'
    '.user': 'elUser'
    '.next-call': 'elNextCall'

  constructor: (@activity) ->
    super {}

  template: ->
    require('views/organization-card/organization-card-activities-table-cell')()

  _onCustomerTap: (event) =>
    event.stopPropagation()
    @trigger 'customerTap', @

  _onActivityTap: =>
    @trigger 'activityTap', @

  render: ->
    @html @template()
    @_fillGeneralInfo()
    @_fillActivityType()
    @

  _fillGeneralInfo: =>
    dateParts = Utils.formatDateTime(@activity.dateTimeOfVisit).split ' '
    @elDate.html dateParts[0]
    @elTime.html dateParts[1]
    @elCustomer.html "#{@activity.contactFullName()} <br/> #{@activity.contactRecordType}"
    @elUser.html @activity.userFullName()
    @elNextCall.text @activity.nextCallObjective

  _fillActivityType: =>
    new CallReportPickListManager().getLabelByValue(CallReport.sfdc.type, @activity.type)
    .then (label) => @elType.html label

module.exports = OrganizationCardActivitiesTableCell
