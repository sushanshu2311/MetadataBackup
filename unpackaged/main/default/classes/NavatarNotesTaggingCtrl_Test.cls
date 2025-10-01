@IsTest
public class NavatarNotesTaggingCtrl_Test {
    @testsetup
    static void createTestData() {
        List<Account> testAccounts = createTestAccounts(2);
        insert testAccounts;
        List<Contact> testContacts = createTestContacts(testAccounts);
        insert testContacts;
        
        navpeII_dev18__Pipeline__c deal = new navpeII_dev18__Pipeline__c();
        deal.Name = 'deal1';
        deal.navpeII_dev18__Our_Role__c = 'IOI';
        insert deal; 
        
        navpeII_dev18__Fund__c fnd = new navpeII_dev18__Fund__c(name = 'NVTR Test Fund');
        insert fnd;
        
        navpeII_dev18__Pipeline__c deal1 = new navpeII_dev18__Pipeline__c();
        deal1.Name = 'Testing';
        deal1.navpeII_dev18__Company__c = testAccounts[0].id;
        deal1.navpeII_dev18__Our_Role__c = 'Lead';
        deal1.navpeII_dev18__Stage__c = 'IOI';
        insert deal1;
        
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()]; 
        
        navpeII_dev18__Attendee__c att = new navpeII_dev18__Attendee__c();
        att.navpeII_dev18__Attendee_Staff__c = thisUser.id;
        insert att;
        
