@isTest
public class TestIndividualInvestorCreation_Ctlr
{
    static TestMethod void TestMethod1()
    {
        Navatar_Setup__c NS =  new Navatar_Setup__c();
        NS.admin_setting__c = true;
        NS.IIS__c = 'Contact:Phone,Contact:Fax,Account:Name;Account:AccountSource,Account:Fax,Account:Phone';
        insert NS;
        System.assertEquals('Contact:Phone,Contact:Fax,Account:Name;Account:AccountSource,Account:Fax,Account:Phone', NS.IIS__c); // (PE3.5, SK, 8Aug2017)
        
        IndividualInvestorCreation_Ctlr ICC = new IndividualInvestorCreation_Ctlr();
        System.currentPageReference().getParameters().put('retURL', 'lightning/page/home');
        ICC.strRequiredField = 'Contact:Phone,Account:Name;Account:AccountSource,Account:Fax';
        System.assertEquals('Contact:Phone,Account:Name;Account:AccountSource,Account:Fax', ICC.strRequiredField); // (PE3.5, SK, 8Aug2017)
        
        ICC.viewRequiredFieldonPage();
        ICC.createIndividualInvestorAct();
        ICC.cancelAct();
        ICC.createIndividualInvestorFinalAct();
        //ICC.objectField();
        IndividualInvestorCreation_Ctlr.getRecorTypeid('Account');
        IndividualInvestorCreation_Ctlr.getRecorTypeid('Contact');
    }
}