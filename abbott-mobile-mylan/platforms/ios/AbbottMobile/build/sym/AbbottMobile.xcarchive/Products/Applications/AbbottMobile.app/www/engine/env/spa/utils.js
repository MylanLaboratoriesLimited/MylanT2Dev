(function(){
	"use strict"

	var utils = {};

	(function(){
		if(!window.CustomEvent){
			window.CustomEvent = function(event, params){
				var evt = document.createEvent('CustomEvent');
				params = params || { bubbles: false, cancelable: false, detail: undefined };
				evt.initCustomEvent(event, params.bubbles, params.cancelable, params.detail);
				return evt;
			}
			window.CustomEvent.prototype = Object.create(Event.prototype);
		}
	})();

	utils.mixin = function(target, source, args){
		var keys = args instanceof Array ? args : Object.keys(source);

		keys.filter(function(key){
			return !!source[key];
		}).forEach(function(key){
				target[key] = source[key];
			});

		return target;
	};

	utils.template = function(string, data){
		return string.replace(/\{([^\}]+)\}/g, function(match, key){
			return data[key.trim()];
		});
	};

	utils.dispathEvent = function(target, event, options){
		options = utils.mixin({ bubbles: true, cancelable: false }, options || {});
		target.dispatchEvent(new CustomEvent(event, options));
	};

	utils.dispatchEvent = utils.dispathEvent;

	utils.load = function(url, callback, async){
		var request = new XMLHttpRequest();

		request.onload = callback;

		request.open('GET', url, !!async);
		request.send();

		return request;
	};
	// mapToArray :: Object -> Array
	// Convert Object properties to Array's item and extending them with property's key
	utils.mapToArray = function(map){
		return Object.keys(map).map(function(id){
			var item = map[id],
				obj = Object.create(item);
			obj.id = id;
			return obj;
		});
	};

	// toObject :: Array -> Array -> Object
	utils.toObject = function(keys, values){
		var object = {};

		keys.forEach(function(key, index){
			object[key] = values[index];
		});

		return object;
	};

	window.utils = utils;
})();
