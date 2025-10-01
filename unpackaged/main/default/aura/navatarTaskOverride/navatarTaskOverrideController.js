({
    doInit: function (component, event, helper) {
        
    //alert(window.location.href);
    var parts = window.location.href.replace(/[?&]+([^=&]+)=([^&]*)/gi,
        function (m, key, value) {
            if (key == 'c__redirectId') {
                component.set("v.redirectId", value);
            }
            if(key == 'c__taskType'){
                component.set("v.taskType", value);
            }
            if(key == 'c__recordId'){
                component.set("v.recordId", value);
            }
            if(key == 'c__isFollowup'){
                component.set("v.isFollowup", value);
            }
            if(key == 'c__isUtilityBar'){
                component.set("v.isUtilityBar", value);
            }
        });
    },
})