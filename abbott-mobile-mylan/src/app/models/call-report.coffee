Entity = require 'models/entity'

class CallReport extends Entity
  @table: 'CallReport'
  @sfdcTable: 'Call_Report__c'
  @description: 'Call Report'

  @TYPE_APPOINTMENT: 'Appointment'
  @TYPE_ONE_TO_ONE: '1:1'

  @PORTFOLIO_PRESENTATION_REMINDER_YES: 'Yes'
  @PORTFOLIO_PRESENTATION_REMINDER_NO: 'No'

  @MESSAGES_IN_PRODUCT_NUMBER: 3
  @MAX_PRODUCTS_NUMBER: 10

  specialty: null
  targetFrequency: null

  @schema: ->
    [
      {local:'id',                                             sfdc:'Id'}
      {local:'organizationSfId',                               sfdc:'Organisation__c', indexWithType:'string',          upload: true}
      {local:'contactSfid',                                    sfdc:'Contact1__c', indexWithType:'string',              upload: true}
      {local:'dateTimeOfVisit',                                sfdc:'Date_Time__c', indexWithType:'string',             upload: true}
      {local:'dateOfVisit',                                    sfdc:'Date__c', indexWithType:'string',                  upload: true}
      {local:'createdFromMobile',                              sfdc:'Created_from_Mobile__c',                           upload: true}
      {local:'createdOffline',                                 sfdc:'Created_Offline__c',                               upload: true}
      {local:'isTargetCall',                                   sfdc:'Is_Target_Call__c'}
      {local:'type',                                           sfdc:'Type__c', indexWithType:'string',                  upload: true}
      {local:'recordTypeId',                                   sfdc:'RecordTypeId',                                     upload: true}
      {local:'duration',                                       sfdc:'Duration__c',                                      upload: true}
      {local:'targetPriority',                                 sfdc:'Target_Priority__c'}
      {local:'jointVisit',                                     sfdc:'Joint_Visit__c',                                   upload: true}
      {local:'jointVisitUserSfid',                             sfdc:'Joint_Visit_User__c',                              upload: true}
      {local:'userSfid',                                       sfdc:'User__c',                                          upload: true}
      {local:'generalComments',                                sfdc:'GeneralComments__c',                               upload: true}
      {local:'nextCallObjective',                              sfdc:'Next_Call_Objective__c',                           upload: true}
      {local:'promotionalItemsPrio1',                          sfdc:'Promotional_Items_Prio_1__c',                      upload: true}
      {local:'prio1ProductSfid',                               sfdc:'Prio_1_Product__c',                                upload: true}
      {local:'noteForPrio1',                                   sfdc:'Note_for_Prio_1__c',                               upload: true}
      {local:'prio1MarketingMessage1',                         sfdc:'Prio_1_Marketing_Message_1__c',                    upload: true}
      {local:'prio1MarketingMessage2',                         sfdc:'Prio_1_Marketing_Message_2__c',                    upload: true}
      {local:'prio1MarketingMessage3',                         sfdc:'Prio_1_Marketing_Message_3__c',                    upload: true}
      {local:'patientProfile1',                                sfdc:'Patient_Profile_1__c',                             upload: true, include: 'isPortfolioSellingModuleEnabled'}
      {local:'prio1Classification',                            sfdc:'Prio1_Classification__c',                          upload: true, include: 'isPortfolioSellingModuleEnabled'}
      {local:'promotionalItemsPrio2',                          sfdc:'Promotional_Items_Prio_2__c',                      upload: true}
      {local:'prio2ProductSfid',                               sfdc:'Prio_2_Product__c',                                upload: true}
      {local:'noteForPrio2',                                   sfdc:'Note_for_Prio_2__c',                               upload: true}
      {local:'prio2MarketingMessage1',                         sfdc:'Prio_2_Marketing_Message_1__c',                    upload: true}
      {local:'prio2MarketingMessage2',                         sfdc:'Prio_2_Marketing_Message_2__c',                    upload: true}
      {local:'prio2MarketingMessage3',                         sfdc:'Prio_2_Marketing_Message_3__c',                    upload: true}
      {local:'patientProfile2',                                sfdc:'Patient_Profile_2__c',                             upload: true, include: 'isPortfolioSellingModuleEnabled'}
      {local:'prio2Classification',                            sfdc:'Prio2_Classification__c',                          upload: true, include: 'isPortfolioSellingModuleEnabled'}
      {local:'promotionalItemsPrio3',                          sfdc:'Promotional_Items_Prio_3__c',                      upload: true}
      {local:'prio3ProductSfid',                               sfdc:'Prio_3_Product__c',                                upload: true}
      {local:'noteForPrio3',                                   sfdc:'Note_for_Prio_3__c',                               upload: true}
      {local:'prio3MarketingMessage1',                         sfdc:'Prio_3_Marketing_Message_1__c',                    upload: true}
      {local:'prio3MarketingMessage2',                         sfdc:'Prio_3_Marketing_Message_2__c',                    upload: true}
      {local:'prio3MarketingMessage3',                         sfdc:'Prio_3_Marketing_Message_3__c',                    upload: true}
      {local:'patientProfile3',                                sfdc:'Patient_Profile_3__c',                             upload: true, include: 'isPortfolioSellingModuleEnabled'}
      {local:'prio3Classification',                            sfdc:'Prio3_Classification__c',                          upload: true, include: 'isPortfolioSellingModuleEnabled'}
      {local:'promotionalItemsPrio4',                          sfdc:'Promotional_Items_Prio_4__c',                      upload: true}
      {local:'prio4ProductSfid',                               sfdc:'Prio_4_Product__c',                                upload: true}
      {local:'noteForPrio4',                                   sfdc:'Note_for_Prio_4__c',                               upload: true}
      {local:'prio4MarketingMessage1',                         sfdc:'Prio_4_Marketing_Message_1__c',                    upload: true}
      {local:'prio4MarketingMessage2',                         sfdc:'Prio_4_Marketing_Message_2__c',                    upload: true}
      {local:'prio4MarketingMessage3',                         sfdc:'Prio_4_Marketing_Message_3__c',                    upload: true}
      {local:'patientProfile4',                                sfdc:'Patient_Profile_4__c',                             upload: true, include: 'isPortfolioSellingModuleEnabled'}
      {local:'prio4Classification',                            sfdc:'Prio4_Classification__c',                          upload: true, include: 'isPortfolioSellingModuleEnabled'}
      {local:'promotionalItemsPrio5',                          sfdc:'Promotional_Items_Prio_5__c',                      upload: true}
      {local:'prio5ProductSfid',                               sfdc:'Prio_5_Product__c',                                upload: true}
      {local:'noteForPrio5',                                   sfdc:'Note_for_Prio_5__c',                               upload: true}
      {local:'prio5MarketingMessage1',                         sfdc:'Prio_5_Marketing_Message_1__c',                    upload: true}
      {local:'prio5MarketingMessage2',                         sfdc:'Prio_5_Marketing_Message_2__c',                    upload: true}
      {local:'prio5MarketingMessage3',                         sfdc:'Prio_5_Marketing_Message_3__c',                    upload: true}
      {local:'patientProfile5',                                sfdc:'Patient_Profile_5__c',                             upload: true, include: 'isPortfolioSellingModuleEnabled'}
      {local:'prio5Classification',                            sfdc:'Prio5_Classification__c',                          upload: true, include: 'isPortfolioSellingModuleEnabled'}
      {local:'promotionalItemsPrio6',                          sfdc:'Promotional_Items_Prio_6__c',                      upload: true}
      {local:'prio6ProductSfid',                               sfdc:'Prio_6_Product__c',                                upload: true}
      {local:'noteForPrio6',                                   sfdc:'Note_for_Prio_6__c',                               upload: true}
      {local:'prio6MarketingMessage1',                         sfdc:'Prio_6_Marketing_Message_1__c',                    upload: true}
      {local:'prio6MarketingMessage2',                         sfdc:'Prio_6_Marketing_Message_2__c',                    upload: true}
      {local:'prio6MarketingMessage3',                         sfdc:'Prio_6_Marketing_Message_3__c',                    upload: true}
      {local:'patientProfile6',                                sfdc:'Patient_Profile_6__c',                             upload: true, include: 'isPortfolioSellingModuleEnabled'}
      {local:'prio6Classification',                            sfdc:'Prio6_Classification__c',                          upload: true, include: 'isPortfolioSellingModuleEnabled'}
      {local:'prio7ProductSfid',                               sfdc:'Prio_7_Product__c',                                upload: true}
      {local:'noteForPrio7',                                   sfdc:'Note_for_Prio_7__c',                               upload: true}
      {local:'prio7MarketingMessage1',                         sfdc:'Prio_7_Marketing_Message_1__c',                    upload: true}
      {local:'prio7MarketingMessage2',                         sfdc:'Prio_7_Marketing_Message_2__c',                    upload: true}
      {local:'prio7MarketingMessage3',                         sfdc:'Prio_7_Marketing_Message_3__c',                    upload: true}
      {local:'patientProfile7',                                sfdc:'Patient_Profile_7__c',                             upload: true, include: 'isPortfolioSellingModuleEnabled'}
      {local:'prio7Classification',                            sfdc:'Prio7_Classification__c',                          upload: true, include: 'isPortfolioSellingModuleEnabled'}
      {local:'prio8ProductSfid',                               sfdc:'Prio_8_Product__c',                                upload: true}
      {local:'noteForPrio8',                                   sfdc:'Note_for_Prio_8__c',                               upload: true}
      {local:'prio8MarketingMessage1',                         sfdc:'Prio_8_Marketing_Message_1__c',                    upload: true}
      {local:'prio8MarketingMessage2',                         sfdc:'Prio_8_Marketing_Message_2__c',                    upload: true}
      {local:'prio8MarketingMessage3',                         sfdc:'Prio_8_Marketing_Message_3__c',                    upload: true}
      {local:'patientProfile8',                                sfdc:'Patient_Profile_8__c',                             upload: true, include: 'isPortfolioSellingModuleEnabled'}
      {local:'prio8Classification',                            sfdc:'Prio8_Classification__c',                          upload: true, include: 'isPortfolioSellingModuleEnabled'}
      {local:'prio9ProductSfid',                               sfdc:'Prio_9_Product__c',                                upload: true}
      {local:'noteForPrio9',                                   sfdc:'Note_for_Prio_9__c',                               upload: true}
      {local:'prio9MarketingMessage1',                         sfdc:'Prio_9_Marketing_Message_1__c',                    upload: true}
      {local:'prio9MarketingMessage2',                         sfdc:'Prio_9_Marketing_Message_2__c',                    upload: true}
      {local:'prio9MarketingMessage3',                         sfdc:'Prio_9_Marketing_Message_3__c',                    upload: true}
      {local:'patientProfile9',                                sfdc:'Patient_Profile_9__c',                             upload: true, include: 'isPortfolioSellingModuleEnabled'}
      {local:'prio9Classification',                            sfdc:'Prio9_Classification__c',                          upload: true, include: 'isPortfolioSellingModuleEnabled'}
      {local:'prio10ProductSfid',                              sfdc:'Prio_10_Product__c',                               upload: true}
      {local:'noteForPrio10',                                  sfdc:'Note_for_Prio_10__c',                              upload: true}
      {local:'prio10MarketingMessage1',                        sfdc:'Prio_10_Marketing_Message_1__c',                   upload: true}
      {local:'prio10MarketingMessage2',                        sfdc:'Prio_10_Marketing_Message_2__c',                   upload: true}
      {local:'prio10MarketingMessage3',                        sfdc:'Prio_10_Marketing_Message_3__c',                   upload: true}
      {local:'patientProfile10',                               sfdc:'Patient_Profile_10__c',                            upload: true, include: 'isPortfolioSellingModuleEnabled'}
      {local:'prio10Classification',                           sfdc:'Prio10_Classification__c',                         upload: true, include: 'isPortfolioSellingModuleEnabled'}
      {local:'signature',                                      sfdc:'Signature__c',                                     upload: true}
      {local:'signatureDate',                                  sfdc:'Signature_taken__c',                               upload: true}
      {local:'callWithIPad',                                   sfdc:'CallWithIPad__c',                                  upload: true}
      {local:'realCallDuration',                               sfdc:'RealCallDuration__c',                              upload: true}
      {local:'patientSupportProgram',                          sfdc:'Patient_Support_Program__c',                       upload: true, include: 'isPortfolioSellingModuleEnabled'}
      {local:'portfolioFeedback',                              sfdc:'Portfolio_Feedback__c',                            upload: true, include: 'isPortfolioSellingModuleEnabled'}
      {local:'patientSupportProgramComments',                  sfdc:'Patient_Support_Program_Comments__c',              upload: true, include: 'isPortfolioSellingModuleEnabled'}
      {local:'fullPortfolioPresentationReminder',              sfdc:'Full_Portfolio_Presentation_Reminder__c',          upload: true, include: 'isPortfolioSellingModuleEnabled'}
      {local:'userFirstName',                                  sfdc:'User__r.FirstName'}
      {local:'userLastName',                                   sfdc:'User__r.LastName'}
      {local:'remoteContactFirstName',                         sfdc:'Contact1__r.FirstName'}
      {local:'remoteContactLastName',                          sfdc:'Contact1__r.LastName'}
      {local:'contactRecordType',                              sfdc:'Contact1__r.Account.RecordType.Name'}
      {local:'contactFirstName',                               indexWithType:'string', search:true}
      {local:'contactLastName',                                indexWithType:'string', search:true}
      {local:'remoteOrganizationName',                         sfdc:'Organisation__r.Name'}
      {local:'organizationName',                               indexWithType:'string', search:true}
      {local:'organizationCity',                               sfdc:'Organisation__r.BillingCity'}
      {local:'organizationAddress',                            sfdc:'Organisation__r.BillingStreet'}
      {local:'atCalls',                                        indexWithType:'string'}
      {local:'typeOfVisit',                                    sfdc:'Type_of_visit__c',                                 upload: true}
      {local:'isSandbox',                                      indexWithType:'string'}
      {local:'clmToolId',                                      sfdc:'CLM_Tool_Id__c',                                   upload: true}
    ]

  userFullName: =>
    "#{@userLastName ? ''} #{@userFirstName ? ''}"

  contactFullName: =>
    "#{@contactLastName ? ''} #{@contactFirstName ? ''}"

  organizationNameAndAddress: =>
    "#{@organizationName ? ''} <br/> #{@organizationAddress ? ''} #{@organizationCity ? ''}"

  getJointVisitUser: =>
    if @jointVisitUser then $.when @jointVisitUser
    else
      UsersCollection = require 'models/bll/users-collection'
      new UsersCollection().fetchEntityById(@jointVisitUserSfid)
      .then (@jointVisitUser) => @jointVisitUser

  getIsTargetCustomer: =>
    if @isTargetCustomer then $.when @isTargetCustomer
    else
      ContactsCollection = require 'models/bll/contacts-collection'
      new ContactsCollection().fetchEntityById(@contactSfid)
      .then (contact) => contact.targetCustomer()

  # TODO: assign on 'didFinishDownloading'
  getSpecialty: =>
    if @specialty then $.when @specialty
    else
      @getContact()
      .then => @specialty = @contact?.abbottSpecialty ? null

  # TODO: assign on 'didFinishDownloading'
  getContact: =>
    if @contact then $.when @contact
    else
      ContactsCollection = require 'models/bll/contacts-collection'
      contactsCollection = new ContactsCollection
      contactsCollection.fetchEntityById(@contactSfid)
      .then (@contact) => @contact

module.exports = CallReport