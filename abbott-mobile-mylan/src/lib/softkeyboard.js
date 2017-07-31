(function() {
    /* Get local ref to global PhoneGap/Cordova/cordova object for exec function.
     - This increases the compatibility of the plugin. */
    var cordovaRef = window.PhoneGap || window.Cordova || window.cordova; // old to new fallbacks

    function SoftKeyboard() {}

    SoftKeyboard.prototype.show = function(win, fail) {
        return cordova.exec(
            function (args) { if(win) { win(args); } },
            function (args) { if(fail) { fail(args); } },
            "SoftKeyboard", "show", []);
    };

    SoftKeyboard.prototype.hide = function(win, fail) {
        return cordova.exec(
            function (args) { if(win) { win(args); } },
            function (args) { if(fail) { fail(args); } },
            "SoftKeyboard", "hide", []);
    };

    SoftKeyboard.prototype.isShowing = function(win, fail) {
        return cordova.exec(
            function (isShowing) {
                if(win) {
                    isShowing = isShowing === 'true' ? true : false
                    win(isShowing);
                }
            },
            function (args) { if(fail) { fail(args); } },
            "SoftKeyboard", "isShowing", []);
    };

    SoftKeyboard.prototype.getAvailScreenHeight = function(win, fail) {
        return cordova.exec(
            function (args) { if(win) { win(args); } },
            function (args) { if(fail) { fail(args); } },
            "SoftKeyboard", "getAvailScreenHeight", []);
    };

    cordovaRef.addConstructor && cordovaRef.addConstructor(function() {
        if (!window.plugins) {
            window.plugins = {};
        }

        if (!window.plugins.softKeyboard) {
            window.plugins.softKeyboard = new SoftKeyboard();
            console.log("**************************** SoftKeyboard ready *************************");
        }
    });

})();/* End of Temporary Scope. */