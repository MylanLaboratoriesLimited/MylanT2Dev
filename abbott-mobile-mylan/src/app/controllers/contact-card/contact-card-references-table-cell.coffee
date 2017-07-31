Spine = require 'spine'

class ContactCardReferencesTableCell extends Spine.Controller
  tag: 'tr'

  elements:
    '.status': 'elStatus',
    '.primary': 'elPrimary',
    '.appt': 'elAppt',
    '.call-report': 'elCallReport',
    '.organization': 'elOrganization'

  constructor: (@reference) ->
    super {}

  template: ->
    require('views/contact-card/contact-card-references-table-cell')()

  _onApptTap: =>
    @trigger 'apptTap', @

  _onCallReportTap: =>
    @trigger 'callReportTap', @

  _onOrganizationTap: =>
    @trigger 'organizationTap', @

  bindEvents: =>
    @elOrganization.on 'tap', @_onOrganizationTap

  render: ->
    @html @template()
    @reference.getStatus()
    .then (status) => @elStatus.html status
    @_showPrimaryCheckmark() if @reference.isPrimary
    @_showCreateVisitsButtons() if @reference.isActive()
    @elOrganization.html @reference.organizationNameAndAddress()
    @bindEvents()
    @

  _showPrimaryCheckmark: ->
    @elPrimary.find('.check-box').addClass 'checked'

  _showCreateVisitsButtons: ->
    @_showCreateApptButton()
    @_showCreateCallReportButton()

  _showCreateApptButton: ->
    @elAppt.addClass 'visible'
    @elAppt.on 'tap', @_onApptTap

  _showCreateCallReportButton: ->
    @elCallReport.addClass 'visible'
    @elCallReport.on 'tap', @_onCallReportTap

module.exports = ContactCardReferencesTableCell
