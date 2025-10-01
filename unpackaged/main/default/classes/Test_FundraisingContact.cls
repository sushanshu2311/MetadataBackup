@isTest
public class Test_FundraisingContact
{
    static string RecTypeInst='';
    static string RecTypeLP='';
    static  string RecTypeCompany='';
    static string RecTypeFM='';
    static string RecTypeFMF='';
   // static  String RecTypeOther='';
    static  RecordType[] Rec;
    public static testmethod void ForFundContact()
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
            if(R.Name == 'Test')
            {
           // RecTypeOther= R.Id;
            }
        }
        
        Account inst = new Account(RecordTypeId = RecTypeInst,Familiar_Name__c='@isTest1',Name='@isTest1');
        insert inst;
        Account inst2 = new Account(RecordTypeId = RecTypeInst,Familiar_Name__c='@isTest2',Name='@isTest2');
        insert inst2;
        Account limpart = new Account(RecordTypeId = RecTypeLP,Name='@isTest',ParentId = inst.Id);
        insert limpart;
        Account com = new Account(RecordTypeId = RecTypeCompany,Name='@isTest', HasPipeline__c = false);
        insert com;
               
        Account fm1=new Account(Name='fund manager1',RecordTypeId=RecTypeFM);
        insert fm1;
        Account fmf1=new Account( parentId=fm1.id ,Name='fund managersfund1',RecordTypeId=RecTypeFMF);
        insert fmf1;
        
    //    Account test1 = new Account(RecordTypeId = RecTypeOther,Name='@isTest');
     //   insert test1;
        
        
        Contact concre = new Contact(LastName = 'Manjot@isTest' ,AccountId = inst.Id);
        insert concre;
        System.assert(concre.Id != null);
        Contact concre2 = new Contact(LastName = 'Manjot@isTest' ,AccountId = limpart.Id);
        insert concre2;
               
            
        Contact con1 = new Contact(LastName = 'Shruti@isTest' ,AccountId = com.Id);
        insert con1;
        try
        {
            delete com;
        }
        catch(Exception e)
        {
            System.assert(ApexPages.hasMessages()==True);
        }

        Contact con2 = new Contact(LastName = 'Shruti@isTest' ,AccountId = fm1.Id);
        try
        {
            insert con2;
        }
        catch(Exception e)
        {
            System.assert(con2.Id == null);
        }
        
        
        
        Fund__c fund = new Fund__c(Name = '@isTest',Investment_Category__c = 'Fund');
        insert fund;
        
        Fund__c coinv = new Fund__c(Name = '@isTest',Investment_Category__c = 'Co-Investment');
        insert coinv;
        
        
        
        
        Fundraising__c fd1 = new Fundraising__c(Name = '@isTest',Fund_Name__c = fund.Id,Legal_Name__c = inst.Id);      
        insert fd1;
        System.assert(fd1.Id!=null);
        Fundraising__c fd2 = new Fundraising__c(Name = '@isTest',Fund_Name__c = coinv.Id,Legal_Name__c = limpart.Id);
        try
        {
            insert fd2;
        }
         catch(Exception e)
        {
            System.assert(ApexPages.hasMessages()==True);
        }
        Fundraising__c fd3 = new Fundraising__c(Name = '@isTest',Fund_Name__c = fund.Id,Legal_Name__c = fm1.Id);
        try
        {
            insert fd3;
        }
         catch(Exception e)
        {
            System.assert(ApexPages.hasMessages()==True);
        }
        
        
        
        Fundraising_Contact__c fc = new Fundraising_Contact__c(Fundraising__c = fd1.Id, Contact__c = concre.Id, isPrimary__c=true);
        insert fc;
        
        // Added by Amit
        Fundraising_Contact__c fcX = new Fundraising_Contact__c(Fundraising__c = fd1.Id, Contact__c = concre2.Id, isPrimary__c=true);
        insert fcX;
        System.assert(fcX.Id!=null);
        delete fcX;
        
        fc.Institution__c = inst2.Id;
        try
        {
            update fc;
        }
         catch(Exception e)
        {
            System.assert(ApexPages.hasMessages()==True);
        }

        fd1.Legal_Name__c = inst2.Id;
        fd1.Portfolio_Company__c = null;
         try
        {
            insert fd1;
        }
         catch(Exception e)
        {
            System.assert(ApexPages.hasMessages()==True);
        }
        fd1.Portfolio_Company__c = limpart.Id;
         try
        {
            insert fd1;
        }
         catch(Exception e)
        {
            System.assert(ApexPages.hasMessages()==True);
        }
        fd1.Portfolio_Company__c = inst.Id;
         try
        {
            insert fd1;
        }
         catch(Exception e)
        {
            System.assert(ApexPages.hasMessages()==True);
        }
        concre.AccountId = inst2.Id;
        try
        {
            update concre;
        }
         catch(Exception e)
        {
           System.assert(ApexPages.hasMessages()==True);
        }
        
        Fundraising_Contact__c fc2 = new Fundraising_Contact__c(Fundraising__c = fd1.Id,Contact__c = concre.Id);
         try
        {
            insert fc2;
        }
         catch(Exception e)
        {

            System.assert(ApexPages.hasMessages()==True);
        }
        try
        {
            delete fc;
        }
         catch(Exception e)
        {
            System.assert(ApexPages.hasMessages()==True);
        }
        Advisor__c ad1 = new Advisor__c(Advisor__c = inst.Id ,client__c =inst2.Id,Role__c = 'Advisor',Fundraising__c = fd2.Id);
        insert ad1;
        
       
        Advisor__c ad5 = new Advisor__c(Advisor__c = inst.Id ,client__c =inst2.Id,Role__c = 'Advisor' );
        try
        {
            insert ad5;
        }
         catch(Exception e)
        {
            System.assert(ApexPages.hasMessages()==True);
        }
        Advisor__c ad2 = new Advisor__c(Advisor__c = inst.Id ,client__c =inst.Id,Role__c = 'Advisor');
        try
        {
            insert ad2;
        }
         catch(Exception e)
        {
            System.assert(ApexPages.hasMessages()==True);
        }
        Advisor__c ad3 = new Advisor__c(Advisor__c = inst.Id ,client__c =limpart.Id,Role__c = 'Advisor' );
        try
        {
            insert ad3;
        }
         catch(Exception e)
        {
            System.assert(ApexPages.hasMessages()==True);
        }
        Advisor__c ad4 = new Advisor__c(Advisor__c = com.Id ,client__c =com.Id,Role__c = 'Advisor' );
        try
        {
            insert ad4;
        }
         catch(Exception e)
        {
            System.assert(ApexPages.hasMessages()==True);
        }
        ad1.advisor__c = inst2.Id;
        ad1.Client__c = inst.Id;
        ad1.Fundraising__c = fd1.Id;
        try
        {
            update ad1;
        }
         catch(Exception e)
        {
             System.assert(ApexPages.hasMessages()==True);
        }
    }
}