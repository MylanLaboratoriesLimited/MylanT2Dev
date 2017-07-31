Spine = require 'spine'
Utils = require 'common/utils'
TotPicklistManager = require 'db/picklist-managers/tot-picklist-manager'
ConfigurationManager = require 'db/configuration-manager'
Tot = require 'models/tot'
Locale = require 'common/localization/locale'

class TotsAllTableCell extends Spine.Controller
  className: 'row'

  elements:
    '.med-rep': 'elMedRep'
    '.type': 'elType'
    '.all-day': 'elAllDay'
    '.start-date': 'elStartDate'
    '.end-date': 'elEndDate'
    '.events': 'elEvents'

  constructor: (@tot, @hasQuarters = true) ->
    super {}
    @totPicklistManager = new TotPicklistManager

  template: ->
    require('views/tots/tots-all/tots-all-table-cell')()

  _onCellTap: =>
    @trigger 'cellTap', @

  bindEvents: =>
    @el.on 'tap', @_onCellTap

  _validateLabel: (label) ->
    if label is Locale.value('common:defaultSelectValue') then '' else label

  _setQuarters: =>
    @elEvents.addClass 'list'
    fieldName = Tot.sfdc.firstQuarterEvent
    @_setQuarter fieldName, @tot.firstQuarterEvent, Locale.value('card.Tot.FirstPart')
    @_setQuarter fieldName, @tot.secondQuarterEvent, Locale.value('card.Tot.SecondPart')
    @_setQuarter fieldName, @tot.thirdQuarterEvent, Locale.value('card.Tot.ThirdPart')
    @_setQuarter fieldName, @tot.fourthQuarterEvent, Locale.value('card.Tot.ForthPart')

  _setQuarter: (fieldName, quarterEvent, eventLabel) =>
    @totPicklistManager.getLabelByValue(fieldName, quarterEvent)
    .then (label) => @elEvents.append "<p>#{eventLabel} #{@_validateLabel label}</p>"

  _setMorningAfternoon: =>
    @elEvents.addClass 'list morning-afternoon'
    fieldName = Tot.sfdc.firstQuarterEvent
    @_setQuarter fieldName, @tot.firstQuarterEvent, Locale.value('card.Tot.Morning')
    @_setQuarter fieldName, @tot.thirdQuarterEvent, Locale.value('card.Tot.Afternoon')

  render: ->
    @html @template()
    @elMedRep.html @tot.userFullName()
    @elAllDay.addClass 'checked' if @tot.allDay
    @elStartDate.html Utils.dotFormatDate @tot.startDate
    @elEndDate.html Utils.dotFormatDate @tot.endDate
    @totPicklistManager.getLabelByValue(Tot.sfdc.type, @tot.type)
    .then (label) => @elType.html label

    ['firstQuarterEvent', 'secondQuarterEvent', 'thirdQuarterEvent', 'fourthQuarterEvent'].forEach (eventField) =>
      @tot[eventField] = '' if @tot[eventField] is @tot.TYPE_NONE

    if @tot.allDay
      @totPicklistManager.getLabelByValue(Tot.sfdc.firstQuarterEvent, @tot.firstQuarterEvent)
      .then (label) => @elEvents.html @_validateLabel label
    else
      if @hasQuarters then @_setQuarters() else @_setMorningAfternoon()
    @

module.exports = TotsAllTableCell