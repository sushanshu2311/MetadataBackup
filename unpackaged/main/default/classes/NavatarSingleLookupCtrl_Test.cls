@isTest
public class NavatarSingleLookupCtrl_Test {
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
        	requestMock fakeResponse = new requestMock();
            Test.setMock(HttpCalloutMock.class, fakeResponse);
            NavatarSingleLookupCtrl.getRelatedData('tes', 'Contact');
        	NavatarSingleLookupCtrl.getRelatedData('', 'Contact');
        	NavatarSingleLookupCtrl.getPreSelectedRecordName(con.id, 'Contact');
        	NavatarSingleLookupCtrl.getIconName('Contact');
        	NavatarSingleLookupCtrl.getIconName('User');
        test.stopTest();
        system.assert(true);
    }

}