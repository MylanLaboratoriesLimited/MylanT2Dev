Spine = require 'spine'
BasePopup = require 'controls/popups/base-popup'
PopupListItem = require 'controls/popups/partial-controls/popup-list-item'

class ListPopup extends BasePopup
  className: 'popup list'

  constructor: (@datasource, @selectedItem = @datasource[0], @caption) ->
    super @caption

  show: =>
    super if @datasource and @datasource.length > 0

  _renderContent: =>
    @elContent.addClass 'scroll-container'
    @scrollList = $ document.createElement('ul')
    @scrollList.addClass 'popup-items-list scroll-content'
    @elContent.html @scrollList
    @_renderList()

  _renderList: =>
    @datasource.forEach (item) =>
      popupItem = new PopupListItem item
      @scrollList.append popupItem.el
      popupItem.on 'onPopupItemSelected', @_onPopupItemSelected
      popupItem.render()
      popupItem.setItemSelected() if item.id is @selectedItem.id

  render: =>
    super
    @_calculatePosition()

  _getSelectedItemIndex: =>
    @datasource.map((el) => el.id is @selectedItem.id).indexOf true

  _calculatePosition: =>
    popupHeight = @elPopup.height()
    headerHeight = if @elHeader.is ':visible' then @elHeader.outerHeight(true) else 0
    buttonsHeight = if @elButtonSection.is ':visible' then @elButtonSection.outerHeight(true) else 0
    if popupHeight > window.innerHeight * 0.75
      @elContent.css 'max-height', popupHeight - headerHeight - buttonsHeight
    selectedItemOrderNumber = @_getSelectedItemIndex()
    @elContent.scrollTop(@scrollList.children().eq(selectedItemOrderNumber).position().top) unless selectedItemOrderNumber is -1

  _onPopupItemSelected: (selectedItem) =>
    @trigger 'onPopupItemSelected', selectedItem

module.exports = ListPopup