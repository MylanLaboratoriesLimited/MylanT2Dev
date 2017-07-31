EntitiesCollection = require 'models/bll/entities-collection'
BuTeamPersonProfile = require 'models/bu-team-person-profile'

class BuTeamPersonProfilesCollection extends EntitiesCollection
  model: BuTeamPersonProfile

  fetchForUserBU: (userBU) =>
    fieldsValues = {}
    fieldsValues[@model.sfdc.businessUnit] = userBU
    @fetchAllWhere(fieldsValues)
    .then(@getAllEntitiesFromResponse)

  fetchForUserUnitAndContacts: (userBU, contactIds)=>
    buCondition = {}
    buCondition[@model.sfdc.businessUnit] = userBU
    query = @_fetchAllQuery().where(buCondition).and().whereIn(@model.sfdc.organizationSfid, contactIds)
    @fetchWithQuery(query)
    .then(@getAllEntitiesFromResponse)

module.exports = BuTeamPersonProfilesCollection