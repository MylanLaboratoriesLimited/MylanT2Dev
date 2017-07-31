Spine = require 'spine'
SyncLogManager = require 'common/log-manager'

class ViewLog extends Spine.Controller
  className: 'view-log'

  constructor: ->
    super
    @_getLogData @render

  render: (logData) =>
    @_renderLogData logData
    @

  _getLogData: (successCallback) =>
    SyncLogManager.getLastDebugLog()
    .then @render

  _renderLogData: (logData) =>
    logData = if logData then logData.split(SyncLogManager.lineSeparator).join '<br/>' else ''
    logViewTemplate = require('views/helpdesk/view-log')(logData: logData)
    @html logViewTemplate

module.exports = ViewLog