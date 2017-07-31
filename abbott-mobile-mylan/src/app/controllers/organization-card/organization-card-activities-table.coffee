TableController = require 'controls/table/card-table'

class OrganizationCardActivitiesTable extends TableController
  elements:
    'tbody': 'elTbody'

  template: ->
    require('views/organization-card/organization-card-activities-table')()

module.exports = OrganizationCardActivitiesTable