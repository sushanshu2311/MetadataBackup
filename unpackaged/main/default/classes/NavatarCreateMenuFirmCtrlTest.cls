@isTest
public class NavatarCreateMenuFirmCtrlTest {

    @testSetup 
    static void setup(){
        Id devRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Advisor').getRecordTypeId();
        Account acc = new Account();
        acc.RecordTypeId = devRecordTypeId;
        acc.Name = 'Test Class';
        insert acc;

    }
    
    @isTest
    public static void createFirmRecordTest(){
        Test.startTest();
        List<Account> acc = [Select Id,Name,RecordTypeId from Account];
        Account acc1 = NavatarCreateMenuFirmCtrl.insertRecord(acc[0].RecordTypeId,acc[0].Name);
      //  NavatarCreateMenuFirmCtrl.getUserAvailableAccountRecordTypes();
        NavatarCreateMenuFirmCtrl.getResponceData();
        Test.stopTest();
        system.assertEquals(acc1.RecordTypeId, acc[0].RecordTypeId);
        
    }
}