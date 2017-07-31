FileProcessor = require 'common/file-processor/file-processor'
PresentationsFileManager = require 'common/presentation-managers/presentations-file-manager'

class PresentationStructureGenerator

  @generate: (scenario) =>
    slidesArray = JSON.parse scenario.structure
    chapterName = scenario.name || 'preview'

    jsonStructure = {
      slides: {}
      chapters: {}
      storyboard: ["#{chapterName}"]
    }

    jsonStructure.chapters["#{chapterName}"] = {
      name: "#{chapterName}"
      content: []
    }

    slidesArray.forEach (slideObject) =>
      slideId = "P#{slideObject.presentationId}_#{slideObject.id}"
      jsonStructure.slides[slideId] = {
        name: slideObject.name
        template: "#{PresentationsFileManager.getPathToPresentation(slideObject.presentationId)}/#{slideObject.path}"
      }
      jsonStructure.chapters["#{chapterName}"].content.push(slideId)

    fileProcessor = new FileProcessor
    fileProcessor.write('structure.json', JSON.stringify jsonStructure)
    fileProcessor.getFullPath('structure.json')

module.exports = PresentationStructureGenerator
