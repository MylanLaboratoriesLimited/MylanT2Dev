class TotsFilter
  @totsAll: ->
    {id: 0, description: Locale.value('tots.FilterPopup.All')}

  @totsOpen: ->
    {id: 1, description: Locale.value('tots.FilterPopup.Open')}

  @totsSubmit: ->
    {id: 2, description: Locale.value('tots.FilterPopup.Submit')}

  @totsClosed: ->
    {id: 3, description: Locale.value('tots.FilterPopup.Closed')}

  @resources: ->
    [@totsAll(), @totsOpen(), @totsSubmit(), @totsClosed()]

module.exports = TotsFilter