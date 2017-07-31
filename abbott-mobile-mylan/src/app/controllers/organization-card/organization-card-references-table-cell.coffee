Spine = require 'spine'

class OrganizationCardReferencesTableCell extends Spine.Controller
  tag: 'tr'

  elements:
    '.primary': 'elPrimary',
    '.appt': 'elAppt',
    '.call-report': 'elCallReport',
    '.customer': 'elCustomer'

  constructor: (@reference) ->
    super {}

  template: ->
    require('views/organization-card/organization-card-references-table-cell')()

  _onApptTap: =>
    @trigger 'apptTap', @

  _onCallReportTap: =>
    @trigger 'callReportTap', @

  _onCustomerTap: =>
    @trigger 'customerTap', @

  bindEvents: =>
    @elCustomer.on 'tap', @_onCustomerTap

  render: ->
    @html @template()
    @_showPrimaryCheckmark() if @reference.isPrimary
    @_showCreateVisitsButtons() if @reference.isActive()
    @elCustomer.html "#{@reference.contactFullName()} <br/> #{@reference.contactRecordType}"
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

module.exports = OrganizationCardReferencesTableCell
