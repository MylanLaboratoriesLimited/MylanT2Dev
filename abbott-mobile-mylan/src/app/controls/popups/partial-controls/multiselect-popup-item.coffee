PopupListItem = require 'controls/popups/partial-controls/popup-list-item'

class MultiselectPopupItem extends PopupListItem
  constructor: (@model, @datasource) ->
    super @model

  setItemUnselected: ->
    @elInput.prop 'checked', false

  _onTap: (event) ->
    event.stopPropagation()
    if @elInput.prop('checked') and @datasource.isCanDeselectItem()
      @setItemUnselected()
      @trigger "onPopupItemUnselected", @
    else if @datasource.isCanSelectItem()
      @setItemSelected()
      @trigger "onPopupItemSelected", @

module.exports = MultiselectPopupItem