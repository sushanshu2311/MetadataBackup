@isTest
private class NavCompanyPageControllerTest {

    private static Id companyRecordTypeId() {
        List<RecordType> rts = [
            SELECT Id FROM RecordType WHERE SobjectType = 'Account' AND Name = 'Company' LIMIT 1
        ];
        return rts.isEmpty() ? null : rts[0].Id;
    }

    @TestSetup
    static void setup() {
        Account company = new Account(
            Name = 'Testco Rehabilitation',
            RecordTypeId = companyRecordTypeId(),
            navpeII__Sector__c = 'Healthcare',
            navpeII__Industry_Level_2__c = 'Outpatient Rehabilitation',
            navpeII__Entity_Type__c = 'Private Company',
            BillingCity = 'Atlanta',
            BillingState = 'GA',
            BillingCountry = 'United States',
            NumberOfEmployees = 850,
            navpeII__LTM_Revenue__c = 48,
            navpeII__LTM_EBITDA__c = 10.6,
            navpeII__Status__c = 'Under Evaluation'
        );
        insert company;

        Contact primary = new Contact(FirstName = 'Pat', LastName = 'Primary', Title = 'CEO',
            AccountId = company.Id, Email = 'pat@testco.example.com',
            navpeII__Last_Touch_Point__c = Date.today().addDays(-5));
        Contact alum = new Contact(FirstName = 'Alex', LastName = 'Alumni', Title = 'Former COO');
        Contact ext = new Contact(FirstName = 'Erin', LastName = 'Extended', Title = 'Chair');
        insert new List<Contact>{ primary, alum, ext };

        insert new List<navpeII__Affiliation__c>{
            new navpeII__Affiliation__c(navpeII__Contact__c = alum.Id,
                navpeII__Institution__c = company.Id, navpeII__Role__c = 'Former Employee'),
            new navpeII__Affiliation__c(navpeII__Contact__c = ext.Id,
                navpeII__Institution__c = company.Id, navpeII__Role__c = 'Board Member')
        };

        // The navpeII pipeline trigger rejects two deals for the same company in one DML,
        // so these go in one at a time.
        Account banker = new Account(Name = 'Testbank Partners');
        insert banker;
        Contact bankerContact = new Contact(FirstName = 'Bea', LastName = 'Banker', AccountId = banker.Id);
        insert bankerContact;

        insert new navpeII__Pipeline__c(Name = 'Test Deal Active', navpeII__Company__c = company.Id,
            navpeII__Stage__c = 'NDA Signed', navpeII__Deal_Type__c = 'Limited Auction',
            navpeII__Enterprise_Value__c = 455, navpeII__Log_In_Date__c = Date.today(),
            navpeII__Source_Company__c = banker.Id, navpeII__Source_Contact__c = bankerContact.Id);
        insert new navpeII__Pipeline__c(Name = 'Test Deal Closed', navpeII__Company__c = company.Id,
            navpeII__Stage__c = 'Closed', navpeII__Log_In_Date__c = Date.today().addYears(-2));
        insert new navpeII__Pipeline__c(Name = 'Test Deal Passed', navpeII__Company__c = company.Id,
            navpeII__Stage__c = 'Declined/Dead', navpeII__Log_In_Date__c = Date.today().addYears(-3));

        insert new List<Task>{
            new Task(Subject = 'Open task mine', WhatId = company.Id, OwnerId = UserInfo.getUserId(),
                ActivityDate = Date.today().addDays(-1), Status = 'Not Started', Priority = 'High'),
            new Task(Subject = 'Logged email', WhatId = company.Id, WhoId = primary.Id,
                TaskSubtype = 'Email', Status = 'Completed', ActivityDate = Date.today().addDays(-3),
                Description = 'Line one\nLine two of the email body.'),
            new Task(Subject = 'Logged call', WhatId = company.Id, WhoId = primary.Id,
                TaskSubtype = 'Call', Status = 'Completed', ActivityDate = Date.today().addDays(-4),
                Description = 'Call notes.')
        };

        insert new Event(Subject = 'Logged meeting', WhatId = company.Id, WhoId = primary.Id,
            DurationInMinutes = 30, ActivityDateTime = Datetime.now().addDays(-2),
            Description = 'Meeting notes.');
    }

