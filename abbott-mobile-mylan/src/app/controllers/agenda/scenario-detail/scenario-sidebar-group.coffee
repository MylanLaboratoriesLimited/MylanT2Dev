Spine = require 'spine'
ScenarioSidebarCell = require 'controllers/agenda/scenario-detail/scenario-detail-sidebar-cell'

class ScenarioSidebarGroup extends Spine.Controller
  className: 'sidebar-slide-group'
  elements:
    'h3.group-name': 'elChapterName'
    '.slides-list': 'elSlidesList'

  constructor: (@chapterData)->
    super {}

  template: =>
    require 'views/agenda/scenario-sidebar-group'

  render: ->
    @html @template()
    @groupCells = []
    @elChapterName.html @chapterData.name
    @chapterData.content.forEach (slideData)=>
      sidebarCell = new ScenarioSidebarCell slideData
      @groupCells.push sidebarCell
      unless slideData.removed
        sidebarCell.render()
        @elSlidesList.append sidebarCell.el
      sidebarCell.on 'sidebarSlideSelected', @_onCellSelected
    @_isHideGroup()

  addSlide: (slideData)=>
    targetCell = @groupCells.filter((cell)=>cell.slideData.id is slideData.id)[0]
    targetCell.slideData.removed = false
    @render()
    @_isHideGroup()


  _onCellSelected: (selectedCell)=>
    @trigger 'sidebarSlideSelected', selectedCell
    selectedCell.el.detach()
    @_isHideGroup()

  _isHideGroup: =>
    action = if @elSlidesList.children().length then 'removeClass' else 'addClass'
    @el[action] 'hidden'


module.exports = ScenarioSidebarGroup