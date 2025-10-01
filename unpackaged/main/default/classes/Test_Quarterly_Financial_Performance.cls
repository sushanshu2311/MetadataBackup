@isTest
public class Test_Quarterly_Financial_Performance
{
    static string RecTypeInst='';
    static string RecTypeLP='';
    static  string RecTypeCompany='';
    static string RecTypeFM='';
    static string RecTypeFMF='';
   // static  String RecTypeOther='';
    static  RecordType[] Rec;
    public static testmethod void ForQuarterlyFinancialPerformance()
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
        Account com = new Account(RecordTypeId = RecTypeCompany,Name='@isTest');
        insert com;
        Account fm1=new Account(Name='fund manager1',RecordTypeId=RecTypeFM);
        insert fm1;
        Account fmf1=new Account( parentId=fm1.id ,Name='fund managersfund1',RecordTypeId=RecTypeFMF);
        insert fmf1;
      //   Account test1 = new Account(RecordTypeId = RecTypeOther,Name='@isTest');
      //  insert test1;
        
        Quarterly_Financial_performance__c qfp1 = new Quarterly_Financial_performance__c(Company__c = inst.Id,Quarter_end_Date__c = System.today(), Fiscal_Year_end__c = System.today(),Quarter__c = 'Q1');
         insert qfp1;
         System.assert(qfp1.Id!=null);
        Quarterly_Financial_performance__c qfp2 = new Quarterly_Financial_performance__c(Company__c = limpart.Id,Quarter_end_Date__c  = System.today(),Fiscal_Year_end__c = System.today(),Quarter__c = 'Q1');
        insert qfp2;
       System.assert(qfp2.Id!=null);
        Quarterly_Financial_performance__c qfp3 = new Quarterly_Financial_performance__c(Company__c = com.Id,Quarter_end_Date__c  = System.today(),Fiscal_Year_end__c = System.today(),Quarter__c = 'Q1');
        insert qfp3;
        System.assert(qfp3.Id != null);
        
         Quarterly_Financial_performance__c qfp4 = new Quarterly_Financial_performance__c(Company__c = fm1.Id,Quarter_end_Date__c  = System.today(),Fiscal_Year_end__c = System.today(),Quarter__c = 'Q1');
        try
        {
            insert qfp4;
        }
        catch(Exception e)
        {
            System.assert(qfp4.Id==null);
        }
        Quarterly_Financial_performance__c qfp5 = new Quarterly_Financial_performance__c(Company__c = fmf1.Id,Quarter_end_Date__c  = System.today(),Fiscal_Year_end__c = System.today(),Quarter__c = 'Q1');
        try
        {
            insert qfp5;
        }
        catch(Exception e)
        {
            System.assert(qfp5.Id==null);
        }
      //  Quarterly_Financial_performance__c qfp6 = new Quarterly_Financial_performance__c(Company__c = test1.Id,Quarter_end_Date__c  = System.today(),Fiscal_Year_end__c = System.today(),Quarter__c = 'Q1');
        try
        {
         //   insert qfp6;
        }
        catch(Exception e)
        {
          //  System.assert(qfp6.Id==null);
        }
}
}