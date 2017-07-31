Spine = require 'spine'
PhotoItem = require 'controllers/trade-module/photos/photo-item'
PhotoPreview = require 'controllers/trade-module/photos/photo-preview'
FileProcessor = require 'common/file-processor/file-processor'
PanelScreen = require 'controllers/base/panel/panel-screen'
ConfirmationPopup = require 'controls/popups/confirmation-popup'
PhotoAdjustmentsCollection = require 'models/bll/photo-adjustments-collection'
AlertPopup = require 'controls/popups/alert-popup'

class PhotosGridView extends Spine.Controller
  className: 'photos-grid-view stack-page scroll-container'
  navigator: navigator

  elements:
    '.take-photo': 'elTakePhoto'
    '.photos-list': 'elPhotosList'

  events:
    'tap .take-photo': '_takePhoto'

  PHOTO_LIMIT: 14

  cameraOptions:
    correctOrientation: true
    quality : 40

  constructor: (@promoAdjustmentEntity) ->
    super {}
    @photoAdjustmentsCollection = new PhotoAdjustmentsCollection

  active: ->
    super
    @render()

  render: ->
    @html @template()
    @_prefetchExistingPhotosIfNeeded()
    .then @_showSavedPhotos
    @_checkPhotoNumber()
    @

  template: ->
    require('views/trade-module/photos-grid-view')()

  _prefetchExistingPhotosIfNeeded: =>
    if @promoAdjustmentEntity.isReadOnly
      @_fetchPhotos()
    else
      $.when()

  _fetchPhotos: =>
    @photoAdjustmentsCollection.getEntitiesForCallReportAndPromotion @promoAdjustmentEntity.callReport, @promoAdjustmentEntity.promoId
    .then (photoAdjustmentEntities) => photoAdjustmentEntities.forEach @promoAdjustmentEntity.addPhoto

  _showSavedPhotos: =>
    @photoAdjustmentsCollection.getLocalImagesByAdjustments(@promoAdjustmentEntity.photos)
    .then (promotionAttachmentsImages) =>
      @promoAdjustmentEntity.photos.forEach (photoAdjustmentEntity) =>
        @_createPhotoItem photoAdjustmentEntity, promotionAttachmentsImages[photoAdjustmentEntity.id]

  _createPhotoItem: (photoAdjustmentEntity, image) =>
    photo = new PhotoItem image, photoAdjustmentEntity
    photo.on 'itemTap', @_preview
    photo.on 'errorOffline', @_showOfflineErrorAlert
    photo.on 'errorUnauthorized', @_showUnauthorizedErrorAlert
    photo.on 'errorAttachment', @_showNoAttachmentErrorAlert
    unless @promoAdjustmentEntity.isReadOnly
      photo.on 'removeTap', @_onRemovePhotoTap
      photo.on 'itemHold', @_activateDeleteMode
    photo.render().el.insertAfter @elTakePhoto

  _showOfflineErrorAlert: =>
    @_showErrorAlert(Locale.value('PhotoAttachmentsPopup.Offline.caption'), Locale.value('PhotoAttachmentsPopup.Offline.message'))

  _showUnauthorizedErrorAlert: =>
    @_showErrorAlert(Locale.value('PhotoAttachmentsPopup.Unauthorized.caption'), Locale.value('PhotoAttachmentsPopup.Unauthorized.message'))

  _showNoAttachmentErrorAlert: =>
    @_showErrorAlert(Locale.value('PhotoAttachmentsPopup.NoAttachment.caption'), Locale.value('PhotoAttachmentsPopup.NoAttachment.message'))

  _showErrorAlert: (caption, message) ->
    alertPopup = new AlertPopup { caption: caption, message: message }
    alertPopup.bind 'yesClicked', => @trigger 'dismissModalController'
    @trigger 'presentModalController', alertPopup

  _preview: (item) =>
    if @elPhotosList.hasClass 'delete-mode' then @_deActivateDeleteMode()
    else
      photoPreview = new PhotoPreview item.image.path
      photoPreview.on 'onPhotoPreviewTap', @_onPhotoPreviewTap
      @trigger 'presentModalController', photoPreview

  _deActivateDeleteMode: =>
    @elPhotosList.removeClass 'delete-mode'

  _onPhotoPreviewTap: =>
    @trigger 'dismissModalController'

  _onRemovePhotoTap: (item) =>
    confirm = new ConfirmationPopup { caption: Locale.value('card.ConfirmationPopup.DeleteItem.Question') }
    confirm.bind 'yesClicked', =>
      @_removePhotoItem item
      @trigger 'dismissModalController'
    confirm.bind 'noClicked', =>
      @trigger 'dismissModalController'
    @trigger 'presentModalController', confirm

  _removePhotoItem: (item) =>
    @photoAdjustmentsCollection.removePhoto(item.photoAdjustmentEntity, item.image)
    .then =>
      @promoAdjustmentEntity.removePhoto item.photoAdjustmentEntity
      item.release()
      @_checkPhotoNumber()

  _checkPhotoNumber: =>
    if @promoAdjustmentEntity.photos.length >= @PHOTO_LIMIT
      @elTakePhoto.addClass 'disabled'
    else
      @elTakePhoto.removeClass 'disabled'

  _activateDeleteMode: =>
    @el.one 'tap', @_deActivateDeleteMode
    @elPhotosList.addClass 'delete-mode'

  _takePhoto: =>
    @navigator.camera.getPicture @_addPhoto, @_onError, @cameraOptions

  _onError: (error) =>
    console.log "Something went wrong: #{error}"

  _addPhoto: (imageUrl) =>
    @photoAdjustmentsCollection.addPhoto(@_createPhotoAdjustment(), imageUrl)
    .then ([photoAdjustmentEntity, image]) =>
      @promoAdjustmentEntity.addPhoto photoAdjustmentEntity
      @_dataChanged()
      @_createPhotoItem photoAdjustmentEntity, image
      @_checkPhotoNumber()

  _createPhotoAdjustment: =>
    photoAdjustment = {}
    photoAdjustment[@photoAdjustmentsCollection.model.sfdc.callReportSfId] = @promoAdjustmentEntity.callReport.attributes._soupEntryId
    photoAdjustment[@photoAdjustmentsCollection.model.sfdc.promotionSfId]  = @promoAdjustmentEntity.promoId
    photoAdjustment.isModifiedInTrade = true
    photoAdjustment.isModifiedInCall = true
    photoAdjustment

  _dataChanged: =>
    @trigger 'dataChanged'

module.exports = PhotosGridView