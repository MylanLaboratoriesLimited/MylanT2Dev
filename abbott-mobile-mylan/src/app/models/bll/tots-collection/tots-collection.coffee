EntitiesCollection = require 'models/bll/entities-collection'
Tot = require 'models/tot'
Query = require 'common/query'

class TotsCollection extends EntitiesCollection
  model: Tot
  ALL_TYPES: 'ALL_TYPES'

  constructor: ->
    super
    @cache.noMerge = false

  parseModel: (result) ->
    if result.Owner
      result[@model.sfdc.userFirstName] = result.Owner.FirstName
      result[@model.sfdc.userLastName] = result.Owner.LastName
    super result

  _dataType: ->
    @ALL_TYPES

  _fetchAllQuery: ->
    query = new Query().selectFrom(@model.table)
    dataType = @_dataType()
    if dataType is @ALL_TYPES then query else query.where(dataType)

  warningErrorCodes: ->
    _.union super, ['ENTITY_IS_LOCKED']

  handleErrorForEntity: (error, entity) =>
    $.when(super(error, entity))
    .then =>
      @markEntityAsNotModified entity if entity and error.details.errorCode is 'ENTITY_IS_LOCKED'

module.exports = TotsCollection