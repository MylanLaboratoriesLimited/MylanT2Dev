Entity = require 'models/entity'
Query = require 'common/query'

class Device extends Entity
  @table: 'Device'
  @sfdcTable: 'Mobile_Devices__c'
  @description: 'Device'

  @schema: ->
    [
      {local:'id',                  sfdc:'Id'}
      {local:'deviceId',            sfdc:'Device_ID__c', indexWithType:'string', search: true, upload: true}
      {local:'erased',              sfdc:'Erased__c', upload: true}
      {local:'requestErase',        sfdc:'Request_Erase__c'}
      {local:'lastSyncronisation',  sfdc:'Last_Syncronization__c', upload: true}
      {local:'lastUserSfid',        sfdc:'Last_User__c', upload: true}
      {local:'model',               sfdc:'Model__c', upload: true}
      {local:'osVersion',           sfdc:'OS_Version__c', upload: true}
      {local:'version',             sfdc:'Version__c', upload: true}
      {local:'lastDebugLog',        sfdc:'Last_Debug_Log__c', upload: true}
    ]


module.exports = Device