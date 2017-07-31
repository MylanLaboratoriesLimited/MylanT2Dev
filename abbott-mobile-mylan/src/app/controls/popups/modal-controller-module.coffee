Spine = require 'spine'

ModalControllerModule =
  didShow: (context) =>
    context.trigger 'didShow', context

  willHide: (context) =>
    context.trigger 'willHide', context

  didHide: (context) =>
    context.trigger 'didHide', context

module.exports = ModalControllerModule