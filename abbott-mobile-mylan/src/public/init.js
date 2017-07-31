var app = {
    init: function() {
        var exports = this;
        $(function() {
            var App = require("index");
            exports.mainController = new App({el: $("body > div")});
            app.onResume();
        });
    },

    showAlert: function (message, title) {
        if (navigator.notification) {
            navigator.notification.alert(message, null, title, 'OK');
        } else {
            alert(title ? (title + ": " + message) : message);
        }
    },

    initialize: function() {
        this.bindEvents();
    },

    bindEvents: function() {
        var userAgent = window.navigator.userAgent.toLowerCase();
        if (userAgent.match(/(iphone|ipod|ipad|android)/)) {
            document.addEventListener('deviceready', this.onDeviceReady, false);
            document.addEventListener('resume', this.onResume, false);
        } else {
            this.onDeviceReady();
        }                         
    },

    onDeviceReady: function() {
        app.receivedEvent('deviceready');
        // app.setupSalesforceCredentials();
        app.init();
    },

    onResume: function() {
        app.receivedEvent('resume');
        if (navigator.splashscreen){
            navigator.splashscreen.hide();
        }
    },

    receivedEvent: function(id) {
        console.log('Received Event: ' + id);
    },

    setupSalesforceCredentials: function() {
        cordova.require("salesforce/plugin/oauth").getAuthCredentials(app.salesforceSessionRefreshed, app.getAuthCredentialsError);
        document.addEventListener("salesforceSessionRefresh", app.salesforceSessionRefreshed, false);
    },

    salesforceSessionRefreshed: function(creds) {
        var credsData = creds;
        if (creds.data) {
            credsData = creds.data;
        }
        Force.init(creds, apiVersion, null, cordova.require("salesforce/plugin/oauth"))
    },

    getAuthCredentialsError: function(error) {
        console.log('Error: ' + error);
    }
};

window.addEventListener("touchmove", function (event) {
    event.preventDefault();
}, false);

function shouldRotateToOrientation (rotation) {
    return rotation == 90;
}