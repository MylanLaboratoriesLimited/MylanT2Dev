PanelScreen = require 'controllers/base/panel/panel-screen'
PromotionTasksTable = require 'controllers/trade-module/promotion-details/promotion-tasks/promotion-tasks-table'
PromotionTasksTableCell = require 'controllers/trade-module/promotion-details/promotion-tasks/promotion-tasks-table-cell'
ListPopup = require 'controls/popups/list-popup'
MultiselectPopup = require 'controls/popups/multiselect-popup'
PromotionTaskAccountsCollection = require 'models/bll/promotion-task-accounts-collection'
TaskAdjustmentsCollection = require 'models/bll/task-adjustments-collection'
TaskAdjustment = require 'models/task-adjustment'
PromoAdjustmentTradeManager = require 'db/trade-module-managers/promo-adjustment-trade-manager'

class PromotionTasks extends Spine.Controller
  className: 'promotion-tasks stack-page'

  constructor: (@promotionAccount, @promoAdjustmentEntity) ->
    super {}
    @taskAdjustmentsCollection = new TaskAdjustmentsCollection
    @promotionTaskAccounts = []

  active: ->
    super
    @render()

  render: ->
    new PromotionTaskAccountsCollection().getAllTasksForPromotionAccountWithId(@promotionAccount.id)
    .then (@promotionTaskAccounts) =>
      if _.isEmpty(@promotionTaskAccounts) then @_renderEmptyTemplate()
      else
        @_initAdjustments()
        .then @_renderTable
    @

  _renderEmptyTemplate: ->
    @html Locale.value('tradeModule.PromotionTasks.NoPromotionTasks')
    @el.addClass 'empty-tab'

  _initAdjustments: =>
    return $.when() if @promoAdjustmentEntity.hasTasks()
    if @promoAdjustmentEntity.isReadOnly
      @_fetchExistingAdjustments()
    else
      @_createNewAdjustments()

  _fetchExistingAdjustments: =>
    promoTaskAccountIds = @promotionTaskAccounts.map (promoTaskAccount) -> promoTaskAccount.id
    @taskAdjustmentsCollection.getAllTaskAdjustmentsByCallReportAndTaskAccounts(@promoAdjustmentEntity.callReport, promoTaskAccountIds)
    .then (taskAdjustments) => taskAdjustments.forEach @promoAdjustmentEntity.addTask

  _createNewAdjustments: =>
    @promotionTaskAccounts.forEach (promotionTaskAccount) =>
      taskAdjustment = {}
      taskAdjustment.isModifiedInCall  = true
      taskAdjustment.isModifiedInTrade = false
      taskAdjustment.promotionTaskSfId = promotionTaskAccount.promotionTaskSfId
      taskAdjustment[TaskAdjustment.sfdc.promotionTaskAccountSfId] = promotionTaskAccount.id
      taskAdjustment.attributes = { type: TaskAdjustment.table }
      @promoAdjustmentEntity.addTask @taskAdjustmentsCollection.parseEntity(taskAdjustment)
    new PromoAdjustmentTradeManager(@promoAdjustmentEntity).initializeTasks()

  _renderTable: =>
    promotionTasksTable = new PromotionTasksTable
    promotionTasksTable.datasource = @
    @html promotionTasksTable.render().el

  numberOfRowsForTable: (table) ->
    @promotionTaskAccounts.length

  cellForRowAtIndexForTable: (index, table) ->
    currentPromoTaskAccount = @promotionTaskAccounts[index]
    currentTaskAdjustment   = @promoAdjustmentEntity.getTaskAdjustmentByTaskAccountEntity currentPromoTaskAccount
    promotionTasksTableCell = new PromotionTasksTableCell currentPromoTaskAccount, currentTaskAdjustment
    promotionTasksTableCell.on 'selected', @_onTaskSelectTap
    promotionTasksTableCell.on 'valueChanged', @_onValueChange
    promotionTasksTableCell

  _onTaskSelectTap: (sender, promotionTaskAccount, taskAdjustment) =>
    initialIndex = 0
    initialValue = { id:initialIndex, value:null, description:Locale.value('common:defaultSelectValue') }
    datasource   = promotionTaskAccount.taskPicklistValues.split('\n').map (value, index) -> { id:index+1, value:value, description:value }
    taskAdjustmentValue = _.find datasource, (item) => taskAdjustment.stringRealValue is item.value or taskAdjustment.numberRealValue is item.value
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
    @promoAdjustmentEntity.setTaskValue taskAdjustment.id, promotionTaskAccount, value

module.exports = PromotionTasks