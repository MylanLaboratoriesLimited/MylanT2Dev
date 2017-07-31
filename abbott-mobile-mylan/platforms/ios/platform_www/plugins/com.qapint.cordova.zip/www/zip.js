cordova.define("com.qapint.cordova.zip.Zip", function(require, exports, module) { var exec = cordova.require('cordova/exec');

    function newProgressEvent(result) {
        var event = {
                loaded: result.loaded,
                total: result.total
        };
        return event;
    }

    exports.unzip = function(fileName, outputDirectory, onSuccess, onFail, progressCallback) {
        var win = function(result) {
            if (result && typeof result.loaded != "undefined") {
                if (progressCallback) {
                    return progressCallback(newProgressEvent(result));
                }
            } else if (onSuccess) {
                onSuccess(result);
            }
        };
        var fail = function(error) {
            if (onFail) {
                onFail(error);
            }
        };
        exec(win, fail, 'Zip', 'unzip', [fileName, outputDirectory]);
    };

    exports.zip = function(sourceDir, destFile, onSuccess, onFail, progressCallback) {
        var win = function(result) {
            if (result && typeof result.loaded != "undefined") {
                if (progressCallback) {
                    return progressCallback(newProgressEvent(result));
                }
            } else if (onSuccess) {
                onSuccess(result);
            }
        };
        var fail = function(error) {
            if (onFail) {
                onFail(error);
            }
        };
        exec(win, fail, 'Zip', 'zip', [sourceDir, destFile]);
    };


});
