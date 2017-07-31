Utils = require 'common/utils'
SettingsManager = require 'db/settings-manager'
AppointmentsCollection = require 'models/bll/call-reports-collection/appointments-collection'

class AlarmManager
  @API_PATH: if Utils.isIOS() then 'NotificationAlarm' else 'SBNotifier'
  @NAVIGATE_TO_APPOINTMENT_KEY: 'NAVIGATE_TO_APPOINTMENT'
  @currentApptScreen: null

  @_sendRequest: (action, params = []) =>
    deferred = new $.Deferred()
    cordova.exec (-> deferred.resolve()), (-> deferred.resolve()), @API_PATH, action, params
    deferred.promise()

  @scheduleNextVisits: =>
    @_sendRequest 'scheduleNextVisits'

  @cancelNotification: =>
    @_sendRequest 'cancelNotification'

  @loadCallReport: =>
    @_appointmentId()
    .then (apptId) =>
      return unless apptId
      new AppointmentsCollection().fetchEntityById(apptId)
      .then (appointment) => @_resetAppointmentId().then => @_openAppointmentScreen(apptId) if appointment
              
  @_openAppointmentScreen: (apptId) =>
    setTimeout =>
      @_dismissCurrentAppointmentScreen()
      AppointmentCardEdit = require 'controllers/appointment-card/appointment-card-edit'
      FullscreenStage = require 'controllers/base/stage/fullscreen-stage'
      Stage = require 'controllers/base/stage/stage'
      @currentApptScreen = new FullscreenStage
      @currentApptScreen.on 'close', => @_dismissCurrentAppointmentScreen()
      @currentApptScreen.setPanel(new AppointmentCardEdit apptId)
      @currentApptScreen.showInContext app.mainController.main
    , 0

  @_dismissCurrentAppointmentScreen: =>
    if @currentApptScreen
      @currentApptScreen.release()
      @currentApptScreen = null

  @_appointmentId: =>
    if Utils.isIOS()
      SettingsManager.getValueByKey @NAVIGATE_TO_APPOINTMENT_KEY
    else
      $.when window.callReportId

  @_resetAppointmentId: (apptId) =>
    if Utils.isIOS()
      SettingsManager.setValueByKey @NAVIGATE_TO_APPOINTMENT_KEY, ''
    else
      $.when -> window.callReportId = 0

module.exports = AlarmManager