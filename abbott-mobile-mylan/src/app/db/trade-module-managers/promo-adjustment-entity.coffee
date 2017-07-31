PromotionMechanic = require 'models/promotion-mechanic'
PromotionTaskAccount = require 'models/promotion-task-account'
PhotoAdjustmentsCollection = require 'models/bll/photo-adjustments-collection'
TaskAdjustmentsCollection = require 'models/bll/task-adjustments-collection'
MechanicEvaluationAccountsCollection = require 'models/bll/mechanic-evaluation-accounts-collection'
MechanicAdjustmentsCollection = require 'models/bll/mechanic-adjustments-collection'
PromotionTaskAccountsCollection = require 'models/bll/promotion-task-accounts-collection'
PromotionMechanicsCollection = require 'models/bll/promotion-mechanics-collection'

class NullEvaluation
  constructor: ->
    @id = null

  realValue: ->
    '-'

class NullMechanicAdjustment
  constructor: ->
    @realValue = '-'

class NullTaskAdjustment
  constructor: ->
    @realValue = ''
    @numberRealValue = ''
    @stringRealValue = ''

class PromoAdjustmentEntity
  constructor: ->
    @callReport = null
    @promotionAccount = null
    @promoId = null
    @photos = []
    @tasks = []
    @taskSkus = []
    @mechanics = []
    @isReadOnly = false

  _addItemToCollection: (item, collection) ->
    collection.push item

  removeItemFromCollection: (item, collection) ->
    collection.splice (collection.indexOf item), 1

  _hasCollectionAnyItems: (collection) ->
    collection.length > 0

  addPhoto: (photo) =>
    @_addItemToCollection photo, @photos

  removePhoto: (photo) =>
    @removeItemFromCollection photo, @photos

  addTask: (task) =>
    @_addItemToCollection task, @tasks

  removeTask: (task) =>
    @removeItemFromCollection task, @tasks

  hasTasks: =>
    @_hasCollectionAnyItems @tasks

  addTaskSku: (taskSku) =>
    @_addItemToCollection taskSku, @taskSkus

  removeTaskSku: (taskSku) =>
    @removeItemFromCollection taskSku, @taskSkus

  hasTaskSkus: =>
    @_hasCollectionAnyItems @taskSkus

  addMechanicEvaluationWithAdjustment: (mechanicEvaluationWithAdjustment) =>
    @_addItemToCollection mechanicEvaluationWithAdjustment, @mechanics

  removeMechanicEvaluationWithAdjustment: (mechanicEvaluationWithAdjustment) =>
    @removeItemFromCollection mechanicEvaluationWithAdjustment, @mechanics

  hasMechanics: =>
    @_hasCollectionAnyItems @mechanics

  setTaskValue: (taskAdjustmentId, promotionTaskAccount, value) =>
    @_saveTaskValueToAdjustmentsList taskAdjustmentId, promotionTaskAccount, value, @tasks

  setTaskSkuValue: (taskSkuAdjustmentId, promotionTaskAccount, value) =>
    @_saveTaskValueToAdjustmentsList taskSkuAdjustmentId, promotionTaskAccount, value, @taskSkus

  areAllAdjustmentsFilled: =>
    @_areSkusAdjustmentsFilled() and  @_areMechanicAdjustmentsFilled() and @_areTaskAdjustmentsFilled() and @_doPhotosExist()

  _doPhotosExist: =>
    not _.isEmpty @photos

  _areTaskAdjustmentsFilled: =>
    return @_areAdjustmentsFilled @tasks

  _areSkusAdjustmentsFilled: =>
    return @_areAdjustmentsFilled @taskSkus

  _areMechanicAdjustmentsFilled: =>
    not _.isEmpty(@mechanics) and
    not _.any(@mechanics, (mechanic) ->
      !mechanic.evaluation.isDisabled() and
      !mechanic.adjustment.numberRealValue and
      !mechanic.adjustment.stringRealValue
    )

  _areAdjustmentsFilled: (adjustments) ->
    not _.isEmpty(adjustments) and
    not _.any(adjustments, @_isAdjustmentWithoutValue)

  _isAdjustmentWithoutValue: (adjustment) ->
    !adjustment.numberRealValue and !adjustment.stringRealValue

  _saveTaskValueToAdjustmentsList: (taskAdjustmentId, promotionTaskAccount, value, adjustmentsList) ->
    adjustmentsList.forEach (taskAdjustment, index) =>
      if taskAdjustment.id is taskAdjustmentId
        adjustmentsList[index].isModifiedInTrade = true
        switch promotionTaskAccount.taskType
          when PromotionTaskAccount.TASK_TYPE_NUMERIC then adjustmentsList[index].numberRealValue = value
          when PromotionTaskAccount.TASK_TYPE_TEXT, PromotionTaskAccount.TASK_TYPE_PICKLIST then adjustmentsList[index].stringRealValue = value

  setMechanicValue: (mechanicEvaluationWithAdjustment, value) =>
    mechanicEvaluationWithAdjustment.adjustment.isModifiedInTrade = true
    switch mechanicEvaluationWithAdjustment.evaluation.mechanicType
      when PromotionMechanic.MECHANIC_TYPE_NUMERIC then mechanicEvaluationWithAdjustment.adjustment.numberRealValue = value
      when PromotionMechanic.MECHANIC_TYPE_TEXT, PromotionMechanic.MECHANIC_TYPE_PICKLIST then mechanicEvaluationWithAdjustment.adjustment.stringRealValue = value

  getTaskAdjustmentByTaskAccountEntity: (promotionTaskAccount) =>
    _.find(@tasks, (taskAdjustment) -> taskAdjustment.promotionTaskAccountSfId is promotionTaskAccount.id) or new NullTaskAdjustment

  getTaskSkuAdjustmentsByTasksAndSku: (promoTaskAccounts, promotionSku) =>
    promoTaskAccounts.map (promoTaskAccount) =>
      taskSku = _.find @taskSkus, (taskSku) -> promoTaskAccount.id is taskSku.promotionTaskAccountSfId and taskSku.productItemSfId is promotionSku.productItemSfId
      taskSku or new NullTaskAdjustment

  getEvaluationsAndMechanicAdjustmentsByMechanicsAndSku: (promotionMechanics, promotionSku) =>
    promotionMechanics.map (promoMechanic) =>
      mechanic = _.find @mechanics, (mechanic) -> mechanic.evaluation.skuPromotionSfId is promotionSku.id and mechanic.evaluation.promotionMechanicSfId is promoMechanic.id
      mechanic or { evaluation: new NullEvaluation, adjustment: new NullMechanicAdjustment }

module.exports = PromoAdjustmentEntity