TableCell = require 'controls/table/table-cell'

class NotesPopupTableCell extends TableCell

  elements:
    '.file-icon': 'elIcon'
    '.name': 'elName'
    '.progress-bar': 'elProgressBar'
    '.check-box': 'elLoadedCheck'

  constructor: (@note) ->
    super {}

  template: ->
    require('views/controls/popups/promotion-popup/notes-attachments-popup-table-cell')()

  render: ->
    @html @template()
    @elIcon.addClass 'note'
    @elName.text @note.title
    @elLoadedCheck.addClass 'checked'
    @

  bindEvents: ->
    @el.on 'tap', @_onCellTap

  _onCellTap: =>
    @trigger 'noteCellTap', @


module.exports = NotesPopupTableCell