        event evt = new event();
        evt.WhoId = testContacts[0].id;
        evt.WhatId = att.id;
        evt.DurationInMinutes = 10;
        evt.Related_Associations__c=testAccounts[0].id+','+testContacts[0].id+','+thisUser.id;
        evt.OwnerId = thisUser.id;
        datetime dt = System.now();
        evt.ActivityDateTime = dt;
        evt.StartDateTime = dt;
        evt.DurationInMinutes = 60;
        evt.EndDateTime = dt.addMinutes(60);
        insert evt;
        
    }
    
    @IsTest
    private static void testcreateFundTeamRecords(){
       navpeII_dev18__Fund__c fund = [Select Id from navpeII_dev18__Fund__c limit 1];
        List<String> recordIds = new List<String>();
        recordIds.add(fund.Id);
        List<NavatarNotesTaggingCtrl.TeamMappingWrapper> mapingWrap = new List<NavatarNotesTaggingCtrl.TeamMappingWrapper>();
        mapingWrap.add(new NavatarNotesTaggingCtrl.TeamMappingWrapper());
        Test.startTest();
        try{
           NavatarNotesTaggingCtrl.createFundTeamRecords(JSON.serialize(mapingWrap),recordIds); 
        }catch(Exception e){
            
        }
        
        Test.stopTest();
    }
    
    @IsTest
    private static void testCreateDealTeamRecords(){
        navpeII_dev18__Pipeline__c deals = [Select Id from navpeII_dev18__Pipeline__c limit 1];
        event eve = [Select Id from event limit 1];
        List<String> recordIds = new List<String>();
        recordIds.add(deals.Id);
        List<NavatarNotesTaggingCtrl.TeamMappingWrapper> mapingWrap = new List<NavatarNotesTaggingCtrl.TeamMappingWrapper>();
        mapingWrap.add(new NavatarNotesTaggingCtrl.TeamMappingWrapper());
         Test.startTest();
        try{
           NavatarNotesTaggingCtrl.CreateDealTeamRecords(JSON.serialize(mapingWrap),recordIds); 
           NavatarNotesTaggingCtrl.getActivityData(eve.Id,'event');
           NavatarNotesTaggingCtrl.getActivityData(eve.Id,'aqbcd');
        }catch(Exception e){
            
        } 
        Test.stopTest();
    }
    
    @IsTest
    private static void testSaveFilesData(){
        event eve = [Select Id from event limit 1];
        List<NavatarNotesTaggingCtrl.FileWrapper> mapingWrap = new List<NavatarNotesTaggingCtrl.FileWrapper>();
        NavatarNotesTaggingCtrl.FileWrapper notesTag = new NavatarNotesTaggingCtrl.FileWrapper();
        notesTag.recordId = eve.Id;
        notesTag.filename = 'abcd';
        notesTag.base64 = 'efgh';
        notesTag.index = 0;
        mapingWrap.add(notesTag);
        Test.startTest();
        try{
           NavatarNotesTaggingCtrl.saveFilesData(JSON.serialize(mapingWrap),eve.Id);   
        }catch(Exception e){
            
        }
        Test.stopTest();
    }
    
    @IsTest
    private static void testGetExistingDealTeamMembers(){
        List<navpeII_dev18__Pipeline__c> deals = [Select Id from navpeII_dev18__Pipeline__c];
        List<String> deals1 = new List<String>();
        for(navpeII_dev18__Pipeline__c deal : deals){
           deals1.add(deal.Id); 
        }
      List<navpeII_dev18__Deal_Team__c> dealTeams =  NavatarNotesTaggingCtrl.getExistingDealTeamMembers(deals1);
    }
    
    @IsTest
    private static void testGetUserAvailableAccountRecordTypes() {
        List<NavatarNotesTaggingCtrl.RecordTypeOptionWrapper> recTypes = 
            NavatarNotesTaggingCtrl.getUserAvailableAccountRecordTypes();
        System.assertEquals(true , recTypes.size()>0);
    }
    
      
    
    @IsTest
    private static void testCreateAccountContactRecords() {
        List<NavatarNotesTaggingCtrl.QuickRequestWrapper> requestWrapper = 
            new List<NavatarNotesTaggingCtrl.QuickRequestWrapper>();
        requestWrapper.add(addAccountRequest());
        requestWrapper.addAll(addContactRequestList());
        String reqString = JSON.serialize(requestWrapper);
        NavatarNotesTaggingCtrl.ResponseWrapper createRecordResponse = 
            NavatarNotesTaggingCtrl.createAccountContactRecords(reqString);
        System.assertEquals(false, createRecordResponse.isError);
    }
    
    @IsTest
    private static void testGetRelatedContactsDetails() {
        List<String> contactIds = new List<String>();
        List<Contact> contacts = [SELECT ID From CONTACT];
        for(Contact con : contacts) {
            contactIds.add(con.Id);
        }
        List<NavatarNotesTaggingCtrl.TeamMappingWrapper> response = 
        NavatarNotesTaggingCtrl.getRelatedContactsDetails(contactIds);
        System.assertEquals(true, response.size()>0);
    }
    
    private static NavatarNotesTaggingCtrl.QuickRequestWrapper addAccountRequest() {
        NavatarNotesTaggingCtrl.QuickRequestWrapper accountRequest = 
            new NavatarNotesTaggingCtrl.QuickRequestWrapper();
        accountRequest.index = 1;
        accountRequest.name = NavatarConstants.TEST_ACCOUNT_NAME;
        accountRequest.objectType = NavatarConstants.ACCOUNT_API_NAME;
        accountRequest.accountRecType = Schema.SObjectType.Account.getRecordTypeInfosByName().get(NavatarConstants.COMPANY_REC_TYPE_NAME).getRecordTypeId();
        return accountRequest;
    }
    
    private static List<NavatarNotesTaggingCtrl.QuickRequestWrapper> addContactRequestList() {
        List<NavatarNotesTaggingCtrl.QuickRequestWrapper> contactRequests = 
            new List<NavatarNotesTaggingCtrl.QuickRequestWrapper>();
        String accId = [SELECT Id from ACCOUNT LIMIT 1].Id;
        for(Integer i= 2; i<5; i++) {
            NavatarNotesTaggingCtrl.QuickRequestWrapper request = 
                new NavatarNotesTaggingCtrl.QuickRequestWrapper();
            request.index = i;
            request.name = NavatarConstants.TEST_CONTACT_NAME+i;
            request.accountId = (i==2)?accId:'';
            request.objectType = NavatarConstants.CONTACT_API_NAME;
            request.searchAccountText = (i==3)?'':(i==4)?NavatarConstants.DUMMY_ACCOUNT_NAME:'';
            contactRequests.add(request);
        }
        return contactRequests;
    }
    public static List<Account> createTestAccounts(Integer size) {
        List<Account> accounts = new List<Account>();
        for(Integer i = 0; i< size; i++) {
            accounts.add(new Account(Name = 'TestAccount '+i));
        }
        return accounts;
    }
    
    public static List<Contact> createTestContacts(List<Account> accounts) {
        List<Contact> contacts = new List<Contact>();
        for(Account acc : accounts) {
            contacts.add(new Contact(LastName = 'testContact', AccountId = acc.Id));
        }
        return contacts;
    }

}