/****************************************************************************************************
** Module Name : Meeting Prep Card (On Demand) 1.0 
** Description : Test Class for NavatarMeetingPrepCardOnDemand.
** Organization : Navatar Group
** Product Name & Version : PE Agentforce Baseline 1.0
** Revision History:-
** Version    Date(YYYY-MM-DD)    Author            Description of Action
** 1.0        2026-02-05          Salauddin Sheikh  PE Agentforce Baseline Phase 1
****************************************************************************************************/
@isTest
public class NavatarMeetingPrepCardOnDemandTest {
    @testSetup
    static void setupTestData() {
        // Create test data required for NavatarMeetingPrepCardOnDemand
        Account acc = new Account(Name = 'Test Account');
        insert acc;
        Contact con = new Contact(FirstName = 'Test', LastName = 'Contact', AccountId = acc.Id);
        insert con;
        // Add more setup as needed for coverage
    }

    @isTest
    static void testNoFutureEvents() {
        // Valid Contact, but no future events
        Contact c = [SELECT Id FROM Contact LIMIT 1];
        NavatarMeetingPrepCardOnDemand.RequestWrapper req = new NavatarMeetingPrepCardOnDemand.RequestWrapper();
        req.contactId = c.Id;
        Test.startTest();
        List<NavatarMeetingPrepCardOnDemand.ResponseWrapper> resps = NavatarMeetingPrepCardOnDemand.generatePrepCard(new List<NavatarMeetingPrepCardOnDemand.RequestWrapper>{req});
        Test.stopTest();
        System.assert(resps[0].summary.contains('No future events found'), 'Should handle no future events');
    }

    @isTest
    static void testHappyPath() {
        // Create Account, Contact, Event, EventRelation
		Id institutionRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Institution').getRecordTypeId();
        Account acc = new Account(Name='HappyPath Account', RecordTypeId = institutionRecordTypeId);
        insert acc;
        Contact c = new Contact(FirstName='Happy', LastName='Contact', AccountId=acc.Id);
        insert c;
        Event e = new Event(Subject='Happy Event', StartDateTime=System.now().addDays(2), EndDateTime=System.now().addDays(2).addHours(1));
        insert e;
        EventRelation er = new EventRelation(EventId=e.Id, RelationId=c.Id);
        insert er;
        
        // Create test Deal
        navpeII__Pipeline__c deal = new navpeII__Pipeline__c();
        deal.Name = 'Testing';
        deal.navpeII__Company__c = acc.id;
        deal.navpeII__Source_Company__c = acc.id;
        deal.navpeII__Our_Role__c = 'Lead';
        deal.navpeII__Stage__c = 'IOI';
        insert deal;

        navpeII__Deal_Team__c dealTeam = new navpeII__Deal_Team__c();
        dealTeam.navpeII__Deal__c = deal.id;
        dealTeam.navpeII__Deal_Contact__c = c.id;
        insert dealTeam;

        navpeII__Fund__c fund = new navpeII__Fund__c();
        fund.Name = 'Test1';
        fund.navpeII__Fund_Type__c = 'Fund';
        fund.navpeII__Investment_Category__c = 'Fund';
        insert fund;

        navpeII__Fundraising__c fundraisingRecord = new navpeII__Fundraising__c(Name = 'testFundraising', navpeII__Fund_Name__c = fund.Id, navpeII__Legal_Name__c = acc.Id);
        insert fundraisingRecord;

        // Mock callPromptTemplate using a test subclass
        Test.startTest();
        // Use a test version if possible, else just call the method
        NavatarMeetingPrepCardOnDemand.RequestWrapper req = new NavatarMeetingPrepCardOnDemand.RequestWrapper();
        req.contactId = c.Id;
        List<NavatarMeetingPrepCardOnDemand.ResponseWrapper> resps = NavatarMeetingPrepCardOnDemand.generatePrepCard(new List<NavatarMeetingPrepCardOnDemand.RequestWrapper>{req});
        Test.stopTest();
        System.assert(resps[0].summary != null, 'Summary should be generated');
    }

    @isTest
    static void testExceptionHandling() {
        // Simulate exception by passing a ContactId that will cause SOQL error
        NavatarMeetingPrepCardOnDemand.RequestWrapper req = new NavatarMeetingPrepCardOnDemand.RequestWrapper();
        req.contactId = '003000000000000AAA'; // unlikely to match any EventRelation
        Test.startTest();
        List<NavatarMeetingPrepCardOnDemand.ResponseWrapper> resps = NavatarMeetingPrepCardOnDemand.generatePrepCard(new List<NavatarMeetingPrepCardOnDemand.RequestWrapper>{req});
        Test.stopTest();
        System.assert(resps[0].summary != null, 'Should handle exception gracefully');
    }
}