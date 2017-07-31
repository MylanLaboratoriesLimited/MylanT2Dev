RootPanelScreen = require 'controllers/base/panel/root-panel-screen'
TourPlanningTableController = require 'controllers/tour-planning/tour-planning-table'
TourPlanningCollection = require 'models/bll/tour-planning-collection/tour-planning-collection'
AppointmentsCollection = require 'models/bll/call-reports-collection/appointments-collection'
TourPlanningTableCell = require 'controllers/tour-planning/tour-planning-table-cell'
TableHeaderItem = require 'controls/table/table-header/table-header-item'
SortingTableHeaderItem = require 'controls/table/table-header/sorting-table-header-item'
ListPopup = require 'controls/popups/list-popup'
MultiselectPopup = require 'controls/popups/multiselect-popup'
CallReport = require 'models/call-report'
Utils = require 'common/utils'
Query = require 'common/query'
BricksCollection = require 'models/bll/bricks-collection'
SforceDataContext = require 'models/bll/sforce-data-context'
ConfigurationManager = require 'db/configuration-manager'
AlarmManager = require 'common/alarm/alarm-manager'
HeaderBaseControl = require 'controls/header-controls/header-base-control'
HeaderDateTimeControl = require 'controls/header-controls/header-date-time-control'
BaseHeader = require 'controls/header/base-header'
DateTimePicker = require 'controls/datepicker/date-time-picker'
ActivityIndicator = require 'common/activity-indicator'
ContactCard = require 'controllers/contact-card/contact-card'
OrganizationCard = require 'controllers/organization-card/organization-card'
SettingsManager = require 'db/settings-manager'

