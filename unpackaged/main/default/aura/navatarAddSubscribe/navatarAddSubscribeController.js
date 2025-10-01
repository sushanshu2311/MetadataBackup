({
    doInit : function(component, event, helper) {
        
    },
    
    handleChanged: function(cmp, event, helper) {
        cmp.set("v.spinner", true); 
        // Read the message argument to get the values in the message payload
        if (event != null && event.getParams() != null) {
            let params = event.getParams();
            helper.createNewQuickAction(cmp,params);
        }
    }
})