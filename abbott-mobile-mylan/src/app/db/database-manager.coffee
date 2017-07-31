Utils = require 'common/utils'
BuTeamPersonProfile = require 'models/bu-team-person-profile'
CallReport = require 'models/call-report'
Contact = require 'models/contact'
MarketingCycle = require 'models/marketing-cycle'
MarketingMessage = require 'models/marketing-message'
Brick = require 'models/brick'
Organization = require 'models/organization'
PEAbbottAttendee = require 'models/pe-abbott-attendee'
PEAttendee = require 'models/pe-attendee'
PharmaEvent = require 'models/pharma-event'
Product = require 'models/product'
Reference = require 'models/reference'
TargetFrequency = require 'models/target-frequency'
Target = require 'models/target'
Tot = require 'models/tot'
User = require 'models/user'
Presentation = require 'models/presentation'
SettingsManager = require 'db/settings-manager'
PicklistManager = require 'db/picklist-managers/picklist-manager'
Device = require 'models/device'
SforceDataContext = require 'models/bll/sforce-data-context'
AlarmManager = require 'common/alarm/alarm-manager'
PresentationFileManager = require 'common/presentation-managers/presentations-file-manager'
AttachmentFileManager = require 'common/attachment-managers/attachment-file-manager'
PhotoAttachmentFileManager = require 'common/attachment-managers/photo-attachment-file-manager'
CLMCallReportData = require 'models/clm-call-report-data'
Scenario = require 'models/scenario'
PromotionAccount = require 'models/promotion-account'
PromotionTaskAccount = require 'models/promotion-task-account'
TaskAdjustment = require 'models/task-adjustment'
ProductItem = require 'models/product-item'
PromotionSku = require 'models/promotion-sku'
PromotionMechanic = require 'models/promotion-mechanic'
MechanicAdjustment = require 'models/mechanic-adjustment'
MechanicEvaluationAccount = require 'models/mechanic-evaluation-account'
PhotoAdjustment = require 'models/photo-adjustment'
PromotionNote = require 'models/promotion-note'
PromotionAttachment = require 'models/promotion-attachment'
PhotoAttachment = require 'models/photo-attachment'
LocalImage = require 'models/local-image'
ProductInPortfolio = require 'models/product-in-portfolio'
ProfileProductInPortfolio = require 'models/profile-product-in-portfolio'
PatientDisease = require 'models/patient-disease'

class DatabaseManager
  models: [
    BuTeamPersonProfile
    CallReport
    Contact
    MarketingCycle
    MarketingMessage
    Brick
    Organization
    PEAbbottAttendee
    PEAttendee
    PharmaEvent
    Product
    Reference
    TargetFrequency
    Target
    Tot
    User
    Presentation
    Device
    CLMCallReportData
    Scenario
    PromotionAccount
    PromotionTaskAccount
    TaskAdjustment
    ProductItem
    PromotionSku
    PromotionMechanic
    MechanicAdjustment
    MechanicEvaluationAccount
    PhotoAdjustment
    PromotionNote
    PromotionAttachment
    PhotoAttachment
    LocalImage
    ProductInPortfolio
    ProfileProductInPortfolio
    PatientDisease
  ]

  initializeDatabase: =>
    @_isDifferentUserLoggedIn()
    .then (isDifferentUser) =>
      if isDifferentUser
        @clearDatabase()
        .then @_clearSettings
        .then @_disableTradeModule
        .then @_disablePortfolioModule
      else
        @_setupDatabase()
    .then @_saveCurrentUser

  clearDatabase: =>
    @_clearDBSchemaModels()
    .then(@_clearPicklists)
    .then(@_resetAlarmNotifications)
    .then(@_clearPresentationsStore)
    .then(@_clearAttachmentsStore)
    .then(@_clearPhotoAttachmentsStore)
    .then(SforceDataContext.cleanup)

  _clearDBSchemaModels: =>
    Utils.runSimultaneously _(@models).map (model) => @_dropSoup model

  _dropSoup: (model) =>
    Force.smartstoreClient.soupExists(model.table)
    .then((soupExists) => Force.smartstoreClient.removeSoup model.table if soupExists)
    .done(=> @_createSoup model)

  _createSoup: (model) =>
    model.mapModel()
    cache = new Force.StoreCache model.table, model.indexSpec
    Force.smartstoreClient.soupExists(model.table)
    .then (soupExists) => cache.init() unless soupExists

  _clearSettings: =>
    SettingsManager.clearData()

  _disableTradeModule: =>
    SettingsManager.setValueByKey 'isTradeModuleEnabled', false

  _disablePortfolioModule: =>
    SettingsManager.setValueByKey 'isPortfolioSellingModuleEnabled', false

  _clearPicklists: =>
    PicklistManager.clearData()

  _resetAlarmNotifications: =>
    AlarmManager.cancelNotification()

  _clearPresentationsStore: =>
    PresentationFileManager.wipePresentationsStore()

  _clearAttachmentsStore: =>
    AttachmentFileManager.wipeStorage()

  _clearPhotoAttachmentsStore: =>
    PhotoAttachmentFileManager.wipeStorage()

  _setupDatabase: =>
    Utils.runSimultaneously _(@models).map (model) => @_createSoup model

  _isDifferentUserLoggedIn: =>
    SettingsManager.getValueByKey 'UserId'
    .then (userId) -> userId isnt Force.userId and userId?

  _saveCurrentUser: =>
    SettingsManager.setValueByKey 'UserId', Force.userId

module.exports = DatabaseManager