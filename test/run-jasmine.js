var system = require('system');

/**
 * Wait until the test condition is true or a timeout occurs. Useful for waiting
 * on a server response or for a ui change (fadeIn, etc.) to occur.
 *
 * @param testFx javascript condition that evaluates to a boolean,
 * it can be passed in as a string (e.g.: "1 == 1" or "$('#bar').is(':visible')" or
 * as a callback function.
 * @param onReady what to do when testFx condition is fulfilled,
 * it can be passed in as a string (e.g.: "1 == 1" or "$('#bar').is(':visible')" or
 * as a callback function.
 * @param timeOutMillis the max amount of time to wait. If not specified, 3 sec is used.
 */
function waitFor(testFx, onReady, timeOutMillis) {
    var maxtimeOutMillis = timeOutMillis ? timeOutMillis : 3001, //< Default Max Timeout is 3s
        start = new Date().getTime(),
        condition = false,
        interval = setInterval(function() {
            if ( (new Date().getTime() - start < maxtimeOutMillis) && !condition ) {
                // If not time-out yet and condition not yet fulfilled
                condition = (typeof(testFx) === "string" ? eval(testFx) : testFx()); //< defensive code
            } else {
                if(!condition) {
                    // If condition still not fulfilled (timeout but condition is 'false')
                    console.log("'waitFor()' timeout");
                    phantom.exit(1);
                } else {
                    // Condition fulfilled (timeout and/or condition is 'true')
                    var head = "<!DOCTYPE HTML PUBLIC \"-//W3C//DTD HTML 4.01 Transitional//EN\"\n";
                    head += "\"http://www.w3.org/TR/html4/loose.dtd\">\n";
                    head += "<html><head>\n";
                    head += "<meta http-equiv=\"content-type\" content=\"text/html; charset=UTF-8\">\n";
                    head += "<link rel=\"stylesheet\" href=\"default.css\" type=\"text/css\">";
                    head += "<title>jasmine-result</title>\n";
                    head += "</head><body>\n";
                    head += "<div id=\"resultlist\">\n";
                    console.log(head);
                    console.log("<p>'waitFor()' finished in " + (new Date().getTime() - start) + "ms.</p>");
                    typeof(onReady) === "string" ? eval(onReady) : onReady(); //< Do what it's supposed to do once the condition is fulfilled
                    clearInterval(interval); //< Stop this interval
                }
            }
        }, 100); //< repeat check every 100ms
};


if (system.args.length !== 2) {
    console.log('Usage: run-jasmine.js URL');
    phantom.exit(1);
}

var page = require('webpage').create();


// Route "console.log()" calls from within the Page context to the main Phantom context (i.e. current "this")
page.onConsoleMessage = function(msg) {
    console.log(msg);
};

page.open(system.args[1], function(status){
    if (status !== "success") {
        console.log("Unable to access network");
        phantom.exit();
    } else {
        waitFor(function(){
            return page.evaluate(function(){
                //console.log(document.body.innerText);
                if (document.body.querySelector('.duration')) {
                    return true;
                }
                return false;
            });
        }, function(){
            page.evaluate(function() {
                console.log("<dl>\n");
                var specList = document.body.querySelectorAll('.specSummary');
                for (i = 0; i < specList.length; ++i) {
                    var element = specList[i];
                    if (element.classList[1] === "passed") {
                        console.log("<dt><font color=\"green\">passed:</font></dt><dd>" + element.querySelector('.description').title + "</dd>");
                    } else {
                        console.log("<dt><font color=\"red\">failed:</font></dt><dd>" + element.querySelector('.description').title + "</dd>");
                    }
                }
                console.log("</dl>\n");
 
                var passedList = document.body.querySelectorAll('.symbolSummary > .passed');
                var failedList = document.body.querySelectorAll('.symbolSummary > .failed');
                var spec = passedList.length + failedList.length;
                var message = "<p>" + spec + " spec | " + passedList.length + " passed / " + failedList.length + " failed</p>";
                console.log(message);
                
                var foot = "</div>\n";
                foot += "</body></html>";
                console.log(foot);
            });
            phantom.exit();
        });
    }
});
