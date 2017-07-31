Spine = require 'spine'
Utils = require 'common/utils'
ConfigurationManager = require 'db/configuration-manager'
PeCardCreate = require 'controllers/pe-card/pe-card-create'

class PeCardEdit extends PeCardCreate
  className: 'pe-card pe-cart-edit'

  _initHeader: =>
    super
    @header.find('.title').html Locale.value('card.PharmaEvent.HeaderTitle')

  _initProducts: =>
    @_initProductsDatasource()
    .then =>
      _(@MAX_PRODUCTS_NUMBER).times (productNumber) =>
        product = @productsDatasource.filter (productModel) => productModel.id is @pe["productPrio#{productNumber + 1}SfId"]
        @selectedProducts.push _.first product if product.length is 1
      @_renderProducts()
    @elProducts.on 'tap', @_openProductsPopup

  _showAttendees: ->
    super
    if @attendeesIds.length
      @elAttendees.removeClass 'placeholder'
    else
      @elAttendees.addClass 'placeholder'
      @elAttendees.html @_attendeesPlaceholder()

  _savePe: ->
    @pe.eventName = @_getInputValue @elEventName
    @pe.createdOffline = true
    @pe.eventType = @eventType.selectedValue
    @pe.location = @_getInputValue @elLocation
    @pe.startDate = Utils.originalDateTime @startDate
    @pe.endDate = Utils.originalDateTime @endDate
    @pe.stage = @stagePicklist.selectedValue
    @pe.objectives = @_getInputValue @elObjectives
    @pe.agenda = @_getInputValue @elAgenda
    @pe.speakers = @_getInputValue @elSpeakers
    @pe.evaluation = @_getInputValue @elEvaluation
    @_setProducts @pe
    @peCollection.updateEntity(@pe)
    .then (entity) => @_setAttendees entity

module.exports = PeCardEdit