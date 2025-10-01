({
    createNewQuickAction : function(component,eventData) {
        var actionAPI = component.find("quickActionAPI");
        var args = { actionName :eventData.quickActionName };
        actionAPI.selectAction(args).then(function(result) {
            component.set("v.spinner", false);
        }).catch(function(e) {
            if (e.errors) {
                alert('error'+JSON.stringify(e.errors))
                // If the specified action isn't found on the page,
                // show an error message in the my component
            }
        })
        
    }
})