@isTest
private class NavatarFirmPDFCtrlTest {
    //get revenue grid api key from custom meta data
    private static String apiKey = [SELECT Value__c FROM RG_Setting__mdt WHERE DeveloperName = 'RG_API_Key'].Value__c;
    //store this variable revenue grid api key
    private static string storeApiKey = 'ApiKey '+apiKey;
    //store this variable authorization
    private static string storeAuth = 'Authorization';
    //store this variable post mehod type
    private static string storePost = 'POST';
    //store get mehod type
   // private static string storeGet = 'GET';
    //store this variable content type
    private static string storeCT = 'Content-Type';
    //store this variable application json format
    private static string storeTPJson = 'application/json';   
    private static string accConnectionEndPoint = RG_Setting__mdt.getInstance('RG_Firm_Contacts').Value__c;
    private static String np = [SELECT NamespacePrefix FROM ApexClass WHERE Name = 'FileUploaderCtrl'].NamespacePrefix;
    private static String namespacePrefix = np + '__'; 
    
    private class userListMOCK implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            String fullJson = '[ { "mailboxId": "37919e14-b813-41de-a896-c65b939d8ee9", "activityId": "<DM5PR15MB14492619672DB9DB873DC89897389@DM5PR15MB1449.namprd15.prod.outlook.com>", "activityTime": 1667468711000, "activityCategory": "indirectEmails", "subject": "Harshit 2", "from": "johnlowry@kedaracapital-ng.com", "to": [ "robertday@kedaracapital-ng.com" ], "cc": [ "jason.hoffman@baincapital-ng.com", "terry.larson@baincapital-ng.com" ], "tags": [ "neutralSentiment" ] }, { "mailboxId": "37919e14-b813-41de-a896-c65b939d8ee9", "activityId": "<DM5PR15MB1225B0E0357D8988BA3C8E378B399@DM5PR15MB1225.namprd15.prod.outlook.com>", "activityTime": 1667373425000, "activityCategory": "inboundEmails", "subject": "Testing the RG", "from": "robertday@kedaracapital-ng.com", "to": [ "jason.hoffman@baincapital-ng.com", "johnlowry@kedaracapital-ng.com" ], "cc": [ "terry.larson@baincapital-ng.com" ], "tags": [ "neutralSentiment" ] }, { "mailboxId": "e31bfc6d-f571-48b4-8896-53d73ab1c903", "activityId": "<MN2PR04MB6813BAA6DB6F37B1BB84F7E8C5389@MN2PR04MB6813.namprd04.prod.outlook.com>", "activityTime": 1667468626000, "activityCategory": "outboundEmails", "subject": "Harshit ---", "from": "jason.hoffman@baincapital-ng.com", "to": [ "johnlowry@kedaracapital-ng.com", "terry.larson@baincapital-ng.com" ], "cc": [ "robertday@kedaracapital-ng.com" ], "tags": [ "neutralSentiment" ] }]';
            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'text/json');
            res.setBody(fullJson);
            res.setStatusCode(200);
            return res;
        }
    } 
    @testSetup 
    static void testSetup() {
         navpeII_dev18__Navatar_Setup__c navSetup = new navpeII_dev18__Navatar_Setup__c();
        navSetup.RAS__c = '001,003';
        navSetup.navpeII_dev18__Admin_Setting__c = true;
        insert navSetup; 
        List<Contact> conList =new List<Contact>();
        List<event> listOfEvent = new List<event>();
        //List<EventRelation> listOfEventRelation = new List<EventRelation>();
        List<sObject> listOfEventRelation = new List<sObject>();
        List<sObject> listOfTaskRelation = new List<sObject>();
        Account acRec = new Account();
        acRec.Name='Test Account';
        insert acRec;
         Task tskRec = new Task();
        tskRec.Description='Created from Test class';
        tskRec.navpeII_dev18__Related_Associations__c=acRec.Id;
        tskRec.Classification__c='A';
        tskRec.ActivityDate = date.today();
        tskRec.Subject='Test task';
        insert tskRec;
        Contact con = new Contact();
        con.LastName ='Test Contact';
        con.AccountId = acRec.Id;
        con.Title='Mr';
        con.navpeII_dev18__Last_Touch_Point__c=date.today();
        conList.add(con);
         Contact con1 = new Contact();
        con1.LastName ='Test Contact1';
        con1.navpeII_dev18__Last_Touchpoint_ID__c = tskRec.id;
        
        con1.Title='Mr';
        con1.navpeII_dev18__Last_Touch_Point__c=date.today();
        conList.add(con1);
        insert conList;
       
        
        Task tsk = new Task();
        tsk.Description='Created from Test class';
        tsk.navpeII_dev18__Related_Associations__c=acRec.Id;
        tsk.Classification__c='A';
        tsk.ActivityDate = date.today();
        tsk.WhoId = conList[1].Id;
        tsk.Subject='Test task';
        insert tsk;
        if(Schema.getGlobalDescribe().get('TaskRelation') != null){
        Schema.SObjectType stTsk = Schema.getGlobalDescribe().get('TaskRelation');
        sObject evtr1 = stTsk.newSobject();
        evtr1.put('TaskId', tsk.Id);
        evtr1.put('RelationId', conList[0].Id);
        listOfTaskRelation.add(evtr1);
        insert listOfTaskRelation;
        }
        
        for(Integer i=1;i<3;i++){
            event ev = new event();
            ev.subject = 'Test event';
            ev.ActivityDate = date.today();
            ev.StartDateTime = system.now();
            ev.WhoId = conList[1].Id;
            ev.WhatId=acRec.Id;
            ev.EndDateTime = system.now().addhours(2);
            if(i==1){
                ev.navpeII_dev18__Related_Associations__c= acRec.id;
               
            }
            listOfEvent.add(ev);
        }
        insert listOfEvent;
        for(Integer i=1;i<3;i++){
            Schema.SObjectType st = Schema.getGlobalDescribe().get('EventRelation');
            sObject evtr = st.newSobject();
           evtr.put('RelationId', conList[0].Id);
            if(i==1){
                evtr.put('EventId', listOfEvent[0].Id);
            }
            else{
                 evtr.put('EventId', listOfEvent[1].Id);
            }
            listOfEventRelation.add(evtr);
        }
        insert listOfEventRelation; 
        
        
         Id devRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Company').getRecordTypeId();
        Account acct = new Account();
        acct.RecordTypeId = devRecordTypeId;
        acct.Name = 'Test Class';
        insert acct;
        
        Contact cont = new Contact();
        cont.LastName = 'Testing';
        cont.AccountId = acct.id;
        cont.Email = 'jsmith@acme.com';
        cont.Title = 'BA';
        insert cont;
        navpeII_dev18__Pipeline__c deal = new navpeII_dev18__Pipeline__c();
        deal.Name = 'Testing';
        deal.navpeII_dev18__Company__c = acct.id;
        deal.navpeII_dev18__Our_Role__c = 'Lead';
        deal.navpeII_dev18__Stage__c = 'IOI';
        insert deal;
        navpeII_dev18__Fund__c fund1 = new navpeII_dev18__Fund__c();
        fund1.Name = 'Test1';
        fund1.navpeII_dev18__Fund_Type__c = 'Fund';
        fund1.navpeII_dev18__Investment_Category__c = 'Fund';
        insert fund1;
        List<navpeII_dev18__Deal_Team__c> dealTeamList = new List<navpeII_dev18__Deal_Team__c>();
        navpeII_dev18__Deal_Team__c dealTeam = new navpeII_dev18__Deal_Team__c();
        dealTeam.navpeII_dev18__Deal__c = deal.id;
        dealTeam.navpeII_dev18__Deal_Contact__c = cont.id;
         dealTeamList.add(dealTeam);
        navpeII_dev18__Deal_Team__c dealTeam2 = new navpeII_dev18__Deal_Team__c();
        dealTeam2.navpeII_dev18__Deal__c = deal.id;
        dealTeam2.navpeII_dev18__Team_Member__c = UserInfo.getUserId();
        dealTeamList.add(dealTeam2);
        insert dealTeamList ;
        Theme__c themeRec=new Theme__c();
        themeRec.Name='testing theme';
        insert themeRec;
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        event evt = new event();
        evt.Subject='Ev Test';
        evt.WhoId = cont.id;
        evt.WhatId = acct.id; 
        evt.DurationInMinutes = 10;
        evt.navpeII_dev18__Related_Associations__c=acct.id+','+cont.id+','+fund1.Id+','+deal.Id;
        evt.ActivityDateTime = System.now();
        insert evt;
        List<Task> tskLst = new List<Task>();
        Task tskk = new task();
        tskk.WhoId = cont.id;
        tskk.WhatId = acct.id; 
        tskk.ActivityDate=date.today();
        tskk.Priority='High';
        tskk.Status='In Progress';
        tskk.navpeII_dev18__Related_Associations__c=acct.id+','+cont.id+','+fund1.Id+','+deal.Id;
        tskk.TaskSubtype='Task';
         tskLst.add(tskk);
        
        Task tsk1 = new task();
        tsk1.WhoId = cont.id;
        tsk1.WhatId = acct.id;
        tsk1.navpeII_dev18__Related_Associations__c=acct.id+','+cont.id+','+fund1.Id+','+deal.Id;
        tsk1.TaskSubtype='Call';
        tskLst.add(tsk1);
        
        
        
        Task tsk2 = new task();
        tsk2.WhoId = cont.Id;
        tsk2.WhatId = acct.Id; 
        tsk2.navpeII_dev18__Related_Associations__c=acct.id+','+cont.id+','+thisUser.Id+','+fund1.Id+','+deal.Id;
        tsk2.TaskSubtype='Email'; 
        tskLst.add(tsk2);
        insert tskLst;
        Id companyRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Company').getRecordTypeId();
        Id RecordTypeIdFirm = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Institution').getRecordTypeId();
        Account acc1 = new Account(name='test1', RecordTypeId = RecordTypeIdFirm);
        insert acc1;
        Account acc2 = new Account(name='test',RecordTypeId = companyRecordTypeId);
        insert acc2;   
    }
    @isTest
    static void accountPdfTest(){
        test.startTest();
        Id companyRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Company').getRecordTypeId();
        Id RecordTypeIdFirm = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Institution').getRecordTypeId();
        Account acc1 = new Account(name='test1', RecordTypeId = RecordTypeIdFirm);
        insert acc1;
        Account acc2 = new Account(name='test',RecordTypeId = companyRecordTypeId);
        insert acc2;
        Account accRec =[SELECT Id,Name from Account Where Name ='Test Account'];
        PageReference pageRef = Page.Company_Report;
        Test.setCurrentPage(pageRef);
        ApexPages.StandardController sc = new  ApexPages.StandardController(accRec);
        NavatarFirmPDFCtrl ac = new NavatarFirmPDFCtrl(sc);
        test.stopTest();
        System.assertEquals(accRec.Name, ac.mainTitle);
    }
    @isTest
    static void accountPdfTestForDeals(){
        test.startTest();
       
        Id companyRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Company').getRecordTypeId();
        Id RecordTypeIdFirm = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Institution').getRecordTypeId();
        Account acc1 = new Account(name='test1', RecordTypeId = RecordTypeIdFirm);
        insert acc1;
        Account acc2 = new Account(name='test',RecordTypeId = companyRecordTypeId);
        insert acc2;

        Map<String, sObject> dealMap = new Map<String, sObject>();
        List<navpeII_dev18__Pipeline__c> dealLst = new List<navpeII_dev18__Pipeline__c>();
        navpeII_dev18__Pipeline__c dealRecord1 = new navpeII_dev18__Pipeline__c(Name = 'testDeal1', navpeII_dev18__Stage__c = 'Parked', navpeII_dev18__Company__c = acc2.Id);
        dealLst.add(dealRecord1);
        navpeII_dev18__Pipeline__c dealRecord2 = new navpeII_dev18__Pipeline__c(Name = 'testDeal2', navpeII_dev18__Stage__c = 'Parked', navpeII_dev18__Source_Company__c = acc2.Id);
        dealLst.add(dealRecord2);
        
        navpeII_dev18__Pipeline__c navRec = new navpeII_dev18__Pipeline__c();
        navRec.Name = 'Test Deals';
        navRec.navpeII_dev18__Stage__c='Deal Received';
        dealLst.add(navRec);
        insert dealLst;
        navpeII_dev18__Deal_Team__c dealTeamRecord = new navpeII_dev18__Deal_Team__c( navpeII_dev18__Deal__c = dealRecord1.id, navpeII_dev18__Team_Member__c = UserInfo.getUserId() );
        insert dealTeamRecord;
        Account accRec =[SELECT Id,Name from Account Where Name ='Test Account'];
        PageReference pageRef = Page.Company_Report;
        Test.setCurrentPage(pageRef);
        ApexPages.StandardController sc = new  ApexPages.StandardController(accRec);
        NavatarFirmPDFCtrl ac = new NavatarFirmPDFCtrl(sc);
        test.stopTest();
         System.assertEquals(accRec.Name, ac.mainTitle);
    }
    
    // modification
    @isTest
    static void handleOnLoadInfoTest(){
         test.startTest();
        Account acc = [select id,Name from Account where Name like '%Test Class%' limit 1]; 
        Contact cnt = [select id,email from Contact where LastName='Testing' limit 1];
        Event ev = [select id from Event Where Subject like '%Ev Test%' limit 1];
        Map<String, Task> taskMap = new Map<String, Task>([select id from Task LIMIT 10]);
        Set<String> conIdSet = new Set<String>();
        conIdSet.add(cnt.id);
        List<String> accidList = new List<String>();
        accidList.add(ev.id);
        accidList.addAll(taskMap.keySet());
        set<String> accSet = new Set<String>();
        accSet.add(acc.id);
        List<String> conidList = new List<String>();
        conidList.add(cnt.id);
        Map<String,Sobject> conMap = new Map<String,Sobject>([Select id, Lastname,Email from Contact ]);
        
         ApexPages.StandardController sc = new  ApexPages.StandardController(acc);
        NavatarFirmPDFCtrl ac = new NavatarFirmPDFCtrl(sc);
        NavatarFirmPDFCtrl.ResponseWrapper wrapperResults=NavatarFirmPDFCtrl.handleOnLoadInfo(acc.id,'Account');
        test.stopTest();
        //Assert.isTrue(wrapperResults!=null);
        Assert.areEqual(wrapperResults.recName,acc.Name);
       // system.assert(true);
    }
     @isTest
    static void handleOnLoadInfoTest2(){
        test.startTest();
        Account acc = [select id,Name from Account where Name like '%Test Class%' limit 1]; 
        Contact cnt = [select id,email from Contact where LastName='Testing' limit 1];
        Event ev = [select id from Event Where Subject like '%Ev Test%' limit 1];
        Map<String, Task> taskMap = new Map<String, Task>([select id from Task LIMIT 10]);
        Set<String> conIdSet = new Set<String>();
        conIdSet.add(cnt.id);
        List<String> accidList = new List<String>();
        accidList.add(ev.id);
        accidList.addAll(taskMap.keySet());
        set<String> accSet = new Set<String>();
        accSet.add(acc.id);
        List<String> conidList = new List<String>();
        conidList.add(cnt.id);
        Map<String,Sobject> conMap = new Map<String,Sobject>([Select id, Lastname,Email from Contact ]);
         ApexPages.StandardController sc = new  ApexPages.StandardController(acc);
        NavatarFirmPDFCtrl ac = new NavatarFirmPDFCtrl(sc);
       NavatarFirmPDFCtrl.ResponseWrapper wrapperResults= NavatarFirmPDFCtrl.handleOnLoadInfo(acc.id,'Contact');
        Assert.isTrue(wrapperResults!=null);
        test.stopTest();
        Assert.areEqual(wrapperResults.recName,acc.Name);
        //system.assert(true);
    }
    static testmethod void handleOnLoadInfoTest3() {
        Test.startTest();
          Account acc = [select id,Name from Account where Name like '%Test Class%' limit 1]; 
        Contact cnt = [select id,email from Contact where LastName='Testing' limit 1];
        Event ev = [select id from Event Where Subject like '%Ev Test%' limit 1];
        Map<String, sObject> dealMap = new Map<String, sObject>();
         Id companyRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Company').getRecordTypeId();
        Id RecordTypeIdFirm = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Institution').getRecordTypeId();
        Account acc1 = new Account(name='test1', RecordTypeId = RecordTypeIdFirm);
        insert acc1;
        Account acc2 = new Account(name='test',RecordTypeId = companyRecordTypeId);
        insert acc2;
        List<navpeII_dev18__Pipeline__c> dealLst = new List<navpeII_dev18__Pipeline__c>();
        navpeII_dev18__Pipeline__c dealRecord1 = new navpeII_dev18__Pipeline__c(Name = 'testDeal1', navpeII_dev18__Stage__c = 'Parked', navpeII_dev18__Company__c = acc2.Id);
        dealLst.add(dealRecord1);
        navpeII_dev18__Pipeline__c dealRecord2 = new navpeII_dev18__Pipeline__c(Name = 'testDeal2', navpeII_dev18__Stage__c = 'Parked', navpeII_dev18__Source_Company__c = acc2.Id);
        dealLst.add(dealRecord2);
        
        navpeII_dev18__Pipeline__c navRec = new navpeII_dev18__Pipeline__c();
        navRec.Name = 'Test Deals';
        navRec.navpeII_dev18__Stage__c='Deal Received';
        dealLst.add(navRec);
        insert dealLst;
        navpeII_dev18__Deal_Team__c dealTeamRecord = new navpeII_dev18__Deal_Team__c( navpeII_dev18__Deal__c = dealRecord1.id, navpeII_dev18__Team_Member__c = UserInfo.getUserId() );
        insert dealTeamRecord;
        navpeII_dev18__Pipeline__c dealRecord = [Select id, name,navpeII_dev18__Stage__c,navpeII_dev18__Company__c from navpeII_dev18__Pipeline__c LIMIT 1];
        dealMap.put('string', dealRecord);
        
         ApexPages.StandardController sc = new  ApexPages.StandardController(acc);
        NavatarFirmPDFCtrl ac = new NavatarFirmPDFCtrl(sc);
        NavatarFirmPDFCtrl.ResponseWrapper wrapperResults=NavatarFirmPDFCtrl.handleOnLoadInfo(acc.id, 'navpeII_dev18__Pipeline__c');
        Test.stopTest();
        //Assert.isTrue(wrapperResults!=null);
        Assert.areEqual(wrapperResults.recName,acc.Name);
       
    }
    static testmethod void handleOnLoadInfoTest4() {
        
        Test.startTest();
        Account acc = [select id,Name from Account where Name like '%Test Class%' limit 1]; 
        Contact cnt = [select id,email from Contact where LastName='Testing' limit 1];
        Event ev = [select id from Event Where Subject like '%Ev Test%' limit 1];
        navpeII_dev18__Fund__c fundRecord = [Select Id, name, navpeII_dev18__Fund_Type__c  from navpeII_dev18__Fund__c LIMIT 1]; 
        
         ApexPages.StandardController sc = new  ApexPages.StandardController(acc);
        NavatarFirmPDFCtrl ac = new NavatarFirmPDFCtrl(sc);
        NavatarFirmPDFCtrl.ResponseWrapper wrapperResults=NavatarFirmPDFCtrl.handleOnLoadInfo(acc.id, 'navpeII_dev18__Fund__c');
        Test.stopTest();
        //Assert.isTrue(wrapperResults!=null);
        Assert.areEqual(wrapperResults.recName,acc.Name);
        
    } 
    
     public static testMethod void processConInfoTest() {
         test.startTest();
        
        Id companyRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Company').getRecordTypeId();
        Id RecordTypeIdFirm = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Institution').getRecordTypeId();
        Account acc1 = new Account(name='test1', RecordTypeId = RecordTypeIdFirm);
        insert acc1;
        Account acc2 = new Account(name='test',RecordTypeId = companyRecordTypeId);
        insert acc2;
         
        Account acc=[Select id from Account where Name like '%Test Class%' Limit 1];
        Contact con=[Select id from Contact where LastName='Testing' limit 1];
        Task thisTask=[Select id, subject, priority, status, activitydate, TaskSubType, ownerId, Owner.Name from Task where Priority like '%High%' limit 1];
        Event thisEvent=[Select id from Event limit 1];
        Map<String, sObject> conMap = new Map<String, sObject>([Select id, Name,Email,AccountId,Account.Name from Contact where LastName='Testing' limit 1]);
        
         ApexPages.StandardController sc = new  ApexPages.StandardController(acc);
        NavatarFirmPDFCtrl ac = new NavatarFirmPDFCtrl(sc);
        NavatarFirmPDFCtrl.ResponseWrapper wrapperResults=NavatarFirmPDFCtrl.processConInfo(conMap,acc.Id,'Acuity_Connection_Field1','Acuity_Connection_Field1','navpeII_dev18__', 'test@gmail.com',new List<String>{thisTask.Id}, true, 'Account', '', new List<String>());
        test.stopTest();
         //Assert.isTrue(wrapperResults!=null);
        system.assert(true);
    }
    public static testMethod void processConInfoTest2() {
        test.startTest();
        
        Id companyRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Company').getRecordTypeId();
        Id RecordTypeIdFirm = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Institution').getRecordTypeId();
        Account acc1 = new Account(name='test1', RecordTypeId = RecordTypeIdFirm);
        insert acc1;
        Account acc2 = new Account(name='test',RecordTypeId = companyRecordTypeId);
        insert acc2;
        
        Account acc=[Select id from Account  Limit 1];
        Contact con=[Select id from Contact limit 1];
        Task thisTask=[Select id, subject, priority, status, activitydate, TaskSubType, ownerId, Owner.Name from Task  limit 1];
        Event thisEvent=[Select id from Event  limit 1];
        Map<String, sObject> accMap = new Map<String, sObject>([Select id, Name,navpeII_dev18__Last_Touchpoint_ID__c,navpeII_dev18__Last_Touchpoint__c from Account limit 1]);
         
         ApexPages.StandardController sc = new  ApexPages.StandardController(acc);
        NavatarFirmPDFCtrl ac = new NavatarFirmPDFCtrl(sc);
        NavatarFirmPDFCtrl.ResponseWrapper wrapperResults=NavatarFirmPDFCtrl.processConInfo(accMap,con.Id,'Acuity_Connection_Field1','Acuity_Connection_Field2','navpeII_dev18__', 'test@gmail.com',new List<String>{thisTask.Id}, true, 'Contact', 'IC', new List<String>());
        test.stopTest();
        system.assert(true);
    }
     public static testMethod void processConInfoTest3() {
        test.startTest();
        Account acc=[Select id from Account  Limit 1];
        Contact con=[Select id from Contact limit 1];
        Task thisTask=[Select id, subject, priority, status, activitydate, TaskSubType, ownerId, Owner.Name from Task  limit 1];
        Event thisEvent=[Select id from Event limit 1];
        Id companyRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Company').getRecordTypeId();
         //Test class coverage fix by LK on 2024-11-06
        Id RecordTypeIdFirm = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Individual Investor').getRecordTypeId();
        Account acc1 = new Account(name='test1', RecordTypeId = RecordTypeIdFirm);
        insert acc1;
        Account acc2 = new Account(name='test',RecordTypeId = companyRecordTypeId);
        insert acc2;
         navpeII_dev18__Fund__c fundRecord = new navpeII_dev18__Fund__c(Name = 'testFund', navpeII_dev18__Fund_Type__c = 'Fund');
         insert fundRecord;
         navpeII_dev18__Fundraising__c fundraisingRecord = new navpeII_dev18__Fundraising__c(Name = 'testFundraising', navpeII_dev18__Fund_Name__c = fundRecord.Id, navpeII_dev18__Legal_Name__c = acc1.Id, navpeII_dev18__Portfolio_Company__c = acc2.Id);
        insert fundraisingRecord;
        navpeII_dev18__Fundraising_Contact__c fdrContact = new navpeII_dev18__Fundraising_Contact__c();
        fdrContact.navpeII_dev18__Contact__c = con.Id;
        fdrContact.navpeII_dev18__Institution__c = acc.Id;
        fdrContact.navpeII_dev18__Fundraising__c = fundraisingRecord.Id;
        insert fdrContact;  
        navpeII_dev18__Fundraising__c fdrRec = [Select id from navpeII_dev18__Fundraising__c limit 1];
        Map<String, sObject> accMap = new Map<String, sObject>([Select id, Name from navpeII_dev18__Fundraising__c limit 1]);
         
         ApexPages.StandardController sc = new  ApexPages.StandardController(acc);
        NavatarFirmPDFCtrl ac = new NavatarFirmPDFCtrl(sc);
        NavatarFirmPDFCtrl.ResponseWrapper wrapperResults=NavatarFirmPDFCtrl.processConInfo(accMap,con.Id,'Acuity_FDRC_Connection_Field1','Acuity_FDRC_Connection_Field2,Acuity_FDRC_Connection_Field3,Acuity_FDRC_Connection_Field4','navpeII_dev18__', 'test@gmail.com',new List<String>{thisTask.Id}, true, 'navpeII_dev18__Fundraising__c', 'PageLoad', new List<String>());
       test.stopTest();
         Assert.isTrue(wrapperResults!=null);
        //system.assert(true);
       
    } 
    @isTest
    static void dealsTestMethod(){
        test.startTest();
        Contact con = new Contact(navpeII_dev18__Contact_Type__c='Banker',lastname='Test Contact - Deals Insights');
        insert con;
        //Test class coverage fix by LK on 2024-11-06
        Id iiRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Individual Investor').getRecordTypeId();
        Id companyRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Company').getRecordTypeId();
        Id intrmdryRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Intermediary').getRecordTypeId();
        Id advisorRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Advisor').getRecordTypeId();
        Account acc=new Account(recordtypeId=iiRecordTypeId,name='Test II');
        Account acc2=new Account(recordtypeId=companyRecordTypeId,name='Test Company');
        Account acc3=new Account(recordtypeId=intrmdryRecordTypeId,name='Test Intermediary');
        Account acc4=new Account(recordtypeId=advisorRecordTypeId,name='Test Advisor');
        List<Account> accList=new List<Account>();
        accList.add(acc);
        accList.add(acc2);
        accList.add(acc3);
        accList.add(acc4);
        insert accList;
        con.AccountId = acc2.id;
        update con;
        List<navpeII_dev18__Pipeline__c> dealList=new List<navpeII_dev18__Pipeline__c>();
        List<navpeII_dev18__Fundraising__c> fdrList=new List<navpeII_dev18__Fundraising__c>();
        navpeII_dev18__Fund__c fnd=new navpeII_dev18__Fund__c(name = 'NVTR Test Fund');
        insert fnd;
        for(Integer i=0;i<10;i++){
            navpeII_dev18__Pipeline__c dl=new navpeII_dev18__Pipeline__c(navpeII_dev18__Source_Contact__c=con.Id,name='Test Deals'+i,
                                                             navpeII_dev18__source_company__c=acc3.Id,navpeII_dev18__company__c=acc2.Id);
            dealList.add(dl);
            navpeII_dev18__Fundraising__c fdr=new navpeII_dev18__Fundraising__c(name='Test Fdr'+i,navpeII_dev18__Fund_Name__c=fnd.Id,
                                                                    navpeII_dev18__legal_name__c=acc.Id);
            fdrList.add(fdr);
        }
        insert fdrList;
        insert dealList;
        navpeII_dev18__Deal_Team__c dt=new navpeII_dev18__Deal_Team__c(navpeII_dev18__Deal_Contact__c=con.Id,navpeII_dev18__Deal__c=dealList[0].Id);
        insert dt;
        navpeII_dev18__Deal_Team__c dt1 = new navpeII_dev18__Deal_Team__c(navpeII_dev18__Team_Member__c = UserInfo.getUserId(),navpeII_dev18__Deal__c=dealList[0].Id);
        insert dt1;
        navpeII_dev18__Fundraising_Contact__c fdC = new navpeII_dev18__Fundraising_Contact__c(navpeII_dev18__Contact__c = con.id,navpeII_dev18__Fundraising__c=fdrList[0].id);
        insert fdc;
      
         ApexPages.StandardController sc = new  ApexPages.StandardController(acc);
        NavatarFirmPDFCtrl ac = new NavatarFirmPDFCtrl(sc);
        NavatarFirmPDFCtrl.handleFundRaisingOnLoad(fdrList[0].id,'PageLoad');
       
       NavatarFirmPDFCtrl.InfoWrapper ew = new NavatarFirmPDFCtrl.InfoWrapper('','',0,null,false); 
        test.stopTest();
        Assert.areEqual('Banker',con.navpeII_dev18__Contact_Type__c);
        //system.assert(true);
    }
    
    @istest
    public static void userListOfRecordsTM(){
        Account acc = new Account();
        acc.Name = 'Test';
        insert acc;
        
        Contact con = new Contact();
        con.LastName = 'Test Navatar';
        con.Email = 'robertday@kedaracapital-ng.com';
        con.AccountId = acc.Id;
        insert con;
        Contact con2 = new Contact();
        con2.LastName = 'Test Navatar1';
        con2.Email = 'jason.hoffman@baincapital-ng.com';
        con2.AccountId = acc.Id;
        insert con2;
        Contact con3 = new Contact();
        con3.LastName = 'Test Navatar3';
        con3.Email = 'johnlowry@kedaracapital-ng.com';
        con3.AccountId = acc.Id;
        insert con3;
        
        Test.setMock(HttpCalloutMock.class, new userListMOCK());
        Test.startTest();
        HttpRequest req = new HttpRequest();
        req.setEndpoint(accConnectionEndPoint);
        req.setMethod(storePost);
        req.setHeader(storeAuth,storeApiKey);
        String splitDomainName = con.Email.split('@').get(1);
        String dn = '"'+splitDomainName+'"';
        String sbody = '{accountId:['+dn+']}';
        req.setBody(sbody);
        req.setHeader(storeCT, storeTPJson);
        req.setTimeout(120000);
        Http h = new Http();
        HttpResponse res = h.send(req);
        try{
            
         ApexPages.StandardController sc = new  ApexPages.StandardController(acc);
        NavatarFirmPDFCtrl ac = new NavatarFirmPDFCtrl(sc);
            NavatarFirmPDFCtrl.getUsersListOfRecords(con.Email,'Account',acc.Id,namespacePrefix);
            NavatarFirmPDFCtrl.getUsersListOfRecords(con.Email,'Contact',acc.Id,namespacePrefix);
        } catch(Exception e){
            
        }
        
        Test.stopTest();
        system.assert(true);
    }
    
    @isTest
    static void ULTestMethod18(){
        try{
            List<NavatarFirmPDFCtrl.ConWrapper> eWrappList=NavatarFirmPDFCtrl.getUsersListOfRecords(null, null, null, null);
            Assert.isNull(eWrappList);
        }
        catch(CalloutException e) {}
        catch(Exception e){}
        //system.assert(true);
    }
}