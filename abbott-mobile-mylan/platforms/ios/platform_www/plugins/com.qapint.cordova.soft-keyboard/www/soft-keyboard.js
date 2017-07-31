cordova.define("com.qapint.cordova.soft-keyboard.SoftKeyboard", function(require, exports, module) { var exec = require('cordova/exec'),
		pluginName = "SoftKeyboard";

function SoftKeyboard() {
	console.log("**************************** SoftKeyboard ready *************************");
}

SoftKeyboard.prototype.show = function(success, fail) {
    return exec(success, fail, pluginName, "show", []);
};

SoftKeyboard.prototype.hide = function(success, fail) {
    return exec(success, fail, pluginName, "hide", []);
};

SoftKeyboard.prototype.isShowing = function(success, fail) {
    return exec(
        function (isShowing) {
            if(success) {
							isShowing = isShowing === 'true' ? true : false;
              success(isShowing);
            }
        },
        function (args) { if(fail) { fail(args); } },
        pluginName, "isShowing", []);
};

SoftKeyboard.prototype.getAvailScreenHeight = function(success, fail) {
    return exec(success, fail, pluginName, "getAvailScreenHeight", []);
};

module.exports = new SoftKeyboard();
});
