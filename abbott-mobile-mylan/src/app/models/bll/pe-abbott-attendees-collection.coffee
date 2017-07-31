EntitiesCollection = require 'models/bll/entities-collection'
PEAbbottAttendee = require 'models/pe-abbott-attendee'

class PEAbbottAttendeesCollection extends EntitiesCollection
  model: PEAbbottAttendee

  fetchAllWhere: (fieldsValues, ignoreDeleted=true) =>
    query = @_fetchAllQuery().where(fieldsValues)
    @fetchWithQuery query, ignoreDeleted

  didStartUploading: (records) ->
    PharmaEventsCollection = require 'models/bll/pharma-events-collection'
    pharmaEventsCollection = new PharmaEventsCollection()
    pharmaEventsCollection.linkEntitiesToEntity records, 'pharmaEventSfId'

module.exports = PEAbbottAttendeesCollection