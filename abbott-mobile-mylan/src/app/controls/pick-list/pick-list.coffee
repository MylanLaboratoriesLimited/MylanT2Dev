ListPopup = require 'controls/popups/list-popup'

class PickList
  constructor: (@context, @target, @datasource, @selectedValue) ->
    @target.parent().bind 'tap', @show
    @setValue @selectedValue

  show: =>
    @datasource.getItems()
    .then (items) =>
      popup = new ListPopup(@_prepareItems(items), @selectedItem)
      popup.bind 'onPopupItemSelected', (@selectedItem) =>
        @selectedValue = @selectedItem.id
        @target.html @selectedItem.description
        @_onPickListItemSelected @selectedItem
        @context.dismissModalController()
      @context.presentModalController popup

  _prepareItems: (items) ->
    unless (items.some (item) => item.id is @selectedValue)
      items.push
        id: @selectedValue
        description: @selectedValue
    items

  setValue: (@selectedValue) ->
    @datasource.getItemForSelectedValue @selectedValue
    .then (@selectedItem) =>
      @target.html @selectedItem.description

  _onPickListItemSelected: (selectedItem) =>
    @context.trigger 'onPickListItemSelected', selectedItem

  bind: (eventName, event) ->
    @context.bind eventName, event

module.exports = PickList