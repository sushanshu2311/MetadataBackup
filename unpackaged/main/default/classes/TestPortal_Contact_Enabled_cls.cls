@isTest
public class TestPortal_Contact_Enabled_cls
{

    static testmethod void Portal_Contact_Enabled_cls()
    {
        Account acc = new Account(name='TestAccount');
        insert acc;
        System.assertEquals('TestAccount', acc.Name); // (PE3.5, SK, 9Aug2017)
        
        Contact com = new Contact(Accountid=acc.id,email='A@b.com',lastname='testcontact');
        insert com;
        System.assertEquals('testcontact', com.LastName); // (PE3.5, SK, 9Aug2017)
        
        ApexPages.currentPage().getHeaders().put('Host','https\\.na15.salesforce.com');
        ApexPages.StandardController controller =   new ApexPages.StandardController(com);
        Investor_Portal_Contact_Enabled_cls comEnab = new Investor_Portal_Contact_Enabled_cls( controller);
    }
}