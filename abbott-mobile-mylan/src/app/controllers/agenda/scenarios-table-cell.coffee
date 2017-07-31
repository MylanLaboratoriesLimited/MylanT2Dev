Spine = require 'spine'
Switcher = require 'common/switcher'

class ScenariosTableCell extends Spine.Controller
  className: 'row'

  elements:
    '.name': 'elScenarioName'
    '.open': 'elOpenButton'
    '.openContainer': 'elOpenButtonContainer',
    '.delete': 'elDeleteButton',
    '.cell-wrapper': 'elCellWrapper'
    '.delete-btn-wrapper': 'deleteBtnWrapper'

  TIME_DELAY: 400

  constructor: (@scenario) ->
    super {}

  template: ->
    require('views/agenda/scenarios-table-cell')()

  bindEvents: =>
    @el.on 'tap', @_onCellTap
    @elOpenButton.on 'tap', @_onOpenScenarioTap
    @elDeleteButton.on 'tap', @_onDeleteScenarioTap
    @elOpenButtonContainer.on 'tap', @_onOpenScenarioTap
    @elCellWrapper.on 'onSwitcherShow', @_showDeleteButton
    @elCellWrapper.on 'onSwitcherHide', @_hideDeleteButton
    @switcher = new Switcher @elCellWrapper, @deleteBtnWrapper

  _onCellTap: (event) =>
    @trigger 'cellTap', @ unless @switcher.isMove

  _onOpenScenarioTap: (event) =>
    event.stopPropagation()
    @trigger 'openScenarioTap', @

  _onDeleteScenarioTap: (event) =>
    event.stopPropagation()
    @trigger 'deleteScenarioTap', @

  render: ->
    @html @template()
    @elScenarioName.html @scenario.name
    Locale.localize @el
    @

  _showDeleteButton: =>
    @trigger 'deleteScenarioShow', @

  _hideDeleteButton: =>
    @trigger 'deleteScenarioHide', @

module.exports = ScenariosTableCell
