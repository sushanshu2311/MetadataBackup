@isTest
public class TestPortal_Institution_Enabled_cls
{

    static testMethod void Portal_Institution_Enabled_cls()
    {
        Account com = new Account(name='TestAccount');
        insert com;
        System.assertEquals('TestAccount', com.Name); // (PE3.5, SK, 9Aug2017)
        
        ApexPages.currentPage().getHeaders().put('Host','https\\.na15.salesforce.com');
        ApexPages.StandardController controller =   new ApexPages.StandardController(com);
        
        Investor_Portal_Institution_Enabled_cls comEnab = new Investor_Portal_Institution_Enabled_cls( controller);
        comEnab.IFrameURL= 'abc';
        comEnab.SERVER_URL = 'def';
        comEnab.url = 'efg';
        
        System.assertEquals('abc', comEnab.IFrameURL); // (PE3.5, SK, 9Aug2017)
        System.assertEquals('def', comEnab.SERVER_URL); // (PE3.5, SK, 9Aug2017)
        System.assertEquals('efg', comEnab.url); // (PE3.5, SK, 9Aug2017)
        
    }

}