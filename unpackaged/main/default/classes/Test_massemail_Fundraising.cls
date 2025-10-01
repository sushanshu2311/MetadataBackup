/*  New Implimentation:
        Developer               :  Bvenkat Jeewesh
        Product Version         :   PE V3.0
        date of Creation        :   18/05/2015
        Purpose of Creation     :   Custom Controller For massemailFundraising Page
                                    Code Coverage for massemailFundraising Class
        */
@isTest(SeeAllData=true)
public class Test_massemail_Fundraising
{   
    static testMethod void testMethod1()
    {
            Account objacc=new Account();
            objacc.Name='test account';
            insert objacc;
            System.assertEquals('test account', objacc.Name); // (PE3.5, SK, 9Aug2017)
            
            Fund__c fundObj = new Fund__c(Name='testFund',Fund_Type__c='Fund');
            insert fundObj;  
            System.assertEquals('testFund', fundObj.Name); // (PE3.5, SK, 9Aug2017)   
            
            /*Office_Location__c objoff=new Office_Location__c();
            objoff.Name='test name';
            objoff.Organization_Name__c=objacc.id;
            objoff.City__c='test office city';
            objoff.State__c='test office staet';
            objoff.Country__c='test office country';
            objoff.Street__c='test office strewe';
            objoff.ZIP__c='test office staet';
            
            insert objoff;*/
            
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
            //con.Office_Location__c=objoff.id;
            insert con;
            System.assertEquals('Test last Contact', con.LastName); // (PE3.5, SK, 9Aug2017)   
           
            Schema.DescribeSObjectResult cfrSchema = Schema.SObjectType.Account; 
            Map<String,Schema.RecordTypeInfo> AccountRecordTypeInfo = cfrSchema.getRecordTypeInfosByName(); 
            
            Account acc = new Account(Name='test Account',recordtypeid=AccountRecordTypeInfo.get('Company').getRecordTypeId());
            insert acc;
            System.assertEquals('test Account', acc.Name); // (PE3.5, SK, 9Aug2017)   
            
           // Account Acc_comp1 = new Account(Name='test',recordtypeid=AccountRecordTypeInfo.get('Company').getRecordTypeId());
           // insert Acc_comp1;
        	// Institution replaced with Individual Investor by Sudhanshu on 06-11-2024
            Account Acc_inst = new Account(Name='test1',recordtypeid=AccountRecordTypeInfo.get('Individual Investor').getRecordTypeId());
            insert Acc_inst;
            System.assertEquals('test1', Acc_inst.Name); // (PE3.5, SK, 9Aug2017)   
           
            
            Fundraising__c objFR = new Fundraising__c(Name= 'Test Fundraising',Portfolio_Company__c=acc.id,Fund_Name__c=fundObj.id,Legal_Name__c=Acc_inst.id);      
            insert objFR;   
            System.assertEquals('Test Fundraising', objFR.Name); // (PE3.5, SK, 9Aug2017)
            
            Fundraising_Contact__c FC=new   Fundraising_Contact__c();
            FC.Contact__c=con.id;
            FC.Fundraising__c=objFR.id;   
            insert FC;
            System.assertNotEquals('Test last Contact', FC.Name); // (PE3.5, SK, 9Aug2017)   
            
            list<Fundraising__c> lstfr=new list<Fundraising__c>(); 
            lstfr.add(objFR);        
            
            Test.startTest();
            Apexpages.currentPage().getHeaders().put('USER-AGENT','MSIE');
            Apexpages.currentPage().getParameters().put('Fid',fundObj.id);
            Apexpages.currentPage().getParameters().put('Lid',Acc_inst.id);   
            //Apexpages.currentPage().getParameters().put('Fid',fundObj.id);
           // Apexpages.currentPage().getParameters().put('Lid','a0L36000004FOtd');           
        
            massemailFundraising objMEF = new massemailFundraising(new ApexPages.StandardSetController(lstfr));
        
        objMEF.cancel();
        objMEF.ETData();
        objMEF.getItems();
      
       // Apexpages.currentPage().getParameters().put('selectConIdFundrasingId','01p360000df8MIR@@01p360000df8MIR,01p360000df8MIR@@01p360000df8MIR');
        objMEF.selectConIdFundrasingId=con.id+'@@'+objFR.id+'@@'+FC.Id;
        integer Sendmailcount = 0;
        objMEF.bCC_Me_On_One= true;
        objMEF.use_My_Signature= true;
        objMEF.chkStoreActivity= true;
        objMEF.count=0;
        objMEF.sendmassmail();
        objMEF.bCC_Me_On_One= false;
        objMEF.sendmassmail();
        MassEmailFundraising.GetEmailLimit();
        Apexpages.currentPage().getParameters().put('Fid',null);
        Apexpages.currentPage().getParameters().put('Lid','a0L36000004FOtd');
        massemailFundraising objMEF1 = new massemailFundraising(new ApexPages.StandardSetController(lstfr));
        objMEF1.cancel();
        Test.stopTest();
    }
    
    
}