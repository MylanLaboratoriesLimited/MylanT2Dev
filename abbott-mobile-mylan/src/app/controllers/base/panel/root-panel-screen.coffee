PanelScreen = require 'controllers/base/panel/panel-screen'

class RootPanelScreen extends PanelScreen
  onBack: =>
    @navigate '/home'

module.exports = RootPanelScreen