Spine = require 'spine'
TableController = require 'controls/table/card-table'
TableHeadersList = require 'controls/table/table-header/table-headers-list'
TableHeaderItem = require 'controls/table/table-header/table-header-item'
PageControl = require 'controls/page-control/page-control'
Iterator = require 'common/iterator'
TacticsTableCell = require 'controllers/trade-module/promotion-details/tactics/tactics-table-cell'
PromotionMechanicsCollection = require 'models/bll/promotion-mechanics-collection'
PromotionSkusCollection = require 'models/bll/promotion-skus-collection'
MechanicEvaluationAccountsCollection = require 'models/bll/mechanic-evaluation-accounts-collection'
MechanicAdjustmentsCollection = require 'models/bll/mechanic-adjustments-collection'
MechanicAdjustment = require 'models/mechanic-adjustment'
ListPopup = require 'controls/popups/list-popup'
PromoAdjustmentTradeManager = require 'db/trade-module-managers/promo-adjustment-trade-manager'
Utils = require 'common/utils'

class NullMechanicAdjustment
  constructor: ->
    @realValue = '-'

class Tactics extends Spine.Controller
  className: 'tactics stack-page'

  elements:
    '.tactics-table': 'elTable'
    '.navigation-panel': 'elNavigationPanel'
    '.navigation-panel .check-box': 'elBorderValueCheck'

  events:
    'swipeleft': '_onPrevPageTap'
    'swiperight': '_onNextPageTap'
    'change .check-box': '_handleBorderValue'
    'tap .navigation-panel p': '_changeBorderValue'

  NUM_MECHANICS_PER_PAGE: 5

  constructor: (@promotionAccount, @promoAdjustmentEntity) ->
    super {}
    @evaluationAccountsCollection = new MechanicEvaluationAccountsCollection
    @adjustmentsCollection = new MechanicAdjustmentsCollection
    @pageControl = null
    @mechanicsIterator = null
    @promoSkus = null

  _onPrevPageTap: (event) ->
    event.stopPropagation()
    return unless @mechanicsIterator?.hasPrev()
    @mechanicsIterator.prev()
    @_renderPage()

  _onNextPageTap: (event) ->
    event.stopPropagation()
    return unless @mechanicsIterator?.hasNext()
    @mechanicsIterator.next()
    @_renderPage()

  _handleBorderValue: (event) =>
    @el.toggleClass 'hide-border-value'

  _changeBorderValue: =>
    checkbox = @elBorderValueCheck[0]
    checkbox.checked = not checkbox.checked
    @_handleBorderValue()

  active: ->
    super
    @render()

  render: ->
    @html @template()
    new PromotionMechanicsCollection().getAllMechanicsForPromotionWithId(@promotionAccount.promotionSfId)
    .then (mechanics) =>
      if _.isEmpty(mechanics) then @_renderEmptyTemplate()
      else
        @_getAllSkusForCurrentPromotion()
        .then (@promoSkus) =>
          mechanicsPerPage = @_splitMechanics mechanics
          @_initPageControl mechanicsPerPage
          @_initIterator mechanicsPerPage
          @_initEvaluationsAndAdjustmentsForMechanics(mechanics)
          .then @_renderPage
    Locale.localize @el
    @

  template: ->
    require('views/trade-module/promotion-details/tactics/tactics')()

  _renderEmptyTemplate: ->
    @html Locale.value('tradeModule.Tactics.NoMechanics')
    @el.addClass 'empty-tab'

  _getAllSkusForCurrentPromotion: =>
    new PromotionSkusCollection().getAllSkusForPromotionWithId(@promotionAccount.promotionSfId)

  _splitMechanics: (mechanics) ->
    _.chain(mechanics).groupBy((_, index) => Math.floor index / @NUM_MECHANICS_PER_PAGE).toArray().value()

  _initPageControl: (mechanicsPerPage) ->
    @pageControl = new PageControl mechanicsPerPage.length
    @pageControl.on 'pageControlItemTap', (pageControlItem) => @_moveToPageAtIndex pageControlItem.index
    @elNavigationPanel.prepend @pageControl.el

  _moveToPageAtIndex: (index) ->
    return if @mechanicsIterator.currentIndex() is index
    @mechanicsIterator.setCurrentIndex index
    @_renderPage()

  _renderPage: =>
    @pageControl.refreshByActivePageIndex @mechanicsIterator.currentIndex()
    @elTable.html ''
    @_renderTableHeader()
    @_renderTable()

  _renderTableHeader: ->
    currentMechanicsHeaderItems = @mechanicsIterator.currentItem().map (mechanic) -> new TableHeaderItem mechanic.mechanicName
    mechanicsTableHeader = new TableHeadersList [new TableHeaderItem Locale.value('common:names.Product')].concat(currentMechanicsHeaderItems)
    @elTable.append mechanicsTableHeader.el

  _renderTable: ->
    tacticsTable = new TableController
    tacticsTable.datasource = @
    tacticsTable.render()
    tacticsTable.el.addClass 'scroll-container'
    @elTable.append tacticsTable.el

  _initIterator: (mechanicsPerPage) ->
    @mechanicsIterator = new Iterator mechanicsPerPage

  _initEvaluationsAndAdjustmentsForMechanics: (mechanics) ->
    return $.when() if @promoAdjustmentEntity.hasMechanics()
    if @promoAdjustmentEntity.isReadOnly
      @_fetchExistingAdjustments mechanics
    else
      @_createNewAdjustments mechanics

  _fetchExistingAdjustments: (mechanics) =>
    @evaluationAccountsCollection.getAllEvaluationsForPromoMechanics(@promotionAccount, mechanics)
    .then (evaluations) =>
      mechanicEvaluationIds = evaluations.map (evaluation) -> evaluation.id
      @adjustmentsCollection.getAdjustmentsByCallReportAndMechanicEvaluationAccounts(@promoAdjustmentEntity.callReport, mechanicEvaluationIds)
      .then (mechanicAdjustments) =>
        evaluations.forEach (evaluation) =>
          adjustment = _.find(mechanicAdjustments, (adjustment) -> adjustment.mechanicEvaluationAccountSfId is evaluation.id) or new NullMechanicAdjustment
          @promoAdjustmentEntity.addMechanicEvaluationWithAdjustment { evaluation:evaluation, adjustment:adjustment }

  _createNewAdjustments: (mechanics) =>
    @evaluationAccountsCollection.getAllEvaluationsForPromoMechanics(@promotionAccount, mechanics)
    .then (evaluations) =>
      evaluations.forEach (evaluation) =>
        adjustment = {}
        adjustment.isModifiedInCall  = true
        adjustment.isModifiedInTrade = false
        adjustment[MechanicAdjustment.sfdc.mechanicEvaluationAccountSfId] = evaluation.id
        adjustment[MechanicAdjustment.sfdc.mechanicType] = evaluation.mechanicType
        adjustment.attributes = { type: MechanicAdjustment.table }
        @promoAdjustmentEntity.addMechanicEvaluationWithAdjustment { evaluation:evaluation, adjustment:@adjustmentsCollection.parseEntity(adjustment) }
      new PromoAdjustmentTradeManager(@promoAdjustmentEntity).initializeMechanics()

  numberOfRowsForTable: (table) ->
    @promoSkus.length

  cellForRowAtIndexForTable: (index, table) ->
    promoSku = @promoSkus[index]
    evaluationsWithAdjustments = @promoAdjustmentEntity.getEvaluationsAndMechanicAdjustmentsByMechanicsAndSku(@mechanicsIterator.currentItem(), promoSku)
    tacticsTableCell = new TacticsTableCell promoSku, evaluationsWithAdjustments
    tacticsTableCell.on 'selected', @_onTacticsSelectTap
    tacticsTableCell.on 'valueChanged', @_onValueChange
    tacticsTableCell

  _onValueChange: (evalWithAdj, value) =>
    @trigger 'dataChanged'
    evalWithAdj.evaluation.isModifiedInTrade = true
    @promoAdjustmentEntity.setMechanicValue evalWithAdj, value

  _onTacticsSelectTap: (sender, evaluationWithAdjustment) =>
    evaluation = evaluationWithAdjustment.evaluation
    adjustment = evaluationWithAdjustment.adjustment
    initialIndex = 0
    initialValue = { id:initialIndex, value:null, description:Locale.value('common:defaultSelectValue') }
    datasource = evaluation.promotionMechanicPicklistValues.split('\n').map (value, index) -> { id:index+1, value:value, description:value }
    mechanicAdjustmentValue = _.find datasource, (item) -> item.value is adjustment.stringRealValue or item.value is adjustment.numberRealValue
    defaultValue = mechanicAdjustmentValue or initialValue
    popup = new ListPopup datasource, defaultValue, evaluation.mechanicName
    popup.el.addClass 'promotion-pick-list'
    popup.bind 'onPopupItemSelected', (item) =>
      sender.didSelectValue(item.model.description)
      @_onValueChange evaluationWithAdjustment, item.model.value,
      @trigger 'dismissModalController'
    @trigger 'presentModalController', popup

module.exports = Tactics