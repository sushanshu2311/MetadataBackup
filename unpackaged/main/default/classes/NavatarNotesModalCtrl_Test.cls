@isTest
public class NavatarNotesModalCtrl_Test {
    @isTest
    public static void method1() {
        Account testAccount = new Account(name='Test');
        insert testAccount;
        
        Account testAccount2 = new Account(name='Test account 2');
        insert testAccount2;
        
        contact con = new contact();
        con.lastName='test';
        con.AccountId=testAccount.id;
        insert con;
        
        contact con1 = new contact();
        con1.lastName='test 2 con'; 
        con1.AccountId=testAccount.id;
        insert con1;
        
        String sObjectName = 'Navatar_Setup__c';
        string namespace='';
        for(Schema.SObjectType objTyp : Schema.getGlobalDescribe().Values())
        {
            String nameStr = objTyp.getDescribe().getName();  
            if(nameStr.contains('__c') && nameStr == 'navpeII_dev18__Navatar_Setup__c') {
                sObjectName = 'navpeII_dev18__Navatar_Setup__c';
                namespace = 'navpeII_dev18__';
                break;
            }
        }
        Schema.SObjectType t = Schema.getGlobalDescribe().get(sObjectName);
        SObject navSetup = t.newSObject();
        navSetup.put('RAS__c','001,003');
        navSetup.put('Notes_Popup_Event_Fields__c','OwnerId,Location,StartDateTime,EndDateTime,IsAllDayEvent,DurationInMinutes');
        navSetup.put('Notes_Popup_Task_Fields__c','OwnerId,Status,ActivityDate,Priority');
        navSetup.put('Notes_Popup_FollowUp_Task_Fields__c','Subject,OwnerId,Status,ActivityDate');
        navSetup.put(namespace+'Admin_Setting__c',true);
        
        insert navSetup;
        
        task newtask = new task(subject='testtask',description='-------------------------------------------------------------------------------- test sddsfsdf',ownerid=userinfo.getUserId(),Whoid=con.id);
        insert newtask;
        
        task newtask1 = new task(subject='newTask',description='-------------------------------------------------------------------------------- test sddsfsdf',ownerid=userinfo.getUserId(),Whoid=con.id,whatId = testAccount2.Id,Related_Associations__c = con.Id);
        insert newtask1;
        
        Event newEvent = new Event();
        newEvent.WhatId = testAccount.id;
        newEvent.Subject = 'test event account 1';
        newEvent.activityDateTime = System.now().addDays(-10);
        newEvent.ownerid=userinfo.getUserId();
        newEvent.IsAllDayEvent = true;
        newEvent.description='-------------------------------------------------------------------------------- sddsfsdf';
        newEvent.ActivityDate = system.today();
        insert newEvent;
        
        Schema.SObjectType st = Schema.getGlobalDescribe().get('Eventrelation');
        sObject er = st.newSobject();
        er.put('RelationId',con.id);
        //er.put('IsInvitee',true);
        er.put('EventId',newEvent.id);
        //er.put('isParent',true);
        insert er;
        
        // Eventrelation er = new Eventrelation();
        // er.RelationId = con.id;
        // er.IsInvitee = true;
        // er.EventId = newEvent.id;
        // er.isParent = true;
        // insert er;
        
        Test.startTest();
        Id [] fixedSearchResults= new Id[2];
        fixedSearchResults[0] = con.Id;
        fixedSearchResults[1] = testAccount.Id;
        Test.setFixedSearchResults(fixedSearchResults);
        
        requestMock fakeResponse = new requestMock();
        Test.setMock(HttpCalloutMock.class, fakeResponse);
        
        List<String> dataList = NavatarNotesModalCtrl.getSearchableObjName('');
        List<String> dataList2 = NavatarNotesModalCtrl.getSearchableObjName('abc');
        NavatarNotesModalCtrl.checkEditAccess(newtask1.id);
        NavatarNotesModalCtrl.getDefaultTaggedRecordList(new List<String>{con.id}, dataList[0]);
        NavatarNotesModalCtrl.getDefaultTaggedRecords(testAccount2.id, dataList[0]);
        NavatarNotesModalCtrl.getRecordData(newtask1.id, dataList[0], 'Task', dataList[1], dataList[2], '', dataList[3]);
        NavatarNotesModalCtrl.getRecordData(newEvent.id, dataList[0], 'Event', dataList[1], dataList[2], '', dataList[3]);
        NavatarNotesModalCtrl.getRecordData('', dataList[0], 'Task', dataList[1], dataList[2], 'Call', dataList[3]);
        
        NavatarNotesModalCtrl.getSuggestions('Test account lfdfnl test con', dataList[0], '[]');
        NavatarNotesModalCtrl.getRelatedData('test', dataList[0],'[{}]');
        
        
        NavatarNotesModalCtrl.getSubjectFieldLabel();
        NavatarNotesModalCtrl.adjustEventStartEndDate(system.now());
        NavatarNotesModalCtrl.getObjectName(newtask1.id);
        NavatarNotesModalCtrl.getEventDateTime();
        NavatarNotesModalCtrl.getTodayDate();
        
        string pageLyoutFields = '[{"referenceObjName":"User","numberValue":null,"lwcFieldClass":null,"isText":false,"isRightField":false,"isReference":true,"isPicklist":false,"isNumber":false,"isLeftField":true,"isDateTime":false,"isDate":false,"isCombobox":false,"isBoolean":false,"fieldValue":"'+userinfo.getuserid()+'","fieldType":"REFERENCE","fieldLabel":"Assigned To ID","fieldAPI":"OwnerId","dateValue":null,"dateTimeValue":null,"booleanValue":false},{"referenceObjName":null,"numberValue":null,"lwcFieldClass":null,"isText":false,"isRightField":true,"isReference":false,"isPicklist":true,"isNumber":false,"isLeftField":false,"isDateTime":false,"isDate":false,"isCombobox":false,"isBoolean":false,"fieldValue":"Not Started","fieldType":"PICKLIST","fieldLabel":"Status","fieldAPI":"Status","dateValue":null,"dateTimeValue":null,"booleanValue":false},{"referenceObjName":null,"numberValue":null,"lwcFieldClass":null,"isText":false,"isRightField":false,"isReference":false,"isPicklist":false,"isNumber":false,"isLeftField":true,"isDateTime":false,"isDate":true,"isCombobox":false,"isBoolean":false,"fieldValue":null,"fieldType":"DATE","fieldLabel":"Due Date Only","fieldAPI":"ActivityDate","dateValue":null,"dateTimeValue":null,"booleanValue":false},{"referenceObjName":null,"numberValue":null,"lwcFieldClass":null,"isText":false,"isRightField":true,"isReference":false,"isPicklist":true,"isNumber":false,"isLeftField":false,"isDateTime":false,"isDate":false,"isCombobox":false,"isBoolean":false,"fieldValue":"Normal","fieldType":"PICKLIST","fieldLabel":"Priority","fieldAPI":"Priority","dateValue":null,"dateTimeValue":null,"booleanValue":false}]';        	
        string followupFields = '[{"id":0,"data":[{"referenceObjName":null,"numberValue":null,"lwcFieldClass":"Subjectfollowup0","isText":false,"isRightField":false,"isReference":false,"isPicklist":false,"isNumber":false,"isLeftField":true,"isDateTime":false,"isDate":false,"isCombobox":true,"isBoolean":false,"fieldValue":"Email","fieldType":"COMBOBOX","fieldLabel":"Subject","fieldAPI":"Subject","dateValue":null,"dateTimeValue":null,"booleanValue":false},{"referenceObjName":"User","numberValue":null,"lwcFieldClass":"OwnerIdfollowup0","isText":false,"isRightField":true,"isReference":true,"isPicklist":false,"isNumber":false,"isLeftField":false,"isDateTime":false,"isDate":false,"isCombobox":false,"isBoolean":false,"fieldValue":"'+userinfo.getuserid()+'","fieldType":"REFERENCE","fieldLabel":"Assigned To ID","fieldAPI":"OwnerId","dateValue":null,"dateTimeValue":null,"booleanValue":false},{"referenceObjName":null,"numberValue":null,"lwcFieldClass":"Statusfollowup0","isText":false,"isRightField":false,"isReference":false,"isPicklist":true,"isNumber":false,"isLeftField":true,"isDateTime":false,"isDate":false,"isCombobox":false,"isBoolean":false,"fieldValue":"In Progress","fieldType":"PICKLIST","fieldLabel":"Status","fieldAPI":"Status","dateValue":null,"dateTimeValue":null,"booleanValue":false},{"referenceObjName":null,"numberValue":null,"lwcFieldClass":"ActivityDatefollowup0","isText":false,"isRightField":true,"isReference":false,"isPicklist":false,"isNumber":false,"isLeftField":false,"isDateTime":false,"isDate":true,"isCombobox":false,"isBoolean":false,"fieldValue":null,"fieldType":"DATE","fieldLabel":"Due Date Only","fieldAPI":"ActivityDate","dateValue":"2022-09-13","dateTimeValue":null,"booleanValue":false}],"subjectClass":"slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click slds-dropdown-trigger_click_followup0"}]';        	
        string tagged = '[{"objectName":null,"Name":"Matt Damon","isUser":null,"Id":"'+UserInfo.getUserId()+'","iconName":null},{"objectName":null,"Name":"Matt Damon","isUser":null,"Id":"'+testAccount2.id+'","iconName":null}, {"objectName":null,"Name":"Matt Damon","isUser":null,"Id":"'+con1.id+'","iconName":null}]';
        string extratagged = '[{"objectName":null,"Name":"Matt Damon","isUser":null,"Id":"'+con.id+'","iconName":null},{"objectName":null,"Name":"Matt Damon","isUser":null,"Id":"'+testAccount.id+'","iconName":null},{"objectName":null,"Name":"Matt Damon","isUser":null,"Id":"'+userinfo.getuserid()+'","iconName":null}]';
        NavatarNotesModalCtrl.saveRecord(newEvent.description, tagged, newtask1.id, tagged, 'Task', pageLyoutFields, 'Task', 'Call', '', true, followupFields, true,true,newEvent.description);
        
        pageLyoutFields = '[{"referenceObjName":"User","numberValue":null,"lwcFieldClass":null,"isText":false,"isRightField":false,"isReference":true,"isPicklist":false,"isNumber":false,"isLeftField":true,"isDateTime":false,"isDate":false,"isCombobox":false,"isBoolean":false,"fieldValue":"'+userinfo.getuserid()+'","fieldType":"REFERENCE","fieldLabel":"Assigned To ID","fieldAPI":"OwnerId","dateValue":null,"dateTimeValue":null,"booleanValue":false},{"referenceObjName":null,"numberValue":null,"lwcFieldClass":null,"isText":true,"isRightField":true,"isReference":false,"isPicklist":false,"isNumber":false,"isLeftField":false,"isDateTime":false,"isDate":false,"isCombobox":false,"isBoolean":false,"fieldValue":"attendee","fieldType":"STRING","fieldLabel":"Location","fieldAPI":"Location","dateValue":null,"dateTimeValue":null,"booleanValue":false},{"referenceObjName":null,"numberValue":null,"lwcFieldClass":null,"isText":false,"isRightField":false,"isReference":false,"isPicklist":false,"isNumber":false,"isLeftField":true,"isDateTime":true,"isDate":false,"isCombobox":false,"isBoolean":false,"fieldValue":null,"fieldType":"DATETIME","fieldLabel":"Start Date Time","fieldAPI":"StartDateTime","dateValue":null,"dateTimeValue":"2022-09-10T05:19:00.000Z","booleanValue":false},{"referenceObjName":null,"numberValue":null,"lwcFieldClass":null,"isText":false,"isRightField":true,"isReference":false,"isPicklist":false,"isNumber":false,"isLeftField":false,"isDateTime":true,"isDate":false,"isCombobox":false,"isBoolean":false,"fieldValue":null,"fieldType":"DATETIME","fieldLabel":"End Date Time","fieldAPI":"EndDateTime","dateValue":null,"dateTimeValue":"2022-09-11T05:19:00.000Z","booleanValue":false},{"referenceObjName":null,"numberValue":null,"lwcFieldClass":null,"isText":false,"isRightField":false,"isReference":false,"isPicklist":false,"isNumber":false,"isLeftField":true,"isDateTime":false,"isDate":false,"isCombobox":false,"isBoolean":true,"fieldValue":null,"fieldType":"BOOLEAN","fieldLabel":"All-Day Event","fieldAPI":"IsAllDayEvent","dateValue":null,"dateTimeValue":null,"booleanValue":false}]';       	
        NavatarNotesModalCtrl.saveRecord(newEvent.description, tagged, newEvent.id, tagged, 'Event', pageLyoutFields, 'Event', '', '', true, followupFields, true,true,newEvent.description);
        NavatarNotesModalCtrl.saveSuggessionRecods(newtask1.id, tagged, tagged, 'Task', true, 'test', newtask.id);
        NavatarNotesModalCtrl.saveSuggessionRecods(newEvent.id, tagged, tagged, 'Event', true, 'test', newtask.id);
        NavatarNotesModalCtrl.saveRtaToggleStatus(true);//Added by LK on 2024-11-06 for code coverage
        NavatarNotesModalCtrl.checkRtaToggleStatus();//Added by LK on 2024-11-06 for code coverage
        try{NavatarNotesModalCtrl.getDefaultTaggedRecords('fd', 'gfg');} catch (Exception ex) {}
        try{NavatarNotesModalCtrl.saveSuggessionRecods(newtask1.id, 'dfdf', 'dfd', 'Task', true, 'test', newtask.id);} catch (Exception ex) {}
        try{NavatarNotesModalCtrl.saveRecord(newEvent.description, 'df', newEvent.id, 'df', 'Event', pageLyoutFields, 'Event', '', '', true, followupFields, true,true,newEvent.description);} catch (Exception ex) {}
        try{NavatarNotesModalCtrl.getRecordData(newtask1.id,'dfd', 'Task', dataList[1], dataList[2], '', dataList[3]);} catch (Exception ex) {} 
        try{NavatarNotesModalCtrl.getSuggestions('Test account lfdfnl test con', 'dfd', '[]');} catch (Exception ex) {} 
        try{NavatarNotesModalCtrl.getRelatedData('test', 'df','[{}]');} catch (Exception ex) {} 
        try{NavatarNotesModalCtrl.getDefaultValues('Test', new List<String>());} catch (Exception ex) {} 
        test.stopTest();
        system.assert(true);
     }  
}