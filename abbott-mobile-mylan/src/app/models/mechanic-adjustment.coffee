Entity = require 'models/entity'

class MechanicAdjustment extends Entity
  @table: 'MechanicAdjustment'
  @sfdcTable: 'TM_MechanicAdjustment__c'
  @description: 'Mechanic Adjustment'

  @schema: ->
    [
      {local:'id',                            sfdc:'Id'}
      {local:'callReportSfId',                sfdc:'CallReport__c', indexWithType:'string', upload:true}
      {local:'mechanicEvaluationAccountSfId', sfdc:'MechanicEvaluation_Account__c', indexWithType:'string', upload:true}
      {local:'mechanicType',                  sfdc:'MechanicType__c'}
      {local:'numberRealValue',               sfdc:'NumberRealValue__c', upload:true}
      {local:'realValue ',                    sfdc:'RealValue__c'}
      {local:'status',                        sfdc:'Status__c'}
      {local:'stringRealValue',               sfdc:'StringRealValue__c', upload:true}
      {local:'isModifiedInTrade'}
      {local:'isModifiedInCall'}
      {local:'clmToolId',                     sfdc:'CLM_Tool_Id__c',          upload: true}
    ]

module.exports = MechanicAdjustment