class SFQueryBuilder
  @fieldDotConnection: (field) =>
    if _.isEmpty(field) then '' else "#{field}."

  @where: (alreadyHasWhere) =>
    if alreadyHasWhere then '' else 'WHERE'

module.exports = SFQueryBuilder