CommentView = require 'controls/comment-view/comment-view'

class CommentInput

  constructor: (@context, @button, @description, @placeholder, @maxLength=1000) ->
    @button.bind 'tap', @show
    @setDescription @description

  show: =>
    commentView = new CommentView @description, @maxLength, @placeholder
    commentView.bind 'onComment', (@description) =>
      @setDescription @description
      @_onComentTyped @description
      @_onComentHide()
    @_onComentShow()
    commentView.show()

  _refreshPlaceholder: ->
    if @description?.length > 0
      @button.removeClass 'placeholder'
    else
      @button.addClass 'placeholder'
      @button.html @placeholder

  setDescription: (@description) =>
    @button.html @description.replace /\n/gim, '<br/>'
    @_refreshPlaceholder()

  _onComentTyped: (description) =>
    @context.trigger 'onCommentTyped', description

  _onComentShow: ->
    @context.trigger 'onCommentShow', @

  _onComentHide: ->
    @context.trigger 'onCommentHide', @

  bind: (eventName, event) ->
    @context.bind eventName, event

module.exports = CommentInput