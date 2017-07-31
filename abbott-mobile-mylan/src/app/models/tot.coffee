Entity = require 'models/entity'

class Tot extends Entity
  @table: 'Tot'
  @sfdcTable: 'Time_off_Territory__c'
  @description: 'Time-Off-Territory'
  @TYPE_OPEN: 'Open'
  @TYPE_NONE: 'None'
  @TYPE_CLOSED: 'Closed'
  @TYPE_SUBMIT: 'Submit'

  @schema: ->
    [
      {local:'id',                    sfdc:'Id'}
      {local:'userSfId',              sfdc:'OwnerId', upload: true}
      {local:'createdOffline',        sfdc:'Created_Offline__c', upload: true}
      {local:'userLastName',          sfdc:'Owner.LastName'}
      {local:'userFirstName',         sfdc:'Owner.FirstName'}
      {local:'allDay',                sfdc:'All_Day__c', upload: true}
      {local:'startDate',             sfdc:'Start_Date__c', indexWithType:'string', upload: true}
      {local:'endDate',               sfdc:'End_Date__c', indexWithType:'string', upload: true}
      {local:'firstQuarterEvent',     sfdc:'Type_First_Quarter__c', indexWithType:'string', search: true, upload: true}
      {local:'secondQuarterEvent',    sfdc:'Type_Second_Quarter__c', indexWithType:'string', search: true, upload: true}
      {local:'thirdQuarterEvent',     sfdc:'Type_Third_Quarter__c', indexWithType:'string', search: true, upload: true}
      {local:'fourthQuarterEvent',    sfdc:'Type_Fourth_Quarter__c', indexWithType:'string', search: true, upload: true}
      {local:'type',                  sfdc:'Type__c', indexWithType:'string', upload: true}
      {local:'description',           sfdc:'Description__c', indexWithType:'string', search: true, upload: true}
      {local:'isSubmittedForApproval',sfdc:'IsSubmittedForApproval__c', indexWithType:'string'}
      {local:'clmToolId',             sfdc:'CLM_Tool_Id__c',           upload: true}
    ]

  userFullName: ->
    "#{@userLastName ? ''} #{@userFirstName ? ''}"

module.exports = Tot