Entity = require 'models/entity'

class PromotionAttachment extends Entity
  @table: 'PromotionAttachment'
  @sfdcTable: 'Attachment'
  @description: 'Promotion Attachment'

  @schema: ->
    [
      {local:'id',                  sfdc:'Id'}
      {local:'body',                sfdc:'Body'}
      {local:'bodyLength',          sfdc:'BodyLength'}
      {local:'contentType',         sfdc:'ContentType'}
      {local:'description',         sfdc:'Description'}
      {local:'isPrivate',           sfdc:'IsPrivate'}
      {local:'title',               sfdc:'Name'}
      {local:'ownerId',             sfdc:'OwnerId'}
      {local:'attachedByName',      sfdc:'CreatedBy.Name'}
      {local:'parentId',            sfdc:'ParentId', indexWithType:'string'}
      {local:'lastModify',          sfdc:'LastModifiedDate'}
      {local:'localParentId',           indexWithType:'string'}
    ]

module.exports = PromotionAttachment