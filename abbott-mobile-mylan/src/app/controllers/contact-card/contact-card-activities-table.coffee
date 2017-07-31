TableController = require 'controls/table/card-table'

class ContactCardActivitiesTable extends TableController
  elements:
    'tbody': 'elTbody'

  template: ->
    require('views/contact-card/contact-card-activities-table')()

module.exports = ContactCardActivitiesTable