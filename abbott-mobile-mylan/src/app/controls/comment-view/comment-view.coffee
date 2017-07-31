Spine = require('spine')
AndroidViewResizer = require 'common/android-view-resizer'

class CommentView extends Spine.Controller
  className: "comment"

  events:
    "tap .done-btn":"_onSubmit"
    "keyup .input": "_onKeyUp"
    "input .input": "_refreshPlaceholder"
    "touchmove .input": "_preventDefault"
    "tap .btnCancel": "hide"
    "tap .btnDone": "_onSubmit"
    "touchmove .btnCancel": "_preventDefault"
    "touchmove .btnDone": "_preventDefault"

  elements:
    ".input": "elInput"
    ".placeholder": "elPlaceholder"
    "textarea": "elTextArea"

  constructor: (@defaultText, @maxStringLength=null, @placeholder) ->
    super {}

  show: ->
    @render()
    new AndroidViewResizer @el[0], @elInput[0]
    @elInput.focus()
    @elInput.val @defaultText
    @_refreshPlaceholder()
    @_setMaxStringLength()
    document.addEventListener('backbutton', @hide, false);
    @el.bind 'touchmove', @_preventDefault

  _preventDefault: (event) =>
    event.preventDefault() if event.target is @elInput

  hide: =>
    @elInput.blur()
    document.removeEventListener('backbutton', @hide, false);
    @release()

  _setMaxStringLength: =>
    if @maxStringLength then @elTextArea.attr 'maxLength', @maxStringLength

  render: ->
    @html require('views/comment/comment')()
    Locale.localize @el
    @elPlaceholder.html @placeholder if @placeholder
    app.mainController.append @el

  _onSubmit: =>
    comment = @elInput.val()
    @trigger "onComment", comment
    @hide()

  _refreshPlaceholder: ->
    unless @elInput.val() then @elPlaceholder.show() else @elPlaceholder.hide()

  _onKeyUp: (key) =>
    @_refreshPlaceholder()

  _preventDefault: (event) =>
    event.preventDefault()


module.exports = CommentView