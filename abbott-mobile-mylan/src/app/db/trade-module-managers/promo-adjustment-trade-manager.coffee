PromoAdjustmentBaseManager = require 'db/trade-module-managers/promo-adjustment-base-manager'
PhotoAdjustmentsCollection = require 'models/bll/photo-adjustments-collection'
TaskAdjustmentsCollection = require 'models/bll/task-adjustments-collection'
MechanicAdjustmentsCollection = require 'models/bll/mechanic-adjustments-collection'

class PromoAdjustmentTradeManager extends PromoAdjustmentBaseManager
  _savePhotos: =>
    photoAdjustmentsCollection = new PhotoAdjustmentsCollection
    @runSimultaneouslyForCollection @photos, (photoAdjustment) =>
      photoAdjustment.callReportSfId = @callReportLocalId
      photoAdjustment.isModifiedInTrade = false
      photoAdjustmentsCollection.updateEntity(photoAdjustment)

  _saveTasks: =>
    @_saveTasksToAdjustmentsList @tasks

  _saveTaskSkus: =>
    @_saveTasksToAdjustmentsList @taskSkus

  _saveTasksToAdjustmentsList: (adjustmentsList) =>
    taskAdjustmentsCollection = new TaskAdjustmentsCollection
    @runSimultaneouslyForCollection adjustmentsList, (taskAdjustment, index) ->
      return unless (taskAdjustment.id and taskAdjustment.isModifiedInTrade)
      taskAdjustment.isModifiedInTrade = false
      taskAdjustmentsCollection.updateEntity(taskAdjustment)
      .then (entity) => adjustmentsList[index] = taskAdjustmentsCollection.parseEntity entity
  
  _saveMechanics: =>
    mechanicAdjustmentsCollection = new MechanicAdjustmentsCollection
    @runSimultaneouslyForCollection @mechanics, (mechanic, index) =>
      return unless (mechanic.adjustment.id and mechanic.adjustment.isModifiedInTrade)
      mechanic.adjustment.isModifiedInTrade = false
      mechanicAdjustmentsCollection.updateEntity(mechanic.adjustment)
      .then (entity) => @mechanics[index].adjustment = mechanicAdjustmentsCollection.parseEntity entity

  _resetPhotos: =>
    photoAdjustmentEntitiesToRemove = @photos.filter (photoAdjustmentEntity) -> photoAdjustmentEntity.isModifiedInTrade
    @_removePhotoEntities photoAdjustmentEntitiesToRemove

  _resetTasks: =>
    @_resetTasksForAdjustmentsListWithPredicate @tasks, (currentTaskAdj, sourceTaskAdj) ->
      currentTaskAdj.promotionTaskAccountSfId is sourceTaskAdj.promotionTaskAccountSfId and 
      currentTaskAdj.promotionTaskSfId is sourceTaskAdj.promotionTaskSfId

  _resetTaskSkus: =>
    @_resetTasksForAdjustmentsListWithPredicate @taskSkus, (currentTaskAdj, sourceTaskAdj) ->
      currentTaskAdj.promotionTaskAccountSfId is sourceTaskAdj.promotionTaskAccountSfId and 
      currentTaskAdj.promotionTaskSfId is sourceTaskAdj.promotionTaskSfId and
      currentTaskAdj.productItemSfId is sourceTaskAdj.productItemSfId

  _resetTasksForAdjustmentsListWithPredicate: (adjustmentsList, filterPredicate) ->
    filteredTaskAdjustments = adjustmentsList.filter (taskAdjustment) -> taskAdjustment.isModifiedInTrade
    promotionTaskAccountsIds = filteredTaskAdjustments.map (taskAdjustment) -> taskAdjustment.promotionTaskAccountSfId
    new TaskAdjustmentsCollection().getAllTaskAdjustmentsByCallReportAndTaskAccounts(@callReport, promotionTaskAccountsIds)
    .then (taskAdjustments) ->
      taskAdjustments.forEach (taskAdjustment) ->
        adjustmentsList.forEach (task, index) ->
          adjustmentsList[index] = taskAdjustment if filterPredicate task, taskAdjustment

  _resetMechanics: =>
    filteredMechanics = @mechanics.filter (mechanic) => mechanic.adjustment.isModifiedInTrade
    mechanicEvaluationAccountIds = filteredMechanics.map (mechanic) -> mechanic.adjustment.mechanicEvaluationAccountSfId
    new MechanicAdjustmentsCollection().getAdjustmentsByCallReportAndMechanicEvaluationAccounts(@callReport, mechanicEvaluationAccountIds)
    .then (mechanicAdjustments) =>
      mechanicAdjustments.forEach (sourceMechanicAdj) =>
        @mechanics.forEach (currentMechanic, index) =>
          if currentMechanic.adjustment.mechanicEvaluationAccountSfId is sourceMechanicAdj.mechanicEvaluationAccountSfId
            @mechanics[index].adjustment = sourceMechanicAdj

  initializeTasks: =>
    @_initializeTasksForAdjustmentsList @tasks

  initializeTaskSkus: =>
    @_initializeTasksForAdjustmentsList @taskSkus

  _initializeTasksForAdjustmentsList: (adjustmentsList) =>
    taskAdjustmentsCollection = new TaskAdjustmentsCollection
    @runSimultaneouslyForCollection adjustmentsList, (taskAdjustment, index) =>
      taskAdjustment.callReportSfId = @callReportLocalId
      taskAdjustmentsCollection.createEntity(taskAdjustment)
      .then (entity) => adjustmentsList[index] = taskAdjustmentsCollection.parseEntity entity

  initializeMechanics: =>
    mechanicAdjustmentsCollection = new MechanicAdjustmentsCollection
    @runSimultaneouslyForCollection @mechanics, (mechanic, index) =>
      mechanic.adjustment.callReportSfId = @callReportLocalId
      mechanicAdjustmentsCollection.createEntity(mechanic.adjustment)
      .then (entity) => @mechanics[index].adjustment = mechanicAdjustmentsCollection.parseEntity entity

module.exports = PromoAdjustmentTradeManager