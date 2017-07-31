Utils = require 'common/utils'

class PhotoAttachmentFileManager
  @_attachmentsRoot: 'trade'
  @_photoFolder: 'photos'
  @_temporaryRoot: 'temporary'

  @_processRootPath: (url)=>
    url = url.replace 'file://localhost', ''
    url = url.replace 'file://', '' unless Utils.isIOS()
    url

  @_pathToTemporary: =>
    "#{@_rootPath}/#{@_temporaryRoot}"

  @_pathToAttachmentsRoot: =>
    "#{@_rootPath}/#{@_attachmentsRoot}"

  @_pathToAttachments: =>
    "#{@_rootPath}/#{@_attachmentsRoot}/#{@_photoFolder}"

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
    sourcePath = PhotoAttachmentFileManager._processRootPath sourcePath
    deferred = new $.Deferred
    @_rootEntry.getDirectory @_pathToAttachmentsRoot(), {create: true, exclusive: false}, (attachmentsRootDirEntry)=>
      @_rootEntry.getDirectory @_pathToAttachments(), {create: true, exclusive: false}, (attachmentsDirEntry)=>
        @_rootEntry.getFile sourcePath, {create: false, exclusive: false}, (fileEntry)=>
          fileEntry.moveTo attachmentsDirEntry, fileEntry.name, deferred.resolve, deferred.reject
        , deferred.reject
      , deferred.reject
    , deferred.reject
    deferred.promise()

  @fileExist: (filePath)=>
    filePath = PhotoAttachmentFileManager._processRootPath filePath
    deferred = new $.Deferred
    @_rootEntry.getFile filePath, {create: false, exclusive: false}, deferred.resolve, deferred.reject
    deferred.promise()

  @removeFile: (path)=>
    path = PhotoAttachmentFileManager._processRootPath path
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
    @removeFolder @_pathToAttachmentsRoot(), deferred.resolve, deferred.reject
    deferred.promise()

  if window.requestFileSystem
    window.requestFileSystem LocalFileSystem.PERSISTENT, 0, (fileSystem)=>
      @_rootPath = PhotoAttachmentFileManager._processRootPath(fileSystem.root.toURL())
      @_rootEntry = fileSystem.root
    , (error)->
      console.log error
  else
    console.log 'File system unavailable'

module.exports = PhotoAttachmentFileManager