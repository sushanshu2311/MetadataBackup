({
	doInit: function (component, event, helper) {
        var recid = component.get("v.recordId");  //Created by anurag for resolving critical bug #34808
        component.set("v.taskType", recid.startsWith("00T") ? 'Task' : 'Event');
        let params = {};
        console.log('component.get("v.recordId")'+component.get("v.recordId"));
        params['recId'] = component.get("v.recordId");
        params['recType'] = component.get("v.taskType");
        params['mode'] = 'view';
        //Bug Id - 00045252 View_Interaction Fixed by Deepak Tab name change
        let url = '/lightning/n/navpeII_dev18__View_Interaction?c__params=' + JSON.stringify(params); //Changes for View Notes on blank screen Phase 3 CR
       // window.open(url, '_top');// For resolving critical bug 00034808
        window.open(url, '_blank');
        window.history.back();
     //   window.close();
    },
})