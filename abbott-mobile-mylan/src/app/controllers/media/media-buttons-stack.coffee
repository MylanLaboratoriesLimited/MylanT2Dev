Spine = require 'spine'
Button = require 'controls/button/button'

class DoneIcon extends Spine.Controller
  className: 'done-icon'

class MediaButtonsStack extends Spine.Stack
  className: 'media-buttons-stack'

  controllers:
    download: Button
    update: Button
    cancel: Button
    doneIcon: DoneIcon

  default: 'download'

  render: ->
    @download.setTitle Locale.value('common:buttons.Download')
    @update.setTitle Locale.value('common:buttons.Update')
    @cancel.setTitle Locale.value('common:buttons.Cancel')

  bindStackControllersEvents: ->
    @download.el.on 'tap', @downloadTap
    @update.el.on 'tap', @updateTap
    @cancel.el.on 'tap', @cancelTap

  downloadTap: (event) =>
    @_stopEvent event
    @trigger 'download'

  updateTap: (event) =>
    @_stopEvent event
    @trigger 'update'

  cancelTap: (event) =>
    @_stopEvent event
    @trigger 'cancel'

  _stopEvent: (event) ->
    event.stopPropagation()
    event.preventDefault()

  # TODO: refactor method names (remove btn or icon parts, let it be state or nothing at all)
  activateCancelBtn: ->
    @cancel.active()

  activateDownloadBtn: ->
    @download.active()

  activateUpdateBtn: ->
    @update.active()

  activateDoneIcon: ->
    @doneIcon.active()

module.exports = MediaButtonsStack