    private static Account theCompany() {
        return [SELECT Id FROM Account WHERE Name = 'Testco Rehabilitation' LIMIT 1];
    }

    @isTest
    static void profileFormatsFinancialsAndFallsBackToDash() {
        Account a = theCompany();

        Test.startTest();
        NavCompanyPageController.CompanyProfile p = NavCompanyPageController.getCompanyProfile(a.Id);
        Test.stopTest();

        System.assertEquals('Healthcare', p.sector, 'sector should come from the record');
        System.assertEquals('Atlanta, GA', p.hq, 'HQ should join city and state');
        System.assertEquals('$48M', p.revenue, 'revenue should render in millions');
        System.assertEquals('$10.6M · 22%', p.ebitda, 'EBITDA should carry the computed margin');
        System.assertEquals('850', p.employees, 'employees should render as a plain number');
    }

    @isTest
    static void profileFallsBackToDashesWhenFieldsAreEmpty() {
        Account other = new Account(Name = 'No Fields Co');
        insert other;

        NavCompanyPageController.CompanyProfile p = NavCompanyPageController.getCompanyProfile(other.Id);
        System.assertEquals('-', p.sector, 'a blank field should render as a hyphen');
        System.assertEquals('-', p.revenue, 'a null number should render as a hyphen');
        System.assertEquals('-', p.employees, 'a null employee count should render as a hyphen');
        System.assertEquals('-', p.hq, 'a record with no city or state should render as a hyphen');
    }

    @isTest
    static void profileReturnsNullWhenTheRecordIsNotVisible() {
        Contact notAnAccount = [SELECT Id FROM Contact WHERE LastName = 'Primary' LIMIT 1];
        Id missingAccountId = Id.valueOf('001' + String.valueOf(notAnAccount.Id).substring(3));

        System.assertEquals(null, NavCompanyPageController.getCompanyProfile(missingAccountId),
            'an id with no matching account should return null');
    }

    @isTest
    static void contactsAreGroupedByHowTheyReachTheCompany() {
        Account a = theCompany();

        List<NavCompanyPageController.ContactRow> rows = NavCompanyPageController.getContacts(a.Id);

        Map<String, String> categoryByName = new Map<String, String>();
        for (NavCompanyPageController.ContactRow r : rows) {
            categoryByName.put(r.name, r.category);
        }
        System.assertEquals(3, rows.size(), 'all three contacts should be returned');
        System.assertEquals('primary', categoryByName.get('Pat Primary'), 'contacts at the company are Primary');
        System.assertEquals('alumni', categoryByName.get('Alex Alumni'), 'Former Employee affiliations are Alumni');
        System.assertEquals('extended', categoryByName.get('Erin Extended'), 'other affiliations are Extended Network');

        for (NavCompanyPageController.ContactRow r : rows) {
            if (r.name == 'Erin Extended') {
                System.assertEquals('Testco Rehabilitation · Board Member', r.org,
                    'an affiliated contact reads as company then role');
            }
            if (r.name == 'Pat Primary') {
                System.assertEquals('Testco Rehabilitation', r.org,
                    'a primary contact reads as the company alone');
            }
        }
    }

    @isTest
    static void createContactAddsPrimaryOnTheAccount() {
        Account a = theCompany();

        Test.startTest();
        NavCompanyPageController.ContactRow row = NavCompanyPageController.createContact(
            a.Id, 'New', 'Primary', 'CFO', 'new@testco.example.com', 'primary');
        Test.stopTest();

        System.assertEquals('primary', row.category, 'the new row should be Primary');
        Contact created = [SELECT AccountId FROM Contact WHERE Id = :row.recordId];
        System.assertEquals(a.Id, created.AccountId, 'a Primary contact should sit on the company');
    }

