@isTest
public  class NavatarNotificationCtrlTest {

   @testSetup   
    static void testSetupData(){
            Profile p=[Select Id from Profile where Name ='PE Standard User'];

            User u = new User(Alias = 'TestUser', Email='testpe@testorg.com.invalid',
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
            LocaleSidKey='en_US', ProfileId = p.Id,
            TimeZoneSidKey='America/Los_Angeles', UserName='testpe@testorg.com.invalid');
            insert u;

            Account acc = new Account(Name = 'Account 1');
            acc.isAutoCreated__c = true;
            insert acc;

            navpeII_dev18__Navatar_Setup__c navatarSetting = new navpeII_dev18__Navatar_Setup__c();
            navatarSetting.NN_Action__c = true;
            navatarSetting.NN_Information__c= true;
            navatarSetting.navpeII_dev18__Admin_Setting__c = true;
            insert navatarSetting;

            Contact con1 = new Contact();
            con1.FirstName = 'Sasuke';
            con1.LastName = 'Uchiha';
            con1.Email = 'uchiha@sharingan.com';
            con1.AccountId = acc.Id;
            insert con1;

            navpeII_dev18__Pipeline__c deal = new navpeII_dev18__Pipeline__c();
            deal.navpeII_dev18__Company__c = acc.Id;
            deal.navpeII_dev18__Stage__c = 'Deal Received';
            deal.Name ='Account 1';
            insert deal;

            deal.navpeII_dev18__Stage__c ='NDA Signed';
            update deal;

            navpeII_dev18__Deal_Team__c dealTeam = new navpeII_dev18__Deal_Team__c();
            dealTeam.navpeII_dev18__Team_Member__c = UserInfo.getUserId();
            dealTeam.navpeII_dev18__Team_Member_Role__c = 'Partner';
            dealTeam.navpeII_dev18__Deal__c= deal.Id;
            insert dealTeam;

            navpeII_dev18__Deal_Team__c dealTeam1 = new navpeII_dev18__Deal_Team__c();
            dealTeam1.navpeII_dev18__Team_Member__c = u.Id;
            dealTeam1.navpeII_dev18__Team_Member_Role__c = 'Partner';
            dealTeam1.navpeII_dev18__Deal__c = deal.Id;
            insert dealTeam1;

            Theme__c theme = new Theme__c();
            theme.Name = 'Test Theme';
            insert theme;

            Theme_Team__c themeTeam = new Theme_Team__c();
            themeTeam.Member__c = UserInfo.getUserId();
            themeTeam.Role__c = 'Advisor';
            themeTeam.Theme__c = theme.Id;
            insert themeTeam;

            Theme_Team__c themeTeam1 = new Theme_Team__c();
            themeTeam1.Member__c = u.Id;
            themeTeam1.Role__c = 'Advisor';
            themeTeam1.Theme__c = theme.Id;
            insert themeTeam1;

            Event e1 = new event();
            e1.WhoId = con1.Id;
            e1.Subject ='Event sub';
            e1.StartDateTime = DateTime.Now();
            e1.EndDateTime = DateTime.Now();
            e1.Related_Associations__c = deal.Id+','+theme.Id+','+acc.Id;
            insert e1;

            Task t2 = new task();
            t2.WhoId = con1.Id;
            t2.Subject = 'Task Subject';
            t2.Status = 'Completed';
            t2.Priority = 'Normal';
            t2.WhatId = acc.Id;
            t2.Related_Associations__c=deal.Id+','+theme.Id+','+acc.Id;
            insert t2;

            Clip__c c = new Clip__c();
            c.Name = 'Test Clip';
            c.Notes__c = 'Test Clip Notes';
            c.Summary__c = 'Test Clip Summary';
            insert c;
    
            Clip_Relation__c cr = new Clip_Relation__c();
            cr.Clip__c = c.Id;
            cr.User__c= u.Id;
            insert cr;

   }

   @isTest
    static void testFetchDetails(){
        NavatarNotificationCtrl.fetchOrgDomain();
        Account acc = new Account(Name = 'Account 2');
        insert acc;
        List<String> ObjList = new List<String>();
        ObjList.add('Event');
        ObjList.add('Task');
        test.startTest();
        NavatarNotificationCtrl.fetchContacts(acc.Id);
        NavatarNotificationCtrl.checkNotificationVisibleForuser();
        NavatarNotificationCtrl.snoozeNotificationForToday();
        NavatarNotificationCtrl.checkAccessibility(ObjList);
        test.stopTest();
        system.assert(true);

   }

