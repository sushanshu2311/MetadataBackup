//Developer By Ehatsham 1 dec 2022
@isTest
public with sharing class NavatarResearchCtrlTest {
    @testSetup
    static void allTheDataForThisTestClass() {
        navpeII_dev18__ProductSetting__c prodSet = new navpeII_dev18__ProductSetting__c();
        prodSet.Name='FundraisingwithFM';
        prodSet.navpeII_dev18__Status__c = false;
        insert prodSet;
        list<string> accountRecordTypeList=new list<string>();
        list<string> objList=new list<string>{'Account','Contact','navpeII_dev18__Pipeline__c','navpeII_dev18__Fund__c','navpeII_dev18__Fundraising__c'};
    Test.startTest();
            list<recordtype> rcData=[select Id,Name,sObjectType from RecordType where sObjectType In: objList AND isActive=true];
    system.debug('gfgf'+rcData);
    for(recordtype rt:rcData){
    if(rt.sObjectType == 'Account'){
    accountRecordTypeList.add(rt.Id);
    system.debug(rt.Name);
    }
    /*if(rt.sObjectType == 'Contact'){
    contactRecordTypeList.add(rt);
    }
    if(rt.sObjectType == 'navpeII_dev18__Pipeline__c'){
    dealRecordTypeList.add(rt);
    }
    if(rt.sObjectType == 'navpeII_dev18__Fund__c'){
    fundRecordTypeList.add(rt);
    }
    if(rt.sObjectType == 'navpeII_dev18__Fundraising__c'){
    fundraisingRecordTypeList.add(rt);
    }*/
    
    }
    List<sObject> listOfTaskRelationSobj = new List<sObject>();//Rectify the Stagging Issue - storing taskrelation record fake response
    List<sObject> listOfEventRelationSobj = new List<sObject>();//Rectify the Stagging Issue - storing eventrelation record fake response
        //create accounts
        List<Account> accounts = new List<Account>();
        accounts.add(new Account(Name = 'Test Data 1',Description='Test data is processing ',Industry='Banking'));
        accounts.add(new Account(Name = 'Test Data 2',Description='Test data is processing Navatar System ',Industry='Finance',RecordTypeId=((accountRecordTypeList.size() > 1) ? accountRecordTypeList[2] : null )));//'012Dn000001HUuMIAW'
        accounts.add(new Account(Name = 'Test Data 3',Description='Test data is processing Navatar Noida City',Industry='Technology',RecordTypeId=((accountRecordTypeList.size() > 0) ? accountRecordTypeList[1] : null )));//'012Dn000001HUuOIAW'
        accounts.add(new Account(Name = 'Test Data 4',Description='Test data is processing Navatar System ',Industry='Finance',RecordTypeId=((accountRecordTypeList.size() > 2) ? accountRecordTypeList[3] : null )));//'012Dn000001HUuMIAW'
        accounts.add(new Account(Name = 'Test Data 5',Description='Test data is processing Navatar Noida City',Industry='Technology',RecordTypeId=((accountRecordTypeList.size() > 3) ? accountRecordTypeList[4] : null )));//'012Dn000001HUuOIAW'
        accounts.add(new Account(Name = 'Test Data 6',Description='Test data is processing Navatar System ',Industry='Finance',RecordTypeId=((accountRecordTypeList.size() > 4) ? accountRecordTypeList[5] : null )));//'012Dn000001HUuMIAW'
        accounts.add(new Account(Name = 'Test Data 7',Description='Test data is processing Navatar Noida City',Industry='Technology',RecordTypeId=((accountRecordTypeList.size() > 0) ? accountRecordTypeList[0] : null )));//'012Dn000001HUuOIAW'

        
        insert accounts;
        //update accounts in order to create a relationship
        List<Account> accountUpdates = new List<Account>();
        accountUpdates.add(new Account(Id = accounts[0].Id, ParentId = accounts[1].Id));
        accountUpdates.add(new Account(Id = accounts[1].Id, ParentId = accounts[2].Id));
        update accountUpdates; 
        //create some contacts 
        List<Contact> contacts = new List<Contact>();
        contacts.add(new Contact(AccountId = accounts[0].Id, FirstName = 'Test', LastName = 'Manager',Description='Test contact is processing'));
        contacts.add(new Contact(AccountId = accounts[0].Id, FirstName = 'Test', LastName = 'Casher'));
        contacts.add(new Contact(AccountId = accounts[1].Id, FirstName = 'Test', LastName = 'Broker'));
        contacts.add(new Contact(AccountId = accounts[1].Id, FirstName = 'Test', LastName = 'Executive'));
        insert contacts;
        
        // Create Deal
        List<navpeII_dev18__Pipeline__c> dealList=new List<navpeII_dev18__Pipeline__c>();
        for(Account dataAcc:accounts){
            navpeII_dev18__Pipeline__c dealData=new navpeII_dev18__Pipeline__c();
            dealData.Name=dataAcc.Name+' Deal '+dataAcc.Industry;
            dealList.add(dealData);
        }
        insert dealList;
        
        // Create Fund
        List<navpeII_dev18__Fund__c> fundList=new List<navpeII_dev18__Fund__c>();
        fundList.add(new navpeII_dev18__Fund__c(Name = 'Test Fund', navpeII_dev18__Fund_Type__c='Fund', navpeII_dev18__Investment_Category__c='Fund'));
        fundList.add(new navpeII_dev18__Fund__c(Name = 'Test1 Fund', navpeII_dev18__Fund_Type__c='Fund', navpeII_dev18__Investment_Category__c='Fund'));
        fundList.add(new navpeII_dev18__Fund__c(Name = 'Test2 Fund', navpeII_dev18__Fund_Type__c='Fund', navpeII_dev18__Investment_Category__c='Fund'));
        fundList.add(new navpeII_dev18__Fund__c(Name = 'Test3 Fund', navpeII_dev18__Fund_Type__c='Fund', navpeII_dev18__Investment_Category__c='Fund'));
        insert fundList;
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
        taskData.add(new task(Description='Test task is essential ',OwnerId=userId,Related_Associations__c=accountUpdates[0].id+','+accountUpdates[1].id+','+themeList[0].id+','+dealList[0].id+','+dealList[1].id+','+fundList[0].id+','+fundList[1].id+','+clipList[0].id,Subject='Send Letter',Status='Open',Priority='Normal',WhatId=accounts[0].Id,WhoId=contacts[0].Id));
        taskData.add(new task(Description='Test task is essential2 ',OwnerId=userId,Subject='Send Letter',Status='Open',Priority='Normal',WhatId=accounts[1].Id,WhoId=contacts[1].Id));
        //taskData.add(new task(Description='Test task is essential2 ',OwnerId=userId,Subject='Send Letter',Status='Open',Priority='Normal',WhatId=accounts[1].Id,WhoId=userId));
        insert taskData;
        /*Schema.SObjectType stTsk = Schema.getGlobalDescribe().get('TaskRelation');
        sObject tskRel1 = stTsk.newSobject();
        tskRel1.put('TaskId', taskData[0].Id);
        tskRel1.put('RelationId', contacts[3].Id);
        listOfTaskRelationSobj.add(tskRel1);
        
        sObject tskRel2 = stTsk.newSobject();
        tskRel2.put('TaskId', taskData[1].Id);
        tskRel2.put('RelationId', contacts[2].Id);
        listOfTaskRelationSobj.add(tskRel2);
        //sObject tskRel3 = stTsk.newSobject();
        //tskRel3.put('TaskId', taskData[2].Id);
        //tskRel3.put('RelationId', userId);
        //listOfTaskRelationSobj.add(tskRel3);
        insert listOfTaskRelationSobj;*/

        List<Event> eventData = new List<Event>();
        String userId2 = UserInfo.getUserId();
        
        eventData.add(new event(Description='Test event is essential ',Related_Associations__c=accountUpdates[0].id+','+accountUpdates[1].id+','+dealList[0].id+','+dealList[1].id+','+fundList[0].id+','+fundList[1].id+','+clipList[0].id+','+themeList[0].id,ActivityDateTime=system.today(),DurationInMinutes=90,OwnerId=userId2,Subject='Send Letter',WhatId=accounts[0].Id,WhoId=contacts[0].Id));
        eventData.add(new event(Description='Test event is essential2 ',ActivityDateTime=system.today(),DurationInMinutes=80,OwnerId=userId2,Subject='Send Letter',WhatId=accounts[1].Id,WhoId=contacts[1].Id));
        //eventData.add(new event(Description='Test event is essential2 ',ActivityDateTime=system.today(),DurationInMinutes=80,OwnerId=userId2,Subject='Send Letter',WhatId=accounts[1].Id,WhoId=userId2));
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
        //sObject evtRel3 = stEvt.newSobject();
        //evtRel3.put('EventId', eventData[2].Id);
        //evtRel3.put('RelationId', userId);
        //listOfEventRelationSobj.add(evtRel3);
        insert listOfEventRelationSobj;
        Test.stopTest();
            }
    static testMethod void unitTest1() {
        List<Account> acc=new List<Account>();
        List<Contact> con=new List<Contact>();
        List<Task> tk=new List<Task>();
        List<Event> et=new list<Event>();
        Test.startTest();
        Acc=[Select Name,Id,Description,Industry From Account];
        Con=[Select Name,Id,Description From Contact];
        tk=[Select OwnerId,Subject,WhatId,WhoId,Related_Associations__c From Task];
        et=[Select OwnerId,Subject,WhatId,WhoId,Related_Associations__c From Event];
        ContentVersion contentVersion = new ContentVersion(
            Title = 'Penguins Test Data Sosl',
            PathOnClient = 'Test.txt',
            VersionData = Blob.valueOf('Test Content Test Data "Test1data" "test2data" Test,Data Test-Data test'),
            IsMajorVersion = true
        );
        insert contentVersion;    
        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
        
       
        List<ContentDocumentLink> cdl = New List<ContentDocumentLink>();
        cdl.add(new ContentDocumentLink(LinkedEntityId = Acc[0].id,ContentDocumentId=documents[0].Id,shareType = 'V'));
        cdl.add(new ContentDocumentLink(LinkedEntityId = Acc[1].id,ContentDocumentId=documents[0].Id,shareType = 'V'));
        cdl.add(new ContentDocumentLink(LinkedEntityId = con[0].id,ContentDocumentId=documents[0].Id,shareType = 'V'));
        cdl.add(new ContentDocumentLink(LinkedEntityId = con[1].id,ContentDocumentId=documents[0].Id,shareType = 'V'));
       
        insert cdl;

    
    string queryForFile;
        queryForFile = 'FIND '+'{Test}'+' IN ALL FIELDS RETURNING ContentDocument (Id ORDER BY Title)';
    system.debug(queryForFile+'####queryForFile');    
      List<ContentDocument> fileSearchDataList=new List<ContentDocument>();
    List<Search.SearchResult> searchResultFilelist=new List<Search.SearchResult>();
    Search.SearchResults searchResultsFile = Search.find(queryForFile,AccessLevel.USER_MODE);
    searchResultFilelist= searchResultsFile.get('ContentDocument');
    for(Search.SearchResult sr:searchResultFilelist){
    ContentDocument fileRec = (ContentDocument) sr.getSObject();
    System.debug('####fileSearchDataList'+fileRec);
    fileSearchDataList.add(fileRec);
    }
        List<List<SObject>> searchList = [FIND 'Test' 
                                          IN ALL FIELDS RETURNING 
                                          Account(Id, Name,Description)];
        NavatarResearchCtrl.innerStructureWrapper kl1=new NavatarResearchCtrl.innerStructureWrapper();
        kl1 = NavatarResearchCtrl.getSearchResultListWithAdvance(null,
                                                                 null,
                                                                 'Name,Summary__c','Name,Description__c',
                                                                 'Name,navpeII_dev18__Legal_Name__c , navpeII_dev18__Legal_Name__r.Name,navpeII_dev18__Status_Notes__c',
                                                                 'Name,navpeII_dev18__Vintage_Year__c','Name,Description, RecordType.Name','Name,AccountId ,Account.Name,Description',
                                                                 'Name,navpeII_dev18__Stage__c,navpeII_dev18__Pipeline_Comments__c','Test','comingFromChild1');
        Test.stopTest();
        System.assertEquals(Acc.size() , 14);
    }
    static testMethod void unitTest2() {
        List<Account> acc=new List<Account>();
        List<Contact> con=new List<Contact>();
        List<navpeII_dev18__Fund__c> fundList=new List<navpeII_dev18__Fund__c>();
        List<navpeII_dev18__Fundraising__c> fundraisingList=new List<navpeII_dev18__Fundraising__c>();
        List<Theme__c> themeList=new List<Theme__c>();
        List<clip__c> clipList=new List<clip__c>();
        List<Task> tk=new List<Task>();
        List<Event> et=new list<Event>();
        List<navpeII_dev18__Pipeline__c> dealList=new List<navpeII_dev18__Pipeline__c>();
        
        et=[Select OwnerId,Subject,WhatId,WhoId,Related_Associations__c From Event];
        Acc=[Select Name,Id,Description,Industry From Account];
        Con=[Select Name,Id,Description From Contact];
        dealList=[Select Name,Id From navpeII_dev18__Pipeline__c];
        fundList=[Select Name,Id From navpeII_dev18__Fund__c];
        fundraisingList=[Select Name,Id From navpeII_dev18__Fundraising__c];
        themeList=[Select Name,Id From Theme__c];
        clipList=[Select Name,Id From clip__c];
        tk=[Select OwnerId,Subject,WhatId,WhoId,Related_Associations__c From Task];
        list<Theme_Relation__c> trList=new list<Theme_Relation__c>();
         trList.add(new Theme_Relation__c(Contact__c=Con[0].id,theme__c=themeList[0].id));
         trList.add(new Theme_Relation__c(Account__c=acc[0].id,theme__c=themeList[0].id));
        trList.add(new Theme_Relation__c(Fund__c=fundList[0].id,theme__c=themeList[0].id));
        //trList.add(new Theme_Relation__c(Fundraising__c=fundraisingList[0].id,theme__c=themeList[0].id));
        trList.add(new Theme_Relation__c(Deal__c=dealList[0].id,theme__c=themeList[0].id));
        trList.add(new Theme_Relation__c(Clip__c=clipList[0].id,theme__c=themeList[0].id));
        insert trList;
         list<Clip_Relation__c> crList=new list<Clip_Relation__c>();
         crList.add(new Clip_Relation__c(Contact__c=Con[0].id,clip__c=clipList[0].id));
         crList.add(new Clip_Relation__c(Account__c=acc[0].id,clip__c=clipList[0].id));
        crList.add(new Clip_Relation__c(Fund__c=fundList[0].id,clip__c=clipList[0].id));
        //crList.add(new Clip_Relation__c(Fundraising__c=fundraisingList[0].id,clip__c=clipList[0].id));
        crList.add(new Clip_Relation__c(Deal__c=dealList[0].id,clip__c=clipList[0].id));
       
        insert crList;
        NavatarResearchCtrl.innerStructureWrapper kl1=new NavatarResearchCtrl.innerStructureWrapper();
        NavatarResearchCtrl.columnListWrapper kl2=new NavatarResearchCtrl.columnListWrapper();
        NavatarResearchCtrl.referenceRecordWrapper lk3=new NavatarResearchCtrl.referenceRecordWrapper();
        NavatarResearchCtrl.relativeObjectsData lk4=new NavatarResearchCtrl.relativeObjectsData();
        
        kl1 = NavatarResearchCtrl.getSearchResultListWithAdvance('{"Account":"Industry IN (\'Banking\') ","Contact":"","navpeII_dev18__Pipeline__c":"","navpeII_dev18__Fund__c":"","navpeII_dev18__Fundraising__c":"","Theme__c":"","Clip__c":""}',
                                                                 '{"Account":["'+acc[0].id+','+acc[1].id+','+acc[2].id+','+acc[3].id+','+acc[4].id+'"],"Contact":["'+Con[0].id+'"],"navpeII_dev18__Pipeline__c":["'+dealList[0].id+'"],"navpeII_dev18__Fund__c":["'+fundList[0].id+'"],"navpeII_dev18__Fundraising__c":[],"navpeII_dev18__Theme__c":["'+themeList[0].id+'"],"navpeII_dev18__Clip__c":["'+clipList[0].id+'"]}',
                                                                 'Name,Summary__c','Name,Description__c',
                                                                 'Name,navpeII_dev18__Legal_Name__c , navpeII_dev18__Legal_Name__r.Name,navpeII_dev18__Status_Notes__c',
                                                                 'Name,navpeII_dev18__Vintage_Year__c','Name,Description, RecordType.Name','Name,AccountId ,Account.Name,Description',
                                                                 'Name,navpeII_dev18__Stage__c,navpeII_dev18__Pipeline_Comments__c','"Test Data"','comingFromChild');
        System.assertEquals(Acc.size() , 14);
    }
    static testMethod void unitTest3() {
        List<Account> acc=new List<Account>();
        List<Contact> con=new List<Contact>();
        List<Task> tk=new List<Task>();
        List<Event> et=new list<Event>();
        et=[Select OwnerId,Subject,WhatId,WhoId,Related_Associations__c From Event];
        Acc=[Select Name,Id,Description,Industry From Account];
        Con=[Select Name,Id,Description From Contact];
        tk=[Select OwnerId,Subject,WhatId,WhoId,Related_Associations__c From Task];
        NavatarResearchCtrl.innerStructureWrapper kl1=new NavatarResearchCtrl.innerStructureWrapper();
        
        kl1 = NavatarResearchCtrl.getSearchResultListWithAdvance('{"Account":"Industry IN (\'Banking\') ","Contact":"","navpeII_dev18__Pipeline__c":"","navpeII_dev18__Fund__c":"","navpeII_dev18__Fundraising__c":"","navpeII_dev18__Theme__c":"","navpeII_dev18__Clip__c":""}',
                                                                 '{"Account":["'+acc[0].id+'"],"Contact":[],"navpeII_dev18__Pipeline__c":[],"navpeII_dev18__Fund__c":[],"navpeII_dev18__Fundraising__c":[],"navpeII_dev18__Theme__c":[],"navpeII_dev18__Clip__c":[]}',
                                                                 'Name,navpeII_dev18__Summary__c','Name,navpeII_dev18__Description__c',
                                                                 'Name,navpeII_dev18__Legal_Name__c , navpeII_dev18__Legal_Name__r.Name,navpeII_dev18__Status_Notes__c',
                                                                 'Name,navpeII_dev18__Vintage_Year__c','Name,Description, RecordType.Name','Name,AccountId ,Account.Name,Description',
                                                                 'Name,navpeII_dev18__Stage__c,navpeII_dev18__Pipeline_Comments__c','Test Data','comingFromChild');
        System.assertEquals(Acc.size() , 14);
    }
    static testMethod void unitTest4() {
        List<Account> acc=new List<Account>();
        List<Contact> con=new List<Contact>();
        List<Task> tk=new List<Task>();
        Acc=[Select Name,Id,Description,Industry From Account];
        Con=[Select Name,Id,Description From Contact];
        tk=[Select OwnerId,Subject,WhatId,WhoId,Related_Associations__c From Task];
        List<Event> et=new list<Event>();
        et=[Select OwnerId,Subject,WhatId,WhoId,Related_Associations__c From Event];
        NavatarResearchCtrl.getSearchResultListWithAdvance('{"Account":"Industry IN (\'Banking\') ","Contact":"","navpeII_dev18__Pipeline__c":"","navpeII_dev18__Fund__c":"","navpeII_dev18__Fundraising__c":"","navpeII_dev18__Theme__c":"","navpeII_dev18__Clip__c":""}',
                                                           '{"Account":["'+acc[0].id+'"],"Contact":[],"navpeII_dev18__Pipeline__c":[],"navpeII_dev18__Fund__c":[],"navpeII_dev18__Fundraising__c":[],"navpeII_dev18__Theme__c":[],"navpeII_dev18__Clip__c":[]}',
                                                           'Name,navpeII_dev18__Summary__c','Name,navpeII_dev18__Description__c',
                                                           'Name,navpeII_dev18__Legal_Name__c , navpeII_dev18__Legal_Name__r.Name,navpeII_dev18__Status_Notes__c',
                                                           'Name,navpeII_dev18__Vintage_Year__c','Name,Description, RecordType.Name','Name,AccountId ,Account.Name,Description',
                                                           'Name,navpeII_dev18__Stage__c,navpeII_dev18__Pipeline_Comments__c','Test,Data','comingFromChild');
        System.assertEquals(Acc.size() , 14);
    }
    static testMethod void unitTest5() {
        List<Account> acc=new List<Account>();
        List<Contact> con=new List<Contact>();
        List<Task> tk=new List<Task>();
        Acc=[Select Name,Id,Description,Industry From Account];
        Con=[Select Name,Id,Description From Contact];
        tk=[Select OwnerId,Subject,WhatId,WhoId,Related_Associations__c From Task];
        List<Event> et=new list<Event>();
        et=[Select OwnerId,Subject,WhatId,WhoId,Related_Associations__c From Event];
        NavatarResearchCtrl.getSearchResultListWithAdvance('{"Account":"Industry IN (\'Banking\') ","Contact":"","navpeII_dev18__Pipeline__c":"","navpeII_dev18__Fund__c":"","navpeII_dev18__Fundraising__c":"","navpeII_dev18__Theme__c":"","navpeII_dev18__Clip__c":""}',
                                                           '{"Account":["'+acc[0].id+'"],"Contact":[],"navpeII_dev18__Pipeline__c":[],"navpeII_dev18__Fund__c":[],"navpeII_dev18__Fundraising__c":[],"navpeII_dev18__Theme__c":[],"navpeII_dev18__Clip__c":[]}',
                                                           'Name,navpeII_dev18__Summary__c','Name,navpeII_dev18__Description__c',
                                                           'Name,navpeII_dev18__Legal_Name__c , navpeII_dev18__Legal_Name__r.Name,navpeII_dev18__Status_Notes__c',
                                                           'Name,navpeII_dev18__Vintage_Year__c','Name,Description, RecordType.Name','Name,AccountId ,Account.Name,Description',
                                                           'Name,navpeII_dev18__Stage__c,navpeII_dev18__Pipeline_Comments__c',
                                                           'Test-Data','comingFromChild');
        System.assertEquals(Acc.size() , 14);
    }
    static testMethod void unitTest6() {
        List<Account> acc=new List<Account>();
        List<Contact> con=new List<Contact>();
        List<Task> tk=new List<Task>();
        Acc=[Select Name,Id,Description,Industry From Account];
        Con=[Select Name,Id,Description From Contact];
        tk=[Select OwnerId,Subject,WhatId,WhoId,Related_Associations__c From Task];
        List<Event> et=new list<Event>();
        et=[Select OwnerId,Subject,WhatId,WhoId,Related_Associations__c From Event];
        NavatarResearchCtrl.getSearchResultListWithAdvance('{"Account":"Industry IN (\'Banking\') ","Contact":"","navpeII_dev18__Pipeline__c":"","navpeII_dev18__Fund__c":"","navpeII_dev18__Fundraising__c":"","navpeII_dev18__Theme__c":"","navpeII_dev18__Clip__c":""}',
                                                           '{"Account":["'+acc[0].id+'"],"Contact":[],"navpeII_dev18__Pipeline__c":[],"navpeII_dev18__Fund__c":[],"navpeII_dev18__Fundraising__c":[],"navpeII_dev18__Theme__c":[],"navpeII_dev18__Clip__c":[]}',
                                                           'Name,navpeII_dev18__Summary__c','Name,navpeII_dev18__Description__c',
                                                           'Name,navpeII_dev18__Legal_Name__c , navpeII_dev18__Legal_Name__r.Name,navpeII_dev18__Status_Notes__c',
                                                           'Name,navpeII_dev18__Vintage_Year__c','Name,Description, RecordType.Name','Name,AccountId ,Account.Name,Description',
                                                           'Name,navpeII_dev18__Stage__c,navpeII_dev18__Pipeline_Comments__c','"Test1data" "test2data"','comingFromChild');
        System.assertEquals(Acc.size() , 14);
    }
    static testMethod void unitTest7() {
        List<Account> acc=new List<Account>();
        List<Contact> con=new List<Contact>();
        List<Task> tk=new List<Task>();
        Acc=[Select Name,Id,Description,Industry From Account];
        Con=[Select Name,Id,Description From Contact];
        
        NavatarResearchCtrl.columnListWrapper trData= new   NavatarResearchCtrl.columnListWrapper();
        trData= NavatarResearchCtrl.setColumnAndFields();
        System.assertEquals(Acc.size() , 14);
    }
    static testMethod void unitTest8() {
        List<Account> acc=new List<Account>();
        List<Contact> con=new List<Contact>();
        
        Acc=[Select Name,Id,Description,Industry From Account];
        Con=[Select Name,Id,Description From Contact];
        
        boolean flagValue = NavatarResearchCtrl.makeObjectPermissionInMap('Account');
        System.assertEquals(Acc.size() , 14);
    }
    static testMethod void unitTest9() {
        List<Account> acc=new List<Account>();
        Acc=[Select Name,Id,Description,Industry From Account];
        List<ID> accList = new List<ID>(new Map<Id, Account>([Select Name,Id,Description,Industry From Account]).keySet());
        List<ID> conList=new List<ID>(new Map<Id, Contact>([Select Name,Id,Description From Contact]).keySet());
        List<ID> fdList=new List<ID>(new Map<Id, navpeII_dev18__Fund__c>([Select Name,Id From navpeII_dev18__Fund__c]).keySet());
        List<ID> dealList=new List<ID>(new Map<Id, navpeII_dev18__Pipeline__c>([Select Name,Id From navpeII_dev18__Pipeline__c]).keySet());
        List<ID> themeList=new List<ID>(new Map<Id, navpeII_dev18__theme__c>([Select Name,Id From navpeII_dev18__theme__c]).keySet());
        List<ID> clipList=new List<ID>(new Map<Id, navpeII_dev18__clip__c>([Select Name,Id From navpeII_dev18__clip__c]).keySet());
        List<ID> tskList=new List<ID>(new Map<Id,task>([Select Id,Subject From task]).keySet());
        List<ID> evtList=new List<ID>(new Map<Id,event>([Select Id,Subject From event]).keySet());
        tskList.addAll(evtList);
        string themeNameValue='My testing Theme';
        string themedes = 'The great theme';
        boolean addAllContactForEachFirm=false;
        NavatarResearchAdvanceResultCtrl ref=new NavatarResearchAdvanceResultCtrl();
        Test.startTest();
        List<ID> fdrList=new List<ID>(new Map<Id, navpeII_dev18__Fundraising__c>([Select Name,Id From navpeII_dev18__Fundraising__c]).keySet());
    // string response= 
         NavatarResearchAdvanceResultCtrl.createThemeRecord( addAllContactForEachFirm, themeNameValue, themedes ,accList , conList ,dealList , fdList , fdrList ,  themeList ,  clipList,tskList  );
        Test.stopTest();
System.assertEquals(Acc.size() , 14);
    }

    static testMethod void unitTest10() {
        List<Account> acc=new List<Account>();
        Acc=[Select Name,Id,Description,Industry From Account];
        List<ID> accList = new List<ID>(new Map<Id, Account>([Select Name,Id,Description,Industry From Account]).keySet());
        List<ID> conList=new List<ID>(new Map<Id, Contact>([Select Name,Id,Description From Contact]).keySet());
        List<ID> fdList=new List<ID>(new Map<Id, navpeII_dev18__Fund__c>([Select Name,Id From navpeII_dev18__Fund__c]).keySet());
        List<ID> fdrList=new List<ID>(new Map<Id, navpeII_dev18__Fundraising__c>([Select Name,Id From navpeII_dev18__Fundraising__c]).keySet());
        List<ID> dealList=new List<ID>(new Map<Id, navpeII_dev18__Pipeline__c>([Select Name,Id From navpeII_dev18__Pipeline__c]).keySet());
        List<ID> themeList=new List<ID>(new Map<Id, navpeII_dev18__theme__c>([Select Name,Id From navpeII_dev18__theme__c]).keySet());
        List<ID> clipList=new List<ID>(new Map<Id, navpeII_dev18__clip__c>([Select Name,Id From navpeII_dev18__clip__c]).keySet());
        List<ID> tskList=new List<ID>(new Map<Id,task>([Select Id,Subject From task]).keySet());
        List<ID> evtList=new List<ID>(new Map<Id,event>([Select Id,Subject From event]).keySet());
        tskList.addAll(evtList);
        string themeNameValue='My testing Theme';
        string themedes = 'The great theme';
        boolean addAllContactForEachFirm=true;
        
   //  string response= 
         NavatarResearchAdvanceResultCtrl.createThemeRecord( addAllContactForEachFirm, themeNameValue, themedes ,accList , conList ,dealList , fdList , fdrList ,  themeList ,  clipList ,tskList );
System.assertEquals(Acc.size() , 14);
    }    
     static testMethod void unitTest11() {
         List<Account> acc=new List<Account>();
         Acc=[Select Name,Id,Description,Industry From Account];
        List<ID> accList = new List<ID>(new Map<Id, Account>([Select Name,Id,Description,Industry From Account]).keySet());
        List<ID> conList=new List<ID>(new Map<Id, Contact>([Select Name,Id,Description From Contact]).keySet());
        List<ID> fdList=new List<ID>(new Map<Id, navpeII_dev18__Fund__c>([Select Name,Id From navpeII_dev18__Fund__c]).keySet());
        List<ID> fdrList=new List<ID>(new Map<Id, navpeII_dev18__Fundraising__c>([Select Name,Id From navpeII_dev18__Fundraising__c]).keySet());
        List<ID> dealList=new List<ID>(new Map<Id, navpeII_dev18__Pipeline__c>([Select Name,Id From navpeII_dev18__Pipeline__c]).keySet());
        List<ID> themeList=new List<ID>(new Map<Id, theme__c>([Select Name,Id From theme__c]).keySet());
        List<ID> clipList=new List<ID>(new Map<Id, clip__c>([Select Name,Id From clip__c]).keySet());
        List<ID> tskList=new List<ID>(new Map<Id,task>([Select Id,Subject From task]).keySet());
        List<ID> evtList=new List<ID>(new Map<Id,event>([Select Id,Subject From event]).keySet());
        tskList.addAll(evtList);
        string themeNameValue='My testing Theme';
        string themedes = 'The great theme';
        boolean addAllContactForEachFirm=false;
        string themeIdValue=themeList[0];        
     string response= NavatarResearchAdvanceResultCtrl.addToThemeRecord( addAllContactForEachFirm, themeIdValue,accList , conList ,dealList , fdList , fdrList ,  themeList ,  clipList ,tskList );
System.assertEquals(Acc.size() , 14);
    }  
    static testMethod void unitTest12() {
        List<Account> acc=new List<Account>();
        Acc=[Select Name,Id,Description,Industry From Account];
        List<ID> accList = new List<ID>(new Map<Id, Account>([Select Name,Id,Description,Industry From Account]).keySet());
        List<ID> conList=new List<ID>(new Map<Id, Contact>([Select Name,Id,Description From Contact]).keySet());
        List<ID> fdList=new List<ID>(new Map<Id, navpeII_dev18__Fund__c>([Select Name,Id From navpeII_dev18__Fund__c]).keySet());
        List<ID> fdrList=new List<ID>(new Map<Id, navpeII_dev18__Fundraising__c>([Select Name,Id From navpeII_dev18__Fundraising__c]).keySet());
        List<ID> dealList=new List<ID>(new Map<Id, navpeII_dev18__Pipeline__c>([Select Name,Id From navpeII_dev18__Pipeline__c]).keySet());
        List<ID> themeList=new List<ID>(new Map<Id, theme__c>([Select Name,Id From theme__c]).keySet());
        List<ID> clipList=new List<ID>(new Map<Id, clip__c>([Select Name,Id From clip__c]).keySet());
        List<ID> tskList=new List<ID>(new Map<Id,task>([Select Id,Subject From task]).keySet());
        List<ID> evtList=new List<ID>(new Map<Id,event>([Select Id,Subject From event]).keySet());
        tskList.addAll(evtList);
        list<Theme_Relation__c> trList=new list<Theme_Relation__c>();
         trList.add(new Theme_Relation__c(Contact__c=conList[0],theme__c=themeList[0]));
         trList.add(new Theme_Relation__c(Account__c=accList[0],theme__c=themeList[0]));
        trList.add(new Theme_Relation__c(Fund__c=fdList[0],theme__c=themeList[0]));
        //trList.add(new Theme_Relation__c(Fundraising__c=fdrList[0],theme__c=themeList[0]));
        trList.add(new Theme_Relation__c(Deal__c=dealList[0],theme__c=themeList[0]));
        trList.add(new Theme_Relation__c(Clip__c=clipList[0],theme__c=themeList[0]));
        insert trList;
        string themeNameValue='My testing Theme';
        string themedes = 'The great theme';
        boolean addAllContactForEachFirm=true;
        string themeIdValue=themeList[0];        
     string response= NavatarResearchAdvanceResultCtrl.addToThemeRecord( addAllContactForEachFirm, themeIdValue,accList , conList ,dealList , fdList , fdrList ,  themeList ,  clipList ,tskList );
System.assertEquals(Acc.size() , 14);
    } 
    static testMethod void unitTest13() {
       Account a = new Account(Name = 'Dummy');
        insert a;
        List<Account> acc=new List<Account>();
        Acc=[Select Name,Id,Description,Industry From Account];
        List<ID> accList = new List<ID>(new Map<Id, Account>([Select Name,Id,Description,Industry From Account]).keySet());
        List<ID> conList=new List<ID>(new Map<Id, Contact>([Select Name,Id,Description From Contact]).keySet());
        List<ID> fdList=new List<ID>(new Map<Id, navpeII_dev18__Fund__c>([Select Name,Id From navpeII_dev18__Fund__c]).keySet());
        List<ID> dealList=new List<ID>(new Map<Id, navpeII_dev18__Pipeline__c>([Select Name,Id From navpeII_dev18__Pipeline__c]).keySet());
        List<ID> themeList=new List<ID>(new Map<Id, navpeII_dev18__theme__c>([Select Name,Id From navpeII_dev18__theme__c]).keySet());
        List<ID> clipList=new List<ID>(new Map<Id, navpeII_dev18__clip__c>([Select Name,Id From navpeII_dev18__clip__c]).keySet());
        List<ID> tskList=new List<ID>(new Map<Id,task>([Select Id,Subject From task]).keySet());
        List<ID> evtList=new List<ID>(new Map<Id,event>([Select Id,Subject From event]).keySet());
        tskList.addAll(evtList);
        string themeNameValue='My testing Theme';
        string themedes = 'The great theme';
        boolean addAllContactForEachFirm=false;
        NavatarResearchAdvanceResultCtrl ref=new NavatarResearchAdvanceResultCtrl();
        //Create Fundraising
        //Test class coverage fix by LK on 2024-11-06
        List<RecordType> recTypeList = [SELECT Id FROM RecordType WHERE SobjectType='Account' AND Name='Individual Investor' AND IsActive=true];
        system.debug('@@@' + recTypeList);
        Account accnt = new Account(Name='Dummy');
        if(recTypeList.size() > 0){
            accnt.RecordTypeId=recTypeList.get(0).Id;
        }
        insert accnt;
        List<navpeII_dev18__Fundraising__c> fundraisingList=new List<navpeII_dev18__Fundraising__c>();
        navpeII_dev18__Fundraising__c frData=new navpeII_dev18__Fundraising__c(); 
        frData.Name=accnt.Id+' Fundraising'; 
        frData.navpeII_dev18__Legal_Name__c=accnt.Id; 
        frData.navpeII_dev18__Fund_Name__c=fdList.get(0);
        FundraisingList.add(frData); 
        insert FundraisingList;
        List<ID> fdrList=new List<ID>(new Map<Id, navpeII_dev18__Fundraising__c>([Select Name,Id From navpeII_dev18__Fundraising__c]).keySet());
    // string response= 
         NavatarResearchAdvanceResultCtrl.createThemeRecord( addAllContactForEachFirm, themeNameValue, themedes ,accList , conList ,dealList , fdList , fdrList ,  themeList ,  clipList ,tskList );
System.assertEquals(Acc.size() , 15);
    }
    static testMethod void unitTest14() {
        List<Account> acc=new List<Account>();
        List<Contact> con=new List<Contact>();
        List<Task> tk=new List<Task>();
        List<Event> et=new list<Event>();
        Test.startTest();
        Acc=[Select Name,Id,Description,Industry From Account];
        Con=[Select Name,Id,Description From Contact];
        tk=[Select OwnerId,Subject,WhatId,WhoId,Related_Associations__c From Task];
        et=[Select OwnerId,Subject,WhatId,WhoId,Related_Associations__c From Event];
        ContentVersion contentVersion = new ContentVersion(
            Title = 'Penguins Test Data Sosl',
            PathOnClient = 'TestD.txt',
            VersionData = Blob.valueOf('Test Content TestData "Test1data" "test2data" Test,Data Test-Data test'),
            IsMajorVersion = true
        );
        insert contentVersion;    
        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
        
       
        List<ContentDocumentLink> cdl = New List<ContentDocumentLink>();
        cdl.add(new ContentDocumentLink(LinkedEntityId = Acc[0].id,ContentDocumentId=documents[0].Id,shareType = 'V'));
        cdl.add(new ContentDocumentLink(LinkedEntityId = Acc[1].id,ContentDocumentId=documents[0].Id,shareType = 'V'));
        cdl.add(new ContentDocumentLink(LinkedEntityId = con[0].id,ContentDocumentId=documents[0].Id,shareType = 'V'));
        cdl.add(new ContentDocumentLink(LinkedEntityId = con[1].id,ContentDocumentId=documents[0].Id,shareType = 'V'));
       
        insert cdl;

    
    string queryForFile;
        queryForFile = 'FIND '+'{Test}'+' IN ALL FIELDS RETURNING ContentDocument (Id ORDER BY Title)';
    system.debug(queryForFile+'####queryForFile');    
      List<ContentDocument> fileSearchDataList=new List<ContentDocument>();
    List<Search.SearchResult> searchResultFilelist=new List<Search.SearchResult>();
    Search.SearchResults searchResultsFile = Search.find(queryForFile,AccessLevel.USER_MODE);
    searchResultFilelist= searchResultsFile.get('ContentDocument');
    for(Search.SearchResult sr:searchResultFilelist){
    ContentDocument fileRec = (ContentDocument) sr.getSObject();
    System.debug('####fileSearchDataList'+fileRec);
    fileSearchDataList.add(fileRec);
    }
        List<List<SObject>> searchList = [FIND 'Test' 
                                          IN ALL FIELDS RETURNING 
                                          Account(Id, Name,Description)];
        NavatarResearchCtrl.innerStructureWrapper kl1=new NavatarResearchCtrl.innerStructureWrapper();
        kl1 = NavatarResearchCtrl.getSearchResultListWithAdvance(null,
                                                                 null,
                                                                 'Name,Summary__c','Name,Description__c',
                                                                 'Name,navpeII_dev18__Legal_Name__c , navpeII_dev18__Legal_Name__r.Name,navpeII_dev18__Status_Notes__c',
                                                                 'Name,navpeII_dev18__Vintage_Year__c','Name,Description, RecordType.Name','Name,AccountId ,Account.Name,Description',
                                                                 'Name,navpeII_dev18__Stage__c,navpeII_dev18__Pipeline_Comments__c','TestD','comingFromChild1');
        Test.stopTest();
        System.assertEquals(Acc.size() , 14);
    }
    static testMethod void unitTest15(){
        navpeII_dev18__Fund__c fund = new navpeII_dev18__Fund__c();
        fund.Name = 'Dummy Fund 1';
        fund.navpeII_dev18__Fund_Type__c = 'Fund';
        fund.navpeII_dev18__Investment_Category__c = 'Fund';
        NavatarResearchAddToFundCtrl.createFund(JSON.serialize(fund));
        
        NavatarResearchAddToFundCtrl.fetchAllowedAccRecTypeList();
        NavatarResearchAddToFundCtrl.getDefaultRole();
        
        List<navpeII_dev18__Fund__c> fundList = new List<navpeII_dev18__Fund__c>();
        fundList = [SELECT Id FROM navpeII_dev18__Fund__c LIMIT 1];
        NavatarResearchAddToFundCtrl.getFundName(fundList.get(0).Id);
        
        List<Account> accList = new List<Account>();
        accList = [SELECT Id FROM Account LIMIT 1];
        NavatarResearchAddToFundCtrl.createFdr(fundList.get(0).Id, 'Dummy Fund 1', JSON.serialize(new List<String>{accList.get(0).Id}));
        NavatarResearchAddToFundCtrl.addToFundFdr(fundList.get(0).Id, 'Dummy Fund 1', JSON.serialize(new List<String>{accList.get(0).Id}));
        NavatarResearchAddToFundCtrl.createFdrCon(fundList.get(0).Id, JSON.serialize(new List<String>{accList.get(0).Id}));
        
            NavatarResearchAddToFundCtrl.getConFromAcc(new List<String>{accList.get(0).Id});
    }
}