Entity = require 'models/entity'

class PromotionAccount extends Entity
  @table: 'PromotionAccount'
  @sfdcTable: 'TM_PromotionAccount__c'
  @description: 'Promotion Account'

  @schema: ->
    [
      {local:'id',                    sfdc:'Id'}
      {local:'accountSfId',           sfdc:'Account__c', indexWithType:'string'}
      {local:'remoteGlobalPriority',  sfdc:'Account__r.GlobalPriority__c'}
      {local:'promotionSfId',         sfdc:'Promotion__c', indexWithType:'string'}
      {local:'uniqueSfId',            sfdc:'Unique_Id__c'}
      {local:'name',                  sfdc:'Promotion__r.Name'}
      {local:'numberOfPharmacies',    sfdc:'Promotion__r.NumberOfPharmacies__c'}
      {local:'contractNumber',        sfdc:'Promotion__r.ContractNumber__c'}
      {local:'description',           sfdc:'Promotion__r.Description__c'}
      {local:'objectives',            sfdc:'Promotion__r.Objectives__c'}
      {local:'remoteStartDate',       sfdc:'Promotion__r.PromotionStartDate__c'}
      {local:'remoteEndDate',         sfdc:'Promotion__r.PromotionEndDate__c'}
      {local:'status',                sfdc:'Promotion__r.Status__c'}
      {local:'recordType',            sfdc:'Promotion__r.RecordType.Name'}
      {local:'recordTypeId',          sfdc:'Promotion__r.RecordType.Id'}
      {local:'startDate',                 indexWithType:'string'}
      {local:'endDate',                   indexWithType:'string'}
      {local:'globalPriority',            indexWithType:'string'}
    ]

  getPromotionStatus: =>
    PromotionPicklistManager = require 'db/picklist-managers/promotion-picklist-manager'
    new PromotionPicklistManager().getStatusLabelByValue @status

module.exports = PromotionAccount