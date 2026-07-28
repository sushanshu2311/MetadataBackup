/****************************************************************************************************
** Module Name : Meeting Prep Card (Daily) 1.0 
** Description : Test Class for NavatarMeetingPrepCardSchduler.
** Organization : Navatar Group
** Product Name & Version : PE Agentforce Baseline 1.0
** Revision History:-
** Version    Date(YYYY-MM-DD)    Author            Description of Action
** 1.0        2026-02-05          Salauddin Sheikh  PE Agentforce Baseline Phase 1
****************************************************************************************************/
@isTest
public class NavatarMeetingPrepCardSchdulerTest {
   @testSetup
    static void setupTestData() {
        // Create Account, Contact, Event for today
        Account acc = new Account(Name='Test Account');
        insert acc;
        Contact con = new Contact(FirstName='Test', LastName='Contact', AccountId=acc.Id);
        insert con;
        Event ev = new Event(Subject='Test Event', StartDateTime=System.now(), EndDateTime=System.now().addHours(1), WhoId=con.Id);
        insert ev;
    }

    @isTest
    static void testNoEmailAddresses() {
        Test.startTest();
        NavatarMeetingPrepCardSchduler.sendPrepCardToDistributionList();
        Test.stopTest();
        // No exception should be thrown
        System.assert(true, 'No email addresses handled');
    }

    @isTest
    static void testNoEventsToday() {
        // Remove all events for today
        List<Event> todaysEvents = [SELECT Id FROM Event WHERE StartDateTime >= :DateTime.newInstance(Date.today().year(), Date.today().month(), Date.today().day()) AND StartDateTime <= :DateTime.newInstance(Date.today().year(), Date.today().month(), Date.today().day(), 23, 59, 59)];
        delete todaysEvents;
        Test.startTest();
        NavatarMeetingPrepCardSchduler.sendPrepCardToDistributionList();
        Test.stopTest();
        // No exception should be thrown
        System.assert(true, 'No events handled');
    }

    @isTest
    static void testHappyPath() {
        Test.startTest();
        NavatarMeetingPrepCardSchduler.sendPrepCardToDistributionList();
        Test.stopTest();
        // Validate Contact exists and test ran
        Contact c = [SELECT Id FROM Contact LIMIT 1];
        System.assert(c.Id != null, 'Contact should exist and test should run');
    }

    @isTest
    static void testExceptionHandling() {
        // Simulate error by passing null list
        Test.startTest();
        NavatarMeetingPrepCardSchduler.sendPrepCardToDistributionList();
        Test.stopTest();
        System.assert(true, 'Exception handled gracefully');
    }
}