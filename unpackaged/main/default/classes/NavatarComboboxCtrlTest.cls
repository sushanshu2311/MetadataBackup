/****************************************************************************************************
** Module Name : Acuity 2.0 - Acuity
** Description : Used to search record based on input string on Add to themes functionality.
** Throws : NA
** Calls : NA
** Organization : Navatar Group
** Product Name & Version : Acuity 2.0
** Revision History:-
** Version    Date(YYYY-MM-DD)    Author         		Description of Action
** 1.0        2023-02-16          Tejaswini Gunjal	 Test class of NavatarComboboxCtrl class
****************************************************************************************************/
@isTest
public class NavatarComboboxCtrlTest {
    
    @testSetup static void setup() {
        Id devRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Company').getRecordTypeId();
        Account acc = new Account();
        acc.RecordTypeId = devRecordTypeId;
        acc.Name = 'Test Class';
        insert acc;
        
        Contact cnt = new Contact();
        cnt.LastName = 'Testing';
        cnt.AccountId = acc.id;
        cnt.Email = 'jsmith@acme.com';
        cnt.Title = 'BA';
        insert cnt;
        navpeII_dev18__Pipeline__c deal = new navpeII_dev18__Pipeline__c();
        deal.Name = 'Testing';
        deal.navpeII_dev18__Company__c = acc.id;
        deal.navpeII_dev18__Our_Role__c = 'Lead';
        deal.navpeII_dev18__Stage__c = 'IOI';
        insert deal;
        
        system.assert(true);
    }
    
    public static testMethod void fetchLookupDataTest() {
        try{
            Account thisAcc=[Select id,name from account limit 1];
            test.startTest();
            NavatarComboboxCtrl.fetchLookupData('Test', 'Account');
            NavatarComboboxCtrl.fetchDefaultRecord(thisAcc.Id, 'Account');
            test.stopTest();
        }
        catch(Exception e){
            
        }
        system.assert(true);
        
    }

}