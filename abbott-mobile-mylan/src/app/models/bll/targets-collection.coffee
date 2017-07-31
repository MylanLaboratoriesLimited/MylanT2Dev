EntitiesCollection = require 'models/bll/entities-collection'
Target = require 'models/target'

class TargetsCollection extends EntitiesCollection
  model: Target

  getTargetByUser: (user) =>
    userValue = {}
    userValue[@model.sfdc.medrepSfId] = user.id
    @fetchAllWhere(userValue)
    .then @getEntityFromResponse

module.exports = TargetsCollection