
Spine = require 'spine'
SyncManager = require 'sfdc/synchronisation/sync-manager'
SyncPopup = require 'controls/popups/sync-popup'
Alarm = require 'common/alarm/alarm'
BottomMenu = require 'controls/bottom-menu/bottom-menu'
AppointmentsCollection = require 'models/bll/call-reports-collection/appointments-collection'
Utils = require 'common/utils'
AlarmManager = require 'common/alarm/alarm-manager'
AlertPopup = require 'controls/popups/alert-popup'
AppointmentCardEdit = require 'controllers/appointment-card/appointment-card-edit'
FullscreenStage = require 'controllers/base/stage/fullscreen-stage'
NotificationsModule = require 'common/notifications-module'
Scenarios = require 'controllers/agenda/scenarios'
Locale = require 'common/localization/locale'
LanguagesFilter = require 'common/localization/languages-filter'
ListPopup = require 'controls/popups/list-popup'
SettingsManager = require 'db/settings-manager'
DeviceCollection = require 'models/bll/device-collection'
SettingsManager = require 'db/settings-manager'
ConfirmationPopup = require 'controls/popups/confirmation-popup'
SyncLogManager = require 'common/log-manager'

class Home extends Spine.Controller
  @include NotificationsModule

  CLOSEST_VISITS_NUMBER: 2

  className: 'home stack-page'

  events:
    'tap .contacts': '_openContacts'
    'tap .organizations': '_openOrganizations'
    'tap .activities': '_openActivities'
    'tap .tour-planning': '_openTourPlanning'
    'tap .tots': '_openTots'
    'tap .media': '_openMedia'
    'tap .sync': '_startSynchronisation'
    'tap .logo': '_toggleBottomMenu'

  elements:
    '.closest-calls li': 'openCallButtons'
    '.media':'elMedia'
    '.last-sync-date':'elLastSyncDate'

  tabbar: null

  shouldDeferNotification: (notification) =>
    false

  constructor: ->
    super
    AlarmManager.scheduleNextVisits()
    document.addEventListener('resume', @_refreshOnResume, false)
    @subscribeOnNotification 'appointmentChanged', @_getClosestVisits
    @subscribeOnNotification 'databaseCleared', @_resetTabbar
    @bottomMenuPanel = new BottomMenu

  deactivate: ->
    super
    document.removeEventListener('menubutton', @_toggleBottomMenu, false)

  activate: ->
    super
    document.addEventListener('menubutton', @_toggleBottomMenu, false)

  active: ->
    super
    @render()
    @_loadAppointmentFromNotification() if Utils.isIOS()
    @_getClosestVisits() if Utils.isDevice()

  _refreshOnResume: =>
    @_loadAppointmentFromNotification()
    @_getClosestVisits()

  render: ->
    @html @template()
    @_setLastSyncDate()
    @_updateMediaAndAgendaDisplay()
    Locale.localize @el
    @el.bind 'tap', @_hideBottomMenu
    @

  _setLastSyncDate: ->
    SettingsManager.getLastSucceededSyncDateTime()
    .then (date) =>
      @elLastSyncDate.html "#{Locale.value('home.LastSyncDate')} #{Utils.formatDateTime date}" if date

  _updateMediaAndAgendaDisplay: =>
    SettingsManager.getValueByKey('isDynamicAgendaEnabled')
    .then (isAgendaEnabled) => if isAgendaEnabled then @_showAgenda() else @_hideAgenda()

    SettingsManager.getValueByKey('isEdetailingEnabled')
    .then (isEdetailingEnabled) => if isEdetailingEnabled then @_showMedia() else @_hideMedia()

  _hideAgenda: =>
    @bottomMenuPanel.hideAgenda()

  _showAgenda: =>
    @bottomMenuPanel.showAgenda()

  _hideMedia: =>
    @elMedia.css 'display', 'none'

  _showMedia: =>
    @elMedia.css 'display', ''

  template: ->
    require('views/home')()

  _loadAppointmentFromNotification: =>
    AlarmManager.loadCallReport()

  _getClosestVisits: =>
    appointmentsCollection = new AppointmentsCollection(pageSize: @CLOSEST_VISITS_NUMBER)
    appointmentsCollection.fetchClosest()
    .then (response) =>
      closestVisits = @_prepareLastVisits response.records
      @_renderClosestVisits closestVisits

  _prepareLastVisits: (entities) ->
    entities.map (entity) =>
      id: entity.id
      contactFullName: entity.contactFullName()
      dateOfVisit: Utils.dotFormatDate entity.dateTimeOfVisit
      timeOfVisit: Utils.formatTime entity.dateTimeOfVisit

  _renderClosestVisits: (visitsData) =>
    _(@CLOSEST_VISITS_NUMBER).times (index) =>
      button = $ @openCallButtons[index]
      visitData = visitsData[index]
      if visitData
        button.addClass 'show'
        button.find('.name').text visitData.contactFullName
        button.find('.day').text visitData.dateOfVisit
        button.find('.time').text visitData.timeOfVisit
        button.unbind('tap').bind 'tap', => @_openCall visitData
      else
        button.removeClass 'show'
        button.unbind 'tap'

  _openCall: (callItem) =>
    @_openPanelInFullScreenStage(new AppointmentCardEdit callItem.id)

  _openDynamicAgenda: =>
    @_openPanelInFullScreenStage(new Scenarios)

  _openPanelInFullScreenStage: (panel) =>
    stageController = new FullscreenStage
    stageController.on 'close', -> stageController.release()
    stageController.setPanel(panel)
    stageController.showInContext @

  _openContacts: =>
    @navigate '/tabbar/contacts'

  _openOrganizations: =>
    @navigate '/tabbar/organizations'

  _openActivities: =>
    @navigate '/tabbar/activities'

  _openTourPlanning: =>
    @navigate '/tabbar/tour-planning'

  _openTots: =>
    @navigate '/tabbar/tots'

  _openMedia: =>
    @navigate '/tabbar/media'

  _toggleBottomMenu: (event) =>
    event.stopPropagation()
    @bottomMenuPanel.toggle()
    @bottomMenuPanel.unbind('openDynamicAgenda').bind 'openDynamicAgenda', @_openDynamicAgenda
    @bottomMenuPanel.unbind('changeLanguage').bind 'changeLanguage', @_changeLanguage

  _hideBottomMenu: =>
    @bottomMenuPanel.hide()

  _startSynchronisation: =>
    if Utils.deviceIsOnline()
      AlarmManager.cancelNotification()
      @_synchronise()
    else
      @_showOfflineAlert()

  _synchronise: ->
    syncManager = new SyncManager
    @_syncPopup = new SyncPopup
    @_syncPopup.show()
    syncManager.startLoading((status, percentage) => @_syncPopup.updateMessage status, percentage)
    .then(@_onSynchronisationSucceeded, @_onSynchronisationFailed)

  _onSynchronisationSucceeded: =>
    @_getClosestVisits()
    @_syncPopup.hide()
    @_updateMediaAndAgendaDisplay()
    @_resetTabbar()
    @_setLastSyncDate()
    @_showSynchronisationSucceededAlert()

  _showSynchronisationSucceededAlert: ->
    alertPopup = new AlertPopup(caption:Locale.value('synchronizationPopup.SynchronizationStatus'), message: Locale.value('synchronizationPopup.SynchronizationCompleted'))
    alertPopup.bind 'yesClicked', alertPopup.hide
    alertPopup.show()

  _onSynchronisationFailed: (error) =>
    @_syncPopup.hide()
    @_updateMediaAndAgendaDisplay()
    @_resetTabbar()
    @_showSynchronisationFailedMessage()

  _showSynchronisationFailedMessage: ->
    confirm = new ConfirmationPopup { caption: Locale.value('synchronizationPopup.SynchronizationStatus'), message: Locale.value('synchronizationPopup.LogMessage.SendErrorReport', { postProcess: 'sprintf' })}
    confirm.bind 'yesClicked', =>
      SyncLogManager.sendLogToSf()
      confirm.hide()
    confirm.bind 'noClicked', =>
      confirm.hide()
    confirm.show()

  _showOfflineAlert: ->
    alertPopup = new AlertPopup { caption: Locale.value('home.AlertPopup.Caption'), message: Locale.value('home.AlertPopup.Message') }
    alertPopup.bind 'yesClicked', alertPopup.hide
    alertPopup.show()

  _resetTabbar: =>
    @tabbar.reset()

  _changeLanguage: =>
    Locale.currentLanguage()
    .then (lang) =>
      selectedItem = _(LanguagesFilter.resources()).findWhere { value: lang }
      filterPopup = new ListPopup LanguagesFilter.resources(), selectedItem, Locale.value('homeMenu.Language')
      filterPopup.bind 'onPopupItemSelected', (selectedItem) =>
        filterPopup.hide()
        Locale.setCurrentLanguage(selectedItem.value)
        .then @reload
      filterPopup.show()

  reload: =>
    @render()
    @_resetTabbar()
    @_getClosestVisits()

module.exports = Home