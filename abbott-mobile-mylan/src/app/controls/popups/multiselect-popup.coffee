ListPopup = require 'controls/popups/list-popup'
MultiselectPopupItem = require 'controls/popups/partial-controls/multiselect-popup-item'

class MultiselectPopup extends ListPopup
  className: 'popup list single-button'

  constructor: (@datasource, @selectedItems = [], @caption, @maxSelectedItemsCount = 4, @minSelectedItemsCount = 0) ->
    super @datasource, @selectedItems, @caption

  _onPopupItemsUpdated: =>
    @trigger 'onPopupItemsUpdated', @selectedItems
    @_checkItems()

  isCanSelectItem: =>
    @selectedItems.length < @maxSelectedItemsCount

  isCanDeselectItem: =>
    @selectedItems.length > @minSelectedItemsCount

  _onPopupItemSelected: (item) =>
    @selectedItems.push item.model unless _.contains(@selectedItems, item.model)
    @_onPopupItemsUpdated()

  _onPopupItemUnselected: (item) =>
    @selectedItems = @selectedItems.filter (selectedItem) => selectedItem isnt item.model
    @_onPopupItemsUpdated()

  _blockItems: (item) =>
    unless (@selectedItems.some (el) => el.id is item.id)
      item.el.addClass 'blocked'

  _unblockItems: ->
    if @isItemsBlocked
      @listItems.forEach (item) => item.el.removeClass 'blocked'
      @isItemsBlocked = true

  _checkItems: ->
    if @isCanSelectItem()
        @_unblockItems()
    else
      @isItemsBlocked = true
      @listItems.forEach @_blockItems

  _getSelectedItemIndex: =>
    @datasource.map((el) => @selectedItem.some((item)=>item.id is el.id)).indexOf true

  _renderList: =>
    @listItems = []
    @elContent.on 'tap', (event)-> event.stopPropagation()
    @datasource.forEach (item) =>
      popupItem = new MultiselectPopupItem item, @
      @scrollList.append popupItem.el
      popupItem.on 'onPopupItemSelected', @_onPopupItemSelected
      popupItem.on 'onPopupItemUnselected', @_onPopupItemUnselected
      popupItem.render()
      popupItem.elInput.attr 'type', 'checkbox'
      popupItem.setItemSelected() if _.contains(@selectedItems, popupItem.model)
      @listItems.push popupItem
    @_checkItems()

  _renderButtons: =>
    @elButtonSection.html require('views/controls/popups/partial-controls/done-buttons')()
    @elDoneButton = @el.find '.btn.yes'
    @elDoneButton.bind 'tap', @_onDoneTap

  _onDoneTap: =>
    @trigger 'doneTap', @selectedItems
    @_checkItems()

module.exports = MultiselectPopup