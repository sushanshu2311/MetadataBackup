/****************************************************************************************************
** Module Name : Add Deal Experts
** Description : Test Class for NavatarAddDealExperts.
** Organization : Navatar Group
** Product Name & Version : PE Agentforce Baseline 1.0
** Revision History:-
** Version    Date(YYYY-MM-DD)    Author            Description of Action
** 1.0        2026-02-05          Sudhanshu         PE Agentforce Baseline Phase 1
****************************************************************************************************/

@isTest
public with sharing class NavatarAddDealExpertsTest {
    @testSetup
    static void setup() {
        // Create test Account
        Account acc = new Account(Name = 'Test Account');
        insert acc;
        // Create test Contacts
        List<Contact> contacts = new List<Contact>();
        for (Integer i = 0; i < 3; i++) {
            contacts.add(new Contact(FirstName = 'Test', LastName = 'Contact' + i, AccountId = acc.Id));
        }
        insert contacts;

        // Create test Deal
        navpeII__Pipeline__c deal = new navpeII__Pipeline__c();
        deal.Name = 'Testing';
        deal.navpeII__Company__c = acc.id;
        deal.navpeII__Our_Role__c = 'Lead';
        deal.navpeII__Stage__c = 'IOI';
        insert deal;

        navpeII__Deal_Team__c dealTeam = new navpeII__Deal_Team__c();
        dealTeam.navpeII__Deal__c = deal.id;
        dealTeam.navpeII__Deal_Contact__c = contacts[0].id;
        insert dealTeam;
    }

    @isTest
    static void testExtractAndAddDealExperts_All() {
        // Get test data
        Account acc = [SELECT Id FROM Account LIMIT 1];
        List<Contact> contacts = [SELECT Id FROM Contact WHERE AccountId = :acc.Id];
        navpeII__Pipeline__c deal = [SELECT Id FROM navpeII__Pipeline__c WHERE navpeII__Company__c = :acc.Id LIMIT 1];
        // Build formattedText with contact links
        String formattedText = '';
        for (Contact c : contacts) {
            formattedText += '/'+c.Id+' ';
        }
        NavatarAddDealExperts.RequestWrapper req = new NavatarAddDealExperts.RequestWrapper();
        req.formattedText = formattedText;
        req.dealId = deal.Id;
        req.selectionMode = 'ALL';
        List<NavatarAddDealExperts.RequestWrapper> reqs = new List<NavatarAddDealExperts.RequestWrapper>{req};
        Test.startTest();
        List<NavatarAddDealExperts.ResponseWrapper> resps = NavatarAddDealExperts.extractAndAddDealExperts(reqs);
        Test.stopTest();
        System.assertEquals('Expert was successfully added to your Deal.', resps[0].message);
        List<navpeII__Deal_Team__c> dealTeams = [SELECT Id, navpeII__Deal_Contact__c FROM navpeII__Deal_Team__c WHERE navpeII__Deal__c = :deal.Id];
        System.assertEquals(contacts.size(), dealTeams.size());
    }

    @isTest
    static void testExtractAndAddDealExperts_Index() {
        Account acc = [SELECT Id FROM Account LIMIT 1];
        List<Contact> contacts = [SELECT Id FROM Contact WHERE AccountId = :acc.Id];
        navpeII__Pipeline__c deal = [SELECT Id FROM navpeII__Pipeline__c WHERE navpeII__Company__c = :acc.Id LIMIT 1];
        String formattedText = '';
        for (Contact c : contacts) {
            formattedText += '/'+c.Id+' ';
        }
        NavatarAddDealExperts.RequestWrapper req = new NavatarAddDealExperts.RequestWrapper();
        req.formattedText = formattedText;
        req.dealId = deal.Id;
        req.selectionMode = 'INDEX';
        req.selectedIndexes = '1,3';
        List<NavatarAddDealExperts.RequestWrapper> reqs = new List<NavatarAddDealExperts.RequestWrapper>{req};
        Test.startTest();
        List<NavatarAddDealExperts.ResponseWrapper> resps = NavatarAddDealExperts.extractAndAddDealExperts(reqs);
        Test.stopTest();
        System.assertEquals('Expert was successfully added to your Deal.', resps[0].message);
        List<navpeII__Deal_Team__c> dealTeams = [SELECT navpeII__Deal_Contact__c FROM navpeII__Deal_Team__c WHERE navpeII__Deal__c = :deal.Id];
        System.assertEquals(2, dealTeams.size());
    }

    @isTest
    static void testNoNewExpertsToAdd() {
        Account acc = [SELECT Id FROM Account LIMIT 1];
        List<Contact> contacts = [SELECT Id FROM Contact WHERE AccountId = :acc.Id];
        navpeII__Pipeline__c deal = [SELECT Id FROM navpeII__Pipeline__c WHERE navpeII__Company__c = :acc.Id LIMIT 1];
        // Add all contacts as deal experts first
        List<navpeII__Deal_Team__c> dealTeams = new List<navpeII__Deal_Team__c>();
        for (Contact c : contacts) {
            dealTeams.add(new navpeII__Deal_Team__c(navpeII__Deal__c = deal.Id, navpeII__Deal_Contact__c = c.Id));
        }
        insert dealTeams;
        // Now try to add again
        String formattedText = '';
        for (Contact c : contacts) {
            formattedText += '/'+c.Id+' ';
        }
        NavatarAddDealExperts.RequestWrapper req = new NavatarAddDealExperts.RequestWrapper();
        req.formattedText = formattedText;
        req.dealId = deal.Id;
        req.selectionMode = 'ALL';
        List<NavatarAddDealExperts.RequestWrapper> reqs = new List<NavatarAddDealExperts.RequestWrapper>{req};
        Test.startTest();
        List<NavatarAddDealExperts.ResponseWrapper> resps = NavatarAddDealExperts.extractAndAddDealExperts(reqs);
        Test.stopTest();
        System.assertEquals('No new experts to add.', resps[0].message);
    }

    @isTest
    static void testInvalidIndexes() {
        Account acc = [SELECT Id FROM Account LIMIT 1];
        List<Contact> contacts = [SELECT Id FROM Contact WHERE AccountId = :acc.Id];
        navpeII__Pipeline__c deal = [SELECT Id FROM navpeII__Pipeline__c WHERE navpeII__Company__c = :acc.Id LIMIT 1];
        String formattedText = '';
        for (Contact c : contacts) {
            formattedText += '/'+c.Id+' ';
        }
        NavatarAddDealExperts.RequestWrapper req = new NavatarAddDealExperts.RequestWrapper();
        req.formattedText = formattedText;
        req.dealId = deal.Id;
        req.selectionMode = 'INDEX';
        req.selectedIndexes = '100,abc'; // invalid indexes
        List<NavatarAddDealExperts.RequestWrapper> reqs = new List<NavatarAddDealExperts.RequestWrapper>{req};
        Test.startTest();
        List<NavatarAddDealExperts.ResponseWrapper> resps = NavatarAddDealExperts.extractAndAddDealExperts(reqs);
        Test.stopTest();
        System.assertEquals('No new experts to add.', resps[0].message);
    }

    @isTest
    static void testExceptionHandling() {
        NavatarAddDealExperts.RequestWrapper req = new NavatarAddDealExperts.RequestWrapper();
        req.formattedText = null; // will cause exception
        req.dealId = null;
        req.selectionMode = 'ALL';
        List<NavatarAddDealExperts.RequestWrapper> reqs = new List<NavatarAddDealExperts.RequestWrapper>{req};
        Test.startTest();
        List<NavatarAddDealExperts.ResponseWrapper> resps = NavatarAddDealExperts.extractAndAddDealExperts(reqs);
        Test.stopTest();
        System.assert(resps[0].message.startsWith('Error:'));
    }
}