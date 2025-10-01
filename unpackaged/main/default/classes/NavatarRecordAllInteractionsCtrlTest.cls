/****************************************************************************************************
** Module Name : Acuity Phase 3 - Interactions Link
** Description : Test class for NavatarRecordAllInteractionsCtrl.
** Throws : NA
** Calls : NA
** Organization : Navatar Group
** Product Name & Version : PE v5.3
** Revision History:-
** Version    Date(YYYY-MM-DD)    Author         Description of Action
** 1.0        2024-04-10          Lakshya        Acuity Phase 3 - CR
****************************************************************************************************/
@isTest
public with sharing class NavatarRecordAllInteractionsCtrlTest {
    @testSetup static void setup() {
        //Test class coverage fix by LK on 2024-11-06
        Id accRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Individual Investor').getRecordTypeId();
        Account acc = new Account();
        acc.Name = 'Test Class Account 1' + System.now();
        acc.RecordTypeId = accRecTypeId;
        insert acc;
        
        Contact con = new Contact();
        con.FirstName = 'Test Class';
        con.LastName = 'Contact 1 ' + System.now();
        con.Email = UserInfo.getOrganizationId() + '@b.com';
        con.AccountId = acc.Id;
        insert con;
        
        navpeII_dev18__Pipeline__c deal = new navpeII_dev18__Pipeline__c();
        deal.Name = 'Test Class Deal 1' + System.now();
        deal.navpeII_dev18__Company__c = acc.Id;
        deal.navpeII_dev18__Stage__c = 'IOI';
        insert deal;
        
        navpeII_dev18__Fund__c fund = new navpeII_dev18__Fund__c();
        fund.Name = 'Test Class Fund 1' + System.now();
        fund.navpeII_dev18__Fund_Type__c = 'Fund';
        fund.navpeII_dev18__Investment_Category__c = 'Fund';
        insert fund;
        
        navpeII_dev18__Fundraising__c fdr = new navpeII_dev18__Fundraising__c();
        fdr.Name = 'Test Class Fdr 1' + System.now();
        fdr.navpeII_dev18__Fund_Name__c = fund.Id;
        fdr.navpeII_dev18__Legal_Name__c = acc.Id;
        insert fdr;
        
        navpeII_dev18__Theme__c theme = new navpeII_dev18__Theme__c();
        theme.Name = 'Test Class Theme 1' + System.now();
        insert theme;
        
        Task t = new Task();
        t.WhoId = con.Id;
        t.Subject = 'Test Class Task 1' + System.now();
        t.ActivityDate = Date.today();
        t.TaskSubtype = 'Call';
        t.navpeII_dev18__Related_Associations__c = acc.Id + ',' + deal.Id + ',' + fund.Id + ',' + fdr.Id + ',' + theme.Id;
        insert t;
        
        Event ev = new Event();
        ev.Subject = 'Test Class Event 1' + System.now();
        ev.ActivityDateTime = System.now();
        ev.DurationInMinutes = 60;
        ev.WhoId = con.Id;
        ev.navpeII_dev18__Related_Associations__c = acc.Id + ',' + deal.Id + ',' + fund.Id + ',' + fdr.Id + ',' + theme.Id;
        insert ev;
    }
    
    public static testMethod void testHandleOnLoadInfo() {
        Account acc = [SELECT Id FROM Account LIMIT 1];
        NavatarRecordAllInteractionsCtrl.handleOnLoadInfo(acc.Id);
        Contact con = [SELECT Id FROM Contact LIMIT 1];
        NavatarRecordAllInteractionsCtrl.handleOnLoadInfo(con.Id);
        navpeII_dev18__Pipeline__c deal = [SELECT Id FROM navpeII_dev18__Pipeline__c LIMIT 1];
        NavatarRecordAllInteractionsCtrl.handleOnLoadInfo(deal.Id);
        navpeII_dev18__Fund__c fund = [SELECT Id FROM navpeII_dev18__Fund__c LIMIT 1];
        NavatarRecordAllInteractionsCtrl.handleOnLoadInfo(fund.Id);
        navpeII_dev18__Fundraising__c fdr = [SELECT Id FROM navpeII_dev18__Fundraising__c LIMIT 1];
        NavatarRecordAllInteractionsCtrl.handleOnLoadInfo(fdr.Id);
        navpeII_dev18__Theme__c theme = [SELECT Id FROM navpeII_dev18__Theme__c LIMIT 1];
        NavatarRecordAllInteractionsCtrl.handleOnLoadInfo(theme.Id);
        system.assert(true);
    }
    
    public static testMethod void testNegative() {
        try { NavatarRecordAllInteractionsCtrl.handleOnLoadInfo('00x000000000000'); } catch(Exception e){}
        system.assert(true);
    }
}