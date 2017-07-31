Entity = require 'models/entity'

class LocalImage extends Entity
  @table: 'LocalImage'
  @sfdcTable: 'LocalImage'
  @description: 'Local Image'

  @schema: ->
    [
      {local:'id', sfdc:'Id'}
      {local:'parentId', indexWithType:'string'}
      {local:'path'}
      {local:'thumbnailPath'}
    ]

module.exports = LocalImage