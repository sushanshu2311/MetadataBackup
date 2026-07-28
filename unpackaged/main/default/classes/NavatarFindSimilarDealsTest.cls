/****************************************************************************************************
** Module Name : Find Similar Deals Test Class 1.0 
** Description : Test Class for NavatarFindSimilarDeals.
** Organization : Navatar Group
** Product Name & Version : PE Agentforce Baseline 1.0
** Revision History:-
** Version    Date(YYYY-MM-DD)    Author            Description of Action
** 1.0        2026-02-05          Sudhanshu         PE Agentforce Baseline Phase 1
****************************************************************************************************/

@isTest
public class NavatarFindSimilarDealsTest {
    @testSetup
    static void setupTestData() {
        // Create test Company
        Id devRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Company').getRecordTypeId();//AA-780
        Account company = new Account();
        company.RecordTypeId = devRecordTypeId;
        company.Name = 'Test Class';
        insert company;

        // Create input deal
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

        navpeII__Pipeline__c inputnDeal = new navpeII__Pipeline__c(
            Name = 'Input Deal check null',
            navpeII__Company__c = null,
            navpeII__Revenue__c = null,
            navpeII__EBITDA__c = null,
            navpeII__Stage__c = null,
            navpeII__Deal_Type__c = null
        );
        insert inputnDeal;

        // Create similar deals
        List<navpeII__Pipeline__c> deals = new List<navpeII__Pipeline__c>();
        for (Integer i = 0; i < 2; i++) {
            deals.add(new navpeII__Pipeline__c(
                Name = 'Similar Deal ' + i,
                navpeII__Company__c = company.Id,
                navpeII__Stage__c = 'Stage 1',
                navpeII__Transaction_Type__c = 'Type A',
                navpeII__Deal_Type__c = 'Type X',
                navpeII__EBITDA__c = 110000,
                navpeII__Revenue__c = 510000,
                navpeII__Investment_Size__c = 210000
            ));
        }
        deals.add(new navpeII__Pipeline__c(
            Name = 'Similar Deal 0',
            navpeII__Company__c = company.Id,
            navpeII__Stage__c = 'Other Stage', // does not match input
            navpeII__Transaction_Type__c = 'Other Type',
            navpeII__Deal_Type__c = 'Other Deal',
            navpeII__EBITDA__c = 999999, // out of range
            navpeII__Revenue__c = 999999, // out of range
            navpeII__Investment_Size__c = 210000
        ));
        // Deal 1: Matches on Industry and Revenue (score 65)
        deals.add(new navpeII__Pipeline__c(
            Name = 'Similar Deal 1',
            navpeII__Company__c = company.Id,
            navpeII__Stage__c = 'Other Stage',
            navpeII__Transaction_Type__c = 'Other Type',
            navpeII__Deal_Type__c = 'Other Deal',
            navpeII__EBITDA__c = 999999, // out of range
            navpeII__Revenue__c = 500000, // matches input revenue (±15%)
            navpeII__Investment_Size__c = 210000
        ));
        insert deals;

        // Create contacts
        List<Contact> contacts = new List<Contact>();
        for (Integer i = 0; i < 4; i++) {
            contacts.add(new Contact(LastName = 'Expert ' + i));
        }
        insert contacts;

        // Assign contacts to deals (Deal Team)
        List<navpeII__Deal_Team__c> dealTeams = new List<navpeII__Deal_Team__c>();
        for (Integer i = 0; i < deals.size(); i++) {
            dealTeams.add(new navpeII__Deal_Team__c(
                navpeII__Deal__c = deals[i].Id,
                navpeII__Deal_Contact__c = contacts[i].Id
            ));
        }
        insert dealTeams;

        ContentVersion cv = new ContentVersion(
            Title = 'Test File',
            PathOnClient = 'TestFile.txt',
            VersionData = Blob.valueOf('This is a test file')
        );
        insert cv;

        ContentDocumentLink cdl = new ContentDocumentLink(
            ContentDocumentId = [
            SELECT Id, ContentDocumentId
            FROM ContentVersion
            WHERE Id = :cv.Id LIMIT 1
        ].ContentDocumentId,
            LinkedEntityId = deals[0].Id,
            ShareType = 'V',      // Viewer permission
            Visibility = 'AllUsers'
        );
        insert cdl;

    }

    @isTest
    static void testFindSimilarDeals() {
        navpeII__Pipeline__c inputDeal = [SELECT Id FROM navpeII__Pipeline__c WHERE Name = 'Input Deal' LIMIT 1];
        List<NavatarFindSimilarDeals.Request> requests = new List<NavatarFindSimilarDeals.Request>();
        NavatarFindSimilarDeals.Request req = new NavatarFindSimilarDeals.Request();
        req.pipelineId = inputDeal.Id;
        requests.add(req);
        Test.startTest();
        List<NavatarFindSimilarDeals.Response> responses = NavatarFindSimilarDeals.findSimilarDeals(requests);
        Test.stopTest();
        System.assertEquals(1, responses.size(), 'Should return one response');
        System.assertNotEquals(null, responses[0].relatedDealDetails, 'Related deal details should not be null');
        System.assert(responses[0].relatedDealDetails.contains('Similar'), 'Output should mention similarity');
        System.assertEquals(inputDeal.Id, responses[0].dealId, 'Deal Id should match input');
        System.assertNotEquals(null, responses[0].top5Deals, 'Top 5 deals output should not be null');
    }

    @isTest
    static void testFindSimilarDealsNullRequest() {
        navpeII__Pipeline__c inputDeal = [SELECT Id,navpeII__Company__c FROM navpeII__Pipeline__c WHERE Name = 'Input Deal check null' LIMIT 1];
        inputDeal.navpeII__Company__c = null;
        update inputDeal;
        List<NavatarFindSimilarDeals.Request> requests = new List<NavatarFindSimilarDeals.Request>();
        NavatarFindSimilarDeals.Request req = new NavatarFindSimilarDeals.Request();
        req.pipelineId = inputDeal.Id;
        requests.add(req);
        Test.startTest();
        List<NavatarFindSimilarDeals.Response> responses = NavatarFindSimilarDeals.findSimilarDeals(requests);
        Test.stopTest();
        System.assertEquals('', responses[0].top5Deals, 'Should return message about missing data');
    }
}