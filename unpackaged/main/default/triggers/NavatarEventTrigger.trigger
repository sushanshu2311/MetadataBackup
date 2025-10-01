/****************************************************************************************************

** Module Name : Connections 2.0 - Custom Notification
** Description : Used to handle meetings notes captured or not related funtionalities of Connections 2.0 Custom Notification.
** Throws : NA
** Calls : NA
** Organization : Navatar Group
** Product Name & Version : Connections 2.0
** Revision History:-
** Version    Date(YYYY-MM-DD)    Author         Description of Action
** 1.0        2022-08-08          Priyank        fetch and update event's records
** 2.0        2022-10-15          Priyank        handle white space related bug
** 3.0        2022-11-22          Priyank        handle last touchpoint updation
** 4.0        2022-11-22          Adil           handle onInsert and onUpdate to create notification records. removed version 1.0 & 2.0 logic
** 5.0        2022-11-23          Deepak Singh   Update LTP date and Id on Fundraising and Deal
****************************************************************************************************/
trigger NavatarEventTrigger on Event (before update, after insert, after update, before delete, after undelete) {
    /*Functionality of Notes Needed not needed

if(trigger.isBefore && trigger.isUpdate){
for(Event eve : trigger.new){
Event oldEve = trigger.oldMap.get(eve.Id);
String oldDescription = string.isNotBlank(oldEve.Description)?oldEve.Description.replaceAll( '\\s+', ''):'';// Bug: 00031917--> except if someone add space within text
String newDescription = string.isNotBlank(eve.Description)?eve.Description.replaceAll( '\\s+', ''):'';
// check description is updated or not
if((String.isBlank(oldDescription) && string.isNotBlank(newDescription)) || (string.isNotBlank(oldDescription) && oldDescription != newDescription)){
eve.Notes_Needed__c = null;
}
}
}*/
try{
    if(!system.isFuture() && trigger.isBefore && trigger.isDelete){
        Set<Id> conIdsSet=new Set<Id>();
        Set<Id> eventIdsSet=new Set<Id>();
        Set<Id> notesEventIdsSet=new Set<Id>();
        for(Event e:Trigger.old){
            notesEventIdsSet.add(e.Id);
                if(e.navpeII_dev18__Is_Touchpoint_New__c){
            eventIdsSet.add(e.Id);
            conIdsSet.add(e.WhoId);
        }
            }
            if(Schema.getGlobalDescribe().get('EventRelation') != null){
                List<Sobject> EventRelationList = new List<Sobject>();
                EventRelationList = Database.query('Select Id, RelationId from EventRelation where eventId IN: eventIdsSet');
                for(Sobject er: EventRelationList){
                    if(String.valueOf(er.get('RelationId')).startsWith('003'))
                        conIdsSet.add(String.valueof(er.get('RelationId')));
                }
        }
        NavatarTaskEventRelationHandler.onDeleteActivity('EventRelation',eventIdsSet,conIdsSet);
        Set<Id> erEventIdSet=new Set<Id>();
        NavatarTaskEventRelationHandler.deleteRichTextField(notesEventIdsSet);   // Added by Sudhanshu
    }
    if(!system.isFuture() && trigger.isAfter && (trigger.isUpdate || trigger.isUndelete)){
        List<Id> eRelIdsList=new List<Id>();
        Set<Id> eventIdsSet=new Set<Id>();
        for(Event e:(List<Event>)Trigger.new){
            if(!trigger.isUndelete){
                Event oldevnt=Trigger.oldMap.get(e.Id);
                    if(NavatarTaskEventRelationHandler.taskEventchk){
                        //Added above if check & below variable assignment by LK on 2024-06-06 to fix 00045431
                        NavatarTaskEventRelationHandler.taskEventchk = false;
                        //Removed "e.EndDateTime != oldevnt.EndDateTime &&" by LK on 2024-06-06 to fix 00045431
                        if(e.navpeII_dev18__Is_Touchpoint_New__c || (e.navpeII_dev18__Is_Touchpoint_New__c != oldevnt.navpeII_dev18__Is_Touchpoint_New__c)){
                            eventIdsSet.add(e.Id);
                        }
                        system.debug(eventIdsSet);
                    }
            }
                else if(e.navpeII_dev18__Is_Touchpoint_New__c){
                eventIdsSet.add(e.Id);
            }
        }
            if(Schema.getGlobalDescribe().get('EventRelation') != null){
                List<Sobject> EventRelationList = new List<Sobject>();
                EventRelationList = Database.query('Select Id, RelationId from eventRelation where eventId IN: eventIdsSet');
                for(Sobject er: EventRelationList){
                    eRelIdsList.add(String.valueof(er.get('Id')));
                }
        }
        if(eRelIdsList.size() > 0){
            NavatarTaskEventRelationHandler.onInsrtUpdteActivity(eRelIdsList);
        }
    }

    if(!system.isFuture() && trigger.isAfter && (trigger.isInsert || trigger.isUpdate || trigger.isUndelete)){
        Set<String> eventIdsSet=new Set<String>();
        for(Event t:Trigger.new){
                if(t.navpeII_dev18__Related_Associations__c != ''){//Bug 45712 fix
                   eventIdsSet.add(t.Id);
                }
        }
        if(NavatarTaskEventRelationHandler.recursionchk){
            NavatarTaskEventRelationHandler.recursionchk = false;
            if(eventIdsSet.size() > 0){
                NavatarTaskEventRelationHandler.onInsrtUpdteRelatedAssociation(new List<String>(eventIdsSet));
            }
        }
    }
}catch(Exception e){}
    //if(!system.isFuture() && 
    //((trigger.isAfter && trigger.isInsert) || (trigger.isAfter && trigger.isUpdate) || (trigger.isBefore && trigger.isDelete)  || (trigger.isAfter && trigger.isUndelete))){
    //System.debug('@@inside trigger');
    //List<Event> evtList = Trigger.isDelete ? Trigger.Old : Trigger.New;
    //EventTriggerHelper.OnAfterInsUpdDel(evtList, Trigger.oldMap);
    
    //}
    //added for Adil Aleem's functionality
    if(Trigger.isAfter && Trigger.isUpdate) {
        NavatarEventTriggerHandler.onAfterUpdate(Trigger.new, Trigger.oldMap);
    }
    
    if(Trigger.isAfter && Trigger.isInsert) {
        NavatarEventTriggerHandler.onAfterInsert(Trigger.new);
    }
    
}