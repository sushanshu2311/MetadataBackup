/****************************************************************************************************

** Module Name : Clips

** Description : Used to handle logic to oen save clip popup

** Throws : NA

** Calls : NA

** Organization : Navatar Group

** Product Name & Version : Acuity

** Revision History:-

** Version    Date(YYYY-MM-DD)    Author         Description of Action

** 1.0        2022-08-02          Keyur

****************************************************************************************************/
({
    handelopenmodalclip : function(component, event, helper) {
        let modalHeader = 'Clip';
        if(event.getParam('clipName') != null && event.getParam('clipName') != ''){
            modalHeader = 'Edit Clip';
        }
        $A.createComponent("c:navatarClipAuraLwcCalling", {
            "objInfo" : event.getParam('objInfo'),
            "clipName" : event.getParam('clipName'),
            "clipSummary" : event.getParam('clipSummary'),
            "clipId" : event.getParam('clipId'),
        },
        function(content, status) {
            if (status === "SUCCESS") {
                var modalBody = content;
                component.find('overlayLib').showCustomModal({
                    header: modalHeader,
                    body : modalBody,
                    showCloseButton: true,
                    closeCallback: function() {}
                })
            }else{
            }
        });
    },

    navigateToEventScreen : function(component, event, helper) {
        $A.createComponent("c:navatarOpenEventReminder", {
            evtData :event.getParam('eventData')
        },
        function(content, status) {
            var modalBody = content;
            if (status === "SUCCESS") {
                component.find('overlayLib').showCustomModal({
                    header: "Meeting Started",
                    body:modalBody,
                    showCloseButton: true,
                    closeCallback: function() {
                    }
                })
            }
        });
	}
})