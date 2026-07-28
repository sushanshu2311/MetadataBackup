/****************************************************************************************************
** Module Name : Meeting Prep Card Utility) 1.0
** Description : Test Class for NavatarMeetingPrepCardUtility.
** Organization : Navatar Group
** Product Name & Version : PE Agentforce Baseline 1.0
** Revision History:-
** Version    Date(YYYY-MM-DD)    Author            Description of Action
** 1.0        2026-02-05          Shiva           PE Agentforce Baseline Phase 1
****************************************************************************************************/
@isTest
public with sharing class NavatarMeetingPrepCardUtilityTest {
    @testSetup
    static void setupTestData() {
        // Create a System Administrator user with email
        Profile adminProfile = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
        User adminUser = new User(
            Username = System.now().getTime() + 'adminuser1@test.com',
            LastName = 'Admin',
            Email = 'adminuser1@test.com',
            Alias = 'adm1',
            TimeZoneSidKey = 'America/New_York',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            ProfileId = adminProfile.Id
        );
        insert adminUser;

        // Create a regular user with email
        Profile p = [SELECT Id FROM Profile WHERE Name != 'System Administrator' LIMIT 1];
        User u = new User(
            Username = System.now().getTime() + 'user1@test.com',
            LastName = 'User',
            Email = 'user1@test.com',
            Alias = 'usr1',
            TimeZoneSidKey = 'America/New_York',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            ProfileId = p.Id
        );
        insert u;
    }

    @isTest
    static void testSendErrorEmailToAdmins() {
        Test.startTest();
        NavatarMeetingPrepCardUtility.sendErrorEmailToAdmins('Test Subject', 'Test Body');
        Test.stopTest();
        // No exception should be thrown and method should complete
    }

    @isTest
    static void testSendErrorEmailToUsers() {
        // Query the regular user by email or alias
        User u = [SELECT Id FROM User WHERE Email = 'user1@test.com' OR Alias = 'usr1' LIMIT 1];
        Set<Id> userIds = new Set<Id>{u.Id};
        Test.startTest();
        NavatarMeetingPrepCardUtility.sendErrorEmailToUsers('Test Subject', 'Test Body', userIds);
        Test.stopTest();
        // No exception should be thrown and method should complete
    }


    @isTest
    static void testSendErrorEmailToUsersEmptySet() {
        Test.startTest();
        NavatarMeetingPrepCardUtility.sendErrorEmailToUsers('Test Subject', 'Test Body', new Set<Id>());
        Test.stopTest();
        // Should not throw exception
    }

    @isTest
    static void testSendErrorEmailToEmailList() {
        // Use the admin user created in setup
        List<String> emails = new List<String>{'adminuser1@test.com'};
        Test.startTest();
        NavatarMeetingPrepCardUtility.sendErrorEmailToEmailList('Test Subject', 'Test Body', emails);
        Test.stopTest();
        // Should not throw exception
    }

    @isTest
    static void testSendErrorEmailToLoggedInUser() {
        // Run as the admin user created in setup
        User adminUser = [SELECT Id FROM User WHERE Email = 'adminuser1@test.com' LIMIT 1];
        System.runAs(adminUser) {
            Test.startTest();
            NavatarMeetingPrepCardUtility.sendErrorEmailToLoggedInUser('Test Subject', 'Test Body');
            Test.stopTest();
        }
        // Should not throw exception
    }

    @isTest
    static void testSendErrorEmailToUsersNullSet() {
        Test.startTest();
        NavatarMeetingPrepCardUtility.sendErrorEmailToUsers('Test Subject', 'Test Body', null);
        Test.stopTest();
        // Should not throw exception
    }
}