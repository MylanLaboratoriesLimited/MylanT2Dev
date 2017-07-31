(function(){
	var cordovaRef = window.PhoneGap || window.Cordova || window.cordova;

	function Zip(){}
	Zip.prototype.unzip = function(sourceZip, targetDirectory, success, error) {
		cordovaRef.exec(success, error, 'Zip', 'unzip', [sourceZip, targetDirectory]);
	};

	cordovaRef.addConstructor && cordovaRef.addConstructor(function() {
		if (!window.plugins) {
			window.plugins = {};
		}

		if (!window.plugins.zip) {
			window.plugins.zip = new Zip();
			console.log("**************************** Zip ready *************************");
		}
	});
})();

