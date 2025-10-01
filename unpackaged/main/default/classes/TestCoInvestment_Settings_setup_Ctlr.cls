@isTest
public class TestCoInvestment_Settings_setup_Ctlr
{
    @isTest(onInstall=True)
    static void testCoinvestSetup()
    {
        Fund__c fObj = new Fund__c();
        fObj.name = 'TestClassFund';
        insert fObj;
        System.assertEquals('TestClassFund', fObj.Name); // (PE3.5, SK, 9Aug2017)
        
        Navatar_Setup__c NS =  new Navatar_Setup__c();
        NS.admin_setting__c = true;
        NS.IIS__c = 'Contact:Phone,Contact:Fax,Account:Name;Account:AccountSource,Account:Fax,Account:Phone';
        NS.CI_Fund_ID__c = fObj.id;
        insert NS;
        System.assertNotEquals('MI1 test', NS.Name); // (PE3.5, SK, 9Aug2017)
        
        CoInvestment_Settings_setup_Ctlr CSS = new CoInvestment_Settings_setup_Ctlr();
        CSS.editConInvestmentSetup();
        CSS.onSaveCoInvestmentSetup();
    }
}