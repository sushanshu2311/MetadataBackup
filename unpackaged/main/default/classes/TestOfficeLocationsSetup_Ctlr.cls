@isTest
public class TestOfficeLocationsSetup_Ctlr
{
    static TestMethod void TestMethod1()
    {
        OfficeLocationsSetup_Ctlr OLS = new OfficeLocationsSetup_Ctlr();
        OLS.strEnableCMTSetup = true;
        OLS.editOffLocSetup();
        OLS.accLayouts = new List< String >();
        OLS.accLayouts.add('Account-Company');
        OLS.conLayouts = new List< String >();
        OLS.conLayouts.add('Contact-contact layout');
        OLS.onSaveOffLocSetup();
        OLS.strEnableCMTSetup = false;
        OLS.onSaveOffLocSetup();
        OLS.strPageName='test';
        OLS.redirectpage();
        
        System.assertEquals('test', OLS.strPageName); // (PE3.5, SK, 9Aug2017)
    }
}