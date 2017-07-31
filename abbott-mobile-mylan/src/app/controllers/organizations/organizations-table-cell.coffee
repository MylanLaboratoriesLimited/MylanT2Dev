Spine = require 'spine'

class OrganizationsTableCell extends Spine.Controller
  className: "row"

  elements:
    ".account-name": "elAccountName"
    ".account-record-type": "elAccountRecordType"
    ".specialty": "elSpecialty"
    ".billing-address": "elBillingAddress"
    ".global-priority": "elGlobalPriority"
    ".city": "elCity"
    ".phone": "elPhone"

  constructor: (@organization) ->
    super {}

  template: ->
    require('views/organizations/organizations-table-cell')()

  _onCellTap: =>
    @trigger 'cellTap', @

  bindEvents: =>
    @el.on 'tap', @_onCellTap

  render: ->
    @html @template()
    @elAccountName.html @organization.name
    @elAccountRecordType.html @organization.recordType
    @elSpecialty.html @organization.specialty1
    @elGlobalPriority.html @organization.globalPriority
    @elCity.html @organization.city
    @elBillingAddress.html "#{@organization.address ? ''} #{@organization.city ? ''}"
    @elPhone.html @organization.phone ? ''
    @

module.exports = OrganizationsTableCell