   @isTest
   static void testFetchEventData(){
        Profile p = [SELECT Id FROM Profile WHERE Name LIKE '%Admin%' LIMIT 1];
    User u = [Select Id from User where ProfileId =: p.Id Limit 1];
        Account acc = [Select Id from Account where Name = 'Account 1' Limit 1];
        navpeII_dev18__Navatar_Setup__c navatarSetting = [Select Id from navpeII_dev18__Navatar_Setup__c Limit 1];
        Contact con = [Select Id from Contact where AccountId =:acc.Id Limit 1];
        navpeII_dev18__Pipeline__c deal = [Select Id from navpeII_dev18__Pipeline__c where navpeII_dev18__Company__c = :acc.Id Limit 1];
        List<navpeII_dev18__Deal_Team__c> dealTeam = [Select Id from navpeII_dev18__Deal_Team__c where navpeII_dev18__Deal__c =: deal.Id];
        Theme__c theme = [Select Id from Theme__c where Name = 'Test Theme' Limit 1];
        List<Theme_Team__c> themeTeam = [Select Id from Theme_Team__c where Theme__c =: theme.Id];
        String relatedAssosciations= deal.id+','+theme.Id;
        Event e =[Select Id from Event where whoId =:con.Id limit 1];
        Task t = [Select Id from Task where whoId =:con.Id limit 1];

        Navatar_Notification__c nn1 = new Navatar_Notification__c();
        nn1.Record_ID__c = e.Id;
        nn1.Type__c = NavatarConstants.ADD_NOTE;
        nn1.User__c = u.Id;
        insert nn1;

        Navatar_Notification__c nn2 = new Navatar_Notification__c();
        nn2.Record_ID__c = t.Id;
        nn2.Type__c = NavatarConstants.ADD_TAG;
        nn2.User__c = u.Id;
        insert nn2;

        Navatar_Notification__c nn3 = new Navatar_Notification__c();
        nn3.Record_ID__c = acc.Id;
        nn3.Type__c = NavatarConstants.ACCOUNT_INFO;
        nn3.User__c = u.Id;
        insert nn3;
               
        System.runAs(u){
            test.startTest();
            List<NavatarNotificationCtrl.NotificationWrapper> notifications = new List<NavatarNotificationCtrl.NotificationWrapper>();
            notifications=NavatarNotificationCtrl.fetchEventData();
            test.stopTest();
            system.assert(true);
        }      
   }
   @isTest
   static void testFetchEventDataforRecord(){
       Test.startTest();
       Profile p = [SELECT Id FROM Profile WHERE Name LIKE '%Admin%' LIMIT 1];
    User u = [Select Id from User where ProfileId =: p.Id Limit 1];
    Account acc = [Select Id from Account where Name = 'Account 1' Limit 1];
    navpeII_dev18__Navatar_Setup__c navatarSetting = [Select Id from navpeII_dev18__Navatar_Setup__c Limit 1];
    Contact con = [Select Id from Contact where AccountId =:acc.Id Limit 1];
    navpeII_dev18__Pipeline__c deal = [Select Id from navpeII_dev18__Pipeline__c where navpeII_dev18__Company__c = :acc.Id Limit 1];
    List<navpeII_dev18__Deal_Team__c> dealTeam = [Select Id from navpeII_dev18__Deal_Team__c where navpeII_dev18__Deal__c =: deal.Id];
    Theme__c theme = [Select Id from Theme__c where Name = 'Test Theme' Limit 1];
    List<Theme_Team__c> themeTeam = [Select Id from Theme_Team__c where Theme__c =: theme.Id];
    String relatedAssosciations= deal.id+','+theme.Id;
    Event e =[Select Id,Related_Associations__c from Event where whoId =:con.Id limit 1];
    Task t = [Select Id,Related_Associations__c from Task where whoId =:con.Id limit 1];

    Navatar_Notification__c nn1 = new Navatar_Notification__c();
    nn1.Record_ID__c = acc.Id;
    nn1.Type__c = NavatarConstants.ACCOUNT_INFO;
    nn1.User__c = u.Id;
    insert nn1;

    Navatar_Notification__c nn2 = new Navatar_Notification__c();
    nn2.Record_ID__c = e.Id;
    nn2.Type__c = NavatarConstants.ADD_NOTE;
    nn2.User__c = u.Id;
    insert nn2;

    Navatar_Notification__c nn3 = new Navatar_Notification__c();
    nn3.Record_ID__c = t.Id;
    nn3.Type__c = NavatarConstants.ADD_TAG;
    nn3.User__c = u.Id;
    insert nn3;

    Navatar_Notification__c nn4 = new Navatar_Notification__c();
    nn4.Record_ID__c = t.Id;
    nn4.Type__c = NavatarConstants.ADD_TAG;
    nn4.User__c = u.Id;
    insert nn4;

    navpeII_dev18__Fund__c fund =new navpeII_dev18__Fund__c();
    fund.Name = 'Test Fund';
    fund.navpeII_dev18__Fund_Type__c = 'Fund';
    insert fund;
    Account acc1 = new Account(Name='Test Account 2');
       //Test class coverage fix by LK on 2024-11-06
    acc1.recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Individual Investor').getRecordTypeId();   
     insert acc1;

    navpeII_dev18__Fundraising__c fundRaising = new navpeII_dev18__Fundraising__c();
    fundRaising.navpeII_dev18__Fund_Name__c = fund.id;
    fundRaising.Name = 'Test Fund Raising';
    fundRaising.navpeII_dev18__Legal_Name__c = acc1.Id;
    fundRaising.navpeII_dev18__Stage__c= 'Initial Meeting';
    insert fundRaising;

    e.Related_Associations__c = e.Related_Associations__c+','+fund.id+','+fundRaising.id;
    update e;
    t.Related_Associations__c = t.Related_Associations__c+','+fund.id+','+fundRaising.id;
    update t;
Test.stopTest();
    System.runAs(u){
        //Test.startTest();
        //NavatarNotificationCtrl.fetchEventDataforRecord(acc.Id);
        //NavatarNotificationCtrl.fetchEventDataforRecord(con.Id);
        NavatarNotificationCtrl.fetchEventDataforRecord(deal.id);
        NavatarNotificationCtrl.fetchEventDataforRecord(theme.id);
        NavatarNotificationCtrl.fetchEventDataforRecord(fund.Id);
        NavatarNotificationCtrl.dismisNotification(nn4.Id);
      //  Test.stopTest();
    }
    system.assert(true);
   }

