EntitiesCollection = require 'models/bll/entities-collection'
PEAttendee = require 'models/pe-attendee'

class PEAttendeesCollection extends EntitiesCollection
  model: PEAttendee

  fetchAllWhere: (fieldsValues, ignoreDeleted=true) =>
    query = @_fetchAllQuery().where(fieldsValues)
    @fetchWithQuery query, ignoreDeleted

  didStartUploading: (records) ->
    PharmaEventsCollection = require 'models/bll/pharma-events-collection'
    pharmaEventsCollection = new PharmaEventsCollection()
    pharmaEventsCollection.linkEntitiesToEntity records, 'pharmaEventSfId'

module.exports = PEAttendeesCollection