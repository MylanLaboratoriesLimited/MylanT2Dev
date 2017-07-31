Spine = require 'spine'

class AttachmentsManager
  @_cordovaRef = window.PhoneGap || window.Cordova || window.cordova;

  @_exec: (action, params)=>
    deferred = new $.Deferred()
    @_cordovaRef.exec(((result)=>deferred.resolve(result)), ((error)=>deferred.reject(error)), 'AttachmentsViewer', action, [params]);
    deferred.promise()

  @open: (path, mimeType)=>
    console.log path, mimeType
    @_exec 'open', {filePath: path, mimeType: mimeType || ''}

module.exports = AttachmentsManager