@isTest
public class Test_Pipeline
{
    static string RecTypeInst='';
    static string RecTypeLP='';
    static  string RecTypeCompany='';
    static string RecTypeFM='';
    static string RecTypeFMF='';
    static String sCompanyApi =  CommonUtility.chkmasterLookupInPiplineAPI();
  //  static  String RecTypeOther='';
    static  RecordType[] Rec;
    public static testmethod void ForPipeline()
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
          //  RecTypeOther= R.Id;
            }
        }
        
        Account inst = new Account(RecordTypeId = RecTypeInst,Familiar_Name__c='@isTest1',Name='@isTest1');
        insert inst;
        Account limpart = new Account(RecordTypeId = RecTypeLP,Name='@isTest',ParentId = inst.Id);
        insert limpart;
        Account com = new Account(RecordTypeId = RecTypeCompany,Name='@isTest', HasPipeline__c = false);
        insert com;
        
        Account fm1=new Account(Name='fund manager1',RecordTypeId=RecTypeFM);
        insert fm1;
        Account fmf1=new Account( parentId=fm1.id ,Name='fund managersfund1',RecordTypeId=RecTypeFMF);
        insert fmf1;
        
      //  Account test1 = new Account(RecordTypeId = RecTypeOther,Name='@isTest');
      //  insert test1;
        
     //   Pipeline__c pipe6 = new Pipeline__c(Name = '@isTest',Company_Name__c =test1.Id,Stage__c = 'LOI');
        try
        {
        //   insert pipe6;
        }
         catch(Exception e)
        {
           // System.assert(pipe6.Id == null);
        }
        
        Pipeline__c pipe1 = new Pipeline__c(Name = '@isTest', Stage__c = 'LOI');
        pipe1.put(sCompanyApi, inst.Id);
        try
        {
           insert pipe1;
        }
         catch(Exception e)
        {
            System.assert(pipe1.Id == null);
        }
        
       Pipeline__c pipe3 = new Pipeline__c(Name = '@isTest', Stage__c = 'LOI');
        pipe3.put(sCompanyApi, com.Id);
       insert pipe3;
       
       System.assert(pipe3.Id != null);
       
        Pipeline__c pipe4 = new Pipeline__c(Name = '@isTest1', Stage__c = 'LOI',Log_In_Date__c=Date.valueOf('2012-3-4'));
        pipe4.put(sCompanyApi, com.Id);
       insert pipe4;
       
       System.assert(pipe4.Id != null);
       
       Pipeline__c pipe5 = new Pipeline__c(Name = '@isTest1', Stage__c = 'LOI',Log_In_Date__c=Date.valueOf('2012-2-2'));
        pipe5.put(sCompanyApi, com.Id);
       insert pipe5;
       
       System.assert(pipe5.Id != null);
       
       pipe4.Log_In_Date__c=Date.valueOf('2012-1-1');
       
          
        update pipe4;
        
        pipe4.Log_In_Date__c=Date.valueOf('2012-7-7');
        update pipe4;
        
        delete pipe4;
        delete pipe5;
        delete pipe3;
        
        
             
        
        
        
        
}
}