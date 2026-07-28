/****************************************************************************************************
** Module Name : Find Similar Deals Email Sender 1.0 
** Description : Test Class for NavatarFindSimilarDealsSendEmail.
** Organization : Navatar Group
** Product Name & Version : PE Agentforce Baseline 1.0
** Revision History:-
** Version    Date(YYYY-MM-DD)    Author            Description of Action
** 1.0        2026-02-05          Sudhanshu         PE Agentforce Baseline Phase 1
****************************************************************************************************/
@isTest
public class NavatarFindSimilarDealsSendEmailTest {
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
        insert deals;

        // Create contacts
        List<Contact> contacts = new List<Contact>();
        for (Integer i = 0; i < 2; i++) {
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
                SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id LIMIT 1
            ].ContentDocumentId,
            LinkedEntityId = deals[0].Id,
            ShareType = 'V',
            Visibility = 'AllUsers'
        );
        insert cdl;
    }

    @isTest
    static void testFindSimilarDealsAndSendEmail() {
        navpeII__Pipeline__c inputDeal = [SELECT Id FROM navpeII__Pipeline__c WHERE Name = 'Input Deal' LIMIT 1];
        List<NavatarFindSimilarDealsSendEmail.Request> requests = new List<NavatarFindSimilarDealsSendEmail.Request>();
        NavatarFindSimilarDealsSendEmail.Request req = new NavatarFindSimilarDealsSendEmail.Request();
        req.pipelineId = inputDeal.Id;
        requests.add(req);
        Test.startTest();
        List<NavatarFindSimilarDealsSendEmail.Response> responses = NavatarFindSimilarDealsSendEmail.findSimilarDeals(requests);
        Test.stopTest();
        System.assertEquals(1, responses.size(), 'Should return one response');
        System.assertEquals('Success: Email sent.', responses[0].message, 'Should return success message');
    }

    @isTest
    static void testFindSimilarDealsAndSendEmail_NullRequest() {
        List<NavatarFindSimilarDealsSendEmail.Request> requests = new List<NavatarFindSimilarDealsSendEmail.Request>();
        Test.startTest();
        List<NavatarFindSimilarDealsSendEmail.Response> responses = NavatarFindSimilarDealsSendEmail.findSimilarDeals(requests);
        Test.stopTest();
        System.assertEquals(0, responses.size(), 'Should return empty response for null/empty request');
    }
}