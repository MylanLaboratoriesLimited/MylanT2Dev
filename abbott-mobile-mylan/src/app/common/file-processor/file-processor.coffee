class FileProcessor

  _rootPath: null

  _requestFileSystem: =>
    deferred = new $.Deferred()
    onSuccess = (fileSystem) =>
      @_rootPath = fileSystem.root.toURL().replace 'file://localhost', ''
      deferred.resolve(fileSystem)
    onFail = (error) =>
      deferred.reject()
      console.log error.code
    window.requestFileSystem LocalFileSystem.TEMPORARY, 0, onSuccess, onFail
    deferred.promise()

  _gotFS: (fileSystem) =>
    deferred = new $.Deferred()
    onSuccess = (fileEntry) =>
      deferred.resolve(fileEntry)
    onFail = (error) =>
      deferred.reject()
      console.log error.code
    fileSystem.root.getFile(@fileName, {create: true, exclusive: false}, onSuccess, onFail);
    deferred.promise()

  _gotFileEntry: (fileEntry) =>
    deferred = new $.Deferred()
    onSuccess = (writer) =>
      deferred.resolve(writer)
    onFail = (error) =>
      deferred.reject()
      console.log error.code
    fileEntry.createWriter(onSuccess, onFail)
    deferred.promise()

  _gotFile: (fileEntry) =>
    deferred = new $.Deferred()
    onSuccess = (file) =>
      deferred.resolve(file)
    onFail = (error) =>
      deferred.reject()
      console.log error.code
    fileEntry.file(onSuccess, onFail)
    deferred.promise()

  _readAsText: (file) =>
    deferred = new $.Deferred()
    reader = new FileReader()
    reader.onloadend = (evt) =>
      deferred.resolve evt.target.result
    reader.readAsText file
    deferred.promise()

  _gotFileWriter: (writer) =>
    deferred = new $.Deferred()
    writer.onwriteend = => deferred.resolve(writer)
    writer.write(@dataString)
    deferred.promise()

  write: (@fileName, @dataString) =>
    @_requestFileSystem()
    .then(@_gotFS)
    .then(@_gotFileEntry)
    .then(@_gotFileWriter)

  read: (@fileName) =>
    @_requestFileSystem()
    .then(@_gotFS)
    .then(@_gotFile)
    .then(@_readAsText)


  getFullPath: (@fileName) =>
    @_requestFileSystem()
    .then => "#{@_rootPath}/#{@fileName}"

  getFileDirectory: (@fileName) =>
    @_requestFileSystem()
    .then => "#{@_rootPath}"

module.exports = FileProcessor