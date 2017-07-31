class ConfigurationManager
  @_configId: 1
  @_identityKey: 'id'
  @_restPath: '/clmconfiguration'
  @_soupName: 'Configuration'
  @_indexSpec = [
    {
      path: @_identityKey
      type: 'string'
    }
  ]

  @_initSoup: ->
    Force.smartstoreClient.soupExists(@_soupName).then (soupExist) =>
      unless soupExist then Force.smartstoreClient.registerSoup @_soupName, @_indexSpec else $.when()

  @loadConfig: =>
    @_initSoup().then =>
      Force.forcetkClient.apexrest(@_restPath, 'GET', '', {}).then (configurationData) =>
        configurationData[@_identityKey] = @_configId
        Force.smartstoreClient.upsertSoupEntriesWithExternalId @_soupName, [configurationData], @_identityKey

  @getConfig: (segmentKey) =>
    @_initSoup().then =>
      Force.smartstoreClient.retrieveSoupEntries(@_soupName, [@_configId])
      .then (entities) =>
        config = if entities.length then entities[0] else null
        config = config[segmentKey] if segmentKey and config
        config

module.exports = ConfigurationManager