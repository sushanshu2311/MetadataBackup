/*
Class            : scheduledClientData
Purpose          : This is for scheduling clientDataBatch batch class. 
Version          : v4.2
*/
global with sharing class scheduledClientData implements Schedulable 
{
    global void execute(SchedulableContext SC){
        try
        {
            if(!isExpireDate())
                Database.executeBatch(new clientDataBatch('LAST_N_DAYS:8'), 2000);
        }
        catch(Exception Ex)
        {
            clientDataBatch.exceptionEmail('In \'execute\' method of \'scheduledClientData\' class - '+Ex.getMessage(), Ex.getLineNumber());
        }
    }
    global boolean isExpireDate(){
        List<Organization> orgDetail = [SELECT TrialExpirationDate, IsSandbox FROM Organization Limit 1];
        
    /********************************************START******************************************************************/
    //    return false;  // Remove this line before going to production
    /*********************************************END*******************************************************************/

    /**********************************************START****************************************************************/
        if(orgDetail[0].TrialExpirationDate == null && orgDetail[0].IsSandbox == false ) // uncomment this snippet before going to production
            return false;
        else
            return true;
    /***********************************************END*****************************************************************/   

    }
}