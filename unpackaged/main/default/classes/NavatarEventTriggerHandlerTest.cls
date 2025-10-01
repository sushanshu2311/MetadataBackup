@isTest
public with sharing class NavatarEventTriggerHandlerTest {
    @isTest
    private static void testOnAfterInsUpdate(){

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

        navpeII_dev18__Pipeline__c deal = new navpeII_dev18__Pipeline__c();
        deal.navpeII_dev18__Company__c = acc.Id;
        deal.navpeII_dev18__Stage__c = 'Deal Received';
        deal.Name ='Test Auto Created Company';
        insert deal;

        navpeII_dev18__Deal_Team__c dealTeam = new navpeII_dev18__Deal_Team__c();
        dealTeam.navpeII_dev18__Team_Member__c = UserInfo.getUserId();
        dealTeam.navpeII_dev18__Team_Member_Role__c = 'Accountant';
        dealTeam.navpeII_dev18__Deal__c= deal.Id;
        insert dealTeam;

        navpeII_dev18__Deal_Team__c dealTeam1 = new navpeII_dev18__Deal_Team__c();
        dealTeam1.navpeII_dev18__Team_Member__c = testUser.Id;
        dealTeam1.navpeII_dev18__Team_Member_Role__c = 'Accountant';
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
        
        Event e1 = new event();
        e1.WhoId = con1.Id;
        e1.Subject ='Event sub';
        e1.StartDateTime = DateTime.Now();
        e1.EndDateTime = DateTime.Now().addMinutes(60);
        e1.Related_Associations__c = deal.Id;

        Event e2 = new event();
        e2.WhoId = con1.Id;
        e2.Subject ='Event sub 1';
        e2.StartDateTime = DateTime.Now();
        e2.EndDateTime = DateTime.Now().addMinutes(60);
        e2.Related_Associations__c = theme.Id;
        
        Test.startTest();
        insert e1;
        //e1.Related_Associations__c= e1.Related_Associations__c+','+theme.id;
        insert e2;   
        Test.stopTest();        
        
        System.assertEquals(2, [Select Id from Navatar_Notification__c ].size(),
                                'Notifications created');
        

    }
}