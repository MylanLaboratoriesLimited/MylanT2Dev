TabbarView = require 'controllers/tabbar/tabbar-view'
TabbarItem = require 'controllers/tabbar/tabbar-item'
Stage = require 'controllers/base/stage/stage'
Contacts = require 'controllers/contacts/contacts'
Activities = require 'controllers/activities/activities'
TourPlanning = require 'controllers/tour-planning/tour-planning'
Tots = require 'controllers/tots/tots'
Organizations = require 'controllers/organizations/organizations'
Media = require 'controllers/media/media'
SettingsManager = require 'db/settings-manager'

class TabbarController extends Stage.Global
  className: 'tabbar stack-page'

  constructor: ->
    super
    @tabbarView = new TabbarView [
      new TabbarItem action: @_goHome, title: @_tabbarItemTitle('tabbar.Home'), pathToIcon: 'img/tabbar/home.png'
      new TabbarItem controller: (new Activities), name: 'activities', title: @_tabbarItemTitle('tabbar.Activities'), pathToIcon: 'img/tabbar/activities.png'
      new TabbarItem controller: (new Contacts), name: 'contacts', title: @_tabbarItemTitle('tabbar.Contacts'), pathToIcon: 'img/tabbar/contacts.png'
      new TabbarItem controller: (new Organizations), name: 'organizations', title: @_tabbarItemTitle('tabbar.Organizations'), pathToIcon: 'img/tabbar/organizations.png'
      new TabbarItem controller: (new TourPlanning), name: 'tour-planning', title: @_tabbarItemTitle('tabbar.TourPlanning'), pathToIcon: 'img/tabbar/tour-planning.png'
      new TabbarItem controller: (new Tots), name: 'tots', title: @_tabbarItemTitle('tabbar.TimeOffTerritory'), pathToIcon: 'img/tabbar/tots.png'
      new TabbarItem controller: (new Media), name: 'media', title: @_tabbarItemTitle('tabbar.Media'), pathToIcon: 'img/tabbar/media.png'
    ]
    @footer.replaceWith @tabbarView.el
    @footer = @tabbarView.el

  _tabbarItemTitle: (titleLocale) ->
    -> Locale.value titleLocale

  activate: ->
    super
    @tabbarView?.activate()

  active: (params = {}) ->
    SettingsManager.getValueByKey('isEdetailingEnabled')
    .then (@isEdetailingEnabled) =>
      if @isEdetailingEnabled then @_showMedia() else @_hideMedia()
      super params
      @_activateTabControllerByName params.tabName

  _hideMedia: ->
    tabMedia = @tabbarView[@tabbarView.options.length-1]
    tabMedia.el.addClass 'hide'

  _showMedia: ->
    tabMedia = @tabbarView[@tabbarView.options.length-1]
    tabMedia.el.removeClass 'hide'

  _activateTabControllerByName: (tabName) ->
    @tabbarView[tabName]?.active()

  _goHome: =>
    # window.history.back()
    @navigate '/home'

  reset: =>
    @tabbarView.resetControllers()

module.exports = TabbarController