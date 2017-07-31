Spine = require 'spine'
NotesAttachmentsTable = require 'controllers/trade-module/promotion-details/notes-attachments/notes-attachments-table'
AttachmentsTradeTableCell = require 'controllers/trade-module/promotion-details/notes-attachments/attachments-trade-table-cell'
NotesTableCell = require 'controllers/trade-module/promotion-details/notes-attachments/notes-table-cell'
PromotionNotesCollection = require 'models/bll/promotion-notes-collection'
PromotionAttachmentsCollection = require 'models/bll/promotion-attachments-collection'
PromotionNotePopup = require '/controls/popups/promotion-note-popup'
AttachmentLoadManager = require 'common/attachment-managers/attachment-load-manager'
AttachmentsManager = require 'common/attachment-managers/attachments-manager'
AttachmentFileManager = require 'common/attachment-managers/attachment-file-manager'
Utils = require 'common/utils'
PromotionAttachment = require 'models/promotion-attachment'


class Notes extends Spine.Controller
  className: 'notes stack-page'

  constructor: (@promotionAccount) ->
    super {}
    @promotionNotesCollection = new PromotionNotesCollection
    @promotionAttachmentsCollection = new PromotionAttachmentsCollection

  active: ->
    super
    @render()

  render: ->
    @promotionAttachmentsCollection.getAllAttachmentsForPromotionWithId(@promotionAccount.promotionSfId)
    .then (@attachments) =>
      @promotionNotesCollection.getAllNotesForPromotionWithId(@promotionAccount.promotionSfId)
      .then (@notes) =>
        if _.isEmpty(@attachments) and _.isEmpty(@notes) then @_renderEmptyTemplate()
        else
          @notesAndAttachments = @attachments.concat @notes
          notesAttachmentsTable = new NotesAttachmentsTable
          notesAttachmentsTable.datasource = @
          @el.html notesAttachmentsTable.render().el
          Locale.localize @el
    @

  numberOfRowsForTable: (table) =>
    @notesAndAttachments.length

  _renderEmptyTemplate: ->
    @html Locale.value('tradeModule.Notes.NoNotes')
    @el.addClass 'empty-tab'

  cellForRowAtIndexForTable: (index, table) =>
    record = @notesAndAttachments[index]
    if record instanceof PromotionAttachment
      @_createAttachmentTableCell record
    else
      @_createNoteTableCell record

  _onNoteCellTap: (cell) =>
    new PromotionNotePopup(cell.note).show()

  _onAttachmentCellTap: (cell) =>
    attachment = cell.attachment
    if(attachment.loaded)
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

  _createAttachmentTableCell: (attachment) ->
    new AttachmentsTradeTableCell(attachment)
    .on 'attachmentCellTap', @_onAttachmentCellTap

  _createNoteTableCell: (note) ->
    new NotesTableCell(note)
    .on 'noteCellTap', @_onNoteCellTap

module.exports = Notes