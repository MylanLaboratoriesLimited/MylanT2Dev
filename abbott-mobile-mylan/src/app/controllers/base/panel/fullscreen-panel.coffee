Stage = require 'controllers/base/stage/stage'
PanelScreen = require 'controllers/base/panel/panel-screen'

class FullscreenPanel extends PanelScreen
  activate: (params = {}) =>
    super params
    @enableFullScreenMode()

  enableFullScreenMode: ->
  	Stage.globalStage().el.addClass 'fullscreen-panel-mode'

  deactivate: (params = {}) =>
    super params
    @disableFullScreenMode()

  disableFullScreenMode: ->
    Stage.globalStage().el.removeClass 'fullscreen-panel-mode'

module.exports = FullscreenPanel