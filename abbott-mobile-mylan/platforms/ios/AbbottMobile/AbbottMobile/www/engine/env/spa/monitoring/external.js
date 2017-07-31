(function(){
	'use strict';
	var external = {}, events;

	external.methods = {
		getKPI: function(){
			return localStorage.getItem('KPI');
		},
		clearStorage: function(){
			localStorage.removeItem('KPI');
		},
		supportsShortVisitMode: function(){
			var xhr = window.utils.load("structure_cn" + window.params.callNumber + "_short.json");

			return xhr.status !== 404 && xhr.status !== -1100; // status -1100 - ios 6 abbott clm
		},
		getVisitGraph: function(){
			var data = JSON.parse(localStorage.getItem('dynamic'));

			return JSON.stringify({
				'visitNumber': window.params.callNumber,
				'timestamp': Date.now(),
				'data': data.data
			});
		},
		setVisitGraph: function(data){
			localStorage.setItem('dynamic', JSON.stringify(data));
		}
	};

	events = ['suspend', 'proceed'].reduce(function(events, name){
		events[name] = document.createEvent('UIEvents');
		events[name].initUIEvent(name, false, false, window, 1);

		return events;
	}, {});

	function executeMethod(method){
		return external.methods.hasOwnProperty(method) && external.methods[method]();
	}

	function invokeEvent(event){
		if(events.hasOwnProperty(event)){
			window.dispatchEvent(events[event]);
		}
	}

	window.executeMethod = executeMethod;
	window.invokeEvent = invokeEvent;
	window.getVisitGraph = external.methods.getVisitGraph;
	window.setVisitGraph = external.methods.setVisitGraph;
})();