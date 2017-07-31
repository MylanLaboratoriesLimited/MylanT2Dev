Locale = require 'common/localization/locale'

class LanguagesFilter
  @resources: ->
     _(Locale.language)
     .chain()
     .values()
     .map((lang, index) -> {id: index, value: lang, description: Locale.value("common:languages.#{lang}")})
     .value()

module.exports = LanguagesFilter