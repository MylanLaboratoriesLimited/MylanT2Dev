Entity = require 'models/entity'

class TaskAdjustment extends Entity
  @table: 'TaskAdjustment'
  @sfdcTable: 'TM_TaskAdjustment__c'
  @description: 'Task Adjustment'

  @schema: ->
    [
      {local:'id',                        sfdc:'Id'}
      {local:'callReportSfId',            sfdc:'CallReport__c',                               indexWithType:'string',   upload: true}
      {local:'numberRealValue',           sfdc:'NumberRealValue__c',                                                    upload: true}
      {local:'productItemSfId',           sfdc:'SKU__c',                                      indexWithType:'string',   upload: true}
      {local:'stringRealValue',           sfdc:'StringRealValue__c',                                                    upload: true}
      {local:'remotePromotionTaskSfId',   sfdc:'PromotionTask_Account__r.Promotion_Task__c'}
      {local:'promotionTaskAccountSfId',  sfdc:'PromotionTask_Account__c',                    indexWithType:'string',   upload: true}
      {local:'promotionTaskSfId',                                                             indexWithType:'string'}
      {local:'isModifiedInTrade'}
      {local:'isModifiedInCall'}
      {local:'clmToolId',                 sfdc:'CLM_Tool_Id__c',          upload: true}
    ]

module.exports = TaskAdjustment
