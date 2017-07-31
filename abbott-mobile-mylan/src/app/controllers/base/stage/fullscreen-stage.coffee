Stage = require 'controllers/base/stage/stage'

class FullscreenStage extends Stage
  className: 'fullscreen-stage-screen'

  activate: (params = {}) =>
    super params
    Stage.globalStage().el.addClass 'fullscreen-stage-mode'

  release: =>
    super
    Stage.globalStage().el.removeClass 'fullscreen-stage-mode fullscreen-panel-mode'

  setPanel: (@_panel) =>
    @_panel.stage = @
    @add @_panel

  showInContext: (context) =>
    context.append @
    @activate()
    @_panel.active()

  pop: =>
    if @manager.controllers.length > 1 then super
    else
      @trigger 'close', @

module.exports = FullscreenStage