    @isTest
    static void createContactAddsAffiliationForNonPrimary() {
        Account a = theCompany();

        NavCompanyPageController.ContactRow row = NavCompanyPageController.createContact(
            a.Id, 'New', 'Alum', 'Ex-CTO', null, 'alumni');

        List<navpeII__Affiliation__c> links = [
            SELECT navpeII__Role__c FROM navpeII__Affiliation__c
            WHERE navpeII__Contact__c = :row.recordId AND navpeII__Institution__c = :a.Id
        ];
        System.assertEquals(1, links.size(), 'a non-primary contact should be linked by affiliation');
        System.assertEquals('Former Employee', links[0].navpeII__Role__c, 'alumni maps to Former Employee');
        Contact created = [SELECT AccountId FROM Contact WHERE Id = :row.recordId];
        System.assertEquals(null, created.AccountId, 'a non-primary contact should not sit on the company');
    }

    @isTest
    static void createContactRejectsMissingName() {
        Account a = theCompany();

        Boolean threw = false;
        try {
            NavCompanyPageController.createContact(a.Id, 'No', '   ', null, null, 'primary');
        } catch (AuraHandledException e) {
            threw = true;
        }
        System.assert(threw, 'a blank last name should be rejected');
    }

    @isTest
    static void removeContactDropsAffiliationButKeepsContact() {
        Account a = theCompany();
        Contact alum = [SELECT Id FROM Contact WHERE LastName = 'Alumni' LIMIT 1];

        Test.startTest();
        NavCompanyPageController.removeContact(a.Id, alum.Id);
        Test.stopTest();

        System.assertEquals(0, [
            SELECT COUNT() FROM navpeII__Affiliation__c
            WHERE navpeII__Contact__c = :alum.Id AND navpeII__Institution__c = :a.Id
        ], 'the affiliation should be gone');
        System.assertEquals(1, [SELECT COUNT() FROM Contact WHERE Id = :alum.Id],
            'the contact itself should survive');
    }

    @isTest
    static void removeContactDeletesAContactOwnedByTheCompany() {
        Account a = theCompany();
        Contact primary = [SELECT Id FROM Contact WHERE LastName = 'Primary' LIMIT 1];

        NavCompanyPageController.removeContact(a.Id, primary.Id);

        System.assertEquals(0, [SELECT COUNT() FROM Contact WHERE Id = :primary.Id],
            'a contact belonging to the company should be removed');
    }

    @isTest
    static void dealsCarryStatusBuckets() {
        Account a = theCompany();

        List<NavCompanyPageController.DealRow> rows = NavCompanyPageController.getDeals(a.Id);

        Map<String, String> bucketByName = new Map<String, String>();
        for (NavCompanyPageController.DealRow r : rows) {
            bucketByName.put(r.name, r.bucket);
        }
        System.assertEquals('active', bucketByName.get('Test Deal Active'), 'NDA Signed is Active');
        System.assertEquals('closed', bucketByName.get('Test Deal Closed'), 'Closed is Closed');
        System.assertEquals('passed', bucketByName.get('Test Deal Passed'), 'Declined/Dead is Passed');
        for (NavCompanyPageController.DealRow r : rows) {
            if (r.name == 'Test Deal Active') {
                System.assertEquals('$455M', r.enterpriseValue, 'EV should render in millions');
                System.assertEquals('NDA Signed', r.stage, 'stage is the raw field value, no badge');
                System.assertEquals('Testbank Partners', r.sourceFirmName,
                    'the source firm travels with the deal so AI text can link it');
                System.assertEquals('Bea Banker', r.sourceContactName,
                    'the source contact travels with the deal so AI text can link it');
            }
        }
    }

    @isTest
    static void openTasksExcludeLoggedActivityAndFlagOwnership() {
        Account a = theCompany();

        List<NavCompanyPageController.TaskItem> items = NavCompanyPageController.getOpenTasks(a.Id);

        System.assertEquals(1, items.size(), 'only open tasks belong in the widget');
        System.assertEquals('Open task mine', items[0].subject, 'the open task should be returned');
        System.assert(items[0].isMine, 'a task owned by the running user is Mine');
        System.assert(items[0].isOverdue, 'a past due date should be flagged overdue');
    }

