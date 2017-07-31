AppointmentCard = require 'controllers/appointment-card/appointment-card'
AppointmentsCollection = require 'models/bll/call-reports-collection/appointments-collection'
Utils = require 'common/utils'
DurationFilter = require 'controls/filters/duration-filters/duration-filter'
CallReport = require 'models/call-report'
ConfirmationPopup = require 'controls/popups/confirmation-popup'
SforceDataContext = require 'models/bll/sforce-data-context'
ConfigurationManager = require 'db/configuration-manager'
AlarmManager = require 'common/alarm/alarm-manager'
HeaderBaseControl = require 'controls/header-controls/header-base-control'
Header = require 'controls/header/header'
ConvertCallReport = require 'controllers/call-report-card/convert-call-report'
Utils = require 'common/utils'

class AppointmentCardEdit extends AppointmentCard
  maxDays: 14
  collection: null

  constructor: (@appointmentId) ->
    super
    @collection = new AppointmentsCollection
    @subscribeOnNotification 'appointmentChanged', @reload

  reload: =>
    @_fetchAppointmentById(@appointmentId)
    .then (appt) =>
      if appt then @active()
      else
        delayTime = if Utils.isIOS() then @effectDefaults.duration else @effectDefaults.duration+100
        _.delay @onBack, delayTime

  _fetchAppointmentById: (apptId) =>
    keyValue = {}
    keyValue[CallReport.sfdc.id] = apptId
    @collection.fetchAllWhere(keyValue)
    .then (response) =>
      @collection.getEntityFromResponse response

  shouldDeferNotification: (notification) =>
    true

  _init: ->
    @_setLimitation()
    .then =>
      @render()
      @_bindEvents()

  _setLimitation: =>
    SforceDataContext.activeUser()
    .then (user) =>
      unless user.callReportValidationExcempted
        ConfigurationManager.getConfig('callReportValidationSettings')
        .then (dateRangeConfig) =>
          @maxDays = dateRangeConfig.daysCallReport if dateRangeConfig?.daysCallReport

  _initHeader: ->
    @saveBtn = new HeaderBaseControl Locale.value('common:buttons.SaveBtn'), 'ctrl-btn'
    @saveBtn.bind 'tap', @_onSaveTap
    deleteBtn = new HeaderBaseControl Locale.value('common:buttons.DeleteBtn'), 'ctrl-btn red'
    deleteBtn.bind 'tap', @_onDeleteTap
    convertBtn = new HeaderBaseControl Locale.value('card.Appointment.ConvertBtn'), 'ctrl-btn'
    convertBtn.bind 'tap', @_onConvertTap
    apptHeader = new Header Locale.value('card.Appointment.HeaderTitle')
    apptHeader.render()
    apptHeader.addRightControlElement deleteBtn.el
    apptHeader.addRightControlElement convertBtn.el
    apptHeader.addRightControlElement @saveBtn.el
    @setHeader apptHeader

  _onDeleteTap: =>
    confirm = new ConfirmationPopup { caption: Locale.value('card.Appointment.ConfirmationPopup.DeleteItem.Caption'), message: Locale.value('card.ConfirmationPopup.DeleteItem.Question') }
    confirm.bind 'yesClicked', @_onDeleteApprove
    confirm.bind 'noClicked', @_onDeleteDiscard
    @presentModalController confirm

  _onDeleteApprove: (confirm) =>
    @dismissModalController()
    @collection.removeEntity(@appointment)
    .then =>
      AlarmManager.scheduleNextVisits()
      @postNotification 'appointmentChanged'
      @isChanged = false
      @onBack()

  _onDeleteDiscard: (confirm) =>
    @dismissModalController()

  _onConvertTap: =>
    if @isChanged
      @_showConvertConfirmationPopup()
    else
      @_goToConvertView()

  _showConvertConfirmationPopup: =>
    confirm = new ConfirmationPopup { caption: Locale.value('card.Appointment.ConfirmationPopup.SaveChangesBeforeConverting.Caption') }
    confirm.bind 'yesClicked', =>
      @dismissModalController()
      @_saveAppointment()
      .done @_goToConvertView
    confirm.bind 'noClicked', =>
      @_initDateTime()
      @dismissModalController()
      @_goToConvertView()
    @presentModalController confirm

  _saveAppointment: =>
    deferred = new $.Deferred()
    if @_validData()
      @_save().then => deferred.resolve()
    else
      deferred.reject()
    deferred.promise()

  _save: ->
    @appointment.createdOffline = true
    @appointment.dateTimeOfVisit = Utils.originalDateTime @originDateTime
    @appointment.dateOfVisit = Utils.originalDate @originDateTime
    @appointment.duration = @duration
    @appointment.jointVisit = @_jointVisitValue()
    @appointment.generalComments = @elComment[0].getValue()
    @appointment.jointVisitUserSfid = @_jointVisitUserId()
    @collection.updateEntity(@appointment).then => 
      AlarmManager.scheduleNextVisits()
      @postNotification 'appointmentChanged'

  _goToConvertView: =>
    unless @_validatePastDateForConvert()
      $.fn.dpToast Locale.value('card.Appointment.ToastMessage.DateTooFarInThePast')
    else unless @_validateFutureDateForConvert()
      $.fn.dpToast Locale.value('card.Appointment.ToastMessage.DateGreaterThanNow')
    else
      callReportCard = new ConvertCallReport @appointmentId
      @stage.popAndPush(callReportCard)

  _validatePastDateForConvert: ->
    currentDateTime = new Date
    currentDate = new Date currentDateTime.getFullYear(), currentDateTime.getMonth(), currentDateTime.getDate()
    originDate =  new Date @originDateTime.getFullYear(), @originDateTime.getMonth(), @originDateTime.getDate()
    Utils.getDaysBetween(originDate, currentDate) <= @maxDays

  _validateFutureDateForConvert: ->
    currentDate = new Date
    @originDateTime.getFullYear() < currentDate.getFullYear() or
    @originDateTime.getMonth() < currentDate.getMonth() or
    (@originDateTime.getMonth() is currentDate.getMonth() and @originDateTime.getDate() <= currentDate.getDate())

  _initDateTime: ->
    @originDateTime = Utils.originalDateTimeObject @appointment.dateTimeOfVisit
    @elDateTime.html Utils.formatDateTime @appointment.dateTimeOfVisit

  _fillGeneralInfo: =>
    @_fetchAppointmentById(@appointmentId)
    .then (@appointment) =>
      if @appointment
        @elCustomer.html "#{@appointment.contactFullName()} <br/> #{@appointment.contactRecordType}"
        @elOrganization.html @appointment.organizationNameAndAddress()
        @_initDateTime()
        @_initDurationFilter()
        .then =>
          @_initJointVisitPickList()
          @_fillJointVisitUser()
          @_setCommonInput @appointment.generalComments ? ''
          @appointment.getSpecialty()
          .then (specialty) => @elSpecialty.html specialty
    .then @_setActiveUser

  _parseAppointment: (appointment) ->
    @collection.parseEntity appointment

  _initDurationFilter: ->
    if @appointment.duration and @appointment.duration.length isnt 0
      DurationFilter.resources()
      .then (resources)=>
        @durationFilter = resources.filter((item) => item.value is parseInt @appointment.duration)[0]
        @duration = @durationFilter?.value ? resources.defaultValue
        @elDuration.html @duration
    else
      $.when()

  _fillJointVisitUser: ->
    @jointVisitUser = null
    @appointment.getJointVisitUser()
    .then (@jointVisitUser) => @elJointVisitUser.html @jointVisitUser?.fullName()

  _onCustomerTap: =>
    ContactCard = require 'controllers/contact-card/contact-card'
    @stage.push(new ContactCard @appointment.contactSfid)

  _onOrganizationTap: =>
    OrganizationCard = require 'controllers/organization-card/organization-card'
    @stage.push(new OrganizationCard @appointment.organizationSfId)

module.exports = AppointmentCardEdit