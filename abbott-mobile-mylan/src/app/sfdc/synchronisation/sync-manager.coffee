# Collections
EntitiesCollection = require 'models/bll/entities-collection'
SforceDataContext = require 'models/bll/sforce-data-context'
BricksCollection = require 'models/bll/bricks-collection'
BuTeamPersonProfilesCollection = require 'models/bll/bu-team-person-profiles-collection'
CallReportsCollection = require 'models/bll/call-reports-collection/call-reports-collection'
ContactsCollection = require 'models/bll/contacts-collection'
MarketingCyclesCollection = require 'models/bll/marketing-cycles-collection'
MarketingMessagesCollection = require 'models/bll/marketing-messages-collection'
OrganizationsCollection = require 'models/bll/organizations-collection'
PEAbbottAttendeesCollection = require 'models/bll/pe-abbott-attendees-collection'
PEAttendeesCollection = require 'models/bll/pe-attendees-collection'
PharmaEventsCollection = require 'models/bll/pharma-events-collection'
ProductsCollection = require 'models/bll/products-collection'
ReferencesCollection = require 'models/bll/references/references-collection'
TargetFrequenciesCollection = require 'models/bll/target-frequencies-collection'
TargetsCollection = require 'models/bll/targets-collection'
TotsCollection = require 'models/bll/tots-collection/tots-collection'
UsersCollection = require 'models/bll/users-collection'
DeviceCollection = require 'models/bll/device-collection'
PresentationsCollection = require 'models/bll/presentations-collection'
CLMCallReportDataCollection = require 'models/bll/clm-call-report-data-collection'
PromotionAccountsCollection = require 'models/bll/promotion-accounts-collection'
PromotionTaskAccountsCollection = require 'models/bll/promotion-task-accounts-collection'
TaskAdjustmentsCollection = require 'models/bll/task-adjustments-collection'
ProductItemsCollection = require 'models/bll/product-items-collection'
PromotionSkusCollection = require 'models/bll/promotion-skus-collection'
PromotionMechanicsCollection = require 'models/bll/promotion-mechanics-collection'
MechanicAdjustmentsCollection = require 'models/bll/mechanic-adjustments-collection'
MechanicEvaluationAccountsCollection = require 'models/bll/mechanic-evaluation-accounts-collection'
PromotionNotesCollection = require 'models/bll/promotion-notes-collection'
PromotionAttachmentsCollection = require 'models/bll/promotion-attachments-collection'
PhotoAttachmentsCollection = require 'models/bll/photo-attachments-collection'
PhotoAdjustmentsCollection = require 'models/bll/photo-adjustments-collection'
ProductInPortfoliosCollection = require 'models/bll/product-in-portfolios-collection'
ProfileProductInPortfoliosCollection = require 'models/bll/profile-product-in-portfolios-collection'
PatientDiseasesCollection = require 'models/bll/patient-diseases-collection'
# Picklists Managers
PicklistManager = require 'db/picklist-managers/picklist-manager'
CallReportPicklistManager = require 'db/picklist-managers/callreport-picklist-manager'
TotPicklistManager = require 'db/picklist-managers/tot-picklist-manager'
ReferencePicklistManager = require 'db/picklist-managers/reference-picklist-manager'
PharmaEventPicklistManager = require 'db/picklist-managers/pe-picklist-manager'
PromotionPicklistManager = require 'db/picklist-managers/promotion-picklist-manager'
# Other
DatabaseManager = require 'db/database-manager'
ConfigurationManager = require 'db/configuration-manager'
SyncLogManager = require 'common/log-manager'
AlarmManager = require 'common/alarm/alarm-manager'
SettingsManager = require 'db/settings-manager'

