Stage = require 'controllers/base/stage/stage'

class StageTabbarItem extends Stage
  constructor: ->
    super
    @el.addClass 'stage-tabbar-item'

module.exports = StageTabbarItem