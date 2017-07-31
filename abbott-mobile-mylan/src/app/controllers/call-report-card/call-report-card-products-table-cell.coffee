Spine = require 'spine'
CommonInput = require 'controls/common-input/common-input'
ListPopup = require 'controls/popups/list-popup'
Locale = require 'common/localization/locale'

# TODO: VERY UGLY !!!
# TODO: REFACTOR !!!
class CallReportCardProductsTableCell extends Spine.Controller
  tag: 'tbody'

  events:
    'tap .call-report-card-expand-btn': '_onExpandTap'
    'tap .call-report-card-product-list-btn': '_onProductTap'
    'tap .call-report-card-message-list-btn.message-1': '_onMessage1Tap'
    'tap .call-report-card-message-list-btn.message-2': '_onMessage2Tap'
    'tap .call-report-card-message-list-btn.message-3': '_onMessage3Tap'
    'change .product-promotion-item input': '_onPromotionalChange'

  elements:
    '.call-report-card-product-list-btn': 'elProductListBtn'
    '.call-report-card-product-comment': 'elProductComment'
    '.call-report-card-message-list-btn.message-1': 'elProductMessage1'
    '.call-report-card-message-list-btn.message-2': 'elProductMessage2'
    '.call-report-card-message-list-btn.message-3': 'elProductMessage3'
    '.td-content-wrapper': 'elExpandBlock'
    '.product-expand-wrapper': 'elExpandWrapper'
    '.promotion-item': 'elPromotional'
    '.product-general-block': 'elGeneralBlock'

  maxCommentStringLength: 255

  constructor: (@datasource) ->
    #@datasource.productsWithMessages - main array with products and messages
    super {}
    @productId = null
    @productComment = null
    @productMessage1 = null
    @productMessage2 = null
    @productMessage3 = null
    @_currentFilter = null
    @isPromotional = false

  render: ->
    @html @template()
    @_prepareProducts()
    @_prepareMessages()
    Locale.localize @el
    @

  template: ->
    require('views/call-report-card/call-report-card-products-table-cell')()

  _prepareProducts: =>
    @_products = []
    noneValue = @_filterResource null, Locale.value('common:defaultSelectValue')
    @elProductListBtn.html noneValue.description
    @_prepareMessages()
    @_products.push noneValue
    @datasource.productsWithMessages.forEach (productWithMessage) =>
      @_products.push @_filterResource(productWithMessage.product.id, productWithMessage.product.name)

  _filterResource: (id, description) =>
    id: id
    description: description

  _prepareMessages: =>
    @_messages = []
    noneValue = @_filterResource(null, Locale.value('common:defaultSelectValue'))
    _(3).times (index) =>
      ++index
      @['message' + index + 'Model'] = noneValue
      @['elProductMessage' + index].html noneValue.description
    @_messages.push(noneValue)
    messages = @datasource.productsWithMessages.filter (productWithMessage) =>
      productWithMessage.product.id is @productId
    if messages.length is 1
      messages[0].messages.forEach (message) =>
        @_messages.push @_filterResource(message.id, message.name)

  _onExpandTap: =>
    @el.toggleClass 'expanded'
    height = 0
    height = @elExpandWrapper.height() if @el.hasClass 'expanded'
    @elExpandBlock.css 'height', "#{height}px"

  _onProductTap: =>
    @_onFilterTap 'productModel', 'productId', '_products', @elProductListBtn

  _onMessage1Tap: =>
    @_onFilterTap 'message1Model', 'productMessage1', '_messages', @elProductMessage1

  _onMessage2Tap: =>
    @_onFilterTap 'message2Model', 'productMessage2', '_messages', @elProductMessage2

  _onMessage3Tap: =>
    @_onFilterTap 'message3Model', 'productMessage3', '_messages', @elProductMessage3

  _onFilterTap: (modelName, variableName, resourceName, HTMLelement) =>
    @_updateResources() if resourceName is '_products'
    @[modelName] = @[resourceName][0] unless @[modelName]
    filterPopup = new ListPopup @[resourceName], @[modelName]
    filterPopup.bind 'onPopupItemSelected', (selectedItem) =>
      @[modelName] = selectedItem.model
      if resourceName is '_products'
        @_clearMessages()
        @_clearPromorionItem()
        @_setActiveProduct()
        @[variableName] = @[modelName]. id
      else
        @[variableName] = if @[modelName].id then @[modelName].description else null
      @isChanged = true
      HTMLelement.html @[modelName].description
      @_prepareMessages() if resourceName is '_products'
      @trigger 'dismissModalController'
    @trigger 'presentModalController', filterPopup

  _updateResources: =>
    @_products = []
    @_products.push @_filterResource(null, Locale.value('common:defaultSelectValue'))
    @datasource.productsWithMessages.forEach (productWithMessage) =>
      if (!productWithMessage.isSelected) or (productWithMessage.isSelected and @productId is productWithMessage.product.id)
        @_products.push @_filterResource(productWithMessage.product.id, productWithMessage.product.name)

  _clearMessages: =>
    @productMessage1 = null
    @productMessage2 = null
    @productMessage3 = null

  _clearPromorionItem: =>
    @isPromotional = false
    @elPromotional[0].checked = false

  _setActiveProduct: =>
    @datasource.productsWithMessages.forEach (productWithMessage) =>
      if @productId and @productId is productWithMessage.product.id
        productWithMessage.isSelected = false #unselect previous product
      if @productModel and @productModel.id is productWithMessage.product.id
        productWithMessage.isSelected = true #select current product

  _onPromotionalChange: =>
    @isPromotional = @elPromotional[0].checked

  setCommonInput: (value) =>
    @elProductComment.val value
    new CommonInput  @elProductComment.parent(), @elProductComment[0], @maxCommentStringLength
    @elProductComment.on 'change', @_productsChanged
    @elProductComment.on 'blur', @_refresh

  _productsChanged: =>
    @productComment = @elProductComment.val()
    @isChanged = true

  _refresh: =>
    #hack TODO need find a correct solution
    @elGeneralBlock.css 'display', 'table-row'
    setTimeout =>
      @elGeneralBlock.css 'display', ''
    , 0

module.exports = CallReportCardProductsTableCell