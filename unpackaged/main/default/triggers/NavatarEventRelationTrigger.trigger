/****************************************************************************************************
** Module Name : Acuity 2.0 - Event Relation ChangeEvent Trigger
** Description : 
** Throws : NA
** Calls : NA
** Organization : Navatar Group
** Product Name & Version : Acuity 2.0
** Revision History:-
** Version    Date(YYYY-MM-DD)    Author         Description of Action
** 1.0        2022-11-18          Anmol          Acuity Activity Trigger
** 2.0        2022-12-01          Keyur
****************************************************************************************************/
trigger NavatarEventRelationTrigger on EventRelationChangeEvent (after insert) {
    list<string> eventidInsert = new List<String>();
    list<string> eventidDelete = new List<String>();
    Map<String, Boolean> eventVsisExpiredMap = new Map<String, Boolean>();
    list<string> eventIds = new List<String>();//Anmol: AcuityActivityTrigger
    list<string> eventIdsDelete = new List<String>();//Anmol: LTP
    private static boolean isActive = [SELECT navpeII_dev18__Value__c, navpeII_dev18__RG_Contact_Sync_Fix__c FROM navpeII_dev18__RG_Setting__mdt WHERE DeveloperName = 'RG_Sync_Trigger_Active'].navpeII_dev18__RG_Contact_Sync_Fix__c;

    List<String> ErIds = new List<String>();
    if(isActive){
        for(EventRelationChangeEvent er : Trigger.new){
            EventBus.ChangeEventHeader header = er.ChangeEventHeader;
            if(header.changeType == 'CREATE' || header.changeType == 'UPDATE'){
                ErIds.addAll(header.recordIds);
            }
        }
        if(Schema.getGlobalDescribe().get('EventRelation') != null){
            List<sObject> eventRelationList = new List<sObject>();
            if(!Test.isRunningTest()){
        		eventRelationList = Database.query('SELECT Id, Eventid, Event.EndDateTime FROM EventRelation where id in:ErIds');
            }            
            For(sObject er : eventRelationList){    //[Select Id, Eventid, Event.EndDateTime From EventRelation where id in:ErIds]
                if(er.getSObject('Event').get('EndDateTime') != null && DateTime.valueOf(er.getSObject('Event').get('EndDateTime')) < system.now() ){
                    eventVsisExpiredMap.put(string.valueOf(er.get('id')), true);
                }else{
                    eventVsisExpiredMap.put(string.valueOf(er.get('id')), false);
                }
            } 
        }
        
    }
    
    for(EventRelationChangeEvent er : Trigger.new){
        EventBus.ChangeEventHeader header = er.ChangeEventHeader;
        String changeEntity = header.entityName;
        String changeOperation = header.changeType;
        string[] changedFields = header.changedFields;
        if(isActive){
           For(String erId : header.recordIds){
                if(eventVsisExpiredMap.get(erId) != null && !eventVsisExpiredMap.get(erId)){
                    if(changeOperation == 'CREATE' && er.isSet('IsInvitee') && Boolean.valueof(er.get('IsInvitee')) ){
                        eventidInsert.add(erId);
                    }
                    if(changeOperation == 'UPDATE' && header.changedFields.contains('IsInvitee') && er.isSet('IsInvitee') && !Boolean.valueof(er.get('IsInvitee')) ){
                        eventidDelete.add(erId);
                    }
                }
            } 
        }
        //Anmol: AcuityActivityTrigger
        if(header.changeType == 'CREATE' && String.valueOf(er.RelationId).startsWith('003')){
            eventIds.addAll(header.recordIds);
        }
    //End
    //Anmol: LTP
    if(header.changeType == 'DELETE'){
        eventIdsDelete.addAll(header.recordIds);
    }
    //End
    }
    //Anmol: AcuityActivityTrigger
    if(!Test.isRunningTest()){
        if(eventIds.size()>0){
            NavatarTaskEventRelationHandler.onInsrtUpdteActivity(eventIds);
        }//End
    }
    if(!Test.isRunningTest()){
        if(!eventidDelete.isEmpty()){
            Database.delete(eventidDelete, false);
        }
    }
    if(Schema.getGlobalDescribe().get('EventRelation') != null){
        List<sObject> erToUpdate  = new List<sObject>();
        Schema.SObjectType eventrelationSobj = Schema.getGlobalDescribe().get('EventRelation');
        for(String erId : eventidInsert){
            sObject er = eventrelationSobj.newSobject();
            er.put('id', erId);
            er.put('IsParent' , true);
            erToUpdate.add(er);
                
        }
        if(!Test.isRunningTest()){
            Database.update(erToUpdate, false);
        }
    }
    

}