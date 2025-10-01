/****************************************************************************************************
** Module Name : Acuity 2.0 - Quick Deal Creation
** Description : 
** Throws : NA
** Calls : NA
** Organization : Navatar Group
** Product Name & Version : Acuity 2.0
** Revision History:-
** Version    Date(YYYY-MM-DD)    Author         Description of Action
** 1.0        2022-11-21         Virendra Kumar
****************************************************************************************************/
public with sharing class NavatarCreateMenuDealCtrl{
    //Get contacts for the related account
    public static List<Task> completeTaskList = new List<Task>();
    public static List<Event> completeEventList = new List<Event>();
    @AuraEnabled
    public static List<Contact> getRelatedContacts(string accId) {
        return [SELECT Id, AccountId, Name, CreatedDate FROM Contact WHERE AccountId =: accId Order By CreatedDate DESC];        
    }
    
    //clone record from Account to Deal
    @AuraEnabled
    public static List<String>  cloneChildRecords(string dealId , string accId, Boolean isCheckedInteraction, Boolean isCheckedClip){
        try{
            navpeII_dev18__Pipeline__c deal = [SELECT Id, import_Status__c FROM navpeII_dev18__Pipeline__c WHERE Id =: dealId];
            
            String importStatus = deal.import_Status__c != null? deal.import_Status__c : '';

            //Variable to Store Themes Relation and Clip Relation
            List<String> activityNameList = new List<String>();
            List<Clip_Relation__c>  clipRelations = new List<Clip_Relation__c>();
            List<Clip_Relation__c> clipRelationsToBeCloned = new List<Clip_Relation__c>();
            List<Task> tasksToBeUpdate = new List<Task>();
            List<Event> eventsToBeUpdate = new List<Event>();
            Map<Id, String> activitiesMap = new Map<Id, String>();
            String namespacePrefix = getNamespacePrefix() + '__';
            List<Task> taskList = new List<Task>();
            List<Event> eventList = new List<Event>();
            Set<String> eventIdSet = new Set<String>();
            Set<String> taskIdSet = new Set<String>();
            
            if(isCheckedClip) {
                //child query based on firm Id
                for(Clip_Relation__c clip : [SELECT Id, Name,  Deal__c, Account__c, Clip__c FROM Clip_Relation__c WHERE Account__c =: accId]){
                    Clip_Relation__c clientRelation = clip.clone(false,true);
                    if(Schema.sObjectType.Clip_Relation__c.fields.Deal__c.isCreateable()) {
                        clientRelation.Deal__c = dealId;
                    }
                    if(Schema.sObjectType.Clip_Relation__c.fields.Account__c.isCreateable()) {
                        clientRelation.Account__c = null;
                    }
                    clipRelationsToBeCloned.add(clientRelation);
                }
            }            
            if(isCheckedInteraction) {
                String recordId = accId;
                accId = '%'+accId+'%';
                Set<String> conIdSet = new Set<String>();
                conIdSet.addAll(fetchInitInfoToProcess('Id', 'Contact', ' WHERE AccountId = :recordId', recordId));
                //For handling events 46093 Bug Fix by Manonit
                eventIdSet = fetchActRecsToProcess(conIdSet, 'Event', ' WHERE (Event.IsChild = false) AND (Relation.Type = \'Contact\') AND ((RelationId IN :conIdSet) OR (Event.' + namespacePrefix + 'Related_Associations__c LIKE \'%' + String.escapeSingleQuotes(recordId) + '%\'))');
                if(eventIdSet.size() > 0){
                    eventList = [Select Id,subject,navpeII_dev18__Related_Associations__c From Event where Id IN: eventIdSet Limit :getDynamicQueryLimit()] ;
                }
                if(eventList.size() > 0){
                    completeEventList.addAll(eventList);
                }
                prepareAssoActSet('Event', '(' + namespacePrefix + 'Related_Associations__c LIKE \'%' + recordId + '%\')', namespacePrefix);    //For covering the scenario : Empty Name & Accounts in AA field
                //For handling tasks
                if(Schema.getGlobalDescribe().get('TaskRelation') != null){
                    // 46488 Bug Fix By Manonit
                    taskIdSet = fetchActRecsToProcess(conIdSet, 'Task', ' WHERE (Relation.Type = \'Contact\') AND (Task.TaskSubtype != \'ListEmail\') AND ((RelationId IN :conIdSet) OR (Task.' + namespacePrefix + 'Related_Associations__c LIKE \'%' + String.escapeSingleQuotes(recordId) + '%\'))');
                    if(taskIdSet.size() > 0){
                          taskList = [Select Id,subject,navpeII_dev18__Related_Associations__c From Task where Id IN: taskIdSet Limit :getDynamicQueryLimit()];
                     }
                    if(taskList.size() > 0){
                        completeTaskList.addAll(taskList);
                    }
                    prepareAssoActSet('Task', '(' + namespacePrefix + 'Related_Associations__c LIKE \'%' + recordId + '%\' )', namespacePrefix);    //For covering the scenario : Empty Name & Accounts in AA field    
                }
                 List<Task> existingTasks = new List<Task>();
                List<Event> existingEvents = new List<Event>();
                Set<Task> taskSet = new Set<Task>(completeTaskList); // To Avoid Duplicacy
                Set<Event> eventSet = new Set<Event>(completeEventList); // To Avoid Duplicacy
                
                
                existingTasks.addAll(taskSet);
                existingEvents.addAll(eventSet);
               
                
                /* List<Task> existingTasks = [SELECT Id,Subject, WhatId, Related_Associations__c, navpeII_dev18__Watchlist__c  FROM Task WHERE Related_Associations__c LIKE :accId];
                List<Event> existingEvents = [SELECT Id, WhoId, WhatId, Subject, navpeII_dev18__Watchlist__c, Related_Associations__c
                                               FROM Event WHERE Related_Associations__c LIKE :accId];*/
                //Update related associate on Task
                for(Task task : existingTasks){
                    activitiesMap.put(task.Id, task.Subject);
                    Task taskToUpdate = new Task();
                    taskToUpdate.Id = task.Id;
                    taskToUpdate.Related_Associations__c = task.Related_Associations__c != null ? task.Related_Associations__c +','+dealId : dealId;
                    tasksToBeUpdate.add(taskToUpdate);
                }
                //Update related associate on Event
                for(Event event : existingEvents){
                    activitiesMap.put(event.Id, event.Subject);
                    Event eventToUpdate = new Event();
                    eventToUpdate.Id = event.Id;
                    eventToUpdate.Related_Associations__c = event.Related_Associations__c != null ? event.Related_Associations__c +','+dealId : dealId;
                    eventsToBeUpdate.add(eventToUpdate);
                }
                if(!tasksToBeUpdate.isEmpty()){
                    // calling separate method to update the records 
                    updateActivitiesRecords(tasksToBeUpdate, activityNameList, activitiesMap);
                    importStatus = importStatus.contains('All Interaction') ? importStatus + '' : importStatus+'All Interaction:true,';
                }

                if(!eventsToBeUpdate.isEmpty()){
                    // calling separate method to update the records 
                    updateActivitiesRecords(eventsToBeUpdate, activityNameList, activitiesMap); 
                    importStatus = importStatus.contains('All Interaction') ? importStatus + '' : importStatus+'All Interaction:true,';
                }
            }
            
            if(!clipRelationsToBeCloned.isEmpty() && Schema.sObjectType.Clip_Relation__c.isCreateable()){
                insert clipRelationsToBeCloned;
                importStatus = importStatus.contains('All Clips') ? importStatus + '' : importStatus + 'All Clips:true,';
            }
            //Update related status on Deal
            if(String.isNotBlank(importStatus)) {
                navpeII_dev18__Pipeline__c dealToUpdate = new navpeII_dev18__Pipeline__c();
                dealToUpdate.Id = dealId;
                if(Schema.sObjectType.navpeII_dev18__Pipeline__c.fields.import_Status__c.isUpdateable()) {
                    dealToUpdate.import_Status__c = importStatus;
                }               
                if(Schema.sObjectType.navpeII_dev18__Pipeline__c.isUpdateable()) {
                    Update dealToUpdate;
                }                
            }
            return activityNameList;
        }
        catch(Exception e) {
            throw new AuraHandledException('Error Occured While Loading Component : <<' + e.getStackTraceString() + '>>');
        }
    } 

    //Update Activity records and track error if any
    public static List<String> updateActivitiesRecords( List<Sobject> sObjectList, List<String> activityNameList, Map<Id, String> activitiesMap){
        List<Database.SaveResult> updateResults = Database.update(sObjectList, false);
        for(Integer i=0;i<updateResults.size();i++){
            if (updateResults.get(i).isSuccess()){
                updateResults.get(i).getId();
                
            }else if (!updateResults.get(i).isSuccess()){
                Database.Error error = updateResults.get(i).getErrors().get(0);
                String failedDML = error.getMessage();
                //activityNameList.add(activitiesMap.get(sObjectList.get(i).Id));//failed record from the list
                activityNameList.add(sObjectList.get(i).Id);//failed record from the list
            }
        }
        return activityNameList;
    }
    

    //Method to check if related childs to clone are there.
    @AuraEnabled
    public static String getCloneConfirmation(string accId) {        
        Map<String , Boolean> confirmationForClone = new Map<String , Boolean>();        
        confirmationForClone.put('isThemeExist', false);
        confirmationForClone.put('isInteractionExist', false);
        confirmationForClone.put('isClipExist', false);
        for(Clip_Relation__c clipRelation : [SELECT Id, Name,  Deal__c, Account__c FROM Clip_Relation__c WHERE Account__c =: accId]) {
            confirmationForClone.put('isClipExist', true);
        }
      /*  accId = '%'+accId+'%';
        List<Task> existingTasks = [SELECT Id FROM Task WHERE Related_Associations__c LIKE :accId LIMIT 50000];
        List<Event> existingEvents = [SELECT Id FROM Event WHERE Related_Associations__c LIKE :accId LIMIT 50000];
        46489 Bug Fix By Manonit*/
       List<Event> eventList = new List<Event>();
       List<Task> taskList = new List<Task>();
       Set<String> eventIdSet = new Set<String>();
       Set<String> taskIdSet = new Set<String>();
       String namespacePrefix = 'navpeII_dev18__';
       String recordId = accId;
                accId = '%'+accId+'%';
                Set<String> conIdSet = new Set<String>();
                conIdSet.addAll(fetchInitInfoToProcess('Id', 'Contact', ' WHERE AccountId = :recordId', recordId));
                //For handling events 46093 Bug Fix by Manonit
                eventIdSet = fetchActRecsToProcess(conIdSet, 'Event', ' WHERE (Event.IsChild = false) AND (Relation.Type = \'Contact\') AND ((RelationId IN :conIdSet) OR (Event.' + namespacePrefix + 'Related_Associations__c LIKE \'%' + String.escapeSingleQuotes(recordId) + '%\'))');
                if(eventIdSet.size() > 0){
                    eventList = [Select Id,subject,navpeII_dev18__Related_Associations__c From Event where Id IN: eventIdSet Limit :getDynamicQueryLimit()] ;
                }
                if(eventList.size() > 0){
                    completeEventList.addAll(eventList);
                }
                prepareAssoActSet('Event', '(' + namespacePrefix + 'Related_Associations__c LIKE \'%' + recordId + '%\')', namespacePrefix);    //For covering the scenario : Empty Name & Accounts in AA field
                //For handling tasks
                if(Schema.getGlobalDescribe().get('TaskRelation') != null){
                     // 46488 Bug Fix By Manonit
                    taskIdSet = fetchActRecsToProcess(conIdSet, 'Task', ' WHERE (Relation.Type = \'Contact\') AND (Task.TaskSubtype != \'ListEmail\') AND ((RelationId IN :conIdSet) OR (Task.' + namespacePrefix + 'Related_Associations__c LIKE \'%' + String.escapeSingleQuotes(recordId) + '%\'))');
                    if(taskIdSet.size() > 0){
                          taskList = [Select Id,subject,navpeII_dev18__Related_Associations__c From Task where Id IN: taskIdSet Limit :getDynamicQueryLimit()];
                     }
                    if(taskList.size() > 0){
                        completeTaskList.addAll(taskList);
                    }
                    prepareAssoActSet('Task', '(' + namespacePrefix + 'Related_Associations__c LIKE \'%' + recordId + '%\' )', namespacePrefix);    //For covering the scenario : Empty Name & Accounts in AA field    
                }



        if(!completeTaskList.isEmpty() || !completeEventList.isEmpty()) {
            confirmationForClone.put('isInteractionExist', true);
        }
        completeTaskList.clear();
        completeEventList.clear();
        return JSON.serialize(confirmationForClone);
        
    }
    //Insert Deal Team based on selection of contacts from Firm.
    @AuraEnabled
    public static List<navpeII_dev18__Deal_Team__c> cloneSelectedContacts( String dealId , String cloneIds){
        try{
            List<DealWrapper> dealMembers = (List<DealWrapper>)JSON.deserialize(cloneIds, List<DealWrapper>.class);
            List<navpeII_dev18__Deal_Team__c> dealTeamToBeInserted = new  List<navpeII_dev18__Deal_Team__c>();
            
            for(DealWrapper dealTMember : dealMembers){
                navpeII_dev18__Deal_Team__c dealteam = new navpeII_dev18__Deal_Team__c();
                if(Schema.sObjectType.navpeII_dev18__Deal_Team__c.fields.navpeII_dev18__Deal_Contact__c.isCreateable()) {
                    dealteam.navpeII_dev18__Deal_Contact__c = dealTMember.id;
                }
                if(Schema.sObjectType.navpeII_dev18__Deal_Team__c.fields.navpeII_dev18__Team_Member_Role__c.isCreateable()) {
                    dealteam.navpeII_dev18__Team_Member_Role__c = dealTMember.role;
                }
                if(Schema.sObjectType.navpeII_dev18__Deal_Team__c.fields.navpeII_dev18__Deal__c.isCreateable()) {
                    dealteam.navpeII_dev18__Deal__c = dealId;  
                }
                
                dealTeamToBeInserted.add(dealteam);                    
            }

            if(!dealTeamToBeInserted.isempty() && Schema.sObjectType.navpeII_dev18__Deal_Team__c.isCreateable()){            
                insert dealTeamToBeInserted;
            }

            return [SELECT Id, Name FROM navpeII_dev18__Deal_Team__c WHERE Id =: dealTeamToBeInserted];
        }
        catch(Exception e) {
            throw new AuraHandledException('Error Occured While Loading Component : <<' + e.getStackTraceString() + '>>');
        }
    } 

    /*--------------------------------------------Interaction Fix Start By Manonit  Bug id - 00046093-----------------------------------------*/
    /*
     * Purpose : Finds activity records to be processed
     * Input : conIdSet     [Set of related records of the main object to be processed]
     *         actObjName   [Activity type (Task/Event)]
     *         whereClause  [Where clause to be used in the SOQL query]
     * Returns : Se<String> containing activity IDs to be processed
     */
    private static Set<String> fetchActRecsToProcess(Set<String> conIdSet, String actObjName, String whereClause){
        try {
            Set<String> actIdSet = new Set<String>();
            for(sObject actRec : Database.query('SELECT ' + actObjName + 'Id FROM ' + actObjName + 'Relation' + whereClause + ' AND IsDeleted = false ORDER BY CreatedDate DESC ' + getQueryLimit() + ' ALL ROWS')){
                actIdSet.add(String.valueOf(actRec.get(actObjName + 'Id')));
            }
            return actIdSet;
        } catch (Exception e) {
            throw new AuraHandledException(' : <<' + e.getStackTraceString() + '>>');
        }
    }

        /*
     * Purpose : Processes the activity records
     * Input : actObjName       [Activity type (Task/Event)]
     *         relAssoClause    [Related Association clause to be used in the query]
     *         namespacePrefix  [Namespaceprefix to be used]
     * Returns : N/A
     */
    private static void prepareAssoActSet(String actObjName, String relAssoClause, String namespacePrefix){
        try {
            //Added IsChild = false check on 2022-10-07 to consider only the main copy of the event record
             if(actObjName == 'Event'){
                List<Event> evtList = Database.query('SELECT Id, Subject,' + namespacePrefix + 'Related_Associations__c FROM ' + actObjName + ' WHERE ' + relAssoClause + (actObjName.equalsIgnoreCase('Event') ? ' AND IsChild = false' : '') + ' AND IsDeleted = false ORDER BY CreatedDate DESC ' + getQueryLimit() + ' ALL ROWS');
                   completeEventList.addAll(evtList);
            }else if(actObjName == 'Task'){
               List<Task> tskList = Database.query('SELECT Id,Subject, ' + namespacePrefix + 'Related_Associations__c FROM ' + actObjName + ' WHERE ' + relAssoClause + (actObjName.equalsIgnoreCase('Event') ? ' AND IsChild = false' : '') + ' AND IsDeleted = false ORDER BY CreatedDate DESC ' + getQueryLimit() + ' ALL ROWS');
               completeTaskList.addAll(tskList);
            }

        } catch(Exception e) {
            throw new AuraHandledException(' : <<' + e.getStackTraceString() + '>>');
        }
    }

     /*
     * Purpose : Fetches query limit
     * Returns : String containing remaining query limit
     */
    private static String getQueryLimit(){
        try{
            return ' LIMIT ' + (Limits.getLimitQueryRows() - Limits.getQueryRows() - 1);
        } catch (Exception e) {
            throw new AuraHandledException(' : <<' + e.getStackTraceString() + '>>');
        }
    }

    /*
     * Purpose : Fetches initial data to be used for further processing
     * Input : fieldApiName        [Field whose map is to be created]
     *         objApiName          [Object to query data from]
     *         whereClause         [Where clause to be used in the SOQL query]
     *         recordId            [Record ID of the current record (Account/Contact)]
     * Returns : Set<String> containing initial data to be used for further processing
     */
    private static Set<String> fetchInitInfoToProcess(String fieldApiName, String objApiName, String whereClause, String recordId){
        try {
            Set<String> recIdSet = new Set<String>();
            if(Schema.getGlobalDescribe().get(objApiName).getDescribe().isAccessible()){
                for(sObject objRec : Database.query('SELECT ' + fieldApiName + ' FROM ' + String.escapeSingleQuotes(objApiName) + String.escapeSingleQuotes(whereClause) + getQueryLimit())){
                    String recId = String.valueOf(objRec.get(fieldApiName));
                    if(String.isNotBlank(recId)){
                        recIdSet.add(recId);
                    }
                }
                return recIdSet;
            } else {
                return new Set<String>();
            }
        } catch (Exception e) {
            throw new AuraHandledException( + ' : <<' + e.getStackTraceString() + '>>');
        }    
    }

    /*
     * Purpose : Wrapper for page load information
     */
    public class ResponseWrapperAct{
        @AuraEnabled public List<Event> alleventList; //Namespaceprefix to be used
        @AuraEnabled public List<Task> alltaskList; //Associated activity ID list
    }
    /* Purpose : Fetches namespace prefix
* Returns : Namespaceprefix to be used as a String
*/
    public static String getNamespacePrefix(){
        try{
            return [SELECT NamespacePrefix FROM ApexClass WHERE Name = 'FileUploaderCtrl'].NamespacePrefix;
        } catch (Exception e) {
            throw new AuraHandledException('Error Occured While Loading Component : <<' + e.getStackTraceString() + '>>');
        }
    }

   /*
     * Purpose : Fetches query limit
     * Returns : String containing remaining query limit
     */
    private static Integer getDynamicQueryLimit(){
        try{
            return  (Limits.getLimitQueryRows() - Limits.getQueryRows() - 1);
        } catch (Exception e) {
            throw new AuraHandledException(' : <<' + e.getStackTraceString() + '>>');
        }
    }






    /*--------------------------------------------Interaction Fix End-------------------------------------------*/   
    
    public class DealWrapper{
        @AuraEnabled
        public String id;
        @AuraEnabled
        public String role;
    }
    
}