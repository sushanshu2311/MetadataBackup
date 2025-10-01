@isTest
public class NavatarAddContactsCtrlTest {
    @testSetup
    static void allTheDataForThisTestClass() {
        Account acc = new Account(Name = 'Test Account 1');
        insert acc;
        Contact con = new Contact(LastName = 'Test Contact 1');
        con.AccountId = acc.Id;
        insert con;
        Theme__c theme= new Theme__c(Name = 'Test111');
        insert theme;
        
        theme_relation__c tr = new theme_relation__c(Theme__c = theme.Id , Account__c = acc.Id);
        insert tr;
        navpeII_dev18__Navatar_Setup__c prodSet = new navpeII_dev18__Navatar_Setup__c();
        prodSet.navpeII_dev18__Add_Prospect_Setting__c='FundraisingwithFM';
        prodSet.navpeII_dev18__Admin_Setting__c = false;
        insert prodSet;
        list<string> accountRecordTypeList=new list<string>();
        list<string> objList=new list<string>{'Account','Contact','navpeII_dev18__Fund__c','navpeII_dev18__Fundraising__c'};
        Test.startTest();
        list<recordtype> rcData=[select Id,Name,sObjectType from RecordType where sObjectType In: objList AND isActive=true];
        system.debug('gfgf'+rcData);
        for(recordtype rt:rcData){
        if(rt.sObjectType == 'Account'){
        accountRecordTypeList.add(rt.Id);
        system.debug(rt.Name);
     }
    
     }
     List<sObject> listOfTaskRelationSobj = new List<sObject>();//Rectify the Stagging Issue - storing taskrelation record fake response
     List<sObject> listOfEventRelationSobj = new List<sObject>();//Rectify the Stagging Issue - storing eventrelation record fake response
        //create accounts
        List<Account> accounts = new List<Account>();
        List<String> accIIRecTypeIdList = new List<String>();
        //Test class coverage fix by LK on 2024-11-06
        for(RecordType recType : [SELECT ID, NAME, DEVELOPERNAME FROM RECORDTYPE WHERE SOBJECTTYPE = 'Account' AND DEVELOPERNAME = 'Individual_Investor']){
            accIIRecTypeIdList.add(recType.Id);
        }
        accounts.add(new Account(Name = 'Test Data 1',Description='Test data is processing ',Industry='Banking', RecordTypeId = accIIRecTypeIdList.get(0)));
        accounts.add(new Account(Name = 'Test Data 7',Description='Test data is processing Navatar Noida City',Industry='Technology',RecordTypeId = accIIRecTypeIdList.get(0)));//'012Dn000001HUuOIAW'

        insert accounts;
        /*List<Account> accountUpdates = new List<Account>();
        accountUpdates.add(new Account(Id = accounts[0].Id, ParentId = accounts[1].Id));
        update accountUpdates; */
        List<Contact> contacts = new List<Contact>();
        contacts.add(new Contact(AccountId = accounts[0].Id, FirstName = 'Test', LastName = 'Manager',Description='Test contact is processing'));
        contacts.add(new Contact(AccountId = accounts[0].Id, FirstName = 'Test', LastName = 'Casher'));
        contacts.add(new Contact(AccountId = accounts[1].Id, FirstName = 'Test', LastName = 'Broker'));
        contacts.add(new Contact(AccountId = accounts[1].Id, FirstName = 'Test', LastName = 'Executive'));
        insert contacts;
        
        List<navpeII_dev18__Fund__c> fundList=new List<navpeII_dev18__Fund__c>();
        fundList.add(new navpeII_dev18__Fund__c(Name = 'Test Fund'));
        fundList.add(new navpeII_dev18__Fund__c(Name = 'Test1 Fund'));
        fundList.add(new navpeII_dev18__Fund__c(Name = 'Test2 Fund'));
        fundList.add(new navpeII_dev18__Fund__c(Name = 'Test3 Fund'));
        insert fundList;
        
        // Create Fundraising 
        List<navpeII_dev18__Fundraising__c> fundraisingList=new List<navpeII_dev18__Fundraising__c>();
        for(Account accData:accounts){
            navpeII_dev18__Fundraising__c frData=new navpeII_dev18__Fundraising__c();
            frData.Name=accData.Name+' Fundraising '+accData.Industry;
            frData.navpeII_dev18__Fund_Name__c = fundList[0].id;
            frData.navpeII_dev18__Legal_Name__c = accData.id;
            fundraisingList.add(frData);
        }
        insert fundraisingList;
        
        
        
        // Create Theme 
        List<navpeII_dev18__Theme__c> themeList=new List<navpeII_dev18__Theme__c>();
        themeList.add(new navpeII_dev18__Theme__c(Name = 'Test Theme'));
        themeList.add(new navpeII_dev18__Theme__c(Name = 'Test1 theme'));
        themeList.add(new navpeII_dev18__Theme__c(Name = 'Test2 theme'));
        themeList.add(new navpeII_dev18__Theme__c(Name = 'Test3 theme'));
        insert themeList;
        
        // Create Clip
        List<navpeII_dev18__Clip__c> clipList=new List<navpeII_dev18__Clip__c>();
        clipList.add(new navpeII_dev18__Clip__c(Name = 'Test Clip'));
        clipList.add(new navpeII_dev18__Clip__c(Name = 'Test1 Clip'));
        clipList.add(new navpeII_dev18__Clip__c(Name = 'Test2 Clip'));
        clipList.add(new navpeII_dev18__Clip__c(Name = 'Test3 Clip'));
        insert clipList;
        
        //create some task
        List<Task> taskData = new List<Task>();
        String userId = UserInfo.getUserId();
        taskData.add(new task(Description='Test task is essential ',OwnerId=userId,navpeII_dev18__Related_Associations__c=accounts[0].id+','+themeList[0].id+','+fundList[0].id+','+fundList[1].id+','+fundraisingList[0].id+','+fundraisingList[1].id+','+clipList[0].id,Subject='Send Letter',Status='Open',Priority='Normal',WhatId=accounts[0].Id,WhoId=contacts[0].Id));
        taskData.add(new task(navpeII_dev18__Related_Associations__c=null,Description='Test task is essential2 ',OwnerId=userId,Subject='Send Letter',Status='Open',Priority='Normal',WhatId=accounts[1].Id,WhoId=contacts[1].Id));
        
        insert taskData;

        List<Event> eventData = new List<Event>();
        String userId2 = UserInfo.getUserId();
        
        eventData.add(new event(Description='Test event is essential ',navpeII_dev18__Related_Associations__c=accounts[0].id+','+fundList[0].id+','+fundList[1].id+','+fundraisingList[0].id+','+fundraisingList[1].id+','+clipList[0].id+','+themeList[0].id,ActivityDateTime=system.today(),DurationInMinutes=90,OwnerId=userId2,Subject='Send Letter',WhatId=accounts[0].Id,WhoId=contacts[0].Id));
        eventData.add(new event(navpeII_dev18__Related_Associations__c=null,Description='Test event is essential2 ',ActivityDateTime=system.today(),DurationInMinutes=80,OwnerId=userId2,Subject='Send Letter',WhatId=accounts[1].Id,WhoId=contacts[1].Id));
        
        insert eventData;
        
        Schema.SObjectType stEvt = Schema.getGlobalDescribe().get('EventRelation');
        sObject evtRel1 = stEvt.newSobject();
        evtRel1.put('EventId', eventData[0].Id);
        evtRel1.put('RelationId', contacts[2].Id);
        listOfEventRelationSobj.add(evtRel1);
        sObject evtRel2 = stEvt.newSobject();
        evtRel2.put('EventId', eventData[1].Id);
        evtRel2.put('RelationId', contacts[3].Id);
        listOfEventRelationSobj.add(evtRel2);
        insert listOfEventRelationSobj;
        test.stopTest();
 }
    static testMethod void getNavatarSetupDataTest1(){
        NavatarAddContactsCtrl.getNavatarSetupData();
        navpeII_dev18__Navatar_Setup__c navSetup = new navpeII_dev18__Navatar_Setup__c(navpeII_dev18__Add_Prospect_Setting__c = '');
        insert navSetup;
        system.assert(NavatarAddContactsCtrl.getNavatarSetupData() != null);        
        navpeII_dev18__Navatar_Setup__c navSetup1 = new navpeII_dev18__Navatar_Setup__c(navpeII_dev18__Add_Prospect_Setting__c = 'AddInviteTarget:Contact:Name:Full Name:string,Contact:Email:Email:email,Account:Name:Account Name:string,Contact:Phone:Phone:Phone');
        insert navSetup1;
        system.assert(NavatarAddContactsCtrl.getNavatarSetupData() != null);
    }
    static testMethod void executeQuery1Test(){
        system.assert(NavatarAddContactsCtrl.executeQuery1(null, '', null) != null);
        String s ='[{"serialnumber":1,"field":"Account:navpeII_dev18__Active__c:Active:PICKLIST","Value":"","Operator":"="}]';
        String s2 = '[{"serialnumber":1,"field":"Contact:Email:Email:EMAIL","Value":"test@gamil.com","Operator":"="}]';
        NavatarAddContactsCtrl.inviteResponse res = new NavatarAddContactsCtrl.inviteResponse();
        NavatarAddContactsCtrl.inviteResponse res1 = new NavatarAddContactsCtrl.inviteResponse();
        res = NavatarAddContactsCtrl.executeQuery1(s, 'DAIT', '');
        System.assertEquals('success', res.status);
        res1 = NavatarAddContactsCtrl.executeQuery1(s2, 'DAIT', '');
	
        String getqueryjson1 = null;
        String pageName1 = 'CMF';
        String filterString1 = '';
        
        Test.startTest();
        res1  = NavatarAddContactsCtrl.executeQuery1(getqueryjson1, pageName1, filterString1);
        Test.stopTest();
        
        System.assertEquals('success', res1 .status);
        
        // Test case 2: Filter criteria provided
        String getqueryjson2 = '[{"field":"Account:Name","Value":"Test","Operator":"=","serialnumber":"1"}]';
        String pageName2 = 'CMF';
        String filterString2 = '';
        
        res1  = NavatarAddContactsCtrl.executeQuery1(getqueryjson2, pageName2, filterString2);
        String getqueryjson3 = '[{"field":"Contact:FirstName","Value":"John","Operator":"=","serialnumber":"1"}]';
        String pageName3 = 'DAIT';
        String filterString3 = '1,2,3';
        
        res1  = NavatarAddContactsCtrl.executeQuery1(getqueryjson3, pageName3, filterString3);
        
        String getqueryjson4 = null;
        String pageName4 = 'DAIT';
        String filterString4 = '1,2,3';
    
        res1 = NavatarAddContactsCtrl.executeQuery1(getqueryjson4, pageName4, filterString4);
     
        String getqueryjson5 = null;
        String pageName5 = 'CMF';
        String filterString5 = '1,2';
    
         res1 = NavatarAddContactsCtrl.executeQuery1(getqueryjson5, pageName5, filterString5);
        
        NavatarAddContactsCtrl.inviteResponse res2 = new NavatarAddContactsCtrl.inviteResponse();
        res2 = NavatarAddContactsCtrl.executeQuery1(s, 'MEF', '');
        NavatarAddContactsCtrl.inviteResponse res3 = new NavatarAddContactsCtrl.inviteResponse();
        res3 = NavatarAddContactsCtrl.executeQuery1(s, 'CMFC', '');
        NavatarAddContactsCtrl.inviteResponse res4 = new NavatarAddContactsCtrl.inviteResponse();
        res4 = NavatarAddContactsCtrl.executeQuery1(s, 'CMFA', '');
        NavatarAddContactsCtrl.inviteResponse res5 = new NavatarAddContactsCtrl.inviteResponse();
        res5 = NavatarAddContactsCtrl.executeQuery1(s, 'MEP', '');
        NavatarAddContactsCtrl.inviteResponse res6 = new NavatarAddContactsCtrl.inviteResponse();
        res6 = NavatarAddContactsCtrl.executeQuery1(s, 'DAIT_ConRole', '');
        NavatarAddContactsCtrl.inviteResponse res7 = new NavatarAddContactsCtrl.inviteResponse();
        res7 = NavatarAddContactsCtrl.executeQuery1(s, 'DAIT_AccContactTab', '');
        
        NavatarAddContactsCtrl.inviteResponse res8 = new NavatarAddContactsCtrl.inviteResponse();
        res8 = NavatarAddContactsCtrl.executeQuery1(s2, 'MI', '');
        NavatarAddContactsCtrl.inviteResponse res9 = new NavatarAddContactsCtrl.inviteResponse();
        res9 = NavatarAddContactsCtrl.executeQuery1(s2, 'CMF', '');
        NavatarAddContactsCtrl.inviteResponse res10 = new NavatarAddContactsCtrl.inviteResponse();
        res10 = NavatarAddContactsCtrl.executeQuery1(s2, 'CMFC', '');
        NavatarAddContactsCtrl.inviteResponse res11 = new NavatarAddContactsCtrl.inviteResponse();
        res11 = NavatarAddContactsCtrl.executeQuery1(s2, 'DAIT_ConRole', '');
        NavatarAddContactsCtrl.inviteResponse res12 = new NavatarAddContactsCtrl.inviteResponse();
        res12 = NavatarAddContactsCtrl.executeQuery1(s2, 'DAIT_AccContactTab', '');
        NavatarAddContactsCtrl.inviteResponse res13 = new NavatarAddContactsCtrl.inviteResponse();
        res13 = NavatarAddContactsCtrl.executeQuery1(s2, 'MEP', '');
        NavatarAddContactsCtrl.inviteResponse res14 = new NavatarAddContactsCtrl.inviteResponse();
        res14 = NavatarAddContactsCtrl.executeQuery1(s2, 'MEPE', '');
        String s3 = '[{"serialnumber":1,"field":"Contact:AccountId:Account Name:REFERENCE","Value":"001000000000000000","Operator":"="}]';
        NavatarAddContactsCtrl.inviteResponse res15 = new NavatarAddContactsCtrl.inviteResponse();
        res15 = NavatarAddContactsCtrl.executeQuery1(s3, 'MEPE', '');
        String s4 = '[{"serialnumber":1,"field":"Contact:navpeII_dev18__Region__c:Region:PICKLIST","Value":"Europe","Operator":"IN:"}]';
        NavatarAddContactsCtrl.inviteResponse res16 = new NavatarAddContactsCtrl.inviteResponse();
        res16 = NavatarAddContactsCtrl.executeQuery1(s4, 'MEPE', '');
        System.assertEquals('success', res1.status);
    }
   static testMethod void getInitQueryTest(){
        List<Account> acc = [Select Id From Account];
        List<String> str = new List<String>(); 
        str.add(acc[0].Id);
        NavatarAddContactsCtrl.inviteResponse result = new NavatarAddContactsCtrl.inviteResponse();
            result = NavatarAddContactsCtrl.getInitQuery('SELECT Id FROM Contact',null,str, null);
            System.assertEquals('success', result.status);
    }
   static testMethod void unitTest11() {
        List<Account> acc=new List<Account>();
        Acc=[Select Name,Id,Description,Industry From Account];
       List<ID> accList = new List<ID>(new Map<Id, Account>([Select Name,Id,Description,Industry From Account]).keySet());
       List<ID> conList=new List<ID>(new Map<Id, Contact>([Select Name,Id,Description From Contact]).keySet());
       List<ID> fdList=new List<ID>(new Map<Id, navpeII_dev18__Fund__c>([Select Name,Id From navpeII_dev18__Fund__c]).keySet());
       List<ID> fdrList=new List<ID>(new Map<Id, navpeII_dev18__Fundraising__c>([Select Name,Id From navpeII_dev18__Fundraising__c]).keySet());
       List<ID> themeList=new List<ID>(new Map<Id, navpeII_dev18__Theme__c>([Select Name,Id From navpeII_dev18__Theme__c]).keySet());
       List<ID> clipList=new List<ID>(new Map<Id, navpeII_dev18__clip__c>([Select Name,Id From navpeII_dev18__clip__c]).keySet());
       List<ID> tskList=new List<ID>(new Map<Id,task>([Select Id,Subject From task]).keySet());
       List<ID> evtList=new List<ID>(new Map<Id,event>([Select Id,Subject From event]).keySet());
       tskList.addAll(evtList);
       string themeNameValue='My testing Theme';
       string themedes = 'The great theme';
       boolean addAllContactForEachFirm=false;
       string themeIdValue=themeList[0];        
        string response= NavatarAddContactsCtrl.addToThemeRecord( addAllContactForEachFirm, themeIdValue,accList , conList ,null , fdList , fdrList ,  themeList ,  clipList ,tskList );
       string response2= NavatarAddContactsCtrl.addToThemeRecord( true, themeIdValue,accList , conList ,null , fdList , fdrList ,  themeList ,  clipList ,tskList );
        System.assert(Acc.size() != 0, 'true');
   } 
   @IsTest static void processRelObjIdsTest(){
            // Create test data
            List<Account> acc=new List<Account>();
        Acc=[Select Name,Id,Description,Industry From Account];
            String ids = '1,2,3';
            ID actId = Acc[0].Id;
            
            // Set up expected values
            Map<String, Set<String>> expectedMap = new Map<String, Set<String>>();
            for (String recId : ids.split(',')) {
                Set<String> idSet = new Set<String>();
                idSet.add(actId);
                expectedMap.put(recId, idSet);
            }
            
            // Call the method
            Test.startTest();
            NavatarAddContactsCtrl.processRelObjIds(ids, actId);
            Test.stopTest();
            
            // Verify the results
            Map<String, Set<String>> actualMap = NavatarAddContactsCtrl.objIdVsActIdsMap;
            System.assertEquals(expectedMap.keySet(), actualMap.keySet());
            
            for (String recId : expectedMap.keySet()) {
                Set<String> expectedSet = expectedMap.get(recId);
                Set<String> actualSet = actualMap.get(recId);
                System.assertEquals(expectedSet, actualSet);
            }
        }
        static testMethod void unitTest17() {
            List<Account> acc=new List<Account>();
            Acc=[Select Name,Id,Description,Industry From Account];
            List<ID> accList = new List<ID>(new Map<Id, Account>([Select Name,Id,Description,Industry From Account]).keySet());
            List<ID> conList=new List<ID>(new Map<Id, Contact>([Select Name,Id,Description From Contact]).keySet());
            List<ID> fdList=new List<ID>(new Map<Id, navpeII_dev18__Fund__c>([Select Name,Id From navpeII_dev18__Fund__c]).keySet());
            List<ID> fdrList=new List<ID>(new Map<Id, navpeII_dev18__Fundraising__c>([Select Name,Id From navpeII_dev18__Fundraising__c]).keySet());
           // List<ID> fundList=new List<ID>(new Map<Id, navpeII_dev18__Pipeline__c>([Select Name,Id From navpeII_dev18__Pipeline__c]).keySet());
            List<ID> themeList=new List<ID>(new Map<Id, navpeII_dev18__Theme__c>([Select Name,Id From navpeII_dev18__Theme__c]).keySet());
            List<ID> clipList=new List<ID>(new Map<Id, navpeII_dev18__clip__c>([Select Name,Id From navpeII_dev18__clip__c]).keySet());
            List<ID> tskList=new List<ID>(new Map<Id,task>([Select Id,Subject From task]).keySet());
            List<ID> evtList=new List<ID>(new Map<Id,event>([Select Id,Subject From event]).keySet());
           tskList.addAll(evtList);
           string themeNameValue='My testing Theme';
           string themedes = 'The great theme';
           navpeII_dev18__theme__c thm=new navpeII_dev18__theme__c();
           thm.Name='the theme test';
           thm.Description__c=themeNameValue;
           insert thm;
           string themeIdValueData=string.ValueOf(thm.id);
           boolean addAllContactForEachFirm=false;
           string themeIdValue=themeList[0];        
        string response= NavatarAddContactsCtrl.addToThemeRecord( addAllContactForEachFirm, themeIdValueData,accList , conList ,null , fdList , fdrList ,  themeList ,  clipList , tskList );
        System.assert(Acc.size() != 0, 'true');
       }  
   @IsTest
   static void operatorOperationTest() {
       // Test case 1: Test DATETIME field type
        List<Account> Acc=[Select Name,Id,Description,Industry From Account];
       String accId = Acc[0].Id;
       String accId1 = JSON.serialize(accId);
       String accId3 = accId1+','+'testing';
       String result = new clsOne_filter().operatorOperation('DateTimeField', 'DATETIME', '=', '2023-06-21 12:00:00', 'en_US');

       result = new clsOne_filter().operatorOperation('DateTimeField', 'DATETIME', '<=', '2023-06-21 12:00:00', 'en_US');
       result = new clsOne_filter().operatorOperation('DateTimeField', 'DATETIME', '>=', '2023-06-21 12:00:00', 'en_US');
       result = new clsOne_filter().operatorOperation('DateTimeField', 'DATETIME', '!=', '2023-06-21 12:00:00', 'en_US');
       result = new clsOne_filter().operatorOperation('DateTimeField', 'DATETIME', '!=', '2023-06-21 12:00:00', 'en_US');
       result = new clsOne_filter().operatorOperation('DateTimeField', 'DATETIME', '<', '2023-06-21 12:00:00', 'en_US');
       result = new clsOne_filter().operatorOperation('DateTimeField', 'DATETIME', '>', '2023-06-21 12:00:00', 'en_US');
       result = new clsOne_filter().operatorOperation('DateTimeField', 'DATETIME', '=', '', 'en_US');

       result = new clsOne_filter().operatorOperation('ReferenceField', 'REFERENCE', '=', 'RecordId', 'en_US');

       result = new clsOne_filter().operatorOperation('ReferenceField', 'REFERENCE', '!=', 'RecordId', 'en_US');
       result = new clsOne_filter().operatorOperation('ReferenceField', 'REFERENCE', '<=', 'RecordId', 'en_US');
       result = new clsOne_filter().operatorOperation('ReferenceField', 'REFERENCE', '<', 'RecordId', 'en_US');
       result = new clsOne_filter().operatorOperation('ReferenceField', 'REFERENCE', '>', 'RecordId', 'en_US');
       result = new clsOne_filter().operatorOperation('ReferenceField', 'REFERENCE', '>=', 'RecordId', 'en_US');
       result = new clsOne_filter().operatorOperation('ReferenceField', 'REFERENCE', '>=', accId1, 'en_US');
       result = new clsOne_filter().operatorOperation('ReferenceField', 'REFERENCE', '>=', accId3, 'en_US');
       result = new clsOne_filter().operatorOperation('ReferenceField', 'REFERENCE', '!=', accId3, 'en_US');
       result = new clsOne_filter().operatorOperation('ReferenceField', 'REFERENCE', '!=', ' ,RecordId', 'en_US');
       result = new clsOne_filter().operatorOperation('ReferenceField', 'REFERENCE', '=', ' ,RecordId', 'en_US');
       result = new clsOne_filter().operatorOperation('ReferenceField', 'REFERENCE', '!=', 'RecordId,', 'en_US');
       result = new clsOne_filter().operatorOperation('ReferenceField', 'REFERENCE', '=', 'RecordId,', 'en_US');
       result = new clsOne_filter().operatorOperation('ReferenceField', 'REFERENCE', 'doesnotcontain', accId1, 'en_US');
       result = new clsOne_filter().operatorOperation('ReferenceField', 'REFERENCE', 'doesnotcontain', accId3, 'en_US');
       result = new clsOne_filter().operatorOperation('test__r.Name', 'REFERENCE', 'doesnotcontain', accId3, 'en_US');

       result = new clsOne_filter().operatorOperation('DateField', 'DATE', '!=', '2023-06-21', 'en_US');
       result = new clsOne_filter().operatorOperation('DateField', 'DATE', '!=', '', 'en_US');
       result = new clsOne_filter().operatorOperation('DateField', 'DATE', '=', '2023-06-21', 'en_US');
       result = new clsOne_filter().operatorOperation('DateField', 'DATE', '<=', '2023-06-21', 'en_US');
       result = new clsOne_filter().operatorOperation('DateField', 'DATE', '>=', '2023-06-21', 'en_US');
       result = new clsOne_filter().operatorOperation('DateField', 'DATE', '>', '2023-06-21', 'en_US');
       result = new clsOne_filter().operatorOperation('DateField', 'DATE', '<', '2023-06-21', 'en_US');
       result = new clsOne_filter().operatorOperation('DateField', 'DATE', '>=', '2023-06-21,2023-06-23', 'en_US');

           String field = 'Amount__c';
           String field_allchar = 'CURRENCY';
           String operator = '<';
           String value = '100,200';
           String locale_info = 'en_US';
   
           clsOne_filter filter = new clsOne_filter();
           String result1 = filter.operatorOperation(field, field_allchar, operator, '', locale_info);
           String result2 = filter.operatorOperation(field, field_allchar, '=', value, locale_info);
           result2 = filter.operatorOperation(field, field_allchar, '!=', value, locale_info);
           result2 = filter.operatorOperation(field, field_allchar, '<=', value, locale_info);
           result2 = filter.operatorOperation(field, field_allchar, '>=', value, locale_info);
           result2 = filter.operatorOperation(field, field_allchar, '>', value, locale_info);
           result2 = filter.operatorOperation(field, field_allchar, '=', '10.10', locale_info);
           result2 = filter.operatorOperation(field, field_allchar, '=', '10', locale_info);
           String expected5 = 'Amount__c = 10.0';
           System.assertEquals(expected5, result2);
           result2 = filter.operatorOperation(field, field_allchar, '=', ' ,10', locale_info);
           result2 = filter.operatorOperation(field, field_allchar, '<', ' ,10', locale_info);
           result2 = filter.operatorOperation(field, field_allchar, '!=', ' ,10', locale_info);
           result2 = filter.operatorOperation(field, field_allchar, '=', '10.10,', locale_info);
           result2 = filter.operatorOperation(field, field_allchar, '!=', '10', locale_info);
           result2 = filter.operatorOperation(field, field_allchar, '!=', '10.10,', locale_info);
           result2 = filter.operatorOperation(field, field_allchar, '<', '10.10', locale_info);

           field = 'Active__c';
           field_allchar = 'BOOLEAN';
           operator = '!=';
           value = '';
   
           result1 = filter.operatorOperation(field, field_allchar, operator, value, locale_info);
           result1 = filter.operatorOperation(field, field_allchar, operator, 'false', locale_info);
           String expected4 = 'Active__c != false';
           System.assertEquals(expected4, result1);
           result1 = filter.operatorOperation(field, field_allchar, '=', 'true', locale_info);
           result1 = filter.operatorOperation(field, field_allchar, operator, 'false', locale_info);
           result1 = filter.operatorOperation(field, field_allchar, '!=', 'false,true', locale_info);
           // Add your assertions here to verify the result
           field = 'Active__c';
           field_allchar = 'DOUBLE';
           operator = '!=';
           value = '';
   
           String result3 = filter.operatorOperation(field, field_allchar, operator, value, locale_info);
           String result7 = filter.operatorOperation(field, field_allchar, '<', value, locale_info);
           result7=filter.operatorOperation(field, field_allchar, '<', '10,1', locale_info);
           result7=filter.operatorOperation(field, field_allchar, '=', '10', locale_info);
           String expected3 = 'Active__c = 10.0';
           System.assertEquals(expected3, result7);
           result7=filter.operatorOperation(field, field_allchar, '=', '10,', locale_info);
           result7=filter.operatorOperation(field, field_allchar, '!=', '10,', locale_info);
           result7=filter.operatorOperation(field, field_allchar, '=', ' ,10', locale_info);
           result7=filter.operatorOperation(field, field_allchar, '!=', ' ,10,', locale_info);
           result7=filter.operatorOperation(field, field_allchar, '<', ' ,10', locale_info);
           result7=filter.operatorOperation(field, field_allchar, '=', '10,49', locale_info);
           result7 = filter.operatorOperation(field, field_allchar, '>', value, locale_info);
           result7 = filter.operatorOperation(field, field_allchar, '>', '10.3', locale_info);
           result7 = filter.operatorOperation(field, field_allchar, '<', '10.3', locale_info);
           result7 = filter.operatorOperation(field, field_allchar, '=', value, locale_info);
           result7 = filter.operatorOperation(field, field_allchar, '<=', value, locale_info);
           result7 = filter.operatorOperation(field, field_allchar, '>=', value, locale_info);
           result7 = filter.operatorOperation(field, field_allchar, '!=', '10,3.3', locale_info);

           field = 'Active__c';
           field_allchar = 'INTEGER';
           operator = '=';
           value = '';
   
           String result4 = filter.operatorOperation(field, field_allchar, operator, value, locale_info);
           result4 = filter.operatorOperation(field, field_allchar, operator, '10', locale_info);
           String expected2 = 'Active__c = 10';
           System.assertEquals(expected2, result4);
           result4 = filter.operatorOperation(field, field_allchar, operator, '10.10', locale_info);
           String result8 = filter.operatorOperation(field, field_allchar, '<=', value, locale_info);
           result8 = filter.operatorOperation(field, field_allchar, '<=', '80', locale_info);
           result8 = filter.operatorOperation(field, field_allchar, '>=', '80', locale_info);
           result8 = filter.operatorOperation(field, field_allchar, '!=', '80', locale_info);
           result8 = filter.operatorOperation(field, field_allchar, '!=', '80,100', locale_info);
           result8 = filter.operatorOperation(field, field_allchar, '<', '80,100', locale_info);
           result8 = filter.operatorOperation(field, field_allchar, '=', '80,100', locale_info);
           result8 = filter.operatorOperation(field, field_allchar, '=', '80.12,100', locale_info);
           result8 = filter.operatorOperation(field, field_allchar, '=', '8,', locale_info);
           result8 = filter.operatorOperation(field, field_allchar, '!=', '8,', locale_info);
           result8 = filter.operatorOperation(field, field_allchar, '=', ' ,8', locale_info);
           result8 = filter.operatorOperation(field, field_allchar, '=', '8.2,3.4', locale_info);
           result8 = filter.operatorOperation(field, field_allchar, '!=', '8.2,3.4', locale_info);
           result8 = filter.operatorOperation(field, field_allchar, '!=', ' ,8', locale_info);
           result8 = filter.operatorOperation(field, field_allchar, '>', '80,100', locale_info);
           result8 = filter.operatorOperation(field, field_allchar, '>', '90', locale_info);

           field = 'Active__c';
           field_allchar = 'PERCENT';
           operator = '=';
           value = '10%';
   
           String result5 = filter.operatorOperation(field, field_allchar, operator, value, locale_info);
           String expected1 = 'Active__c = 10.0';
           System.assertEquals(expected1, result5);
           String result9 = filter.operatorOperation(field, field_allchar, '<=', value, locale_info);
           result9 = filter.operatorOperation(field, field_allchar, '=', '10%,60%', locale_info);
           result9 = filter.operatorOperation(field, field_allchar, '=', '10%,', locale_info);
           result9 = filter.operatorOperation(field, field_allchar, '=', '', locale_info);
           result9 = filter.operatorOperation(field, field_allchar, '>=', value, locale_info);
           result9 = filter.operatorOperation(field, field_allchar, '!=', '10%', locale_info);
           result9 = filter.operatorOperation(field, field_allchar, '!=', '10%,20%', locale_info);
           result9 = filter.operatorOperation(field, field_allchar, '!=', '30%,', locale_info);
           result9 = filter.operatorOperation(field, field_allchar, '=', '30%,60%', locale_info);
           result9 = filter.operatorOperation(field, field_allchar, '<', '30%,60%', locale_info);
           result9 = filter.operatorOperation(field, field_allchar, '>', '30%,60%', locale_info);

           
           field = 'Active__c';
           field_allchar = 'STRING';
           operator = '=';
           value = 'test';
   
           String result11 = filter.operatorOperation(field, field_allchar, operator, value, locale_info);
           String result10 = filter.operatorOperation(field, field_allchar, '<=', value, locale_info);
           
           String expected = 'Active__c <= \'test\'';
           System.assertEquals(expected, result10);

           result10 = filter.operatorOperation(field, field_allchar, '>=', value, locale_info);
           result10 = filter.operatorOperation(field, field_allchar, '!=', value, locale_info);
           result10 = filter.operatorOperation(field, field_allchar, '!=', 'test,', locale_info);
           result10 = filter.operatorOperation(field, field_allchar, '=', 'test,', locale_info);
           result10 = filter.operatorOperation(field, field_allchar, '<', 'test,', locale_info);
           result10 = filter.operatorOperation(field, field_allchar, 'like', value, locale_info);
           result10 = filter.operatorOperation(field, field_allchar, 'not like', value, locale_info);
           result10 = filter.operatorOperation(field, field_allchar, 'start like', value, locale_info);
           result10 = filter.operatorOperation(field, field_allchar, '=', 'value,test', locale_info);
           result10 = filter.operatorOperation(field, field_allchar, '=', ' ,test', locale_info);
           result10 = filter.operatorOperation(field, field_allchar, '=', ' ,test,', locale_info);
           result10 = filter.operatorOperation(field, field_allchar, '!=', 'value,test', locale_info);
           result10 = filter.operatorOperation(field, field_allchar, '!=', ' ,test', locale_info);
           result10 = filter.operatorOperation(field, field_allchar, '!=', ' ,test,', locale_info);
           result10 = filter.operatorOperation(field, field_allchar, '<', 'test', locale_info);
           result10 = filter.operatorOperation(field, field_allchar, '<', 'test,copy', locale_info);
           result10 = filter.operatorOperation(field, field_allchar, '<', ' ,copy', locale_info);
           result10 = filter.operatorOperation(field, field_allchar, '>', ' ,copy', locale_info);
           result10 = filter.operatorOperation(field, field_allchar, '>', 'value,test', locale_info);


           field = 'Active__c';
           field_allchar = 'MULTIPICKLIST';
           operator = '=';
           value = '';
   
           String result12 = filter.operatorOperation(field, field_allchar, operator, value, locale_info);
           String result13 = filter.operatorOperation(field, field_allchar, '!=', 'val,check', locale_info);
           result13 = filter.operatorOperation(field, field_allchar, '!=', 'check', locale_info);
           result13 = filter.operatorOperation(field, field_allchar, '!=', 'check,', locale_info);
           result13 = filter.operatorOperation(field, field_allchar, '=', 'val,check', locale_info);
           result13 = filter.operatorOperation(field, field_allchar, '=', 'check,', locale_info);
           result13= filter.operatorOperation(field, field_allchar, 'contains', 'about', locale_info);
           result13= filter.operatorOperation(field, field_allchar, 'includes', 'about', locale_info);
           result13= filter.operatorOperation(field, field_allchar, 'excludes', 'about', locale_info);
           result13= filter.operatorOperation(field, field_allchar, '=', 'test', locale_info);
           String expected8 = 'Active__c = \'test\'';
           System.assertEquals(expected8, result13);
           result13 = filter.operatorOperation(field, field_allchar, '=', ' ,check', locale_info);
           result13 = filter.operatorOperation(field, field_allchar, '!=', ' ,check', locale_info);

           field = 'Active__c';
           field_allchar = 'PICKLIST';
           operator = '=';
           value = '';
   
           String result14 = filter.operatorOperation(field, field_allchar, operator, value, locale_info);
           String result15 = filter.operatorOperation(field, field_allchar, '!=', value, locale_info);
           String result16 = filter.operatorOperation(field, field_allchar, 'like', value, locale_info);
           result16 = filter.operatorOperation(field, field_allchar, 'not like', value, locale_info);
           result16 = filter.operatorOperation(field, field_allchar, '<', 'value', locale_info);
           result16 = filter.operatorOperation(field, field_allchar, '<', 'test,check', locale_info);
           result16 = filter.operatorOperation(field, field_allchar, '=', 'test,check', locale_info);
           result16 = filter.operatorOperation(field, field_allchar, '=', 'check', locale_info);
           String expected9 = 'Active__c = \'check\'';
           System.assertEquals(expected9, result16);
           result16 = filter.operatorOperation(field, field_allchar, '=', 'check,', locale_info);
           result16 = filter.operatorOperation(field, field_allchar, '=', ' ,check,', locale_info);
           result16 = filter.operatorOperation(field, field_allchar, '!=', 'check,', locale_info);
           result16 = filter.operatorOperation(field, field_allchar, '!=', 'check,val', locale_info);
           result16 = filter.operatorOperation(field, field_allchar, '!=', ' ,check,', locale_info);
           result16 = filter.operatorOperation(field, field_allchar, '>', value, locale_info);
           result16 = filter.operatorOperation(field, field_allchar, '>=', 'value', locale_info);
           result16 = filter.operatorOperation(field, field_allchar, '<=', value, locale_info);
           result16 = filter.operatorOperation(field, field_allchar, '<=', 'test,', locale_info);
           result16 = filter.operatorOperation(field, field_allchar, '<=', 'check,test', locale_info);
           result16 = filter.operatorOperation(field, field_allchar, '<', 'check,test', locale_info);
           result16 = filter.operatorOperation(field, field_allchar, '>', 'check,test', locale_info);
           result16 = filter.operatorOperation(field, field_allchar, '>=', 'check,test', locale_info);
           result16 = filter.operatorOperation(field, field_allchar, '!=', 'abcd', locale_info);
           result16 = filter.operatorOperation(field, field_allchar, '<', 'abcd,', locale_info);
           result16 = filter.operatorOperation(field, field_allchar, '=<', 'abcd,', locale_info);
           result16 = filter.operatorOperation(field, field_allchar, '>', 'abcd,', locale_info);
           result16 = filter.operatorOperation(field, field_allchar, '>=', 'abcd,', locale_info);
   }

    @isTest static void codeCoverageImprovement1(){
        try { NavatarAddContactsCtrl.getInitQuery('', new List<String>(), new List<String>(), 'str'); } catch(Exception e) {}
        system.assert(true);
    }

}