cordova.define("com.qapint.cordova.phone-dialer.PhoneDialer", function(require, exports, module) { var exec = require('cordova/exec'),
		pluginName = "PhoneDialer",
		PhoneDialer = function(){
			this.resultTypes = {
				NOT_SUPPORTED: 1
			};
		};

PhoneDialer.prototype.dial = function(phnum, success){
	document.location.href = "tel:" + phnum;
	success && success();
};

module.exports = new PhoneDialer();
});
