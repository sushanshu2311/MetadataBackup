/****************************************************************************************************
** Module Name : Meeting Prep Card (On Demand Email) 1.0 
** Description : Test Class for NavatarMeetingPrepCardSendEmail.
** Organization : Navatar Group
** Product Name & Version : PE Agentforce Baseline 1.0
** Revision History:-
** Version    Date(YYYY-MM-DD)    Author            Description of Action
** 1.0        2026-02-05          Salauddin Sheikh  PE Agentforce Baseline Phase 1
****************************************************************************************************/
@isTest
public class NavatarMeetingPrepCardSendEmailTest {
     @testSetup
    static void setupTestData() {
        Account acc = new Account(Name = 'Test Account');
        insert acc;
        Contact con = new Contact(FirstName = 'Test', LastName = 'Contact', AccountId = acc.Id);
        insert con;
    }
	
    @isTest
    static void testInvalidContactId() {
        NavatarMeetingPrepCardSendEmail.RequestWrapper req = new NavatarMeetingPrepCardSendEmail.RequestWrapper();
        req.contactId = null;
        List<NavatarMeetingPrepCardSendEmail.RequestWrapper> reqs = new List<NavatarMeetingPrepCardSendEmail.RequestWrapper>{req};
        Test.startTest();
        List<NavatarMeetingPrepCardSendEmail.ResponseWrapper> resps = NavatarMeetingPrepCardSendEmail.generatePrepCardAndEmail(reqs);
        Test.stopTest();
        System.assertEquals('Error: Provided Id is not a valid Contact Id.', resps[0].summary);
    }

    @isTest
    static void testNoFutureEvents() {
        Contact c = [SELECT Id FROM Contact LIMIT 1];
        NavatarMeetingPrepCardSendEmail.RequestWrapper req = new NavatarMeetingPrepCardSendEmail.RequestWrapper();
        req.contactId = c.Id;
        Test.startTest();
        List<NavatarMeetingPrepCardSendEmail.ResponseWrapper> resps = NavatarMeetingPrepCardSendEmail.generatePrepCardAndEmail(new List<NavatarMeetingPrepCardSendEmail.RequestWrapper>{req});
        Test.stopTest();
        System.assert(resps[0].summary.contains('No future events found'), 'Should handle no future events');
    }

    @isTest
    static void testHappyPath() {
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

        Test.startTest();
        NavatarMeetingPrepCardSendEmail.RequestWrapper req = new NavatarMeetingPrepCardSendEmail.RequestWrapper();
        req.contactId = c.Id;
        List<NavatarMeetingPrepCardSendEmail.ResponseWrapper> resps = NavatarMeetingPrepCardSendEmail.generatePrepCardAndEmail(new List<NavatarMeetingPrepCardSendEmail.RequestWrapper>{req});
        Test.stopTest();
        System.assert(resps[0].message != null, 'Message should be generated and emailed');
    }

    @isTest
    static void testExceptionHandling() {
        NavatarMeetingPrepCardSendEmail.RequestWrapper req = new NavatarMeetingPrepCardSendEmail.RequestWrapper();
        req.contactId = '0TT000000000$000AAA';
        Test.startTest();
        List<NavatarMeetingPrepCardSendEmail.ResponseWrapper> resps = NavatarMeetingPrepCardSendEmail.generatePrepCardAndEmail(new List<NavatarMeetingPrepCardSendEmail.RequestWrapper>{req});
        Test.stopTest();
        System.assert(resps[0].summary != null, 'Should handle exception gracefully');
    }
}