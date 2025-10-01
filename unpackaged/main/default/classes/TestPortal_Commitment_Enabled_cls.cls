@isTest
public class TestPortal_Commitment_Enabled_cls{

    static testmethod void Cmmitment_Enabled_cls()
    {
        Account acc= new Account(name='testAccount');
        insert acc;
        System.assertEquals('testAccount', acc.Name); // (PE3.5, SK, 9Aug2017)
        
        fund__c fundObj = new Fund__c(Name='testFund',Fund_Type__c='Fund',Investment_Category__c='Co-investment');
        insert fundObj;
        System.assertEquals('testFund', fundObj.Name); // (PE3.5, SK, 9Aug2017)
        
        partnership__c partObj = new partnership__c(Name='testPartner',Fund__c=fundObj.id);
        insert partObj; 
        System.assertEquals('testPartner', partObj.Name); // (PE3.5, SK, 9Aug2017)
        
        Commitment__c com = new Commitment__c(Limited_Partner__c=acc.id, Partnership__c=partObj.id);   
    }
}