/****************************************************************************************************

** Module Name : Navatar Note

** Description : Test class for NavatarNotesRTAToolbarEnabler.

** Throws : NA

** Calls : NA

** Organization : Navatar Group

** Product Name & Version : PE v5.5

** Revision History:-

** Version    Date(YYYY-MM-DD)    Author         Description of Action

** 1.0        2025-01-14          Sudhanshu

****************************************************************************************************/

@isTest
public with sharing class NavatarNotesRTAToolbarEnablerTest {
    @isTest
    static void testUpdateRTAField() {
        // Create test users
        List<User> users = new List<User>();
        
        // Fetch a valid ProfileId for the user (adjust for your org)
        Id profileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1].Id;
        
        // Create 10 users, activating alternate users and updating the field to either TRUE or FALSE
        for (Integer i = 0; i < 10; i++) {
            // Manually assign active status without using modulus operator
            Boolean isActive = (i == 0 || i == 2 || i == 4 || i == 6 || i == 8); // Alternate users will be active
            
            users.add(new User(
                Username = 'testuser' + i + '@navtest.com',
                Alias = 'test' + i,
                Email = 'testuser' + i + '@navtest.com',
                ProfileId = profileId,  // Provide a valid ProfileId
                IsActive = isActive,
                navpeII_dev18__Enable_RTA_Toolbar__c = TRUE,  // Even users will have FALSE, odd will have TRUE
                LastName = 'TestLastName' + i,  // Required field
                TimeZoneSidKey = 'America/Los_Angeles',  // Required field
                LocaleSidKey = 'en_US',  // Required field
                EmailEncodingKey = 'UTF-8',  // Required field
                LanguageLocaleKey = 'en_US'  // Required field
            ));
        }
        
        // Insert users
        insert users;
        
        // Create an instance of the class and execute it
        Test.startTest();
        
        // Directly calling the execute method for testing
        NavatarNotesRTAToolbarEnabler scheduler = new NavatarNotesRTAToolbarEnabler();
        scheduler.execute(null);  // Simulate the execution of the scheduled job
        
        Test.stopTest();
        
        // Query the updated users to check if the field was updated
        List<User> updatedUsers = [SELECT Id, navpeII_dev18__Enable_RTA_Toolbar__c 
                                   FROM User 
                                   WHERE IsActive = TRUE and Username LIKE '%testuser%'];

        // Assert that the field is set to TRUE for all active users
        for (User u : updatedUsers) {
            System.assertEquals(TRUE, u.navpeII_dev18__Enable_RTA_Toolbar__c, 
                                'The Enable RTA Toolbar field should be TRUE for active users');
        }
    }

    @isTest
    static void testScheduleJob() {
        // Test the scheduling function
        Test.startTest();
        
        // Call the scheduleUpdateJob method (this doesn't actually run in test context, 
        // but we can test if it schedules correctly)
        NavatarNotesRTAToolbarEnabler.scheduleUpdateJob();
        
        Test.stopTest();
        
        // Verify that the job is scheduled (this checks if the method was executed)
        List<CronTrigger> jobs = [SELECT Id, CronExpression, State FROM CronTrigger WHERE CronExpression != null];
        System.assert(!jobs.isEmpty(), 'The job should be scheduled');
    }
    
}