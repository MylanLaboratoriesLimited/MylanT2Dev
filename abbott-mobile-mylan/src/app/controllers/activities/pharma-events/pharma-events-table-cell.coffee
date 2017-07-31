Spine = require 'spine'
Utils = require 'common/utils'
PePickListManager = require 'db/picklist-managers/pe-picklist-manager'
PharmaEvent = require 'models/pharma-event'

class PharmaEventsTableCell extends Spine.Controller
  className: "row"

  elements:
    '.status': 'elStatus'
    '.owner': 'elOwner'
    '.event-name': 'elEventName'
    '.type-of-event': 'elTypeOfEvent'
    '.stage': 'elStage'
    '.start-date': 'elStartDate'
    '.location': 'elLocation'

  constructor: (@pharmaEvent) ->
    super {}
    @pePicklistManager = new PePickListManager

  template: ->
    require('views/activities/pharma-events/pharma-events-table-cell')()

  _onCellTap: =>
    @trigger 'cellTap', @

  bindEvents: =>
    @el.on 'tap', @_onCellTap

  render: ->
    @html @template()
    @_fillGeneralInfo()
    @_fillStage()
    @_fillTypeOfEvent()
    @_fillStatus()
    @

  _fillGeneralInfo: ->
    @elOwner.html @pharmaEvent.ownerFullName()
    @elEventName.text @pharmaEvent.eventName
    @elStartDate.html Utils.formatDateTimeWithBreak @pharmaEvent.startDate
    @elLocation.text @pharmaEvent.location

  _fillStage: ->
    @pePicklistManager.getLabelByValue(PharmaEvent.sfdc.stage, @pharmaEvent.stage)
    .then (label) => @elStage.html label

  _fillTypeOfEvent: ->
    @pePicklistManager.getLabelByValue(PharmaEvent.sfdc.eventType, @pharmaEvent.eventType)
    .then (label) => @elTypeOfEvent.html label

  _fillStatus: ->
    @pePicklistManager.getLabelByValue(PharmaEvent.sfdc.status, @pharmaEvent.status)
    .then (label) => @elStatus.html label


module.exports = PharmaEventsTableCell