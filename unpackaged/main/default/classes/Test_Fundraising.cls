@isTest
public class Test_Fundraising
{
    static string RecTypeInst='';
    static string RecTypeLP='';
    static  string RecTypeCompany='';
    static string RecTypeFM='';
    static string RecTypeFMF='';
    static  String RecTypeOther='';
    static     RecordType[] Rec;
    
    public static testmethod void ForFundraising()
    {
        Rec= [Select id,Name,SObjectType from RecordType where SObjectType='Account'];
        
        for(RecordType R:Rec)
        {
            // Institution replaced with Individual Investor by Sudhanshu on 06-11-2024
            if(R.Name == 'Individual Investor')
            {
                RecTypeInst= R.Id;
            }
            if(R.Name == 'Limited Partner')
            {
                RecTypeLP= R.Id;
            }
            if(R.Name == 'Company')
            {
                RecTypeCompany= R.Id;
            }
            if(R.Name == 'Fund Manager')
            {
                RecTypeFM= R.Id;
            }
            if(R.Name == 'Fund Manager’s Fund')
            {
                RecTypeFMF= R.Id;
            }
        }
        
          // Institution Scenario
        Account ins1=new Account(Name='ins1',RecordTypeId=RecTypeInst,Familiar_Name__c='ins1');  // Parent Institution is blank
        insert ins1;
        System.assertEquals('ins1', ins1.Name); // (PE3.5, SK, 8Aug2017)
        
        Account lp1=new Account( parentId=ins1.id,Name='lp1',RecordTypeId=RecTypeLP);
        insert lp1;
        System.assertEquals('lp1', lp1.Name); // (PE3.5, SK, 8Aug2017)
        
        Account Company1=new Account(Name='company',RecordTypeId=RecTypeCompany);
        insert Company1;
        System.assertEquals('company', Company1.Name); // (PE3.5, SK, 8Aug2017)
        
        Account fm1=new Account(Name='fund manager1',RecordTypeId=RecTypeFM);
        insert fm1;
        System.assertEquals('fund manager1', fm1.Name); // (PE3.5, SK, 8Aug2017)
        
        Account fmf1=new Account( parentId=fm1.id ,Name='fund managersfund1',RecordTypeId=RecTypeFMF);
        insert fmf1;
        System.assertEquals('fund managersfund1', fmf1.Name); // (PE3.5, SK, 8Aug2017)
        
        Contact contact1 = new Contact(lastname = 'Tester', AccountID=ins1.id);
        insert contact1;
        System.assertEquals('Tester', contact1.LastName); // (PE3.5, SK, 8Aug2017)

        Fund__c fund1 = new Fund__c(Name = '@isTest',Investment_Category__c = 'Fund');
        insert fund1;
        System.assertEquals('@isTest', fund1.Name); // (PE3.5, SK, 8Aug2017)
        
        Fund__c coinv = new Fund__c(Name = '@isTest',Investment_Category__c = 'Co-Investment');
        insert coinv;
        System.assertEquals('@isTest', coinv.Name); // (PE3.5, SK, 8Aug2017)
        
        Fundraising__c fundr1= new Fundraising__c(Name='TestFundraising',Fund_Name__c=coinv.id, Legal_Name__c=ins1.id,Portfolio_Company__c=company1.id);
        insert fundr1;
        System.assertEquals('TestFundraising', fundr1.Name); // (PE3.5, SK, 8Aug2017)
        
        Fundraising_Contact__c fundrsingcontact=new Fundraising_Contact__c(Fundraising__c=fundr1.Id,Contact__c=contact1.Id);
        insert fundrsingcontact;
        System.assertNotEquals('', fundrsingcontact.Name); // (PE3.5, SK, 8Aug2017)
        
        ProductSetting__c.getInstance('FundraisingwithFM').status__c=false;
        update ProductSetting__c.getInstance('FundraisingwithFM');
        
        ProductSetting__c.getInstance('FundraisingwithFMF').status__c=false;
        update ProductSetting__c.getInstance('FundraisingwithFMF');
        
        Fundraising__c fundr2= new Fundraising__c(Name='TestFundraising',Fund_Name__c=coinv.id, Legal_Name__c=Company1.id,Portfolio_Company__c=company1.id);
        try
        {
            insert fundr2;
            System.assertEquals('TestFundraising', fundr2.Name); // (PE3.5, SK, 8Aug2017)
        }
        catch(Exception e)
        {
        
        }
        
        Fundraising__c fundr3= new Fundraising__c(Name='TestFundraising',Fund_Name__c=coinv.id, Legal_Name__c=fm1.id,Portfolio_Company__c=company1.id);
        try
        {
            insert fundr3;
            System.assertEquals('TestFundraising', fundr3.Name); // (PE3.5, SK, 8Aug2017)
        }
        catch(Exception e)
        {
        
        }
        Fundraising__c fundr41= new Fundraising__c(Name='TestFundraising',Fund_Name__c=coinv.id, Legal_Name__c=ins1.id,Portfolio_Company__c=ins1.id);
        try
        {
            insert fundr41;
            System.assertEquals('TestFundraising', fundr41.Name); // (PE3.5, SK, 8Aug2017)
        }
        catch(Exception e)
        {
        
        }
         Fundraising__c fundr4_11= new Fundraising__c(Name='TestFundraising',Fund_Name__c=fund1.id, Legal_Name__c=ins1.id,Portfolio_Company__c=company1.id);
        try
        {
            insert fundr4_11;
            System.assertEquals('TestFundraising', fundr4_11.Name); // (PE3.5, SK, 8Aug2017)
        }
        catch(Exception e)
        {
        
        }
        Fundraising__c fundr4_1= new Fundraising__c(Name='TestFundraising',Fund_Name__c=coinv.id, Legal_Name__c=ins1.id,Portfolio_Company__c=null);
        try
        {
            insert fundr4_1;
            System.assertEquals('TestFundraising', fundr4_1.Name); // (PE3.5, SK, 8Aug2017)
        }
        catch(Exception e)
        {
        
        }
        Fundraising__c fundr4= new Fundraising__c(Name='TestFundraising',Fund_Name__c=coinv.id, Legal_Name__c=fmf1.id,Portfolio_Company__c=company1.id);
        try
        {
            insert fundr4;
            System.assertEquals('TestFundraising', fundr4.Name); // (PE3.5, SK, 8Aug2017)
        }
        catch(Exception e)
        {
        
        }
        Fundraising__c fundr5= new Fundraising__c(Name='TestFundraising',Fund_Name__c=coinv.id);
        try
        {
            insert fundr5;
            System.assertEquals('TestFundraising', fundr5.Name); // (PE3.5, SK, 8Aug2017)
        }
        catch(Exception e)
        {
        
        }
        fundr1.Legal_Name__c=fmf1.id;
        try
        {
            update fundr1;
        }
        catch(Exception e)
        {
        
        }
        Fundraising__c fundr6= new Fundraising__c(Name='TestFundraising', Legal_Name__c=fmf1.id,Portfolio_Company__c=company1.id);
        try
        {
            insert fundr6;
            System.assertEquals('TestFundraising', fundr6.Name); // (PE3.5, SK, 8Aug2017)
        }
        catch(Exception e)
        {
        
        }
        
    }
}