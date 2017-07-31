SettingsManager = require 'db/settings-manager'
DeviceManager = require 'common/device-manager'
EmailManager = require 'common/email-manager'

class LogManager
  @_logStorageKey: 'LastDebugLog'
  @_maxLogLength: 32768
  @log: ''
  @errorMessagesLog: ''
  @logDateFormat: 'HH:mm:ss:SSS'
  @startDateFormat: 'DD.MM.YYYY HH:mm'
  @lineSeparator: '\n'
  @_stepIndexKey:'stepIndex'

  @initLog: =>
    @log = @_prepareFirstLog()

  @_prepareFirstLog: ->
    date = "#{moment().format @startDateFormat}#{@lineSeparator}"
    OSVersion = "#{Locale.value('helpdesk.OSVersion')}-#{DeviceManager.osVersion()}#{@lineSeparator}"
    appVersion = "#{Locale.value('helpdesk.LogScreen.AppVersion')}-#{DeviceManager.appVersion()}#{@lineSeparator}"
    firstLog = date + OSVersion + appVersion
    @saveDebugLog firstLog
    .then -> console.log "SAVED"
    firstLog

  @appendInfoLog: (message) ->
    @log += "#{Locale.value('helpdesk.LogScreen.Info')} #{@_formatedDate()}-#{message}#{@lineSeparator}"
    @saveDebugLog @log + @lineSeparator

  @updateStepsCount: (stepsCount)->
    @log = @log.replace(@_stepIndexKey,stepsCount)
    @saveDebugLog @log + @lineSeparator

  @appendError: (error) ->
    @log += "#{Locale.value('helpdesk.LogScreen.Error')} #{@_formatedDate()}#{@lineSeparator}#{@_prepareLogData error}#{@lineSeparator}"
    @saveDebugLog @log

  @appendWarning: (warning) ->
    @log += "#{Locale.value('helpdesk.LogScreen.Warning')} #{@_formatedDate()}#{@lineSeparator}#{@_prepareLogData warning}#{@lineSeparator}"
    @saveDebugLog @log

  @sendLogToSf: =>
    @getLastDebugLog()
    .done (logData) =>
      logData = if logData then logData.split(@lineSeparator) else []
      deviceId = "#{Locale.value('helpdesk.LogScreen.DeviceId')}: #{DeviceManager.deviceId()}"
      logData.unshift deviceId
      EmailManager.sendMail 'Abbott mobile log.', logData.join('<br/>')
    .fail (error) ->
      console.log error

  @_setLastDebugLog: (lastDebugLog) ->
    if lastDebugLog.length > @_maxLogLength
      lastDebugLog = lastDebugLog.substring(lastDebugLog.length - @_maxLogLength + 5, lastDebugLog.length - 1)
      lastDebugLog = "...#{lastDebugLog}"
    @log = lastDebugLog

  @saveDebugLog: (log) ->
    SettingsManager.setValueByKey(@_logStorageKey, log)
    .then -> console.log log

  @getLastDebugLog: ->
    SettingsManager.getValueByKey(@_logStorageKey)

  @_prepareLogData: (error) ->
    JSON.stringify error

  @_formatedDate: ->
    moment().format @logDateFormat

module.exports = LogManager