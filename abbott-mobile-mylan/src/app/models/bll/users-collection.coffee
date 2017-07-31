EntitiesCollection = require 'models/bll/entities-collection'
User = require 'models/user'

class UsersCollection extends EntitiesCollection
  model: User

  didPageFinishDownloading: (records) ->
    @_updateActiveUser records

  _updateActiveUser: (users) ->
    users = users.map (user) =>
      # TODO: get to know why Force.userId has no suffix 'AAM' but users are the same
      isCurrentUser = user[@model.sfdc.id].indexOf(Force.userId) is 0
      _.extend {isCurrentUser: isCurrentUser}, user
    @cache.saveAll(users)
    .then (users) -> require('models/bll/sforce-data-context').reloadActiveUser()

  _fetchAllQuery: =>
    activeUser = {}
    activeUser[@model.sfdc.isActive] = true
    super().where(activeUser)

  loadActiveUser: ->
    Utils = require 'common/utils'
    if Utils.isIOS()
      @fetchAllWhere(isCurrentUser: true)
      .then (response) => @getEntityFromResponse response
    else
      @fetchEntityById Force.userId

module.exports = UsersCollection