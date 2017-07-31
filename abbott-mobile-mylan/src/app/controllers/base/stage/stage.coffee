SpineMobileStage = require 'spine.mobile/lib/stage'

class Stage extends SpineMobileStage
  push: (panel, animated = true) ->
    panel.stage = @
    @add panel
    panel.active @_animation(animated, 'right')

  pop: (animated = true) ->
    [previous, current] = _.last @manager.controllers, 2
    current.deactivate @_animation(animated, 'left') if current
    previous.activate @_animation(animated, 'left')
    @delay(current.release, @effectDefaults.duration) if current

  popAndPush: (panel, animated = true) ->
    current = _.last @manager.controllers
    if current
      current.deactivate @_animation(false, 'left')
      current.release()
    @push panel, animated

  resetToRoot: ->
    _.first(@manager.controllers).deactivate()
    _(@manager.controllers).chain().rest().each (controller) -> controller.release()

  popToRoot: ->
    _(@manager.controllers).chain().rest().each (controller) -> controller.release()
    _.first(@manager.controllers).activate()

  _animation: (animated, direction) -> 
    if animated is true then { trans: direction } else {}

class Stage.Global extends Stage
  global: true

module.exports = Stage