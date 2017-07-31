Entity = require 'models/entity'

class PhotoAttachment extends Entity
  @table: 'PhotoAttachment'
  @sfdcTable: 'Attachment'
  @description: 'Photo Attachment'

  @schema: ->
    [
      {local:'id',                  sfdc:'Id'}
      {local:'body',                sfdc:'Body', upload: true}
      {local:'bodyLength',          sfdc:'BodyLength'}
      {local:'contentType',         sfdc:'ContentType', upload: true}
      {local:'description',         sfdc:'Description'}
      {local:'isPrivate',           sfdc:'IsPrivate'}
      {local:'title',               sfdc:'Name', upload: true}
      {local:'ownerId',             sfdc:'OwnerId'}
      {local:'parentId',            sfdc:'ParentId', indexWithType:'string', upload: true}
      {local:'lastModify',          sfdc:'LastModifiedDate'}
      {local:'localParentId',           indexWithType:'string'}
    ]

module.exports = PhotoAttachment