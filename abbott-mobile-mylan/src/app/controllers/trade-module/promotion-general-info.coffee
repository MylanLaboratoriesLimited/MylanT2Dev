Spine = require 'spine'
Utils = require 'common/utils'

class PromotionGeneralInfo extends Spine.Controller
  className: 'general-info'

  elements:
    '.trade-module-promotion-start-date': 'elPromotionStartDate'
    '.trade-module-promotion-end-date': 'elPromotionEndDate'
    '.trade-module-contract': 'elContractNumber'
    '.trade-module-number-of-pharmacies': 'elNumberOfPharmacies'
    '.trade-module-mobile-record-type': 'elRecordType'
    '.trade-module-status': 'elStatus'
    '.trade-module-objectives': 'elObjectives'
    '.trade-module-description': 'elDescription'

  constructor: (@promotionAccount) ->
    super {}

  active: ->
    super
    @render()

  render: ->
    @html @template()
    @elPromotionStartDate.text Utils.slashFormatDate(new Date @promotionAccount.startDate)
    @elPromotionEndDate.text Utils.slashFormatDate(new Date @promotionAccount.endDate)
    @elContractNumber.text @promotionAccount.contractNumber
    @elNumberOfPharmacies.text @promotionAccount.numberOfPharmacies
    @elRecordType.text @promotionAccount.recordType
    @elObjectives.text @promotionAccount.objectives
    @elDescription.text @promotionAccount.description
    @promotionAccount.getPromotionStatus().then (status) => @elStatus.text status
    Locale.localize @el
    @

  template: ->
    require 'views/trade-module/promotion-general-info'

module.exports = PromotionGeneralInfo