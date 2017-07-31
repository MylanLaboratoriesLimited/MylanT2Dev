cordova.define("com.qapint.cordova.attachments-viewer.AttachmentsViewer", function(require, exports, module) { var exec = require('cordova/exec'),
		pluginName = "AttachmentsViewer";

function AttachmentsViewer(){}

AttachmentsViewer.prototype.open = function(path, mimeType){
	var deferred = new $.Deferred();
	exec(deferred.resolve, deferred.reject, pluginName, 'open', [{filePath: path, mimeType: mimeType || ''}]);
	return deferred.promise();
};

module.exports = new AttachmentsViewer()
});
