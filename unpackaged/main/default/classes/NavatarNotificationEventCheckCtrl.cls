/****************************************************************************************************
  
    ** Module Name : Connections 2.0 - Custom Notification
    ** Description : Used to handle all the DML & schema related funtionalities of Connections 2.0 Custom Notification.
    ** Throws : NA
    ** Calls : NA
    ** Organization : Navatar Group
    ** Product Name & Version : Connections 2.0
    ** Revision History:-
    ** Version    Date(YYYY-MM-DD)    Author         Description of Action
    ** 1.0        2022-10-10          Priyank        update Notes Needed Fieldvalue
    ** 2.0        2022-11-21          Adil           create notification record based on event and user id

****************************************************************************************************/
public with sharing class NavatarNotificationEventCheckCtrl {
    @InvocableMethod(label='Create Notification Records' description='when event end we need to mark Notes Needed as Yes if event is not private.')
    public static void createNotificationRecords(List<ID> ids) {
        try {
            Map<String , Boolean> notificationSettings = NavatarUtility.isNotificationAllowed();
            if(notificationSettings.containsKey('action') && notificationSettings.get('action')){   
                Map<String , List<String>> eventRelatedAssociationMap = new Map<String , List<String>>();
                Map<String , String> notificationMap = new Map<String , String>();
                List<Navatar_Notification__c> notificationList = new List<Navatar_Notification__c>(); 
                //added  stripInaccessible by Pavani w.r.t security fix
                for(SObject notif :Security.stripInaccessible(AccessType.READABLE,
                                    [SELECT Id, Record_ID__c, User__c, Type__c 
                                    FROM Navatar_Notification__c 
                                    WHERE Record_ID__c IN :ids]).getRecords()){
                    Navatar_Notification__c nn = (Navatar_Notification__c)notif;
                    if(nn.isSet('Record_ID__c') && nn.Record_ID__c != null && nn.isSet('User__c') && nn.User__c != null) {
                        notificationMap.put(nn.Record_ID__c + '-' + nn.User__c + '-' + nn.Type__c, nn.id);
                    }   
                }
                List<Event> eveList = Database.query(String.escapeSingleQuotes('SELECT Id, Subject, Description, OwnerId , (Select EventId,RelationId From EventRelations) FROM Event WHERE Id IN :ids and IsChild = false and IsDeleted = false and IsPrivate = false ORDER BY EndDateTime Desc'));
                //added  stripInaccessible by Pavani w.r.t security fix
                SObjectAccessDecision decision = Security.stripInaccessible(AccessType.READABLE,eveList);
    
                for(SObject e : decision.getRecords()){
                    Event eve = (Event)e;
                    Set<String> userSet = new Set<String>();
                    if(eve.getSObjects('EventRelations') != null) {
                        for(SObject er : eve.getSObjects('EventRelations')){
                            if(String.valueOf(er.get('RelationId')) != null && String.valueOf(er.get('RelationId')).startsWith('005')
                                && !notificationMap.containsKey(eve.id + '-' + String.valueOf(er.get('RelationId')) + '-' + NavatarConstants.ADD_NOTE)){
                                    Navatar_Notification__c nn = new Navatar_Notification__c();
                                    if (Schema.sObjectType.Navatar_Notification__c.fields.Record_ID__c.isCreateable()) {
                                        nn.Record_ID__c = eve.Id;
                                    }
                                    if (Schema.sObjectType.Navatar_Notification__c.fields.User__c.isCreateable()) {
                                        nn.User__c = String.valueOf(er.get('RelationId'));
                                    }    
                                    if (Schema.sObjectType.Navatar_Notification__c.fields.Type__c.isCreateable()) {
                                        nn.Type__c = NavatarConstants.ADD_NOTE;    
                                    }           
                                    notificationList.add(nn);    
                                    userSet.add(nn.User__c);      
                            }        
                        }    
                    }
                    if(eve.isSet('OwnerId') && eve.OwnerId != null && String.valueOf(eve.OwnerId).startsWith('005')
                        && !notificationMap.containsKey(eve.id + '-' + eve.OwnerId + '-' + NavatarConstants.ADD_NOTE)
                        && !userSet.contains(eve.OwnerId)){
                            Navatar_Notification__c nn = new Navatar_Notification__c();
                            if (Schema.sObjectType.Navatar_Notification__c.fields.Record_ID__c.isCreateable()) {
                                nn.Record_ID__c = eve.Id;
                            }
                            if (Schema.sObjectType.Navatar_Notification__c.fields.User__c.isCreateable()) {
                                nn.User__c = eve.OwnerId;
                            }    
                            if (Schema.sObjectType.Navatar_Notification__c.fields.Type__c.isCreateable()) {
                                nn.Type__c = NavatarConstants.ADD_NOTE;   
                            }       
                            notificationList.add(nn);          
                    }
                }  
                
                if(Schema.getGlobalDescribe().get('navpeII_dev18__Navatar_Notification__c').getDescribe().isCreateable()){
                    Database.SaveResult[] nnSaveList = Database.insert(notificationList, false);
                }    
            }   
        }
        catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }    
    }   
      
}