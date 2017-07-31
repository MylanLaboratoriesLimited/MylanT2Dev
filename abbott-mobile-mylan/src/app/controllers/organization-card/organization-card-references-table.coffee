TableController = require 'controls/table/card-table'

class OrganizationCardReferencesTable extends TableController
  elements:
    'tbody': 'elTbody'

  template: ->
    require('views/organization-card/organization-card-references-table')()

module.exports = OrganizationCardReferencesTable