(function(global){
	'use strict';

	function PopupViewPort(){
		var that = this;
		this.el = document.createElement('div');
		this.el.classList.add('popup');
		this.button = document.createElement('button');
		this.button.classList.add('close-button');
		this.button.addEventListener('click', this.close.bind(this));

		ViewPort.call(this, this.el);

		this.el.appendChild(this.button);
		document.body.appendChild(this.el);

		this.subscribe('viewAppeared', function(){
			that.el.classList.add('show');
		});

		this.subscribe('viewDisappeared', function(){
			document.body.removeChild(that.el);
		});
	};

	PopupViewPort.prototype = Object.create(ViewPort.prototype);
	PopupViewPort.prototype.constructor = PopupViewPort;
	PopupViewPort.prototype.super = ViewPort.prototype;

	PopupViewPort.prototype.goto = function(){
		if(!this.isPopupOpen){
			this.isPopupOpen = true;
			this.super.goto.apply(this, arguments);
		}
	};

	PopupViewPort.prototype.enter = function(){
		this.super.enter.apply(this, arguments);
		this.publish('viewAppeared');
	};

	PopupViewPort.prototype.close = function(){
		var that = this;
		if(this.isPopupOpen){
			this.el.classList.remove('show');
			this.dispatchTransitionEvent(this.el, function(){
				that.publish('viewDisappeared');
			})
			this.isPopupOpen = false;
			this.super.leave.apply(this, arguments);
		}
	};


	global.PopupViewPort = PopupViewPort;

})(window);