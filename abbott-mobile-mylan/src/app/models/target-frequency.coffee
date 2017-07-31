Entity = require 'models/entity'
Utils = require 'common/utils'

class TargetFrequency extends Entity
  @table: 'TargetFrequency'
  @sfdcTable: 'TF__c'
  @description: 'Target Frequency'

  @schema: ->
    [
      {local:'id',                    sfdc:'Id'}
      {local:'marketingCycleSfId',    sfdc:'Marketing_Cycle__c', indexWithType:'string'}
      {local:'targetSfId',            sfdc:'Target__c'}
      {local:'customerSfId',          sfdc:'Customer__c', indexWithType:'string'}
      {local:'isActive',              sfdc:'Active_TMF__c'}
      {local:'actualCallsCount',      sfdc:'Actual_Calls__c'}
      {local:'mcTargetFrequency',     sfdc:'MC_Target_Frequency_c__c'}
      {local:'isPharmacist',          sfdc:'IsPharmacist__c'}
      {local:'priority',              sfdc:'Priority__c'}
      {local:'targetCycleFrequency',  sfdc:'Target_Cycle_Frequency__c'}
      {local:'lastCallReportDate',    sfdc:'Last_Call_Report_Date__c', indexWithType:'string'}
      {local:'medrepId',              sfdc:'Target__r.MedRep__r.Id', indexWithType:'string'}
      {local:'medrepFirstName',       sfdc:'Target__r.MedRep__r.FirstName'}
      {local:'medrepLastName',        sfdc:'Target__r.MedRep__r.LastName'}
    ]

  lastCallReportDateFormated: ->
    if @lastCallReportDate then Utils.dotFormatDate(@lastCallReportDate) else ''

  medrepFullName: ->
    "#{@medrepLastName ? ''} #{@medrepFirstName ? ''}"

  atCalls: ->
    "#{@actualCallsCount ? 0}/#{@targetCycleFrequency ? 0}"

  lastCall: ->
    lastCall = @lastCallReportDateFormated()
    "#{lastCall} <br/> #{@medrepFullName()}" if lastCall

module.exports = TargetFrequency