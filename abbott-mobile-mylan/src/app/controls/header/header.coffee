BaseHeader = require 'controls/header/base-header'

class Header extends BaseHeader
  events:
    'tap .back': '_onBackClick'

  template: ->
    require 'views/controls/header/header'

  _onBackClick: =>
    @trigger 'backbutton', @

module.exports = Header