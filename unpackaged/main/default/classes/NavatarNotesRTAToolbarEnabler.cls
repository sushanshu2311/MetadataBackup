/****************************************************************************************************

** Module Name : Navatar Note

** Description : Used to update field value of user objects that are used in RTA.

** Throws : NA

** Calls : NA

** Organization : Navatar Group

** Product Name & Version : PE v5.5

** Revision History:-

** Version    Date(YYYY-MM-DD)    Author         Description of Action

** 1.0        2025-01-14          Sudhanshu

****************************************************************************************************/



public class NavatarNotesRTAToolbarEnabler implements Schedulable {
    public void execute(SchedulableContext sc) {
        try {
            // Query all active users where navpeII_dev18__Enable_RTA_Toolbar__c is not TRUE
            List<User> activeUsers = [SELECT Id, navpeII_dev18__Enable_RTA_Toolbar__c 
                                      FROM User 
                                      WHERE IsActive = TRUE 
                                      AND navpeII_dev18__Enable_RTA_Toolbar__c != TRUE];

            // Update the Enable_RTA_Toolbar__c field to TRUE for each active user
            for (User u : activeUsers) {
                u.navpeII_dev18__Enable_RTA_Toolbar__c = TRUE;
            }

            // Update the users in the database
            if (!activeUsers.isEmpty()) {
                Database.SaveResult[] results = Database.update(activeUsers, false);
            }
            
            
      
        } catch (Exception e) {
            System.debug('Error occurred during User field update: ' + e.getMessage());
        }
    }

    public static void scheduleUpdateJob() {
        // Schedule the job (use a valid cron expression for your needs)
        String cronExp = '0 0 * * * ?'; // Run once immediately (schedule for next minute)
        NavatarNotesRTAToolbarEnabler scheduler = new NavatarNotesRTAToolbarEnabler();
        System.schedule('Update RTA Toolbar Field Job', cronExp, scheduler);
       
    }
}