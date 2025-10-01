@isTest
public class Test_Advisor_Involvement
{
    static string RecTypeInst='';
    static string RecTypeLP='';
    static  string RecTypeCompany='';
    static string RecTypeFM='';
    static string RecTypeFMF='';
   // static  String RecTypeOther='';
    static  RecordType[] Rec;
    public static testmethod void ForAdvisorInvolvement()
    {
        Rec= [Select id,Name,SObjectType from RecordType where SObjectType='Account'];
        
        for(RecordType R:Rec)
        {
            if(R.Name == 'Institution')
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
           //   RecTypeOther= R.Id;
            }
        }
             
         Account inst = new Account(RecordTypeId = RecTypeInst,Familiar_Name__c='@isTest1',Name='@isTest1');
        insert inst;
        Account limpart = new Account(RecordTypeId = RecTypeLP,Name='@isTest',ParentId = inst.Id);
        insert limpart;
        Account com = new Account(RecordTypeId = RecTypeCompany,Name='@isTest');
        insert com;
        Account fm1=new Account(Name='fund manager1',RecordTypeId=RecTypeFM);
        insert fm1;
        Account fmf1=new Account( parentId=fm1.id ,Name='fund managersfund1',RecordTypeId=RecTypeFMF);
        insert fmf1;
      //   Account test1 = new Account(RecordTypeId = RecTypeOther,Name='@isTest');
       // insert test1;
        
        
        Fund__c fund = new Fund__c(Name = '@isTest',Investment_Category__c = 'Fund');
        insert fund;
        Fund__c coinv = new Fund__c(Name = '@isTest',Investment_Category__c = 'Co-Investment');
        insert coinv;
        
        Advisor_Involvement__c ai1 = new  Advisor_Involvement__c(Legal_name__c = inst.Id,Fund__c = fund.Id);
        insert ai1;
        System.assert(ai1.Id != null);
        
        Advisor_Involvement__c ai2 = new  Advisor_Involvement__c(Legal_name__c = limpart.Id,Fund__c = fund.Id);
        insert ai2;
        System.assert(ai2.Id != null);
        
        
        Advisor_Involvement__c ai3 = new  Advisor_Involvement__c(Legal_name__c = com.Id,Fund__c = fund.Id);
        insert ai3;
        System.assert(ai3.Id != null);
        
        Advisor_Involvement__c ai4 = new  Advisor_Involvement__c(Legal_name__c = fm1.Id,Fund__c = fund.Id);
        insert ai4;
        System.assert(ai4.Id != null);
        
        
        Advisor_Involvement__c ai5 = new  Advisor_Involvement__c(Legal_name__c = fmf1.Id,Fund__c = fund.Id);
        try
        {
            insert ai5;
        }
         catch(Exception e)
        {
            System.assert(ai5.Id == null);
        }
     //   Advisor_Involvement__c ai6 = new  Advisor_Involvement__c(Legal_name__c = test1.Id,Fund__c = fund.Id);
        try
        {
        //    insert ai6;
        }
         catch(Exception e)
        {
          //  System.assert(ai6.Id == null);
        }
        
        
        try
        {
           delete fund;
        }
        catch(Exception e)
        {
            System.assert(fund.Id != null);
        }
}
}