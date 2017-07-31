PresentationFileManager = require 'common/presentation-managers/presentations-file-manager'

class PresentationStructureManager
  @_relativePathToStructure: 'structure.json'

  @_parseStructure: (structureContent, presentationId)=>
    structure = JSON.parse structureContent
    Object.keys(structure['chapters']).filter (chapterId)=>
      structure['chapters'][chapterId].content.length > 0
    .map (chapterId)=>
      chapter = structure['chapters'][chapterId]
      chapter['id'] = chapterId
      chapter['content'] = chapter['content'].map (slideId)=>
        slide = structure['slides'][slideId]
        slide['id'] = slideId
        slide['path'] = slide['template']
        slide['thumbnail'] = @_mapThumbnailPath slideId
        slide['chapterId'] = chapterId
        slide['presentationId'] = presentationId
        delete slide['template']
        slide
      chapter

  @_mapPathToStructure: (presentationId)=>
    "#{presentationId}/#{@_relativePathToStructure}"

  @_mapThumbnailPath: (slideId)=>
    "/media/images/common/thumbs/#{slideId}.jpg"

  @getParsedStructure: (presentationId)=>
    structurePath = @_mapPathToStructure presentationId
    promise = new $.Deferred
    PresentationFileManager.readPresentationFile structurePath
    .done (structureContent)=>
      promise.resolve @_parseStructure(structureContent, presentationId)
    .fail (error)=>
      promise.reject error
    promise.promise()

module.exports = PresentationStructureManager