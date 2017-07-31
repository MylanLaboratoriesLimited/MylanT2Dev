Entity = require 'models/entity'

class User extends Entity
  @table: 'User'
  @sfdcTable: 'User'
  @description: 'User'

  @schema: ->
    [
      {local:'id',                            sfdc:'Id'}
      {local:'email',                         sfdc:'Email',         indexWithType: 'string', search: true}
      {local:'firstName',                     sfdc:'FirstName',     indexWithType: 'string', search: true}
      {local:'lastName',                      sfdc:'LastName',      indexWithType: 'string', search: true}
      {local:'currency',                      sfdc:'DefaultCurrencyIsoCode'}
      {local:'businessUnit',                  sfdc:'Business_Unit__c'}
      {local:'callReportValidationExcempted', sfdc:'Is_Exempted_in_Call_Report_Validation__c'}
      {local:'pinCode',                       sfdc:'ATC_Class__c',  indexWithType:'string'}
      {local:'isActive',                      sfdc:'IsActive',      indexWithType:'string'}
      {local:'DayOff1',                     sfdc:'Day_Off_1__c'}
      {local:'DayOff2',                     sfdc:'Day_Off_2__c'}
      {local:'isCurrentUser',                                       indexWithType:'string'}
      {local:'atcClass'}
      {local:'isLocked'}
      {local:'pinAttemptsCnt'}
    ]

  fullName: ->
    "#{@lastName ? ''} #{@firstName ? ''}"

  getDayOffByIndex:(index) ->
    days = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]
    days[index]

module.exports = User