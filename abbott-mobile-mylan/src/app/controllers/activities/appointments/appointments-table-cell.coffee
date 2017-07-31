Spine = require 'spine'
Utils = require 'common/utils'
TargetFrequenciesCollection = require 'models/bll/target-frequencies-collection'

class AppointmentsTableCell extends Spine.Controller
  className: 'row'

  elements:
    '.date-time': 'elDateTime'
    '.customer': 'elCustomer'
    '.specialty': 'elSpecialty'
    '.priority': 'elPriority'
    '.organization': 'elOrganization'
    '.user': 'elUser'
    '.at-calls': 'elAtCalls'
    '.appointments-contact-cell': 'elAppointmentsContactCell'
    '.appointments-organization-cell': 'elAppointmentsOrganizationCell'
    '.promotions-info': 'elInfoButton'

  constructor: (@appointment) ->
    super {}

  render: ->
    @html @template()
    @elDateTime.html Utils.formatDateTimeWithBreak @appointment.dateTimeOfVisit
    @elUser.html @appointment.userFullName()
    @elCustomer.html @appointment.contactFullName()
    @elOrganization.html "#{@appointment.organizationName} <br/> #{@appointment.organizationCity ? ''}"
    @appointment.getContact()
    .then (contact) =>
      @elPriority.html contact.priority ? ''
      if contact.lastDateTargetFrequency
        lastDateTargetFrequency = new TargetFrequenciesCollection().parseEntity contact.lastDateTargetFrequency
        @elAtCalls.html lastDateTargetFrequency.atCalls()
    @appointment.getSpecialty()
    .then (specialty) => @elSpecialty.html @appointment.specialty
    @

  template: ->
    require('views/activities/appointments/appointments-table-cell')()

  bindEvents: =>
    @el.on 'tap', @_onCellTap
    @elAppointmentsContactCell.on 'tap', @_onAppointmentsContactCellTap
    @elAppointmentsOrganizationCell.on 'tap', @_onAppointmentsOrganizationCellTap

  _onCellTap: (event)=>
    event.stopPropagation()
    @trigger 'cellTap', @

  _onAppointmentsContactCellTap: (event) =>
    event.stopPropagation()
    @trigger 'appointmentsContactCellTap', @

  _onAppointmentsOrganizationCellTap: (event) =>
    event.stopPropagation()
    @trigger 'appointmentsOrganizationCellTap', @

module.exports = AppointmentsTableCell