Entity = require 'models/entity'

class PhotoAdjustment extends Entity
  @table: 'PhotoAdjustment'
  @sfdcTable: 'TM_PhotoAdjustment__c'
  @description: 'Photo Adjustment'

  @schema: ->
    [
      {local:'id',                     sfdc:'Id'}
      {local:'callReportSfId',         sfdc:'CallReport__c',          upload: true, indexWithType:'string'}
      {local:'promotionSfId',          sfdc:'Promotion__c',           upload: true, indexWithType:'string'}
      {local:'isModifiedInTrade'}
      {local:'isModifiedInCall'}
      {local:'clmToolId',              sfdc:'CLM_Tool_Id__c',         upload: true}
    ]

module.exports = PhotoAdjustment