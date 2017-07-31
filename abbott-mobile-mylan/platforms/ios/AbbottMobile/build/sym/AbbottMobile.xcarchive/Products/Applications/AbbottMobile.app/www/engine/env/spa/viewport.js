(function(global){
	"use strict";

	var touchCount;

	utils.load('spa-ctl.json', function(){
		var settings = JSON.parse(this.responseText);
		touchCount = settings.navTouchCount || 1;
		window.app.speciality = settings.speciality || '';
		// hack: going from visit to product presentation url still contains visit's callNumber.
		// clm guys said they'll fix this after 2 months (cur date - 20.08.2014)
		if(!settings.speciality){
			window.params.callNumber = null;
		}
	}, false);

	function createFrames(element){
		return ["current", "next"].reduce(function(frames, frame){
			var wrapper = document.createElement("div"),
				iframe = document.createElement("iframe");

			wrapper.className = "slide " + frame;
			iframe.sandbox = "allow-same-origin allow-scripts allow-popups allow-top-navigation";

			wrapper.appendChild(iframe);
			element.appendChild(wrapper);

			frames[frame] = {element: wrapper, iframe: iframe};

			return frames;
		}, {});
	}

	function ViewPort(element){
		var chapter, slide, that = this;

		this.element = element;

		Observer.call(this);

		Object.defineProperties(this, {
			"chapter": {
				set: function(value){
					chapter = value;
					that.slides = app.structure.chapters[chapter].content;

					that.publish("chapterchange");
				},
				get: function(){return chapter;}
			},
			"slide": {
				set: function(value){
					slide = value;
					that.index = that.slides.indexOf(slide);

					that.publish("slidechange", slide);
				},
				get: function(){return slide;}
			}
		});

		this.frames = createFrames(element);
	}

	ViewPort.prototype = Object.create(Observer.prototype);
	ViewPort.prototype.isTouch = ("ontouchstart" in window);

	ViewPort.prototype.goto = function(options){
		var chapter = options.chapter, slide = options.slide;

		if(!app.structure.chapters.hasOwnProperty(chapter)){
			throw new Error("There is no \"" + chapter + "\" chapter.");
		}

		if(!slide){
			slide = app.structure.chapters[chapter].content[0];
		}

		if(!app.structure.slides.hasOwnProperty(slide)){
			throw new Error("Slide \"" + slide + "\" is not described.");
		}

		if(app.structure.chapters[chapter].content.indexOf(slide) === -1){
			throw new Error("There is no \"" + slide + "\" slide in \"" + chapter + "\" chapter.");
		}

		if(!(this.chapter === chapter && this.slide === slide)){
			this.update(chapter, slide, options.noTransition);
		}
	};

	ViewPort.prototype.update = function(chapter, slide, noTransition){
		if(!this.chapter || this.chapter !== chapter){
			this.buildNewChapter(chapter, slide);
		}else{
			this.shiftChapter(slide, noTransition);
		}
	};

	ViewPort.prototype.dispatchSlideEvent = function(event, frame){
		frame = frame || this.frames.current;

		utils.dispatchEvent(frame.iframe.contentDocument, event, {detail: {slide: this.frames.current.element}});
		utils.dispatchEvent(document, event, {detail: {slide: this.frames.current.element}});
	};

	ViewPort.prototype.buildNewChapter = function(chapter, slide) {
		var iframe = this.frames.current.iframe, that = this;

		if(this.slide){
			this.dispatchSlideEvent("slideleave");
		}

		iframe.onload = function(){
			that.dispatchSlideEvent("slideenter");
			that.enableSwipes();
		};


		this.chapter = chapter;
		this.slide = slide;

		iframe.src = app.structure.slides[slide].template;
		iframe.id = slide;
	};

	ViewPort.prototype.shiftChapter = function(slide, noTransition){
		var iframe = this.frames.next.iframe,
			template = app.structure.slides[slide].template,
			direction = this.slides.indexOf(slide) - this.slides.indexOf(this.slide),
			nextFrameElement = this.frames.next.element,
			currentSlide = this.slide, that = this,
			currentFrame = that.frames.current;

		iframe.onload = function(){
			that.moveSlideshow(direction, function(){
				if(currentSlide){
					that.dispatchSlideEvent("slideleave", that.frames.next);
				}

				that.enableSwipes();
				that.dispatchSlideEvent("slideenter");
			}, noTransition);
		};

		that.frames.current = that.frames.next;
		that.frames.next = currentFrame;

		that.slide = slide;

		this.prepareToMoving(direction);

		if(iframe.src !== template){
			iframe.src = template;
			iframe.id = slide;
		}else{
			iframe.onload();
		}
	};

	ViewPort.prototype.moveSlideshow = function(direction, callback, noTransition){
		var currentFrameElement = this.frames.next.element,
			nextFrameElement = this.frames.current.element;

		["no-trans", "next", "prev"].forEach(function(className){
			nextFrameElement.classList.remove(className);
		});

		if(noTransition){
			currentFrameElement.classList.add("no-trans");
			nextFrameElement.classList.add("no-trans");
		}else{
			currentFrameElement.classList.remove("no-trans");
			nextFrameElement.classList.remove("no-trans");
		}

		currentFrameElement.classList.remove("current");
		currentFrameElement.classList.add(direction > 0 ? "prev" : "next");

		nextFrameElement.classList.add("current");

		this.addTransitionEventListener(nextFrameElement, callback);
	};

	ViewPort.prototype.prepareToMoving = function(direction){
		var element = this.frames.current.element;

		element.classList.add("no-trans");
		element.classList.remove("next");
		element.classList.remove("prev");

		element.classList.add(direction > 0 ? "next" : "prev");
	};

	ViewPort.prototype.gotoNextSlide = function() {
		var slides = app.structure.chapters[this.chapter].content,
			currentSlideIndex = slides.indexOf(this.slide),
			nextSlide = slides[currentSlideIndex + 1];

		if(nextSlide){
			this.goto({chapter: this.chapter, slide: nextSlide});
		}else{
			this.enableSwipes();
		}
	};

	ViewPort.prototype.gotoPreviousSlide = function() {
		var slides = app.structure.chapters[this.chapter].content,
			currentSlideIndex = slides.indexOf(this.slide),
			previousSlide = slides[currentSlideIndex - 1];

		if(previousSlide){
			this.goto({chapter: this.chapter, slide: previousSlide});
		}else{
			this.enableSwipes();
		}
	};

	ViewPort.prototype.enableSwipes = function(){
		var doc = this.frames.current.iframe.contentDocument,
			that = this, onSwipeLeft, onSwipeRight;

		doc.addEventListener("swipeleft", onSwipeLeft = function(event){
			if(that.isRequiredTouchesCount(event.detail.touchesCount)){
				doc.removeEventListener("swipeleft", onSwipeLeft);
				doc.removeEventListener("swiperight", onSwipeRight);

				that.gotoNextSlide();
			}
		});

		doc.addEventListener("swiperight", onSwipeRight = function(event){
			if(that.isRequiredTouchesCount(event.detail.touchesCount)){
				doc.removeEventListener("swipeleft", onSwipeLeft);
				doc.removeEventListener("swiperight", onSwipeRight);

				that.gotoPreviousSlide();
			}
		});
	};

	ViewPort.prototype.addTransitionEventListener = function(element, callback){
		var transitionDuration = getComputedStyle(element).webkitTransitionDuration,
			isTransitionSet = transitionDuration !== '' && transitionDuration !== '0s';

		if(isTransitionSet){
			this.addEventListenerForOnce(element, 'webkitTransitionEnd', callback.bind(element));
		}else{
			setTimeout(function(){
				callback.apply(element, arguments);
			}, 0);
		}
	};

	ViewPort.prototype.addEventListenerForOnce = function(element, event, callback, isOnCapturing){
		var func;

		element.addEventListener(event, func = function(){
			callback.apply(this, arguments);

			element.removeEventListener(event, func, isOnCapturing);
		}, isOnCapturing);
	};

	ViewPort.prototype.isRequiredTouchesCount = function(count){
		return !this.isTouch || count === touchCount;
	};

	global.ViewPort = ViewPort;
})(window);