class PresentationsFileManager
  @_rootPath: null
  @_presentationsRoot: 'presentations'
  @_temporaryRoot: 'temporary'

  @getPathToTemporaryDir: =>
    "#{@_rootPath}/#{@_temporaryRoot}"

  @getPathToPresentationsDir: =>
    "#{@_rootPath}/#{@_presentationsRoot}"

  @getPathToTemporaryPresentation: (presentationId)=>
    "#{@getPathToTemporaryDir()}/#{presentationId}"

  @getPathToPresentation: (presentationId)=>
    "#{@getPathToPresentationsDir()}/#{presentationId}"

  @presentationExist: (presentationId)=>
    presentationPath = "#{@_presentationsRoot}/#{presentationId}"
    promise = new $.Deferred
    @_rootEntry.getDirectory presentationPath, {create: false, exclusive: false}, promise.resolve, promise.reject
    promise.promise()

  @pathExist: (iconPath)=>
    iconPath = "#{@_presentationsRoot}/#{iconPath}"
    promise = new $.Deferred
    @_rootEntry.getFile iconPath, {create: false, exclusive: false}, promise.resolve, promise.reject
    promise.promise()

  @readPresentationFile: (pathToFile)=>
    filePath = "#{@_presentationsRoot}/#{pathToFile}"
    promise = new $.Deferred
    onReadError = (error)=>
      promise.reject error
    onReadSuccess = (file)=>
      fileReader = new FileReader
      fileReader.onloadend = (event)=>
        promise.resolve event.target.result
      fileReader.onError = onReadError
      fileReader.readAsText file

    @_rootEntry.getFile filePath, {create: false, exclusive: false},
      (fileEntry)=>
        fileEntry.file onReadSuccess, onReadError
      onReadError
    promise.promise()

  @replacePresentation: (presentationId, onSuccess, onError)=>
    presentationPath = @getPathToPresentation presentationId
    onFolderDeleted = =>
      tempPath = @getPathToTemporaryPresentation presentationId
      tEntry = new DirectoryEntry tempPath, tempPath
      @_rootEntry.getDirectory @_presentationsRoot, {create: true, exclusive: false}, (entry)=>
        tEntry.moveTo entry, presentationId, onSuccess, onError
      ,onError
    @removeFolder presentationPath, onFolderDeleted, onError

  @removeFolder: (path, onSuccess, onError)=>
    dirEntry = new DirectoryEntry path, path
    dirEntry.removeRecursively onSuccess, (fileError)=>
      if fileError.code is 12 or fileError.code is 1 then onSuccess?() else onError?()

  @wipePresentationsStore: =>
    deferred = new $.Deferred
    @removeFolder @getPathToPresentationsDir(), deferred.resolve, deferred.reject
    deferred.promise()

  @removeArchive: (presentationId)=>
    tempDir = @getPathToTemporaryDir()
    dirEntry = new DirectoryEntry tempDir, tempDir
    dirEntry.getFile "#{presentationId}.zip", {create: false, exclusive: false}, (entry)->
      entry.remove()

  if window.requestFileSystem
    window.requestFileSystem LocalFileSystem.PERSISTENT, 0, (fileSystem)=>
      @_rootPath = fileSystem.root.toURL().replace 'file://localhost', ''
      @_rootEntry = fileSystem.root
    , (error)->
      console.log error
  else
    console.log 'File system unavailable'

module.exports = PresentationsFileManager