# TODO: REFACTOR !!!
class TourPlanning extends RootPanelScreen
  className: 'table-view tour-planning'

  elements:
    'input[name="checkAll"]': 'elCheckboxAll'

  isCheckAll: false
  isCalculated: false
  isNeedRecalculate: false
  checkedCells: []
  bricksList: []
  originDateTime: null
  currentTime: null
  currentFilter: null
  config: null
  activeUser: null
  saveBtn: null
  appointmentsCollection: null
  bricksCollection: null

  TIMEPICKER_BEFORE_DAYS: 0
  TIMEPICKER_AFTER_DAYS: 90

  constructor: ->
    super
    @appointmentsCollection = new AppointmentsCollection
    @bricksCollection = new BricksCollection
    @subscribeOnNotification 'callReportCreated', @refresh

  active: ->
    super
    @_resetToDefaults()
    Locale.localize @el
    ConfigurationManager.getConfig()
    .then(@_handleConfigResponse,@_handleConfigResponse)
    .then(@_fetchTourplanningSettings)
    .then(@_activeTourPlanning,@_activeTourPlanning)
    .then(@_initHeader,@_initHeader)
    .then(@_initContent,@_initContent)

  _fetchTourplanningSettings: =>
    SettingsManager.getTourPlanningSettings()
    .then((settings)=>@planningSettings = settings)

  _resetToDefaults: ->
    @isCheckAll = false
    @isCalculated = false
    @isNeedRecalculate = false
    @checkedCells = []
    @bricksList = []
    @originDateTime = null
    @currentTime = null
    @currentFilter = []
    @config = null
    @activeUser = null
    @saveBtn = null

  _handleConfigResponse: (@config) =>
    @_getActiveUser()

  _getActiveUser: =>
    SforceDataContext.activeUser()
    .then (@activeUser) => @activeUser

  _activeTourPlanning: =>
    @_fetchBricks()
    .done (bricksList) =>
      @bricksList = bricksList.map (brick) -> { id: brick.id, description: brick.shortDescription }
      @_clearFilter()
    .fail (err) =>
      alert 'Error fetching records:\n #{JSON.stringify err}'

  _fetchBricks: ->
    @bricksCollection.fetchAllSortedBy([@bricksCollection.model.sfdc.name], true)
    .then (response) => @bricksCollection.getAllEntitiesFromResponse(response)

  _clearFilter: ->
    @currentFilter = _.first(@bricksList) ? [{ id: '', description: '' }]

  _composeFilterText: =>
    text = @currentFilter.map((filterItem)=>filterItem.description).join(', ')
    text = text.substr(0, 35) + '...' if text.length > 35
    text

  _initHeader: =>
    @currentFilter = [_.first(@bricksList)] unless _.isEmpty @bricksList
    headerFilterBtn = new HeaderBaseControl @_composeFilterText(), 'select-btn'
    headerFilterBtn.bind 'tap', @_onFilterTap
    @saveBtn = new HeaderBaseControl Locale.value('common:buttons.SaveBtn'), 'ctrl-btn'
    @saveBtn.bind 'tap', @_onSaveTap
    calculateBtn = new HeaderBaseControl Locale.value('tourPlanning.CalculateBtn'), 'ctrl-btn'
    calculateBtn.bind 'tap', @_onCalculateTap
    dateTimeBtn = new HeaderDateTimeControl Locale.value('tourPlanning.StartTime'), ''
    dateTimeBtn.bind 'tap', @_showDateTimePicker
    planningHeader = new BaseHeader Locale.value("tourPlanning.HeaderTitle")
    planningHeader.render()
    planningHeader.addLeftControlElement headerFilterBtn.el
    planningHeader.addRightControlElement dateTimeBtn.el
    planningHeader.addRightControlElement calculateBtn.el
    planningHeader.addRightControlElement @saveBtn.el
    @setHeader planningHeader
    @_setDateTime dateTimeBtn, new Date

  _onFilterTap: (headerFilterBtn) =>
    unless _.isEmpty @bricksList
      multiselectPopup = new MultiselectPopup @bricksList, _.clone(@currentFilter), '', @bricksList.length, 1
      multiselectPopup.on 'doneTap', (selectedItems) =>
        @currentFilter = selectedItems
        headerFilterBtn.updateTitle @_composeFilterText()
        @dismissModalController()
        @reload()
      @presentModalController multiselectPopup

  reload: =>
    @clearCheckedData()
    @tableController.reload()

  refresh: =>
    @tableController?.reload()

  clearCheckedData: =>
    @checkedCells = []
    @_setCheckAllState false
    @_calculateReset()

  _setCheckAllState: (isCheck) =>
    if @elCheckboxAll[0] then @elCheckboxAll[0].checked = @isCheckAll = isCheck

  _onSaveTap: =>
    unless @isNeedRecalculate
      @savePlannedAppointments()
      .then(-> AlarmManager.scheduleNextVisits())
      .then(=> @postNotification 'appointmentChanged')
      .then(@reload)
    else
      $.fn.dpToast Locale.value('tourPlanning.ToastMessage.NeedCalculate')

  _onCalculateTap: =>
    @calculate()

  calculate: =>
    unless _.isEmpty @checkedCells
      @currentTime = moment @originDateTime
      @_sortCheckedCells()

  _sortCheckedCells: =>
    spinner = new ActivityIndicator @tableController.el[0]
    spinner.show()
    setTimeout =>
      @_filteredCheckedCells(@checkedCells)
      .then ([@checkedCells, haveExistingAppointments]) =>
        checkedCellsTourPlannings = @checkedCells.map (cell) -> cell.tourPlanningEntity
        @tableController.moveEntitiesToBeginning checkedCellsTourPlannings
        @tableController.reloadTable()
        unless _.isEmpty @checkedCells
          @_calculateDone()
        else
          @_setCheckAllState false
          @_calculateReset()
        spinner.hide()
        @_showMessageAboutExistingAppointments() if haveExistingAppointments
    , 100

  _filteredCheckedCells: (cells) ->
    filteredCheckedCells = []
    haveExistingAppointments = false
    @_getExistingAppointments()
    .then (appointments) =>
      cells.forEach (cell) =>
        existingAppointments = appointments.filter (record) -> record.contactFullName() is cell.tourPlanningEntity.contactFullName()
        if _.isEmpty existingAppointments
          @_calculateTimeForTourPlanning cell.tourPlanningEntity
          filteredCheckedCells.push cell if cell.tourPlanningEntity.isChecked
        else
          haveExistingAppointments = true
          @_clearDataForTourPlanning cell.tourPlanningEntity
      [filteredCheckedCells, haveExistingAppointments]

  _getExistingAppointments: =>
    startOfCurrentDate = Utils.originalStartOfDate @currentTime
    endOfCurrentDate = Utils.originalEndOfDate @currentTime
    startOfCurrentDateCondition = {}
    startOfCurrentDateCondition[@appointmentsCollection.model.sfdc.dateTimeOfVisit] = startOfCurrentDate
    endOfCurrentDateCondition = {}
    endOfCurrentDateCondition[@appointmentsCollection.model.sfdc.dateTimeOfVisit] = endOfCurrentDate
    query = new Query()
    .selectFrom(@appointmentsCollection.model.table)
    .where(startOfCurrentDateCondition, Query.GRE)
    .and().where(endOfCurrentDateCondition, Query.LRE)
    @appointmentsCollection.fetchWithQuery(query)
    .then (response) => @appointmentsCollection.getAllEntitiesFromResponse response

  _calculateTimeForTourPlanning: (tourPlanning) ->
    startTime = moment @currentTime
    endTime = moment startTime
    tourPlanning.callDuration = @planningSettings.callDuration
    endTime.minutes endTime.minutes() + Utils.minutesOfDay(tourPlanning.callDuration)
    if Utils.isIntervalBefore(startTime, endTime, @planningSettings.lastVisitTimeEnd)
      if Utils.isTimeBefore(endTime, @planningSettings.lunchTimeStart) or Utils.isTimeAfter(startTime, @planningSettings.lunchTimeEnd)
        tourPlanning.visitStartTime = Utils.originalDateTime startTime.toDate()
        tourPlanning.visitEndTime = Utils.originalDateTime endTime.toDate()
        @currentTime = endTime
        @currentTime.minutes @currentTime.minutes() + Utils.minutesOfDay(@planningSettings.breakDuration)
      else
        @currentTime.hours(@planningSettings.lunchTimeEnd.hours()).minutes(@planningSettings.lunchTimeEnd.minutes())
        @_calculateTimeForTourPlanning tourPlanning
    else
      @_clearDataForTourPlanning tourPlanning

  _clearDataForTourPlanning: (tourPlanning) ->
    tourPlanning.isChecked = false
    tourPlanning.visitOrderNumber = 0

  _calculateDone: =>
    @isNeedRecalculate = false

  _calculateReset: =>
    @isNeedRecalculate = true
    @_updateSaveBtnState()

  _updateSaveBtnState: =>
    @saveBtn.el[if @checkedCells.length then 'addClass' else 'removeClass'] 'active' if @saveBtn

  _showMessageAboutExistingAppointments: ->
    $.fn.dpToast Locale.value('tourPlanning.ToastMessage.ExistedAppointments')

  _showDateTimePicker: (dateTimeBtn) =>
    unless @originDateTime then @originDateTime = new Date()
    dateTimePicker = new DateTimePicker @originDateTime, { beforeDays: @TIMEPICKER_BEFORE_DAYS, afterDays: @TIMEPICKER_AFTER_DAYS }
    dateTimePicker.on 'onDonePressed', (dateTime) =>
      @dismissModalController()
      @_setDateTime dateTimeBtn, dateTime
    @presentModalController dateTimePicker

  _setDateTime: (dateTimeBtn, result) =>
    @originDateTime = result
    dateTime = Utils.formatDateTimeWithBreak result
    dateTimeBtn.updateValue dateTime
    @_calculateReset()

  _initContent: =>
    @tableController = new TourPlanningTableController datasource: @
    @html @tableController.render().el

  createCollection: ->
    new TourPlanningCollection

  createTableHeaderItemsForModel: (model) ->
    # TODO: create custom headerItem
    checkAllHeaderItem = new TableHeaderItem '<input type="checkbox" name="checkAll" class="check-box">'
    checkAllHeaderItem.el.on 'tap', @_onCheckAllTap
    [
      checkAllHeaderItem
      new SortingTableHeaderItem Locale.value('common:names.Contact'), model.sfdc.contactLastName, model.sfdc.contactFirstName, model.sfdc.id
      new SortingTableHeaderItem Locale.value('common:names.Organization'), model.sfdc.organizationName, model.sfdc.id
      new SortingTableHeaderItem Locale.value('common:names.AtCalls'), 'atCalls'
      new TableHeaderItem Locale.value('common:names.LastCall')
      new TableHeaderItem Locale.value('common:names.Priority')
      new TableHeaderItem Locale.value('common:names.VisitOrder')
      new TableHeaderItem Locale.value('common:names.VisitsTimeInfo')
    ]

  _onCheckAllTap: =>
    @_setCheckAllState !@elCheckboxAll[0].checked
    @checkedCells = []
    if @isCheckAll
      @tableController.getAllEntities()
      .then (allEntities) =>
        allEntities.forEach (tourPlanningEntity) =>
          tourPlanningTableCell = @_createCell tourPlanningEntity
          @checkedCells.push tourPlanningTableCell
        @_calculateReset()
        @tableController.reload()
    else
      @_calculateReset()
      @tableController.reload()

  cellForObjectOnTable: (tourPlanningEntity, table) =>
    tourPlanningTableCell = @_createCell tourPlanningEntity
    matchingCells = @checkedCells.filter (cell) -> cell.tourPlanningEntity.id is tourPlanningEntity.id
    unless _.isEmpty matchingCells
      cellIndex = @checkedCells.indexOf matchingCells[0]
      tourPlanningTableCell.tourPlanningEntity.isChecked = true
      tourPlanningTableCell.tourPlanningEntity.visitStartTime = matchingCells[0].tourPlanningEntity.visitStartTime
      tourPlanningTableCell.tourPlanningEntity.visitEndTime = matchingCells[0].tourPlanningEntity.visitEndTime
      tourPlanningTableCell.setVisitNumber cellIndex + 1
      @checkedCells[cellIndex] = tourPlanningTableCell
    tourPlanningTableCell

  _createCell: (tourPlanningEntity) =>
    tourPlanningTableCell = new TourPlanningTableCell tourPlanningEntity
    tourPlanningTableCell.on 'checkboxCellTap', @_onCheckboxCellTap
    tourPlanningTableCell.on 'contactCellTap', @_onContactCellTap
    tourPlanningTableCell.on 'organizationCellTap', @_onOrganizationCellTap
    tourPlanningTableCell.on 'visitOrderCellTap', @_onVisitOrderCellTap
    tourPlanningTableCell

  _onCheckboxCellTap: (cell) =>
    if cell.tourPlanningEntity.isChecked
      @checkedCells.push cell
      cell.setVisitNumber @checkedCells.length
    else
      cellIndex = @checkedCells.indexOf cell
      @checkedCells.splice cellIndex, 1
      cell.setVisitNumber 0
      @_recalculateVisitOrder(cellIndex) if @checkedCells.length > 0
      if @isCheckAll then @_setCheckAllState false
    @_calculateReset()

  _recalculateVisitOrder: (indexFrom) =>
    @checkedCells[index].setVisitNumber(index + 1) for index in [indexFrom...@checkedCells.length]

  _onContactCellTap: (cell) =>
    @stage.push(new ContactCard cell.tourPlanningEntity.contactSfId)

  _onOrganizationCellTap: (cell) =>
    @stage.push(new OrganizationCard cell.tourPlanningEntity.organizationSfId)

  _onVisitOrderCellTap: (cell) =>
    if @checkedCells.length
      datasource = [1..@checkedCells.length].map (value) -> {id: value, description: value}
      currentCellNumber = cell.tourPlanningEntity.visitOrderNumber
      orderPopup = new ListPopup datasource, {id: currentCellNumber}, Locale.value('tourPlanning.VisitOrderPopupHeader')
      orderPopup.bind 'onPopupItemSelected', (selectedItem) =>
        newIndex = selectedItem.id - 1
        @dismissModalController()
        @_swapOrderIndexes currentCellNumber - 1, newIndex
      @presentModalController orderPopup

  _swapOrderIndexes: (firstIndex, secondIndex) ->
    [@checkedCells[firstIndex], @checkedCells[secondIndex]] = [@checkedCells[secondIndex], @checkedCells[firstIndex]]
    @checkedCells[firstIndex].setVisitNumber firstIndex + 1
    @checkedCells[secondIndex].setVisitNumber secondIndex + 1
    @_calculateReset()

  brickIds: =>
    @currentFilter.map((filterItem)=>filterItem.id)

  userId: =>
    @activeUser?.id ? null

  savePlannedAppointments: =>
    Utils.runSimultaneously _(@checkedCells).map (cell) =>
      tourPlanningEntity = cell.tourPlanningEntity
      newAppointment = {}
      newAppointment[CallReport.sfdc.createdOffline] = true
      newAppointment[CallReport.sfdc.dateTimeOfVisit] = tourPlanningEntity.visitStartTime
      newAppointment[CallReport.sfdc.dateOfVisit] = Utils.originalDate tourPlanningEntity.visitStartTime
      newAppointment[CallReport.sfdc.organizationSfId] = tourPlanningEntity.organizationSfId
      newAppointment[CallReport.sfdc.remoteOrganizationName] = tourPlanningEntity.organizationName
      newAppointment.organizationName = tourPlanningEntity.organizationName
      newAppointment[CallReport.sfdc.organizationCity] = tourPlanningEntity.organizationCity
      newAppointment[CallReport.sfdc.organizationAddress] = tourPlanningEntity.organizationAddress
      newAppointment[CallReport.sfdc.contactSfid] = tourPlanningEntity.contactSfId
      newAppointment[CallReport.sfdc.remoteContactFirstName] = tourPlanningEntity.contactFirstName
      newAppointment[CallReport.sfdc.remoteContactLastName] = tourPlanningEntity.contactLastName
      newAppointment.contactFirstName = tourPlanningEntity.contactFirstName
      newAppointment.contactLastName = tourPlanningEntity.contactLastName
      newAppointment[CallReport.sfdc.contactRecordType] = tourPlanningEntity.contactRecordType
      newAppointment[CallReport.sfdc.userFirstName] = @activeUser.firstName
      newAppointment[CallReport.sfdc.userLastName] = @activeUser.lastName
      newAppointment[CallReport.sfdc.userSfid] = @activeUser.id
      newAppointment[CallReport.sfdc.duration] = tourPlanningEntity.callDuration.minutes()
      newAppointment[CallReport.sfdc.type] = CallReport.TYPE_APPOINTMENT
      newAppointment[CallReport.sfdc.recordTypeId] = @config.appointmentRecordTypeId
      newAppointment['attributes'] = {type: CallReport.table}
      @appointmentsCollection.createEntity(newAppointment)

module.exports = TourPlanning