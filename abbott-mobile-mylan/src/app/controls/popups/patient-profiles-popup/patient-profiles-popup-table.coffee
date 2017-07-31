TableController = require 'controls/table/card-table'

class PatientProfilesPopupTable extends TableController
  elements:
    '.scroll-container': 'elScrollContainer'
    '.scroll-content tbody': 'elTbody'

  template: ->
    require('views/controls/popups/patient-profiles-popup/patient-profiles-popup-table')()

  scrollToItemIndex: (itemIndex)=>
    @elScrollContainer.scrollTop(@elTbody.children().eq(itemIndex).position().top)
    window.elScrollContainer = @elScrollContainer

module.exports = PatientProfilesPopupTable