@isTest
public class TestInvestorPortal_Alertscls{

    static testMethod void InvestorPortal_Alertscls()
    {
        Account com = new Account(name='TestAccount');
        insert com;
        System.assertEquals('TestAccount', com.Name); // (PE3.5, SK, 9Aug2017)
        
        ApexPages.currentPage().getHeaders().put('Host','https\\.na15.salesforce.com');
        InvestorPortal_Alertscls comEnab = new InvestorPortal_Alertscls();   
    }
}