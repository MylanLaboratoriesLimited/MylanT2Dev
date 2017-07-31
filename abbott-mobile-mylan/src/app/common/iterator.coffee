class Iterator
  constructor: (@list) ->
    @first()
  first: ->
    @current = 0
  next: ->
    @list[++@current] if @hasNext()
  prev: ->
    @list[--@current] if @hasPrev()
  hasNext: ->
    @current < @list.length - 1
  hasPrev: ->
    @current > 0
  isDone: ->
    not @hasNext() or not @hasPrev()
  currentItem: ->
    @list[@current]
  currentIndex: ->
    @current
  setCurrentIndex: (index) ->
    isIndexValid = index >= 0 and index < @list.length
    if isIndexValid then @current = index else throw 'You are trying to set Iterator index out of bounds'

module.exports = Iterator