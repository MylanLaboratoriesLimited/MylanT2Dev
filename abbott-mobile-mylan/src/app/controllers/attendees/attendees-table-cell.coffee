Spine = require 'spine'
Utils = require 'common/utils'

class AttendeesTableCell extends Spine.Controller
  className: "row"

  elements:
    '.check-box': 'elCheckbox'
    '.specialty': 'elSpecialty'
    '.contact': 'elContact'

  isChecked: false

  constructor: (@contact) ->
    super {}

  template: ->
    require('views/attendees/attendees-table-cell')()

  _onCellTap: =>
    @isChecked = !@elCheckbox[0].checked
    @_setSelectedCheckbox()
    @trigger 'cellTap', @

  bindEvents: =>
    @el.on 'tap', @_onCellTap
    @elContact.on 'tap', @_onContactTap

  _onContactTap: (event) =>
    event.stopPropagation()
    @trigger 'contactTap', @

  render: ->
    @html @template()
    @elContact.html "#{@contact.fullName()} <br/> #{@contact.recordType ? ''}"
    @elSpecialty.html @contact.abbottSpecialty
    if @isChecked
      @_setSelectedCheckbox()
    @

  _setSelectedCheckbox: =>
    @elCheckbox[0].checked = @isChecked

module.exports = AttendeesTableCell