@isTest
public with sharing class NavatarCreateMenuContactCtrlTest {

     @testSetup 
    static void setup(){
        Id devRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Advisor').getRecordTypeId();
        Account acc = new Account();
        acc.RecordTypeId = devRecordTypeId;
        acc.Name = 'Test Class';
        insert acc;
    }
    
    @isTest
    public static void insertContactRecordTest(){
       Test.startTest();
       List<Account> acc = [Select Id,Name from Account limit 1];
       String record = '{"lastName": "Test Contact","firstName":"contactTest","email":"navatar@gmail.com"}';
       Contact conTest = NavatarCreateMenuContactCtrl.insertContactRecord(acc[0].Id,acc[0].Name,record);
       NavatarCreateMenuContactCtrl.getMetaDataFields();
       Test.stopTest(); 
       system.assert(conTest != null); 
    }
    
    @isTest
    public static void insertContactRecordTest1(){
       Test.startTest();
       String record = '{"lastName": "Test Contact","firstName":"contactTest","email":"navatar@gmail.com"}';
       Contact conTest = NavatarCreateMenuContactCtrl.insertContactRecord('','',record);
       NavatarCreateMenuContactCtrl.getMetaDataFields();
       Test.stopTest(); 
       system.assert(conTest.AccountId != null); 
    }
}