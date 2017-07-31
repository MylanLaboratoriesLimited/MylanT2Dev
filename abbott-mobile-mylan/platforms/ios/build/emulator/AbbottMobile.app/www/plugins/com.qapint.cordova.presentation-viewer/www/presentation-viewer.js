cordova.define("com.qapint.cordova.presentation-viewer.PresentationViewer", function(require, exports, module) { var exec = require('cordova/exec'),
		pluginName = "PresentationViewer";

function PresentationViewer(){}

PresentationViewer.events = {
	didLoad: 'DID_LOAD',
	complete: 'COMPLETE'
};

function paramsForOpen(paramsObj){
	var paramsArray = [paramsObj.index];
	if(paramsObj.structure){
		paramsArray.push(paramsObj.structure);
	}
	return paramsArray;
}

PresentationViewer.prototype.open = function(openParams, success, fail){
	exec(success, fail, pluginName, 'openPresentation', paramsForOpen(openParams));
};

PresentationViewer.prototype.close = function(success, fail){
	exec(success, fail, pluginName, 'closePresentation', []);
};

PresentationViewer.prototype.getKPI = function(success, fail){
	exec(success, fail, pluginName, 'getKPI', []);
};

module.exports = PresentationViewer
});
