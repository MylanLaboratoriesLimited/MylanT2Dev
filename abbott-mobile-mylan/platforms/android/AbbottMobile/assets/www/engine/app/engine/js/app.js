var rivets = require('rivets'),
	isPopup = window.parent.isSPA && !!window.parent.app.navigator.popupViews.length;

require('android-fixes').setAttributeFix();

require('polyfills');

require('extension')(rivets);
require('touch').init(document);
require('translate').configure({
	path: 'i18n/{ lang }/{ id }.json',
	id: require('slide').id
});

require('./rv-html').substitute();

// bind head element for augment rivets
rivets.bind(document.head, {});

// bind page content
rivets.bind(document.body, {
	isPopup: isPopup,
	t: require('translate').load(require('settings').lang)
});

require('orientation-fix').fix(window);
