/****************************************************************************************************
** Module Name : Meeting Prep Card (Daily) 1.0 
** Description : Used to Send Meeting Prep Card Daily.
** Organization : Navatar Group
** Product Name & Version : PE Agentforce Baseline 1.0
** Revision History:-
** Version    Date(YYYY-MM-DD)    Author            Description of Action
** 1.0        2026-02-05          Salauddin Sheikh  PE Agentforce Baseline Phase 1
****************************************************************************************************/
public with sharing class NavatarMeetingPrepCardSchduler {
     @InvocableMethod
    public static void sendPrepCardToDistributionList() {
        try {
            NavatarMeetingPrepCardSchdulerBatch batch = new NavatarMeetingPrepCardSchdulerBatch();
            Database.executeBatch(batch,1);//Bug Fixing 00051002,00051024 Salauddin
        } catch (Exception e) {
            
            System.debug(LoggingLevel.ERROR, 'Error in sendPrepCardToDistributionList: ' + e.getMessage());
        }
    }
}