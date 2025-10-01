/**
* --------------------------------------------------------------------------------------------------
* Apex class designed to calculate the Last Touch point from  Event based EndDateTime field and task based activity date field then update
* Last Touch Point date Contact.
* --------------------------------------------------------------------------------------------------
* @author         Priyank Kumar
* @modifiedBy     Priyank Kumar
* @version        1.0    
* @created        2022-11-22    
* @modified       2022-11-24
*/

public with sharing class NavatarEventTriggerHandler{

    //added for Adil Aleem's functionality
    /*****************************************************************************************************
    * @Name         :   onAfterInsert
    * @Description  :   Method to handle after insert of Event
    * @Parameter    :   List<Event>
    *****************************************************************************************************/
    public static void onAfterInsert(List<Event> newRecords){    
        if(newRecords.size() == 1) {
            Map<String , Boolean> notificationSettings = NavatarUtility.isNotificationAllowed();
            if(notificationSettings.containsKey('info') && notificationSettings.get('info') ){
                createInfoNotification(newRecords[0] , null);
            }  
        }
    }

    /*****************************************************************************************************
    * @Name         :   onAfterUpdate
    * @Description  :   Method to handle after update of Event
    * @Parameter    :   List<Event> , Map<Id, Event>
    *****************************************************************************************************/
    public static void onAfterUpdate(List<Event> newRecords, Map<Id , Event> oldRecordMap){
        if(newRecords.size() == 1) {
            Map<String , Boolean> notificationSettings = NavatarUtility.isNotificationAllowed();
            if(notificationSettings.containsKey('info') && notificationSettings.get('info') ){
                createInfoNotification(newRecords[0] , oldRecordMap.get(newRecords[0].id));
            }  
        } 
        deleteNotification(newRecords, oldRecordMap); 
    }

    /*****************************************************************************************************
    * @Name         :   deleteNotification
    * @Description  :   Method to handle delete notification on description
    * @Parameter    :   List<Event> , Map<Id, Event>
    *****************************************************************************************************/
    public static void deleteNotification(List<Event> newRecords, Map<Id , Event> oldRecordMap){
        Set<String> eventIds = new Set<String>();
        for(SObject o : trigger.new){
           Event eve = (Event) o; 
           Event oldEvent = oldRecordMap != null ? (Event) oldRecordMap.get(eve.Id) : null;
           if(oldEvent != null) {
               String oldDescription = string.isNotBlank(oldEvent.Description) ? oldEvent.Description.replaceAll( '\\s+', ''):'';// Bug: 00031917--> except if someone add space within text
               String newDescription = string.isNotBlank(eve.Description)?eve.Description.replaceAll( '\\s+', ''):'';
               if((String.isBlank(oldDescription) && string.isNotBlank(newDescription)) || (string.isNotBlank(oldDescription) && oldDescription != newDescription)){
                   eventIds.add(eve.Id);
               }
           }
        } 

        if(Schema.getGlobalDescribe().get('navpeII_dev18__Navatar_Notification__c').getDescribe().isDeletable()){
           delete [select id from navpeII_dev18__Navatar_Notification__c WHERE Record_ID__c = :eventIds AND Type__c = :NavatarConstants.ADD_NOTE];
       }    
   } 


     /*****************************************************************************************************
    * @Name         :   createInfoNotification
    * @Description  :   Method to create Info Notification record based on addition of deal/theme
    * @Parameter    :   Event, Event
    *****************************************************************************************************/
    private static void createInfoNotification(Event newRecord, Event oldRecord){
        if(!String.isBlank(newRecord.Related_Associations__c) && (oldRecord == null || newRecord.Related_Associations__c != oldRecord.Related_Associations__c)){
            String relatedAssociation = (oldRecord != null && String.isNotBlank(oldRecord.Related_Associations__c)) ? oldRecord.Related_Associations__c : '';
            List<String> newTaggedRecords = new List<String>(); 
            List<String> oldTaggedRecords = new List<String>(); 
            Set<String> oldTaggedRecordSet = new Set<String>();
            Set<Id>  dealIdSet = new Set<Id> (); 
            Set<Id> themeIdSet = new Set<Id> (); 
            List<Navatar_Notification__c> notificationList = new List<Navatar_Notification__c>(); 
 
            if(!String.isBlank(newRecord.Related_Associations__c)){
                newTaggedRecords = newRecord.Related_Associations__c.split(',');
                for(String tag : newTaggedRecords) {
                    String objectAPIName = Id.valueOf(tag).getSObjectType().getDescribe().getName();
                    if((objectAPIName == 'navpeII_dev18__Pipeline__c' || objectAPIName == 'Pipeline__c') && !relatedAssociation.contains(tag)){
                        dealIdSet.add(tag);
                    }
                    else if((objectAPIName == 'navpeII_dev18__Theme__c' || objectAPIName == 'Theme__c') && !relatedAssociation.contains(tag)){
                        themeIdSet.add(tag);
                    }
                }
            }
            if(!dealIdSet.isEmpty()){
                notificationList.addAll(prepareNotificationForDealTeam(dealIdSet , newRecord));
            }
            if(!themeIdSet.isEmpty()){
                notificationList.addAll(prepareNotificationForThemeRelation(themeIdSet , newRecord));
            }  
            
            if(!notificationList.isEmpty() && Schema.getGlobalDescribe().get('navpeII_dev18__Navatar_Notification__c').getDescribe().isCreateable()){
                Database.insert(notificationList , false);
            }    
        }
    }

     /*****************************************************************************************************
    * @Name         :   prepareNotificationForDealTeam
    * @Description  :   Method to prepare Deal Activity Info Notification record based on deal ids
    * @Parameter    :   Set<Id>
    *****************************************************************************************************/
    private static List<Navatar_Notification__c> prepareNotificationForDealTeam(Set<Id> dealIds, Event activity){
        Set<String> existingNotificationSet = new Set<String>();
        List<Navatar_Notification__c> notificationList = new List<Navatar_Notification__c>(); 
        //added  stripInaccessible by Pavani w.r.t security fix 
        for(SObject notif :Security.stripInaccessible(AccessType.READABLE,
                            [SELECT Id, Record_ID__c, User__c 
                            FROM Navatar_Notification__c 
                            WHERE Record_ID__c IN :dealIds]).getRecords()){
            Navatar_Notification__c nn = (Navatar_Notification__c)notif;
            if(nn.isSet('Record_ID__c') && nn.Record_ID__c != null && nn.isSet('User__c') && nn.User__c != null) {
                existingNotificationSet.add(nn.Record_ID__c + '-' + nn.User__c + '-' + nn.Type__c);
            }   
        }
        if(Schema.SObjectType.navpeII_dev18__Pipeline__c.isAccessible() && 
        Schema.SObjectType.navpeII_dev18__Deal_Team__c.isAccessible()){
            List<navpeII_dev18__Deal_Team__c> dealTeamList = [SELECT Id, navpeII_dev18__Deal__c, navpeII_dev18__Team_Member__c FROM navpeII_dev18__Deal_Team__c WHERE navpeII_dev18__Deal__c IN : dealIds
                                                        AND navpeII_dev18__Team_Member__c!=null];
            SObjectAccessDecision dtReadDecision = Security.stripInaccessible(AccessType.READABLE,dealTeamList);
            for(SObject dealteam : dtReadDecision.getRecords()){ 
                navpeII_dev18__Deal_Team__c dt = (navpeII_dev18__Deal_Team__c)dealteam;
                if(Schema.SObjectType.navpeII_dev18__Deal_Team__c.fields.navpeII_dev18__Deal__c.isAccessible() &&
                    Schema.SObjectType.navpeII_dev18__Deal_Team__c.fields.navpeII_dev18__Team_Member__c.isAccessible() ){
                    String key = dt.navpeII_dev18__Deal__c + '-' + dt.navpeII_dev18__Team_Member__c  + '-' + NavatarConstants.DEAL_ACTIVITY_INFO;
                    if(!existingNotificationSet.contains(key) && activity.OwnerId != dt.navpeII_dev18__Team_Member__c){
                Navatar_Notification__c nn = new Navatar_Notification__c();
                if (Schema.sObjectType.Navatar_Notification__c.fields.Record_ID__c.isCreateable()) {
                    nn.Record_ID__c = activity.Id;
                }
                if (Schema.sObjectType.Navatar_Notification__c.fields.User__c.isCreateable()) {
                    nn.User__c = dt.navpeII_dev18__Team_Member__c;
                }
                if (Schema.sObjectType.Navatar_Notification__c.fields.Type__c.isCreateable()) {
                    nn.Type__c = NavatarConstants.DEAL_ACTIVITY_INFO;
                }    
                notificationList.add(nn);         
            }
        }
            }
        }
        return  notificationList;
    }

     /*****************************************************************************************************
    * @Name         :   prepareNotificationForThemeRelation
    * @Description  :   Method to prepare Theme Activity Info Notification record based on theme ids
    * @Parameter    :   Set<Id>
    *****************************************************************************************************/
    private static List<Navatar_Notification__c> prepareNotificationForThemeRelation(Set<Id> themeIds, Event activity){
        Set<String> existingNotificationSet = new Set<String>();
        List<Navatar_Notification__c> notificationList = new List<Navatar_Notification__c>(); 
        //added  stripInaccessible by Pavani w.r.t security fix 
        for(SObject notif :Security.stripInaccessible(AccessType.READABLE,
                           [SELECT Id, Record_ID__c, User__c 
                           FROM Navatar_Notification__c 
                           WHERE Record_ID__c IN :themeIds]).getRecords()){
           Navatar_Notification__c nn = (Navatar_Notification__c)notif;
            if(nn.isSet('Record_ID__c') && nn.Record_ID__c != null && nn.isSet('User__c') && nn.User__c != null) {
                existingNotificationSet.add(nn.Record_ID__c + '-' + nn.User__c + '-' + nn.Type__c);
            }   
        }
        if(Schema.SObjectType.navpeII_dev18__Theme__c.isAccessible() && 
        Schema.SObjectType.navpeII_dev18__Theme_Team__c.isAccessible()){
        List<navpeII_dev18__Theme_Team__c> themeTeamList = [SELECT Id, navpeII_dev18__Theme__c, navpeII_dev18__Member__c FROM navpeII_dev18__Theme_Team__c WHERE navpeII_dev18__Theme__c IN : themeIds
											AND navpeII_dev18__Member__c!=null];
        SObjectAccessDecision ttReadDecision = Security.stripInaccessible(AccessType.READABLE,themeTeamList);
        for(SObject themeteam : ttReadDecision.getRecords()){ 
            navpeII_dev18__Theme_Team__c tr = (navpeII_dev18__Theme_Team__c)themeteam;
                if(Schema.SObjectType.navpeII_dev18__Theme_Team__c.fields.navpeII_dev18__Theme__c.isAccessible() &&
                Schema.SObjectType.navpeII_dev18__Theme_Team__c.fields.navpeII_dev18__Member__c.isAccessible()){
            String key = tr.navpeII_dev18__Theme__c + '-' + tr.navpeII_dev18__Member__c  + '-' + NavatarConstants.THEME_ACTIVITY_INFO;
            if(!existingNotificationSet.contains(key) && activity.OwnerId !=tr.navpeII_dev18__Member__c){
                Navatar_Notification__c nn = new Navatar_Notification__c();
                if (Schema.sObjectType.Navatar_Notification__c.fields.Record_ID__c.isCreateable()) {
                    nn.Record_ID__c = activity.Id;
                }
                if (Schema.sObjectType.Navatar_Notification__c.fields.User__c.isCreateable()) {
                    nn.User__c = tr.navpeII_dev18__Member__c;
                }    
                if (Schema.sObjectType.Navatar_Notification__c.fields.Type__c.isCreateable()) {
                    nn.Type__c = NavatarConstants.THEME_ACTIVITY_INFO;
                }    
                notificationList.add(nn);         
                    }
                }
            }
        }
        return  notificationList;
    }
}