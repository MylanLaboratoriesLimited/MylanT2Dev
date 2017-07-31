Spine = require 'spine'
ScenariosGridViewCell = require 'controllers/agenda/scenarios-grid-view-cell'
PresentationsFileManager = require 'common/presentation-managers/presentations-file-manager'
DragAndDrop = require 'common/drag-and-drop'

class ScenariosGridView extends Spine.Controller
  className: 'scenarios-grid-view scroll-content'

  RESET_TIME: 300
  cells: []

  clear: =>
    @cells.forEach (cellObject) => cellObject.removeCell()

  loadScenarios: (scenario = []) =>
    @cells = []
    @html ''
    scenario.forEach (slideObject) =>
      @addCell(slideObject)

  addCell: (slideObject) =>
    scenariosGridViewCell = new ScenariosGridViewCell slideObject
    scenariosGridViewCell.on 'gridRemoveCell', @_removeCell
    @append scenariosGridViewCell.render().el
    new DragAndDrop scenariosGridViewCell, @el,
      onStart: @_onCellDndStart
      onMove: @_onCellDndMove
      onEnd: @_onCellDndEnd
    @cells.push scenariosGridViewCell
    @_triggerSequenceUpdate()

  _removeCell: (cellObject) =>
    @cells = @cells.filter (cell) => !@_isSameSlides(cell, cellObject)
    @_triggerSequenceUpdate()
    @trigger 'gridRemoveCell', cellObject
    cellObject.release()

  _triggerSequenceUpdate: =>
    @trigger 'scenarioSequenceUpdate', @cells

  _onCellDndStart: (dndObj)=>
    dndObj.element.addClass 'zoomed'

  _onCellDndMove: (dndObj)=>
    @trigger 'onCellMove', dndObj

  _onCellDndEnd: (dndObj)=>
    dndObj.element.removeClass 'zoomed'
    @_onCellDown dndObj

  _inRect: (pointX, pointY, element) =>
    offset = element.offset()
    inHorizintal = pointX >= offset.left and pointX <= offset.left + element.outerWidth()
    inVertical = pointY >= offset.top and pointY <= offset.top + element.outerHeight()
    inHorizintal and inVertical

  _getCellCenter: (element) =>
    offset = element.offset()
    x: offset.left + element.outerWidth() / 2
    y: offset.top + element.outerHeight() / 2

  _insertAfter: (newNode, referenceNode) =>
    referenceNode.parentNode.insertBefore newNode, referenceNode.nextSibling

  _replaceCell: (indexDest, indexSrc) =>
    destCell = @cells.splice(indexSrc, 1)[0]
    @cells.splice(indexDest, 0, destCell)
    @_triggerSequenceUpdate()

  _indexOf: (cellObject) =>
    result = null
    @cells.forEach (obj, index) => result = index if @_isSameSlides(obj, cellObject)
    result

  _isSameSlides: (cellObject1, cellObject2) =>
    slide1 = cellObject1.slideObject
    slide2 = cellObject2.slideObject
    slide1.id is slide2.id and slide1.presentationId is slide2.presentationId

  _onCellDown: (dndObj) =>
    cellCenter = @_getCellCenter dndObj.element
    targetCell = @cells.filter (cellObject) => @_inRect(cellCenter.x, cellCenter.y, cellObject.el) and !@_isSameSlides(dndObj.cellObject, cellObject)
    if targetCell.length is 1
      dndObj.reset()
      $targetElement = targetCell[0].el
      targetIndex = @_indexOf targetCell[0]
      dndIndex = @_indexOf dndObj.cellObject
      if targetIndex > dndIndex
        @_insertAfter dndObj.element[0], $targetElement[0]
      else
        @el[0].insertBefore dndObj.element[0], $targetElement[0]
      @_replaceCell targetIndex, dndIndex
    else
      dndObj.reset @RESET_TIME

module.exports = ScenariosGridView