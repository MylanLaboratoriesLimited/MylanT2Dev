AttachmentsTableCell = require 'controllers/trade-module/promotion-details/notes-attachments/attachments-table-cell'


class AttachmentsPopupTableCell extends AttachmentsTableCell
  elements:
    '.file-type': 'elFileType'
    '.name': 'elName'
    '.progress-bar-holder': 'elProgressBarHolder'
    '.check-box': 'elLoadedCheck'

  template: ->
    require('views/controls/popups/promotion-popup/notes-attachments-popup-table-cell')()

  _renderContent: =>
    @html @template()
    @elName.text @attachment.title
    @elFileType.text @attachment.title?.split('.').pop() or 'file'
    @_checkLoadState()


module.exports = AttachmentsPopupTableCell