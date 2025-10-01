public class NavatarEventReminderCtrl {
    
    @InvocableMethod
    public static void callFlowApexAction(List<FlowInputParams> inputParamsFlow) {
        try{
            List<navpeII_dev18__Event_Reminder__e> eventStartNotifications = new List<navpeII_dev18__Event_Reminder__e>();
            for(FlowInputParams inputParams  : inputParamsFlow){ //added by shivam
                system.debug('input '+inputParams.eventRecords);
                Set<Id> evtIds = new Set<Id>();
                Map<String, List<UserWrapper>> eventRelationMap = new Map<STring, List<UserWrapper>>();
                List<Event> evtRecs = new List<Event>();
                Map<Id, Event> eventMap = new Map<Id,Event>();
                set<id> handleAssignTo = new set<id>(); //added by shivam
                Event evtRecord;
                for(Event evt : inputParams.eventRecords) {
                    evtRecs.add(evt);
                    eventMap.put(evt.Id, evt);
                    evtIds.add(evt.Id);
                    evtRecord = evt;
                }
                for(EventRelation relation : [Select Id, Relation.Name, relationId, STatus, EventId,Event.OwnerId from EventRelation where EventId In : evtIds]) {
                    if(!eventRelationMap.containsKey(relation.EventId)) {
                        eventRelationMap.put(relation.EventId, new List<UserWrapper>());
                    }
                    Id relationId = (Id)relation.RelationId;
                    if(String.valueOf(relationId.getSobjectType()) == 'User') {
                        handleAssignTo.add(relationId);
                        eventRelationMap.get(relation.EventId).add(new UserWrapper(relation.relationId, relation.relation.Name));
                    }
                }
                //handle the assign to scenario by shivam            
                for(String eId : eventMap.keySet()){
                    if(!eventRelationMap.containsKey(eId)) {
                        eventRelationMap.put(eId, new List<UserWrapper>());
                    }
                    Id relationId = (Id)eventMap.get(eId).ownerId;
                    if(String.valueOf(relationId.getSobjectType()) == 'User') {
                        if(!handleAssignTo.contains(relationId)){
                            eventRelationMap.get(eId).add(new UserWrapper(eventMap.get(eId).ownerId,''));
                        }
                        handleAssignTo.add(relationId);
                    }
                }//end Shivam
                
                for(String evtId : eventRelationMap.keySet()) {
                    DateTime dt = eventMap.get(evtId).StartDateTime;
                    Date d =  date.newinstance(dT.year(), dT.month(), dT.day());
                    if(d <= System.today() && eventMap.get(evtId).endDateTime > system.Now() ){//changed by shivam bug #00035286
                        EventWrapper evtWrap = new EventWrapper();
                        evtWrap.evtId = evtId;
                        evtWrap.ownerId = eventMap.get(evtId).OwnerId;
                        evtWrap.Subject = eventMap.get(evtId).Subject;
                        evtWrap.evtStartTime = String.valueOf(System.today());
                        evtWrap.userData = eventRelationMap.get(evtId);
                        String completeJSONStruct = JSON.serialize(evtWrap);
                        eventStartNotifications.add(new navpeII_dev18__Event_Reminder__e(navpeII_dev18__Event_Reminder_Data__c = completeJSONStruct));
                    }
                } 
                
            }
            List<Database.SaveResult> results = EventBus.publish(eventStartNotifications);
        }catch(Exception e){
            system.debug('Exception in callFlowApexAction:: '+e.getMessage());
        }
        
    }
    
    public class FlowInputParams {
        @InvocableVariable
        public List<Event> eventRecords;
    }
    
    private class EventWrapper {
        private String evtId{get;set;}
        private String evtStartTime{get;set;}
        private String Subject{get;Set;}
        private String ownerId{get;set;}
        private List<UserWrapper> userData{get;set;}
    }
    
    private class UserWrapper {
        private String userId{get;set;}
        private String userName{get;set;}
        public UserWrapper(String userId, String userName) {
            this.userId = userId;
            this.userName = userName;
        }
    }
    
}