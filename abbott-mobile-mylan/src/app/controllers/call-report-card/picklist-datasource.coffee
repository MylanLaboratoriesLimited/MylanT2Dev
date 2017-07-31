Locale = require 'common/localization/locale'

class PickListDatasource
  getItems: =>
    if @items
      $.when @items
    else
      @pickListManager().getPickList(@pickListName())
      .then @_preparePickListItems
      .then (@items) =>
        @items

  _preparePickListItems: (pickList) =>
    noneValue = [
      id: null
      description: Locale.value('common:defaultSelectValue')
    ]
    unless _.isEmpty pickList
      noneValue.concat(pickList.map (el) -> { id: el.value, description: el.label })
    else
      noneValue

  getItemForSelectedValue:(value) ->
    @getItems()
    .then (items) =>
      _(items).find (item) => item.id is value
    .then (item) =>
      if item then item
      else if value
        id: value
        description: value
      else null

  pickListName: ->
    throw new Error 'This method should be overridden.'

  pickListManager: ->
    throw new Error 'This method should be overridden.'

module.exports = PickListDatasource