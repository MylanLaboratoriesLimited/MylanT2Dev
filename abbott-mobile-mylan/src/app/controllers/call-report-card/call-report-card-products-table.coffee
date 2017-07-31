CallReportCardProductsTableCell = require 'controllers/call-report-card/call-report-card-products-table-cell'
CallReportCardViewProductsTableCell = require 'controllers/call-report-card/call-report-card-view-products-table-cell'
ProductsCollection = require 'models/bll/products-collection'
MarketingMessagesCollection = require 'models/bll/marketing-messages-collection'
SforceDataContext = require 'models/bll/sforce-data-context'
Locale = require 'common/localization/locale'

class CallReportCardProductsTable extends Spine.Controller

  className: 'products-table'
  tag: 'table'

  constructor: (@_productCount) ->
    super
    @_productsCells = []

  render: (@_callReport)->
    @html @template()
    Locale.localize @el
    @productsWithMessages = []
    @_initPickListsAndProducts()
    .then =>
      if @_isViewMode() then @renderWithData() else @renderEmptyTable()

  _isViewMode: =>
    !!@_callReport

  _initPickListsAndProducts: ->
    @_getProductsWithMessages()

  _getProductsWithMessages: =>
    @_getProducts()
    .then (products) =>
      marketingMessagesCollection = new MarketingMessagesCollection
      marketingMessagesCollection.fetchAll()
      .then marketingMessagesCollection.getAllEntitiesFromResponse
      .then (messages) => @_prepareProductsWithMessages products, messages

  _getProducts: =>
    productsCollection = new ProductsCollection
    if @_isViewMode()
      productsCollection.fetchAll()
      .then productsCollection.getAllEntitiesFromResponse
    else
      @_getActiveUser()
      .then (activeUser) =>
        atcClassArray = activeUser.pinCode.split ' '
        productsCollection.fetchAllWhereIn(productsCollection.model.sfdc.atcClass, atcClassArray)
        .then productsCollection.getAllEntitiesFromResponse

  _prepareProductsWithMessages: (products, messages) =>
    products.forEach (product) =>
      if product and product.id
        productWithMessages = {}
        productWithMessages.product = product
        productWithMessages.isSelected = false
        productWithMessages.messages = messages.filter (message) -> message.produtSfId is product.id
        @productsWithMessages.push productWithMessages

  _getActiveUser: =>
    SforceDataContext.activeUser()

  #TO DO REFACTOR!!!!
  renderEmptyTable: ->
    _(@_productCount).times =>
       callReportCardProductsTableCell = new CallReportCardProductsTableCell @
       callReportCardProductsTableCell.on 'presentModalController', @_onPresentModalController
       callReportCardProductsTableCell.on 'dismissModalController', @_onDismissModalController
       @_productsCells.push callReportCardProductsTableCell
       @append callReportCardProductsTableCell.render().el
       callReportCardProductsTableCell.setCommonInput ''

  #TO DO REFACTOR!!!!
  #Separate rendering and filling table
  renderWithData: ->
    for productNumber in [1..@_productCount] by 1
      productId = @_callReport['prio' + productNumber + 'ProductSfid']
      if productId
        productWithMessage = @productsWithMessages.filter (productWithMessage) =>
          productWithMessage['product'].id is productId
        if productWithMessage.length is 1
          productName = productWithMessage[0]['product'].name
          productComment = @_callReport['noteForPrio' + productNumber]
          productPromotional = @_callReport['promotionalItemsPrio' + productNumber]
          messageNames = []
          for messageNumber in [1..3]
            messageNames[messageNumber] = @_callReport['prio' + productNumber + 'MarketingMessage' + messageNumber]
          callReportCardViewProductsTableCell = new CallReportCardViewProductsTableCell(
            productName,
            productComment,
            messageNames[1],
            messageNames[2],
            messageNames[3],
            productPromotional
          )
          @append callReportCardViewProductsTableCell.render().el
          callReportCardViewProductsTableCell.refreshComment()

  _onPresentModalController: (filterPopup) =>
    @trigger 'presentModalController', filterPopup

  _onDismissModalController: (filterPopup) =>
    @trigger 'dismissModalController'

  template: ->
    require('views/call-report-card/call-report-card-products-table')()

  getProducts: ->
    productsArray = []
    @_productsCells.forEach (productCell, index) =>
      product = {}
      product.productId = productCell.productId
      product.productComment = productCell.productComment
      product.productMessage1 = productCell.productMessage1
      product.productMessage2 = productCell.productMessage2
      product.productMessage3 = productCell.productMessage3
      product.isPromotional = productCell.isPromotional
      productsArray.push product
    productsArray

  isFirstProductSelected: ->
    @_productsCells[0].productId?

  isAnyProductChanged: ->
    @_productsCells.filter((productCell) => productCell.isChanged).length

  resetChangeFlags: ->
    @_productsCells.forEach((productCell) => productCell.isChanged = false)


module.exports = CallReportCardProductsTable