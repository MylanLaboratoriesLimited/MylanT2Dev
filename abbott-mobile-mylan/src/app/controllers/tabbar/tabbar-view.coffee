Spine = require 'spine'

class TabbarView extends Spine.Stack
  tag: 'footer'

  constructor: (tabbarItems) ->
    super
    tabbarItems.forEach (tabbarItem, index) =>
      tabbarItem.on 'tabbarItemTap', (tabItem) -> tabItem.active() unless tabItem.isActive()
      tabbarItem.stack = @
      @[tabbarItem.name] = tabbarItem
      @add tabbarItem.render()

  _doForEachController: (action) ->
    action controller for controller in @manager.controllers

  resetControllers: =>
    @_doForEachController (controller) -> controller.reset()

  activate: ->
    @_doForEachController (controller) -> controller.render()

module.exports = TabbarView