@isTest
public with sharing class NavatarUtility_Test {
    @isTest
    private static void test_IsNotificationAllowed(){
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
            Test.startTest();
                //NavatarUtility nu = new NavatarUtility();
                Map<String, Boolean> response = NavatarUtility.isNotificationAllowed();
            Test.stopTest();
            System.assertEquals(3, response.size(), 'Action and Info notifications are checked');

    }

   
}