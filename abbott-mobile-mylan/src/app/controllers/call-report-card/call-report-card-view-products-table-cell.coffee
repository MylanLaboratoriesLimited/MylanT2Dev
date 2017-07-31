Spine = require 'spine'
Locale = require 'common/localization/locale'

class CallReportCardViewProductsTableCell extends Spine.Controller
  tag: 'tbody'

  events:
    'tap .call-report-card-expand-btn': '_onExpandTap'

  elements:
    '.call-report-card-product-list-btn': 'elProductListBtn'
    '.call-report-card-product-comment': 'elProductComment'
    '.call-report-card-message-list-btn.message-1': 'elProductMessage1'
    '.call-report-card-message-list-btn.message-2': 'elProductMessage2'
    '.call-report-card-message-list-btn.message-3': 'elProductMessage3'
    '.td-content-wrapper': 'elExpandBlock'
    '.product-expand-wrapper': 'elExpandWrapper'
    '.promotion-item': 'elPromotional'

  constructor: (@productName, @productComment, @message1Name, @message2Name, @message3Name, @isPromotional) ->
    super {}

  _onExpandTap: =>
    @el.toggleClass 'expanded'
    height = 0
    height = @elExpandWrapper.height() if @el.hasClass 'expanded'
    @elExpandBlock.css 'height', height + 'px'

  _template: ->
    require('views/call-report-card/call-report-card-products-table-cell')()

  refreshComment: =>
    @elProductComment.elastic()

  render: ->
    @html @_template()
    @elProductListBtn.html @productName
    @elProductComment.val @productComment
    @elProductMessage1.html @message1Name if @message1Name
    @elProductMessage2.html @message2Name if @message2Name
    @elProductMessage3.html @message3Name if @message3Name
    @elPromotional[0].checked = @isPromotional
    Locale.localize @el
    @

module.exports = CallReportCardViewProductsTableCell