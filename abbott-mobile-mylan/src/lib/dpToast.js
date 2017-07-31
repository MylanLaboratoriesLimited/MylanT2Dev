/*
    DP Toast jQuery Plugin, Version 1.1
    Copyright (C) Dustin Poissant 2014
    See http://htmlpreview.github.io/?https://github.com/dustinpoissant/jquery.dpToast/blob/master/License.html
    for more information reguarding usage.
*/
;(function($){
    var isPreviousToastHide = true;
    $.fn.dpToast = function(){
        var container;
        if( $("#dp-toasts").length < 1){
            $("body").append("<div id='dp-toasts'></div>");
            container = $("#dp-toasts");
            container[0].count = 0;
            container.css({
                position: "fixed",
                display: "inline-block",
                bottom: "20%",
                left: "0px",
                width: "100%",
                textAlign: "center",
                margin: "0 auto"
            });
        } else {
            container = $("#dp-toasts");
        }
        var message = "Error: No Toast Message";
        var timeout = 3000;
        for(var i=0; i<arguments.length; i++){
            if(typeof(arguments[i]) == "string" && arguments[i].length > 0) message = arguments[i];
            else if(typeof(arguments[i]) == "number") timeout = arguments[i];
        }
        if (isPreviousToastHide){
            container.prepend("<div class='dp-toast'><p>"+message+"</p></div>");
            var toast = $(".dp-toast");
            toast.css({
                display: "inline-block",
                backgroundColor: "rgba(0,0,0,0.9)",
                color: "white",
                padding: "10px 16px",
                borderRadius: "3px",
                margin: "5px auto",
                boxShadow: "0 0 5px rgba(0,0,0,0.5), 0 0 2px rgba(0,0,0,0.5)"
            });
            toast.hide().fadeIn();
            isPreviousToastHide = false;
            setTimeout(function(){
                isPreviousToastHide = true;
                toast.fadeOut(function(){
                    toast.remove();
                    if(container.children().size() == 0 ) container.remove();
                });
            }, timeout);
        }
    }
}(jQuery));