Entity = require 'models/entity'

class PromotionNote extends Entity
  @table: 'PromotionNote'
  @sfdcTable: 'Note'
  @description: 'Promotion Note'

  @schema: ->
    [
      {local:'id',              sfdc:'Id'}
      {local:'body',            sfdc:'Body'}
      {local:'isDeleted',       sfdc:'IsDeleted'}
      {local:'isPrivate',       sfdc:'IsPrivate'}
      {local:'ownerId',         sfdc:'OwnerId'}
      {local:'attachedByName',  sfdc:'CreatedBy.Name'}
      {local:'parentId',        sfdc:'ParentId', indexWithType:'string'}
      {local:'title',           sfdc:'Title'}
      {local:'lastModify',      sfdc:'LastModifiedDate'}
    ]

module.exports = PromotionNote