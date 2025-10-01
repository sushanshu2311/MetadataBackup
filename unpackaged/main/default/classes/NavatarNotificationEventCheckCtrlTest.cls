@isTest
public class NavatarNotificationEventCheckCtrlTest {
    @isTest
   static void testCreateNotificationRecords(){
        Profile p=[Select Id from Profile where Name ='PE Standard User'];

        User u = new User(Alias = 'TestUser', Email='testpe@testorg.com.invalid',
        EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
        LocaleSidKey='en_US', ProfileId = p.Id,
        TimeZoneSidKey='America/Los_Angeles', UserName='testpe@testorg.com.invalid');
        insert u;

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
        e1.Related_Associations__c = deal.Id;
        insert e1;
        Event e2 = new event();
        e2.WhoId = con1.Id;
        e2.Subject ='Event sub';
        e2.StartDateTime = DateTime.Now();
        e2.EndDateTime = DateTime.Now().addDays(1);
        e2.Related_Associations__c = theme.Id;
        insert e2;
        //changed Event Relation reference to Sobject
        Schema.SObjectType st = Schema.getGlobalDescribe().get('EventRelation');
        sObject obj = st.newSobject();
        obj.put('RelationId', u.Id);
        obj.put('EventId', e1.Id);
        insert obj;

        Test.startTest();
        List<Id> events=new List<Id>();
        events.add(e1.Id);
        events.add(e2.Id);
        NavatarNotificationEventCheckCtrl.createNotificationRecords(events);
        Test.stopTest();

        System.assertEquals(3, [Select Id from Navatar_Notification__c where User__c =:u.Id].size());
    }
}