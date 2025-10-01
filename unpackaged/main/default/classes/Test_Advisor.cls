@isTest
public class Test_Advisor
{
    static string RecTypeInst='';
    static string RecTypeLP='';
    static  string RecTypeCompany='';
    static string RecTypeFM='';
    static string RecTypeFMF='';
   // static  String RecTypeOther='';
    static  RecordType[] Rec;
    public static testmethod void ForAdvisor()
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
              //  RecTypeOther= R.Id;
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
        
      //  Account test1 = new Account(RecordTypeId = RecTypeOther,Name='@isTest');
       // insert test1;
               
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
               
        Advisor__c ad1 = new Advisor__c(Advisor__c = inst.Id ,client__c =inst2.Id,Role__c = 'Advisor');
        insert ad1;
        
        ad1.Role__c='Legal';
        try
        {
            update ad1;
        }
        catch(Exception e)
        {
            System.assert(ApexPages.hasMessages()==True);
        }
        
        Advisor__c ad10 = new Advisor__c(Advisor__c = inst.Id ,client__c =inst2.Id,Role__c = 'Advisor');
       try
        {
            insert ad10;
        }
        catch(Exception e)
        {
            System.assert(ApexPages.hasMessages()==True);
        }
        
         Advisor__c ad11 = new Advisor__c(Advisor__c = inst.Id ,client__c =inst2.Id,Role__c = 'Advisor',Fundraising__c = fd1.Id);
        insert ad11;
        
        ad11.advisor__c = inst2.Id;
        try
        {
            update ad11;
        }
        catch(Exception e)
        {
            System.assert(ApexPages.hasMessages()==True);
        }
        
        Advisor__c ad6 = new Advisor__c(Advisor__c = inst.Id ,client__c =inst2.Id,Role__c = 'Advisor',Fundraising__c = fd2.Id);
        try
        {
            insert ad6;
        }
        catch(Exception e)
        {
            System.assert(ApexPages.hasMessages()==True);
        }
        
       // Advisor__c ad8 = new Advisor__c(Advisor__c = inst.Id ,client__c =test1.Id,Role__c = 'Advisor',Fundraising__c = fd2.Id);
        try
        {
          //  insert ad8;
        }
        catch(Exception e)
        {
          //  System.assert(ApexPages.hasMessages()==True);
        }
        
//Advisor__c ad9 = new Advisor__c(Advisor__c = test1.Id ,client__c =inst.Id,Role__c = 'Advisor',Fundraising__c = fd2.Id);
        try
        {
         //   insert ad9;
        }
        catch(Exception e)
        {
          //  System.assert(ApexPages.hasMessages()==True);
        }
               
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
        Advisor__c ad4 = new Advisor__c(Advisor__c = com.Id ,client__c =inst.Id,Role__c = 'Advisor' );
        try
        {
            insert ad4;
        }
         catch(Exception e)
        {
            System.assert(ApexPages.hasMessages()==True);
        }
        ad11.advisor__c = inst2.Id;
        ad11.Client__c = inst.Id;
        ad11.Fundraising__c = fd1.Id;
        try
        {
            update ad1;
        }
         catch(Exception e)
        {
             System.assert(ApexPages.hasMessages()==True);
        }
        
        ad4.advisor__c = inst2.Id;
        try
        {
            update ad4;
        }
         catch(Exception e)
        {
             System.assert(ApexPages.hasMessages()==True);
        }
        
        ad3.Client__c = com.Id;
        try
        {
            update ad3;
        }
         catch(Exception e)
        {
             System.assert(ApexPages.hasMessages()==True);
        }
        
        ad3.Fundraising__c = fd1.Id;
        try
        {
            update ad3;
        }
         catch(Exception e)
        {
             System.assert(ApexPages.hasMessages()==True);
        }
    }
}