class SyncManager
  STEPS_COUNT: 51

  startLoading: (@statusCB) =>
    SyncLogManager.initLog()
    @_stepIndex = 0
    @deviceCollection = new DeviceCollection
    @_downloadDeviceAndCheckErase()

  _downloadDeviceAndCheckErase: =>
    @_updateStatus Locale.value('synchronizationPopup.LogMessage.CheckDevice')
    @deviceCollection.serverConfig()
    .then((config) => @deviceCollection.sync 'read', null, { config: config, cache: @deviceCollection.cache })
    .then(=> @deviceCollection.getDevice())
    .then (device)=>
      if device and device.requestErase
        @_eraseDeviceAndLogout device
      else
        @makeSync()

  _eraseDeviceAndLogout: (device) =>
    device.erased = true
    @deviceCollection.updateEntity(device)
    .then(=> @deviceCollection.serverConfig())
    .then((config) => @deviceCollection.sync 'upsert', null, { config: config, cache: @deviceCollection.cache, each: @_onEntityUpload })
    .then => new DatabaseManager().clearDatabase().then(=> SforceDataContext.logout())

  makeSync: =>
    isEdetailingEnabled = null
    isTradeModuleEnabled = null
    isPortfolioSellingEnabled = null
    SforceDataContext.cleanup();
    SyncLogManager.appendInfoLog Locale.value('synchronizationPopup.LogMessage.SyncStart', {count: SyncLogManager._stepIndexKey})
    .then @_downloadConfigurationData
    .then @_processConfiguration
    .then => SettingsManager.getValueByKey('isEdetailingEnabled').then (isEnabled) -> isEdetailingEnabled = isEnabled
    .then => SettingsManager.getValueByKey('isTradeModuleEnabled').then (isEnabled) -> isTradeModuleEnabled = isEnabled
    .then => SettingsManager.getValueByKey('isPortfolioSellingModuleEnabled').then (isEnabled) -> isPortfolioSellingEnabled = isEnabled
    .then => @_downloadEntitiesForCollection(new UsersCollection)
    .then => if isEdetailingEnabled then @_downloadEntitiesForCollection(new CLMCallReportDataCollection) else @_skipStep()
    .then => @_downloadEntitiesForCollection(new TargetsCollection)
    .then => @_downloadEntitiesForCollection(new MarketingCyclesCollection)
    .then => @_downloadEntitiesForCollection(new MarketingMessagesCollection)
    .then => @_downloadEntitiesForCollection(new BricksCollection)
    .then => @_downloadEntitiesForCollection(new OrganizationsCollection)
    .then => @_downloadEntitiesForCollection(new BuTeamPersonProfilesCollection)
    .then => @_downloadEntitiesForCollection(new ContactsCollection)
    .then => @_downloadEntitiesForCollection(new ReferencesCollection)
    .then => @_downloadEntitiesForCollection(new ProductsCollection)
    .then => @_uploadEntitiesForCollection(new CallReportsCollection)
    .then => @_downloadEntitiesForCollection(new CallReportsCollection)
    .then => if isEdetailingEnabled then @_uploadEntitiesForCollection(new CLMCallReportDataCollection) else @_skipStep()
    .then => @_uploadEntitiesForCollection(new PharmaEventsCollection)
    .then => @_downloadEntitiesForCollection(new PharmaEventsCollection)
    .then => @_uploadEntitiesForCollection(new PEAbbottAttendeesCollection)
    .then => @_downloadEntitiesForCollection(new PEAbbottAttendeesCollection)
    .then => @_uploadEntitiesForCollection(new PEAttendeesCollection)
    .then => @_downloadEntitiesForCollection(new PEAttendeesCollection)
    .then => @_uploadEntitiesForCollection(new TotsCollection)
    .then => @_downloadEntitiesForCollection(new TotsCollection)
    .then => @_downloadEntitiesForCollection(new TargetFrequenciesCollection)
    .then => if isEdetailingEnabled then @_downloadEntitiesForCollection(new PresentationsCollection) else @_skipStep()
    .then => if isTradeModuleEnabled then @_downloadEntitiesForCollection(new PromotionAccountsCollection) else @_skipStep()
    .then => if isTradeModuleEnabled then @_uploadEntitiesForCollection(new TaskAdjustmentsCollection) else @_skipStep()
    .then => if isTradeModuleEnabled then @_downloadEntitiesForCollection(new TaskAdjustmentsCollection) else @_skipStep()
    .then => if isTradeModuleEnabled then @_downloadEntitiesForCollection(new PromotionTaskAccountsCollection) else @_skipStep()
    .then => if isTradeModuleEnabled then @_downloadEntitiesForCollection(new ProductItemsCollection) else @_skipStep()
    .then => if isTradeModuleEnabled then @_downloadEntitiesForCollection(new PromotionSkusCollection) else @_skipStep()
    .then => if isTradeModuleEnabled then @_downloadEntitiesForCollection(new PromotionMechanicsCollection) else @_skipStep()
    .then => if isTradeModuleEnabled then @_uploadEntitiesForCollection(new MechanicAdjustmentsCollection) else @_skipStep()
    .then => if isTradeModuleEnabled then @_downloadEntitiesForCollection(new MechanicAdjustmentsCollection) else @_skipStep()
    .then => if isTradeModuleEnabled then @_downloadEntitiesForCollection(new MechanicEvaluationAccountsCollection) else @_skipStep()
    .then => if isTradeModuleEnabled then @_uploadEntitiesForCollection(new PhotoAdjustmentsCollection) else @_skipStep()
    .then => if isTradeModuleEnabled then @_downloadEntitiesForCollection(new PhotoAdjustmentsCollection) else @_skipStep()
    .then => if isTradeModuleEnabled then @_uploadEntitiesForCollection(new PhotoAttachmentsCollection) else @_skipStep()
    .then => if isTradeModuleEnabled then @_downloadEntitiesForCollection(new PhotoAttachmentsCollection) else @_skipStep()
    .then => if isTradeModuleEnabled then @_downloadEntitiesForCollection(new PromotionAttachmentsCollection) else @_skipStep()
    .then => if isTradeModuleEnabled then @_downloadEntitiesForCollection(new PromotionNotesCollection) else @_skipStep()
    .then => if isPortfolioSellingEnabled then @_downloadEntitiesForCollection(new ProductInPortfoliosCollection) else @_skipStep()
    .then => if isPortfolioSellingEnabled then @_downloadEntitiesForCollection(new ProfileProductInPortfoliosCollection) else @_skipStep()
    .then => if isPortfolioSellingEnabled then @_downloadEntitiesForCollection(new PatientDiseasesCollection) else @_skipStep()
    .then => @_downloadPicklistWithDatasource(new TotPicklistManager)
    .then => @_downloadPicklistWithDatasource(new CallReportPicklistManager)
    .then => @_downloadPicklistWithDatasource(new ReferencePicklistManager)
    .then => @_downloadPicklistWithDatasource(new PharmaEventPicklistManager)
    .then => if isTradeModuleEnabled then @_downloadPicklistWithDatasource(new PromotionPicklistManager) else @_skipStep()
    .then @_onSynchronisationSucceeded
    .fail @_onSynchronisationFailed

  _skipStep: ->
    --@STEPS_COUNT
    $.when()

  _downloadEntitiesForCollection: (collection) =>
    @_updateStatus Locale.value('synchronizationPopup.Table.' + collection.model.table)
    collection.serverConfig()
    .then (config) -> collection.sync 'read', null, { config:config, cache:collection.cache }
    .done (response) -> SyncLogManager.appendInfoLog Locale.value('synchronizationPopup.LogMessage.DownloadOk', {name: Locale.value('synchronizationPopup.Table.' + collection.model.table), count: response.totalSize})
    .fail (error) -> SyncLogManager.appendInfoLog Locale.value('synchronizationPopup.LogMessage.DownloadFail', {name: Locale.value('synchronizationPopup.Table.' + collection.model.table)})

  _uploadEntitiesForCollection: (collection) =>
    @_updateStatus(Locale.value('synchronizationPopup.Uploading') + " " + Locale.value('synchronizationPopup.Table.' + collection.model.table))
    collection.serverConfig()
    .then (config) => collection.sync 'upsert', null, { config:config, cache:collection.cache, each:@_onEntityUpload }
    .then (records) -> SyncLogManager.appendInfoLog Locale.value('synchronizationPopup.LogMessage.UploadOk', {name: Locale.value('synchronizationPopup.Table.' + collection.model.table), count: records?.length ? 0})

  _onEntityUpload: (entity, error) =>
    return unless error
    if error.type is EntitiesCollection.TYPE_WARNING
      warningParams = { type: entity.sobjectType, entity: entity.id, message: error.details.message, code: error.details.errorCode }
      SyncLogManager.appendWarning Locale.value('synchronizationPopup.LogMessage.WarningUploading', warningParams)
    else
      errorParams = { type: entity.sobjectType, entity: entity.id, message: error.details.message, code: error.details.errorCode }
      SyncLogManager.appendError Locale.value('synchronizationPopup.LogMessage.ErrorUploading', errorParams)

  _updateStatus: (status) ->
    @statusCB status, Math.round((@_stepIndex / (@STEPS_COUNT - 1)) * 100)
    ++@_stepIndex if @_stepIndex < @STEPS_COUNT - 1

  _downloadConfigurationData: =>
    @_updateStatus Locale.value('synchronizationPopup.Configuration')
    ConfigurationManager.loadConfig()
    .then (records) -> SyncLogManager.appendInfoLog  Locale.value('synchronizationPopup.LogMessage.DownloadOk', {name: Locale.value('synchronizationPopup.Configuration'), count:''})

  _downloadPicklistWithDatasource: (datasource) ->
    @_updateStatus Locale.value('synchronizationPopup.Table.' + datasource.targetModel().table) + " " + Locale.value('synchronizationPopup.PickList')
    PicklistManager.loadPicklist(datasource.targetModel().sfdcTable, datasource.fieldNames())
    .done (records) => @_appendSuccessPicklistDownloadSyncLog datasource.targetModel().table, records.length
    .fail (error) -> SyncLogManager.appendInfoLog Locale.value('synchronizationPopup.LogMessage.DownloadFail', {name: Locale.value('synchronizationPopup.Table.' + datasource.targetModel().table)})

  _appendSuccessPicklistDownloadSyncLog: (picklistEntityTableName, recordsCount) =>
    picklistName = Locale.value('synchronizationPopup.Table.' + picklistEntityTableName) + " " + Locale.value('synchronizationPopup.PickList')
    SyncLogManager.appendInfoLog Locale.value('synchronizationPopup.LogMessage.DownloadOk', {name: picklistName, count: recordsCount})

  _onSynchronisationSucceeded: =>
    SyncLogManager.updateStepsCount @_stepIndex-1
    SyncLogManager.appendInfoLog Locale.value('synchronizationPopup.LogMessage.Success')
    .then => @deviceCollection.updateDeviceInfo()
    .then => @_setLastSucceededSyncronisationDateTime()
    .then => @_uploadEntitiesForCollection @deviceCollection
    .then -> AlarmManager.scheduleNextVisits()

  _setLastSucceededSyncronisationDateTime: =>
    @deviceCollection.getDevice()
    .then (device)=>
      SettingsManager.setLastSucceededSyncDateTime(device.lastSyncronisation)

  _onSynchronisationFailed: (error) =>
    console.log JSON.stringify error
    SyncLogManager.updateStepsCount @_stepIndex-1
    SyncLogManager.appendError error
    .then -> SyncLogManager.appendInfoLog Locale.value('synchronizationPopup.LogMessage.Error')
    .then => @deviceCollection.updateDeviceInfo()
    .then => @_uploadEntitiesForCollection @deviceCollection

  _processConfiguration: =>
    # ConfigurationManager.getConfig 'isTradeModuleEnabled'
    # .then (value) -> SettingsManager.setValueByKey 'isTradeModuleEnabled', value
    ConfigurationManager.getConfig('isDynamicAgendaEnabled')
    .then (value) -> SettingsManager.setValueByKey 'isDynamicAgendaEnabled', value
    .then -> ConfigurationManager.getConfig('isEdetailingEnabled')
    .then (value) -> SettingsManager.setValueByKey 'isEdetailingEnabled', value
    .then -> ConfigurationManager.getConfig('isJuridicGroupEnabled')
    .then (value) -> SettingsManager.setValueByKey 'isJuridicGroupEnabled', value
    .then -> ConfigurationManager.getConfig('tourPlanningSettings')
    .then (value) -> SettingsManager.setValueByKey 'tourPlanningSettings', value
    # .then -> ConfigurationManager.getConfig('isPortfolioSellingModuleEnabled')
    # .then (value) -> SettingsManager.setValueByKey 'isPortfolioSellingModuleEnabled', value

module.exports = SyncManager