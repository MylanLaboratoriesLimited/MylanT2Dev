Entity = require 'models/entity'

class Presentation extends Entity
  @table: 'Presentation'
  @sfdcTable: 'Presentation__c'
  @description: 'Presentation'

  @schema: ->
    [
      {local:'id',       sfdc:'Id'}
      {local:'name',     sfdc:'Name'}
      {local:'description',  sfdc:'Description__c'}
      {local:'availableVersion',  sfdc:'Version__c'}
      {local:'url',  sfdc:'DownloadUrl__c'}
      {local:'iconName'}
      {local:'iconPath'}
      {local:'currentVersion', indexWithType:'string'}
    ]

  wasDownloaded: ->
    @currentVersion > 0

  hasUpdate: ->
    @availableVersion > @currentVersion

module.exports = Presentation