EntitiesCollection = require 'models/bll/entities-collection'
MarketingCycle = require 'models/marketing-cycle'
Utils = require 'common/utils'
Query = require 'common/query'

class MarketingCyclesCollection extends EntitiesCollection
  model: MarketingCycle

  prepareServerConfig: (configPromise) =>
    configPromise
    .then (config) =>
      SforceDataContext = require 'models/bll/sforce-data-context'
      SforceDataContext.activeUser()
      .then (currentUser) =>
        today = Utils.currentDate()
        config.query += " where #{@model.sfdc.startDate} <= #{today} and #{@model.sfdc.endDate} >= #{today} and #{@model.sfdc.currencyIsoCode} = '#{currentUser.currency}'"
        config

  fetchByDateAndCurrency: (date, currency) ->
    startDateValue = {}
    endDateValue = {}
    currencyValue = {}
    startDateValue[@model.sfdc.startDate] = date
    endDateValue[@model.sfdc.endDate] = date
    currencyValue[@model.sfdc.currencyIsoCode] = currency
    query = new Query().selectFrom(@model.table).where(startDateValue, Query.LRE).and().where(endDateValue, Query.GRE).and().where(currencyValue).limit(1)
    @fetchWithQuery(query).then @getEntityFromResponse

module.exports = MarketingCyclesCollection