cordova.define("com.qapint.cordova.pdf-viewer.PdfViewer", function(require, exports, module) { var exec = require('cordova/exec'),
		pluginName = "PdfViewer";

function PdfViewer(){}

PdfViewer.prototype.open = function(documentUrl, success, fail){
	exec(success, fail, pluginName, 'openDocument', [documentUrl]);
};
module.exports = new PdfViewer()
});
