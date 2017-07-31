UsersCollection = require 'models/bll/users-collection'
MarketingCyclesCollection = require 'models/bll/marketing-cycles-collection'
Utils = require 'common/utils'
AlarmManager = require 'common/alarm/alarm-manager'
SFOAuthPlugin = cordova.require 'salesforce/plugin/oauth'

class SforceDataContext
  @usersCollection = new UsersCollection
  @mcsCollection = new MarketingCyclesCollection
  @_activeUser: null
  @_activeTarget: null
  @_currentCycle: null

  @cleanup: =>
    @_activeUser = null
    @_currentCycle = null
    @_activeTarget = null

  @activeUser: =>
    if @_activeUser? then $.when @_activeUser else @usersCollection.loadActiveUser().then (@_activeUser) => @_activeUser

  @reloadActiveUser: =>
    @_activeUser = null
    @activeUser()

  @currentMarketingCycle: =>
    unless @_currentCycle
      today = Utils.currentDate()
      @activeUser()
      .then((activeUser) => @mcsCollection.fetchByDateAndCurrency today, activeUser.currency)
      .then((@_currentCycle) => @_currentCycle)
    else
      $.when @_currentCycle

  @getAuthCredentials: =>
    deferred = new $.Deferred
    cordova.require("salesforce/plugin/oauth").getAuthCredentials deferred.resolve, deferred.reject
    deferred.promise()

  @logout: =>
    AlarmManager.cancelNotification()
    SFOAuthPlugin.logout();

module.exports = SforceDataContext