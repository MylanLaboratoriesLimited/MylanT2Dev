(function(){
	"use strict";

	var search = location.search, params = {};

	search && search.slice(1).split("&").forEach(function(pair){
		pair = pair.split("=");
		params[pair[0]] = getTypedValue(decodeURIComponent(pair[1]));
	});

	function getTypedValue(str){
		try{
			return JSON.parse(str);
		}catch(e){
			return str;
		}
	}

	window.params = params;
})();
