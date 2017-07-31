(function(global){
	"use strict";

	function Navigator(viewId){
		var element = document.getElementById(viewId),
			that = this;

		this.viewport = new ViewPort(element);
		this.popupViews = [];
		this.history = [];
		this.collectedPopupsCount = 0;

		this.viewport.subscribe("slidechange", function(slide){
			var currentFrame = that.viewport.frames.current;

			app.current.chapter = app.structure.chapters[that.viewport.chapter];
			app.current.slide = {
				id: that.viewport.slide,
				element: currentFrame.element,
				frame: currentFrame.iframe
			};
			app.current.index = that.viewport.index;

			that.changing = true;
			that.routeTo({chapter: that.viewport.chapter, slide: that.viewport.slide});

			that.refreshHistory(slide);
		});

		routie('/:chapter/:slide?', function(chapter, slide){
			if(!that.changing){
				that.viewport.goto({chapter: chapter, slide: slide});
			}

			that.changing = false;
		});
	}

	Navigator.prototype.goto = function(options) {
		var popupView = this.popupViews.length && this.popupViews[this.popupViews.length - 1];

		if(popupView && popupView.chapter === options.chapter){
			popupView.goto(options);
		}else{
			this.viewport.goto(options);
		}
	};

	Navigator.prototype.nextSlide = function() {
		this.viewport.gotoNextSlide();
	};

	Navigator.prototype.previousSlide = function() {
		this.viewport.gotoPreviousSlide();
	};

	Navigator.prototype.routeTo = function(options){
		routie('/' + options.chapter + '/' + (options.slide || ""));
	};

	Navigator.prototype.openPopup = function(options){
		var popupElement = document.createElement("div"),
			popupViewPort = new ViewPort(popupElement);

		popupElement.className = "popup";

		this.viewport.subscribe('slidechange', function(){
			this.closePopup();
		}.bind(this));

		this.popupViews.push(popupViewPort);

		document.body.appendChild(popupElement);

		popupViewPort.goto(options);
	};


	Navigator.prototype.closePopup = function(){
		var popupViewPort = this.popupViews.pop();

		if(popupViewPort){
			popupViewPort.dispatchSlideEvent("slideleave");
			popupViewPort.element.parentNode.removeChild(popupViewPort.element);
		}
	};

	Navigator.prototype.collectPopup = function(slides, slide){
		var id = "collected-popup-" + (++this.collectedPopupsCount),
			presentation;

		if(window.params.callNumber){
			presentation = app.current.slide.id.split('_')[0];
			slides = slides.map(function(slide){
				return presentation + '_' + slide;
			});

			if(slide){
				slide = presentation + '_' + slide;
			}
		}

		app.structure.chapters[id] = {
			id: id,
			name: "Collected Popup " + this.collectedPopupsCount,
			content: slides
		};

		this.openPopup({chapter: id, slide: slide});
	};

	Navigator.prototype.refreshHistory = function(){
		var history, slides;

		slides = app.structure.chapters[this.viewport.chapter].content;

		if(this.viewport.index >= this.history.length){
			history = slides.slice(0, this.viewport.index + 1);
		}else{
			history = this.history.filter(function(slide){
				return slides.indexOf(slide) !== -1;
			});
		}

		this.history = history;

		this.saveChanges();
	};

	Navigator.prototype.saveChanges = function(){
		var data = JSON.parse(localStorage.getItem("dynamic"));

		data = data || {};
		data.data = data.data || {};

		data.data["visit" + window.params.callNumber] = {
			slides: this.history,
			branches: app.dynamic.history
		};

		localStorage.setItem("dynamic", JSON.stringify(data));
	};

	global.Navigator = Navigator;
})(window);