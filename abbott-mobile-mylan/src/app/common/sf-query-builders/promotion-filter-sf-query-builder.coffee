SFQueryBuilder = require 'common/sf-query-builders/sf-query-builder'
Utils = require 'common/utils'

class PromotionFilterSFQueryBuilder extends SFQueryBuilder
  @buildWhereFilter: (promotionField, clmConfig, alreadyHasWhere = false) =>
    " #{@where(alreadyHasWhere)} (#{@fieldDotConnection(promotionField)}RecordType.Id = '#{clmConfig.contractRecordTypeId}'" +
    " OR #{@fieldDotConnection(promotionField)}RecordType.Id = '#{clmConfig.campaignRecordTypeId}')" +
    " AND #{@fieldDotConnection(promotionField)}PromotionEndDate__c >= #{Utils.currentDate()}"

module.exports = PromotionFilterSFQueryBuilder