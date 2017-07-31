Spine = require 'spine'
TableController = require 'controls/table/card-table'
TableHeadersList = require 'controls/table/table-header/table-headers-list'
TableHeaderItem = require 'controls/table/table-header/table-header-item'
PromotionSkusCollection = require 'models/bll/promotion-skus-collection'
PromotionTaskAccountsCollection = require 'models/bll/promotion-task-accounts-collection'
TaskAdjustmentsCollection = require 'models/bll/task-adjustments-collection'
PageControl = require 'controls/page-control/page-control'
Iterator = require 'common/iterator'
ListPopup = require 'controls/popups/list-popup'
SkusTableCell = require 'controllers/trade-module/promotion-details/skus/skus-table-cell'
TaskAdjustment = require 'models/task-adjustment'
PromotionTaskAccount = require 'models/promotion-task-account'
PromoAdjustmentTradeManager = require 'db/trade-module-managers/promo-adjustment-trade-manager'

class Skus extends Spine.Controller
  className: 'skus stack-page'

  elements:
    '.skus-table': 'elTable'
    '.navigation-panel': 'elNavigationPanel'

  events:
    'swipeleft': '_onPrevPageTap'
    'swiperight': '_onNextPageTap'

  NUM_TASKS_PER_PAGE: 5

  constructor: (@promotionAccount, @promoAdjustmentEntity) ->
    super {}
    @pageControl = null
    @tasksIterator = null
    @skus = []
    @taskAdjustmentsCollection = new TaskAdjustmentsCollection

  _onPrevPageTap: ->
    return unless @tasksIterator?.hasPrev()
    @tasksIterator.prev()
    @_renderPage()

  _onNextPageTap: ->
    return unless @tasksIterator?.hasNext()
    @tasksIterator.next()
    @_renderPage()

  active: ->
    super
    @render()

  render: ->
    @html @template()
    new PromotionTaskAccountsCollection().getAllTasksRelatedToSKUsForPromotionAccountWithId(@promotionAccount.id)
    .then (tasks) =>
      if _.isEmpty(tasks) then @_renderEmptyTemplate()
      else
        @_getAllSkusForCurrentPromotion()
        .then (@skus) =>
          tasksPerPage = @_splitTasks tasks
          @_initPageControl tasksPerPage
          @_initIterator tasksPerPage
          @_initAdjustmentsForSkusAndTasks(@skus, tasks)
          .then @_renderPage
    Locale.localize @el
    @

  template: ->
    require('views/trade-module/promotion-details/skus/skus')()

  _renderEmptyTemplate: ->
    @html Locale.value('tradeModule.Skus.NoSkus')
    @el.addClass 'empty-tab'

  _getAllSkusForCurrentPromotion: =>
    new PromotionSkusCollection().getAllSkusForPromotionWithId(@promotionAccount.promotionSfId)

  _splitTasks: (tasks) ->
    _.chain(tasks).groupBy((_, index) => Math.floor index / @NUM_TASKS_PER_PAGE).toArray().value()

  _initPageControl: (tasksPerPage) ->
    @pageControl = new PageControl tasksPerPage.length
    @pageControl.on 'pageControlItemTap', (pageControlItem) => @_moveToPageAtIndex pageControlItem.index
    @elNavigationPanel.prepend @pageControl.el

  _moveToPageAtIndex: (index) ->
    return if @tasksIterator.currentIndex() is index
    @tasksIterator.setCurrentIndex index
    @_renderPage()

  _renderPage: =>
    @pageControl.refreshByActivePageIndex @tasksIterator.currentIndex()
    @elTable.html ''
    @_renderTableHeader()
    @_renderTable()

  _initIterator: (tasksPerPage) ->
    @tasksIterator = new Iterator tasksPerPage

  _initAdjustmentsForSkusAndTasks: (skus, tasks) ->
    return $.when() if @promoAdjustmentEntity.hasTaskSkus()
    if @promoAdjustmentEntity.isReadOnly
      @_fetchExistingAdjustments tasks
    else
      @_createNewAdjustments skus, tasks

  _fetchExistingAdjustments: (tasks) =>
    taskIds = tasks.map (task) -> task.id
    @taskAdjustmentsCollection.getAllTaskAdjustmentsByCallReportAndTaskAccounts(@promoAdjustmentEntity.callReport, taskIds)
    .then (taskAdjustments) => taskAdjustments.forEach @promoAdjustmentEntity.addTaskSku

  _createNewAdjustments: (skus, tasks) =>
    skus.forEach (sku) =>
      tasks.forEach (task) =>
        taskAdjustment = {}
        taskAdjustment.isModifiedInCall  = true
        taskAdjustment.isModifiedInTrade = false
        taskAdjustment.promotionTaskSfId = task.promotionTaskSfId
        taskAdjustment[TaskAdjustment.sfdc.productItemSfId] = sku.productItemSfId
        taskAdjustment[TaskAdjustment.sfdc.promotionTaskAccountSfId] = task.id
        taskAdjustment.attributes = { type: TaskAdjustment.table }
        @promoAdjustmentEntity.addTaskSku @taskAdjustmentsCollection.parseEntity(taskAdjustment)
    new PromoAdjustmentTradeManager(@promoAdjustmentEntity).initializeTaskSkus()

  _renderTableHeader: ->
    currentTaksHeaderItems = @tasksIterator.currentItem().map (task) -> new TableHeaderItem task.taskName
    tasksTableHeader = new TableHeadersList [new TableHeaderItem Locale.value('common:names.Product')].concat(currentTaksHeaderItems)
    @elTable.append tasksTableHeader.el

  _renderTable: =>
    skusTable = new TableController
    skusTable.datasource = @
    skusTable.render()
    skusTable.el.addClass 'scroll-container'
    @elTable.append skusTable.el

  numberOfRowsForTable: (table) =>
    @skus.length

  cellForRowAtIndexForTable: (index, table) =>
    adjustmnets = @promoAdjustmentEntity.getTaskSkuAdjustmentsByTasksAndSku @tasksIterator.currentItem(), @skus[index]
    skuCell = new SkusTableCell @skus[index], @tasksIterator.currentItem(), adjustmnets
    skuCell.on 'selected', @_onTaskSelectTap
    skuCell.on 'valueChanged', @_onValueChange
    skuCell

  _onTaskSelectTap: (sender, promotionTaskAccount, taskAdjustment) =>
    initialIndex = 0
    initialValue = { id:initialIndex, value:null, description:Locale.value('common:defaultSelectValue') }
    datasource   = promotionTaskAccount.taskPicklistValues.split('\n').map (value, index) -> { id:index+1, value:value, description:value }
    taskAdjustmentValue = _.find datasource, (item) -> taskAdjustment.stringRealValue is item.value or taskAdjustment.numberRealValue is item.value
    defaultValue = taskAdjustmentValue or initialValue
    popup = new ListPopup datasource, defaultValue, promotionTaskAccount.taskName
    popup.el.addClass 'promotion-pick-list'
    popup.bind 'onPopupItemSelected', (item) =>
      sender.text item.model.description
      @_onValueChange taskAdjustment, promotionTaskAccount, item.model.value
      @trigger 'dismissModalController'
    @trigger 'presentModalController', popup

  _onValueChange: (taskAdjustment, promotionTaskAccount, value) =>
    @trigger 'dataChanged'
    taskAdjustment.isModifiedInTrade = true
    @promoAdjustmentEntity.setTaskSkuValue taskAdjustment.id, promotionTaskAccount, value

module.exports = Skus