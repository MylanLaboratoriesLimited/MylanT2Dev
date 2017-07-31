PanelScreen = require 'controllers/base/panel/panel-screen'
Header = require 'controls/header/header'
Utils = require 'common/utils'
ConfigurationManager = require 'db/configuration-manager'
PharmaEventsCollection = require 'models/bll/pharma-events-collection'
ProductsCollection = require 'models/bll/products-collection'
PePickListManager = require 'db/picklist-managers/pe-picklist-manager'
PharmaEvent = require 'models/pharma-event'
PEAttendeesCollection = require 'models/bll/pe-attendees-collection'
ContactsCollection = require 'models/bll/contacts-collection'
CommonInput = require 'controls/common-input/common-input'

class PeCardView extends PanelScreen
  className: 'pe-card pe-card-view'

  elements:
    '.owner': 'elOwner'
    '.event-type': 'elEventType'
    '.start-date': 'elStartDate'
    '.business-unit': 'elBusinessUnit'
    '.stage': 'elStage'
    '.end-date': 'elEndDate'
    '.event-name': 'elEventName'
    '.location': 'elLocation'
    '.products': 'elProducts'
    '.speakers': 'elSpeakers'
    '.agenda': 'elAgenda'
    '.objectives': 'elObjectives'
    '.evaluation': 'elEvaluation'
    '.attendees': 'elAttendees'
    '.scroll-content': 'elScrollContent'

  INPUT_DEFAULT_VALUE: ' '
  VIEW_COMMENT_LENGTH: 32000
  MAX_PRODUCTS_NUMBER: 4

  constructor: (@pharmaEventId) ->
    super
    @peCollection = new PharmaEventsCollection
    @productsCollection = new ProductsCollection
    @pePicklistManager = new PePickListManager
    @peAttendeesCollection = new PEAttendeesCollection
    @contactsCollection = new ContactsCollection

  active: ->
    super
    @render()

  render: ->
    @html @template()
    Locale.localize @el
    @_initHeader()
    @_fillInfo()
    @

  template: ->
    require('views/pe-card/pe-card')()

  _initHeader: ->
    peHeader = new Header Locale.value('card.PharmaEvent.HeaderTitle')
    peHeader.render()
    @setHeader peHeader

  _fillInfo: ->
    unless @pharmaEventId then @_fillDefaultInfo()
    else
      @peCollection.fetchEntityById(@pharmaEventId)
      .then (@pe) => @_fillGeneralInfo()

  _fillDefaultInfo: =>
    throw new Error "should be overridden"

  _fillGeneralInfo: =>
    @_initOwner()
    @_initEventType()
    @_initStartDate()
    @_initBusinessUnit()
    @_initStage()
    @_initEndDate()
    @_initEventName()
    @_initLocation()
    @_initProducts()
    @_initSpeakers()
    @_initAgenda()
    @_initObjectives()
    @_initEvaluation()
    @_initAttendees()

  _initOwner: ->
    @elOwner.html @pe.ownerFullName()

  _initEventType: ->
    @pePicklistManager.getLabelByValue(PharmaEvent.sfdc.eventType, @pe.eventType)
    .then (label) => @elEventType.html label

  _initStartDate: ->
    @startDate = Utils.originalDateTimeObject @pe.startDate
    @elStartDate.html Utils.formatDateTime @startDate

  _initBusinessUnit: ->
    @businessUnit = @pe.businessUnit
    @elBusinessUnit.html @businessUnit

  _initStage: ->
    @pePicklistManager.getLabelByValue(PharmaEvent.sfdc.stage, @pe.stage)
    .then (label) => @elStage.html label

  _initEndDate: ->
    @endDate = Utils.originalDateTimeObject @pe.endDate
    @elEndDate.html Utils.formatDateTime @endDate

  _initEventName: ->
    @_initCommonInput @elEventName, @pe?.eventName || @INPUT_DEFAULT_VALUE, @eventNameMaxLength

  _initCommonInput: (element, value, maxLength) =>
    element.val value or ''
    new CommonInput @elScrollContent[0], element[0], (if @cardType is 'view' then @VIEW_COMMENT_LENGTH else maxLength)
    element.on 'input', => @isChanged = true

  _initLocation: (defValue)->
    @_initCommonInput @elLocation, @pe?.location || @INPUT_DEFAULT_VALUE, @locationMaxLength

  _initProducts: ->
    productsIds = []
    _(@MAX_PRODUCTS_NUMBER).times (productNumber) => productsIds.push @pe["productPrio#{productNumber + 1}SfId"]
    @productsCollection.getProductsByIds(productsIds)
    .then (products) =>
      productsNames = products.map (product) => product.name
      @elProducts.html productsNames.join(', ')

  _initSpeakers: ->
    @_initCommonInput @elSpeakers, @pe?.speakers || @INPUT_DEFAULT_VALUE, @speakersMaxLength

  _initAgenda: ->
    @_initCommonInput @elAgenda, @pe?.agenda || @INPUT_DEFAULT_VALUE, @agendaMaxLength

  _initObjectives: ->
    @_initCommonInput @elObjectives, @pe?.objectives || @INPUT_DEFAULT_VALUE, @objectivesMaxLength

  _initEvaluation: ->
    @_initCommonInput @elEvaluation, @pe?.evaluation || @INPUT_DEFAULT_VALUE, @evaluationMaxLength

  _initAttendees: ->
    @attendees = []
    @attendeesIds = []
    if @pe
      @_loadAttendees()
      .then => @_showAttendees()
    else
      @elAttendees.html ''

  _loadAttendees: =>
    @pe.fetchNotDeletedPEAttendees()
    .then(@peAttendeesCollection.getAllEntitiesFromResponse)
    .then (@attendees) =>
      @attendeesIds = @attendees.map (attendee) -> attendee.attendeeSfId

  _showAttendees: =>
    contactsNames = []
    @attendeesIds.map (attendeeId) =>
      @contactsCollection.fetchEntityById(attendeeId)
      .then (contact) =>
        if contact?
          contactsNames.push contact.fullName()
          @elAttendees.html contactsNames.join ', '

module.exports = PeCardView