TableController = require 'controls/table/card-table'

class ContactCardReferencesTable extends TableController
  elements:
    'tbody': 'elTbody'

  template: ->
    require('views/contact-card/contact-card-references-table')()

module.exports = ContactCardReferencesTable