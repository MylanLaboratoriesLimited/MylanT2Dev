EntitiesCollection = require 'models/bll/entities-collection'
MarketingMessage = require 'models/marketing-message'
SforceDataContext = require 'models/bll/sforce-data-context'
Utils = require 'common/utils'

class MarketingMessagesCollection extends EntitiesCollection
  model: MarketingMessage

  prepareServerConfig: (configPromise) =>
    config = null
    configPromise
    .then (config) =>
      SforceDataContext.activeUser()
      .then (currentUser) =>
        config.query += " where #{@model.sfdc.status} = true and #{@model.sfdc.currencyIsoCode} = '#{currentUser.currency}'"
        config

module.exports = MarketingMessagesCollection