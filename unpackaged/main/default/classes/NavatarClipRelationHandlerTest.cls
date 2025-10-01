/************************************************************************************
** Description : Test class for ClipRelationTriggerHandler
** Class: ClipRelationTriggerHandler_Test
** Organization : Navatar Group
** Revision History:-
** Version Date(YYYY-MM-DD)          Author                  
** 1.0     2023-01-09              Pavani Manneni   
*/

@isTest
public with sharing class NavatarClipRelationHandlerTest {
    @isTest
    private static void notificationInsetOnClip(){
        User testUser = [Select Id from User where Profile.Name ='PE Standard User' and IsActive=TRUE
                         Limit 1];
        navpeII_dev18__Navatar_Setup__c navatarSetting = new navpeII_dev18__Navatar_Setup__c();
        navatarSetting.NN_Action__c = true;
        navatarSetting.NN_Information__c= true;
        navatarSetting.navpeII_dev18__Admin_Setting__c = true;
        insert navatarSetting;
        
        Clip__c c = new Clip__c();
        c.Name = 'Test Clip';
        c.Notes__c = 'Test Clip Notes';
        c.Summary__c = 'Test Clip Summary';
        insert c;

        Clip_Relation__c cr = new Clip_Relation__c();
        cr.Clip__c = c.Id;
        cr.User__c= testUser.Id;
        Test.startTest();
        insert cr;
        Test.stopTest();
        System.assertEquals(NavatarConstants.CLIP_INFO,[Select Type__c from Navatar_Notification__c where 
                                                 Record_ID__c=:c.Id AND User__c =: testUser.Id].Type__c);
        
    }
}