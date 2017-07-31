(function(global){
    "use strict";

    function getMousePos(event, canvas) {
        var rect = canvas.getBoundingClientRect(),
            mouseX = event.pageX - rect.left,
            mouseY = event.pageY - rect.top;

        return {
            x: mouseX,
            y: mouseY
        };
    }

    function DrawController(canvas, title, img){
        var that = this;
        this.title = title;
        this.canvas = canvas;
        this.context = this.canvas.getContext('2d');
        this.context.lineWidth = 5;
        this.context.strokeStyle = 'black';
        this.context.lineCap = 'round';
        this.img = img;
        this.renderImg();
        this.fillText();

        ['start', 'move', 'end'].forEach(function(eventName){
            that.canvas.addEventListener(touchy.events[eventName], that, false);
        });
    }

    DrawController.prototype.fillText = function(){
        this.context.fillStyle = "#646464";
        this.context.font = "normal 16px/20px HelveticaNeue";
        this.context.fillText(this.title.toUpperCase(), 20, 20);
    };

    DrawController.prototype.handleEvent = function(event){
        var type = event.type,
            position;

        event.stopPropagation();
        event.preventDefault();

        if(touchy.isTouch){
            event = event.changedTouches[0];
        }

        position = getMousePos(event, this.canvas);

        switch(type){
            case touchy.events.start:
                this.isDrawing = true;
                this.context.beginPath();
                this.context.lineJoin = 'round';
                this.context.moveTo(position.x, position.y);
                break;
            case touchy.events.move:
                if(this.isDrawing){
                    this.context.lineTo(position.x, position.y);
                    this.context.stroke();
                }
                break;
            case touchy.events.end:
                this.isDrawing = false;
                this.context.closePath();
                this.isDrawed = true;
                break;
        }
    };

    DrawController.prototype.clear = function(){
        this.isDrawed = false;
        this.isDrawing = false;
        this.context.clearRect(0, 0, this.canvas.width, this.canvas.height);
        this.fillText()
    };

    DrawController.prototype.renderImg = function(){
        if(this.img)
            this.context.drawImage(this.img,0,0);
    };

    DrawController.prototype.save = function(){
        var data = this.canvas.toDataURL("image/png");
        return data
    };

    window.DrawController = DrawController;
})(window);