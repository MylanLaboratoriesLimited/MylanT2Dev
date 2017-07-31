PanelScreen = require 'controllers/base/panel/panel-screen'
TotsColection = require '/models/bll/tots-collection/tots-collection'
Utils = require 'common/utils'
TotEventsPickListDatasource = require 'controllers/tot-card/tot-events-picklist-datasource'
ConfigurationManager = require 'db/configuration-manager'
TotPicklistManager = require 'db/picklist-managers/tot-picklist-manager'
Tot = require 'models/tot'
CommonInput = require 'controls/common-input/common-input'
HeaderBaseControl = require 'controls/header-controls/header-base-control'
Header = require 'controls/header/header'
ConfirmationPopup = require 'controls/popups/confirmation-popup'

class TotCardView extends PanelScreen
  className: 'tot card'

  elements:
    '.tot-card-user': 'elUserFullName'
    '.check-all-day': 'elAllDay'
    '.tot-card-start-date': 'elStartDate'
    '.tot-card-end-date': 'elEndDate'
    '.first-quarter': 'elFirstQuarter'
    '.second-quarter': 'elSecondQuarter'
    '.third-quarter': 'elThirdQuarter'
    '.fourth-quarter': 'elFourthQuarter'
    '.call-comments': 'elDescription'
    '.morning': 'morningLabel'
    '.afternoon': 'afternoonLabel'

  _hasQuarters: true

  maxCommentStringLength: 50

  constructor: (@totId, @allowDelete = false) ->
    super
    @collection = new TotsColection
    @totPicklistManager = new TotPicklistManager

  active: ->
    super
    @_init()

  _init: ->
    @render()

  render: ->
    @html @template()
    @_initHeader()
    @_initContent()
    Locale.localize @el
    @_fetchConfig()
    .then @_fillInfoWithConfig
    @

  template: ->
    require('views/tot-card/tot-card')()

  _initHeader: ->
    totHeader = new Header Locale.value('card.Tot.HeaderTitle')
    if @allowDelete
      deleteBtn = new HeaderBaseControl Locale.value('common:buttons.DeleteBtn'), 'ctrl-btn red'
      deleteBtn.bind 'tap', @_onDeleteTap
      totHeader.render()
      totHeader.addRightControlElement deleteBtn.el
    else
      totHeader.render()
    @setHeader totHeader

  _initContent: =>
    @el.addClass if @allowDelete then 'view-mode' else 'edit-mode'

  _onDeleteTap: =>
    confirm = new ConfirmationPopup { caption: Locale.value('card.Tot.ConfirmationPopup.DeleteItem.Caption'), message: Locale.value('card.ConfirmationPopup.DeleteItem.Question') }
    confirm.bind 'yesClicked', @_onDeleteApprove
    confirm.bind 'noClicked', @_onDeleteDiscard
    @presentModalController confirm

  _onDeleteApprove: (confirm) =>
    @dismissModalController()
    @collection.removeEntity(@tot)
    .then =>
      @trigger 'totChanged'
      @onBack()

  _onDeleteDiscard: (confirm) =>
    @dismissModalController()

  _fetchConfig: =>
    ConfigurationManager.getConfig('countryAndCurrencySettings')

  _fillInfoWithConfig: (config) =>
    @_hasQuarters = config.isQuarter if config
    unless @totId then @_fillDefaultInfo()
    else
      @collection.fetchEntityById(@totId)
      .then (@tot) =>	@_fillGeneralInfo()

  _fillDefaultInfo: ->
    throw 'should be overridden'

  _fillGeneralInfo: ->
    @_initUserFullName()
    @_initAllDay()
    @_initStartDate()
    @_initEndDate()
    @_initFirstQuarter()
    @_initThirdQuarter()
    @el.addClass 'view-mode' if @tot.type is 'Closed' or @tot.type is 'Submit'
    if @_hasQuarters
      @_initSecondQuarter()
      @_initFourthQuarter()
    else
      @el.addClass 'morning-afternoon'
      @morningLabel.text Locale.value('card.Tot.Morning')
      @afternoonLabel.text Locale.value('card.Tot.Afternoon')
    @_initDescription @tot.description ? ''

  _initUserFullName: ->
    @userFullName = @tot.userFullName()
    @elUserFullName.html @userFullName

  _initAllDay: ->
    @allDay = @tot.allDay
    @elAllDay[0].checked = @allDay

  _initStartDate: ->
    @startDate = Utils.getDateByStr(@tot.startDate)
    @elStartDate.html Utils.dotFormatDate @startDate

  _initEndDate: ->
    @endDate = Utils.getDateByStr(@tot.endDate)
    @elEndDate.html Utils.dotFormatDate @endDate

  _initFirstQuarter: ->
    @_initQuarter @tot.firstQuarterEvent, @elFirstQuarter

  _initSecondQuarter: ->
    @_initQuarter @tot.secondQuarterEvent, @elSecondQuarter

  _initThirdQuarter: ->
    @_initQuarter @tot.thirdQuarterEvent, @elThirdQuarter

  _initFourthQuarter: ->
    @_initQuarter @tot.fourthQuarterEvent, @elFourthQuarter

  _initQuarter: (quarterEvent, quarterLabel) =>
    @totPicklistManager.getLabelByValue(Tot.sfdc.firstQuarterEvent, quarterEvent)
    .then (label) => quarterLabel.html label

  _initDescription: (@description) ->
    @elDescription.val @description
    new CommonInput @el[0], @elDescription[0], @maxCommentStringLength
    @elDescription.on 'input', @_onDescriptionChange

  _onDescriptionChange: =>
    @isChanged = true
    @description = @elDescription.val()

module.exports = TotCardView