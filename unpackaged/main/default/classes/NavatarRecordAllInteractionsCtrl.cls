/****************************************************************************************************
** Module Name : Acuity Phase 3 - Interactions Link
** Description : Used to handle all the DML & schema related funtionalities of Interactions link.
** Throws : NA
** Calls : NA
** Organization : Navatar Group
** Product Name & Version : PE v5.3
** Revision History:-
** Version    Date(YYYY-MM-DD)    Author         Description of Action
** 1.0        2024-04-10          Lakshya        Acuity Phase 3 - CR
****************************************************************************************************/

public with sharing class NavatarRecordAllInteractionsCtrl {
    //Stores the generic error message
    private final static String ERR_MSG = 'Error Occured While Loading Component';
    //Stores the unique activity IDs
    private static Set<String> completeActIdsSet = new Set<String>();
    //Stores the allowed CPU time for processing the data on page load
    private static Integer ALLOWED_CPU_TIME = 9000;

    /*
     * Purpose : Processes the page load info to be displayed
     * Input : recordId     [Record ID of the current record (Account/Contact/Deal/Fund/Fundraising/Theme)]
     * Returns : ResponseWrapper containing info to be shared on page load
     */
    @AuraEnabled
    public static ResponseWrapper handleOnLoadInfo(Id recordId){
        try {
            ResponseWrapper respWrapper = new ResponseWrapper();
            respWrapper.namespacePrefix = getNamespacePrefix();
            respWrapper.actIdList = fetchAssoActIdList(recordId, String.valueOf(recordId.getSobjectType()), respWrapper.namespacePrefix);
            return respWrapper;
        } catch(Exception e) {
            throw new AuraHandledException(ERR_MSG + ' : <<' + e.getStackTraceString() + '>>');
        }
    }

    /*
     * Purpose : Handles the fetching of associated activity IDs
     * Input : recordId         [Record ID of the current record (Account/Contact/Deal/Fund/Fundraising/Theme)]
     *         objectApiName    [API name of the current record (Account/Contact/Deal/Fund/Fundraising/Theme)]
     *         namespacePrefix  [Namespaceprefix to be used]
     * Returns : List<String> containing associated activity ID list
     */
    private static List<String> fetchAssoActIdList(String recordId, String objectApiName, String namespacePrefix){
        try{
            if(String.escapeSingleQuotes(objectApiName).equalsIgnoreCase('Account')){
                Set<String> conIdSet = new Set<String>();
                conIdSet.addAll(fetchInitInfoToProcess('Id', 'Contact', ' WHERE AccountId = :recordId', recordId));
                
                Set<String> actIdSet = new Set<String>();
                //For handling events
                actIdSet = fetchActRecsToProcess(conIdSet, 'Event', ' WHERE (Event.IsChild = false) AND (Relation.Type = \'Contact\') AND ((RelationId IN :conIdSet) OR (Event.' + namespacePrefix + 'Related_Associations__c LIKE \'%' + String.escapeSingleQuotes(recordId) + '%\'))');
                //prepareAssoActSet('Event', actIdSet, ' WHERE (EventId IN :actIdSet)', conIdSet, recordId, objectApiName, namespacePrefix);
                if(actIdSet.size() > 0){
                    completeActIdsSet.addAll(actIdSet);
                }
                prepareAssoActSet('Event', '(' + namespacePrefix + 'Related_Associations__c LIKE \'%' + recordId + '%\')', namespacePrefix);    //For covering the scenario : Empty Name & Accounts in AA field
                //For handling tasks
                if(Schema.getGlobalDescribe().get('TaskRelation') != null){
                    actIdSet = fetchActRecsToProcess(conIdSet, 'Task', ' WHERE (Relation.Type = \'Contact\') AND ((RelationId IN :conIdSet) OR (Task.' + namespacePrefix + 'Related_Associations__c LIKE \'%' + String.escapeSingleQuotes(recordId) + '%\'))');
                    //prepareAssoActSet('Task', actIdSet, ' WHERE (TaskId IN :actIdSet)', conIdSet, recordId, objectApiName, namespacePrefix);
                    if(actIdSet.size() > 0){
                        completeActIdsSet.addAll(actIdSet);
                    }
                    prepareAssoActSet('Task', '(' + namespacePrefix + 'Related_Associations__c LIKE \'%' + recordId + '%\')', namespacePrefix);    //For covering the scenario : Empty Name & Accounts in AA field    
                }
            } else if(String.escapeSingleQuotes(objectApiName).equalsIgnoreCase('Contact')){
                Set<String> actIdSet = new Set<String>();
                //For handling events
                actIdSet = fetchActRecsToProcess(recordId, 'Event', ' WHERE (Event.IsChild = false) AND (RelationId = :recordId)');
                // prepareAssoActSet('Event', actIdSet, ' WHERE (EventId IN :actIdSet)', null, recordId, objectApiName, namespacePrefix);
                if(actIdSet.size() > 0){
                    completeActIdsSet.addAll(actIdSet);
                }
                //For handling tasks
                if(Schema.getGlobalDescribe().get('TaskRelation') != null){
                    actIdSet = fetchActRecsToProcess(recordId, 'Task', ' WHERE (RelationId = :recordId)');
                    // prepareAssoActSet('Task', actIdSet, ' WHERE (TaskId IN :actIdSet)', null, recordId, objectApiName, namespacePrefix);
                    if(actIdSet.size() > 0){
                        completeActIdsSet.addAll(actIdSet);
                    }
                }
            } else if(String.escapeSingleQuotes(objectApiName).equalsIgnoreCase(namespacePrefix + 'Pipeline__c') || String.escapeSingleQuotes(objectApiName).equalsIgnoreCase(namespacePrefix + 'Theme__c')){
                Set<String> actIdSet = new Set<String>();
                //For handling events
                actIdSet = fetchActRecsToProcess('', 'Event', ' WHERE (Event.IsChild = false) AND (Relation.Type = \'Contact\') AND (Event.' + namespacePrefix + 'Related_Associations__c LIKE \'%' + String.escapeSingleQuotes(recordId) + '%\')');
                // prepareAssoActSet('Event', actIdSet, ' WHERE (EventId IN :actIdSet)', null, recordId, objectApiName, namespacePrefix);
                if(actIdSet.size() > 0){
                    completeActIdsSet.addAll(actIdSet);
                }
                prepareAssoActSet('Event', '(' + namespacePrefix + 'Related_Associations__c LIKE \'%' + String.escapeSingleQuotes(recordId) + '%\')', namespacePrefix);    //For covering the scenario : Empty Name & Accounts in AA field
                //For handling tasks
                if(Schema.getGlobalDescribe().get('TaskRelation') != null){
                    actIdSet = fetchActRecsToProcess('', 'Task', ' WHERE (Relation.Type = \'Contact\') AND (Task.' + namespacePrefix + 'Related_Associations__c LIKE \'%' + String.escapeSingleQuotes(recordId) + '%\')');
                    // prepareAssoActSet('Task', actIdSet, ' WHERE (TaskId IN :actIdSet)', null, recordId, objectApiName, namespacePrefix);
                    if(actIdSet.size() > 0){
                        completeActIdsSet.addAll(actIdSet);
                    }
                    prepareAssoActSet('Task', '(' + namespacePrefix + 'Related_Associations__c LIKE \'%' + String.escapeSingleQuotes(recordId) + '%\')', namespacePrefix);     //For covering the scenario : Empty Name & Accounts in AA field
                }
            } else if(String.escapeSingleQuotes(objectApiName).equalsIgnoreCase(namespacePrefix + 'Fund__c')){
                Set<String> fdrIdSet = new Set<String>();
                fdrIdSet.addAll(fetchInitInfoToProcess('Id', namespacePrefix + 'Fundraising__c', ' WHERE ' + namespacePrefix + 'Fund_Name__c = :recordId', recordId));

                String fdrWhereClauseStrEvent = '(Event.' + namespacePrefix + 'Related_Associations__c LIKE \'%' + String.escapeSingleQuotes(recordId) + '%\')';
                String fdrWhereClauseStrTask = '(Task.' + namespacePrefix + 'Related_Associations__c LIKE \'%' + String.escapeSingleQuotes(recordId) + '%\')';
                for(String fdrRecId : fdrIdSet){
                    fdrWhereClauseStrEvent += ' OR (Event.' + namespacePrefix + 'Related_Associations__c LIKE \'%' + String.escapeSingleQuotes(fdrRecId) + '%\')';
                    fdrWhereClauseStrTask += ' OR (Task.' + namespacePrefix + 'Related_Associations__c LIKE \'%' + String.escapeSingleQuotes(fdrRecId) + '%\')';
                }
                Set<String> actIdSet = new Set<String>();
                //For handling events
                actIdSet = fetchActRecsToProcess('', 'Event', ' WHERE (Event.IsChild = false) AND (Relation.Type = \'Contact\') AND (' + fdrWhereClauseStrEvent + ')');
                // prepareAssoActSet('Event', actIdSet, ' WHERE (EventId IN :actIdSet)', null, recordId, objectApiName, namespacePrefix);
                if(actIdSet.size() > 0){
                    completeActIdsSet.addAll(actIdSet);
                }
                prepareAssoActSet('Event', '(' + fdrWhereClauseStrEvent + ')', namespacePrefix);    //For covering the scenario : Empty Name & Accounts in AA field
                //For handling tasks
                if(Schema.getGlobalDescribe().get('TaskRelation') != null){
                    actIdSet = fetchActRecsToProcess(fdrIdSet, 'Task', ' WHERE (Relation.Type = \'Contact\') AND (' + fdrWhereClauseStrTask + ')');
                    // prepareAssoActSet('Task', actIdSet, ' WHERE (TaskId IN :actIdSet)', null, recordId, objectApiName, namespacePrefix);
                    if(actIdSet.size() > 0){
                        completeActIdsSet.addAll(actIdSet);
                    }
                    prepareAssoActSet('Task', '(' + fdrWhereClauseStrTask + ')', namespacePrefix);    //For covering the scenario : Empty Name & Accounts in AA field    
                }
            } else if(String.escapeSingleQuotes(objectApiName).equalsIgnoreCase(namespacePrefix + 'Fundraising__c')){
                Set<String> conIdSet = new Set<String>();
                conIdSet.addAll(fetchInitInfoToProcess(namespacePrefix + 'Contact__c', namespacePrefix + 'Fundraising_Contact__c', ' WHERE ' + namespacePrefix + 'Fundraising__c = :recordId', recordId));
                
                Set<String> actIdSet = new Set<String>();
                //For handling events
                actIdSet = fetchActRecsToProcess(conIdSet, 'Event', ' WHERE (Event.IsChild = false) AND (Relation.Type = \'Contact\') AND ((RelationId IN :conIdSet) OR (Event.' + namespacePrefix + 'Related_Associations__c LIKE \'%' + String.escapeSingleQuotes(recordId) + '%\'))');
                // prepareAssoActSet('Event', actIdSet, ' WHERE (EventId IN :actIdSet)', conIdSet, recordId, objectApiName, namespacePrefix);
                if(actIdSet.size() > 0){
                    completeActIdsSet.addAll(actIdSet);
                }
                prepareAssoActSet('Event', '(' + namespacePrefix + 'Related_Associations__c LIKE \'%' + recordId + '%\')', namespacePrefix);    //For covering the scenario : Empty Name & Accounts in AA field
                //For handling tasks
                if(Schema.getGlobalDescribe().get('TaskRelation') != null){
                    actIdSet = fetchActRecsToProcess(conIdSet, 'Task', ' WHERE (Relation.Type = \'Contact\') AND ((RelationId IN :conIdSet) OR (Task.' + namespacePrefix + 'Related_Associations__c LIKE \'%' + String.escapeSingleQuotes(recordId) + '%\'))');
                    // prepareAssoActSet('Task', actIdSet, ' WHERE (TaskId IN :actIdSet)', conIdSet, recordId, objectApiName, namespacePrefix);
                    if(actIdSet.size() > 0){
                        completeActIdsSet.addAll(actIdSet);
                    }
                    prepareAssoActSet('Task', '(' + namespacePrefix + 'Related_Associations__c LIKE \'%' + recordId + '%\')', namespacePrefix);    //For covering the scenario : Empty Name & Accounts in AA field    
                }
            }
            List<String> actIdsList = new List<String>();
            if(completeActIdsSet.size() > 0){
                actIdsList.addAll(completeActIdsSet);
                completeActIdsSet.clear();
                return actIdsList;
            } else {
                return null;
            }
        } catch (Exception e) {
            throw new AuraHandledException(ERR_MSG + ' : <<' + e.getStackTraceString() + '>>');
        }
    }

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
            throw new AuraHandledException(ERR_MSG + ' : <<' + e.getStackTraceString() + '>>');
        }
    }

    /*
     * Purpose : Finds activity records to be processed
     * Input : recordId     [Given object's records to be processed]
     *         actObjName   [Activity type (Task/Event)]
     *         whereClause  [Where clause to be used in the SOQL query]
     * Returns : Set<String> containing activity IDs to be processed
     */
    private static Set<String> fetchActRecsToProcess(String recordId, String actObjName, String whereClause){
        try {
            Set<String> actIdSet = new Set<String>();
            for(sObject actRec : Database.query('SELECT ' + actObjName + 'Id FROM ' + actObjName + 'Relation' + whereClause + ' AND IsDeleted = false ORDER BY CreatedDate DESC ' + getQueryLimit() + ' ALL ROWS')){
                actIdSet.add(String.valueOf(actRec.get(actObjName + 'Id')));
            }
            return actIdSet;
        } catch (Exception e) {
            throw new AuraHandledException(ERR_MSG + ' : <<' + e.getStackTraceString() + '>>');
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
            Integer processedRecCount = 0;
            //Added IsChild = false check on 2022-10-07 to consider only the main copy of the event record
            for(sObject actRec : Database.query('SELECT Id, ' + namespacePrefix + 'Related_Associations__c FROM ' + actObjName + ' WHERE ' + relAssoClause + (actObjName.equalsIgnoreCase('Event') ? ' AND IsChild = false' : '') + ' AND IsDeleted = false ORDER BY CreatedDate DESC ' + getQueryLimit() + ' ALL ROWS')){
                if(Limits.getCpuTime() < ALLOWED_CPU_TIME){
                    completeActIdsSet.add(String.valueOf(actRec.get('Id')));
                    processedRecCount++;
                } else {
                    system.debug('--->' + actObjName + ' > ' + processedRecCount + ' private records processed in prepareAssoActSet().');
                    break;
                }
            }
        } catch(Exception e) {
            throw new AuraHandledException(ERR_MSG + ' : <<' + e.getStackTraceString() + '>>');
        }
    }

    /*
     * Purpose : Processes the activity relation records
     * Input : actObjName       [Activity type (Task/Event)]
     *         actIdSet         [Set of activities to be processed]
     *         whereClause      [Where clause to be used in the SOQL query]
     *         conIdSet         [List of associated contacts]
     *         recordId         [Record ID of the current record (Account/Contact/Deal/Fund/Fundraising)]
     *         objectApiName    [API name of the current record (Account/Contact/Deal/Fund/Fundraising)]
     *         namespacePrefix  [Namespaceprefix to be used]
     * Returns : N/A
     */
    // private static void prepareAssoActSet(String actObjName, Set<String> actIdSet, String whereClause, Set<String> conIdSet, String recordId, String objectApiName, String namespacePrefix){
    //     try {
    //         String accIdClause = (Schema.getGlobalDescribe().get('EventRelation').getDescribe().fields.getMap().get('AccountId') != null) ? (' AccountId, ') : '';
    //         String isChildClause = actObjName.equalsIgnoreCase('Event') ? ' AND IsChild = false' : '';
    //         Integer processedRecCount = 0;
    //         for(sObject actRec : Database.query('SELECT Id, ' + namespacePrefix + 'Related_Associations__c, (SELECT ' + accIdClause + ' RelationId FROM ' + actObjName + 'Relations WHERE IsDeleted = false) FROM ' + actObjName + ' WHERE Id IN :actIdSet' + isChildClause + ' AND IsDeleted = false ORDER BY CreatedDate DESC ALL ROWS')){
    //             if(Limits.getCpuTime() < ALLOWED_CPU_TIME){
    //                 String actId = String.valueOf(actRec.get('Id'));
    //                 String relAssoIds = String.valueOf(actRec.get(namespacePrefix + 'Related_Associations__c'));
    //                 for(sObject actRelRec : actRec.getSObjects(actObjName + 'Relations')){
    //                     //If condition for Account Record Page & else condition for Contact Record Page
    //                     if(objectApiName.equalsIgnoreCase('Account')){
    //                         //For storing activities where contact is referenced
    //                         if(conIdSet.contains(String.valueOf(actRelRec.get('RelationId')))){
    //                             completeActIdsSet.add(actId);
    //                         }
    //                         //For storing activities where account id is referenced
    //                         if(String.isNotBlank(relAssoIds) && relAssoIds.contains(recordId)){
    //                             completeActIdsSet.add(actId);
    //                         }
    //                     } else {
    //                         completeActIdsSet.add(actId);
    //                     }
    //                 }
    //                 processedRecCount++;
    //             } else {
    //                 system.debug('--->' + actObjName + ' > ' + processedRecCount + ' records processed in prepareAssoActSet().');
    //                 break;
    //             }
    //         }
    //     } catch (Exception e) {
    //         throw new AuraHandledException(ERR_MSG + ' : <<' + e.getStackTraceString() + '>>');
    //     }
    // }

    /************************* COMMON METHODS : START *************************/

    /*
     * Purpose : Fetches namespace prefix
     * Returns : String containing namespaceprefix to be used
     */
    private static String getNamespacePrefix(){
        try{
            return [SELECT NamespacePrefix FROM ApexClass WHERE Name = 'FileUploaderCtrl' LIMIT :(Limits.getLimitQueryRows() - Limits.getQueryRows())].NamespacePrefix + '__';
        } catch (Exception e) {
            throw new AuraHandledException(ERR_MSG + ' : <<' + e.getStackTraceString() + '>>');
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
            throw new AuraHandledException(ERR_MSG + ' : <<' + e.getStackTraceString() + '>>');
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
            throw new AuraHandledException(ERR_MSG + ' : <<' + e.getStackTraceString() + '>>');
        }    
    }

    /************************* COMMON METHODS : END *************************/

    /*
     * Purpose : Wrapper for page load information
     */
    public class ResponseWrapper{
        @AuraEnabled public String namespacePrefix; //Namespaceprefix to be used
        @AuraEnabled public List<String> actIdList; //Associated activity ID list
    }
}