Query = require 'common/query'
Utils = require 'common/utils'

class SettingsManager
  @_soupName: 'Settings'
  @_identityKey: 'key'
  @_indexSpec = [
    {
      path: @_identityKey
      type: 'string'
    }
  ]

  @_mapSetting: (key, value) ->
    setting = {}
    setting[@_identityKey] = key
    setting.value = value
    setting

  @_fetchByKeyQuery: (key) ->
    whereCondition = {}
    whereCondition[@_identityKey] = key
    query = new Query()
    query.selectFrom(@_soupName).where(whereCondition)
    Force.smartstoreClient.impl.buildSmartQuerySpec(query.toString())

  @_parseResponse: (response) ->
    entities = response.currentPageOrderedEntries.reduce ((result, segment) -> result.concat segment), []
    setting = if entities.length then entities[0].value else null
    $.when(setting)

  @_initSoup: ->
    Force.smartstoreClient.soupExists(@_soupName).then (soupExist) =>
      unless soupExist then Force.smartstoreClient.registerSoup @_soupName, @_indexSpec else $.when()

  @setValueByKey: (key, value) =>
    @_initSoup().then =>
      setting = @_mapSetting key, value
      Force.smartstoreClient.upsertSoupEntriesWithExternalId @_soupName, [setting], @_identityKey

  @getValueByKey: (key) =>
    @_initSoup().then =>
      query = @_fetchByKeyQuery key
      Force.smartstoreClient.runSmartQuery(query)
      .then @_parseResponse

  @clearData: ->
    Force.smartstoreClient.soupExists(@_soupName)
    .then((soupExists) => Force.smartstoreClient.removeSoup @_soupName if soupExists)
    .done => @_initSoup

  @getTourPlanningSettings: =>
    @getValueByKey('tourPlanningSettings')
    .then (settings)=>
      defaultDuration = [5,10,15,20,25,30,35,40,45,50,55,60,90,120,240,300,480]
      defaultBreakTimeValue = (settings['defaultBreakTimeValue'] and parseInt(settings['defaultBreakTimeValue'])) or 15
      defaultDurationValue = (settings['defaultDurationValue'] and parseInt(settings['defaultDurationValue'])) or 30
      defaultLunchStartValue = Utils.timeFromString(settings['defaultLunchStartValue'] or '13:00')
      defaultLunchEndValue = Utils.timeFromString(settings['defaultLunchEndValue'] or '14:00')
      unless settings['duration']
        duration = defaultDuration
      else
        duration = settings['duration'].split(',').map (value)->parseInt value
        duration = defaultDuration unless duration.length
      $.when({
        breakDuration: moment({minutes: defaultBreakTimeValue}),
        callDuration: moment({minutes: defaultDurationValue}),
        lunchTimeStart: defaultLunchStartValue,
        lunchTimeEnd: defaultLunchEndValue,
        lastVisitTimeEnd: moment({hours: 20, minutes: 0}),
        duration: duration
      })

  @setLastSucceededSyncDateTime: (lastSyncDate)->
    @setValueByKey("lastSyncDate", lastSyncDate)

  @getLastSucceededSyncDateTime: (lastSyncDate)->
    @getValueByKey("lastSyncDate")

module.exports = SettingsManager