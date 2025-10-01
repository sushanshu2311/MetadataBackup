@isTest
public class Test_FundSelectionDrawdown
{
    public static testMethod void testFundSelectionDrawdown()
    {
        Fund__c fnd = new Fund__c(name = 'Test Fund');
        insert fnd;
        Fund_Drawdown__c fndDrdwn = new Fund_Drawdown__c(Fund_Name__c =fnd.id);
        insert fndDrdwn;
        Fund__c fnd1=[select name from Fund__c where id=:fnd.id];
        System.assertEquals('Test Fund',fnd1.name);
        ApexPages.StandardController sc = new ApexPages.StandardController(fndDrdwn);
        FundSelectionDrawdown f = new FundSelectionDrawdown(sc);
        f.evaluate();
        ApexPages.currentPage().getParameters().put('retURL','hksdfsld');
        f.evaluate();
        f.part = new Partnership__c(name='Test Part', Fund__c = fnd.id);
        insert f.part;
        ApexPages.currentPage().getParameters().put('retURL',fnd.id);
        f.evaluate();
        ApexPages.currentPage().getParameters().put('retURL',f.part.id);
        f.evaluate();
        f.redirectFun();
    }
}