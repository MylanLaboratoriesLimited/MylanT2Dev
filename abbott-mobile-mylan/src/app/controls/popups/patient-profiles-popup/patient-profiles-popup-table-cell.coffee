TableCell = require 'controls/table/table-cell'

class PatientProfilesPopupTableCell extends TableCell
  tag: 'tr'

  elements:
    '.name': 'elName'
    '.age': 'elAge'
    '.gender': 'elGender'
    '.general-health': 'elGeneralHealth'
    '.occupation': 'elOccupation'
    '.bmi': 'elBmi'
    '.diseases': 'elDiseases'

  constructor: (@patientProfile) ->
    super

  template: ->
    require('views/controls/popups/patient-profiles-popup/patient-profiles-popup-table-cell')()

  render: ->
    super
    @elName.text @patientProfile.profileProduct.patientProfileName
    @elAge.text @patientProfile.profileProduct.age
    @elGender.text @patientProfile.profileProduct.gender
    @elGeneralHealth.text @patientProfile.profileProduct.generalHealth
    @elOccupation.text @patientProfile.profileProduct.occupation
    @elBmi.text @patientProfile.profileProduct.bmi
    diseasesNames = @patientProfile.patientDiseases?.map((patientDisease)=>
        patientDisease.diseaseName;
    ).join(", ");

    @elDiseases.text diseasesNames
    @bindEvents()
    @

  bindEvents: =>
    @el.on 'tap', @_onCellTap

  setSelected: ->
    @el.addClass 'selected'

  _onCellTap: =>
    @trigger 'cellTap', @

module.exports = PatientProfilesPopupTableCell