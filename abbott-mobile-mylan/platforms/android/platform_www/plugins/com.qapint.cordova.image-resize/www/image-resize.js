cordova.define("com.qapint.cordova.image-resize.ImageResize", function(require, exports, module) { var ImageResizer = function () {},
    pluginName = "ImageResize",
    resizerOptions = {
        IMAGE_DATA_TYPE_BASE64: "base64Image",
        IMAGE_DATA_TYPE_URL: "urlImage",
        RESIZE_TYPE_FACTOR: "factorResize",
        RESIZE_TYPE_PIXEL: "pixelResize",
        FORMAT_JPG: "jpg",
        FORMAT_PNG: "png"
    };

ImageResizer.prototype.resizeImage = function (imageData, width,
                                               height, options) {
    if (!options) {
        options = {}
    }
    var params = {
        data: imageData,
        width: width,
        height: height,
        format: options.format,
        imageDataType: options.imageType,
        resizeType: options.resizeType,
        quality: options.quality ? options.quality : 70
    }, deferred = new $.Deferred();

    cordova.exec(deferred.resolve, deferred.reject, pluginName,
        "resizeImage", [params]);
    return deferred.promise();
};

ImageResizer.prototype.imageSize = function (imageData,
                                             options) {
    if (!options) {
        options = {}
    }
    var params = {
        data: imageData,
        imageDataType: options.imageType
    }, deferred = new $.Deferred();

    cordova.exec(deferred.resolve, deferred.reject, pluginName,
        "imageSize", [params]);
    return deferred.promise();
};

ImageResizer.prototype.storeImage = function (imageData, options) {
    if (!options) {
        options = {}
    }
    var params = {
        data: imageData,
        format: options.format,
        imageDataType: options.imageType,
        filename: options.filename,
        directory: options.directory,
        quality: options.quality ? options.quality : 100,
        photoAlbum: !!options.photoAlbum
    }, deferred = new $.Deferred();

    cordova.exec(deferred.resolve, deferred.reject, pluginName,
        "storeImage", [params]);
    return deferred.promise();
};

var imageResizer = new ImageResizer();
imageResizer.options = resizerOptions;

module.exports = imageResizer

});
