Spine = require 'spine'
PresentationStructureManager = require 'common/presentation-managers/presentation-structure-manager'
ScenarioSidebarGroup = require 'controllers/agenda/scenario-detail/scenario-sidebar-group'

class ScenarioDetailSlidesList extends Spine.Controller
  className: 'scenario-slides-list scroll-container'
  scroller: $ '<div class="scroll-content"></div>'

  _cumputeScrollerHeight: =>
    parentNode = @el.parent()
    parentHeight = parentNode.height()
    syblingsHeight = parentNode.children().outerHeight()
    @el.height "#{parentHeight - syblingsHeight}px"

  _onSlideSelected: (selectedSlide)=>
    @trigger 'sidebarSlideSelected', selectedSlide

  render: ->
    @el.scrollTop(0)
    @scroller.html ''
    @html @scroller
    @sidebarGroups = []
    if(@presentationStructure)
      @presentationStructure.forEach (chapter)=>
        sidebarGroup = new ScenarioSidebarGroup chapter
        sidebarGroup.render()
        @scroller.append sidebarGroup.el
        sidebarGroup.on 'sidebarSlideSelected', @_onSlideSelected
        @sidebarGroups.push sidebarGroup
      @_cumputeScrollerHeight()

  appendSlide: (slideData)=>
    if slideData.presentationId is @presentationId
      targetGroup = @sidebarGroups.filter((group)=>group.chapterData.id is slideData.chapterId)[0]
      targetGroup.addSlide slideData if targetGroup

  _isInSequence: (slide, sequence)=>
    sequence.filter (sequenceSlide)=>
      (slide.presentationId is sequenceSlide.presentationId) and (slide.id is sequenceSlide.id)
    .length > 0

  _updateSlidesState: (sequence)=>
    @presentationStructure = @presentationStructure.map (chapter)=>
      chapter.content = chapter.content.map (slide)=>
        slide.removed = @_isInSequence slide, sequence
        slide
      chapter

  renderPresentationSlides: (@presentationId, existsSequence)=>
    PresentationStructureManager.getParsedStructure @presentationId
    .done (@presentationStructure)=>
      @_updateSlidesState existsSequence
      @render()
    .fail =>
      @presentationStructure=[]
      @render()



module.exports = ScenarioDetailSlidesList