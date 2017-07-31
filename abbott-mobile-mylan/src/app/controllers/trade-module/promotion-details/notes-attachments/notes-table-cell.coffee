Spine = require 'spine'
Utils = require 'common/utils'

class NotesTableCell extends Spine.Controller
  tag: 'tr'

  elements:
    ".note-type": "elType"
    ".progress-bar-holder": "elTitle"
    ".last-modify": "elLastModify"
    ".attached-by": "elAttachedBy"
    ".check-box": "elLoadedCheck"

  constructor: (@note) ->
    super {}

  template: ->
    require('views/trade-module/promotion-details/notes-attachments/notes-attachments-table-cell')()

  bindEvents: =>
    @el.on 'tap', @_onCellTap

  render: ->
    @html @template()
    @elType.text @note.sobjectType
    @elTitle.find('.title-label').text @note.title
    @elLastModify.html "#{Utils.dotFormatDate(@note.lastModify)}<br />#{Utils.formatTime(@note.lastModify)}"
    @elAttachedBy.text @note.attachedByName
    @elLoadedCheck.addClass 'checked'
    @bindEvents()
    @

  _onCellTap: (event) =>
    event.stopPropagation
    @trigger 'noteCellTap', @


module.exports = NotesTableCell