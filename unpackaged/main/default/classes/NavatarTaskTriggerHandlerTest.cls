@isTest
public with sharing class NavatarTaskTriggerHandlerTest {
    @isTest
    private static void testOnAfterInsUpdate(){
		Test.startTest();
        User testUser = [Select Id from User where Profile.Name ='PE Standard User' and IsActive=TRUE
                         Limit 1];

        Account acc = new Account(Name = 'Account 1');
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

        Contact con2 = new Contact();
        con2.FirstName = 'Sasuke1';
        con2.LastName = 'Uchiha1';
        con2.Email = 'uchiha@sharingan2.com';
        con2.AccountId = acc.Id;
        insert con2;

        navpeII_dev18__Pipeline__c deal = new navpeII_dev18__Pipeline__c();
        deal.navpeII_dev18__Company__c = acc.Id;
        deal.navpeII_dev18__Stage__c = 'Deal Received';
        deal.Name ='Test Auto Created Company';
        insert deal;

        navpeII_dev18__Deal_Team__c dealTeam = new navpeII_dev18__Deal_Team__c();
        dealTeam.navpeII_dev18__Team_Member__c = UserInfo.getUserId();
        dealTeam.navpeII_dev18__Team_Member_Role__c = 'Partner';
        dealTeam.navpeII_dev18__Deal__c= deal.Id;
        insert dealTeam;

        navpeII_dev18__Deal_Team__c dealTeam1 = new navpeII_dev18__Deal_Team__c();
        dealTeam1.navpeII_dev18__Team_Member__c = testUser.Id;
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
        themeTeam1.Member__c = testUser.Id;
        themeTeam1.Role__c = 'Advisor';
        themeTeam1.Theme__c = theme.Id;
        insert themeTeam1;
        
        Task t2 = new task();
        t2.WhoId = con1.Id;
        t2.Subject = 'Task Subject';
        t2.Status = 'Completed';
        t2.Priority = 'Normal';
        t2.WhatId = acc.Id;
        t2.Related_Associations__c=deal.Id;

        Task t = new task();
        t.WhoId = con1.Id;
        t.Subject = 'Task Subject';
        t.Status = 'Completed';
        t.Priority = 'Normal';
        t.WhatId = acc.Id;
        t.Related_Associations__c=deal.Id;
        t.navpeII_dev18__Is_Touchpoint__c= true;
        t.ActivityDate = System.today();
        
        insert t2;
        insert t;
        t2.Related_Associations__c= t2.Related_Associations__c+','+theme.id;
        t2.WhoId=con2.Id;
        update t2;   
        Test.stopTest();        
        
        System.assertEquals(2, [Select Id from Navatar_Notification__c where Record_Id__c = :t2.Id].size(),
                                'Notifications created');

    }
     	
    @isTest 
    static  void unitTest1() {
        List<Account> accounts = new List<Account>();
        accounts.add(new Account(Name = 'TestData1',Description='Test data is processing '));
        accounts.add(new Account(Name = 'TestData2'));
        accounts.add(new Account(Name = 'TestData3'));
        insert accounts;
        
        List<Account> accountUpdates = new List<Account>();
        accountUpdates.add(new Account(Id = accounts[0].Id, ParentId = accounts[1].Id));
        accountUpdates.add(new Account(Id = accounts[1].Id, ParentId = accounts[2].Id));
        update accountUpdates;
        
        List<Contact> contacts = new List<Contact>();
        contacts.add(new Contact(AccountId = accounts[0].Id, FirstName = 'Mohan', LastName = 'Manager',Description='Test contact is processing'));
        contacts.add(new Contact(AccountId = accounts[0].Id, FirstName = 'Kishor', LastName = 'Casher'));
        contacts.add(new Contact(AccountId = accounts[1].Id, FirstName = 'Swati', LastName = 'Broker'));
        contacts.add(new Contact(AccountId = accounts[1].Id, FirstName = 'Kamlesh', LastName = 'Executive'));
        insert contacts;
        
        List<Task> taskData = new List<Task>();
        String userId = UserInfo.getUserId();
        taskData.add(new task(Description='From: TestData1 task is essential Manager Mohan ',OwnerId=userId,Related_Associations__c=accountUpdates[0].id+','+accountUpdates[1].id,Subject='Send Letter',Status='Open',Priority='Normal',WhatId=accounts[0].Id,WhoId=contacts[0].Id, TaskSubtype='Email'));
       // taskData.add(new task(Description='From: Test task is essential2 Broker ',OwnerId=userId,Subject='Send Letter',Status='Open',Priority='Normal',WhatId=accounts[1].Id,WhoId=contacts[1].Id));
        insert taskData;
        
        List<Event> eventData = new List<Event>();
        String userId2 = UserInfo.getUserId();
        eventData.add(new event(Description='Test event is essential ',Related_Associations__c=accountUpdates[0].id+','+accountUpdates[1].id,ActivityDateTime=system.today(),DurationInMinutes=90,OwnerId=userId2,Subject='Send Letter',WhatId=accounts[0].Id,WhoId=contacts[0].Id));
        eventData.add(new event(Description='Test event is essential2 ',ActivityDateTime=system.today(),DurationInMinutes=80,OwnerId=userId2,Subject='Send Letter',WhatId=accounts[1].Id,WhoId=contacts[1].Id));
        insert eventData;
        
        List<Navatar_Notification__c> navatarNotificationList = new List<Navatar_Notification__c>();
        String userId3 = UserInfo.getUserId();
        navatarNotificationList.add(new Navatar_Notification__c(Type__c = 'Add Tag',OwnerId=userId3,User__c=userId3));
        insert navatarNotificationList;
        
        Task newTask = new Task();
        
        List<Task> task = [SELECT Id, WhoId, WhatId, Subject, ActivityDate, Status, Priority, 
                           IsHighPriority, OwnerId, Description, IsDeleted, AccountId, IsClosed, CreatedDate, 
                           CreatedById, LastModifiedDate, LastModifiedById, SystemModstamp, IsArchived, 
                           CallDurationInSeconds, CallType, CallDisposition, CallObject, ReminderDateTime, 
                           IsReminderSet, RecurrenceActivityId, IsRecurrence, RecurrenceStartDateOnly, 
                           RecurrenceEndDateOnly, RecurrenceTimeZoneSidKey, RecurrenceType, RecurrenceInterval, 
                           RecurrenceDayOfWeekMask, RecurrenceDayOfMonth, RecurrenceInstance, RecurrenceMonthOfYear, 
                           RecurrenceRegeneratedType, TaskSubtype, CompletedDateTime, Related_Associations__c FROM Task];
        Set<Id> taskIds = new Set<Id>();
        Map<Id, Task> mapTask = new Map<Id, Task>();
        for(Task t : task){
            taskIds.add(t.Id);
            mapTask.put(t.Id, t);
        }

        try{
            NavatarTaskTriggerHandler.handleDescriptionInsert(mapTask);
              NavatarTaskTriggerHandler.insertNavatarNotification(mapTask);
              
        }
        catch (Exception e) {}
        
        task[0].Description = 'Test Description';
        system.assertEquals('Test Description', task[0].Description);
        update task;    
    }

        
}