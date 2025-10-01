({
    doInit : function(component, event, helper) {
        //alert('test '+JSON.stringify(component.get('v.evtData')))
        
    },
    handleModalClose : function(component, event, helper) {

        component.find("overlayLib").notifyClose();

    },
    
    handleNavigateToNotesComponent : function(component,event,helper) {
        alert('inside'+component.get('v.evtData').evtId)
        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
            "recordId": component.get('v.evtData').evtId,
            "slideDevName": "detail"
        });
        navEvt.fire();
    }
    
})