class SfdcInitializer
  constructor: (@successCB, @errorCB) ->

  setupSalesforceCredentials: ->
    cordova.require("salesforce/plugin/oauth").getAuthCredentials @_getAuthCredentialsSuccess, @_getAuthCredentialsError
    document.addEventListener "salesforceSessionRefresh", @_salesforceSessionRefreshed, false

  _salesforceSessionRefreshed: (creds) =>
    Force.init creds, apiVersion, null, cordova.require("salesforce/plugin/oauth").forcetkRefresh

  _getAuthCredentialsSuccess: (creds) =>
    console.log "Auth Success: #{JSON.stringify creds}"
    @_salesforceSessionRefreshed creds
    @successCB creds

  _getAuthCredentialsError: (error) =>
    console.log "Auth Error: #{JSON.stringify error}"
    @errorCB error

module.exports = SfdcInitializer