Utils = require 'common/utils'
AttachmentsTableCell = require 'controllers/trade-module/promotion-details/notes-attachments/attachments-table-cell'


class NotesAttachmentsTableCell extends AttachmentsTableCell
  tag: 'tr'

  elements:
    ".note-type": "elType"
    ".progress-bar-holder": "elProgressBarHolder"
    ".last-modify": "elLastModify"
    ".attached-by": "elAttachedBy"
    ".check-box": "elLoadedCheck"

  template: ->
    require('views/trade-module/promotion-details/notes-attachments/notes-attachments-table-cell')()

  _renderContent: =>
    @html @template()
    @elType.text @attachment.sobjectType
    @elProgressBarHolder.find('.title-label').text @attachment.title
    @elLastModify.html "#{Utils.dotFormatDate(@attachment.lastModify)}<br />#{Utils.formatTime(@attachment.lastModify)}"
    @elAttachedBy.text @attachment.attachedByName
    @_checkLoadState()
    @bindEvents()

module.exports = NotesAttachmentsTableCell