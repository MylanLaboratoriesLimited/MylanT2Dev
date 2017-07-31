Entity = require 'models/entity'

class PromotionMechanic extends Entity
  @table: 'PromotionMechanic'
  @sfdcTable: 'TM_MechanicPromotion__c'
  @description: 'Promotion Mechanic'

  @MECHANIC_TYPE_NUMERIC: 'Numeric_Mechanic'
  @MECHANIC_TYPE_PICKLIST: 'Picklist_Mechanic'
  @MECHANIC_TYPE_TEXT: 'Text_Mechanic'

  @schema: ->
    [
      {local:'id',                      sfdc:'Id'}
      {local:'numberOfPlannedRepeats',  sfdc:'PlannedRecurrency__c'}
      {local:'isRecurrent',             sfdc:'IsRecurrent__c'}
      {local:'mechanicSfId',            sfdc:'Mechanic__c'}
      {local:'mechanicName',            sfdc:'MechanicName__c'}
      {local:'mechanicType',            sfdc:'MechanicType__c'}
      {local:'mechanicRecordType',      sfdc:'Mechanic__r.RecordType.Name'}
      {local:'mechanicPicklistValues',  sfdc:'Mechanic__r.Picklist__c'}
      {local:'promotionSfId',           sfdc:'Promotion__c', indexWithType:'string'}
    ]

module.exports = PromotionMechanic