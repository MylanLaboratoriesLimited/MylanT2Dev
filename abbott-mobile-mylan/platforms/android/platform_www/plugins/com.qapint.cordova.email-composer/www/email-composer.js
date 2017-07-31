cordova.define("com.qapint.cordova.email-composer.EmailComposer", function(require, exports, module) { var exec = require('cordova/exec'),
		pluginName = "EmailComposer";

function EmailComposer() {
	this.resultCallback = function(){}; 
}

EmailComposer.ComposeResultType = {
    Cancelled:0,
    Saved:1,
    Sent:2,
    Failed:3,
    NotSent:4
};

EmailComposer.prototype.showEmailComposer = function(subject, body, toRecipients, ccRecipients, bccRecipients, bIsHTML, attachments) {
    var args = {};
    args.subject = subject ? subject : "";
    args.body = body ? body : "";
    args.toRecipients = toRecipients ? toRecipients : [];
    args.ccRecipients = ccRecipients ? ccRecipients : [];
    args.bccRecipients = bccRecipients ? bccRecipients : [];
    args.bIsHTML = bIsHTML ? true : false;
    args.attachments = attachments ? attachments : [];
    exec(null, null, pluginName, "showEmailComposer", [args]);
};

EmailComposer.prototype.showEmailComposerWithCallback = function(callback, subject, body, toRecipients, ccRecipients, bccRecipients, isHTML, attachments) {
    this.resultCallback = callback;
    this.showEmailComposer.apply(this, [subject, body, toRecipients, ccRecipients, bccRecipients, isHTML, attachments]);
};

EmailComposer.prototype._didFinishWithResult = function(res) {
    this.resultCallback(res);
};
		
var composer = new EmailComposer();
composer.ComposeResultType = EmailComposer.ComposeResultType;
		
module.exports = composer
});
