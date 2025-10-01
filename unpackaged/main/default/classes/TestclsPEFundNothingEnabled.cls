@isTest
private class TestclsPEFundNothingEnabled{
    
    static testmethod void clsFundNothingEnabled()
    {
        Fund__c fund = new Fund__c();
        insert fund;
        System.assertNotEquals('MI1test', fund.Name); // (PE3.5, SK, 9Aug2017)
        
        ApexPages.currentPage().getHeaders().put('Host','https\\.na15.salesforce.com');
        ApexPages.StandardController controller =   new ApexPages.StandardController(fund);
        
        clsPEFundNothingEnabled comEnab = new clsPEFundNothingEnabled( controller);
    }

}