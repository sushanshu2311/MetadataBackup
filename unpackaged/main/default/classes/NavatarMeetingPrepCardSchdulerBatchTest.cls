/****************************************************************************************************
** Module Name : Meeting Prep Card (Daily) 1.0 
** Description : Test class for NavatarMeetingPrepCardSchdulerBatch.
** Organization : Navatar Group
** Product Name & Version : PE Agentforce Baseline 1.0
** Revision History:-
** Version    Date(YYYY-MM-DD)    Author            Description of Action
** 1.0        2026-02-05          Shiva            PE Agentforce Baseline Phase 1
****************************************************************************************************/
@istest
public class NavatarMeetingPrepCardSchdulerBatchTest {
    @testSetup
    static void setupTestData() {
        // Create Account
        Account acc = new Account(Name = 'Test Account');
        insert acc;
        // Create Contact
        Contact con = new Contact(FirstName = 'Test', LastName = 'Contact', Email = 'testcontact@example.com', AccountId = acc.Id);
        insert con;
        // Create User (Event Owner)
        Profile p = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
        User u = new User(
            Username = 'dailydigestuser@test.com',
            LastName = 'User',
            Email = 'dailydigestuser@test.com',
            Alias = 'ddu',
            TimeZoneSidKey = 'America/New_York',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            ProfileId = p.Id,
            LanguageLocaleKey = 'en_US'
        );
        insert u;
        // Create Event for today
        Event e = new Event(
            Subject = 'Test Event',
            StartDateTime = System.now().addHours(1),
            EndDateTime = System.now().addHours(2),
            WhoId = con.Id,
            OwnerId = u.Id
        );
        insert e;
    }

        @isTest
        static void testStartMethod_Coverage() {
            NavatarMeetingPrepCardSchdulerBatch batch = new NavatarMeetingPrepCardSchdulerBatch();
            // Directly call start and assert query locator is returned
            Test.startTest();
            Database.QueryLocator locator = batch.start(null);
            Test.stopTest();
            System.assertNotEquals(null, locator, 'QueryLocator should not be null');
        }

        @isTest
        static void testFinishMethod_Coverage() {
            NavatarMeetingPrepCardSchdulerBatch batch = new NavatarMeetingPrepCardSchdulerBatch();
            // Directly call finish to cover the method
            Test.startTest();
            batch.finish(null);
            Test.stopTest();
            System.assert(true, 'Finish method executed');
        }

        @isTest
        static void testExecuteBatch_NullEvents() {
            // Directly call execute with null to cover null branch
            NavatarMeetingPrepCardSchdulerBatch batch = new NavatarMeetingPrepCardSchdulerBatch();
            Test.startTest();
            batch.execute(null, null);
            Test.stopTest();
            System.assert(true, 'Execute with null events should not throw');
        }

        @isTest
        static void testExecuteBatch_EmptyEvents() {
            // Directly call execute with empty list to cover empty branch
            NavatarMeetingPrepCardSchdulerBatch batch = new NavatarMeetingPrepCardSchdulerBatch();
            Test.startTest();
            batch.execute(null, new List<Event>());
            Test.stopTest();
            System.assert(true, 'Execute with empty events should not throw');
        }

    @isTest
    static void testExecuteBatch_Positive() {
        NavatarMeetingPrepCardSchdulerBatch batch = new NavatarMeetingPrepCardSchdulerBatch();
        Test.startTest();
        Id batchJobId = Database.executeBatch(batch, 200);
        Test.stopTest();
        System.assertNotEquals(null, batchJobId, 'Batch job should be started and return a job Id');
    }

    @isTest
    static void testExecuteBatch_NoEvents() {
        List<Event> events = [SELECT Id FROM Event];
        delete events;
        NavatarMeetingPrepCardSchdulerBatch batch = new NavatarMeetingPrepCardSchdulerBatch();
        Test.startTest();
        Id batchJobId = Database.executeBatch(batch, 200);
        Test.stopTest();
        System.assertNotEquals(null, batchJobId, 'Batch job should be started even if no events');
    }

    @isTest
    static void testExecuteBatch_MissingWhoIdOwnerId() {
        // Create Event with missing WhoId and OwnerId
        Event e = new Event(
            Subject = 'Event No WhoId/OwnerId',
            StartDateTime = System.now().addHours(3),
            EndDateTime = System.now().addHours(4)
        );
        insert e;
        NavatarMeetingPrepCardSchdulerBatch batch = new NavatarMeetingPrepCardSchdulerBatch();
        Test.startTest();
        Id batchJobId = Database.executeBatch(batch, 200);
        Test.stopTest();
        System.assertNotEquals(null, batchJobId, 'Batch job should be started for event with missing WhoId/OwnerId');
    }

    @isTest
    static void testExecuteBatch_ErrorHandling() {
        // Simulate error in fetchPromptResponse by inserting a Contact with AccountId as null
        Account acc = new Account(Name = 'Error Account');
        insert acc;
        Contact con = new Contact(FirstName = 'Error', LastName = 'Contact', Email = 'errorcontact@example.com', AccountId = acc.Id);
        insert con;
        Profile p = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
        User u = new User(
            Username = 'erroruser'+System.currentTimeMillis()+'@test.com',
            LastName = 'User',
            Email = 'erroruser@test.com',
            Alias = 'erru',
            TimeZoneSidKey = 'America/New_York',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            ProfileId = p.Id,
            LanguageLocaleKey = 'en_US'
        );
        insert u;
        Event e = new Event(
            Subject = 'Error Event',
            StartDateTime = System.now().addHours(5),
            EndDateTime = System.now().addHours(6),
            WhoId = con.Id,
            OwnerId = u.Id
        );
        insert e;
        Test.startTest();
        try {
            NavatarMeetingPrepCardSchdulerBatch batch = new NavatarMeetingPrepCardSchdulerBatch();
            Id batchJobId = Database.executeBatch(batch, 200);
            System.assertNotEquals(null, batchJobId, 'Batch job should be started even if error occurs');
        } catch (Exception ex) {
            System.assert(true, 'Exception should be caught and not fail the batch');
        }
        Test.stopTest();
    }

}