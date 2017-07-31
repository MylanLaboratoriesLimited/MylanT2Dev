Spine = require 'spine'
Touchy = require 'common/touchy'
Home = require 'controllers/home'
Helpdesk = require 'controllers/helpdesk/helpdesk'
TabbarController = require 'controllers/tabbar/tabbar-controller'

class Main extends Spine.Stack
  className: 'main-stack stack-page'

  controllers:
    home: Home
    helpdesk: Helpdesk
    tabbar: TabbarController

  default: 'home'

  routes:
    '/home': 'home'
    '/helpdesk': 'helpdesk'
    '/tabbar/:tabName': 'tabbar'

  constructor: ->
    super
    @home.tabbar = @tabbar
    Spine.Route.setup()

module.exports = Main