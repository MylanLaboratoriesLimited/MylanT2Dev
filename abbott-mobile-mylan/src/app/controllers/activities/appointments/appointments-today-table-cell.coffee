AppointmentsTableCell = require 'controllers/activities/appointments/appointments-table-cell'
PromotionPopup = require 'controls/popups/promotion-popup/promotion-popup'
PromotionAccountsCollection = require 'models/bll/promotion-accounts-collection'

class AppointmentsTableCellToday extends AppointmentsTableCell
  template: ->
    require('views/activities/appointments/appointments-today-table-cell')()

  bindEvents: =>
    super
    @_initInfoButton()

  _initInfoButton: ->
    promotionAccountsCollection = new PromotionAccountsCollection pageSize: 1
    promotionAccountsCollection.getActualPromotionsForAccount @appointment.organizationSfId, moment()
    .then (promotionAccounts) =>
      if promotionAccounts.length
        @elInfoButton.removeClass('hidden')
        .bind 'tap', @_showPromotionPopup

  _showPromotionPopup: (event) =>
    event.stopPropagation()
    promotionPopup = new PromotionPopup @appointment
    promotionPopup.show()

  _showNoPromotionsToast: ->
    $.fn.dpToast Locale.value("card.CallReport.ToastMessage.NoPromosForOrganization")

module.exports = AppointmentsTableCellToday