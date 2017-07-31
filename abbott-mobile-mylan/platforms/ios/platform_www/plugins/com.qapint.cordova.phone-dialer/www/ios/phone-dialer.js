cordova.define("com.qapint.cordova.phone-dialer.PhoneDialer", function(require, exports, module) { var exec = require('cordova/exec'),
		pluginName = "PhoneDialer",
		PhoneDialer = function(){
			this.resultTypes = {
				NOT_SUPPORTED: 1
			};
		};
		
function log(message){
	return function(){
		console.log(message)
	}
}

PhoneDialer.prototype.dial = function(phnum, success, fail){
	exec(success || log('Dial success'), fail || log('Dial fail'), pluginName, "dialPhone", [phnum]);
};

module.exports = new PhoneDialer();
});
