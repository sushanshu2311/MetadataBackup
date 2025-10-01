@isTest
private class Test_SetPrimaryContactCTRL
{
    public static testMethod void method1()
    {
        Account objacc=new Account();
        objacc.Name='test account';
        insert objacc;
        System.assertEquals('test account', objacc.Name); 
        
        Fund__c fundObj = new Fund__c(Name='testFund',Fund_Type__c='Fund');
        insert fundObj;  
        System.assertEquals('testFund', fundObj.Name); // (PE3.5, SK, 9Aug2017)   
        
        
        contact con = new contact();
        con.lastName = 'Test last Contact'; 
        con.firstname = 'Test First Name'; 
        con.HasOptedOutOfEmail=false;  
        con.MailingCity ='Test City'; 
        con.MailingCountry='Test country';  
        con.MailingPostalCode = '102010';
        con.MailingState = 'Test State';
        con.MailingStreet='Test street';
        con.Description='test hello how are you';
        con.Fax='012423';
        con.Phone = '01245263';
        con.otherCity = 'test other city';
        con.otherCountry='Test other country';  
        con.otherPostalCode = '1020101';
        con.otherState = 'Test other State';
        con.otherStreet='Test other street'; 
        con.accountid=objacc.id;
        insert con;
        System.assertEquals('Test last Contact', con.LastName);
        
        
        Schema.DescribeSObjectResult cfrSchema = Schema.SObjectType.Account; 
        Map<String,Schema.RecordTypeInfo> AccountRecordTypeInfo = cfrSchema.getRecordTypeInfosByName(); 
        
        Account acc = new Account(Name='test Account',recordtypeid=AccountRecordTypeInfo.get('Company').getRecordTypeId());
        insert acc;
        System.assertEquals('test Account', acc.Name); 
        
        // Institution replaced with Individual Investor by Sudhanshu on 06-11-2024
        Account Acc_inst = new Account(Name='test1',recordtypeid=AccountRecordTypeInfo.get('Individual Investor').getRecordTypeId());
        insert Acc_inst;
        System.assertEquals('test1', Acc_inst.Name); 
        
        
        Fundraising__c objFR = new Fundraising__c(Name= 'Test Fundraising',Portfolio_Company__c=acc.id,Fund_Name__c=fundObj.id,Legal_Name__c=Acc_inst.id);      
        insert objFR;   
        System.assertEquals('Test Fundraising', objFR.Name); 
        
        Fundraising_Contact__c FC=new   Fundraising_Contact__c();
        FC.Contact__c=con.id;
        FC.Fundraising__c=objFR.id;   
        insert FC;
        System.assertNotEquals('Test last Contact', FC.Name); 
        
        list<Fundraising_Contact__c > lstfr = new list<Fundraising_Contact__c >(); 
        lstfr.add(FC);
        
        Apexpages.currentPage().getParameters().put('id', objFR.id);
        SetPrimaryContactCTRL objMEF = new SetPrimaryContactCTRL(new ApexPages.StandardSetController(lstfr));
        
        ApexPages.StandardController sc = new ApexPages.StandardController(FC);
        SetPrimaryContactCTRL testAccPlan = new SetPrimaryContactCTRL(sc);
    }
    
}