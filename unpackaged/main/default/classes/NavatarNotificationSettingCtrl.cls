/* --------------------------------------------------------------------------------------------------
* Apex class to fetch the Navatar Setup object and show action notification & info notification setting values from Navatar Setup
* --------------------------------------------------------------------------------------------------
* @author         Adil A
* @modifiedBy     Adil A
* @version        1.0
* @created        2022-11-21
* @modified       2022-11-21
** Revision History:-
** Version    Date(YYYY-MM-DD)    Author         Description of Action
** 1.0        2022-11-21          Adil             Acuity Phase 1
** 2.0        2024-03-06          Sudhanshu        Added NN_Action_Review_Tag__c in query & wrapper
*/
public with sharing class NavatarNotificationSettingCtrl {
    @AuraEnabled
    public static NavatarNotificationSettingWrapper fetchNotificationSettings(){
        List <sObject> lst = new List <sObject> ();
        NavatarNotificationSettingWrapper wrapper = new NavatarNotificationSettingWrapper();
        String strQuery;
        try{
            strQuery = 'SELECT Id, NN_Action__c, NN_Information__c,NN_Action_Review_Tag__c FROM navpeII_dev18__Navatar_Setup__c Where navpeII_dev18__Admin_Setting__c = true LIMIT 1';
            lst = Database.query(string.escapesinglequotes(strQuery));
        }
        catch(exception ex){
            strQuery = 'SELECT Id, NN_Action__c, NN_Information__c,NN_Action_Review_Tag__c FROM navpeII_dev18__Navatar_Setup__c Where navpeII_dev18__Admin_Setting__c = true LIMIT 1';
            lst = Database.query(string.escapesinglequotes(strQuery));
        }
        wrapper.actionNotification = Boolean.valueOf(lst[0].get('NN_Action__c'));
        wrapper.infoNotification = Boolean.valueOf(lst[0].get('NN_Information__c'));
        wrapper.reviewTag = Boolean.valueOf(lst[0].get('NN_Action_Review_Tag__c'));
        wrapper.recordId = String.valueOf(lst[0].get('Id'));
        return wrapper;
    }   
    
    @AuraEnabled
    public static Boolean deleteNotifications(String type){
        if(type == 'actionNotification') {
            if(Schema.getGlobalDescribe().get('navpeII_dev18__Navatar_Notification__c').getDescribe().isDeletable()){
                delete [select id from Navatar_Notification__c WHERE Type__c IN :NavatarConstants.NOTIFICATION_ACTION_TYPE_SET LIMIT 9999] ;
            }    
        } else if(type == 'infoNotification') {
            if(Schema.getGlobalDescribe().get('navpeII_dev18__Navatar_Notification__c').getDescribe().isDeletable()){
                delete [select id from Navatar_Notification__c WHERE Type__c IN :NavatarConstants.NOTIFICATION_INFO_TYPE_SET LIMIT 9999];
            }    
        }
        else if(type == 'reviewTag'){
            if(Schema.getGlobalDescribe().get('navpeII_dev18__Navatar_Notification__c').getDescribe().isDeletable()){
                delete [select id from Navatar_Notification__c WHERE Type__c IN :NavatarConstants.NOTIFICATION_REVIEW_TYPE_SET LIMIT 9999];
            }   
        }
        return true;
    }   

    public class NavatarNotificationSettingWrapper{
        @AuraEnabled
        public String recordId {get; set;}
        @AuraEnabled
        public Boolean actionNotification {get; set;}
        @AuraEnabled
        public Boolean infoNotification {get; set;}
        @AuraEnabled
        public Boolean reviewTag {get;set;}
    }
    
}