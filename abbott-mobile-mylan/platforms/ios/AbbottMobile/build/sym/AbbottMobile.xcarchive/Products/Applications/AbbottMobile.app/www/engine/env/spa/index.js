(function(){
	"use strict";

	var firstChapterId, firstSlideId, navigator;

	app.current = {};

	navigator = new Navigator("viewport");

	app.goto = function(options){
		navigator.goto(options);
	};

	app.nextSlide = function(){
		navigator.nextSlide();
	};

	app.previousSlide = function(){
		navigator.previousSlide();
	};
	
	app.navigator = navigator;

	if(!app.current.slide){
		firstChapterId = app.structure.storyboard[0];
		firstSlideId = app.structure.chapters[firstChapterId].content[0];
		app.goto({chapter: firstChapterId, slide: firstSlideId});
	}

	window.isSPA = true;
	window.storage = {};
}());