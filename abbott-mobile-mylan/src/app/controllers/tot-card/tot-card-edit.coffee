TotCardCreate = require 'controllers/tot-card/tot-card-create'
ConfirmationPopup = require 'controls/popups/confirmation-popup'
TotsCollection = require '/models/bll/tots-collection/tots-collection'
Utils = require 'common/utils'
Tot = require 'models/tot'
HeaderBaseControl = require 'controls/header-controls/header-base-control'
Header = require 'controls/header/header'

class TotCardEdit extends TotCardCreate
  className: 'tot card edit-mode'

  _initHeader: ->
    saveBtn = new HeaderBaseControl Locale.value('common:buttons.SaveBtn'), 'ctrl-btn'
    saveBtn.bind 'tap', @_saveTot
    deleteBtn = new HeaderBaseControl Locale.value('common:buttons.DeleteBtn'), 'ctrl-btn red'
    deleteBtn.bind 'tap', @_onDeleteTap
    totHeader = new Header Locale.value('card.Tot.HeaderTitle')
    totHeader.render()
    totHeader.addRightControlElement deleteBtn.el
    totHeader.addRightControlElement saveBtn.el
    @setHeader totHeader

  _fillGeneralInfo: ->
    super
    @_refreshQuarters()

  _onDeleteTap: =>
    confirm = new ConfirmationPopup { caption: Locale.value('card.Tot.ConfirmationPopup.DeleteItem.Caption'), message: Locale.value('card.ConfirmationPopup.DeleteItem.Question') }
    confirm.bind 'yesClicked', @_onDeleteApprove
    confirm.bind 'noClicked', @_onDeleteDiscard
    @presentModalController confirm

  _onDeleteApprove: (confirm) =>
    @dismissModalController()
    @collection.removeEntity(@tot)
    .then =>
      @trigger 'totChanged'
      @isChanged = false
      @onBack()

  _onDeleteDiscard: (confirm) =>
    @dismissModalController()

  _save: =>
    @tot.allDay = @allDay
    @tot.createdOffline = true
    @tot.startDate = Utils.currentDate @startDate
    @tot.endDate = Utils.currentDate @endDate
    @tot.firstQuarterEvent = @firstQuarterPickList.selectedValue
    @tot.secondQuarterEvent = @secondQuarterPickList?.selectedValue or null
    @tot.thirdQuarterEvent = @thirdQuarterPickList.selectedValue
    @tot.fourthQuarterEvent = @fourthQuarterPickList?.selectedValue or null
    @tot.description = @description
    @collection.updateEntity(@tot)

module.exports = TotCardEdit