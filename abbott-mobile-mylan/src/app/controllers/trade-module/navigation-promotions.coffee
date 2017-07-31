HeaderBaseControl = require 'controls/header-controls/header-base-control'

class NavigationPromotions extends Spine.Controller
  className: 'navigation-promotions'

  elements:
    '.current': 'elCurrent'
    '.total': 'elTotal'

  constructor: (@currentPromotionIndex, @totalPromotions) ->
    super {}

  render: ->
    @html @_template()
    @prev = new HeaderBaseControl Locale.value('common:buttons.Prev'), 'ctrl-btn'
    @next = new HeaderBaseControl Locale.value('common:buttons.Next'), 'ctrl-btn'
    @append @prev.el, @next.el
    @_setupForCurrentPromotionIndex()
    @_bindEvents()
    @

  _template: ->
    require 'views/trade-module/navigation-promotions'

  _setupForCurrentPromotionIndex: ->
    @elCurrent.html @currentPromotionIndex+1
    @elTotal.html @totalPromotions

  _bindEvents: ->
    @prev.bind 'tap', @_onPrevTap
    @next.bind 'tap', @_onNextTap

  _onPrevTap: =>
    @trigger 'prevBtnTap'

  _onNextTap: =>
    @trigger 'nextBtnTap'

module.exports = NavigationPromotions
