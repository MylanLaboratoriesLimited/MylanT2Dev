PromoAdjustmentBaseManager = require 'db/trade-module-managers/promo-adjustment-base-manager'
PhotoAdjustmentsCollection = require 'models/bll/photo-adjustments-collection'
TaskAdjustmentsCollection = require 'models/bll/task-adjustments-collection'
MechanicAdjustmentsCollection = require 'models/bll/mechanic-adjustments-collection'
PromotionTaskAccountsCollection = require 'models/bll/promotion-task-accounts-collection'
MechanicEvaluationAccountsCollection = require 'models/bll/mechanic-evaluation-accounts-collection'

class PromoAdjustmentCallManager extends PromoAdjustmentBaseManager
  _savePhotos: =>
    photoAdjustmentsCollection = new PhotoAdjustmentsCollection
    @runSimultaneouslyForCollection @photos, (photoAdjustment) =>
      photoAdjustment.callReportSfId = @callReportLocalId
      photoAdjustment.isModifiedInCall = false
      photoAdjustmentsCollection.updateEntity photoAdjustment

  _saveTasks: =>
    @_callReportSaveTasksToAdjustmentsList @tasks

  _saveTaskSkus: =>
    @_callReportSaveTasksToAdjustmentsList @taskSkus

  _callReportSaveTasksToAdjustmentsList: (adjustmentsList) ->
    taskAdjustmentsCollection = new TaskAdjustmentsCollection
    @_clearEmptyAdjustments(adjustmentsList, taskAdjustmentsCollection)
    .then (adjustmentsToSave) =>
      @runSimultaneouslyForCollection adjustmentsToSave, (taskAdjustment, index) =>
        taskAdjustment.isModifiedInCall = false
        taskAdjustment.callReportSfId = @callReportLocalId
        @_incrementActualCallReports(taskAdjustment.promotionTaskAccountSfId, new PromotionTaskAccountsCollection)
        .then -> taskAdjustmentsCollection.updateEntity taskAdjustment

  _saveMechanics: =>
    adjustments = @mechanics.map (mechanic) => mechanic.adjustment
    mechanicAdjustmentsCollection = new MechanicAdjustmentsCollection
    @_clearEmptyAdjustments(adjustments, mechanicAdjustmentsCollection)
    .then (adjustmentsToSave) =>
      @runSimultaneouslyForCollection adjustmentsToSave, (adjustment, index) =>
        adjustment.isModifiedInCall = false
        adjustment.callReportSfId = @callReportLocalId
        @_incrementActualCallReports(adjustment.mechanicEvaluationAccountSfId, new MechanicEvaluationAccountsCollection)
        .then -> mechanicAdjustmentsCollection.updateEntity adjustment

  _clearEmptyAdjustments: (adjustmentsList, collection) =>
    adjustmentsToRemove = []
    adjustmentsToSave = []
    adjustmentsList.forEach (adjustment) ->
      if adjustment.stringRealValue or adjustment.numberRealValue
        adjustmentsToSave.push adjustment
      else
        adjustmentsToRemove.push adjustment
    collection.removeEntities(adjustmentsToRemove)
    .then -> adjustmentsToSave

  _incrementActualCallReports: (accountId, collection) =>
    collection.fetchEntityById(accountId)
    .then (entity) =>
      if entity.isRecurrent
        entity.actualCallReports = (+entity.actualCallReports ? 0) + 1
        collection.updateEntity entity

  _resetPhotos: =>
    @_removePhotoEntities @_adjustmentsModifiedInCallFromList @photos

  _resetTasks: =>
    @_removeTasksFromAdjustmentsList @_adjustmentsModifiedInCallFromList(@tasks), @tasks

  _resetTaskSkus: =>
    @_removeTasksFromAdjustmentsList @_adjustmentsModifiedInCallFromList(@taskSkus), @taskSkus

  _adjustmentsModifiedInCallFromList: (adjustmentsList) ->
    adjustmentsList.filter (adjustment) -> adjustment.isModifiedInCall

  _removeTasksFromAdjustmentsList: (taskAdjustmentsToRemove, adjustmentsList) =>
    adjustmentsToRemoveFromDB = []
    taskAdjustmentsToRemove.forEach (adjustment) =>
      @promoAdjustment.removeItemFromCollection adjustment, adjustmentsList
      adjustmentsToRemoveFromDB.push(adjustment) if adjustment.id
    new TaskAdjustmentsCollection().removeEntities adjustmentsToRemoveFromDB

  _resetMechanics: =>
    mechanicsToRemove = @mechanics.filter (mechanic) -> mechanic.adjustment.isModifiedInCall
    adjustmentsToRemoveFromDB = []
    mechanicsToRemove.forEach (mechanic) =>
      @promoAdjustment.removeMechanicEvaluationWithAdjustment mechanic
      adjustmentsToRemoveFromDB.push(mechanic.adjustment) if mechanic.adjustment.id
    new MechanicAdjustmentsCollection().removeEntities adjustmentsToRemoveFromDB

module.exports = PromoAdjustmentCallManager