var PhoneDialer = function(){
	this.resultTypes = {
		NOT_SUPPORTED: 1
	};
};

PhoneDialer.prototype.dial = function(phnum, onError){
	this.resultCallback = onError;
	cordova.exec("PhoneDialer.dialPhone", {"number": phnum });
};
PhoneDialer.prototype._didFinishWithResult = function(res){
	this.resultCallback && this.resultCallback(res);
};

if(!window.plugins){
	window.plugins = {};
}
if(!window.plugins.phoneDialer){
	window.plugins.phoneDialer = new PhoneDialer();
}
