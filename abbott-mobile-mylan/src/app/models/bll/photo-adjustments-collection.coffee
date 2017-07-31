EntitiesCollection = require 'models/bll/entities-collection'
PhotoAdjustment = require 'models/photo-adjustment'
PromotionAttachment = require 'models/promotion-attachment'
ImageProcessor = require 'common/image-processor/image-processor'
Query = require 'common/query'
ConfigurationManager = require 'db/configuration-manager'
PromotionFilterSFQueryBuilder = require 'common/sf-query-builders/promotion-filter-sf-query-builder'
CallreportFilterSFQueryBuilder = require 'common/sf-query-builders/callreport-filter-sf-query-builder'

class PhotoAdjustmentsCollection extends EntitiesCollection
  model: PhotoAdjustment

  PHOTO_MAX_WIDTH: 1280
  PHOTO_MAX_HEIGHT: 1024

  prepareServerConfig: (configPromise) =>
    configPromise.then (config) =>
      ConfigurationManager.getConfig()
      .then (clmConfig) ->
        config.query += PromotionFilterSFQueryBuilder.buildWhereFilter('Promotion__r', clmConfig)
        config.query += ' AND'
        config.query += CallreportFilterSFQueryBuilder.buildWhereFilter('CallReport__r', true)
        config

  getEntitiesForCallReportAndPromotion: (callReport, promotionId) =>
    promoQuery = {}
    promoQuery[@model.sfdc.promotionSfId] = promotionId
    query = new Query().selectFrom(@model.table)
    .where(promoQuery).and()
    .whereIn(@model.sfdc.callReportSfId, [callReport.id, @_attributesFromEntity(callReport)._soupEntryId])
    @fetchUnparsedWithQuery(query).then @getAllEntitiesFromResponse

  getAdjustmentsByCallReport: (callReport) =>
    callReportIdValue = {}
    callReportIdValue[@model.sfdc.callReportSfId] = @_attributesFromEntity(callReport)._soupEntryId
    @fetchAllWhere(callReportIdValue)
    .then @getAllEntitiesFromResponse

  getAttachmentByPhotoAdjustmentId: (photoAdjustmentId) =>
    photoAttachmentsCollection = @_createPhotoAttachmentsCollection()
    promotionIdValue = {}
    promotionIdValue[photoAttachmentsCollection.model.sfdc.parentId] = photoAdjustmentId
    photoAttachmentsCollection.fetchAllWhere(promotionIdValue).then photoAttachmentsCollection.getEntityFromResponse

  getLocalImagesByAdjustments: (photoAdjustmentsArray) =>
    photoAttachmentsCollection = @_createPhotoAttachmentsCollection()
    adjustmentsIds = photoAdjustmentsArray.map (photoAdjustment) -> photoAdjustment.id
    photoAttachmentsCollection.fetchAllWhereIn(PromotionAttachment.sfdc.parentId, adjustmentsIds)
    .then(photoAttachmentsCollection.getAllEntitiesFromResponse)
    .then (promotionAttachments) =>
      @_createLocalImagesCollection().getAllLocalImagesForAttachments(promotionAttachments)
      .then (localImages) =>
        promotionAttachmentsImages = {}
        localImages.forEach (localImage) =>
          photoAttachment = _.find promotionAttachments, (promotionAttachment) => @_attributesFromEntity(promotionAttachment)._soupEntryId is localImage.parentId
          promotionAttachmentsImages[photoAttachment.parentId] = localImage
        promotionAttachmentsImages

  addPhoto: (photoAdjustment, tmpPhotoUrl) =>
    @_saveImageWithThumbnail(tmpPhotoUrl)
    .then ([photoUrl, thumbUrl]) =>
      @createEntity(photoAdjustment)
      .then @_createPhotoAttachment
      .then (photoAttachment) => @_createLocalImage(photoAttachment, photoUrl, thumbUrl)
      .then (image) => [@parseEntity(photoAdjustment), image]

  _saveImageWithThumbnail: (imageUrl) =>
    imageProcessor = new ImageProcessor
    imageProcessor.save(imageUrl)
    .then (imageFile) =>
      @_saveThumbnailForImageWithPath(imageFile.fullPath)
      .then (thumbPath) -> [imageFile.fullPath, thumbPath]

  _saveThumbnailForImageWithPath: (imagePath) =>
    imageProcessor = new ImageProcessor
    imageProcessor.resize(imagePath)
    .then (base64ThumbData) =>
      thumbPath = ImageProcessor.getThumbnailPath(imagePath)
      fileParts = thumbPath.split('/')
      imageProcessor.saveFromBase64(base64ThumbData.imageData, {filename: fileParts.pop(), directory: fileParts.join('/')})
      .then -> thumbPath

  _createPhotoAttachment: (photoAdjustment) =>
    photoAttachment = {}
    photoAttachment.localParentId = @_attributesFromEntity(photoAdjustment)._soupEntryId
    photoAttachment[PromotionAttachment.sfdc.parentId] = photoAdjustment[@model.sfdc.id]
    photoAttachment[PromotionAttachment.sfdc.contentType] = 'image/jpeg'
    photoAttachment[PromotionAttachment.sfdc.title] = 'Photo'
    @_createPhotoAttachmentsCollection().createEntity photoAttachment

  _createLocalImage: (photoAttachment, photoUrl, thumbUrl) =>
    image = {}
    image.path = photoUrl
    image.thumbnailPath = thumbUrl
    image.parentId = @_attributesFromEntity(photoAttachment)._soupEntryId
    @_createLocalImagesCollection().createEntity image

  saveDownloadedImageWithThumbnail: (photoAttachment, imagePath) =>
    @_saveThumbnailForImageWithPath(imagePath)
    .then (thumbPath) => @_createLocalImage(photoAttachment, imagePath, thumbPath)

  removePhoto: (photoAdjustment, image) =>
    @getAttachmentByPhotoAdjustmentId(photoAdjustment.id)
    .then @_createPhotoAttachmentsCollection().removeEntity
    .then => @_createLocalImagesCollection().removeEntity(image, true)
    .then => @removeEntity photoAdjustment

  _createPhotoAttachmentsCollection: =>
    PhotoAttachmentsCollection = require 'models/bll/photo-attachments-collection'
    new PhotoAttachmentsCollection

  _createLocalImagesCollection: =>
    LocalImagesCollection = require 'models/bll/local-images-collection'
    new LocalImagesCollection

  didStartUploading: (records) ->
    splitBrokenAdjustments = _.groupBy records, (record) -> (record.isModifiedInTrade is true) or (record.isModifiedInCall is true)
    brokenAdjustments = splitBrokenAdjustments.true ? []
    adjustmentsToUpload = splitBrokenAdjustments.false ? []
    @removeEntities brokenAdjustments
    .then -> adjustmentsToUpload
    .then (entities) =>
      CallReportsCollection = require 'models/bll/call-reports-collection/call-reports-collection'
      сallReportsCollection = new CallReportsCollection()
      сallReportsCollection.linkEntitiesToEntity entities, 'callReportSfId'

  didFinishUploading: (records) =>
    @_updatePhotoAttachments records

  _updatePhotoAttachments: (photoAdjustments) =>
    photoAttachmentsCollection = @_createPhotoAttachmentsCollection()
    photoAttachmentsCollection.getAllAttachmentsForAdjustments(photoAdjustments)
    .then (photoAttachments) =>
      photoAttachments.map (photoAttachment) =>
        photoAdjustment = _.find photoAdjustments, (photoAdjustment) -> photoAdjustment._soupEntryId is photoAttachment.localParentId
        photoAttachment.parentId = photoAdjustment[@model.sfdc.id]
        photoAttachment
    .then photoAttachmentsCollection.upsertEntitiesSilently

  removeEntities: (entities) =>
    photoAttachmentsCollection = @_createPhotoAttachmentsCollection()
    photoAttachmentsCollection.getAllAttachmentsForAdjustments(entities)
    .then photoAttachmentsCollection.removeEntities
    .then => super entities

module.exports = PhotoAdjustmentsCollection