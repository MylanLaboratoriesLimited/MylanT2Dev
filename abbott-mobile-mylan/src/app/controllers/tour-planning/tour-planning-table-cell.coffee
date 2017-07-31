Spine = require 'spine'
Utils = require 'common/utils'
SforceDataContext = require 'models/bll/sforce-data-context'
TargetFrequenciesCollection = require 'models/bll/target-frequencies-collection'

class TourPlanningTableCell extends Spine.Controller
  className: 'row'

  elements:
    '.contact': 'elContact'
    '.organization': 'elOrganization'
    '.contact-organization-cell': 'elContactOrganizationCell'
    '.at-calls': 'elAtCalls'
    '.last-call': 'elLastCall'
    '.priority': 'elPriority',
    '.visit-order': 'elVisitOrder',
    '.visit-time-info': 'elVisitTimeInfo'
    'input[type="checkbox"]': 'elCheckbox'
    '.checkbox-cell':'elCheckboxCell'
    '.contact-cell':'elContactCell'
    '.organization-cell':'elOrganizationCell'

  constructor: (@tourPlanningEntity) ->
    super {}

  template: ->
    require('views/tour-planning/tour-planning-table-cell')()

  bindEvents: =>
    @elOrganizationCell.on 'tap', @_onOrganizationCellTap
    @elContactCell.on 'tap', @_onContactCellTap
    @elCheckboxCell.on 'tap', @_onCheckboxCellTap
    @elVisitOrder.parent().on 'tap', @_onVisitOrderCellTap

  _onOrganizationCellTap: (event) =>
    event.stopPropagation
    @trigger 'organizationCellTap', @

  _onContactCellTap: (event) =>
    event.stopPropagation
    @trigger 'contactCellTap', @

  _onCheckboxCellTap: (event) =>
    event.stopPropagation
    @tourPlanningEntity.isChecked = !@elCheckbox[0].checked
    @_setSelectedCheckbox()
    @trigger 'checkboxCellTap', @

  _onVisitOrderCellTap: (event) =>
    event.stopPropagation
    @trigger 'visitOrderCellTap', @ if @elCheckbox[0].checked

  render: ->
    @html @template()
    if @tourPlanningEntity.isChecked
      @_setSelectedCheckbox()
    @elContact.html @tourPlanningEntity.contactFullName()
    @elOrganization.html @tourPlanningEntity.organizationNameAndAddress()
    @setVisitNumber @tourPlanningEntity.visitOrderNumber
    @elLastCall.html @tourPlanningEntity.lastCall
    @tourPlanningEntity.getContact()
    .then (contact) =>
      lastDateTargetFrequency = new TargetFrequenciesCollection().parseEntity contact.lastDateTargetFrequency
      @elAtCalls.html lastDateTargetFrequency.atCalls()
      @elPriority.html contact.priority
    @

  _setSelectedCheckbox: ->
    @elCheckbox[0].checked = @tourPlanningEntity.isChecked

  setVisitNumber: (number) =>
    @tourPlanningEntity.visitOrderNumber = number
    if @tourPlanningEntity.visitOrderNumber > 0
      visitTimeInfo = '-'
      if @tourPlanningEntity.visitStartTime and @tourPlanningEntity.visitEndTime
        visitTimeInfo = Utils.formatTime(@tourPlanningEntity.visitStartTime) + ' - ' + Utils.formatTime(@tourPlanningEntity.visitEndTime)
      @elVisitOrder.html @tourPlanningEntity.visitOrderNumber
      @elVisitTimeInfo.html visitTimeInfo
    else
      @elVisitOrder.html ''
      @elVisitTimeInfo.html ''
      @tourPlanningEntity.visitStartTime = 0
      @tourPlanningEntity.visitEndTime = 0

module.exports = TourPlanningTableCell
