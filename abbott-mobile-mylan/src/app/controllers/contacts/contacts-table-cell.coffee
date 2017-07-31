Spine = require 'spine'
TargetFrequenciesCollection = require 'models/bll/target-frequencies-collection'
AppointmentCard = require 'controllers/appointment-card/appointment-card'
CallReportCard = require 'controllers/call-report-card/call-report-card'

class ContactsTableCell extends Spine.Controller
  className: 'row'

  elements:
    '.contact': 'elContact'
    '.priority': 'elPriority'
    '.Specialty': 'elSpecialty'
    '.BUSpecialty': 'elBUSpecialty'
    '.at-calls': 'elAtCalls'
    '.last-call': 'elLastCall'
    '.organization': 'elOrganization'
    '.contact-organization-cell': 'elContactOrganizationCell'
    '.appt': 'elAppt'
    '.call-report': 'elCallReport'

  constructor: (@reference) ->
    super {}

  template: ->
    require('views/contacts/contacts-table-cell')()

  bindEvents: =>
    @_subscribeElementOnTapEvent @elContactOrganizationCell, @_onOrganizationCellTap
    @el.on 'tap', @_onCellTap
    @el.on 'hold', @_onCellHold if @reference.isActive()
    @_showCreateVisitsButtons() if @reference.isActive()

  _subscribeElementOnTapEvent: (element, callback) ->
    element.on 'tap', callback
    element.on 'hold', (event) -> event.stopPropagation()

  _onOrganizationCellTap: (event) =>
    event.stopPropagation()
    @trigger 'organizationCellTap', @

  _onCellTap: (event) =>
    @trigger 'cellTap', @

  _onCellHold: (event) =>
    @trigger 'cellHold', @

  render: ->
    @html @template()
    @elContact.html "#{@reference.contactFullName()} <br/> #{@reference.contactRecordType ? ''}"
    @elOrganization.html @reference.organizationNameAndAddress()
    @reference.getContact()
    .then (contact) =>
      if contact.lastDateTargetFrequency
        lastDateTargetFrequency = new TargetFrequenciesCollection().parseEntity contact.lastDateTargetFrequency
        @elAtCalls.html lastDateTargetFrequency.atCalls()
        @elLastCall.html lastDateTargetFrequency.lastCall()
      @elPriority.html contact.priority
      @elSpecialty.html contact.specialty
      @elBUSpecialty.html contact.abbottSpecialty
    @

  _showCreateVisitsButtons: =>
    @_showCreateApptButton()
    @_showCreateCallReportButton()

  _showCreateApptButton: =>
    @elAppt.addClass 'visible'
    @_subscribeElementOnTapEvent @elAppt, @_onApptTap

  _showCreateCallReportButton: =>
    @elCallReport.addClass 'visible'
    @_subscribeElementOnTapEvent @elCallReport, @_onCallReportTap

  _onApptTap: (event) =>
    event.stopPropagation()
    @trigger 'apptTap', @

  _onCallReportTap: (event) =>
    event.stopPropagation()
    @trigger 'callReportTap', @

module.exports = ContactsTableCell
