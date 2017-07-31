EntitiesCollection = require 'models/bll/entities-collection'
ImageProcessor = require 'common/image-processor/image-processor'
LocalImage = require 'models/local-image'
Query = require 'common/query'
Utils = require 'common/utils'

class LocalImagesCollection extends EntitiesCollection
  model: LocalImage

  getAllLocalImagesForAttachments: (attachments) =>
    @fetchAllWhereIn('parentId', attachments.map (attachment) => @_attributesFromEntity(attachment)._soupEntryId)
    .then @getAllEntitiesFromResponse

  removeEntity: (entity, localAction = true) =>
    @_removePhotoImageForLocalImage(entity)
    .then => super entity, localAction

  _removePhotoImageForLocalImage: (localImage, imageProcessor = new ImageProcessor) =>
    imageProcessor.remove(localImage.path)
    .then -> imageProcessor.removeThumb(localImage.thumbnailPath)

  removeEntities: (entities) =>
    @_removePhotoImagesForLocalImages(entities)
    .then => super entities

  _removePhotoImagesForLocalImages: (entities) =>
    imageProcessor = new ImageProcessor
    recursion = (entities, index) =>
      unless index < entities.length then $.when entities
      else
        @_removePhotoImageForLocalImage(entities[index], imageProcessor)
        .then -> recursion entities, ++index
    recursion entities, 0

module.exports = LocalImagesCollection