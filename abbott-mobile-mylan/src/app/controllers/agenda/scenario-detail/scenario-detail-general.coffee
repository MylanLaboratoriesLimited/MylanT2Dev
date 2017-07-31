Spine = require 'spine'
ListPopup = require 'controls/popups/list-popup'
PresentationsCollection = require 'models/bll/presentations-collection'
CommonInput = require 'controls/common-input/common-input'

class ScenarioDetailGeneral extends Spine.Controller
  _currentPresentation: null
  className: 'sidebar-general'
  elements:
    '.presentation-name': 'elPresentationName'
    '.selected-presentation': 'elSelectedPresentation'

  MAX_NAME_LENGTH: 255

  constructor: (@_scenarioName = '')->
    super {}

  _loadAvailablePresentations: =>
    new PresentationsCollection().fetchAllLoaded().then (@presentations)=>
      @presentations = @presentations.filter (presentation, index)=>
        @presentations[index]['description'] = @presentations[index]['name']
        !!presentation.currentVersion
      @presentations.unshift {id: null, description: 'None', name: 'None'}
      $.when()

  _onPresentationChoosed: (selectedPresentation)=>
    @elSelectedPresentation.html selectedPresentation.name
    @_currentPresentation = selectedPresentation
    @trigger 'presentationChanged', selectedPresentation

  _bindEvents: =>
    @elSelectedPresentation.bind 'tap', @_openPresentationsList
    @elPresentationName.bind 'blur', @_updateScenarioName
    @elPresentationName.bind 'touchstart', (event)-> event.stopPropagation()

  _openPresentationsList: =>
    @_loadAvailablePresentations()
    .then =>
      @_showFilterPopup()

  _showFilterPopup: ->
    filterPopup = new ListPopup @presentations, @_currentPresentation
    filterPopup.on 'onPopupItemSelected', (selectedElement)=>
      @_onPresentationChoosed selectedElement.model
      filterPopup.hide()
    filterPopup.show()

  _updateScenarioName: (event)=>
    @trigger 'scenarioNameChanged', @elPresentationName[0].getValue()

  template: ->
    require 'views/agenda/scenario-details-general'

  render: ->
    @html @template()
    @commonInput = new CommonInput app.mainController.el, @elPresentationName, @MAX_NAME_LENGTH, 'touchstart'
    @commonInput.setValue @_scenarioName
    @_bindEvents()

  hideKeyboard: =>
    @commonInput.element.blur()

module.exports = ScenarioDetailGeneral