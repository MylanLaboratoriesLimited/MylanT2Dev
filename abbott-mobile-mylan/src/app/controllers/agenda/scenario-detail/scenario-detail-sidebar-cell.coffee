Spine = require 'spine'
PresentationFileManager = require 'common/presentation-managers/presentations-file-manager'

class ScenarioSidebarCell extends Spine.Controller
  className: 'slide-item'
  tag: 'li'
  elements:
    '.slide-thumb': 'elThumbnail'
    '.slide-name': 'elSlideName'

  _onCellTap: =>
    @slideData.removed = true
    @trigger 'sidebarSlideSelected', @

  _bindEvents: =>
    @el.bind 'tap', @_onCellTap

  constructor: (@slideData)->
    super {}

  template: =>
    require 'views/agenda/sidebar-slide-cell'

  render: ->
    @html @template()
    @elSlideName.html @slideData.name
    fullPath = @_rootPathForPresentationWithId(@slideData.presentationId) + @slideData.thumbnail
    @elThumbnail.css 'background-image', "url('#{fullPath}')"
    @_bindEvents()

  _rootPathForPresentationWithId: (presentationId) =>
    PresentationFileManager.getPathToPresentation presentationId

module.exports = ScenarioSidebarCell