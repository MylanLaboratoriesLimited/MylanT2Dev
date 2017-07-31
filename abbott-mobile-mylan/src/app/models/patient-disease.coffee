Entity = require 'models/entity'

class PatientDisease extends Entity
  @table: 'PatientDisease'
  @sfdcTable: 'Patient_Disease__c'
  @description: 'Patient Disease'

  @schema: ->
    [
      {local:'id',                    sfdc:'Id'}
      {local:'diseaseSfId',           sfdc:'Disease__c'}
      {local:'diseaseName',           sfdc:'DiseaseName__c'}
      {local:'patientProfileSfId',    sfdc:'Patient_Profile__c', indexWithType:'string'}
    ]

module.exports = PatientDisease