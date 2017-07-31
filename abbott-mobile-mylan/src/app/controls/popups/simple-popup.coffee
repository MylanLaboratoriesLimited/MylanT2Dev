BasePopup = require 'controls/popups/base-popup'

class SimplePopup extends BasePopup

  className: "#{@::className} simple-popup"

  constructor: (@content)->
    super ''

  _renderContent: =>
    @elContent.text @content


module.exports = SimplePopup
