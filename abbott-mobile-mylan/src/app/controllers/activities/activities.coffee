RootPanelScreen = require 'controllers/base/panel/root-panel-screen'
ActivitiesFilter = require 'controllers/activities/activities-filter'
ListPopup = require 'controls/popups/list-popup'
HeaderBaseControl = require 'controls/header-controls/header-base-control'
BaseHeader = require 'controls/header/base-header'
Search = require 'controls/search/search'
ActivitiesManager = require 'controllers/activities/activities-manager'
PeCardCreate = require 'controllers/pe-card/pe-card-create'

class Activities extends RootPanelScreen
  className: 'activities'

  elements:
    'input': 'elInput'

  # fix bluring on android
  events:
    'tap header': '_searchBlur'
    'tap .tables-holder': '_searchBlur'
  # end offix bluring on android

  activitiesManager: null

  activate: (params = {}) =>
    super params
    @activitiesManager?.activateCurrent()

  _searchBlur: =>
    @elInput.blur()

  active: ->
    super
    Locale.localize @el
    @activitiesManager?.release()
    @activitiesManager = new ActivitiesManager
    @activitiesManager.setContext @
    @_initHeader()
    @_initTableControllers()

  template: ->
    require('views/activities/activities')()

  _initHeader: =>
    @currentFilter = ActivitiesFilter.resources()[0]
    headerFilterBtn = new HeaderBaseControl @currentFilter.description, 'select-btn'
    headerFilterBtn.bind 'tap', @_onFilterTap
    @search = new Search()
    @search.bind 'searchChanged', @_onSearchChanged
    @search.bind 'searchClear', @_resetSearchingFilter
    @addPharmaEventButton = new HeaderBaseControl '', 'ctrl-add-button'
    @addPharmaEventButton.bind 'tap', @_onAddPharmaEventTap
    @addPharmaEventButton.el.hide()
    activitiesHeader = new BaseHeader Locale.value('activities.HeaderTitle')
    activitiesHeader.render()
    activitiesHeader.addLeftControlElement headerFilterBtn.el
    activitiesHeader.addLeftControlElement @addPharmaEventButton.el
    activitiesHeader.addRightControlElement @search.render().el
    @setHeader activitiesHeader

  _onFilterTap: (headerFilterBtn) =>
    filterPopup = new ListPopup ActivitiesFilter.resources(), @currentFilter
    filterPopup.bind 'onPopupItemSelected', (selectedItem) =>
      @currentFilter = selectedItem.model
      headerFilterBtn.updateTitle @currentFilter.description
      @dismissModalController()
      @reload()
    @presentModalController filterPopup

  reload: =>
    @addPharmaEventButton.el.hide()
    filterController = switch @currentFilter.id
      when ActivitiesFilter.appointments().id
        @activitiesManager.appointments
      when ActivitiesFilter.appointmentsToday().id
        @activitiesManager.appointmentsToday
      when ActivitiesFilter.appointmentsPast().id
        @activitiesManager.appointmentsPast
      when ActivitiesFilter.appointmentsTomorrow().id
        @activitiesManager.appointmentsTomorrow
      when ActivitiesFilter.calls().id
        @activitiesManager.calls
      when ActivitiesFilter.callsToday().id
        @activitiesManager.callsToday
      when ActivitiesFilter.pharmaEvents().id
        @addPharmaEventButton.el.show()
        @activitiesManager.pharmaEvents
    @activitiesManager.activeControllerWithSearch filterController, @search.getValue()

  _onSearchChanged: (value) =>
    @activitiesManager.filterCurrentBy value

  _resetSearchingFilter: =>
    @activitiesManager.resetAll()
    @activitiesManager.activeCurrent()

  _onAddPharmaEventTap: =>
    peCard = new PeCardCreate
    peCard.on 'pharmaEventChanged', => @activitiesManager.reloadCurrent()
    @stage.push(peCard)

  _initTableControllers: ->
    @content.append @activitiesManager[controllerName].el for controllerName of @activitiesManager.controllers
    @activitiesManager.activeControllerWithSearch @activitiesManager.defaultController()

module.exports = Activities