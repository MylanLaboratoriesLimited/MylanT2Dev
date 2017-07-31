SettingsManager = require 'db/settings-manager'
Utils = require 'common/utils'

class Locale
  @language:
    english: 'en'
    french: 'fr'
  @defaultLang: Locale.language.english
  @defaultOpts: {
    ns: {
      namespaces: ['app', 'common'],
      defaultNs: 'app'
    },
    lng: Locale.defaultLang
  }
  @langSettings: 'language'

  @initialize: ->
    SettingsManager.getValueByKey(Locale.langSettings)
    .done (lang) ->
      if lang then Locale.setCurrentLanguage lang
      else
        unless navigator.globalization then Locale.setDefaultAsCurrentLanguage()
        else
          deferred = $.Deferred()
          navigator.globalization.getPreferredLanguage (language) ->
            Locale.setCurrentLanguage(language.value.substring(0, 2).toLowerCase()).then -> deferred.resolve()
          , ->
            Locale.setDefaultAsCurrentLanguage().then -> deferred.resolve()
          deferred.promise()
    .fail -> 
      Locale.setDefaultAsCurrentLanguage()

  @value: (key, parameters = {}) ->
    i18n.t(key, parameters)

  @localize: (el) ->
    el.i18n()

  @currentLanguage: ->
    SettingsManager.getValueByKey(Locale.langSettings)
    .then (lang) -> if lang then lang else i18n.lng()

  @setCurrentLanguage: (lang) ->
    deferred = $.Deferred()
    lang = Locale.existingLocalizationForLanguage lang
    moment.locale lang
    i18n.init _.extend(Locale.defaultOpts, { lng: lang }), -> 
      SettingsManager.setValueByKey(Locale.langSettings, lang)
      .then -> Locale._setNativeAppLanguage(lang).then deferred.resolve
    deferred.promise()

  @_setNativeAppLanguage: (lang) ->
    deferred = $.Deferred()
    if Utils.isIOS()
      cordova.exec (-> deferred.resolve()), (-> deferred.resolve()), 'Locale', 'setLanguage', [lang]
    else
      deferred.resolve()
    deferred.promise()

  @existingLocalizationForLanguage: (lang) ->
    if _(Locale.language).chain().values().contains(lang).value() then lang else Locale.defaultLang

  @setDefaultAsCurrentLanguage: ->
    Locale.setCurrentLanguage Locale.defaultLang

module.exports = Locale