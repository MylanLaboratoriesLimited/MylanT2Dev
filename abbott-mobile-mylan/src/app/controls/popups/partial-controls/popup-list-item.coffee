Spine = require 'spine'

class PopupListItem extends Spine.Controller
  events:
    "tap":"_onTap"

  tag:'li'

  elements:
    '.input': 'elInput'

  constructor: (@model) ->
    super

  render:->
    @html require('views/controls/popups/partial-controls/popup-list-item')(model:@model)

  setItemSelected:->
    @elInput.prop 'checked', true

  _onTap: (event)->
    event.stopPropagation()
    @setItemSelected()
    setTimeout(
      =>
        @trigger "onPopupItemSelected", @
      ,100
    )

module.exports = PopupListItem