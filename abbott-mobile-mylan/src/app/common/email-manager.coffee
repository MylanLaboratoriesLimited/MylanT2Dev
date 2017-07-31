Spine = require 'spine'

class EmailManager
  @_defaultEmail = 'abbottmobilelog@gmail.com'
  @_defaultResultCallback = (result)->
    console.log "Email sended with result: #{result}"

  @sendMail: (subject, content, recipient = @_defaultEmail)=>
    window.plugins.emailComposer.showEmailComposer subject, content, [recipient], [], [], true, []

  @sendMailAsync: (subject, content, recipient = @_defaultEmail, resultCallback = @_defaultResultCallback)=>
    window.plugins.emailComposer.showEmailComposerWithCallback resultCallback, subject, content, [recipient], [], [], true, []

module.exports = EmailManager