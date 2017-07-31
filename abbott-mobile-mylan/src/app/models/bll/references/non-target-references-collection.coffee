ReferencesCollection = require 'models/bll/references/references-collection'

class NonTargetReferencesCollection extends ReferencesCollection

  _fetchAllQuery: ->
    @_queryWithTargetFilter false

  count: =>
    @_countWithTargetFilter false

module.exports = NonTargetReferencesCollection
