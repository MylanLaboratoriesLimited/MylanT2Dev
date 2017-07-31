CommonInput = require 'controls/common-input/common-input'
ListPopup = require 'controls/popups/list-popup'
Locale = require 'common/localization/locale'
CallReport = require 'models/call-report'

class SummaryPopupListDatasource
  @default: ->
    {id: -1,  description: Locale.value('common:defaultSelectValue'), value: null}
  @yes: ->
    {id: 0, description: Locale.value('common:buttons.YesBtn'), value: CallReport.PORTFOLIO_PRESENTATION_REMINDER_YES}
  @no: ->
    {id: 1, description: Locale.value('common:buttons.NoBtn'), value: CallReport.PORTFOLIO_PRESENTATION_REMINDER_NO}
  @resources: ->
    [@default(), @yes(), @no()]


class Summary extends Spine.Controller
  className: 'summary'

  elements:
    '.patient-support':'elPatientSupport'
    '.portfolio-feedback':'elFeedback'
    '.check-box': 'elPationSupport'
    '.full-portfolio-btn':'elFullPortfolio'

  events:
    'tap .full-portfolio-btn':'_showListPopup'

  summaryEntity: null

  constructor: (@summaryEntity) ->
    super {}
    @isChanged = false
    if @summaryEntity.fullPortfolioPresentationReminder
      @fullPortfolio = if @summaryEntity.fullPortfolioPresentationReminder is CallReport.PORTFOLIO_PRESENTATION_REMINDER_YES then SummaryPopupListDatasource.yes() else SummaryPopupListDatasource.no()
    else
      @fullPortfolio = SummaryPopupListDatasource.default()

  render: ->
   	@html @template()
    Locale.localize @el
    @elFullPortfolio.html @fullPortfolio.description
    @_initCommonInputs()
    @_initPatientSupportProgram()
    @

  template: ->
    require('views/call-report-card/portfolio/summary')()

  _initCommonInputs: ->
    @_initPatientSupport @summaryEntity.patientSupportProgramComments or ''
    @_initFeedback @summaryEntity.portfolioFeedback or ''

  _initPatientSupport: (value) ->
    # TODO: CommonInput like control
    @_setElementFontStyleByValue @elPatientSupport, value
    @elPatientSupport.val value
    new CommonInput $('.call-report .wrapper'), @elPatientSupport[0]
    @elPatientSupport.on 'change', =>
      @isChanged = true
      @summaryEntity.patientSupportProgramComments = @elPatientSupport[0].getValue()

  _initFeedback: (value)->
    # TODO: CommonInput like control
    @_setElementFontStyleByValue @elFeedback, value
    @elFeedback.val value
    new CommonInput $('.call-report .wrapper'), @elFeedback[0]
    @elFeedback.on 'change', =>
      @isChanged = true
      @summaryEntity.portfolioFeedback = @elFeedback[0].getValue()

  _setElementFontStyleByValue: (element,value)->
    unless value.length then element.addClass "call-report-empty-font-style"

  _initPatientSupportProgram: =>
    @elPationSupport.prop("checked", true) if @summaryEntity.patientSupportProgram
    @elPationSupport.on 'change', =>
      @isChanged = true
      @summaryEntity.patientSupportProgram = @elPationSupport.prop("checked")

  _showListPopup: ->
    listPopup = new ListPopup SummaryPopupListDatasource.resources(), @fullPortfolio
    listPopup.bind 'onPopupItemSelected', (selectedItem) =>
      @isChanged = true
      @fullPortfolio = selectedItem.model
      @elFullPortfolio.html @fullPortfolio.description
      @summaryEntity.fullPortfolioPresentationReminder = @fullPortfolio.value
      @trigger 'dismissModalController'
    @trigger 'presentModalController', listPopup

module.exports = Summary