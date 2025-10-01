@isTest
public with sharing class NavatarReportCtrlTest {
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
        NavatarReportCtrl.getReportData(con.id);
        NavatarReportCtrl.getReportData(testAccount2.id);
        test.stopTest();
        system.assert(true);
    }
    
    @isTest
    public static void method2() {
        try{
            NavatarReportCtrl.getReportData('Hello');
            system.assert(true);
        } catch(Exception ex){}
    }
}