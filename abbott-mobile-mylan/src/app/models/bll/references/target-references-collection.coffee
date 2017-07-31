ReferencesCollection = require 'models/bll/references/references-collection'

class TargetReferencesCollection extends ReferencesCollection

  _fetchAllQuery: ->
    @_queryWithTargetFilter true

  count: =>
    @_countWithTargetFilter true

module.exports = TargetReferencesCollection