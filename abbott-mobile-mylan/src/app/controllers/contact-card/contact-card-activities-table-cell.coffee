Spine = require 'spine'
Utils = require 'common/utils'
CallReport = require 'models/call-report'
CallReportPickListManager = require 'db/picklist-managers/callreport-picklist-manager'

class ContactCardActivitiesTableCell extends Spine.Controller
  tag: 'tr'

  elements:
    '.type': 'elType'
    '.date': 'elDate'
    '.time': 'elTime'
    '.user': 'elUser'
    '.next-call': 'elNextCall'

  events:
    'tap': '_onTap'

  constructor: (@activity) ->
    super {}

  template: ->
    require('views/contact-card/contact-card-activities-table-cell')()

  _onTap: =>
    @trigger 'tap', @

  render: ->
    @html @template()
    @_fillGeneralInfo()
    @_fillActivityType()
    @

  _fillActivityType: =>
    new CallReportPickListManager().getLabelByValue(CallReport.sfdc.type, @activity.type)
    .then (label) => @elType.html label

  _fillGeneralInfo: =>
    timeParts = Utils.formatDateTime(@activity.dateTimeOfVisit).split ' '
    @elDate.html timeParts[0]
    @elTime.html timeParts[1]
    @elUser.html @activity.userFullName()
    @elNextCall.text @activity.nextCallObjective

module.exports = ContactCardActivitiesTableCell