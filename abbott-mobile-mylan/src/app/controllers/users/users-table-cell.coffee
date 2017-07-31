Spine = require 'spine'
Utils = require 'common/utils'

class UsersTableCell extends Spine.Controller
  className: 'row'

  elements:
    '.check-box': 'elCheckbox'
    '.user': 'elUser'
    '.email': 'elEmail'

  isChecked: false

  constructor: (@user) ->
    super {}

  template: ->
    require('views/users/users-table-cell')()

  _onCellTap: =>
    @isChecked = !@elCheckbox[0].checked
    @_setSelectedCheckbox()
    @trigger 'cellTap', @

  bindEvents: =>
    @el.on 'tap', @_onCellTap

  render: ->
    @html @template()
    @elUser.text @user.fullName()
    @elEmail.text @user.email
    @_setSelectedCheckbox() if @isChecked
    @

  _setSelectedCheckbox: =>
    @elCheckbox[0].checked = @isChecked

module.exports = UsersTableCell