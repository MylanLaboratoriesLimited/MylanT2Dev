Function::getter = (prop, get) ->
  Object.defineProperty @prototype, prop, {get, configurable: yes}

Function::setter = (prop, set) ->
  Object.defineProperty @prototype, prop, {set, configurable: yes}

class Entity extends Force.SObject
  @table: ''
  @sfdcTable: ''
  @description: 'Entity'

  @sfdc: null             # Model.sfdc.reference will return e.g. 'Reference__c'
  @isToLabel: null        # Model.isToLabel.Reference__c or Model.isToLabel['Reference__c'] will return true or false
  @indexSpec: null        # Model.indexSpec will return e.g. [{path:'Name',type:'string'}]
  @searchFields: null     # Model.searchFields will return e.g. ['Name', 'Address']
  @sfdcFields: null       # Model.sfdcFields will return e.g. ['Name', 'Address', 'Reference__c']
  @uploadableFields: null # Model.uploadableFields will return e.g. ['Name', 'Address', 'Reference__c']
  @excludableFields: null # Model.excludableFields will return e.g. {'GlobalPriority__c': 'isTradeModuleEnabled'}
  @includableFields: null # Model.includableFields will return e.g. {'Patient_Profile_1__c': 'isPortfolioSellingModuleEnabled'}

  fieldlist: (method) =>
    @constructor.sfdcFields

  @mapModel: ->
    @_mapField field for field in @schema()
    @_generateSfdcFields @schema()
    @_generateSfdcPropertiesByLocal @schema()
    @_generateIndexSpec @schema()
    @_generateSearchFields @schema()
    @_generateIsToLabel @schema()
    @_generateUploadableFields @schema()
    @_generateExcludableFields @schema()
    @_generateIncludableFields @schema()

  @_mapField: (field) ->
    @_generateProperty field

  @_generateSfdcFields: (schema) ->
    @sfdcFields ?= schema
      .filter((field) -> field.hasOwnProperty 'sfdc')
      .map((field) -> field.sfdc)

  @_generateProperty: (field) ->
    @getter field.local, ->
      if field.hasOwnProperty 'sfdc'
        @attributes[field.sfdc] ? @[field.sfdc]
      else
        @attributes[field.local]
    @setter field.local, (val) ->
      if field.hasOwnProperty 'sfdc'
        @attributes[field.sfdc] = val
      else
        @attributes[field.local] = val

  @_generateSfdcPropertiesByLocal: (schema) ->
    unless @sfdc
      @sfdc = {}
      schema.forEach (field) => if field.hasOwnProperty 'sfdc' then @sfdc[field.local] = field.sfdc

  @_generateIndexSpec: (schema) ->
    @indexSpec ?= schema
      .filter((field) -> field.hasOwnProperty 'indexWithType')
      .map((field) => { 'path': @_valueOfField(field), 'type': field.indexWithType })

  @_generateSearchFields: (schema) ->
    @searchFields ?= schema
      .filter((field) -> field.hasOwnProperty('search') and field.search is true)
      .map((field) => @_valueOfField field)

  @_valueOfField: (field) ->
    if field.hasOwnProperty 'sfdc' then field.sfdc else field.local

  @_generateIsToLabel: (schema) ->
    unless @isToLabel?
      @isToLabel = {}
      schema.forEach (field) =>
        @isToLabel[field.sfdc] = field.hasOwnProperty('toLabel') and field.toLabel is true

  @_generateUploadableFields: (schema) ->
    @uploadableFields ?= schema
      .filter((field) -> field.hasOwnProperty('upload') and field.upload is true)
      .map((field) => @_valueOfField field)

  @_generateExcludableFields: (schema) ->
    @excludableFields ?= {}
    fields = schema.filter((field) -> field.hasOwnProperty('exclude') and field.exclude)
    fields?.forEach (field) => @excludableFields[@_valueOfField(field)] = field.exclude

  @_generateIncludableFields: (schema) ->
    @includableFields ?= {}
    fields = schema.filter((field) -> field.hasOwnProperty('include') and field.include)
    fields?.forEach (field) => @includableFields[@_valueOfField(field)] = field.include

module.exports = Entity