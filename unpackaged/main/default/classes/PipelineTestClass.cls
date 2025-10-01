@isTest
private class PipelineTestClass
{
    /*  New Implimentation:

        Developer               :   Vivek Kumar

        Product Version         :   PE 2.0

        Date of Creation        :   11/12/2009

        Purpose of Creation     :   To test the code coverage for the 'PipelineTgrCRandMOdate' trigger.
    */

    static String sCompanyApi =  CommonUtility.chkmasterLookupInPiplineAPI();

    public static testMethod void validateCompanyDates() 
    {
        Date myDate = Date.newInstance(2009, 11, 11);
        Date myDate1 = Date.newInstance(2009, 10, 10);
        Date myDate2 = Date.newInstance(2009, 12, 12);
        String RecInst = '';
        String RecLim = '';
        String RecCom = '';
        RecordType[] Rec = [Select id,Name,SObjectType from RecordType limit 100];
        for(RecordType R:Rec)
        {
            if(R.Name == 'Institution' && R.SObjectType == 'Account')
            {
                RecInst = R.Id;
            }
            if(R.Name == 'Limited Partner' && R.SObjectType == 'Account')
            {
                RecLim = R.Id;
            }
            if(R.Name == 'Company' && R.SObjectType == 'Account')
            {
                RecCom = R.Id;
            }
         }
         Account acc = new Account(name ='Navatar',RecordTypeId = RecCom, Date_Created__c=NULL, Date_Last_Modified__c=NULL, HasPipeline__c=false);
         insert acc;
         
         Account ac=[select name from Account where id=:acc.id];
         System.assertEquals('Navatar',ac.name);
         
         Pipeline__c pipe1 = new Pipeline__c(name='p1', Log_In_Date__c=myDate, Stage__c='on Hold');
         pipe1.put(sCompanyApi, acc.id);
         insert pipe1;
         
         Pipeline__c pip=[select name from Pipeline__c where id=:pipe1.id];
         System.assertEquals('p1',pip.name);
         
         acc.HasPipeline__c=true; acc.Date_Created__c=pipe1.Log_In_Date__c;
         Pipeline__c pipe2 = new Pipeline__c(name='p2', Log_In_Date__c=myDate1, Stage__c='LOI');
         pipe2.put(sCompanyApi, acc.id);
         insert pipe2;
         
         pip=[select name from Pipeline__c where id=:pipe2.id];
         System.assertEquals('p2',pip.name);
         
         Pipeline__c pipe3 = new Pipeline__c(name='p3', Log_In_Date__c=myDate, Stage__c='Idea Generation');
         pipe3.put(sCompanyApi, acc.id);
         insert pipe3;
         
         pip=[select name from Pipeline__c where id=:pipe3.id];
         System.assertEquals('p3',pip.name);
         
         Pipeline__c pipe4 = new Pipeline__c(name='p4', Log_In_Date__c=myDate2, Stage__c='On Hold');
         pipe4.put(sCompanyApi, acc.id);
         insert pipe4;
          
         pip=[select name from Pipeline__c where id=:pipe4.id];
         System.assertEquals('p4',pip.name);
          
         delete pipe2;
         update pipe1;
         delete pipe4;
         update pipe3;
         delete pipe1;
         delete pipe3;
           
         acc.Date_Created__c=NULL;
         acc.Date_Last_Modified__c=NULL;
         acc.HasPipeline__c=false;
    }
}