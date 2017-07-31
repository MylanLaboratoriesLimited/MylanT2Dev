Spine = require 'spine'
SforceDataContext = require 'models/bll/sforce-data-context'
Utils = require 'common/utils'
ConfigurationManager = require 'db/configuration-manager'
PeCardView = require 'controllers/pe-card/pe-card-view'
CommentInput = require 'controls/comment-view/comment-input'
MultiselectPopup = require 'controls/popups/multiselect-popup'
PEAttendee = require 'models/pe-attendee'
PharmaEvent = require 'models/pharma-event'
DateTimePicker = require 'controls/datepicker/date-time-picker'
DateTimePickerExtended = require 'controls/datepicker/date-time-picker-extended'
EventTypePickListDatasource = require 'controllers/pe-card/event-type-picklist-datasource'
StagePickListDatasource = require 'controllers/pe-card/stage-picklist-datasource'
PickList = require 'controls/pick-list/pick-list'
ConfirmationPopup = require 'controls/popups/confirmation-popup'
HeaderBaseControl = require 'controls/header-controls/header-base-control'
Header = require 'controls/header/header'
Attendees = require 'controllers/attendees/attendees'

class PeCardCreate extends PeCardView
  className: 'pe-card pe-cart-create'

  speakersMaxLength: 1000
  agendaMaxLength: 32000
  objectivesMaxLength: 32000
  evaluationMaxLength: 32000
  eventNameMaxLength: 80
  locationMaxLength: 255
  daysMax: 13
  daysAfter: 90

  events:
    'tap .start-date': '_onStartDate'
    'tap .end-date': '_onEndDate'
    'tap .attendees' : '_onAttendeesTap'

  INPUT_DEFAULT_VALUE: ''

  active: ->
    @_resetChangeFlags()
    super

  _resetChangeFlags: =>
    @isChanged = false
    @isAttendeesWereChanged = false

  _initHeader: ->
    saveBtn = new HeaderBaseControl Locale.value('common:buttons.SaveBtn'), 'ctrl-btn'
    saveBtn.bind 'tap', @_onSaveTap
    peHeader = new Header Locale.value('card.PharmaEvent.CreateCardHeaderTitle')
    peHeader.render()
    peHeader.addRightControlElement saveBtn.el
    @setHeader peHeader

  _onSaveTap: =>
    if @_isDataValid()
      @_savePe()
      .then(@_resetChangeFlags)
      .then(=> @trigger 'pharmaEventChanged')
      .then(@onBack)
    else
      @_showToast @_fillToastBody()

  _isDataValid: ->
    equivalents = @_getEquivalents()
    not Object.keys(equivalents).some (key) -> not equivalents[key]

  _getEquivalents: ->
    'TypeOfEvent': @eventType.selectedValue
    'EventName': @_getInputValue @elEventName
    'Location': @_getInputValue @elLocation
    'Products': (not _.isEmpty @selectedProducts)
    'Speakers': @_getInputValue @elSpeakers
    'Agenda': @_getInputValue @elAgenda
    'Objectives': @_getInputValue @elObjectives

  _savePe: ->
    @pePicklistManager.getPickList PharmaEvent.sfdc.status
    .then (picklist) =>
      status = picklist.shift().value
      peNewEntity = {}
      peNewEntity[PharmaEvent.sfdc.createdOffline] = true
      peNewEntity[PharmaEvent.sfdc.ownerSfid] = @user.id
      peNewEntity[PharmaEvent.sfdc.remoteOwnerFirstName] = @user.firstName
      peNewEntity[PharmaEvent.sfdc.remoteOwnerLastName] = @user.lastName
      peNewEntity.ownerFirstName = @user.firstName
      peNewEntity.ownerLastName = @user.lastName
      peNewEntity[PharmaEvent.sfdc.eventName] = @_getInputValue @elEventName
      peNewEntity[PharmaEvent.sfdc.eventType] = @eventType.selectedValue
      peNewEntity[PharmaEvent.sfdc.location] = @_getInputValue @elLocation
      peNewEntity[PharmaEvent.sfdc.startDate] = Utils.originalDateTime @startDate
      peNewEntity[PharmaEvent.sfdc.endDate] = Utils.originalDateTime @endDate
      peNewEntity[PharmaEvent.sfdc.stage] = @stagePicklist.selectedValue
      peNewEntity[PharmaEvent.sfdc.status] = status
      peNewEntity[PharmaEvent.sfdc.businessUnit] = @businessUnit
      peNewEntity[PharmaEvent.sfdc.objectives] = @_getInputValue @elObjectives
      peNewEntity[PharmaEvent.sfdc.agenda] = @_getInputValue @elAgenda
      peNewEntity[PharmaEvent.sfdc.speakers] = @_getInputValue @elSpeakers
      peNewEntity[PharmaEvent.sfdc.evaluation] = @_getInputValue @elEvaluation
      @_setProducts peNewEntity, true
      @peCollection.createEntity(peNewEntity)
      .then (peNewEntity) => @_setAttendees peNewEntity

  _setProducts: (entity, isCreate) =>
    _(@MAX_PRODUCTS_NUMBER).times (productNumber) =>
      productField = "productPrio#{productNumber + 1}SfId"
      productField = PharmaEvent.sfdc["productPrio#{productNumber + 1}SfId"] if isCreate
      if @selectedProducts[productNumber]
        entity[productField] = @selectedProducts[productNumber].id
      else
        entity[productField] = null

  _setAttendees: (pharmaEvent) ->
    if @isAttendeesWereChanged
      pharmaEventEntity = @peCollection.parseEntity pharmaEvent
      @_updateAttendeesCollectionForPE pharmaEventEntity

  _updateAttendeesCollectionForPE: (pharmaEvent) =>
    @_removeAllAttendees(@attendees)
    .then =>
      Utils.runSimultaneously _(@attendeesIds).map (attendeeId) => @_createNewAttendee(attendeeId, pharmaEvent)

  _removeAllAttendees: (attendees) =>
    Utils.runSimultaneously _(attendees).map (attendee) =>
      @peAttendeesCollection.removeEntity attendee

  _createNewAttendee: (attendeeId, pharmaEvent) =>
    newAttendee = {}
    newAttendee[PEAttendee.sfdc.attendeeSfId] = attendeeId
    newAttendee[PEAttendee.sfdc.pharmaEventSfId] = pharmaEvent.attributes._soupEntryId
    @peAttendeesCollection.createEntity newAttendee

  _showToast: (toastBody) ->
    toastHeader = Locale.value('card.ToastMessage.RequiredFieldsHeader')+ ": <br/>"
    toastMessage = toastHeader + toastBody
    $.fn.dpToast toastMessage if toastBody

  _fillToastBody: ->
    equivalents = @_getEquivalents()
    Object.keys(equivalents).filter((key) -> not equivalents[key])
    .map((key) -> Locale.value('card.PharmaEvent.ToastMessage.Required' + key))
    .join '<br/>'

  onBack: =>
    unless @isChanged then super
    else
      confirm = new ConfirmationPopup {caption: Locale.value('card.ConfirmationPopup.SaveChanges.Caption')}
      confirm.bind 'yesClicked', =>
        @dismissModalController()
        @_onSaveTap()
      confirm.bind 'noClicked', =>
        @isChanged = false
        @dismissModalController()
        super
      @presentModalController confirm

  _fillDefaultInfo: =>
    @_initUser()
    @_initEventType()
    @_initDefaultStartDate()
    @_initStage()
    @_initDefaultEndDate()
    @_initEventName()
    @_initLocation()
    @_initProducts()
    @_initSpeakers()
    @_initAgenda()
    @_initObjectives()
    @_initEvaluation()
    @_initDefaultAttendees()

  _initUser: =>
    SforceDataContext.activeUser()
    .then (@user) =>
      @_initDefaultOwner()
      @_initDefaultBusinessUnit()

  _initDefaultOwner: =>
    @elOwner.html @user?.fullName()

  _initDefaultBusinessUnit: =>
    @businessUnit = @user?.businessUnit
    @elBusinessUnit.html @businessUnit

  _initEventType: =>
    @eventType = new PickList @, @elEventType, new EventTypePickListDatasource, @pe?.eventType or null
    @eventType.bind 'onPickListItemSelected', => @isChanged = true

  _initDefaultStartDate: =>
    @startDate = new Date
    @elStartDate.html Utils.formatDateTime @startDate

  _initStage: =>
    @stagePicklist = new PickList @, @elStage, new StagePickListDatasource, @pe?.stage or null
    @stagePicklist.bind 'onPickListItemSelected', => @isChanged = true

  _initDefaultEndDate: =>
    @endDate = new Date
    @elEndDate.html Utils.formatDateTime @endDate

  _initProducts: =>
    @_initProductsDatasource().then @_renderProducts
    @elProducts.on 'tap', @_openProductsPopup

  _initProductsDatasource: =>
    @productsCollection.getPromotedProducts()
    .then (products) =>
      @productsDatasource = products.map (product) => id: product.id, description: product.name
      @selectedProducts = []

  _renderProducts: =>
    products = (@selectedProducts.map (product) => product.description).join ', '
    if products
      @elProducts.removeClass 'placeholder'
      @elProducts.html products
    else
      @elProducts.addClass 'placeholder'
      @elProducts.html Locale.value('card.PharmaEvent.Placeholders.AddProducts')

  _openProductsPopup: =>
    unless _.isEmpty @productsDatasource
      multiselectPopup = new MultiselectPopup @productsDatasource, @selectedProducts, Locale.value('card.PharmaEvent.ProductsPopupCaption')
      multiselectPopup.bind 'onPopupItemsUpdated', @_renderSelectedProducts
      multiselectPopup.on 'doneTap', @dismissModalController
      @presentModalController multiselectPopup

  _renderSelectedProducts: (@selectedProducts) =>
    @isChanged = true
    @_renderProducts()

  _initDefaultAttendees: ->
    @attendees = []
    @attendeesIds = []
    @elAttendees.html @_attendeesPlaceholder()
    @elAttendees.addClass 'placeholder'

  _onAttendeesSelected: (@attendeesIds) =>
    @isChanged = true
    @isAttendeesWereChanged = true
    if @attendeesIds.length
      @elAttendees.removeClass 'placeholder'
      @_showAttendees()
    else
      @elAttendees.addClass 'placeholder'
      @elAttendees.html @_attendeesPlaceholder()

  _attendeesPlaceholder: ->
    Locale.value('card.PharmaEvent.Placeholders.AddAttendees')

  _onStartDate: =>
    @_showStartDateTimePicker @startDate, @_setStartDate

  _onEndDate: =>
    @_showEndDateTimePicker @endDate, @_setEndDate

  _setStartDate: (value) =>
    @startDate = value
    @elStartDate.html Utils.formatDateTime value
    @isChanged = true if value
    daysBetween = Utils.getDaysBetween(@startDate, @endDate)
    if daysBetween < 0
      @_setEndDate(value)
    if daysBetween > @daysMax
      latestDate = new Date(value)
      latestDate.setDate(latestDate.getDate() + @daysMax)
      @_setEndDate(latestDate)

  _setEndDate: (value) =>
    @endDate = value
    @elEndDate.html Utils.formatDateTime value
    @isChanged = true if value

  # _showDatePicker: (handler, field, isEndDate=false) =>
  #   unless field then field = new Date()
  #   limitations = unless isEndDate
  #     {beforeDays: 14, afterDays: 90}
  #   else
  #     startDate = new Date @startDate.getFullYear(), @startDate.getMonth(), @startDate.getDate()
  #     daysBetween = Utils.getDaysBetween(startDate, @endDate)
  #     {beforeDays: daysBetween, afterDays: @daysMax}
  #   dateTimePicker = unless isEndDate then new DateTimePicker(field, limitations) else new DateTimePickerExtended(@endDate, limitations)
  #   dateTimePicker.on 'onDonePressed', (selectedDate) =>
  #     @_handleDoneBtnPressed(selectedDate, isEndDate, handler)
  #   @presentModalController dateTimePicker

  _showStartDateTimePicker: (date, handler) =>
    dateTimePicker = new DateTimePicker date, { beforeDays: 14, afterDays: 90 }
    dateTimePicker.on 'onDonePressed', (selectedDate) =>
      @dismissModalController()
      handler selectedDate
    @presentModalController dateTimePicker

  _showEndDateTimePicker: (date, handler) =>
    startDate = new Date @startDate.getFullYear(), @startDate.getMonth(), @startDate.getDate()
    daysBetween = Utils.getDaysBetween(startDate, @endDate)
    dateTimePicker = new DateTimePickerExtended @endDate, {beforeDays: daysBetween, afterDays: @daysMax}
    dateTimePicker.on 'onDonePressed', (selectedDate) =>
      @_handleEndDateEntered selectedDate, handler
    @presentModalController dateTimePicker

  # _handleDoneBtnPressed: (date, isEndDate, handler) ->
  #   #getting date with out seconds
  #   endDate = new Date date.getFullYear(), date.getMonth(), date.getDate(), date.getHours(), date.getMinutes()
  #   startDate = new Date @startDate.getFullYear(), @startDate.getMonth(), @startDate.getDate(), @startDate.getHours(), @startDate.getMinutes()

  #   if isEndDate and endDate < startDate
  #     $.fn.dpToast Locale.value('card.PharmaEvent.EndDateLessStartError')
  #   else
  #     @dismissModalController()
  #     handler date

  _handleEndDateEntered: (date, handler) =>
    endDate = Utils.dateTimeWithoutSeconds date
    startDate = Utils.dateTimeWithoutSeconds @startDate
    if endDate < startDate
      $.fn.dpToast Locale.value('card.PharmaEvent.EndDateLessStartError')
    else
      @dismissModalController()
      handler date

  _onAttendeesTap: =>
    attendees = new Attendees @attendeesIds
    attendees.on 'attendeesSelected', @_onAttendeesSelected
    @stage.push(attendees)

  _getInputValue: (input) =>
    if input.hasClass('placeholder-mode') then null else input.val()

module.exports = PeCardCreate