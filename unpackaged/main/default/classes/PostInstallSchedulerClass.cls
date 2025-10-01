/*
Class            : PostInstallClass
Purpose          : This is the controller will run immediately after package upgrade/push and schedule scheduledClientData class weekly . 
Version          : v4.2

** Revision History:-

** Version    Date(YYYY-MM-DD)    Author         Description of Action

** 1.0        2025-01-14          Sudhanshu
*/
global class PostInstallSchedulerClass implements InstallHandler
{
    global void onInstall(InstallContext context)
    {
   
        try
        {
            // Schedule the job after the package installation is complete
            // Immediately invoke the job without using a cron expression
            // Added By Sudhanshu on 14-01-2025
            NavatarNotesRTAToolbarEnabler scheduler = new NavatarNotesRTAToolbarEnabler();      
            scheduler.execute(null);  // Execute immediately



            list<CronJobDetail> cjd = [SELECT Id, Name FROM CronJobDetail WHERE Name = 'NavatarUsageMetrics' Limit 1];
            if(cjd.size() == 0)
            {
                string timeinterval = '0 0 1 ? * 1';
                System.schedule('NavatarUsageMetrics',timeinterval, new scheduledClientData()); // This will schedule class weekly on Sunday at 1:00 AM
                
                scheduledClientData scd = new scheduledClientData();
                if(!scd.isExpireDate())
                    Database.executeBatch(new clientDataBatch('LAST_N_DAYS:180') , 2000); // This will run batch class immediately post upgrade/push
            }
        }
        catch(Exception Ex)
        {
            clientDataBatch.exceptionEmail('In \'onInstall\' method of \'PostInstallSchedulerClass\' class - '+Ex.getMessage(), Ex.getLineNumber());
        }
    }
}