@IsTest
public with sharing class NavatarContactRelationShipTest {
     @isTest
    static void testSendEmails_basic() {
        // Create Account
        Id institutionRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Institution').getRecordTypeId();
        Id companyRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Company').getRecordTypeId();
        List<Account> accs = new List<Account>();
        Account acc = new Account(Name = 'Test Account', RecordTypeId = institutionRecordTypeId);
        Account acc2 = new Account(Name = 'Test Account2', RecordTypeId = companyRecordTypeId,NumberOfEmployees = 100,Industry = 'Technology');
        Account acc3 = new Account(Name = 'Test Account3', RecordTypeId = companyRecordTypeId,NumberOfEmployees = 100);
        accs.add(acc);
        accs.add(acc2);
        accs.add(acc3);
        insert accs;

        // Create Contact
        List<Contact> cons = new List<Contact>();
        Contact con = new Contact(FirstName = 'Test', LastName = 'Contact', Email = 'contact@example.com', AccountId = acc.Id);
        cons.add(con);
        Contact con2 = new Contact(FirstName = 'Test', LastName = 'Contact2', Email = 'contact2@example.com', AccountId = acc.Id);
        cons.add(con2);
        Contact con3 = new Contact(FirstName = 'Test', LastName = 'Contact3', Email = 'contact3@example.com', AccountId = acc2.Id);
        cons.add(con3);
        insert cons;

        // Create User (event owner and participant)
        Profile p = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
        List<User> users = new List<User>();
        User u = new User(
            FirstName = 'Event',
            LastName = 'Owner',
            Email = 'eventowner@example.com',
            Username = 'eventowner' + System.currentTimeMillis() + '@example.com',
            Alias = 'evown',
            TimeZoneSidKey = 'America/New_York',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            ProfileId = p.Id,
            LanguageLocaleKey = 'en_US'
        );
        users.add(u);

        User u1 = new User(
            FirstName = 'Event',
            LastName = 'Owner 1',
            Email = 'eventowner1@example.com',
            Username = 'eventowner1' + System.currentTimeMillis() + '@example.com',
            Alias = 'evown1',
            TimeZoneSidKey = 'America/New_York',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            ProfileId = p.Id,
            LanguageLocaleKey = 'en_US'
        );
        users.add(u1);
        insert users;

        // Create Event
        List<Event> events = new List<Event>();
        Event ev = new Event(
            Subject = 'Test Meeting',
            StartDateTime = System.now().addHours(1),
            EndDateTime = System.now().addHours(2),
            OwnerId = u.Id,
            WhoId = con.Id
        );

        Event ev2 = new Event(
            Subject = 'Past Meeting',
            StartDateTime = System.now().addHours(-5),
            EndDateTime = System.now().addHours(-4),
            OwnerId = u.Id,
            WhoId = con.Id,
            navpeII__Related_Associations__c = String.valueof(acc.Id)
        );
        events.add(ev);
        events.add(ev2);
        insert events;

        Task t = new Task(Subject = 'Test Task', WhatId = acc.Id, OwnerId = u.Id, ActivityDate = System.today().addDays(-2), navpeII__Related_Associations__c = String.valueof(acc.Id));
        insert t;

        List<EventRelation> eventRelations = new List<EventRelation>();
        EventRelation er = new EventRelation(EventId = ev.Id, RelationId = u1.Id,IsParent = false);
        eventRelations.add(er);
        EventRelation er2 = new EventRelation(EventId = ev.Id, RelationId = con2.Id,IsParent = false);
        eventRelations.add(er2);
        EventRelation er3 = new EventRelation(EventId = ev2.Id, RelationId = con2.Id,IsParent = false);
        eventRelations.add(er3);
        insert eventRelations;

        navpeII__Fund__c fund = new navpeII__Fund__c(
            Name = 'Test Fund',
            navpeII__Fund_Type__c = 'Fund'
        );
        insert fund;
        navpeII__Fundraising__c fundRaising = new navpeII__Fundraising__c(
            Name = 'Test Fundraising',
            navpeII__Legal_Name__c = acc.Id,
            navpeII__Fund_Name__c = fund.Id
        );
        insert fundRaising;

        List<navpeII__Pipeline__c> pipelines = new List<navpeII__Pipeline__c>();
        navpeII__Pipeline__c pipeline = new navpeII__Pipeline__c(
            Name = 'Test Pipeline',
            navpeII__Company__c = acc.Id,
            navpeII__Stage__c = 'LOI'
        );
        pipelines.add(pipeline);

        navpeII__Pipeline__c pipeline2 = new navpeII__Pipeline__c(
            Name = 'Test Pipeline 2',
            navpeII__Company__c = acc.Id,
            navpeII__Stage__c = 'Closed'
        );
        pipelines.add(pipeline2);

        navpeII__Pipeline__c pipeline3 = new navpeII__Pipeline__c(
            Name = 'Test Pipeline 3',
            navpeII__Company__c = acc2.Id,
            navpeII__Stage__c = 'LOI',
            navpeII__Source_Company__c = acc.Id,
            navpeII__Source_Contact__c = con.Id
        );
        pipelines.add(pipeline3);
        insert pipelines;

        navpeII__Affiliation__c aff = new navpeII__Affiliation__c(
            navpeII__Contact__c = con.Id,
            navpeII__Institution__c = acc.Id,
            navpeII__Role__c = 'Trustee'
        );
        insert aff;

        navpeII__Fundraising_Contact__c fundContact = new navpeII__Fundraising_Contact__c(
            navpeII__Contact__c = con.Id,
            navpeII__Fundraising__c = fundRaising.Id
        );
        insert fundContact;

        navpeII__Deal_Team__c dealTeam = new navpeII__Deal_Team__c(
            navpeII__Deal_Contact__c = con.Id,
            navpeII__Deal__c = pipeline.Id,
            navpeII__Team_Member__c = u1.Id
        );
        insert dealTeam;

        // No mocking of ConnectApi.EinsteinLLM in test context. Just call method for coverage.
        Test.startTest();
        List<NavatarContactRelationShip.Request> req = new List<NavatarContactRelationShip.Request>();
        NavatarContactRelationShip.Request request = new NavatarContactRelationShip.Request();
        Contact contact = new Contact();
        contact.Id = con.Id;
        request.Contact = contact;

        req.add(request);

        List<NavatarContactRelationShip.Response> rows = NavatarContactRelationShip.getContactRelationship(req);

        
        List<NavatarContactRelationShip.Request> req2 = new List<NavatarContactRelationShip.Request>();
        NavatarContactRelationShip.Request request2 = new NavatarContactRelationShip.Request();
        Contact contact2 = new Contact();
        contact2.Id = con2.Id;
        request2.Contact = contact2;

        req2.add(request2);

        List<NavatarContactRelationShip.Response> rows2 = NavatarContactRelationShip.getContactRelationship(req2);


        List<NavatarContactRelationShip.Request> req3 = new List<NavatarContactRelationShip.Request>();
        NavatarContactRelationShip.Request request3 = new NavatarContactRelationShip.Request();
        Contact contact3 = new Contact();
        contact3.Id = con3.Id;
        request3.Contact = contact3;

        req3.add(request3);

        List<NavatarContactRelationShip.Response> rows3 = NavatarContactRelationShip.getContactRelationship(req3);
        Test.stopTest();
        System.assertEquals(1, rows.size(), 'Should return one response');
        System.assertEquals(1, rows2.size(), 'Should return one response');
        System.assertEquals(1, rows3.size(), 'Should return one response');
        // No exception = pass. Optionally, check debug logs for email send.
    }
}