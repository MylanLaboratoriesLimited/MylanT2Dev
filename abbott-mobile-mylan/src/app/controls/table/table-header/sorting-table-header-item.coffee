Spine = require 'spine'
TableHeaderItem = require 'controls/table/table-header/table-header-item'

class SortingTableHeaderItem extends TableHeaderItem
  className: "#{@::className} sort-filter"
  isSortable: true
  isAsc: true
  fields: null

  constructor: (@title='', @fields...) ->
    super
    @el.on 'tap', @_onTap

  active: ->
    super
    @_toggleDirection @isAsc

  render: ->
    @html $(document.createElement('span')).html @title
    @

  _onTap: (event) =>
    if @isActive()
      @isAsc = !@isAsc
      @_toggleDirection @isAsc

  _toggleDirection: (isAsc) ->
    unless isAsc then @el.addClass 'desc' else @el.removeClass 'desc'

module.exports = SortingTableHeaderItem