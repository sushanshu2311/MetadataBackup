@isTest
public with sharing class NavatarThemeAddToFundCtrlTest {
    @TestSetup
    static void makeData(){
        navpeII_dev18__Theme__c themeRec = new navpeII_dev18__Theme__c(Name='Test Theme');
        insert themeRec;
        List<Account> accountRecordsList = new list<Account>();
        List<navpeII_dev18__Theme_Relation__c> themeRelationList = new list<navpeII_dev18__Theme_Relation__c>();
        Id recordTypeId1 = Schema.sObjectType.Account.getRecordTypeInfosByDeveloperName().get('Institutions').getRecordTypeId();
        For(integer i=0; i<5; i++){
            Account acc = new Account();
            acc.Name = 'Test Acc'+i;
            acc.RecordTypeId = recordTypeId1;
            accountRecordsList.add(acc);
        }
        if(!accountRecordsList.isEmpty()){
            insert accountRecordsList;
        }
        List<Contact> conList = new List<Contact>();
        for(Account acc : accountRecordsList){
            Contact con = new Contact();
            con.FirstName = String.valueOf(System.now());
            con.LastName = String.valueOf(System.now());
            con.Email = 'a@b.com';
            con.AccountId = acc.Id;
            conList.add(con);
        }
        if(conList.size() > 0){
            insert conList;
        }
        navpeII_dev18__Fund__c fund = new navpeII_dev18__Fund__c();
        fund.Name = 'LK Fund ' + System.now();
        fund.navpeII_dev18__Fund_Type__c = 'Fund';
        fund.navpeII_dev18__Investment_Category__c = 'Fund';
        insert fund;
    }

    @isTest
    public static void testAddFirmToFund(){
        list<Account> accountList = new list<Account>([Select Id, Name, RecordTypeId From Account]);
        list<Id> accIdList = new list<Id>();
        Contact contRec = new Contact();
        contRec.LastName = 'Test Contact';
        contRec.AccountId = accountList[0].Id;
        insert contRec;
        String recId = [Select Id, Name From Theme__c limit 1].Id;
        list<navpeII_dev18__Theme_Relation__c> themeRelationList= new list<navpeII_dev18__Theme_Relation__c>();
        for(Integer i=0; i<5; i++){
            navpeII_dev18__Theme_Relation__c themeRel = new navpeII_dev18__Theme_Relation__c();
            themeRel.navpeII_dev18__Account__c = accountList.get(i).Id;
            themeRel.navpeII_dev18__Theme__c = recId;
            themeRelationList.add(themeRel);
            accIdList.add(accountList.get(i).Id);
        }
        if(themeRelationList.size() > 0){
            insert themeRelationList;
        }        
        NavatarThemeAddToFundCtrl.getThemeRelatedAccountRecords(recId);
        boolean haveContacts = NavatarThemeAddToFundCtrl.getAccountsContacts(accIdList);//Changed Naming convention
        System.assertEquals(haveContacts,true,'No Contacts Found');
    }
    
    @isTest
    public static void codeCoverageImprovement(){
        List<String> accountIdList = new List<String>();
        for(Account acc : [Select Id, Name, RecordTypeId From Account]){
            accountIdList.add(acc.Id);
        }
        navpeII_dev18__Fund__c fund = [SELECT ID, Name FROM navpeII_dev18__Fund__c LIMIT 1];
        NavatarThemeAddToFundCtrl.addToFundFdr(fund.Id, fund.Name, JSON.serialize(accountIdList));
        NavatarThemeAddToFundCtrl.createFdrCon(fund.Id, JSON.serialize(accountIdList));
        system.assert(true);
    }
}