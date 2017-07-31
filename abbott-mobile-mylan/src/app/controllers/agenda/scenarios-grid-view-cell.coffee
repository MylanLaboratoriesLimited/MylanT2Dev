Spine = require 'spine'
PresentationFileManager = require 'common/presentation-managers/presentations-file-manager'

class ScenariosGridViewCell extends Spine.Controller
  className: 'scenarios-grid-view-cell'

  events:
    "tap .scenarios-grid-view-cell-remove": "_removeCell"

  elements:
    '.scenarios-grid-view-cell-title': 'elTitle'
    '.scenarios-grid-view-cell-icon': 'elIcon'
    '.scenarios-grid-view-cell-name': 'elName'

  constructor: (slideObject) ->
    super {}
    @slideObject = slideObject

  template: ->
    require 'views/agenda/scenarios-grid-view-cell'

  render: =>
    @html @template()
    @elTitle.html @slideObject.presentationName
    @elName.html @slideObject.name
    fullPath = @_rootPathForPresentationWithId(@slideObject.presentationId) + @slideObject.thumbnail
    @elIcon.css "backgroundImage", "url('#{fullPath}')"
    @

  _rootPathForPresentationWithId: (presentationId) =>
    PresentationFileManager.getPathToPresentation presentationId

  _removeCell: =>
    @trigger 'gridRemoveCell', @

module.exports = ScenariosGridViewCell