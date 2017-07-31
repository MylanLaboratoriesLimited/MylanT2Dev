EntitiesCollection = require 'models/bll/entities-collection'
PhotoAttachment = require 'models/photo-attachment'
PhotoAdjustment = require 'models/photo-adjustment'
ImageProcessor = require 'common/image-processor/image-processor'
ConfigurationManager = require 'db/configuration-manager'
PromotionFilterSFQueryBuilder = require 'common/sf-query-builders/promotion-filter-sf-query-builder'
CallreportFilterSFQueryBuilder = require 'common/sf-query-builders/callreport-filter-sf-query-builder'

class PhotoAttachmentsCollection extends EntitiesCollection
  model: PhotoAttachment

  prepareServerConfig: (configPromise) =>
    configPromise.then (config) =>
      ConfigurationManager.getConfig()
      .then (clmConfig) =>
        config.query += " WHERE #{@model.sfdc.parentId} IN (SELECT #{PhotoAdjustment.sfdc.id} FROM #{PhotoAdjustment.sfdcTable}"
        config.query += PromotionFilterSFQueryBuilder.buildWhereFilter('Promotion__r', clmConfig)
        config.query += ' AND'
        config.query += CallreportFilterSFQueryBuilder.buildWhereFilter('CallReport__r', true)
        config.query += ')'
        config

  getAllAttachmentsForPromotionWithId: (promotionId) =>
    promotionIdValue = {}
    promotionIdValue[@model.sfdc.parentId] = promotionId
    @fetchAllWhere(promotionIdValue).then(@getAllEntitiesFromResponse)

  getAllAttachmentsForAdjustments: (adjustments) =>
    @fetchAllWhereIn('localParentId', adjustments.map (adjustment) => @_attributesFromEntity(adjustment)._soupEntryId)
    .then(@getAllEntitiesFromResponse)

  getLocalImageByPhotoAttachmentId: (photoAttachmentId) =>
    localImagesCollection = @_createLocalImagesCollection()
    localImagesCollection.fetchAllWhere(parentId: photoAttachmentId)
    .then localImagesCollection.getEntityFromResponse

  didStartUploading: (photoAttachments) =>
    PhotoAdjustmentsCollection = require 'models/bll/photo-adjustments-collection'
    photoAdjustmentsCollection = new PhotoAdjustmentsCollection()
    attachmentsIds = photoAttachments.map (photoAttachment) => photoAttachment.localParentId
    photoAdjustmentsCollection.fetchAllWhereIn '_soupEntryId', attachmentsIds
    .then photoAdjustmentsCollection.getAllEntitiesFromResponse
    .then (photoAdjustments) =>
      photoAdjustmentsMap = {}
      photoAdjustments.forEach (photoAdjustment) =>
        photoAdjustmentsMap[photoAdjustment.attributes._soupEntryId] = photoAdjustment.id
      entities = photoAttachments.map (entity) =>
        entity.parentId = photoAdjustmentsMap[entity.localParentId]
        entity
      entities.filter (entity) => entity.parentId
    .then @_prepareAttachmentsBody

  _prepareAttachmentsBody: (photoAttachments) =>
    if _.isEmpty(photoAttachments) then $.when photoAttachments
    else
      @_createLocalImagesCollection().getAllLocalImagesForAttachments(photoAttachments)
      .then (localImages) => @_recursivePhotoUpdate photoAttachments, localImages
      .then -> photoAttachments

  _recursivePhotoUpdate: (photoAttachments, localImages) =>
    imageProcessor = new ImageProcessor
    recursion = (entities, localImages, index) =>
      unless index < entities.length then $.when entities
      else
        localImage = _.find localImages, (image) => image.parentId is @_attributesFromEntity(entities[index])._soupEntryId
        imageProcessor.read(localImage.path)
        .then (base64) ->
          entities[index].body = base64.replace("data:image/jpeg;base64,", "")
          recursion entities, localImages, ++index
    recursion photoAttachments, localImages, 0

  _createLocalImagesCollection: =>
    LocalImagesCollection = require 'models/bll/local-images-collection'
    new LocalImagesCollection

  removeEntities: (entities) =>
    imagesCollection = @_createLocalImagesCollection()
    imagesCollection.getAllLocalImagesForAttachments(entities)
    .then imagesCollection.removeEntities
    .then => super entities

module.exports = PhotoAttachmentsCollection