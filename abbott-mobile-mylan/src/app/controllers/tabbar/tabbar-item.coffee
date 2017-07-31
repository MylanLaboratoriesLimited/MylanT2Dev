Spine = require 'spine'
StageTabbarItem = require 'controllers/tabbar/stage-tabbar-item'
Stage = require 'controllers/base/stage/stage'

class TabbarItem extends Spine.Controller
  className: 'tab-button'

  elements:
    '.tab-icon': 'elIcon'
    '.tab-title': 'elTitle'

  events:
    'tap': '_onTabbarItemTap'
    'doubleTap': '_popToRoot'

  title: null
  name: null
  pathToIcon: null
  controller: null
  action: null

  _onTabbarItemTap: (event) ->
    if @action then @action()
    else
      @trigger 'tabbarItemTap', @

  constructor: ->
    super
    if @controller
      stageController = new StageTabbarItem
      Stage.globalStage().add stageController
      @controller.stage = stageController
      stageController.add @controller

  active: ->
    super
    @render()
    @controller.stage.active()
    unless @_lastOpenedController().isActive()
      @controller.active()
    else
      @_lastOpenedController().activate()

  _lastOpenedController: ->
    _.last(@controller.stage.manager.controllers)

  render: ->
    @html @template()
    @setTitle @title
    @setIcon @pathToIcon
    @

  template: ->
    require 'views/tabbar/tabbar-item'

  setTitle: (@title) ->
    @elTitle.html @title()

  setIcon: (@pathToIcon) ->
    @elIcon.css { 
      '-webkit-mask': "url('#{@pathToIcon}') no-repeat center top"
      '-webkit-mask-size': 'auto 100%'
    }

  reset: =>
    @controller?.stage.resetToRoot()

  _popToRoot: =>
    @controller?.stage.popToRoot()

module.exports = TabbarItem