/* --------------------------------------------------------------------------------------------------
* Test Class for NavatarNotificationSettingCtrl
* --------------------------------------------------------------------------------------------------
* @author         Pavani M
* @modifiedBy     Pavani M
* @version        1.0
* @created        2022-01-11
* @modified       2022-01-11
*/
@isTest
public with sharing class NavatarNotificationSettingsCtrlTest {
    @isTest
    static void testFetchNotificationSettings(){
        navpeII_dev18__Navatar_Setup__c navatarSetting = new navpeII_dev18__Navatar_Setup__c();
        navatarSetting.NN_Action__c = true;
        navatarSetting.NN_Information__c= true;
        navatarSetting.navpeII_dev18__Admin_Setting__c = true;
        insert navatarSetting;

        Profile p=[Select Id from Profile where Name ='PE Standard User'];
        
        User u = new User(Alias = 'TestUser', Email='testpe@testorg.com.invalid',
        EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
        LocaleSidKey='en_US', ProfileId = p.Id,
        TimeZoneSidKey='America/Los_Angeles', UserName='testpe@testorg.com.invalid');
        insert u;

        Account acc = new Account(Name = 'Account 1');
        acc.isAutoCreated__c = true;
        insert acc;

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

        Event e1 = new event();
        e1.WhoId = con1.Id;
        e1.Subject ='Event sub';
        e1.StartDateTime = DateTime.Now();
        e1.EndDateTime = DateTime.Now();
        e1.Related_Associations__c = deal.Id;
        insert e1;

        Navatar_Notification__c nn1 = new Navatar_Notification__c();
        nn1.Record_ID__c = acc.Id;
        nn1.Type__c = NavatarConstants.ACCOUNT_INFO;
        nn1.User__c = u.Id;
        insert nn1;
    
        Navatar_Notification__c nn2 = new Navatar_Notification__c();
        nn2.Record_ID__c = e1.Id;
        nn2.Type__c = NavatarConstants.ADD_NOTE;
        nn2.User__c = u.Id;
        insert nn2;

        NavatarNotificationSettingCtrl.fetchNotificationSettings();
        NavatarNotificationSettingCtrl.deleteNotifications('infoNotification');
        NavatarNotificationSettingCtrl.deleteNotifications('actionNotification');
        Set<Id> nnIds = new Set<Id>();
        nnIds.add(nn1.Id);
        nnIds.add(nn2.Id);
        System.assertEquals(0, [Select Id from Navatar_Notification__c where Id IN:nnIds].size(),'Deleted Notifications');
    
    }
}