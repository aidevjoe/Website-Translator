var Action = function() {};

Action.prototype = {
    
    run: function(arguments) {
        arguments.completionFunction({ "title": document.title, "URL": document.URL })
    },
    
    finalize: function(arguments) {}
};
    
var ExtensionPreprocessingJS = new Action
