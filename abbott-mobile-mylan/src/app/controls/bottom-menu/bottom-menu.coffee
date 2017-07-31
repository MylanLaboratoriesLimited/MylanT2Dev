Spine = require 'spine'
Alarm = require 'common/alarm/alarm'
LockManager = require 'common/lock-manager'
SforceDataContext = require 'models/bll/sforce-data-context'
Locale = require 'common/localization/locale'
AlertPopup = require 'controls/popups/alert-popup'
Utils = require 'common/utils'

class BottomMenu extends Spine.Controller
  className: 'bottom-menu'
  tagName: 'ul'
  isVisible: false

  elements:
    'li': 'buttons'
    'li[data-action="dynamicAgenda"]': 'elAgenda'

  template: ->
    require('views/controls/bottom-menu/bottom-menu')()

  constructor: ->
    super
    @isAgendaHidden = false

  show: ->
    unless @isVisible
      app.mainController.append @
      @render()

  hide: ->
    if @isVisible
      @el.removeClass 'open'
      setTimeout =>
        @release()
        @isVisible = false
      , 400
    @

  hideAgenda: ->
    @isAgendaHidden = true

  showAgenda: ->
    @isAgendaHidden = false

  toggle: ->
    @hide() if @isVisible
    @show() unless @isVisible

  render: ->
    @html @template()
    @elAgenda.css 'display', 'none' if @isAgendaHidden
    Locale.localize @el
    @_bindEvents()
    setTimeout =>
      @el.addClass 'open'
      @isVisible = true
    , 100
    @

  _bindEvents: ->
    @el.bind 'touchmove', (event) -> event.preventDefault()
    @buttons.on 'tap', @_menuButtonAction

  _menuButtonAction: (event) =>
    event.stopPropagation()
    @hide()
    action = $(event.currentTarget).data 'action'
    @_handlePanelEvent action

  _openDynamicAgenda: =>
    @trigger 'openDynamicAgenda', @

  _showOfflineAlert: ->
    alertPopup = new AlertPopup { caption: Locale.value('home.AlertPopup.Caption'), message: Locale.value('home.AlertPopup.Message') }
    alertPopup.bind 'yesClicked', alertPopup.hide
    alertPopup.show()

  _handlePanelEvent: (actionName) ->
    switch actionName
      when 'alarm' then Alarm.setup()
      when 'helpdesk' then @navigate '/helpdesk'
      when 'language' then @trigger 'changeLanguage', @
      when 'lock' then LockManager.lock()
      when 'logout'
        return @_showOfflineAlert() unless Utils.deviceIsOnline()
        SforceDataContext.logout()
      when 'dynamicAgenda' then @_openDynamicAgenda()

module.exports = BottomMenu