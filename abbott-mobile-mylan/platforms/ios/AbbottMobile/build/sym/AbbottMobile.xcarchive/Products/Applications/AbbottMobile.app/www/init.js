var app = {
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

  onResume: function() {
    app.logReceivedEvent('resume');
    if (navigator.splashscreen){
      navigator.splashscreen.hide();
    }
  },

  onDeviceReady: function() {
    var spinner = new Spinner(),
        spinnerElement = document.createElement('div');
    spinnerElement.className = 'spinner-element';
    document.body.appendChild(spinnerElement);
    spinner.spin(spinnerElement);
    setTimeout(function(){
      app.logReceivedEvent('deviceready');
      app.setupSalesforceCredentials(function(creds) {
        app.initializeDatabase()
        .then(app.setupLocalization)
        .then(function(){
          setTimeout(function(){
            app.init();
            spinner.stop();
          }, 100);
        });
      }, function(err) {
        spinner.stop();
        // ...
      });
    }, 10);
  },

  setupLocalization: function() {
    var Locale = require('common/localization/locale');
    return Locale.initialize()
  },

  setupSalesforceCredentials: function(successCB, errorCB) {
    var SfdcInitializer = require('sfdc/sfdc-initializer');
    var initializer = new SfdcInitializer(successCB, errorCB);
    initializer.setupSalesforceCredentials();
  },

  initializeDatabase: function() {
    var DatabaseManager = require('db/database-manager');
    var dbManager = new DatabaseManager();
    return dbManager.initializeDatabase();
  },

  init: function() {
    app.logReceivedEvent('init');
    var exports = this;
    $(function() {
      var App = require('index');
      exports.mainController = new App({el: $("body > .app")});
      app.onResume();
    });
  },

  logReceivedEvent: function(id) {
    console.log('Received Event: ' + id);
  },

  showAlert: function (message, title) {
    if (navigator.notification) {
      navigator.notification.alert(message, null, title, 'OK');
    } else {
      alert(title ? (title + ": " + message) : message);
    }
  }
};

window.addEventListener("load", function (e) {
  function checkDeviceTypeByUserAgent() {
    var userAgent = window.navigator.userAgent.toLowerCase();
    var ios = /iphone|ipod|ipad/.test(userAgent);

    if (/mobile/.test(userAgent)) {
      document.body.className = ios ? "ios" : "android";
    }
  }
  checkDeviceTypeByUserAgent();
}, false);

/*
window.addEventListener("touchmove", function (event) {
  event.preventDefault();
}, false);*/