    @isTest
    static void interactionsCombineTasksAndEventsNewestFirst() {
        Account a = theCompany();

        List<NavCompanyPageController.InteractionRow> rows = NavCompanyPageController.getInteractions(a.Id);

        System.assertEquals(3, rows.size(),
            'the two completed tasks and the event are interactions; the open task is not');
        System.assertEquals('Logged meeting', rows[0].subject, 'newest interaction sorts first');
        Set<String> types = new Set<String>();
        for (NavCompanyPageController.InteractionRow r : rows) {
            types.add(r.interactionType);
        }
        System.assert(types.contains('email'), 'email interactions should be typed');
        System.assert(types.contains('call'), 'call interactions should be typed');
        System.assert(types.contains('meeting'), 'events should be typed as meetings');
        for (NavCompanyPageController.InteractionRow r : rows) {
            if (r.subject == 'Logged email') {
                System.assertEquals('Line one Line two of the email body.', r.snippet,
                    'the snippet should be a flattened single line');
            }
        }
    }

    @isTest
    static void documentsCarrySourceTagAndDealName() {
        Account a = theCompany();
        navpeII__Pipeline__c deal = [SELECT Id FROM navpeII__Pipeline__c WHERE Name = 'Test Deal Active' LIMIT 1];

        ContentVersion cv = new ContentVersion(Title = 'Test CIM', PathOnClient = 'Test CIM.pdf',
            Description = 'SharePoint', VersionData = Blob.valueOf('file body'));
        ContentVersion cv2 = new ContentVersion(Title = 'Untagged file', PathOnClient = 'Untagged file.pdf',
            VersionData = Blob.valueOf('file body'));
        insert new List<ContentVersion>{ cv, cv2 };

        List<ContentVersion> stored = [
            SELECT ContentDocumentId, Title FROM ContentVersion WHERE Id IN (:cv.Id, :cv2.Id)
        ];
        List<ContentDocumentLink> links = new List<ContentDocumentLink>();
        for (ContentVersion v : stored) {
            links.add(new ContentDocumentLink(ContentDocumentId = v.ContentDocumentId,
                LinkedEntityId = a.Id, ShareType = 'V', Visibility = 'AllUsers'));
            if (v.Title == 'Test CIM') {
                links.add(new ContentDocumentLink(ContentDocumentId = v.ContentDocumentId,
                    LinkedEntityId = deal.Id, ShareType = 'V', Visibility = 'AllUsers'));
            }
        }
        insert links;

        Test.startTest();
        List<NavCompanyPageController.DocumentRow> rows = NavCompanyPageController.getDocuments(a.Id);
        Test.stopTest();

        System.assertEquals(2, rows.size(), 'both files linked to the account should be listed');
        Map<String, NavCompanyPageController.DocumentRow> byTitle =
            new Map<String, NavCompanyPageController.DocumentRow>();
        for (NavCompanyPageController.DocumentRow r : rows) {
            byTitle.put(r.title, r);
        }
        System.assertEquals('SharePoint', byTitle.get('Test CIM').source, 'the source tag comes from the description');
        System.assertEquals('Test Deal Active', byTitle.get('Test CIM').dealName,
            'a file also linked to a deal shows that deal');
        System.assertEquals('Navatar', byTitle.get('Untagged file').source, 'an untagged file defaults to Navatar');
        System.assertEquals(null, byTitle.get('Untagged file').dealName, 'a file with no deal link has no deal');
    }

    @isTest
    static void documentsAreEmptyWhenNoneAreLinked() {
        Account bare = new Account(Name = 'No Files Co');
        insert bare;

        System.assertEquals(0, NavCompanyPageController.getDocuments(bare.Id).size(),
            'an account with no files returns an empty list');
    }
}