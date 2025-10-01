@isTest
public class TestIndividualInvestorSetup_Ctlr
{
    static TestMethod void TestMethod1()
    {
        Navatar_Setup__c NS =  new Navatar_Setup__c();
        NS.admin_setting__c = true;
        NS.IIS__c = 'Contact:Phone,Contact:Fax,Account:Name;Account:AccountSource,Account:Fax,Account:Phone';
        insert NS;
        System.assertEquals('Contact:Phone,Contact:Fax,Account:Name;Account:AccountSource,Account:Fax,Account:Phone', NS.IIS__c); // (PE3.5, SK, 8Aug2017)
        
        IndividualInvestorSetup_Ctlr IIS = new IndividualInvestorSetup_Ctlr();
        IIS.revertToDefaultAct();
        IIS.saveIISetupAct();
    }
}