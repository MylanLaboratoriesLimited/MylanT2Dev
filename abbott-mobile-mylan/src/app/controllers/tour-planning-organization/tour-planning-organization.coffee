TourPlanning = require 'controllers/tour-planning/tour-planning'
TargetTourPlanningCollection = require 'models/bll/tour-planning-collection/target-tour-planning-collection'
TourPlanningOrganizationTableController = require 'controllers/tour-planning-organization/tour-planning-organization-table'
HeaderBaseControl = require 'controls/header-controls/header-base-control'
HeaderDateTimeControl = require 'controls/header-controls/header-date-time-control'
Header = require 'controls/header/header'

class TourPlanningOrganization extends TourPlanning
  className: 'table-view tour-planning-organization'

  organizationId: null

  constructor: (@organizationId) ->
    super

  createCollection: =>
    new TargetTourPlanningCollection

  _initContent: =>
    @tableController = new TourPlanningOrganizationTableController datasource: @
    @html @tableController.render().el

  _initHeader: =>
    @saveBtn = new HeaderBaseControl Locale.value('common:buttons.SaveBtn'), 'ctrl-btn'
    @saveBtn.bind 'tap', @_onSaveTap
    calculateBtn = new HeaderBaseControl Locale.value('tourPlanning.CalculateBtn'), 'ctrl-btn'
    calculateBtn.bind 'tap', @_onCalculateTap
    dateTimeBtn = new HeaderDateTimeControl Locale.value('tourPlanning.StartTime'), ''
    dateTimeBtn.bind 'tap', @_showDateTimePicker
    planningHeader = new Header Locale.value("tourPlanning.HeaderTitle")
    planningHeader.render()
    planningHeader.addRightControlElement dateTimeBtn.el
    planningHeader.addRightControlElement calculateBtn.el
    planningHeader.addRightControlElement @saveBtn.el
    @setHeader planningHeader
    @_setDateTime dateTimeBtn, new Date

  # TODO: small hack - overriding onBack as it should be like in PanelScreen because
  # TourPlanningOrganization extends TourPlanning which extends RootPanelScreen but should act as PanelScreen
  onBack: =>
    @unsubscribeFromBackButton()
    @stage.pop()

module.exports = TourPlanningOrganization