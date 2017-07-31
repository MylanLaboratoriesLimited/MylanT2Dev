class ZipManager
  constructor: (@sourceFile, @destinationFolder)->
    @zip = window.plugins.zip

  unzip: (onSuccess, onError)=>
    @zip.unzip @sourceFile, @destinationFolder, onSuccess, onError

module.exports = ZipManager