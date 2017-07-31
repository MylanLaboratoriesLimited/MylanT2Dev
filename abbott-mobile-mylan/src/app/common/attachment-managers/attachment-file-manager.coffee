Utils = require 'common/utils'

class AttachmentFileManager
  @_attachmentsRoot: 'attachments'
  @_temporaryRoot: 'temporary'

  @_processRootPath: (url)=>
    url = url.replace 'file://localhost', ''
    url = url.replace 'file://', '' unless Utils.isIOS()
    url

  @_pathToTemporary: =>
    "#{@_rootPath}/#{@_temporaryRoot}"

  @_pathToAttachments: =>
    "#{@_rootPath}/#{@_attachmentsRoot}"

  @extractFileName: (filePath) =>
    regExp = /Attachment\/(.*)\/Body/gim
    regExpData = regExp.exec filePath
    if regExpData
      regExpData[1]
    else
      filePath.replace(/\W/gim, "")

  @extractFileExtension: (fileName) =>
    regExp = /\.([\w\d]+$)/gim
    regExpData = regExp.exec fileName
    if regExpData
      regExpData[1]
    else
      fileName.replace(/\W/gim, "")

  @getFilePath: (url, name, isPersistent=true)=>
    fileName = @extractFileName url
    fileExt = @extractFileExtension name
    rootDir = if isPersistent then @_pathToAttachments() else @_pathToTemporary()
    filePath = "#{rootDir}/#{fileName}.#{fileExt}"
    filePath

  @moveToPersistent: (sourcePath)=>
    sourcePath = AttachmentFileManager._processRootPath sourcePath
    deferred = new $.Deferred
    @_rootEntry.getDirectory @_pathToAttachments(), {create: true, exclusive: false}, (attachmentsDirEntry)=>
      @_rootEntry.getFile sourcePath, {create: false, exclusive: false}, (fileEntry)=>
        fileEntry.moveTo attachmentsDirEntry, fileEntry.name, deferred.resolve, deferred.reject
      , deferred.reject
    , deferred.reject
    deferred.promise()

  @fileExist: (filePath)=>
    filePath = AttachmentFileManager._processRootPath filePath
    deferred = new $.Deferred
    @_rootEntry.getFile filePath, {create: false, exclusive: false}, deferred.resolve, deferred.reject
    deferred.promise()

  @removeFile: (path)=>
    path = AttachmentFileManager._processRootPath path
    deferred = new $.Deferred
    @_rootEntry.getFile path, {create: false, exclusive: false}, (fileEntry) =>
      fileEntry.remove deferred.resolve, deferred.reject
    , deferred.reject
    deferred.promise()

  @removeFolder: (path, onSuccess, onError)=>
    dirEntry = new DirectoryEntry path, path
    dirEntry.removeRecursively onSuccess, (fileError)=>
      if fileError.code is 12 or fileError.code is 1 then onSuccess?() else onError?()

  @wipeStorage: =>
    deferred = new $.Deferred
    @removeFolder @_pathToAttachments(), deferred.resolve, deferred.reject
    deferred.promise()

  if window.requestFileSystem
    window.requestFileSystem LocalFileSystem.PERSISTENT, 0, (fileSystem)=>
      @_rootPath = AttachmentFileManager._processRootPath(fileSystem.root.toURL())
      @_rootEntry = fileSystem.root
    , (error)->
      console.log error
  else
    console.log 'File system unavailable'

module.exports = AttachmentFileManager