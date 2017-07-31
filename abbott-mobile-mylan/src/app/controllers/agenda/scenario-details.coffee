Spine = require 'spine'
FullscreenPanel = require 'controllers/base/panel/fullscreen-panel'
PanelScreen = require 'controllers/base/panel/panel-screen'
HeaderBaseControl = require 'controls/header-controls/header-base-control'
Header = require 'controls/header/header'
ScenariosGridView = require 'controllers/agenda/scenarios-grid-view'
ScenarioDetailsGeneral = require 'controllers/agenda/scenario-detail/scenario-detail-general'
ScenarioDetailSlidesList = require 'controllers/agenda/scenario-detail/scenario-detail-slides-list'
Scenario = require 'models/scenario'
ScenariosCollection = require 'models/bll/scenarios-collection'
ConfirmationPopup = require 'controls/popups/confirmation-popup'
PresentationScenarioViewer = require 'controllers/presentation-viewer/presentation-scenario-viewer'

class ScenarioDetails extends FullscreenPanel
  _currentPresentation: null
  _scenarioName: ''
  _scenarioSequence: []
  className: 'scenario-details'

  elements:
    '.scenarios-grid-view-wrapper': 'elScenariosGridViewWrapper'
    '.scenarios-side-view': 'elSidebar'

  constructor: (@entity = null) ->
    super
    if @entity
      @_scenarioName = @entity.name
      @_scenarioSequence = JSON.parse @entity.structure
    @isChanged = false

  active: ->
    super
    @render()
    @_initHeader()
    @_initGridView()

  template: =>
    require 'views/agenda/scenario-details'

  render: =>
    @html @template()
    @_renderSidebarGeneral()
    @_renderSlidesList()

  onBack: =>
    @generalInfo.hideKeyboard()
    unless @isChanged then super
    else
      confirm = new ConfirmationPopup {caption: Locale.value('card.ConfirmationPopup.SaveChanges.Caption')}
      confirm.bind 'yesClicked', =>
        @dismissModalController()
        @_saveScenarioTap()
      confirm.bind 'noClicked', =>
        @dismissModalController()
        @isChanged = false
        super
      @presentModalController confirm

  _initHeader: =>
    headerPreviewBtn = new HeaderBaseControl Locale.value('common:buttons.Preview'), 'ctrl-btn'
    headerSaveBtn = new HeaderBaseControl Locale.value('common:buttons.SaveBtn'), 'ctrl-btn'
    headerPreviewBtn.bind 'tap', @_previewScenarioBtnTap
    headerSaveBtn.bind 'tap', @_saveScenarioTap
    title = if @entity
      Locale.value('scenarioDetails.EditHeaderTitle')
    else
      Locale.value('scenarioDetails.HeaderTitle')
    scenarioDetailsHeader = new Header title
    scenarioDetailsHeader.render()
    scenarioDetailsHeader.addRightControlElement headerPreviewBtn.el
    scenarioDetailsHeader.addRightControlElement headerSaveBtn.el
    @setHeader scenarioDetailsHeader

  _previewScenarioBtnTap: =>
    if @_scenarioSequence?.length > 0
      @_previewScenario()
    else
      @_showNoSlidesForPreviewToast()

  _previewScenario: =>
    scenario =
      name: @_scenarioName
      structure: JSON.stringify @_scenarioSequence

    presentationScenarioViewer = new PresentationScenarioViewer(scenario)
    presentationScenarioViewer.on 'complete', -> presentationScenarioViewer.closePresentation()
    presentationScenarioViewer.openPresentation()

  _saveScenarioTap: =>
    if @_scenarioSequence?.length > 0
      @_saveScenario()
    else
      @_showNoSlidesForSaveToast()

  _saveScenario: =>
    @generalInfo.hideKeyboard()
    if @_scenarioName?.length > 0
      scenariosCollection = new ScenariosCollection
      if @entity
        @entity.name = @_scenarioName
        @entity.structure = JSON.stringify @_scenarioSequence
        scenariosCollection.updateEntity(@entity)
      else
        scenario = new Scenario
        scenario.name = @_scenarioName
        scenario.structure = JSON.stringify @_scenarioSequence
        scenariosCollection.createEntity(scenario)
      @postNotification 'scenarioUpdated'
      @isChanged = false
      @onBack()
    else
      toastMessage = Locale.value('card.ToastMessage.RequiredFieldsHeader') + ":<br/> " + Locale.value('common:names.Name')
      $.fn.dpToast toastMessage

  _showNoSlidesForPreviewToast: ->
    $.fn.dpToast Locale.value('scenarioDetails.NoSlidesForPreview')

  _showNoSlidesForSaveToast: ->
    $.fn.dpToast Locale.value('scenarioDetails.NoSlidesForSave')

  _initGridView: =>
    @scenariosGridView = new ScenariosGridView
    @scenariosGridView.on 'gridRemoveCell', @_removeItem
    @scenariosGridView.on 'scenarioSequenceUpdate', @_updateSequence
    @scenariosGridView.on 'onCellMove', @_cellMoved
    @elScenariosGridViewWrapper.append @scenariosGridView.el
    @scenariosGridView.loadScenarios @_scenarioSequence

  _cellMoved: =>
    @isChanged = true

  _updateSequence: (cells)=>
    @_scenarioSequence = cells.map (cell)=>
      cell.slideObject

  _removeItem: (cellItem)=>
    @isChanged = true
    @slidesListController.appendSlide cellItem.slideObject

  _renderSidebarGeneral: =>
    @generalInfo = new ScenarioDetailsGeneral @_scenarioName
    @generalInfo.render()
    @elSidebar.append @generalInfo.el
    @generalInfo.on 'presentationChanged', (@_currentPresentation)=>
      @slidesListController.renderPresentationSlides @_currentPresentation.id, @_scenarioSequence
    @generalInfo.on 'scenarioNameChanged', (scenarioName)=>
      @isChanged = true if @_scenarioName isnt scenarioName
      @_scenarioName = scenarioName

  _renderSlidesList: =>
    @slidesListController = new ScenarioDetailSlidesList
    @slidesListController.render()
    @elSidebar.append @slidesListController.el
    @slidesListController.on 'sidebarSlideSelected', (selectedSlide)=>
      @isChanged = true
      selectedSlide.slideData.presentationName = @_currentPresentation.name
      @scenariosGridView.addCell selectedSlide.slideData

module.exports = ScenarioDetails