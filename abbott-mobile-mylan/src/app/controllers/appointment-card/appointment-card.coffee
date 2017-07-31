PanelScreen = require 'controllers/base/panel/panel-screen'
TableDatasource = require 'controls/table/table-data-source'
ReferencesCollection = require 'models/bll/references/references-collection'
CommentView = require 'controls/comment-view/comment-view'
ListPopup = require 'controls/popups/list-popup'
DurationFilter = require 'controls/filters/duration-filters/duration-filter'
DateTimePicker = require 'controls/datepicker/date-time-picker'
Utils = require 'common/utils'
ConfirmationPopup = require 'controls/popups/confirmation-popup'
Users = require 'controllers/users/users'
CallReport = require 'models/call-report'
AppointmentsCollection = require 'models/bll/call-reports-collection/appointments-collection'
JointVisitPickListDatasource = require 'controllers/call-report-card/joint-visit-picklist-datasource'
ConfigurationManager = require 'db/configuration-manager'
PickList = require 'controls/pick-list/pick-list'
SforceDataContext = require 'models/bll/sforce-data-context'
CommonInput = require 'controls/common-input/common-input'
AlarmManager = require 'common/alarm/alarm-manager'
HeaderBaseControl = require 'controls/header-controls/header-base-control'
Header = require 'controls/header/header'

