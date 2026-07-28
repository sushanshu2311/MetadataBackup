/****************************************************************************************************
** Module Name : Find Deal Experts Test Class 1.0 
** Description : Test Class for NavatarFindDealExperts.
** Organization : Navatar Group
** Product Name & Version : PE Agentforce Baseline 1.0
** Revision History:-
** Version    Date(YYYY-MM-DD)    Author            Description of Action
** 1.0        2026-02-05          Sudhanshu         PE Agentforce Baseline Phase 1
****************************************************************************************************/

@isTest

public class NavatarFindDealExpertsTest {
    @testSetup
    static void setupTestData() {
        // Create test Company
        Id devRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Company').getRecordTypeId();//AA-780
        Account company = new Account();
        company.RecordTypeId = devRecordTypeId;
        company.Name = 'Test Class';
        insert company;

        // Create test Pipeline (input deal)
        navpeII__Pipeline__c inputDeal = new navpeII__Pipeline__c(
            Name = 'Input Deal',
            navpeII__Company__c = company.Id,
            navpeII__Stage__c = 'Stage 1',
            navpeII__Transaction_Type__c = 'Type A',
            navpeII__Deal_Type__c = 'Type X',
            navpeII__EBITDA__c = 100000,
            navpeII__Revenue__c = 500000,
            navpeII__Investment_Size__c = 200000
        );
        insert inputDeal;

        // Create similar deals for default test
        List<navpeII__Pipeline__c> deals = new List<navpeII__Pipeline__c>();
        // Deal 0: Matches Revenue (±15%) only
        deals.add(new navpeII__Pipeline__c(
            Name = 'Similar Deal 0',
            navpeII__Company__c = company.Id,
            navpeII__Stage__c = 'Other Stage',
            navpeII__Transaction_Type__c = 'Other Type',
            navpeII__Deal_Type__c = 'Other Deal',
            navpeII__EBITDA__c = 999999, // out of EBITDA range
            navpeII__Revenue__c = 500000, // matches input revenue (±15%)
            navpeII__Investment_Size__c = 210000
        ));
        // Deal 1: Matches EBITDA (±15%) only
        deals.add(new navpeII__Pipeline__c(
            Name = 'Similar Deal 1',
            navpeII__Company__c = company.Id,
            navpeII__Stage__c = 'Other Stage',
            navpeII__Transaction_Type__c = 'Other Type',
            navpeII__Deal_Type__c = 'Other Deal',
            navpeII__EBITDA__c = 100000, // matches input EBITDA (±15%)
            navpeII__Revenue__c = 999999, // out of revenue range
            navpeII__Investment_Size__c = 210000
        ));
        insert deals;

        // Create contacts for default test
        List<Contact> contacts = new List<Contact>();
        contacts.add(new Contact(LastName = 'Expert 0'));
        contacts.add(new Contact(LastName = 'Expert 1'));
        insert contacts;

        // Assign contacts to deals (Deal Team)
        // Contact 0: assigned to 1 deal (Revenue)
        // Contact 1: assigned to 2 deals (Revenue + EBITDA)
        List<navpeII__Deal_Team__c> dealTeams = new List<navpeII__Deal_Team__c>();
        dealTeams.add(new navpeII__Deal_Team__c(
            navpeII__Deal__c = deals[0].Id,
            navpeII__Deal_Contact__c = contacts[0].Id
        ));
        dealTeams.add(new navpeII__Deal_Team__c(
            navpeII__Deal__c = deals[0].Id,
            navpeII__Deal_Contact__c = contacts[1].Id
        ));
        dealTeams.add(new navpeII__Deal_Team__c(
            navpeII__Deal__c = deals[1].Id,
            navpeII__Deal_Contact__c = contacts[1].Id
        ));
        insert dealTeams;

        // Industry scenario
        navpeII__Pipeline__c industryDeal = new navpeII__Pipeline__c(
            Name = 'Industry Deal',
            navpeII__Company__c = company.Id,
            navpeII__Stage__c = 'Other Stage',
            navpeII__Transaction_Type__c = 'Other Type',
            navpeII__Deal_Type__c = 'Other Deal',
            navpeII__EBITDA__c = 999,
            navpeII__Revenue__c = 999,
            navpeII__Investment_Size__c = 999
        );
        insert industryDeal;
        Contact industryContact = new Contact(LastName = 'Industry Expert');
        insert industryContact;
        navpeII__Deal_Team__c industryDT = new navpeII__Deal_Team__c(navpeII__Deal__c = industryDeal.Id, navpeII__Deal_Contact__c = industryContact.Id);
        insert industryDT;

        // Revenue scenario
        // Decimal revenue = inputDeal.navpeII__Revenue__c;
        // navpeII__Pipeline__c revenueDeal = new navpeII__Pipeline__c(
        //     Name = 'Revenue Deal',
        //     navpeII__Company__c = company.Id,
        //     navpeII__Stage__c = 'Other Stage',
        //     navpeII__Transaction_Type__c = 'Other Type',
        //     navpeII__Deal_Type__c = 'Other Deal',
        //     navpeII__EBITDA__c = 999,
        //     navpeII__Revenue__c = revenue * 1.10,
        //     navpeII__Investment_Size__c = 999
        // );
        // insert revenueDeal;
        // Contact revenueContact = new Contact(LastName = 'Revenue Expert');
        // insert revenueContact;
        // navpeII__Deal_Team__c revenueDT = new navpeII__Deal_Team__c(navpeII__Deal__c = revenueDeal.Id, navpeII__Deal_Contact__c = revenueContact.Id);
        // insert revenueDT;

        // // EBITDA scenario
        // Decimal ebitda = inputDeal.navpeII__EBITDA__c;
        // navpeII__Pipeline__c ebitdaDeal = new navpeII__Pipeline__c(
        //     Name = 'EBITDA Deal',
        //     navpeII__Company__c = company.Id,
        //     navpeII__Stage__c = 'Other Stage',
        //     navpeII__Transaction_Type__c = 'Other Type',
        //     navpeII__Deal_Type__c = 'Other Deal',
        //     navpeII__EBITDA__c = ebitda * 1.10,
        //     navpeII__Revenue__c = 999,
        //     navpeII__Investment_Size__c = 999
        // );
        // insert ebitdaDeal;
        // Contact ebitdaContact = new Contact(LastName = 'EBITDA Expert');
        // insert ebitdaContact;
        // navpeII__Deal_Team__c ebitdaDT = new navpeII__Deal_Team__c(navpeII__Deal__c = ebitdaDeal.Id, navpeII__Deal_Contact__c = ebitdaContact.Id);
        // insert ebitdaDT;

        // // Deal Type scenario (unique company, revenue, EBITDA)
        // Account dealTypeCompany = new Account(Name = 'DealType Company', RecordTypeId = devRecordTypeId);
        // insert dealTypeCompany;
        // navpeII__Pipeline__c dealTypeDeal = new navpeII__Pipeline__c(
        //     Name = 'DealType Deal',
        //     navpeII__Company__c = dealTypeCompany.Id,
        //     navpeII__Stage__c = 'Other Stage',
        //     navpeII__Transaction_Type__c = 'Other Type',
        //     navpeII__Deal_Type__c = inputDeal.navpeII__Deal_Type__c,
        //     navpeII__EBITDA__c = 999999, // Out of range
        //     navpeII__Revenue__c = 999999, // Out of range
        //     navpeII__Investment_Size__c = 999
        // );
        // insert dealTypeDeal;
        // Contact dealTypeContact = new Contact(LastName = 'DealType Expert');
        // insert dealTypeContact;
        // navpeII__Deal_Team__c dealTypeDT = new navpeII__Deal_Team__c(navpeII__Deal__c = dealTypeDeal.Id, navpeII__Deal_Contact__c = dealTypeContact.Id);
        // insert dealTypeDT;

        // // Deal Stage scenario (unique company, revenue, EBITDA)
        // Account stageCompany = new Account(Name = 'Stage Company', RecordTypeId = devRecordTypeId);
        // insert stageCompany;
        // navpeII__Pipeline__c stageDeal = new navpeII__Pipeline__c(
        //     Name = 'Stage Deal',
        //     navpeII__Company__c = stageCompany.Id,
        //     navpeII__Stage__c = inputDeal.navpeII__Stage__c,
        //     navpeII__Transaction_Type__c = 'Other Type',
        //     navpeII__Deal_Type__c = 'Other Deal',
        //     navpeII__EBITDA__c = 999999, // Out of range
        //     navpeII__Revenue__c = 999999, // Out of range
        //     navpeII__Investment_Size__c = 999
        // );
        // insert stageDeal;
        // Contact stageContact = new Contact(LastName = 'Stage Expert');
        // insert stageContact;
        // navpeII__Deal_Team__c stageDT = new navpeII__Deal_Team__c(navpeII__Deal__c = stageDeal.Id, navpeII__Deal_Contact__c = stageContact.Id);
        // insert stageDT;
    }

    @isTest
    static void testFindDealExperts() {
        // Query input deal
        navpeII__Pipeline__c inputDeal = [SELECT Id FROM navpeII__Pipeline__c WHERE Name = 'Input Deal' LIMIT 1];

        // Prepare request
        List<NavatarFindDealExperts.Request> requests = new List<NavatarFindDealExperts.Request>();
        NavatarFindDealExperts.Request req = new NavatarFindDealExperts.Request();
        req.pipelineId = inputDeal.Id;
        requests.add(req);

        // Call method
        Test.startTest();
        List<NavatarFindDealExperts.Response> responses = NavatarFindDealExperts.findDealExperts(requests);
        Test.stopTest();

        // Assert
        System.assertEquals(1, responses.size(), 'Should return one response');
        System.assertNotEquals(null, responses[0].expertDetails, 'Expert details should not be null');
        System.assert(responses[0].expertDetails.contains('Expert'), 'Expert details should mention expert');
        System.assertEquals(inputDeal.Id, responses[0].dealId, 'Deal Id should match input');
    }
}