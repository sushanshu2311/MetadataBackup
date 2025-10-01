({
	doInit: function (component, event, helper) {
        var device = $A.get("$Browser.isPhone");
        component.set("v.isMobile", device);
        //alert('device'+device);
        if (device) {
            // var toastEvent = $A.get("e.force:showToast");
            // toastEvent.setParams({
            //     "title": "Information!",
            //     "message": "This functionality is not available on Android."
            // });
            // toastEvent.fire();
            component.set("v.redirectId", component.get("v.recordId"));
        }
        else {
        var pageReference = {
            type: 'standard__objectPage',
            attributes: {
                objectApiName: 'Task',
                actionName: 'new'
            },
            state: {
                c__redirectId: component.get("v.recordId"),
                c__actName : 'new',
                c__objectName : "Task",
                c__isRedirectToRecord : true,
                c__actName : 'NewTask',
                c__parentRecordId : component.get("v.recordId"),
                c__parentObjectName : component.get("v.sObjectName")
            }
        };
        var navService = component.find("navService");
        navService.navigate(pageReference);
        }
    },
})