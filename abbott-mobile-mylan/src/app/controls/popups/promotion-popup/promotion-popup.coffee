BasePopup = require '/controls/popups/base-popup'
SegmentControl = require 'controls/segment-control/segment-control'
SegmentItem = require 'controls/segment-control/segment-item'
Iterator = require 'common/iterator'
PageControl = require 'controls/page-control/page-control'
PromotionAccountsCollection = require 'models/bll/promotion-accounts-collection'
Utils = require 'common/utils'
SkusPopupTable = require 'controls/popups/promotion-popup/skus-popup-table'
MechanicsPopupTable = require 'controls/popups/promotion-popup/mechanics-popup-table'
TasksPopupTable = require 'controls/popups/promotion-popup/tasks-popup-table'
NotesAttachmentsPopupTable = require 'controls/popups/promotion-popup/notes-attachments-popup-table'


class PromotionPopup extends BasePopup
  tagName: 'article'
  className: "#{@::className} promotion-popup"

  constructor: (@appointment) ->
    super {}
    @skusTable = null
    @mechanicsTable = null
    @tasksTable = null
    @notesAttachmentsTable = null

  _renderHead: =>
    elMainHeader = @el.find '.popup-main-content-holder header'
    @elCross = elMainHeader.find '.cross'
    @elUserName = elMainHeader.find '.user-name'

  template: ->
    require('views/controls/popups/promotion-popup/promotion-popup')()

  _renderContent: =>
    @_initUIElements()
    @_initSegmentation()
    @_fetchPromotionsForOrganizationWithId(@appointment.organizationSfId)
    .then (promotions) =>
      @_initPromotionIterator promotions
      @_initPageControl promotions
      @_refreshPopup()

  _initUIElements: ->
    @elContent.html @_contentTemplate()
    generalInfo = @elContent.find '.general-info'
    @elGeneralInfoTitle = generalInfo.find 'h5'
    @elStartDate = generalInfo.find '.start-date'
    @elContractNumber = generalInfo.find '.contact-number'
    @elEndDate = generalInfo.find '.end-date'
    @elObjectives = generalInfo.find '.objectives'
    @elDescription = generalInfo.find '.description'
    @elSegmentHolder = @elContent.find '.segments-holder'
    @elFooter = @elContent.find 'footer'
    @noteTitle = @el.find '.note-holder h6'
    @noteBody = @el.find '.note-holder .note-body'
    @closeNote = @el.find '.note-holder .back'

  _contentTemplate: ->
    require('views/controls/popups/promotion-popup/promotion-popup-content')()

  _initSegmentation: ->
    @_initSegmentItems()
    @segmentControl = new SegmentControl [
      new SegmentItem name: 'skus', title: Locale.value('PromotionPopup.SKUs'), controller: @skusTable
      new SegmentItem name: 'mechanics', title: Locale.value('PromotionPopup.Tactics'), controller: @mechanicsTable
      new SegmentItem name: 'tasks', title: Locale.value('PromotionPopup.Tasks'), controller: @tasksTable
      new SegmentItem name: 'attachments', title: Locale.value('PromotionPopup.Attachment'), controller: @notesAttachmentsTable
    ]
    @segmentControl.bind 'segmentItemTap', @_segmentItemTap
    @segmentControl.el.insertBefore @elSegmentHolder

  _initSegmentItems: ->
    tables = []
    tables.push @skusTable = new SkusPopupTable
    tables.push @mechanicsTable = new MechanicsPopupTable
    tables.push @tasksTable = new TasksPopupTable
    tables.push @notesAttachmentsTable = new NotesAttachmentsPopupTable
    tables.forEach (table) => @elSegmentHolder.append table.el

  _segmentItemTap: =>
    @elSegmentHolder.scrollTop 0

  _fetchPromotionsForOrganizationWithId: (orgId) ->
    new PromotionAccountsCollection().getActualPromotionsForAccount orgId, moment()

  _initPromotionIterator: (promotions) ->
    @promotionIterator = new Iterator promotions

  _initPageControl: (promotions) ->
    @pageControl = new PageControl promotions.length
    @pageControl.refreshByActivePageIndex 0
    @pageControl.on 'pageControlItemTap', (pageControlItem) => @_moveToPageAtIndex pageControlItem.index
    @elFooter.append @pageControl.el

  _refreshPopup: =>
    @elUserName.html @appointment.contactFullName()
    @_fillGenralInfo()
    promotionSfId = @promotionIterator.currentItem().promotionSfId
    $.when @tasksTable.refreshTableByPromoId @promotionIterator.currentItem().id
    , @mechanicsTable.refreshTableByPromoId promotionSfId
    , @skusTable.refreshTableByPromoId promotionSfId
    , @notesAttachmentsTable.refreshTableByPromoId promotionSfId

  _fillGenralInfo: ->
    currentPromo = @promotionIterator.currentItem()
    @elGeneralInfoTitle.text currentPromo.name ? ''
    @elContractNumber.text currentPromo.contractNumber ? ''
    @elStartDate.text Utils.dotFormatDate(new Date currentPromo.startDate) ? ''
    @elEndDate.text Utils.dotFormatDate(new Date currentPromo.endDate) ? ''
    @elObjectives.text currentPromo.objectives ? ''
    @elDescription.text currentPromo.description ? ''

  _moveToPageAtIndex: (index) ->
    return if @promotionIterator.currentIndex() is index
    @promotionIterator.setCurrentIndex index
    @pageControl.refreshByActivePageIndex index
    @_refreshPopup()

  _bindEvents: =>
    super
    @elCross.bind 'tap', @hide
    @closeNote.bind 'tap', @_hideNote
    @notesAttachmentsTable.bind 'showNote', @_onShowNote
    @_initSwipeRightGesture()
    @_initSwipeLeftGesture()

  _onShowNote: (noteCell) =>
    @noteTitle.text noteCell.note?.title or ''
    @noteBody[0].innerText = noteCell.note?.body or ''
    @_showNote()

  _preventDefault: (event) =>
    event.preventDefault() if @elScrollContent.height() is @elScrollContainer.height()

  _initSwipeRightGesture: ->
    @elContent.bind 'swiperight', =>
      return unless @promotionIterator.hasNext()
      @promotionIterator.next()
      @pageControl.refreshByActivePageIndex @promotionIterator.currentIndex()
      @_refreshPopup()

  _initSwipeLeftGesture: ->
    @elContent.bind 'swipeleft', =>
      return unless @promotionIterator.hasPrev()
      @promotionIterator.prev()
      @pageControl.refreshByActivePageIndex @promotionIterator.currentIndex()
      @_refreshPopup()

  _showNote: =>
    @el.addClass 'show-note'

  _hideNote: =>
    @el.removeClass 'show-note'


module.exports = PromotionPopup