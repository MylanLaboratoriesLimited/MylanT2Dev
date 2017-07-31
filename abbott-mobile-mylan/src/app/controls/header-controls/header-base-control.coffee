Spine = require 'spine'

class HeaderBaseControl extends Spine.Controller

  events:
    'tap': '_tap'

  constructor: (title, @className) ->
    super {}
    @updateTitle title

  _tap: ->
    @trigger 'tap', @

  updateTitle: (title) ->
    @html title

module.exports = HeaderBaseControl