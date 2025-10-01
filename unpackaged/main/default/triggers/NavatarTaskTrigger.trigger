/*
* --------------------------------------------------------------------------------------------------
* To calculate the Last Touch point from task based activity date field and update
* Last Touch Point date Contact and Last Touch Point Id.
* Last Touch Point date Deal and Fundraising
* --------------------------------------------------------------------------------------------------
* @author         Raghvendra Jha
* @modifiedBy     Raghvendra Jha
* @modifiedBy     Priyank Kumar , Anmol
* @modifiedBy     Deepak Singh
* @version        1.0
* @version        2.0
* @created        2019-11-26
* @modified       2019-11-27
* @modified       2019-11-21
* @modified       2024-03-23
*/
trigger NavatarTaskTrigger on Task (after insert, after update, before delete, after undelete){
    try{
    if(!system.isFuture() && trigger.isBefore && trigger.isDelete){
            Set<Id> conIdsSet=new Set<Id>();
            Set<Id> taskIdsSet=new Set<Id>();
            Set<Id> notesTaskIdsSet=new Set<Id>();
            for(task t:Trigger.old){
                notesTaskIdsSet.add(t.Id);
                if(t.navpeII_dev18__Is_Touchpoint_New__c){
                taskIdsSet.add(t.Id);
                conIdsSet.add(t.WhoId);
            }
            }
        if(Schema.getGlobalDescribe().get('taskRelation') != null){
                        List<Sobject> taskRelationList = new List<Sobject>();
                    taskRelationList = Database.query('Select Id, RelationId from taskRelation where taskId IN: taskIdsSet');
            for(Sobject tr: taskRelationList){
                if(String.valueOf(tr.get('RelationId')).startsWith('003'))
                    conIdsSet.add(String.valueof(tr.get('RelationId')));
            }
            }
            NavatarTaskEventRelationHandler.onDeleteActivity('TaskRelation',taskIdsSet,conIdsSet);   
            NavatarTaskEventRelationHandler.deleteRichTextField(notesTaskIdsSet);   // Added By Sudhanshu
        }
    if(!system.isFuture() && trigger.isAfter && (trigger.isUpdate || trigger.isUndelete)){
        //List<Id> tRelIdsList=new List<Id>();
            Set<Id> taskIdsSet=new Set<Id>();
            for(task t:Trigger.new){
                if(!trigger.isUndelete){
                    Task oldtsk=Trigger.oldMap.get(t.Id);
                    if(NavatarTaskEventRelationHandler.taskEventchk){
                        //Added above if check & below variable assignment by LK on 2024-06-06 to fix 00045431
                        NavatarTaskEventRelationHandler.taskEventchk = false;
                        //Removed "t.ActivityDate != oldtsk.ActivityDate &&" by LK on 2024-06-06 to fix 00045431
                        if(t.navpeII_dev18__Is_Touchpoint_New__c || (t.navpeII_dev18__Is_Touchpoint_New__c != oldtsk.navpeII_dev18__Is_Touchpoint_New__c)){
                            taskIdsSet.add(t.Id);
                        }
                    }
                }
                else if(t.navpeII_dev18__Is_Touchpoint_New__c){
                    taskIdsSet.add(t.Id);
                }
            }
            List<Id> tRelIdsList=new List<Id>();
        if(Schema.getGlobalDescribe().get('taskRelation') != null){
                        List<Sobject> taskRelationList = new List<Sobject>();
            taskRelationList = Database.query('Select Id, RelationId from taskRelation where taskId IN: taskIdsSet');
            for(Sobject tr: taskRelationList){
                if(!tRelIdsList.contains(String.valueof(tr.get('Id'))))
                    tRelIdsList.add(String.valueof(tr.get('Id')));
            }
            }
            if(tRelIdsList.size() > 0){
                NavatarTaskEventRelationHandler.onInsrtUpdteActivity(tRelIdsList);
            }
    }

    if(!system.isFuture() && trigger.isAfter && (trigger.isInsert || trigger.isUpdate || trigger.isUndelete)){
        Set<String> taskIdsSet=new Set<String>();
        for(task t:Trigger.new){
                if(t.navpeII_dev18__Related_Associations__c != ''){//Bug - 45712fix
                    taskIdsSet.add(t.Id);
                }
        }
        if(NavatarTaskEventRelationHandler.recursionchk){
            NavatarTaskEventRelationHandler.recursionchk = false;
            if(taskIdsSet.size() > 0){
                NavatarTaskEventRelationHandler.onInsrtUpdteRelatedAssociation(new List<String>(taskIdsSet));
            }
        }
    }
}catch(Exception e){}
    if(Trigger.isAfter && !system.isFuture()){
        //TaskTriggerHandler.OnAfterInsUpdDel(Trigger.New,Trigger.oldMap);
        //NavatarTaskTriggerHandler.OnAfterInsUpdDel(Trigger.New,Trigger.oldMap);
        NavatarTaskTriggerHandler.OnAfterInsUpdDelNew(Trigger.New,Trigger.oldMap);
    }
    else{
        if(!system.isFuture()){
            //TaskTriggerHandler.OnAfterInsUpdDel(Trigger.Old,Trigger.oldMap);
            //NavatarTaskTriggerHandler.OnAfterInsUpdDel(Trigger.Old,Trigger.oldMap);
            NavatarTaskTriggerHandler.OnAfterInsUpdDelNew(Trigger.old,Trigger.oldMap);
            
        }
        
    }
}