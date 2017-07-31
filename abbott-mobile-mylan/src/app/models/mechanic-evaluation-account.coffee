Entity = require 'models/entity'
PromotionMechanic = require 'models/promotion-mechanic'

class MechanicEvaluationAccount extends Entity
  @table: 'MechanicEvaluationAccount'
  @sfdcTable: 'MechanicEvaluation_Account__c'
  @description: 'Mechanic Evaluation Account'

  @schema: ->
    [
      {local:'id',                              sfdc:'Id'}
      {local:'numberOfActualRepeats',           sfdc:'Actual_Repeats__c'}
      {local:'isRecurrent',                     sfdc:'IsRecurrent__c'}
      {local:'actualCallReports',               sfdc:'Actual_CallReports__c'}
      {local:'plannedRecurrency',               sfdc:'PlannedRecurrency__c'}
      {local:'remoteOrganizationSfId',          sfdc:'PromotionAccount__r.Account__c'}
      {local:'promotionAccountSfId',            sfdc:'PromotionAccount__c', indexWithType:'string'}
      {local:'externalId',                      sfdc:'ExternalId__c'}
      {local:'mechanicEvaluationSfId',          sfdc:'MechanicEvaluation__c'}
      {local:'externalId',                      sfdc:'MechanicEvaluation__r.ExternalId__c'}
      {local:'isUsed',                          sfdc:'MechanicEvaluation__r.isUsed__c'}
      {local:'mechanicName',                    sfdc:'MechanicEvaluation__r.MechanicName__c'}
      {local:'mechanicType',                    sfdc:'MechanicEvaluation__r.MechanicType__c'}
      {local:'numberEtalonValue',               sfdc:'MechanicEvaluation__r.NumberEtalonValue__c'}
      {local:'promotionEndDate',                sfdc:'MechanicEvaluation__r.PromotionEndDate__c'}
      {local:'promotionName',                   sfdc:'MechanicEvaluation__r.Promotion_Name__c'}
      {local:'promotionStartDate',              sfdc:'MechanicEvaluation__r.PromotionStartDate__c'}
      {local:'skuName',                         sfdc:'MechanicEvaluation__r.SkuName__c'}
      {local:'remoteSkuPromotionSfId',          sfdc:'MechanicEvaluation__r.SkuPromotion__c'}
      {local:'stringEtalonValue',               sfdc:'MechanicEvaluation__r.StringEtalonValue__c'}
      {local:'remotePromotionMechanicSfId',     sfdc:'MechanicEvaluation__r.MechanicPromotion__c'}
      {local:'remoteGlobalPriority',            sfdc:'MechanicEvaluation__r.GlobalPriority__c'}
      {local:'promotionMechanicPicklistValues', sfdc:'MechanicEvaluation__r.MechanicPromotion__r.Mechanic__r.Picklist__c'}
      {local:'organizationSfId',                      indexWithType:'string'}
      {local:'promotionMechanicSfId',                 indexWithType:'string'}
      {local:'globalPriority',                        indexWithType:'string'}
      {local:'skuPromotionSfId',                      indexWithType:'string'}
    ]

  realValue: =>
    switch @mechanicType
      when PromotionMechanic.MECHANIC_TYPE_NUMERIC then @numberEtalonValue
      when PromotionMechanic.MECHANIC_TYPE_TEXT, PromotionMechanic.MECHANIC_TYPE_PICKLIST then @stringEtalonValue

  isDisabled: =>
    @isRecurrent and (@plannedRecurrency <= @actualCallReports)

module.exports = MechanicEvaluationAccount