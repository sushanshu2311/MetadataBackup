({
    onLoadHelper : function(component) {
        var currentObject ; 
        var localValueStore = [];
        var edgeMenuCompNameAccess = {Contact:"navatarCreateMenuContact",Account:"navatarCreateMenuFirm",navpeII_dev18__Pipeline__c:"navatarCreateMenuDeal"};// Nikita changes
        var getJsonAction = component.get("c.getJson");
        //start changes for utilityType by Aditya PEv4.7 on 19 April 2021
        var globalId = component.getGlobalId().replace(":", "");        
        component.set("v.cmpGlobalId",globalId);
        var expandLevels = 2; // for expanded view of navigation menu
        if(component.get("v.expandNavigationView") == 'False'){
            expandLevels = 1; // for collapsed view of navigtion menu
        }
        var navigationType = component.get("v.navigationType");
        getJsonAction.setParams({
            navigationType: navigationType
        });
        //end changes for utilityType by Aditya PEv4.7 on 19 April 2021
        $A.enqueueAction(getJsonAction);
        getJsonAction.setCallback(this, function(response) {
            
            var state = response.getState();
            if (state === "SUCCESS") {
                var responseObj = response.getReturnValue();
                // Create jqxTree
                var source = JSON.parse(responseObj.jsonStr);
                //var source = JSON.stringify(JSON.parse(responseObj.jsonStr),null,2); 
                var mapValue = responseObj.mapIdToUrl;
                
                var newMapIdToUrl = new Object();
                for ( var key in mapValue) {
                    newMapIdToUrl[key] = mapValue[key];
                }
                component.set("v.mapIdToURL2",newMapIdToUrl);
                var jq = jQuery('#treeview12'+globalId); // added globalId by Aditya PEv4.7 20 April 2021
                var tree = jq.treeview({ 
                    levels: expandLevels, // added by Aditya PEv4.7 on 27 April 2021
                    data: source,
                    onNodeSelected: function(event, node) {
                        localValueStore = node.id.split(',');
                        node.id = localValueStore[0];
                        currentObject = localValueStore[1];
                        //Expand collapse parent node on click
                        if(!node.parentId){
                            if(node.state.expanded){
                                jq.treeview('collapseNode', [ node.nodeId, { silent: true } ]); 
                            }else{
                                jq.treeview('expandNode', [ node.nodeId, { silent: false } ]);
                            }
                        }
                        
                        if(!component.get("v.flagCheck")){
                            component.set("v.flagCheck", true);
                            var clickedId = node.id; 
                            if(clickedId.startsWith('create<@>'))
                            {
                                debugger;
                                var flag = true;
                                var objectName = clickedId.split("<@>")[1];
                                var rtId;
                                var actBtnApiName;// Phase 3 CR:To store the button API name for Multi association popup.
                                
                                if(objectName.indexOf('<btnapi>') > 0){
                                    actBtnApiName = clickedId.split('<btnapi>')[1];
                                    objectName = objectName.split('<RT>')[0];
                                }
                                
                                if(clickedId.indexOf('<RT>') > 0){
                                    rtId = clickedId.split('<RT>')[1];
                                    objectName = objectName.split('<RT>')[0];
                                }
                                
                                //Phase 3 CR changes: get the button api and object label name.
                                if(objectName.indexOf('<btnapi>') > 0){
                                    actBtnApiName = objectName.split('<btnapi>')[1];
                                    objectName = objectName.split('<btnapi>')[0];
                                }
                                var createRecordEvent = $A.get("e.force:createRecord");
                                if(objectName == 'Task' && actBtnApiName != undefined){
                                    // change starts for Navigation Menu - New Call 
                                    if(actBtnApiName.split('<objlbl>')[0].toLowerCase() == 'New_Task_with_Multiple_Associations'.toLowerCase() || actBtnApiName.split('<objlbl>')[0].toLowerCase() =='Log_a_Call_with_Multiple_Associations'.toLowerCase()|| actBtnApiName.split('<objlbl>')[0].toLowerCase() =='New_Meeting'.toLowerCase()){ // for multitagged popup
                                        // added by Aditya on 26 July 2021 for 00029776 PEv4.7
                                        var componentName = "navpeII_dev18:"+"MultipleAssociationPopup";
                                        $A.createComponent(
                                            componentName,
                                            {
                                                "label":actBtnApiName.split('<objlbl>')[1],
                                                "recordTypeId":(rtId!=undefined?rtId:'012000000000000AAA'),
                                                "actName":actBtnApiName.split('<objlbl>')[0],
                                                "parentRecordId":'',
                                                "parentObjectName":'',
                                                "applyCss":'true'
                                            },
                                            function(msgBox){
                                                if(msgBox!= null){                                            
                                                    if (component.isValid()) {
                                                        var targetCmp = component.find('MultipleAssociationModal');
                                                        var body = targetCmp.get("v.body");
                                                        body.push(msgBox);
                                                        targetCmp.set("v.body", body); 
                                                        var utilityAPI = component.find("utilitybar");
                                                        var utilityId;
                                                        var panelHeight;
                                                        utilityAPI.getEnclosingUtilityId().then(function(response) {
                                                            utilityId = response;
                                                        });
                                                        
                                                        utilityAPI.getUtilityInfo(utilityId).then(function(response) {
                                                            panelHeight = response.panelHeight;
                                                            setTimeout(function(){
                                                                var element = document.getElementById("parentContainer");
                                                                element.classList.remove("slds-hide");
                                                                var centerPopup = document.getElementById('containerBody');
                                                                var centerPopupBody = document.getElementById('popupOpenId');
                                                                var popupHeight = centerPopupBody.clientHeight;
                                                                var popupWidth = centerPopup.clientWidth;
                                                                var windowWidth = window.innerWidth;
                                                                var windowHeight = window.screen.availHeight;
                                                                var remainingHeight = windowHeight - panelHeight;
                                                                centerPopup.style.top = (windowHeight/2-popupHeight/2)-remainingHeight+50+"px";
                                                                centerPopup.style.left= (windowWidth/2-popupWidth/2)-100+"px";
                                                                centerPopup.style.position = "fixed";
                                                            }, 1000);
                                                        });
                                                    }
                                                }
                                                else{
                                                    createRecordEvent.setParams({ "entityApiName": objectName,  "recordTypeId": rtId});
                                                    createRecordEvent.fire(); 
                                                }
                                            }
                                        ); 
                                    }else if(actBtnApiName.split('<objlbl>')[0].toLowerCase() == 'QuickNote_Task'.toLowerCase()){ // for standard call with tasksubtype=Call
                                        var pageReference = {
                                            type: 'standard__objectPage',
                                            attributes: {
                                                objectApiName: 'Task',
                                                actionName: 'new'
                                            },
                                            state: {
                                                c__redirectId: component.get("v.recordId"),
                                                c__isUtilityBar : true
                                            }
                                            
                                        };
                                        var navService = component.find("navService");
                                        // Uses the pageReference definition in the init handler
                                        //var pageReference = cmp.get("v.pageReference");
                                        event.preventDefault(); 
                                        navService.navigate(pageReference);
                                         
                                    }else if(actBtnApiName.split('<objlbl>')[0].toLowerCase() == 'QuickNote_Call'.toLowerCase()){ // for standard call with tasksubtype=Call
                                        var pageReference;
                                        var pageReference = {
                                            type: 'standard__objectPage',
                                            attributes: {
                                                objectApiName: 'Task',
                                                actionName: 'new'
                                            },
                                            state: {
                                                c__redirectId: component.get("v.recordId"),
                                                c__taskType: 'Call',
                                                c__isUtilityBar : true
                                            }
                                            
                                        }; 
                                        var navService = component.find("navService");
                                        // Uses the pageReference definition in the init handler
                                        //var pageReference = cmp.get("v.pageReference");
                                        event.preventDefault(); 
                                        navService.navigate(pageReference);
                                        
                                    }else if(actBtnApiName.split('<objlbl>')[0].toLowerCase() == 'LogACall'.toLowerCase()){ // for standard call with tasksubtype=Call
                                        var today = new Date();
                                        var dd = String(today.getDate()).padStart(2, '0');
                                        var mm = String(today.getMonth() + 1).padStart(2, '0'); //January is 0!
                                        var yyyy = today.getFullYear();
                                        today = yyyy + '-' + mm + '-' + dd;
                                        var activityDate = today.toString();
                                        createRecordEvent.setParams({
                                            "entityApiName": objectName, 
                                            "recordTypeId": rtId,
                                            "defaultFieldValues": {
                                                'TaskSubtype' : 'Call',
                                                'Subject' : 'Call',
                                                'Status' : 'Completed',
                                                'ActivityDate' : activityDate
                                            }
                                        });
                                        createRecordEvent.fire();  
                                    }
                                }
                                else if(objectName == 'Event' && actBtnApiName != undefined){
                                    if(actBtnApiName.split('<objlbl>')[0].toLowerCase() == 'QuickNote_Event'.toLowerCase()){ // for standard call with tasksubtype=Call
                                        var pageReference = {
                                            type: 'standard__objectPage',
                                            attributes: {
                                                objectApiName: 'Event',
                                                actionName: 'new'
                                            },
                                            state: {
                                                c__redirectId: component.get("v.recordId"),
                                                c__isUtilityBar : true
                                            }
                                            
                                        }; 
                                        var navService = component.find("navService");
                                        // Uses the pageReference definition in the init handler
                                        //var pageReference = cmp.get("v.pageReference");
                                        event.preventDefault(); 
                                        navService.navigate(pageReference);
                                    }
                                   
                                }
                                // change ends for Navigation Menu - New Call
                                else if(clickedId.indexOf('<RT>') > 0){                                    
                                    createRecordEvent.setParams({ "entityApiName": objectName,  "recordTypeId": rtId});
                                    createRecordEvent.fire();  
                                }
                                    else{
                                    var utilityAPI = component.find("utilitybar");
                                    var utilityId;
                                    var panelHeight;
                                    utilityAPI.getEnclosingUtilityId().then(function (response) {
                                        utilityId = response;
                                    });
                                        
                                    utilityAPI.getUtilityInfo(utilityId).then(function (response) {
                                        panelHeight = response.panelHeight;
                                        component.find('newRecordTypeComp').openNewRecordPopup({ "entityApiName": objectName }, flag, panelHeight + 50); //Added by Jonson
                                    });
                                        
                                    //component.find('newRecordTypeComp').openNewRecordPopup(objectName , flag);
                                }
                            }else if (['navpeII_dev18__Pipeline__c', 'Account', 'Contact'].includes(currentObject)) {
                              
                                    if(node.isLWCInvoked) {
                                        var compName = 'navpeII_dev18:'+edgeMenuCompNameAccess[currentObject];// Nikita changes;
                                       
                                        $A.createComponent(compName,
                                                            {
                                                            },
                                        function(content, status) {
                                            if (status === "SUCCESS") {
                                              
                                                var modalBody = content;
                                                component.find('overlayLib').showCustomModal({
                                                    header: 'New '+node.text,
                                                    body: modalBody, 
                                                    showCloseButton: true,
                                                    closeCallback: function(ovl) {
                                                    }
                                                }).then(function(overlay){
                                                    var utilityAPI = component.find("utilitybar");
                                                    utilityAPI.minimizeUtility();
                                                });
                                            }
                                        });
                                    
                                    } 
                                    
                                
                            }else
                            {
                                 
                                var mapUrl = component.get("v.mapIdToURL2");
                                if(mapUrl[clickedId]){
                                    var urlEvent = $A.get("e.force:navigateToURL");
                                    urlEvent.setParams({
                                        "url": mapUrl[clickedId]
                                    });
                                    urlEvent.fire();
                                    
                                    // code for minimize utility bar.
                                    var utilityAPI = component.find("utilitybar");
                                    utilityAPI.minimizeUtility();
                                }
                            }
                            
                            window.setTimeout(
                                $A.getCallback(function() {	
                                    component.set("v.flagCheck", false);
                                    //To perform operation even if user clicks on a node which is already selected
                                    jq.treeview('unselectNode', [ node.nodeId, { silent: true } ]);
                                }), 100
                            );
                        }
                    },
                    
                    //START-Added to collapse all other nodes on expanding a node ~Akash
                    onNodeExpanded: function (event, node) {
                        jq.treeview('collapseAll', { silent: true }); 
                        jq.treeview('expandNode', [ node.nodeId, { silent: true } ]); 
                        
                    }
                    //END
                });
            }
        });
        
    }
})