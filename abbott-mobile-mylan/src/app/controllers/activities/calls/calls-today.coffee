Spine = require 'spine'
Calls = require 'controllers/activities/calls/calls'
CallsTodayCollection = require 'models/bll/call-reports-collection/calls-today-collection'

class CallsToday extends Calls
  className: 'table-view calls today'

  createCollection: =>
    new CallsTodayCollection

module.exports = CallsToday