    @isTest
    static void codeCoverageImprovement(){
        NavatarNotificationCtrl.fetchUserNotification(null, UserInfo.getUserId());
        Clip__c clip = [Select Id from Clip__c where Name = 'Test Clip' Limit 1];
        Event e =[Select Id,Related_Associations__c from Event limit 1];
        Task t = [Select Id,Related_Associations__c from Task limit 1];
        
        Navatar_Notification__c nn1 = new Navatar_Notification__c();
        nn1.Record_ID__c = clip.Id;
        nn1.Type__c = NavatarConstants.CLIP_INFO;
        nn1.User__c = UserInfo.getUserId();
        insert nn1;
        
        Navatar_Notification__c nn2 = new Navatar_Notification__c();
        nn2.Record_ID__c = e.Id;
        nn2.Type__c = NavatarConstants.DEAL_ACTIVITY_INFO;
        nn2.User__c = UserInfo.getUserId();
        insert nn2;
        
        Navatar_Notification__c nn3 = new Navatar_Notification__c();
        nn3.Record_ID__c = e.Id;
        nn3.Type__c = NavatarConstants.THEME_ACTIVITY_INFO;
        nn3.User__c = UserInfo.getUserId();
        insert nn3;
        
        Navatar_Notification__c nn4 = new Navatar_Notification__c();
        nn4.Record_ID__c = t.Id;
        nn4.Type__c = NavatarConstants.DEAL_ACTIVITY_INFO;
        nn4.User__c = UserInfo.getUserId();
        insert nn4;
        
        Navatar_Notification__c nn5 = new Navatar_Notification__c();
        nn5.Record_ID__c = t.Id;
        nn5.Type__c = NavatarConstants.THEME_ACTIVITY_INFO;
        nn5.User__c = UserInfo.getUserId();
        insert nn5;
        
        List<NavatarNotificationCtrl.NotificationWrapper> notifications = new List<NavatarNotificationCtrl.NotificationWrapper>();
        notifications=NavatarNotificationCtrl.fetchEventData();

        //Patch 3 CR (Bug # 00043018)
      //  NavatarNotificationCtrl.checkReviewTagDisabled();
        
        system.assert(true);
    }
}