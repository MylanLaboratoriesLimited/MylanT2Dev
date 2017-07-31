PicklistManager = require 'db/picklist-managers/picklist-manager'
Locale = require 'common/localization/locale'

class PicklistDatasourceManager
  targetModel: ->
    throw 'Should be overridden'

  fieldNames: ->
    throw 'Should be overridden'

  getPickLists: ->
    PicklistManager.getPicklist(@targetModel().sfdcTable, @fieldNames())
    .then (@pickLists) -> @pickLists

  getPickList: (pickListName) ->
    @getPickLists()
    .then (pickLists) -> pickLists[pickListName]

  getLabelByValue: (pickListName, value) ->
    @getPickList(pickListName)
    .then (pickList) ->
      _(pickList).find (element) -> element.value is value
    .then (element) ->
      if element then element.label or element.value
      else if value is false then Locale.value('common:defaultSelectValue')
      else value

module.exports = PicklistDatasourceManager