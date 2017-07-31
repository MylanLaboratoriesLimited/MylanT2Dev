PhotoAdjustmentsCollection = require 'models/bll/photo-adjustments-collection'
Utils = require 'common/utils'

class PromoAdjustmentBaseManager
  constructor: (@promoAdjustment) ->
    @photos = @promoAdjustment.photos
    @tasks = @promoAdjustment.tasks
    @taskSkus = @promoAdjustment.taskSkus
    @mechanics = @promoAdjustment.mechanics
    @callReport = @promoAdjustment.callReport
    @callReportLocalId = @promoAdjustment.callReport.attributes._soupEntryId
    @callReportExternalId = @promoAdjustment.callReport.id

  runSimultaneouslyForCollection: (collection, forEachItem) =>
    Utils.runSimultaneously _.map(collection, forEachItem)

  saveChanges: =>
    @_savePhotos()
    .then @_saveTasks
    .then @_saveTaskSkus
    .then @_saveMechanics

  _savePhotos: => $.when()

  _saveTasks: => $.when()

  _saveTaskSkus: => $.when()

  _saveMechanics: => $.when()

  resetChanges: =>
    @_resetPhotos()
    .then @_resetTasks
    .then @_resetTaskSkus
    .then @_resetMechanics

  _resetPhotos: => $.when()

  _resetTasks: => $.when()

  _resetTaskSkus: => $.when()

  _resetMechanics: => $.when()

  _removePhotoEntities: (photoAdjustmentsToRemove) =>
   photoAdjustmentsCollection = new PhotoAdjustmentsCollection
   photoAdjustmentsCollection.getLocalImagesByAdjustments(photoAdjustmentsToRemove)
   .then (promotionAttachmentImages) =>
      @runSimultaneouslyForCollection photoAdjustmentsToRemove, (photoAdjustment) =>
        @promoAdjustment.removePhoto(photoAdjustment)
        photoAdjustmentsCollection.removePhoto(photoAdjustment, promotionAttachmentImages[photoAdjustment.id])

module.exports = PromoAdjustmentBaseManager