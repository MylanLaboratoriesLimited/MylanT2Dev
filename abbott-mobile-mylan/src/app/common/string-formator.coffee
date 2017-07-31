class StringFormator

  @stringToHtml: (string) ->
    string?.replace /\n/gm, '<br />' ? ''

module.exports = StringFormator