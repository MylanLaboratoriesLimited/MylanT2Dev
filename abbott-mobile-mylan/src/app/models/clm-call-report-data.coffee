Entity = require 'models/entity'

class CLMCallReportData extends Entity
  @table: 'CLMCallReportData'
  @sfdcTable: 'Clm_CallReportData__c'
  @description: 'CLM Call Report Data'

  @schema: ->
    [
      {local:'id',                     sfdc:'Id'}
      {local:'kpiSrcJson',             sfdc:'KpiSrcJson__c',         upload: true}
      {local:'timeOnPresentation',     sfdc:'TimeOnPresentation__c',         upload: true}
      {local:'timeOnSlides',           sfdc:'TimeOnSlides__c',         upload: true}
      {local:'callReportId',           sfdc:'CallReport__c', indexWithType: 'string', upload: true}
      {local:'productId',              sfdc:'Product__c',         upload: true}
      {local:'clmToolId',              sfdc:'CLM_Tool_Id__c',                         upload: true}
    ]

module.exports = CLMCallReportData