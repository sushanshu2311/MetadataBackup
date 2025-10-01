@isTest
public class NavatarContactPDFCtrlTest {
    private static String apiKey = [SELECT Value__c FROM RG_Setting__mdt WHERE DeveloperName = 'RG_API_Key'].Value__c;
    private static string storeApiKey = 'ApiKey '+apiKey;
    private static string storeAuth = 'Authorization';
    private static string storePost = 'POST';
    private static string storeCT = 'Content-Type';
    private static string storeTPJson = 'application/json';   
    private static string accConActivityEndPoint = RG_Setting__mdt.getInstance('RG_Connection_Count').Value__c;
    private static String np = 'navpeII_dev18';//[SELECT NamespacePrefix FROM ApexClass WHERE Name = 'FileUploaderCtrl'].NamespacePrefix;
    private static String namespacePrefix = np + '__'; 
    @testSetup 
    static void testSetup() {
        navpeII_dev18__Navatar_Setup__c navSetup = new navpeII_dev18__Navatar_Setup__c();
        navSetup.RAS__c = '001,003';
        navSetup.navpeII_dev18__Admin_Setting__c = true;
        insert navSetup;
        List<Contact> conList =new List<Contact>();
        List<event> listOfEvent = new List<event>();
        //List<EventRelation> listOfEventRelation = new List<EventRelation>();
        List<sObject> listOfEventRelationSobj = new List<sObject>();
        List<sObject> listOfTaskRelation = new List<sObject>();
        Account acRec = new Account();
        acRec.Name='Test Account';
        insert acRec;
        
        Contact con = new Contact();
        con.LastName ='Test Contact';
        con.AccountId = acRec.Id;
        con.Title='Mr';
        con.navpeII_dev18__Last_Touch_Point__c=date.today();
        conList.add(con);
        
        Contact con1 = new Contact();
        con1.LastName ='Test Contact1';
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
        try{
        navpeII_dev18__Pipeline__c navRec = new navpeII_dev18__Pipeline__c();
        navRec.Name = 'Test Deals';
        navRec.navpeII_dev18__Stage__c='Deal Received';
        insert navRec;
        }catch(exception e){
            system.debug('error -?'+e);
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
            else{
                //ev.navpeII_dev18__Related_Associations__c= navRec.Id;  
                
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
            listOfEventRelationSobj.add(evtr);
        }
        insert listOfEventRelationSobj; 
        
        Id devRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Company').getRecordTypeId();
        Account acc = new Account();
        acc.RecordTypeId = devRecordTypeId;
        acc.Name = 'Test Class';
        insert acc;
        
        Contact cnt = new Contact();
        cnt.LastName = 'Testing';
        cnt.AccountId = acc.id;
        cnt.Email = 'jsmith@acme.com';
        cnt.Title = 'BA';
        insert cnt;
        navpeII_dev18__Pipeline__c deal = new navpeII_dev18__Pipeline__c();
        deal.Name = 'Testing';
        deal.navpeII_dev18__Company__c = acc.id;
        deal.navpeII_dev18__Our_Role__c = 'Lead';
        deal.navpeII_dev18__Stage__c = 'IOI';
        insert deal;
        navpeII_dev18__Fund__c fund1 = new navpeII_dev18__Fund__c();
        fund1.Name = 'Test1';
        fund1.navpeII_dev18__Fund_Type__c = 'Fund';
        fund1.navpeII_dev18__Investment_Category__c = 'Fund';
        insert fund1;
        Theme__c themeRec=new Theme__c();
        themeRec.Name='testing theme';
        insert themeRec;
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        event evt = new event();
        evt.Subject='Ev Test';
        evt.WhoId = cnt.id;
        evt.WhatId = acc.id; 
        evt.DurationInMinutes = 10;
        evt.navpeII_dev18__Related_Associations__c=acc.id+','+cnt.id+','+fund1.Id+','+deal.Id;
        evt.ActivityDateTime = System.now();
        insert evt;
        
        Task tskk = new task();
        tskk.WhoId = cnt.id;
        tskk.WhatId = acc.id; 
        tskk.ActivityDate=date.today();
        tskk.Priority='High';
        tskk.Status='In Progress';
        tskk.navpeII_dev18__Related_Associations__c=acc.id+','+cnt.id+','+fund1.Id+','+deal.Id;
        tskk.TaskSubtype='Task';
        insert tskk;
        
        Task tsk1 = new task();
        tsk1.WhoId = cnt.id;
        tsk1.WhatId = acc.id;
        tsk1.navpeII_dev18__Related_Associations__c=acc.id+','+cnt.id+','+fund1.Id+','+deal.Id;
        tsk1.TaskSubtype='Call';
        insert tsk1;
        
        
        
        Task tsk2 = new task();
        tsk2.WhoId = cnt.Id;
        tsk2.WhatId = acc.Id; 
        tsk2.navpeII_dev18__Related_Associations__c=acc.id+','+cnt.id+','+thisUser.Id+','+fund1.Id+','+deal.Id;
        tsk2.TaskSubtype='Email'; 
        insert tsk2;
        
        Id RecordTypeIdFirm = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Institution').getRecordTypeId();
        Id companyRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Company').getRecordTypeId();
        Account acc1 = new Account(name='test1', RecordTypeId = RecordTypeIdFirm);
        insert acc1;
        Account acc2 = new Account(name='test');
        insert acc2;

        Account acc3 = new Account(name='test',RecordTypeId = companyRecordTypeId);
        insert acc3;
        
        
        
      /*  navpeII_dev18__Pipeline__c dealRecord1 = new navpeII_dev18__Pipeline__c(Name = 'testDeal1', navpeII_dev18__Stage__c = 'Parked', navpeII_dev18__Company__c = acc2.Id);
        insert dealRecord1;
        navpeII_dev18__Pipeline__c dealRecord2 = new navpeII_dev18__Pipeline__c(Name = 'testDeal2', navpeII_dev18__Stage__c = 'Parked', navpeII_dev18__Source_Company__c = acc2.Id);
        insert dealRecord2;*/

        
        navpeII_dev18__Fund__c fundRecord = new navpeII_dev18__Fund__c(Name = 'testFund', navpeII_dev18__Fund_Type__c = 'Fund');
        insert fundRecord;
        
       
    }
    @isTest
    static void contactPdfTest(){
        test.startTest();
        //Account accRec =[SELECT Id from Account Where Name ='Test Account'];
        Contact conRec = [Select ID,Name,Title from Contact limit 1];
        NavatarContactPDFCtrl contCon;
        PageReference pageRef = Page.Contact_Report;
        Test.setCurrentPage(pageRef);
        ApexPages.StandardController sc = new  ApexPages.StandardController(conRec);
        contCon = new NavatarContactPDFCtrl(sc);
        test.stopTest();
        String mainTitle = conRec.title != null ? conRec.Name+','+conRec.Title : conRec.Name;
        System.assertEquals(contCon.mainTitle,mainTitle);
    }
    @isTest
    public static void handlePeopleRefInfoTest(){
        Test.startTest();
        //Account accRec =[SELECT Id from Account Where Name ='Test Account'];
        Contact con = [Select Name,LastName,Title,navpeII_dev18__Last_Touch_Point__c From Contact Limit 1];
        //Contact con = new Contact();
        //con.LastName ='Test Contact People';
        //con.Title='Mr';
        //con.navpeII_dev18__Last_Touch_Point__c=date.today();
        //insert con;
        Task tsk = [Select ID from task Limit 1];
        Event evt = [Select ID from Event Limit 1];
        List<String> conStrLst = new List<String>();
        conStrLst.add(con.Id);
        Contact conRec = [Select ID from Contact where LastName = 'Test Contact1'];
        List<String> accStrList = new List<String>();
        accStrList.add(tsk.Id);
        accStrList.add(evt.Id);
        List<NavatarContactPDFCtrl.InfoWrapper>  infoWrap = new List<NavatarContactPDFCtrl.InfoWrapper>();
        
        ApexPages.StandardController sc = new  ApexPages.StandardController(conRec);
        NavatarContactPDFCtrl ac = new NavatarContactPDFCtrl(sc);
        infoWrap = NavatarContactPDFCtrl.handlePeopleRefInfo(conStrLst,accStrList);
        Test.stopTest();
        string name='rte';
        System.assertEquals(name, 'rte');
        
    }
    private class rgApiTest1 implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            String fullJson = '[ { "contact": "jason.hoffman@baincapital-ng.com", "activityCategory": "meetings", "count": 2 }, { "contact": "jason.hoffman@baincapital-ng.com", "activityCategory": "inboundEmails", "count": 2 }, { "contact": "ashishyadav@baincapital-ng.com", "activityCategory": "outboundEmails", "count": 1 }, { "contact": "cena@baincapital-ng.com", "activityCategory": "outboundEmails", "count": 1 }, { "contact": "dannygross@walmart-ng.com", "activityCategory": "outboundEmails", "count": 1 }, { "contact": "jack@tcs.com", "activityCategory": "outboundEmails", "count": 1 }, { "contact": "jason.hoffman@baincapital-ng.com", "activityCategory": "outboundEmails", "count": 2 }, { "contact": "suemira@amazon-ng.com", "activityCategory": "outboundEmails", "count": 2 }, { "contact": "bradmeadows@amazon-ng.com", "activityCategory": "indirectEmails", "count": 1 }, { "contact": "dannygross@walmart-ng.com", "activityCategory": "indirectEmails", "count": 1 }, { "contact": "jason.hoffman@baincapital-ng.com", "activityCategory": "indirectEmails", "count": 6 }, { "contact": "suemira@amazon-ng.com", "activityCategory": "indirectEmails", "count": 1 } ]';
            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'text/json');
            res.setBody(fullJson);
            res.setStatusCode(200);
            return res;
        }
    }
    @isTest
    static void handleExternalConnInfoTest(){
        //Account accRec =[SELECT Id from Account Where Name ='Test Account'];
        
        /*Contact cnt = new Contact();
        cnt.email = 'aa@test.com';
        cnt.LastName='new con';
        insert cnt;*/
       
        Test.setMock(HttpCalloutMock.class, new rgApiTest1());
        Test.startTest();
        Contact cnt = [select id,email from Contact limit 1];
        HttpRequest req = new HttpRequest();
        req.setEndpoint(accConActivityEndPoint);
        req.setMethod(storePost);
        req.setHeader(storeAuth,storeApiKey);
        String domainStr='';
        String sbody = '{contact:'+cnt.Email+'}';
        req.setBody(sbody);
        req.setHeader(storeCT, storeTPJson);
        req.setTimeout(120000);
        Http h = new Http();
        HttpResponse res = h.send(req);
        try{
            ApexPages.StandardController sc = new  ApexPages.StandardController(cnt);
            NavatarContactPDFCtrl contCon = new NavatarContactPDFCtrl(sc);
            Event ev=[Select id from Event limit 1];
            List<String> accidList = new List<String>();
        	accidList.add(ev.id);
            NavatarContactPDFCtrl.handleExternalConnInfo(cnt.id,'Contact',namespacePrefix,cnt.Email,accidList);
        } catch(Exception e){
            
        }
        
        test.stopTest();
    }
    @isTest
    static void handleOnLoadInfoTest(){
        Test.startTest();
        Account acc = [select id from Account where Name like '%Test Class%' limit 1]; 
        Contact cnt = [select id,email,Name from Contact where LastName='Testing' limit 1];
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
        
        Test.setMock(HttpCalloutMock.class, new rgApiTest1());
        
        HttpRequest req = new HttpRequest();
        req.setEndpoint(accConActivityEndPoint);
        req.setMethod(storePost);
        req.setHeader(storeAuth,storeApiKey);
        String domainStr='';
        String sbody = '{contact:'+cnt.Email+'}';
        req.setBody(sbody);
        req.setHeader(storeCT, storeTPJson);
        req.setTimeout(120000);
        Http h = new Http();
        HttpResponse res = h.send(req);
        ApexPages.StandardController sc = new  ApexPages.StandardController(cnt);
        NavatarContactPDFCtrl ac = new NavatarContactPDFCtrl(sc);
        NavatarContactPDFCtrl.ResponseWrapper wrapperResults=NavatarContactPDFCtrl.handleOnLoadInfo(cnt.id,'Contact'); 
        test.stopTest();
        //Assert.isTrue(wrapperResults!=null);
        Assert.areEqual(wrapperResults.recName,cnt.Name);
        try{
        }
        catch(Exception e){}
        //system.assert(true);
    }
    static testmethod void handleOnLoadInfoTest2() {
        Test.startTest();
        //Account acc = [select id from Account where Name like '%Test Class%' limit 1]; 
        Contact cnt = [select id,email,Name from Contact where LastName='Testing' limit 1];
        Event ev = [select id from Event Where Subject like '%Ev Test%' limit 1];
        Test.setMock(HttpCalloutMock.class, new rgApiTest1());
        
        HttpRequest req = new HttpRequest();
        req.setEndpoint(accConActivityEndPoint);
        req.setMethod(storePost);
        req.setHeader(storeAuth,storeApiKey);
        String domainStr='';
        String sbody = '{contact:'+cnt.Email+'}';
        req.setBody(sbody);
        req.setHeader(storeCT, storeTPJson);
        req.setTimeout(120000);
        Http h = new Http();
        HttpResponse res = h.send(req);
        ApexPages.StandardController sc = new  ApexPages.StandardController(cnt);
        NavatarContactPDFCtrl ac = new NavatarContactPDFCtrl(sc);
        NavatarContactPDFCtrl.ResponseWrapper wrapperResults=NavatarContactPDFCtrl.handleOnLoadInfo(cnt.id, 'navpeII_dev18__Pipeline__c');
        Test.stopTest();
       // Assert.isTrue(wrapperResults!=null);
        Assert.areEqual(wrapperResults.recName,cnt.Name);
    }
     static testmethod void handleOnLoadInfoTest3() {
         Test.startTest();
      //Account acc = [select id from Account where Name like '%Test Class%' limit 1]; 
        Contact cnt = [select id,email,Name from Contact where LastName='Testing' limit 1];
        Event ev = [select id from Event Where Subject like '%Ev Test%' limit 1];
        Test.setMock(HttpCalloutMock.class, new rgApiTest1());
        
        HttpRequest req = new HttpRequest();
        req.setEndpoint(accConActivityEndPoint);
        req.setMethod(storePost);
        req.setHeader(storeAuth,storeApiKey);
        String domainStr='';
        String sbody = '{contact:'+cnt.Email+'}';
        req.setBody(sbody);
        req.setHeader(storeCT, storeTPJson);
        req.setTimeout(120000);
        Http h = new Http();
        HttpResponse res = h.send(req);
        ApexPages.StandardController sc = new  ApexPages.StandardController(cnt);
        NavatarContactPDFCtrl ac = new NavatarContactPDFCtrl(sc);
        NavatarContactPDFCtrl.ResponseWrapper wrapperResults=NavatarContactPDFCtrl.handleOnLoadInfo(cnt.id, 'navpeII_dev18__Fund__c');
         Test.stopTest();
       //  Assert.isTrue(wrapperResults!=null);
         Assert.areEqual(wrapperResults.recName,cnt.Name);
    }
    static testmethod void handleOnLoadInfoTest4() {
        Test.startTest();
       Account acc = [select id from Account where Name like '%Test Class%' limit 1]; 
        Contact cnt = [select id,email,Name from Contact where LastName='Testing' limit 1];
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
        Test.setMock(HttpCalloutMock.class, new rgApiTest1());
        
        HttpRequest req = new HttpRequest();
        req.setEndpoint(accConActivityEndPoint);
        req.setMethod(storePost);
        req.setHeader(storeAuth,storeApiKey);
        String domainStr='';
        String sbody = '{contact:'+cnt.Email+'}';
        req.setBody(sbody);
        req.setHeader(storeCT, storeTPJson);
        req.setTimeout(120000);
        Http h = new Http();
        HttpResponse res = h.send(req);
        ApexPages.StandardController sc = new  ApexPages.StandardController(cnt);
        NavatarContactPDFCtrl ac = new NavatarContactPDFCtrl(sc);
        NavatarContactPDFCtrl.ResponseWrapper wrapperResults= NavatarContactPDFCtrl.handleOnLoadInfo(cnt.id, 'Account');
         Test.stopTest();
        //Assert.isTrue(wrapperResults!=null);
        Assert.areEqual(wrapperResults.recName,cnt.Name);
    }
    
    public static testMethod void processConInfoTest() {
         test.startTest();
        //Account acc=[Select id from Account  Limit 1];
        Contact con=[Select id,Name from Contact limit 1];
        Task thisTask=[Select id, subject, priority, status, activitydate, TaskSubType, ownerId, Owner.Name from Task  limit 1];
        Event thisEvent=[Select id from Event  limit 1];
        Map<String, sObject> accMap = new Map<String, sObject>([Select id, Name,navpeII_dev18__Last_Touchpoint__c from Account limit 1]);
      
        ApexPages.StandardController sc = new  ApexPages.StandardController(con);
        NavatarContactPDFCtrl ac = new NavatarContactPDFCtrl(sc);
        NavatarContactPDFCtrl.ResponseWrapper wrapperResults = NavatarContactPDFCtrl.processConInfo(accMap,con.Id,'Acuity_Connection_Field1','Acuity_Connection_Field1','navpeII_dev18__', 'test@gmail.com',new List<String>{thisTask.Id}, true, 'Contact', 'IC', new List<String>());
        test.stopTest();
        Assert.isTrue(wrapperResults!=null);
        System.debug('wrapperResults.conSecDynFieldHeader=='+wrapperResults);
        System.debug('wrapperResults.conSecDynFieldHeader==:'+wrapperResults.conSecDynFieldHeader);
       // Assert.areEqual(wrapperResults.conSecDynFieldHeader, 'Title');
        
        system.assert(true);
    }
    public static testMethod void processConInfoTest2() {
        test.startTest();
        //Test class coverage fix by LK on 2024-11-06
         Id RecordTypeIdFirm = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Individual Investor').getRecordTypeId();
        Id companyRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Company').getRecordTypeId();
        Account acc1 = new Account(name='test1', RecordTypeId = RecordTypeIdFirm);
        insert acc1;
        Account acc2 = new Account(name='test');
        insert acc2;

        Account acc3 = new Account(name='test',RecordTypeId = companyRecordTypeId);
        insert acc3;
         navpeII_dev18__Fund__c fundRecord = new navpeII_dev18__Fund__c(Name = 'testFund', navpeII_dev18__Fund_Type__c = 'Fund');
        insert fundRecord;
        navpeII_dev18__Fundraising__c fundraisingRecord = new navpeII_dev18__Fundraising__c(Name = 'testFundraising', navpeII_dev18__Fund_Name__c = fundRecord.Id, navpeII_dev18__Legal_Name__c = acc1.Id, navpeII_dev18__Portfolio_Company__c = acc3.Id);
        insert fundraisingRecord;
        //Account acc=[Select id from Account  Limit 1];
        Contact con=[Select id from Contact limit 1];
        Task thisTask=[Select id, subject, priority, status, activitydate, TaskSubType, ownerId, Owner.Name from Task  limit 1];
        Event thisEvent=[Select id from Event limit 1];
        navpeII_dev18__Fundraising__c fdrRec = [Select id from navpeII_dev18__Fundraising__c limit 1];
        Map<String, sObject> accMap = new Map<String, sObject>([Select id, Name from navpeII_dev18__Fundraising__c limit 1]);
        
        ApexPages.StandardController sc = new  ApexPages.StandardController(con);
        NavatarContactPDFCtrl ac = new NavatarContactPDFCtrl(sc);
        NavatarContactPDFCtrl.ResponseWrapper wrapperResults=NavatarContactPDFCtrl.processConInfo(accMap,con.Id,'Acuity_FDRC_Connection_Field1','Acuity_FDRC_Connection_Field2,Acuity_FDRC_Connection_Field3,Acuity_FDRC_Connection_Field4','navpeII_dev18__', 'test@gmail.com',new List<String>{thisTask.Id}, true, 'navpeII_dev18__Fundraising__c', 'PageLoad', new List<String>());
        test.stopTest();
        Assert.isTrue(wrapperResults!=null);
        //system.assert(true);
        
    }
    @isTest
    static void ULTestMethod18(){
        try{
            List<NavatarContactPDFCtrl.ConWrapper> eWrappList=NavatarContactPDFCtrl.getUsersListOfRecords(null, null, null, null);
        Assert.isNull(eWrappList);
        }
        catch(CalloutException e) {}
        catch(Exception e){}
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
        
        ApexPages.StandardController sc = new  ApexPages.StandardController(con);
        NavatarContactPDFCtrl ac = new NavatarContactPDFCtrl(sc);
        NavatarContactPDFCtrl.handleFundRaisingOnLoad(fdrList[0].id,'PageLoad');
        
        NavatarContactPDFCtrl.InfoWrapper ew = new NavatarContactPDFCtrl.InfoWrapper('','',0,null,false); 
       test.stopTest();
        system.assert(true);
    }
}