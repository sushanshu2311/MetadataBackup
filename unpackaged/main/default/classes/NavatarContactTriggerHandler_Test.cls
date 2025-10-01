/**
* --------------------------------------------------------------------------------------------------
* Test class designed for NavatarContactTrigger & NavatarContactTriggerHandler.
* --------------------------------------------------------------------------------------------------
* @author         Anmol Uppal
* @modifiedBy     Anmol Uppal
* @version        1.0
* @created        2023-02-07
* @modified       2023-02-07
* @organization   Navatar Group
*/
@isTest
public class NavatarContactTriggerHandler_Test {
    @testSetup
    static void createRecords(){
        Id recTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Intermediary').getRecordTypeId();
        Account acc=new Account(name='Test Intermediary Account',recordTypeId=recTypeId);
        insert acc;
        Contact con =new Contact(navpeII_dev18__Last_Touch_Point__c=Date.today().addDays(-4),lastname='Test Contact');
        insert con;
    }
    static testmethod void testMethod1(){
        Account acc=[Select Id,Last_Touchpoint__c from Account where recordtype.developername='Intermediary' limit 1];
        Contact con =new Contact(navpeII_dev18__Last_Touch_Point__c=Date.today().addDays(-4),AccountId=acc.Id,lastname='Test Contact1');
        insert con;
        Contact con2 =new Contact(AccountId=acc.Id,lastname='Test Contact2');
        insert con2;
        con2.navpeII_dev18__Last_Touch_Point__c=Date.today().addDays(-2);
        update con2;
		Id recTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Intermediary').getRecordTypeId();
        Account acc2=new Account(name='Test Intermediary Account2',recordTypeId=recTypeId);
        insert acc2;
		con2.AccountId=acc2.Id;
		update con2;        
        delete con2;
		undelete con2;
        con2.navpeII_dev18__Last_Touch_Point__c=Date.today();
		update con2;
    }
    static testmethod void bulkTestMethod1(){
        Account acc=[Select Id,Last_Touchpoint__c from Account where recordtype.developername='Intermediary' limit 1];
        Id recTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Intermediary').getRecordTypeId();
        Account acc2=new Account(name='Test Intermediary Account2',recordTypeId=recTypeId);
        insert acc2;        
        List<Contact> conList=new List<Contact>();
        for(Integer i=0;i<10;i++){
            if(Math.mod(i,2)==0){
            Contact con =new Contact(navpeII_dev18__Last_Touch_Point__c=Date.today().addDays(-1),AccountId=acc.Id,lastname='Test Contact'+i);
            Contact con2 =new Contact(navpeII_dev18__Last_Touch_Point__c=Date.today().addDays(-4),AccountId=acc.Id,lastname='Test Contact'+i);
            Contact con3 =new Contact(navpeII_dev18__Last_Touch_Point__c=Date.today().addDays(+1),AccountId=acc.Id,lastname='Test Contact'+i);
			conList.add(con);
			conList.add(con2);
			conList.add(con3);
            }
            else{
            Contact con =new Contact(navpeII_dev18__Last_Touch_Point__c=Date.today().addDays(-1),AccountId=acc2.Id,lastname='Test Contact'+i);
            Contact con2 =new Contact(navpeII_dev18__Last_Touch_Point__c=Date.today().addDays(-4),AccountId=acc2.Id,lastname='Test Contact'+i);
            Contact con3 =new Contact(navpeII_dev18__Last_Touch_Point__c=Date.today().addDays(+1),AccountId=acc2.Id,lastname='Test Contact'+i);
			conList.add(con);
			conList.add(con2);
			conList.add(con3);
            }
        }
        insert conList;
        delete conList;
    }
}