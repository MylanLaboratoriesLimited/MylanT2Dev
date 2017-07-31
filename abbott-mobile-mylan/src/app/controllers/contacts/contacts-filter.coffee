class ContactsFilter
  @targetContacts: ->
    {id: 0, description: Locale.value('contacts.FilterPopup.TargetContacts')}

  @nonTargetContacts: ->
    {id: 1, description: Locale.value('contacts.FilterPopup.NonTargetContacts')}

  @resources: ->
    [@targetContacts(), @nonTargetContacts()]

module.exports = ContactsFilter
