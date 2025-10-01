@isTest
public class NavatarThemeCallListCtrlTest {
    @TestSetup
    static void setup(){
        Theme__c theme = new Theme__c();
        theme.Name = 'Theme 1';
        insert theme;
        
        Account acc = new Account();
        acc.Name = 'Acc 1';
        insert acc;
        
        Contact con = new Contact();
        con.LastName = 'Con 1';
        con.Email = 'test@test.com';
        con.AccountId = acc.Id;
        insert con;
        
        Contact con1 = new Contact();
        con1.LastName = 'Con 1';
        con1.Email = 'test1@test.com';
        con1.AccountId = acc.Id;
        insert con1;
        
        Theme_Relation__c themeR1 = new Theme_Relation__c(Account__c = acc.Id, Theme__c = theme.Id);	insert themeR1;
        Theme_Relation__c themeR2 = new Theme_Relation__c(Contact__c = con.Id, Theme__c = theme.Id);	insert themeR2;
        Theme_Relation__c themeR3 = new Theme_Relation__c(Contact__c = con1.Id, Theme__c = theme.Id);	insert themeR3;

    }
    
    static testmethod void fetchAllContacts(){
        navpeII_dev18__Theme__c theme = [Select Id From navpeII_dev18__Theme__c Limit 1];
        NavatarThemeCallListCtrl.getThemeCallListData(theme.Id);
        NavatarThemeCallListCtrl.getFirmListData(theme.Id);
        
        Account acc1 = new Account();
        acc1.Name = 'Acc 2';
        insert acc1;
        
        Contact con = new Contact();
        con.LastName = 'Con 1';
        con.Email = 'test3@test.com';
        con.AccountId = acc1.Id;
        insert con;
        
        List<Id> sets = new List<Id>();
        sets.add([Select Id From Account Limit 1].Id);
        sets.add(acc1.Id);
        NavatarThemeCallListCtrl.importContactsToTheme(theme.Id,sets);
        
        System.assert(theme != null);
    }
}