class AppointmentsCard extends PanelScreen
  className: 'appointment card'

  events:
    'tap .appointments-card-customer': '_onCustomerTap'
    'tap .appointments-card-organization': '_onOrganizationTap'

  elements:
    '.appointments-card-customer': 'elCustomer'
    '.appointments-card-organization': 'elOrganization'
    '.appointments-card-speciality': 'elSpecialty'
    '.appointments-card-user': 'elUser'
    '.appointments-card-date-time': 'elDateTime'
    '.appointments-card-duration ': 'elDuration'
    '.call-comments': 'elComment'
    '.appointments-card-joint-visit': 'elJointVisit'
    '.appointments-card-joint-visit-user': 'elJointVisitUser'
    '.wrapper': 'elWrapper'

  maxCommentStringLength: 32000
  isChanged: false
  appointmentRecordTypeId: null

  template: ->
    require('views/appointment-card/appointment-card')()

  constructor: (@referenceId) ->
    super

  active: =>
    super
    @_resetChangeFlags()
    ConfigurationManager.getConfig()
    .then (config) =>
      @appointmentRecordTypeId = config.appointmentRecordTypeId
      @_init()

  _enableInputs: =>
    setTimeout =>
      @elComment.attr("disabled",false)
    , @effectDefaults.duration

  _resetChangeFlags: =>
    @isChanged = false

  _init: ->
    @appointment = null
    @render()
    @_setCommonInput ''
    @_bindEvents()
    @_initJointVisitPickList()
    @_initDurationFilter()
    .then =>
      @_initDateTime()
      @isAppointmentsChanged = false
      @jointVisitUser = null

  _setCommonInput: (value)->
    @elComment.val value
    new CommonInput @elWrapper[0], @elComment[0]
    @elComment.on 'change', @_appointmentChanged

  render: ->
    @html @template()
    @_initHeader()
    Locale.localize @el
    @_fillGeneralInfo()
    @_enableInputs()
    @

  _onCustomerTap: =>
    ContactCard = require 'controllers/contact-card/contact-card'
    @stage.push(new ContactCard @reference.contactSfId)

  _onOrganizationTap: =>
    OrganizationCard = require 'controllers/organization-card/organization-card'
    @stage.push(new OrganizationCard @reference.organizationSfId)

  _onJointVisitUserTap: =>
    users = new Users @jointVisitUser
    users.on 'onClose', (user) =>
      if user
        @elJointVisitUser.html user.fullName()
        @jointVisitUser = user
        @elJointVisitUser.removeClass 'placeholder'
      else
        @elJointVisitUser.html Locale.value('card.GeneralInfoFields.JointVisitUserPlaceholder')
        @jointVisitUser = null
        @elJointVisitUser.addClass 'placeholder'
      @_appointmentChanged()
    @stage.push users

  _fillGeneralInfo: ->
    @_setActiveUser()
    .then =>
      collection = new ReferencesCollection
      collection.fetchEntityById(@referenceId)
    .then (@reference) =>
      @elCustomer.html "#{@reference.contactFullName()} <br/> #{@reference.contactRecordType}"
      @elOrganization.html @reference.organizationNameAndAddress()
      @elDateTime.html Utils.currentDateTime()
      @reference.getContact()
    .then (contact) =>
      @elSpecialty.html contact.abbottSpecialty

  _setActiveUser: =>
    SforceDataContext.activeUser()
    .then (@activeUser) => @elUser.html @activeUser?.fullName()

  onBack: =>
    unless @isChanged then super
    else
      confirm = new ConfirmationPopup {caption: Locale.value('card.ConfirmationPopup.SaveChanges.Caption')}
      confirm.bind 'yesClicked', =>
        @dismissModalController()
        @_onSaveTap()
      confirm.bind 'noClicked', =>
        @dismissModalController()
        @isChanged = false
        super
      @presentModalController confirm

  _initHeader: ->
    @saveBtn = new HeaderBaseControl Locale.value('common:buttons.SaveBtn'), 'ctrl-btn'
    @saveBtn.bind 'tap', @_onSaveTap
    apptHeader = new Header Locale.value('card.Appointment.HeaderTitle')
    apptHeader.render()
    apptHeader.addRightControlElement @saveBtn.el
    @setHeader apptHeader

  _onSaveTap: =>
    @_saveAppointment()
    .then(@_resetChangeFlags)
    .then(=> @postNotification 'appointmentChanged')
    .then(@onBack)

  _bindEvents: ->
    @elDuration.on 'tap', @_onDurationTap
    @elDateTime.on 'tap', @_showDateTimePicker
    @elJointVisitUser.on 'tap', @_onJointVisitUserTap

  _onDurationTap: =>
    DurationFilter.resources()
    .then (resources)=>
      datasource = resources
      filterPopup = new ListPopup datasource, @durationFilter, Locale.value('card.DurationPopup.Title')
      filterPopup.bind 'onPopupItemSelected', (selectedItem) =>
        @durationFilter = selectedItem.model
        @elDuration.html @durationFilter.value
        @dismissModalController()
        @duration = @durationFilter.value
        @_appointmentChanged()
      @presentModalController filterPopup

  _setDateTime: (result) =>
    @originDateTime = result
    @elDateTime.html Utils.currentDateTime result
    @_appointmentChanged()

  _initJointVisitPickList: =>
    @jointVisitPickList = new PickList @, @elJointVisit, new JointVisitPickListDatasource, @appointment?.jointVisit or null
    @jointVisitPickList.bind 'onPickListItemSelected', @_appointmentChanged

  _initDurationFilter: =>
    DurationFilter.resources()
    .then (resources)=>
      @durationFilter = resources.defaultValue
      @elDuration.html @durationFilter.value
      @duration = @durationFilter.value

  _showDateTimePicker: =>
    @originDateTime = new Date() unless @originDateTime
    dateTimePicker = new DateTimePicker @originDateTime, { beforeDays: 0, afterDays: 90 }
    dateTimePicker.on 'onDonePressed', (dateTime) =>
      @dismissModalController()
      @_setDateTime dateTime
    @presentModalController dateTimePicker

  _initDateTime: ->
    @originDateTime = new Date

  jointVisitValid: ->
    @_jointVisitValue() isnt null

  _jointVisitValue: ->
    @jointVisitPickList.selectedValue

  _jointVisitUserId: ->
    @jointVisitUser?.id ? null

  _defaultJointVisitFilterValue: ->
    @_defaultJointVisitFilter().description

  _validateDate: ->
    currentDate = new Date
    @originDateTime.getFullYear() > currentDate.getFullYear() or
    @originDateTime.getMonth() > currentDate.getMonth() or
    (@originDateTime.getMonth() is currentDate.getMonth() and @originDateTime.getDate() >= currentDate.getDate())

  _validData: ->
    isDataValid = true
    if not @jointVisitUser and @jointVisitValid()
      toastMessage = Locale.value('card.ToastMessage.RequiredFieldsHeader') + ":<br/> " + Locale.value('card.ToastMessage.RequiredJointVisitUser')
      isDataValid = false
    if @jointVisitUser and not @jointVisitValid()
      toastMessage = Locale.value('card.ToastMessage.RequiredFieldsHeader') + ":<br/> " + Locale.value('card.ToastMessage.RequiredJointVisit')
      isDataValid = false
    unless @_validateDate()
      toastMessage = Locale.value('card.Appointment.ToastMessage.DateLessThanNow')
      isDataValid = false
    $.fn.dpToast toastMessage unless isDataValid
    isDataValid

  _checkExistingAppointments: ->
    @appointmentsCollection = new AppointmentsCollection
    @appointmentsCollection.getAllAppointmentsFor(@reference, @originDateTime)

  _saveAppointment: =>
    deferred = new $.Deferred()
    unless @_validData() then deferred.reject()
    else
      @_checkExistingAppointments()
      .then (existingAppointments) =>
        unless existingAppointments.length > 0 then @_save()
        else
          @appointment = _.first existingAppointments
          @_showMessageAboutExistingCallReport()
      .then => deferred.resolve()
    deferred.promise()

  _showMessageAboutExistingCallReport: ->
    deferred = new $.Deferred()
    confirm = new ConfirmationPopup { caption: Locale.value('card.Appointment.ConfirmationPopup.ReplaceExistingAppointment.Caption'), message: Locale.value('card.Appointment.ConfirmationPopup.ReplaceExistingAppointment.Question', { postProcess: "sprintf"}) }
    confirm.bind 'yesClicked', =>
      @dismissModalController()
      @_save().then => deferred.resolve()
    confirm.bind 'noClicked', =>
      @dismissModalController()
      @appointment = null
      @_save().then => deferred.resolve()
    @presentModalController confirm
    deferred.promise()

  _appointmentChanged: =>
    @isChanged = true

  _save: =>
    shouldCreateNew = false
    unless @appointment
      shouldCreateNew = true
      @appointment = {}
    @appointment[CallReport.sfdc.createdOffline] = true
    @appointment[CallReport.sfdc.dateTimeOfVisit] = Utils.originalDateTime @originDateTime
    @appointment[CallReport.sfdc.dateOfVisit] = Utils.originalDate @originDateTime
    @appointment[CallReport.sfdc.organizationSfId] = @reference.organizationSfId
    @appointment[CallReport.sfdc.remoteOrganizationName] = @reference.organizationName
    @appointment.organizationName = @reference.organizationName
    @appointment[CallReport.sfdc.organizationCity] = @reference.organizationCity
    @appointment[CallReport.sfdc.organizationAddress] = @reference.organizationAddress
    @appointment[CallReport.sfdc.contactSfid] = @reference.contactSfId
    @appointment[CallReport.sfdc.remoteContactFirstName] = @reference.contactFirstName
    @appointment[CallReport.sfdc.remoteContactLastName] = @reference.contactLastName
    @appointment.contactFirstName = @reference.contactFirstName
    @appointment.contactLastName = @reference.contactLastName
    @appointment[CallReport.sfdc.contactRecordType] = @reference.contactRecordType
    @appointment[CallReport.sfdc.userFirstName] = @activeUser.firstName
    @appointment[CallReport.sfdc.userLastName] = @activeUser.lastName
    @appointment[CallReport.sfdc.userSfid] = @activeUser.id
    @appointment[CallReport.sfdc.duration] = @duration
    @appointment[CallReport.sfdc.type] = CallReport.TYPE_APPOINTMENT
    @appointment[CallReport.sfdc.recordTypeId] = @appointmentRecordTypeId
    @appointment[CallReport.sfdc.jointVisit] = @_jointVisitValue()
    @appointment[CallReport.sfdc.jointVisitUserSfid] = @_jointVisitUserId()
    @appointment[CallReport.sfdc.generalComments] = @elComment[0].getValue()
    @appointment['attributes'] = {type: CallReport.table}
    if shouldCreateNew
      @appointmentsCollection.createEntity(@appointment).then -> AlarmManager.scheduleNextVisits()
    else
      @appointmentsCollection.updateEntity(@appointment).then -> AlarmManager.scheduleNextVisits()

module.exports = AppointmentsCard