Entity = require 'models/entity'

class PromotionTaskAccount extends Entity
  @table: 'PromotionTaskAccount'
  @sfdcTable: 'TM_PromotionTask_Account__c'
  @description: 'Promotion Task Account'

  @TASK_TYPE_NUMERIC: 'Numeric_Task'
  @TASK_TYPE_PICKLIST: 'Picklist_Task'
  @TASK_TYPE_TEXT: 'Text_Task'

  @schema: ->
    [
      {local:'id',                   sfdc:'Id'}
      {local:'numberOfActualRepeats',sfdc:'Actual_Repeats__c'}
      {local:'isRecurrent',          sfdc:'IsRecurrent__c'}
      {local:'actualCallReports',    sfdc:'Actual_CallReports__c'}
      {local:'plannedRecurrency',    sfdc:'PlannedRecurrency__c'}
      {local:'promotionAccountSfId', sfdc:'PromotionAccount__c', indexWithType:'string'}
      {local:'promotionTaskSfId',    sfdc:'Promotion_Task__c'}
      {local:'remotePromotionSfId',  sfdc:'PromotionAccount__r.Promotion__c'}
      {local:'promotionEndDate',     sfdc:'Promotion_Task__r.PromotionEndDate__c'}
      {local:'promotionName',        sfdc:'Promotion_Task__r.PromotionName__c'}
      {local:'promotionStartDate',   sfdc:'Promotion_Task__r.PromotionStartDate__c'}
      {local:'remoteRelatedToSku',   sfdc:'Promotion_Task__r.RelatedToSKU__c'}
      {local:'taskSfId',             sfdc:'Promotion_Task__r.Task__c'}
      {local:'taskRecordType',       sfdc:'Promotion_Task__r.Task__r.RecordType.Name'}
      {local:'taskPicklistValues',   sfdc:'Promotion_Task__r.Task__r.Picklist__c'}
      {local:'taskName',             sfdc:'Promotion_Task__r.TaskName__c'}
      {local:'taskType',             sfdc:'Promotion_Task__r.TaskType__c'}
      {local:'promotionSfId',              indexWithType:'string'}
      {local:'relatedToSku',               indexWithType:'string'}
    ]

module.exports = PromotionTaskAccount