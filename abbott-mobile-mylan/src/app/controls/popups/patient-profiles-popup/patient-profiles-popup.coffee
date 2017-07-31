BasePopup = require '/controls/popups/base-popup'
PatientProfilesPopupTable = require 'controls/popups/patient-profiles-popup/patient-profiles-popup-table'
PatientProfilesPopupTableCell = require 'controls/popups/patient-profiles-popup/patient-profiles-popup-table-cell'

class PatientProfilesPopup extends BasePopup
  className: "#{@::className} patient-profiles-popup"
  elements:
    '.scroll-container': 'elScrollContainer'

  _noneValue:
    isNone: true
    patientDisease: {}
    profileProduct:
      id:null
      patientProfileName: Locale.value('common:defaultSelectValue')
      age: ''
      gender: ''
      generalHealth: ''
      occupation: ''
      bmi: ''
      diseases: []

  constructor: (@patientProfiles, @selectedItem)->
    super null
    @patientProfiles.unshift(@_noneValue);
    @selectedItem = @_noneValue unless @selectedItem

  _renderContent: =>
    profilesTable = new PatientProfilesPopupTable
    profilesTable.datasource = @
    @elContent.html profilesTable.render().el
    @_scrollTableToSelectedItem(profilesTable)

  _scrollTableToSelectedItem: (profilesTable)=>
    selectedItemIndex = @patientProfiles.map( (el, index) => el.profileProduct.id is @selectedItem.profileProduct.id ).indexOf true
    profilesTable.scrollToItemIndex selectedItemIndex

  numberOfRowsForTable: (table) ->
    @patientProfiles.length

  cellForRowAtIndexForTable: (index, table) ->
    pationProfile = @patientProfiles[index]
    cell = new PatientProfilesPopupTableCell pationProfile
    if pationProfile.profileProduct.id is @selectedItem?.profileProduct.id then cell.setSelected()
    cell.on 'cellTap', (cell) => @trigger 'didChosePatientProfile', cell.patientProfile
    cell

module.exports = PatientProfilesPopup