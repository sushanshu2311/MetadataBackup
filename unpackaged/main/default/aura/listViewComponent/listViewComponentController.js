({
	doInit : function(component, event, helper) {
        var lst = component.get("v.obj_Listview");
        if(lst == undefined || lst == null || lst == ''){
            component.set("v.objectName",'Account');
            component.set("v.listViews",'AllAccounts');
        }else{
            component.set("v.objectName",lst.split(':')[0]);
        	component.set("v.listViews",lst.split(':')[1]);
        }
	}
})