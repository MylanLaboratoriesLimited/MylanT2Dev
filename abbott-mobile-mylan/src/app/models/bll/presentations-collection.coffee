EntitiesCollection = require 'models/bll/entities-collection'
Presentation = require 'models/presentation'

class PresentationsCollection extends EntitiesCollection
  model: Presentation

  constructor: ->
    super
    @cache.noMerge = false
    @cache.mergeMode = Force.MERGE_MODE.MERGE_ACCEPT_THEIRS

  parseModel: (result) ->
    result.iconName ?= "icon.png"
    result.iconPath ?= "img/media/#{result.iconName}"
    super result

  fetchAllLoaded: ->
    @fetchAll()
    .then (response) =>
      $.when(@parse(response.records))

module.exports = PresentationsCollection