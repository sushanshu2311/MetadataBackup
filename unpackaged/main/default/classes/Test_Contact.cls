@isTest
public class Test_Contact
{
    static string RecTypeInst='';
    static string RecTypeLP='';
    static  string RecTypeCompany='';
    static string RecTypeFM='';
    static string RecTypeFMF='';
  //  static  String RecTypeOther='';
    static  RecordType[] Rec;
    public static testmethod void ForContact()
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
          Fund__c coinv = new Fund__c(Name = '@isTest',Investment_Category__c = 'Co-Investment');
        insert coinv;
        
        Account fm1=new Account(Name='fund manager1',RecordTypeId=RecTypeFM);
        insert fm1;
        Account fmf1=new Account( parentId=fm1.id ,Name='fund managersfund1',RecordTypeId=RecTypeFMF);
        insert fmf1;
        
    //    Account test1 = new Account(RecordTypeId = RecTypeOther,Name='@isTest');
     //   insert test1;

   
       Contact concre = new Contact(LastName = 'Manjot@isTest' ,AccountId = inst.Id);
        insert concre;
        System.assert(concre.Id != null);
      Fundraising__c fd1 = new Fundraising__c(Name = '@isTest',Fund_Name__c = coinv.Id,Legal_Name__c = inst.Id,Portfolio_Company__c = com.id);
        insert fd1;
    Fundraising_Contact__c fc = new Fundraising_Contact__c(Fundraising__c = fd1.Id, Contact__c = concre.Id, isPrimary__c=true);
        insert fc;
        try
        {
        concre.AccountId=com.id;
            update concre;
        }
        catch(Exception e)
        {
            System.assert(ApexPages.hasMessages()==True);
        }
        
        Contact concre2 = new Contact(LastName = 'Manjot@isTest' ,AccountId = inst2.Id);
        insert concre2;
               
        Contact con1 = new Contact(LastName = 'Manjot@isTest' ,AccountId = com.Id);
        insert con1;
        try
        {
            delete com;
        }
        catch(Exception e)
        {
            System.assert(ApexPages.hasMessages()==True);
        }

        Contact con2 = new Contact(LastName = 'Manjot@isTest' ,AccountId = fmf1.Id);
        try
        {
            insert con2;
        }
        catch(Exception e)
        {
            System.assert(con2.Id == null);
        }
        
     //   Contact con3 = new Contact(LastName = 'Manjot@isTest' ,AccountId = test1.Id);
        try
        {
       //     insert con3;
        }
        catch(Exception e)
        {
       //     System.assert(con3.Id == null);
        }
    }
}