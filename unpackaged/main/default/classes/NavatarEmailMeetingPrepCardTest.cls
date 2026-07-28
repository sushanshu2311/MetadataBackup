@isTest
public class NavatarEmailMeetingPrepCardTest {
    @testSetup
    static void setupData() {
        // Create Accounts
		Id institutionRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Institution').getRecordTypeId();
        Account acc = new Account(Name = 'Test Account', RecordTypeId = institutionRecordTypeId);
        Account acc2 = new Account(Name = 'Test Account2');
        insert new List<Account>{acc, acc2};

        // Create Contacts
        Contact con = new Contact(FirstName = 'Test', LastName = 'Contact', Email = 'contact@example.com', AccountId = acc.Id);
        Contact con2 = new Contact(FirstName = 'Second', LastName = 'Contact', Email = 'contact2@example.com', AccountId = acc.Id);
        insert new List<Contact>{con, con2};

        // Create User (event owner and participant)
        Profile p = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
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
        insert u;

        // Create Fund and Fundraising
        navpeII__Fund__c fund = new navpeII__Fund__c(
            Name = 'Test Funds',
            navpeII__Fund_Type__c = 'Fund'
        );
        insert fund;
        navpeII__Fundraising__c fundRaising = new navpeII__Fundraising__c(
            Name = 'Test Fundraising',
            navpeII__Legal_Name__c = acc.Id,
            navpeII__Fund_Name__c = fund.Id
        );
        insert fundRaising;

        // Create Pipelines
        List<navpeII__Pipeline__c> pipelines = new List<navpeII__Pipeline__c>{
            new navpeII__Pipeline__c(
                Name = 'Test Pipeline',
                navpeII__Company__c = acc.Id,
                navpeII__Stage__c = 'LOI'
            ),
            new navpeII__Pipeline__c(
                Name = 'Test Pipeline 2',
                navpeII__Company__c = acc.Id,
                navpeII__Stage__c = 'Closed'
            ),
            new navpeII__Pipeline__c(
                Name = 'Test Pipeline 3',
                navpeII__Company__c = acc2.Id,
                navpeII__Stage__c = 'LOI',
                navpeII__Source_Company__c = acc.Id
            )
        };
        insert pipelines;

        

        navpeII__Affiliation__c aff = new navpeII__Affiliation__c(
            navpeII__Contact__c = con.Id,
            navpeII__Institution__c = acc.Id,
            navpeII__Role__c = 'Trustee'
        );
        insert aff;
    }
    @isTest
    static void testEmail() {
        Account acc = [SELECT Id FROM Account WHERE Name = 'Test Account' LIMIT 1];
        Contact con = [SELECT Id FROM Contact WHERE AccountId = :acc.Id LIMIT 1];
        User u = [SELECT Id FROM User WHERE Email = 'eventowner@example.com' LIMIT 1];
        // Create Event for the contact/account
        Event ev = new Event(
            Subject = 'Deal Meeting',
            StartDateTime = System.now().addHours(1),
            EndDateTime = System.now().addHours(2),
            OwnerId = u.Id,
            WhoId = con.Id
        );
        insert ev;
        Test.startTest();
        NavatarEmailMeetingPrepCard.sendEmails(new List<Id>{ev.Id});
         System.assertEquals(1, Limits.getEmailInvocations(), 'An email should have been sent by sendEmails');
        Test.stopTest();
        // Assert that an email was sent
       
    }

    
}