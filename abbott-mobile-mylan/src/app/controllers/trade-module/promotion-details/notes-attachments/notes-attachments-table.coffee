TableController = require 'controls/table/card-table'

class NotesAttachmentsTable extends TableController

  elements:
    '.scroll-content tbody': 'elTbody'

  template: ->
    require('views/trade-module/promotion-details/notes-attachments/notes-attachments-table')()

module.exports = NotesAttachmentsTable