Utils = require('common/utils')

class Query
  @_isIOS: Utils.isIOS()
  @TRUE: if @_isIOS then "1" else "'true'"
  @FALSE: if @_isIOS then "0" else "'false'"
  @ALL: '_soup'
  @AND: 'AND'
  @OR: 'OR'
  @IN: 'IN'
  @NOT_IN: 'NOT IN'
  @EQ: '='
  @NE: '!='
  @GR: '>'
  @LR: '<'
  @GRE: '>='
  @LRE: '<='
  @ASC: 'ASC'
  @DESC: 'DESC'

  constructor: (@soup) ->
    @query = ''
    @isWhereUsed = false
    @isConditionUsed = false

  customQuery: (queryString) ->
    @query += queryString
    @isWhereUsed = true if @query.indexOf(" WHERE ") > 0
    @

  selectFrom: (@soup, fields = Query.ALL) ->
    if fields is Query.ALL
      @query += "SELECT {#{@soup}:#{fields}} FROM {#{@soup}}"
      @
    else
      selectConditions = fields.map (field) => "{#{@soup}:#{field}}"
      @query += "SELECT " + selectConditions.join(',') " FROM {#{@soup}}"
      @

  where: (fieldsValues, eqCondition = Query.EQ, joinWith = Query.AND) ->
    whereConditions = ("{#{@soup}:#{field}} #{eqCondition} #{@valueOf(value)}" for field, value of fieldsValues)
    @query += @_whereCondition() + whereConditions.join(" #{joinWith} ")
    @isConditionUsed = false
    @

  whereLike: (fieldsValues, joinWith = Query.OR) ->
    likeConditions = ("{#{@soup}:#{field}} LIKE '%#{@_ecranisedValue(value)}%'" for field, value of fieldsValues)
    @query += @_whereCondition() + '(' + likeConditions.join(" #{joinWith} ") + ')'
    @isConditionUsed = false
    @

  whereIn: (field, values) ->
    values = values.map (value) => @valueOf(value)
    @query += @_whereCondition() + " {#{@soup}:#{field}} #{Query.IN} (#{values.join(', ')})"
    @

  whereNotIn: (field, values) ->
    values = values.map (value) => @valueOf(value)
    @query += @_whereCondition() + " {#{@soup}:#{field}} #{Query.NOT_IN} (#{values.join(', ')})"
    @

  orderBy: (fields, order = Query.ASC) ->
    isIOS = Utils.isIOS()
    orderConditions = fields.map (field) =>
      if Utils.isIOS() then "{#{@soup}:#{field}} COLLATE NOCASE #{order}" else "{#{@soup}:#{field}} = 'null' #{order}, {#{@soup}:#{field}} COLLATE NOCASE #{order}"
    @query += ' ORDER BY ' + orderConditions.join(',')
    @

  limit: (count) ->
    @query += " LIMIT #{count}"
    @

  and: ->
    @query += @_andQuery()
    @

  _andQuery: ->
    @isConditionUsed = true
    " #{Query.AND} "

  or: ->
    @query += " #{Query.OR} "
    @isConditionUsed = true
    @

  valueOf: (value) ->
    switch value
      when true then Query.TRUE
      when false then Query.FALSE
      else "'#{@_ecranisedValue(value)}'"

  _ecranisedValue: (value) ->
    if typeof value is 'string'
      value.replace '\'', '\'\''
    else
      value

  _whereCondition: ->
    if @isWhereUsed
      if @isConditionUsed
        ' '
      else
        @_andQuery()
    else 
      @isWhereUsed = true
      ' WHERE '

  toString: ->
    @query

module.exports = Query