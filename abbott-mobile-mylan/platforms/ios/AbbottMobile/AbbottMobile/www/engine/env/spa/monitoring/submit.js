(function(){
	'use strict';
	var /*app = window.parent.app, */time, like, header,
		halfHeight = window.innerHeight / 2,
		touchstart = ('ontouchstart' in window) ? 'touchstart' : 'mousedown',
		currentSlide;

	window.currentPresentation = 1;
	window.detailedPresentations = [];

	function sendImpression(event){
		like = event.detail.startY < halfHeight;
	}

	function startTimer(){
		var headerElement = app.current.slide.frame.contentDocument.querySelector('h1');

		currentSlide = app.current.slide.id;

		like = 0;
		time = Date.now();
		header = headerElement ? headerElement.innerText : '';

		app.current.slide.frame.contentDocument.addEventListener('swipeleft', sendImpression);
		app.current.slide.frame.contentDocument.addEventListener('swiperight', sendImpression);
	}

	function updateKPI(){
		var estimate = Math.round((Date.now() - time) / 1000),
			name = app.current.slide.name || header || '',
			currentChapter = app.current.chapter.id;

		if(name){
			name = name
				.replace(/<sup>(.*)<\/sup>/gi, ' ')
				.replace(/<sub>(.*)<\/sub>/gi, ' ')
				.replace(/<(.*?)>/gi, ' ')
				.replace(/(\t)+/gi, ' ')
				.replace(/\n/gi, ' ')
				.trim();
		}

		window.timeSpent = estimate;

		submit.data('slides', {
			id: currentSlide,
			name: name,
			time: estimate,
			chapter: currentChapter,
			likes: +like || 0,
			presentation: ''
		}, false);

		submit.data('chapter', {
			id: currentChapter,
			time: estimate
		});

	}

	document.addEventListener('slideenter', startTimer);
	document.addEventListener('slideleave', updateKPI);

	window.addEventListener('proceed', startTimer);
	window.addEventListener('suspend', updateKPI);

	submit.schema('slides', {
		id: String,
		name: String,
		time: Number,
		likes: Number,
		chapter: String,
		presentation: String
	}, {
		updateBy: 'id',
		update: function(oldItem, newItem){
			oldItem.time += newItem.time;
			window.timeSpent = oldItem.time;
		}
	});

	submit.schema('chapter', {
		id: String,
		time: Number
	}, {
		updateBy: 'id',
		update: function(oldItem, newItem){
			oldItem.time += newItem.time;
		}
	});


})();