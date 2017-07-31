cordova.define("com.qapint.cordova.locale.Locale", function(require, exports, module) { var exec = require('cordova/exec'),
		pluginName = "Locale";

function Locale(){}

Locale.prototype.setLanguage = function(locale, success, fail){
	exec(success, fail, pluginName, 'setLanguage', [locale]);
};

module.exports = new Locale()
});
