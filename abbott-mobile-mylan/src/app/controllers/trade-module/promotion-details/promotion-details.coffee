Spine = require 'spine'
SegmentControl = require 'controls/segment-control/segment-control'
SegmentItem = require 'controls/segment-control/segment-item'
Tactics = require 'controllers/trade-module/promotion-details/tactics/tactics'
PromotionTasks = require 'controllers/trade-module/promotion-details/promotion-tasks/promotion-tasks'
Skus = require 'controllers/trade-module/promotion-details/skus/skus'
NotesAttachments = require 'controllers/trade-module/promotion-details/notes-attachments/notes-attachments'
PhotosGridView = require 'controllers/trade-module/photos/photos-grid-view'

class PromotionDetails extends Spine.Controller
  className: 'promotion-details'

  events:
    'tap .full-screen-btn': '_onFullScreenTap'

  elements:
    '.top-panel': 'elTopPanel'
    '.segmentation': 'elSegmentation'
    '.content': 'elContent'

  constructor: (promotionAccount, promoAdjustmentEntity) ->
    super {}
    @tactics = new Tactics promotionAccount, promoAdjustmentEntity
    @promoTasks = new PromotionTasks promotionAccount, promoAdjustmentEntity
    @skus = new Skus promotionAccount, promoAdjustmentEntity
    @notesAttachments = new NotesAttachments promotionAccount, promoAdjustmentEntity
    @photos = new PhotosGridView promoAdjustmentEntity
    @_bindEvents()

  active: ->
    super
    @render()

  render: ->
    @html @template()
    @_initSegmentation()
    @

  _bindEvents: =>
    [@tactics, @promoTasks, @skus, @notesAttachments, @photos].forEach (page) =>
      page.on 'presentModalController', @_onPresentModalController
      page.on 'dismissModalController', @_onDismissModalController
      page.on 'dataChanged', @_dataChanged

  _dataChanged: =>
    @trigger 'dataChanged'

  _onPresentModalController: (mediaController) =>
    @trigger 'presentModalController', mediaController

  _onDismissModalController: =>
    @trigger 'dismissModalController'

  refresh: =>
    #hack TODO need find a correct solution
    @el.addClass "hide"
    timeout = setTimeout =>
        @el.removeClass "hide"
        clearTimeout timeout
      , 0

  _initSegmentation: ->
    @_initSegmentItems()
    segmentControl = new SegmentControl [
      new SegmentItem name: 'tactics', title: Locale.value('tradeModule.PromoDetails.Tactics'), controller: @tactics
      new SegmentItem name: 'promotionTasks', title: Locale.value('tradeModule.PromoDetails.PromotionTasks'), controller: @promoTasks
      new SegmentItem name: 'skus', title: Locale.value('tradeModule.PromoDetails.SKUs'), controller: @skus
      new SegmentItem name: 'notes', title: Locale.value('tradeModule.PromoDetails.Notes'), controller: @notesAttachments
      new SegmentItem name: 'photos', title: Locale.value('tradeModule.PromoDetails.Photos'), controller: @photos
    ]
    @elSegmentation.append segmentControl.el

  _onFullScreenTap: =>
    @trigger 'fullScreenTap', @

  _initSegmentItems: ->
    @elContent.append @tactics.el
    @elContent.append @promoTasks.el
    @elContent.append @skus.el
    @elContent.append @notesAttachments.el
    @elContent.append @photos.el

  template: ->
    require 'views/trade-module/promotion-details/promotion-details'

module.exports = PromotionDetails