(function(){
	"use strict";

	var history = [];

	function isArray(array){
		return array && Object.prototype.toString.call(array) === "[object Array]";
	}

	function insert(slides, slide){
		if(!isArray(slides)){
			slides = app.structure.chapters[slides].content;
		}

		return insertSlides(slides, slide);
	}

	function insertSlides(slides, slide){
		var current = app.current.chapter.content, id,
			insertAfter = current.indexOf(slide) + 1;

		if(!insertAfter){
			insertAfter = current.length;
		}

		current.splice.apply(current, [insertAfter, 0].concat(slides));

		id = [app.current.chapter.id, app.current.slide.id, Date.now()].join("/");

		history.push({
			id: id,
			chapter: app.current.chapter,
			visit: window.params.callNumber,
			slides: slides,
			index: insertAfter,
			length: slides.length,
			slide: app.current.slide.id
		});

		if(app.navigator){
			app.navigator.saveChanges();
		}

		return id;
	}

	function clear(){
		var id, insertion;

		if(!history.length){
			return;
		}

		if(arguments.length){
			id = arguments[0];

			if(!history.some(function(insertion){
					return insertion.id === id;
				})){
				return;
			}
		}else{
			id = history[history.length - 1].id;
		}

		insertion = history.reduce(function(insertion){
			if(insertion.id === id){
				return insertion;
			}
		});

		console.log(insertion);

		if(insertion){
			insertion.chapter.content.splice(insertion.index, insertion.length);

			history.forEach(function(item, index){
				if(index > history.indexOf(insertion)){
					item.index -= insertion.length;
				}
			});

			history.splice(history.indexOf(insertion), 1);
		}
	}

	function clearAll(){
		while(history.length){
			clearLast();
		}
	}

	window.app.dynamic = {
		insert: insert,
		clear: clear,
		clearAll: clearAll,
		history: history
	};
})();