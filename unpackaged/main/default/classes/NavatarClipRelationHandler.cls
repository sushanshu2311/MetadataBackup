/************************************************************************************
** Module Name : Clip Relation Trigger Handler
** Description : This class is used for handling clip relation insert
** Class: ClipRelationTriggerHandler
** Organization : Navatar Group
** Revision History:-
** Version Date(YYYY-MM-DD)    Author                  
** 1.0     2022-11-25          Adil Aleem   
** 2.0     2023-02-23          Pavani         Created the clipRelationTrigger with new name
****************************************************************************************************************/
public with sharing class NavatarClipRelationHandler {
     /*****************************************************************************************************
    * @Name         :   onAfterInsert
    * @Description  :   Method to handle after update of Clip Relation
    * @Parameter    :   Map<Id , Clip_Relation__c>
    *****************************************************************************************************/
    public static void onAfterInsert(Map<Id , Clip_Relation__c> newRecordMap){
        Map<String , Boolean> notificationSettings = NavatarUtility.isNotificationAllowed();
        if(notificationSettings.containsKey('info') && notificationSettings.get('info')){
            createInfoNotification(newRecordMap);
        }     
    }

     /*****************************************************************************************************
    * @Name         :   createInfoNotification
    * @Description  :   Method to create Info Notification record based on creation of Clip Relation
    * @Parameter    :   Map<Id , Clip_Relation__c>
    *****************************************************************************************************/
    private static void createInfoNotification(Map<Id , Clip_Relation__c> newRecordMap){
        Set<String> existingNotificationSet = new Set<String>();
        List<Navatar_Notification__c> notificationList = new List<Navatar_Notification__c>(); 
        //added  stripInaccessible by Pavani w.r.t security fix 
        for(SObject notif :Security.stripInaccessible(AccessType.READABLE,
                            [SELECT Id, Record_ID__c, User__c, Type__c 
                            FROM Navatar_Notification__c 
                            WHERE Record_ID__c IN :newRecordMap.keySet()]).getRecords()){
            Navatar_Notification__c nn = (Navatar_Notification__c)notif;
            if(nn.isSet('Record_ID__c') && nn.Record_ID__c != null && nn.isSet('User__c') && nn.User__c != null) {
                existingNotificationSet.add(nn.Record_ID__c + '-' + nn.User__c + '-' + nn.Type__c);
            }   
        }

        for(Clip_Relation__c cr : newRecordMap.values()){ 
            //added FLS check on Clip by Pavani w.r.t security fix
            if(Schema.sObjectType.Clip_Relation__c.fields.User__c.isAccessible() && 
                Schema.sObjectType.Clip_Relation__c.fields.Clip__c.isAccessible()){
            String key = cr.Clip__c + '-' + cr.User__c + '-' + NavatarConstants.CLIP_INFO;
            if(!existingNotificationSet.contains(key) && cr.User__c != userinfo.getUserId()){
                Navatar_Notification__c nn = new Navatar_Notification__c();  
                if (Schema.sObjectType.Navatar_Notification__c.fields.Record_ID__c.isCreateable()) {
                    nn.Record_ID__c = cr.Clip__c;
                }
                if (Schema.sObjectType.Navatar_Notification__c.fields.User__c.isCreateable()) {
                    nn.User__c = cr.User__c;
                }
                if (Schema.sObjectType.Navatar_Notification__c.fields.Type__c.isCreateable()) {
                    nn.Type__c = NavatarConstants.CLIP_INFO;
                }
                notificationList.add(nn);         
            }
        } 
        } 
             
        if(!notificationList.isEmpty() && Schema.getGlobalDescribe().get('navpeII_dev18__Navatar_Notification__c').getDescribe().isCreateable()){
            Database.insert(notificationList , false);
        }    
    }
}