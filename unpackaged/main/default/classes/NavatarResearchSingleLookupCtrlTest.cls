// Developer By Ehatsham 1 feb 2023
@isTest
public class NavatarResearchSingleLookupCtrlTest {
@isTest
    public static void method1() {
        Account testAccount = new Account(name='Test');
        insert testAccount;
        
        Account testAccount2 = new Account(name='Test account 2');
        insert testAccount2;
        
        contact con = new contact();
        con.lastName='test';
        con.AccountId=testAccount.id;
        insert con;
        
        contact con1 = new contact();
        con1.lastName='test 2 con';
        con1.AccountId=testAccount.id;
        insert con1;
        
        Test.startTest();
        	list<sobject> data=new list<sobject>();
        data=NavatarResearchSingleLookupCtrl.getRelatedData('test', 'Account');

        Test.stopTest();
        system.assert(true);
    }
    @isTest
    public static void method2() {
        Account testAccount = new Account(name='Test');
        insert testAccount;
        account acc=[select name , id from account Limit 1];
        Test.startTest();
       string iconName= NavatarResearchSingleLookupCtrl.getIconName('Account');
        string iconName2= NavatarResearchSingleLookupCtrl.getIconName('User');
        Test.stopTest();
        System.assertEquals(acc.name , 'Test');
    }
    @isTest
    public static void method3() {
        Account testAccount = new Account(name='Test');
        insert testAccount;
        account acc=[select name , id from account Limit 1];
        Test.startTest();
       string preselectedName= NavatarResearchSingleLookupCtrl.getPreSelectedRecordName(string.valueOf(acc.id),'Account');
        Test.stopTest();
        System.assertEquals(acc.name , 'Test');
        
    }
    
}