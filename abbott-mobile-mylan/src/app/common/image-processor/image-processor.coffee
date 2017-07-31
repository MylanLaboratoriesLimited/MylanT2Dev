FileProcessor = require 'common/file-processor/file-processor'
Utils = require 'common/utils'

# TODO: REFACTOR THIS SHIT !!!!
# TODO: REMOVE COPYPASTE !!!!
# TODO: WRAP CALLBACKS INTO PROMISES DYNAMICALLY AS IT IS DONE IN SMARTSYNC !!!!
# TODO: IMAGE SHOULD BE SAVED WITH PATH ACCORDING DOCUMENTS DIR !!!!
class ImageProcessor
  @_resizer: window.plugins.imageResizer
  @_defaultResizeOptions = {
    format: ImageProcessor._resizer.options.FORMAT_JPG
    imageType: ImageProcessor._resizer.options.IMAGE_DATA_TYPE_URL
    resizeType: ImageProcessor._resizer.options.RESIZE_TYPE_PIXEL
    width: 320
    height: 240
    quality: 80
  }
  @_defaultSaveOptions = {
    format: ImageProcessor._resizer.options.FORMAT_JPG
    imageType: ImageProcessor._resizer.options.IMAGE_DATA_TYPE_BASE64
    directory: ''
    photoAlbum: false
  }

  _photoDirectory:  "photos"
  _tradeDirectory:  "trade"
  _thumbsDirectory: "thumbs"

  _getRootDir: =>
    deferred = new $.Deferred()
    onSuccess = (fileSystem) => deferred.resolve(fileSystem.root)
    onFail = (error) =>
      deferred.reject()
      console.log '_getRootDir' + error.code
    window.requestFileSystem LocalFileSystem.PERSISTENT, 0, onSuccess, onFail
    deferred.promise()

  _getTempDir: =>
    deferred = new $.Deferred()
    onSuccess = (fileSystem) => deferred.resolve(fileSystem.root)
    onFail = (error) =>
      deferred.reject()
      console.log '_getTempDir' + error.code
    window.requestFileSystem LocalFileSystem.TEMPORARY, 0, onSuccess, onFail
    deferred.promise()

  _getFileEntry: (dirEntry) =>
    deferred = new $.Deferred()
    onSuccess = (@fileEntry) => deferred.resolve(@fileEntry)
    onFail = (error) =>
      deferred.reject()
      console.log '_getFileEntry' + error.code
    dirEntry.getFile(@fileName, null, onSuccess, onFail);
    deferred.promise()

  _getChildDirEntry:(parentDirEntry, dirName) =>
    deferred = new $.Deferred()
    onSuccess = (dirEntry) => deferred.resolve(dirEntry)
    onFail = (error) =>
      deferred.reject()
      console.log '_getChildDirEntry' + error.code
    parentDirEntry.getDirectory dirName, {create: true}, onSuccess, onFail
    deferred.promise()

  _moveFile: (targetDirEntry)=>
    deferred = new $.Deferred()
    onSuccess = (dirEntry) => deferred.resolve(dirEntry)
    onFail = (error) =>
      deferred.reject()
      console.log '_moveFile' + error.code
    timeStamp = new Date().getTime()
    @fileEntry.moveTo(targetDirEntry, timeStamp + @fileName, onSuccess, onFail);
    deferred.promise()

  _removeFile: =>
    deferred = new $.Deferred()
    onSuccess = (dirEntry) => deferred.resolve(dirEntry)
    onFail = (error) => deferred.reject()
    @fileEntry.remove(onSuccess, onFail);
    deferred.promise()

  _readAsBase64: (file) =>
    deferred = new $.Deferred()
    reader = new FileReader()
    reader.onloadend = (evt) => deferred.resolve evt.target.result
    reader.readAsDataURL file
    deferred.promise()

  save: (fileName) =>
    @fileName = fileName.replace(/^.*(\\|\/|\:)/, '')
    @_getTempDir()
    .then(@_getFileEntry)
    .then(@_getRootDir)
    .then (parentDirEntry) => @_getChildDirEntry(parentDirEntry, @_tradeDirectory)
    .then (parentDirEntry) => @_getChildDirEntry(parentDirEntry, @_photoDirectory)
    .then(@_moveFile)

  read: (fileName) =>
    @fileName = fileName.replace(/^.*(\\|\/|\:)/, '')
    @_getRootDir()
    .then (parentDirEntry) => @_getChildDirEntry(parentDirEntry, @_tradeDirectory)
    .then (parentDirEntry) => @_getChildDirEntry(parentDirEntry, @_photoDirectory)
    .then(@_getFileEntry)
    .then => new FileProcessor()._gotFile(@fileEntry)
    .then(@_readAsBase64)

  remove: (fileName) =>
    @fileName = fileName.replace(/^.*(\\|\/|\:)/, '')
    @_getRootDir()
    .then (parentDirEntry) => @_getChildDirEntry(parentDirEntry, @_tradeDirectory)
    .then (parentDirEntry) => @_getChildDirEntry(parentDirEntry, @_photoDirectory)
    .then(@_getFileEntry)
    .then(@_removeFile)

  removeThumb: (fileName) =>
    @fileName = fileName.replace(/^.*(\\|\/|\:)/, '')
    @_getRootDir()
    .then (parentDirEntry) => @_getChildDirEntry(parentDirEntry, @_tradeDirectory)
    .then (parentDirEntry) => @_getChildDirEntry(parentDirEntry, @_photoDirectory)
    .then (parentDirEntry) => @_getChildDirEntry(parentDirEntry, @_thumbsDirectory)
    .then(@_getFileEntry)
    .then(@_removeFile)

  resize: (url, options = {}) =>
    options = $.extend(ImageProcessor._defaultResizeOptions, options)
    ImageProcessor._resizer.resizeImage(url, options.width, options.height, options)

  saveFromBase64: (imageData, options = {}) =>
    options = $.extend(ImageProcessor._defaultSaveOptions, options)
    ImageProcessor._resizer.storeImage(imageData, options)

  @getThumbnailPath: (url) =>
    return '' unless url
    pathSegments = url.split '/'
    pathSegments[pathSegments.length - 1] = "thumbs/#{pathSegments[pathSegments.length - 1]}"
    pathSegments.join '/'

module.exports = ImageProcessor