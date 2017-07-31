TableController = require 'controls/table/table-controller'
AttachmentsTableCell = require 'controls/popups/promotion-popup/attachments-popup-table-cell'
NotesTableCell = require 'controls/popups/promotion-popup/notes-popup-table-cell'
PromotionNotesCollection = require 'models/bll/promotion-notes-collection'
PromotionAttachmentsCollection = require 'models/bll/promotion-attachments-collection'
PromotionAttachment = require 'models/promotion-attachment'
AttachmentLoadManager = require 'common/attachment-managers/attachment-load-manager'
AttachmentFileManager = require 'common/attachment-managers/attachment-file-manager'
AttachmentsManager = require 'common/attachment-managers/attachments-manager'
Utils = require 'common/utils'


class NotesAttachmentsPopupTable extends TableController
  className: "#{@::className} notes-attachments-popup-table"

  constructor: ->
    super @
    @promotionNotesCollection = new PromotionNotesCollection
    @promotionAttachmentsCollection = new PromotionAttachmentsCollection
    @notesAttachments = []

  refreshTableByPromoId: (promoId) ->
    $.when( @_refreshAttachments(promoId), @_refreshNotes(promoId) )
    .then (attachments, notes) =>
      if _.isEmpty(attachments) and _.isEmpty(notes) then @_renderEmptyTable(@el, Locale.value('tradeModule.Notes.NoNotes') )
      else
        @notesAttachments = attachments.concat notes
        @render().el.removeClass 'empty-table'

  _refreshAttachments: (promoId) ->
    @promotionAttachmentsCollection.getAllAttachmentsForPromotionWithId(promoId)

  _refreshNotes: (promoId) ->
    @promotionNotesCollection.getAllNotesForPromotionWithId(promoId)

  _renderEmptyTable: (tableElement, text) ->
    tableElement.addClass 'empty-table'
    .html "<p>#{text}</p>"

  numberOfRowsForTable: (table) ->
    @notesAttachments?.length ? 0

  cellForRowAtIndexForTable: (index, table) ->
    @_createTableCell @notesAttachments[index]

  _createTableCell: (record) ->
    if record instanceof PromotionAttachment
      @_createAttachmentTableCell record
    else
      @_createNoteTableCell record

  _createAttachmentTableCell: (attachment) ->
    new AttachmentsTableCell(attachment)
    .on 'attachmentCellTap', @_onAttachmentCellTap

  _createNoteTableCell: (note) ->
    new NotesTableCell(note)
    .on 'noteCellTap', @_showNote

  _showNote: (noteCell) =>
    @trigger 'showNote', noteCell

  _onAttachmentCellTap: (cell) =>
    attachment = cell.attachment
    if attachment.loaded
      filePath = AttachmentFileManager.getFilePath(attachment.body, attachment.title)
      AttachmentsManager.open filePath, attachment.contentType
    else
      return $.fn.dpToast Locale.value("AttachmentsPopup.Offline") unless Utils.deviceIsOnline()
      unless AttachmentLoadManager.getLoaderForAttachment(attachment)
        cell.addProgress()
        AttachmentLoadManager.queueInvoke(attachment, {
          onStateChange: cell.onLoadStateChange
          onSuccess: cell.onLoadSuccess
          onFail: cell.onLoadFail
        })


module.exports = NotesAttachmentsPopupTable