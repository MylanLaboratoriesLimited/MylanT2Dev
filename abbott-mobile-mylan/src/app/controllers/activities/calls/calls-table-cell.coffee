Spine = require 'spine'
Utils = require 'common/utils'
TargetFrequenciesCollection = require 'models/bll/target-frequencies-collection'

class CallsTableCell extends Spine.Controller
  className: "row"

  elements:
    '.date-time': 'elDateTime'
    '.customer': 'elCustomer'
    '.specialty': 'elSpecialty'
    '.priority': 'elPriority'
    '.user': 'elUser'
    '.at-calls': 'elAtCalls'
    '.calls-contact-cell': 'elCallsContactCell',

  constructor: (@call) ->
    super {}

  template: ->
    require('views/activities/calls/calls-table-cell')()

  _onCellTap: =>
    @trigger 'cellTap', @

  _onCallsContactCell: (event)=>
    event.stopPropagation()
    @trigger 'callsContactCellTap', @

  bindEvents: =>
    @elCallsContactCell.on 'tap', @_onCallsContactCell
    @el.on 'tap', @_onCellTap

  render: ->
    @html @template()
    @elDateTime.html Utils.formatDateTimeWithBreak @call.dateTimeOfVisit
    @elCustomer.html "#{@call.contactFullName()} <br/> #{@call.contactRecordType ? ''}"
    @elUser.html @call.userFullName()
    @call.getContact()
    .then (contact) =>
      @elPriority.html contact.priority
      if contact.lastDateTargetFrequency
        lastDateTargetFrequency = new TargetFrequenciesCollection().parseEntity contact.lastDateTargetFrequency
        @elAtCalls.html lastDateTargetFrequency.atCalls()
    @call.getSpecialty()
    .then((specialty) => @elSpecialty.html @call.specialty)
    @

module.exports = CallsTableCell