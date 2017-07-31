FullscreenPanel = require 'controllers/base/panel/fullscreen-panel'
LazyTableController = require 'controllers/lazy-table-controller'
ScenariosCollection = require 'models/bll/scenarios-collection'
ScenariosTableCell = require 'controllers/agenda/scenarios-table-cell'
Header = require 'controls/header/header'
HeaderBaseControl = require 'controls/header-controls/header-base-control'
Scenario = require 'models/scenario'
ScenarioDetails = require 'controllers/agenda/scenario-details'
PresentationScenarioViewer = require 'controllers/presentation-viewer/presentation-scenario-viewer'
ConfirmationPopup = require 'controls/popups/confirmation-popup'

class Scenarios extends FullscreenPanel
  className: 'table-view scenarios'

  tableController: null

  constructor: ->
    super
    @subscribeOnNotification 'scenarioUpdated', @reload

  shouldDeferNotification: (notification) =>
    true

  active: ->
    super
    @_initHeader()
    @_initContent()

  _initHeader: ->
    addScenarioEventButton = new HeaderBaseControl '', 'ctrl-add-button'
    addScenarioEventButton.bind 'tap', @_onAddScenarioTap
    scenariosHeader = new Header Locale.value('scenarios.HeaderTitle')
    scenariosHeader.render()
    scenariosHeader.addRightControlElement addScenarioEventButton.el
    @setHeader scenariosHeader

  _onAddScenarioTap: =>
    @stage.push(new ScenarioDetails)

  reload: =>
    @tableController?.reload()

  _initContent: ->
    @tableController = new LazyTableController datasource: @
    @html @tableController.render().el

  createCollection: ->
    new ScenariosCollection

  createTableHeaderItemsForModel: (model) ->
    null

  cellForObjectOnTable: (scenario, table) =>
    contactsTableCell = new ScenariosTableCell scenario
    contactsTableCell.on 'cellTap', @_onCellTap
    contactsTableCell.on 'openScenarioTap', @_onOpenScenarioTap
    contactsTableCell.on 'deleteScenarioTap', @_onDeleteScenarioTap
    contactsTableCell.on 'deleteScenarioShow', @_onDeleteScenarioShow
    contactsTableCell.on 'deleteScenarioHide', @_onDeleteScenarioHide
    contactsTableCell

  _onCellTap: (cell) =>
    if @_cellWithDeleteButton
      @_cellWithDeleteButton?.switcher?.hide()
      @_cellWithDeleteButton = null
    else
      @stage.push(new ScenarioDetails cell.scenario)

  _onOpenScenarioTap: (cell) =>
    presentationScenarioViewer = new PresentationScenarioViewer(cell.scenario)
    presentationScenarioViewer.on 'complete', -> presentationScenarioViewer.closePresentation()
    presentationScenarioViewer.openPresentation()

  _onDeleteScenarioTap: (cell) =>
    confirm = new ConfirmationPopup { caption: Locale.value('scenarios.ConfirmationPopup.DeleteItem.Caption'), message: Locale.value('card.ConfirmationPopup.DeleteItem.Question') }
    confirm.cell = cell
    confirm.bind 'yesClicked', @_onDeleteApprove
    confirm.bind 'noClicked', @_onDeleteDiscard
    @presentModalController confirm

  _onDeleteApprove: (confirm) =>
    @dismissModalController()
    scenariosCollection = new ScenariosCollection
    scenariosCollection.removeEntity(confirm.cell.scenario)
    .then =>
      @reload()
      @postNotification 'scenarioUpdated'

  _onDeleteDiscard: (confirm) =>
    @dismissModalController()

  _onDeleteScenarioShow: (cell) =>
    if cell isnt @_cellWithDeleteButton
      @_cellWithDeleteButton?.switcher?.hide()
      @_cellWithDeleteButton = cell

  _onDeleteScenarioHide: (cell) =>
    @_cellWithDeleteButton = null if cell is @_cellWithDeleteButton

module.exports = Scenarios
