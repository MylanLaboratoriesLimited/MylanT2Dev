Spine = require 'spine'

class Button extends Spine.Controller

  className:"ctrl-btn"

  setTitle: (title)->
    @html title

module.exports = Button