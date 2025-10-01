/****************************************************************************************************
** Module Name : Acuity 2.0 - Acuity
** Description : Used to handle all the Themes record page funtionalities of Acuity 2.0 Acuity.
** Throws : NA
** Calls : NA
** Organization : Navatar Group
** Product Name & Version : Acuity 1.0
** Revision History:-
** Version    Date(YYYY-MM-DD)    Author         Description of Action
** 1.0        2022-11-14          Anshika Ahuja
** 2.0        2024-02-14          Sudhanshu      Handle Activity layout fields
** 2.1        2024-03-08          Manonit        Category Implementation on Theme Page for Contact ,Deal,Fund and Fundraising Object
** 2.1        2024-03-20          Manonit        Theme Page Load Issue
****************************************************************************************************/
public with sharing class NavatarThemeAcuityCtrl { //Added By Tejaswini - Naming Convention

    /*
     * Purpose : Processes the page load info to be displayed
     * Input : recordId     [Record ID of the current record (Themes)]     
     * Returns : Info to be displayed on page load as a ResponseWrapper
     */
 @AuraEnabled
 public static ResponseWrapper handleOnLoadDescription(String recordId){
     try{
         ResponseWrapper respWrapper = new ResponseWrapper();
         List<String> themeTeamNamesList = new List<String>();
         List<navpeII_dev18__Theme_Team__c> themeTeamList =[Select id, navpeII_dev18__Member__c, navpeII_dev18__Member__r.Name, navpeII_dev18__Theme__c, navpeII_dev18__Theme__r.Description__c from navpeII_dev18__Theme_Team__c where navpeII_dev18__Theme__c =:recordId];
         if(themeTeamList.size() > 0){
             for(navpeII_dev18__Theme_Team__c thisThemeTeamRec : themeTeamList){
			 if(schema.sobjecttype.Theme_Team__c.Fields.Member__c.isaccessible()){ // Added by Hema - W.R.T to Security Fix
                 themeTeamNamesList.add(thisThemeTeamRec.navpeII_dev18__Member__r.Name);
                  }				 
             }    
         }
         // Added by Hema - W.R.T to Security Fix
         respWrapper.themeDescription = (schema.sobjecttype.Theme__c.Fields.Description__c.isaccessible())? [Select id, navpeII_dev18__Description__c from navpeII_dev18__Theme__c where Id =:recordId].navpeII_dev18__Description__c :'';
         respWrapper.themeTeamMembers = (themeTeamNamesList.size() > 0) ? String.join(themeTeamNamesList, ', '):'';
         return respWrapper;    
     }
     
     catch(Exception e) {
         throw new AuraHandledException('Error Occured While Loading Component : <<' + e.getStackTraceString() + '>>');
     }
 }
 
 /*
     * Purpose : Processes the page load info to be displayed
     * Input : recordId     [Record ID of the current record (Themes)]     
     * Returns : Info to be displayed on page load as a ResponseWrapper
     */
 @AuraEnabled
 public static ResponseWrapper handleOnLoadInfo(String recordId){
     try {
         ResponseWrapper respWrapper = new ResponseWrapper();
         respWrapper.namespacePrefix = getNamespacePrefix() + '__';
         Map<Id,List<String>> mapThemeToThemeTeamMembers = new Map<Id,List<String>>();
         String themeRecordId = '%'+recordId+'%'; //Bug -00044202 Manonit Theme Page Load Issue Fix Phase 2
         List<String> completeActIdList = new List<String>();
         Set<String> allActivityIdSet = new Set<String>();
         respWrapper.currentRecordName = [Select id, Name from navpeII_dev18__Theme__c where Id=:recordId].Name;
         List<Task> taskRecList = [SELECT ID,Subject,Description,navpeII_dev18__Related_Associations__c FROM Task where Related_Associations__c != null AND Related_Associations__c Like :themeRecordId WITH SECURITY_ENFORCED Order By CreatedDate DESC LIMIT :(Limits.getLimitQueryRows() - Limits.getQueryRows()) ];
         List<Event> eventRecList = [SELECT ID,Subject,Description,navpeII_dev18__Related_Associations__c FROM Event where Related_Associations__c != null AND Related_Associations__c Like :themeRecordId WITH SECURITY_ENFORCED Order By CreatedDate DESC LIMIT :(Limits.getLimitQueryRows() - Limits.getQueryRows()) ];
         for(Task thisTask : taskRecList){
             allActivityIdSet.add(thisTask.Id);	   
        /*     for(String whatid : thisTask.navpeII_dev18__Related_Associations__c.split(',')){
                 Id recId = (Id)whatid;
                 String sObjName = recId.getSObjectType().getDescribe().getName(); 
                 if(sObjName == 'navpeII_dev18__Theme__c' && thisTask.navpeII_dev18__Related_Associations__c.contains(recordId)){
                     allActivityIdSet.add(thisTask.Id);	    
                 }
             }*/
         }
         for(Event thisEvent : eventRecList){
              allActivityIdSet.add(thisEvent.Id);
            /* for(String whatid : thisEvent.navpeII_dev18__Related_Associations__c.split(',')){
                 Id recId = (Id)whatid;
                 String sObjName = recId.getSObjectType().getDescribe().getName(); 
                 if(sObjName == 'navpeII_dev18__Theme__c' && thisEvent.navpeII_dev18__Related_Associations__c.contains(recordId)){
                  //   allActivityIdSet.add(thisEvent.Id);	    
                 }  
             }*/
         }
         if(!allActivityIdSet.isEmpty()){
             completeActIdList.addAll(allActivityIdSet);
         }
         respWrapper.completeActIdList = completeActIdList;
         return respWrapper;
     } catch(Exception e) {
         throw new AuraHandledException('Error Occured While Loading Component : <<' + e.getStackTraceString() + '>>');
     }
 }
 
 /************************* COMMON METHODS : START *************************/
 
 /*
     * Purpose : Fetches namespace prefix
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
     * Purpose : Fetches the field label to be displayed as data table column header
     * Input : objName      [Contact/User]
     *         fieldName    [Field whose label is to be fetched]
     * Returns : Field label as a String
     */
 public static String fetchFieldLabel(String objName, String fieldName){
     try {
         return Schema.getGlobalDescribe().get(objName).getDescribe().fields.getMap().get(fieldName.split('\\.')[0].replace('__r','__c')).getDescribe().getLabel();
     } catch (Exception e) {
         throw new AuraHandledException('Error Occured While Loading Component : <<' + e.getStackTraceString() + '>>');
     }
 }
 
 
 /************************* INTERACTIONS SECTION MAIN METHODS : START *************************/
 
 /*
     * Purpose : Handles the Interactions section information on Account & Contact objects
     * Input : namespacePrefix   [Namespaceprefix to be used]
     *         actIdList         [Activity IDs to be processed]
     * Returns : Final activity info as a list of ActivityWrapper
     */
 @AuraEnabled
 public static List<ActivityWrapper> handleInteractionsInfo(String namespacePrefix, List<String> actIdList){
     try {
         List<ActivityWrapper> actWrapper = new List<ActivityWrapper>();
         Set<String> taggedObjApiNameSet = fetchTaggedObjApiNameSet(namespacePrefix);
         Map<String, String> objApiNameVsIconNameMap = fetchIconInfo(taggedObjApiNameSet);
         List<ActivityWrapper> evWrapper = fetchActInfo(actIdList, taggedObjApiNameSet, objApiNameVsIconNameMap, 'Event', 'WHERE (Relation.Type = \'Contact\' OR Relation.Type = \'User\')', namespacePrefix);
         actWrapper.addAll(evWrapper);
         if(Schema.getGlobalDescribe().get('TaskRelation') != null){
             List<ActivityWrapper> taskWrapper = fetchActInfo(actIdList, taggedObjApiNameSet, objApiNameVsIconNameMap, 'Task', 'WHERE (Relation.Type = \'Contact\')', namespacePrefix);
         	actWrapper.addAll(taskWrapper);
         }
         return actWrapper;
     } catch (Exception e) {
         throw new AuraHandledException('Error Occured While Loading Component : <<' + e.getStackTraceString() + '>>'+e.getLineNumber());
     }
 }
 
 /*
     * Purpose : Fetches the activities information
     * Input : objName                      [Activity object name (Task/Event)]
     *         dateRefField                 [Field to consider for displaying date information (ActivityDateTime : Event; ActivityDate : Task)]
     *         actIdList                    [Activity IDs list to be processed]
     *         namespacePrefix              [Namespaceprefix to be used]
     *         attendeeAndNameWhereClause   [Where clause for fetching attendee & assigned to info from Activity objects]
     * Returns : Activity info as a list of ActivityWrapper of provided activity object
     */
 private static List<ActivityWrapper> fetchActInfo(List<String> actIdList, Set<String> objApiNameSet, Map<String, String> objApiNameVsIconNameMap, String objName, String whereClause, String namespacePrefix){
     try {

        List<String> otherLayoutFields=getSearchableObjName();
        String taskLayoutFields=otherLayoutFields[0];
        String eventLayoutFields=otherLayoutFields[1];
        String FollowupTaskLayoutFields=otherLayoutFields[2];

        System.debug('TaskLayout===>'+taskLayoutFields);

         Set<String> relAssoIdSet = new Set<String>();
         Set<String> associatedUsersIdSet = new Set<String>();
         Set<String> associatedConIdSet = new Set<String>();
         String limitClause = ' AND Id IN :actIdList WITH SECURITY_ENFORCED'; // Added by Hema - W.R.T to Security Fix
         //For processing the data of related associations field
         for(sObject actRec : Database.query('SELECT OwnerId, Related_Associations__c, (SELECT RelationId FROM ' + objName + 'Relations) FROM ' + objName + ' WHERE (' + objName + '.' + objName + 'SubType != \'ListEmail\')' + limitClause)){
             String relAssoIdsStr = String.valueOf(actRec.get('Related_Associations__c'));
             if(String.isNotBlank(relAssoIdsStr)){
                 relAssoIdSet.addAll(relAssoIdsStr.split(','));
             }
             for(sObject actRelRec : actRec.getSObjects(objName + 'Relations')){
                 String relId = String.valueOf(actRelRec.get('RelationId'));
                 if(relId.startsWith('005')){
                     associatedUsersIdSet.add(relId);
                 } else {
                     associatedConIdSet.add(relId);
                 }
             }
             associatedUsersIdSet.add(String.valueOf(actRec.get('OwnerId')));
         }
         //Added below code on 2022-10-26 to fetch tagged records info dynamically
         //Fetching id vs name of records to be used for processing
         Map<String, String> objRecMap = new Map<String, String>();
         objRecMap.putAll(fetchRecsInfo('User', associatedUsersIdSet));
         if(Schema.SObjectType.Contact.isAccessible()){ // Added by Hema - 00039693 Merged by Manonit
         objRecMap.putAll(fetchRecsInfo('Contact', associatedConIdSet));
         }
         for(String objApiName : objApiNameSet){
		 if(Schema.getGlobalDescribe().get(objApiName).getDescribe().isAccessible()){ // Added by Hema - 00039693 Merged by Manonit
             objRecMap.putAll(fetchRecsInfo(objApiName, relAssoIdSet));
			 }
         }
         List<ActivityWrapper> actWrapper = new List<ActivityWrapper>();
         String taskOtherField='FORMAT(ActivityDate), Status, Priority, navpeII_dev18__Classification__c';
            String eventOtherField='FORMAT(ActivityDate), FORMAT(ActivityDateTime), FORMAT(EndDateTime), IsAllDayEvent, navpeII_dev18__Classification__c';
            if(String.isNotBlank(taskLayoutFields))
            {
                // taskOtherField=taskOtherField+', '+taskLayoutFields;
                Map<String, Schema.SObjectField> taskSchema = Schema.SObjectType.Task.fields.getMap();
                for(String fieldName : taskLayoutFields.split(',')){
                    // bug 00047136 fixed by Sudhanshu on 23-07-2024
                    Schema.SObjectField field = taskSchema.get(fieldName);
                    String fieldType = String.valueOf(field.getDescribe().getType());
                    if(fieldName != 'navpeII_dev18__Classification__c')
                    {
                        if(fieldType == 'DATE' || fieldType == 'DATETIME' )
                        {
                            taskOtherField=taskOtherField+', FORMAT('+fieldName+')';
                        }
                        else
                        {
                            taskOtherField=taskOtherField+', '+fieldName;
                        }
                    }
                    if(fieldType == 'REFERENCE')
                    {
                        System.debug('fieldType==>>'+fieldType);
                        taskOtherField=taskOtherField+' , '+ fieldName.replace('__c','__r.Name');
                    }

                }
            }
            if(String.isNotBlank(eventLayoutFields))
            {
                // eventOtherField=eventOtherField+', '+eventLayoutFields;
                Map<String, Schema.SObjectField> eventSchema = Schema.SObjectType.Event.fields.getMap();
                for(String fieldName : eventLayoutFields.split(',')){
                    // bug 00047136 fixed by Sudhanshu on 23-07-2024
                    Schema.SObjectField field = eventSchema.get(fieldName);
                    String fieldType = String.valueOf(field.getDescribe().getType());
                    if(fieldName != 'navpeII_dev18__Classification__c')
                    {
                        if(fieldType == 'DATE' || fieldType == 'DATETIME' )
                        {
                            eventOtherField=eventOtherField+', FORMAT('+fieldName+')';
                        }
                        else
                        {
                            eventOtherField=eventOtherField+', '+fieldName;
                        }
                    }
                    if(fieldType == 'REFERENCE')
                    {
                        System.debug('fieldType==>>'+fieldType);
                        eventOtherField=eventOtherField+' , '+ fieldName.replace('__c','__r.Name');
                    }

                }
            }


         String otherFieldStr = objName.equalsIgnoreCase('Task')
                                 ? taskOtherField
                                 : eventOtherField;
         limitClause = (' WHERE Id IN :actIdList' + (objName.equalsIgnoreCase('Event') ? ' AND IsChild = false' : ''));
                         
         for(sObject objRec : Database.query('SELECT Id, OwnerId, Owner.Name, Subject, Description, Related_Associations__c, ' + objName + 'SubType, ' + otherFieldStr + ', (SELECT RelationId, Relation.Name FROM ' + objName + 'Relations ' + whereClause + ') FROM ' + objName + limitClause)){
             actWrapper.add(createActWrapper(objRec, objName, objApiNameVsIconNameMap, objRecMap));
         }
         return actWrapper;
     } catch (Exception e) {
         throw new AuraHandledException('Error Occured While Loading Component : <<' + e.getStackTraceString() + '>>'+e.getLineNumber());
     }
 }
 
 /*
     * Purpose : Fetches API names of all objects that are to be tagged
     * Input : namespacePrefix  [Namespaceprefix to be used]
     * Returns : Set of API names of objects to be tagged
     */
 private static Set<String> fetchTaggedObjApiNameSet(String namespacePrefix){
     try {
         Set<String> taggedObjIdPrefixSet = new Set<String>();
         Set<String> objApiNameSet = new Set<String>();
         taggedObjIdPrefixSet.addAll(String.valueOf((Database.query(String.escapeSingleQuotes('SELECT RAS__c FROM ' + String.escapeSingleQuotes(namespacePrefix) + 'Navatar_Setup__c WHERE ' + String.escapeSingleQuotes(namespacePrefix) + 'Admin_Setting__c = true LIMIT 1'))[0]).get('RAS__c')).split(','));
         for(Schema.SObjectType sObjType : Schema.getGlobalDescribe().values()){
             Schema.DescribeSObjectResult descRes = sObjType.getDescribe();
             String prefix = descRes.getKeyPrefix();
             if(taggedObjIdPrefixSet.contains(prefix)){
                 objApiNameSet.add(descRes.getName());
             }
         }
         return objApiNameSet;
     } catch (Exception e) {
         throw new AuraHandledException('Error Occured While Loading Component : <<' + e.getStackTraceString() + '>>'+e.getLineNumber());
     }
 }
 
 
 /*
     * Purpose : Fetches info of icons of objects to be tagged
     * Input : objApiNameSet    [Set of object API names to be tagged]
     * Returns : Map of tagged object's API names vs icon name
     */
 private static Map<String, String> fetchIconInfo(Set<String> objApiNameSet){
     try {
         objApiNameSet.add('Contact');
         Map<String, String> objApiNameVsIconNameMap = new Map<String, String>();
         List<JsonResponse> layoutInfo = (list<JsonResponse>)System.JSON.deserialize(fetchEndpointResponse('/services/data/v55.0/tabs'), List<JsonResponse>.class);
         for(String objApiName : objApiNameSet){
             for(JsonResponse tab : layoutInfo){
                 if(tab.sobjectName.equalsIgnoreCase(objApiName)){
                     for(Icons icon : tab.icons){
                         if(icon.height == 0 && icon.theme == 'theme4'){
                             objApiNameVsIconNameMap.put(objApiName, icon.url.split('/')[6] + ':' + (icon.url.split('/')[7]).split('\\.')[0]);
                             break;
                         }
                     }
                 }
             }
         }
         return objApiNameVsIconNameMap;
     } catch (Exception e) {
         throw new AuraHandledException('Error Occured While Loading Component : <<' + e.getStackTraceString() + '>>'+e.getLineNumber());
     }
 }
 
 
 
 
 /************************* INTERACTIONS SECTION MAIN METHODS : END *************************/
 
 /************************* INTERACTIONS SECTION COMMON METHODS : START *************************/
 
 /*
     * Purpose : Fetch info of provided objects
     * Input : objName      [Object name whose info is to be fetched]
     *         relAssoIds   [Set of IDs of records to be processed]
     * Returns : Map of record id vs record name
     */
 public static Map<String, String> fetchRecsInfo(String objName, Set<String> relAssoIds){
     try {
         Map<String, String> recMap = new Map<String, String>();
         for(sObject rec : Database.query('SELECT Id, Name FROM ' + String.escapeSingleQuotes(objName) + ' WHERE Id IN :relAssoIds WITH SECURITY_ENFORCED')){
             recMap.put(String.valueOf(rec.get('Id')), String.valueOf(rec.get('Name')));
         }
         return recMap;
     } catch (Exception e) {
         throw new AuraHandledException('Error Occured While Loading Component : <<' + e.getStackTraceString() + '>>');
     }
 }
 
 /*
     * Purpose : Creates the Activity Wrapper
     * Input : objRec                   [Activity record]
     *         actObjName               [Activity object API name]
     *         objApiNameVsIconNameMap  [Object API name vs Icon Name map]
     *         objRecMap                [Participants/Tags record ID vs Name]
     * Returns : Activity wrapper
     */
 private static ActivityWrapper createActWrapper(sObject objRec, String actObjName, Map<String, String> objApiNameVsIconNameMap, Map<String, String> objRecMap){
     try {
         ActivityWrapper actWrap = new ActivityWrapper();
         actWrap.actInfo = objRec;
         actWrap.attendees = new List<ReferenceWrapper>();
         actWrap.references = new List<ReferenceWrapper>();
         actWrap.actId = String.valueOf(objRec.get('Id'));
         actWrap.type = String.valueOf(objRec.get(actObjName + 'SubType')).replace('Event', 'Meeting').replace('ListEmail', 'List Email');
         actWrap.subject = String.isNotBlank(String.valueOf(objRec.get('Subject'))) ?
                             String.valueOf(objRec.get('Subject'))
                             : '[No subject]';
         actWrap.detail = String.valueOf(objRec.get('Description'));
         actWrap.classification = String.valueOf(objRec.get('Classification__c'));
         //actWrap.actOwner = String.valueOf(objRec.getSObject('Owner').get('Name'));
         //For test class coverage
         actWrap.actOwner = String.valueOf(objRec.getSObject('Owner')) != null ? String.valueOf(objRec.getSObject('Owner').get('Name')) : '';
         actWrap.iconName = fetchIconName(String.valueOf(objRec.get(actObjName + 'SubType')));
         actWrap.priority = actObjName.equalsIgnoreCase('Task')
                             ? String.valueOf(objRec.get('Priority'))
                             : '';
         actWrap.status = actObjName.equalsIgnoreCase('Task')
                             ? String.valueOf(objRec.get('Status'))
                             : '';
         actWrap.actDate = actObjName.equalsIgnoreCase('Task') || (actObjName.equalsIgnoreCase('Event') && Boolean.valueOf(String.valueOf(objRec.get('IsAllDayEvent'))))
                             ? String.valueOf(objRec.get('ActivityDate'))
                             : String.valueOf(objRec.get('ActivityDateTime'));
         actWrap.actDateAsLong = String.isBlank(actWrap.actDate)
                                 ? ((actObjName.equalsIgnoreCase('Task') && !String.valueOf(objRec.get('Status')).equalsIgnoreCase('Completed'))
                                     ? 9223372036854775807L
                                     : 0)
                                 : (actObjName.equalsIgnoreCase('Event') && !Boolean.valueOf(String.valueOf(objRec.get('IsAllDayEvent')))
                                     ? (DateTime.parse(actWrap.actDate)).getTime()
                                     : ((DateTime)Date.parse(actWrap.actDate)).getTime());
         //For Interactions tab to display Add/Edit Button or, no button
         //Modified activity type checking from email to ListEmail on 2022-11-09 to display "Edit Note" button for emails
         if(!actWrap.type.containsIgnoreCase('ListEmail')){
             //Replaced act.actDate with "String.valueOf(actRec.get('EndDateTime'))" ; "<=" with ">" and added or condition on 2022-09-26 to consider an event as a future event if enddatetime of an event has passed
             actWrap.isFutureActivity = String.isNotBlank(actWrap.actDate) || actObjName.equalsIgnoreCase('Event')
                                     ? (actObjName.equalsIgnoreCase('Event')
                                         ? (DateTime.parse(String.valueOf(objRec.get('EndDateTime'))) > DateTime.now())
                                         : Date.parse(actWrap.actDate) <= Date.today())
                                     : false;
              // Bug 00033749 Fix by Sudhanshu on 28-05-2024                      
             actWrap.buttonTitle = actObjName.equalsIgnoreCase('Event') && String.isBlank(String.valueOf(objRec.get('Description')))
                                     ? 'Add Note'
                                     : 'Edit Note';
         }
         if(String.isNotBlank(String.valueOf(objRec.get('Related_Associations__c')))){
             for(String taggedRecId : String.valueOf(objRec.get('Related_Associations__c')).split(',')){
                 ReferenceWrapper refWrap = new ReferenceWrapper();
                 String recObjName = String.valueOf(Id.valueOf(taggedRecId).getsobjecttype());
                 refWrap.name = objRecMap.get(taggedRecId);
                 refWrap.nameRef = '/' + taggedRecId;
                 refWrap.iconName = objApiNameVsIconNameMap.get(recObjName);
                 if(objRecMap.get(taggedRecId) != null){// Modified by Hema for Anurag critical bug 00039958
                 actWrap.references.add(refWrap);
             }
         }
         }
         for(sObject actRelRec : objRec.getSObjects(actObjName + 'Relations')){
             //For adding Contact/User info
             ReferenceWrapper refWrap = new ReferenceWrapper();
             String recObjName = String.valueOf(Id.valueOf(String.valueOf(actRelRec.get('RelationId'))).getsobjecttype());
             refWrap.name = objRecMap.get(String.valueOf(actRelRec.get('RelationId')));
             refWrap.nameRef = recObjName.equalsIgnoreCase('Contact')
                                 ? '/' + String.valueOf(actRelRec.get('RelationId'))
                                 : '';
             refWrap.iconName = recObjName.equalsIgnoreCase('Contact')
                                 ? objApiNameVsIconNameMap.get(recObjName)
                                 : 'standard:user';
            // if(objRecMap.get(String.valueOf(actRelRec.get('RelationId'))) != null){
             actWrap.attendees.add(refWrap);
            // }
            
         }
         //For adding Assigned To user's info
         ReferenceWrapper refWrap = new ReferenceWrapper();
         refWrap.name = objRecMap.get(String.valueOf(objRec.get('OwnerId')));
         refWrap.iconName = 'standard:user';
         actWrap.attendees.add(refWrap);
         return actWrap;
     } catch (Exception e) {
         throw new AuraHandledException('Error Occured While Loading Component : <<' + e.getStackTraceString() + '>>');
     }
 }

       /****************************************************************************************************
    Purpose : get set-up object and layout fields from navatar setup object

    Returns : list of strings which includes objectList and auout details
    ****************************************************************************************************/
    @AuraEnabled
    public static List<string> getSearchableObjName(){
        try {
            List <sObject> lst = new List <sObject> ();
            String strQuery = '';
            String RAS='003,';  //005,
            String Notes_Popup_Task_Fields='';
            String Notes_Popup_Event_Fields='';
            String Notes_Popup_FollowUp_Task_Fields='';
            String AD_Switcher='';
            try{
                strQuery = 'SELECT Id, navpeII_dev18__AD_Switcher__c, navpeII_dev18__RAS__c, navpeII_dev18__Notes_Popup_Event_Fields__c, navpeII_dev18__Notes_Popup_Task_Fields__c, navpeII_dev18__Notes_Popup_FollowUp_Task_Fields__c FROM navpeII_dev18__Navatar_Setup__c Where navpeII_dev18__Admin_Setting__c = true AND navpeII_dev18__RAS__c != Null';
                lst = Database.query(string.escapesinglequotes(strQuery));
                RAS = RAS + String.valueOf(lst[0].get('navpeII_dev18__RAS__c'));
                Notes_Popup_Task_Fields=(String)lst[0].get('navpeII_dev18__Notes_Popup_Task_Fields__c');
                Notes_Popup_Event_Fields=(String)lst[0].get('navpeII_dev18__Notes_Popup_Event_Fields__c');
                Notes_Popup_FollowUp_Task_Fields=(String)lst[0].get('navpeII_dev18__Notes_Popup_FollowUp_Task_Fields__c');
                AD_Switcher=String.valueOf(lst[0].get('navpeII_dev18__AD_Switcher__c'));
            }
            catch(exception ex){
                strQuery = 'SELECT Id, AD_Switcher__c, RAS__c, Notes_Popup_Event_Fields__c, Notes_Popup_Task_Fields__c, Notes_Popup_FollowUp_Task_Fields__c FROM Navatar_Setup__c Where Admin_Setting__c = true AND RAS__c != Null';
                lst = Database.query(string.escapesinglequotes(strQuery));
                RAS = RAS + String.valueOf(lst[0].get('RAS__c'));
                Notes_Popup_Task_Fields=(String)lst[0].get('Notes_Popup_Task_Fields__c');
                Notes_Popup_Event_Fields=(String)lst[0].get('Notes_Popup_Event_Fields__c');
                Notes_Popup_FollowUp_Task_Fields=(String)lst[0].get('Notes_Popup_FollowUp_Task_Fields__c');
                AD_Switcher=String.valueOf(lst[0].get('AD_Switcher__c'));
            }
            
            String uNotes_Popup_Task_Fields='';
            String uNotes_Popup_Event_Fields='';
            String uNotes_Popup_FollowUp_Task_Fields='';
        
            for(String str:checkUpdateableFields(Schema.getGlobalDescribe().get('Task'),Notes_Popup_Task_Fields.split(',') ) ){
                if(String.isNotBlank(str) && str != 'ActivityDate' && str != 'Status' && str != 'Priority' && str != 'navpeII_dev18__Classification__c' && str !='OwnerId')
                uNotes_Popup_Task_Fields+=str+',';
            }
			uNotes_Popup_Task_Fields=uNotes_Popup_Task_Fields.removeEnd(',');  //FIx for FLS issues
            for(String str:checkUpdateableFields(Schema.getGlobalDescribe().get('Event'),Notes_Popup_Event_Fields.split(',') ) ){
                if(String.isNotBlank(str) && str!= 'ActivityDate' && str!= 'ActivityDateTime' && str!= 'EndDateTime'  && str!= 'IsAllDayEvent' &&str!= 'navpeII_dev18__Classification__c' && str !='OwnerId')
                uNotes_Popup_Event_Fields+=str+',';
            }
			uNotes_Popup_Event_Fields=uNotes_Popup_Event_Fields.removeEnd(',');  //FIx for FLS issues
            for(String str:checkUpdateableFields(Schema.getGlobalDescribe().get('Task'),Notes_Popup_FollowUp_Task_Fields.split(',') ) ){
                if(String.isNotBlank(str))
                uNotes_Popup_FollowUp_Task_Fields+=str+',';
            }
			uNotes_Popup_FollowUp_Task_Fields=uNotes_Popup_FollowUp_Task_Fields.removeEnd(','); //FIx for FLS issues
        
            //added code for Security Fix checking Updateable:ended
            return new List<String>{uNotes_Popup_Task_Fields, uNotes_Popup_Event_Fields, uNotes_Popup_FollowUp_Task_Fields};
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    private static List<String> checkUpdateableFields(Schema.SObjectType objectType, List<String> fieldNames) {
        Map<String, Schema.SobjectField> fields = objectType.getDescribe().fields.getMap();
        //System.debug('Before: '+fieldNames);
        for (String s : fieldNames.clone() ) {
            //System.debug(fields.keySet());
            if (!(fields.get(s.toLowerCase()).getDescribe().isUpdateable()) ) {
                System.debug(s+' '+fieldNames);
                fieldNames.remove(fieldNames.indexOf(s));
            }
        }
        //System.debug('After: '+fieldNames);
        return fieldNames;
    }
 
 /*
     * Purpose : Fetches the icon name
     * Input : subType      [Task/Event subtype]
     * Returns : Icon name
     */
 @TestVisible //Added by Tejaswini for Test Coverage
 private static String fetchIconName(String subType){
     try {
         switch on subType{
             when 'Event'{
                 return 'utility:event';
             }
             when 'Task'{
                 return 'utility:task';
             }
             when 'Call'{
                 return 'utility:call';
             }
             when 'List Email'{
                 return 'utility:list_email';
             }
             when else{
                 return 'utility:email';
             }
         }
     } catch (Exception e) {
         throw new AuraHandledException('Error Occured While Loading Component : <<' + e.getStackTraceString() + '>>');
     }
 }
 
 
 /*
     * Purpose : Fetches session ID using the sessionIdPage VF page
     * Input : vfPage       [VF page reference]
     * Returns : Session ID in the form of a string
     */
 private static String getSessionIdFromVFPage(PageReference vfPage){
     try {
         if(Test.isRunningTest()){
             return 'SessionIdForTestClass';
         }
         String content = vfPage.getContent().toString();
         return content.substring(content.indexOf('Session_Id_Start_Here') + 'Session_Id_Start_Here'.length(), content.indexOf('Session_Id_End_Here'));
     } catch(Exception e) {
         throw new AuraHandledException('Error Occured While Loading Component : <<' + e.getStackTraceString() + '>>');
     }
 }
 
 
 /*
     * Purpose : Fetches response on hitting the API
     * Input : endpointUrl       [Endpoint URL to hit]
     * Returns : Response on hitting the API
     */
 private static String fetchEndpointResponse(String endpointUrl){
     try {
         HttpRequest req = new HttpRequest();
         String domainUrl = URL.getSalesforceBaseUrl().toExternalForm();
         req.setEndpoint(domainUrl + endpointUrl);
         req.setMethod('GET');
         String sessionId = NavatarThemeAcuityCtrl.getSessionIdFromVFPage(Page.sessionIdPage);    //Added by Tejaswini - Naming Convention
         String auth = 'Bearer ' + sessionId;
         req.setHeader('Authorization', auth);
         Http http = new Http();
         HTTPResponse resp = http.send(req);
         return resp.getBody();
     } catch(Exception e) {
         throw new AuraHandledException('Error Occured While Loading Component : <<' + e.getStackTraceString() + '>>');
     }
 }
 
 
 
 /************************* INTERACTIONS SECTION COMMON METHODS : END *************************/
 
 
 /************************* CATEGORIES SECTION : START *************************/
 
 public static Map<String, RecordType> fetchRecordTypeInfo(){
     List<String> objList=new List<String>{'Account','Contact','navpeII_dev18__Pipeline__c','navpeII_dev18__Fund__c','navpeII_dev18__Fundraising__c'};
     return new Map<String, RecordType>([Select Id,Name,sObjectType from RecordType where sObjectType In: objList AND isActive=true]);    
 }
 
 public static Map<String, Account> fetchAccountInfo(String accountId){
     return new Map<String, Account>([Select Id,Name, Description from Account where Id=:accountId]);    
 }
 //Added by Tejaswini - 00033368
 public static Map<String, Account> fetchAccountInfoList(Set<Id> accIdList){
     return new Map<String, Account>([Select Id,Name, Description from Account where Id IN: accIdList]);    
 }
 public static Map<String, navpeII_dev18__Fund__c> fetchFundInfoList(Set<Id> fundIdList){
     return new Map<String, navpeII_dev18__Fund__c>([Select Id,Name from navpeII_dev18__Fund__c where Id IN: fundIdList]);     
 }// Addded by Manonit for Critical Bug Fix 00041133
 
 /*
     * Purpose : Fetch columns names- Called from wire method
     * Input : N.A.
     * Returns : Columns Wrapper as a details of Columns only
     */
 @AuraEnabled
 public static ThemeRelationsTableWrapper handleOnLoadTheme(){ 
     try{
         ThemeRelationsTableWrapper themeRelationsWrapper=new ThemeRelationsTableWrapper();
         for(RecordType rtInfo:fetchRecordTypeInfo().values()){
             if(rtInfo.sObjectType == 'Account'){
                 themeRelationsWrapper.accountRecordTypeIdList.add(rtInfo.Name);
             }
             if(rtInfo.sObjectType == 'Contact'){
                 themeRelationsWrapper.contactRecordTypeIdList.add(rtInfo.Name);
             }
             if(rtInfo.sObjectType == 'navpeII_dev18__Pipeline__c'){
                 themeRelationsWrapper.dealRecordTypeIdList.add(rtInfo.Name);
             }
             if(rtInfo.sObjectType == 'navpeII_dev18__Fund__c'){
                 themeRelationsWrapper.fundRecordTypeIdList.add(rtInfo.Name);
             }
             if(rtInfo.sObjectType == 'navpeII_dev18__Fundraising__c'){
                 themeRelationsWrapper.fundraisingRecordTypeIdList.add(rtInfo.Name);
             }
                           
         }
         return themeRelationsWrapper;
     }catch(exception e){
         system.debug(e.getMessage()+'  error occure on Line number ->'+e.getLineNumber()+' on apex Side in Column Making- Please check the APi Name of Fields in Metadata ');
         
         return null;
     }
     
 }
 
 
 /*
     * Purpose : Processes the page load info to be displayed columns and Data in the grids
     * Input : recordId     [Record ID of the current record (Account/Contact)]     
     * Returns : Info to be displayed on page load as a ResponseWrapper
     */
 @AuraEnabled //Added by Tejaswini - 00033368
 public static ResponseWrapper handleColumnHeaders(String recordId, String orderbyClauseFirm, String orderbyClauseContact, String orderbyClauseDeal, String orderbyClauseFund, String orderbyClauseFundraising, String sorting, String idToSort){
     ResponseWrapper respWrapper = new ResponseWrapper(); 
     //Fetch Account Fields Values From Custom Metadata
     String accField1 = Acuity_Setting__mdt.getInstance('Theme_Acc_Field1').Value__c;
     String accField2 = Acuity_Setting__mdt.getInstance('Theme_Acc_Field2').Value__c;
     String accField3 = Acuity_Setting__mdt.getInstance('Theme_Acc_Field3').Value__c;
     String accField4 = Acuity_Setting__mdt.getInstance('Theme_Acc_Field4').Value__c;
     
     //Fetch Contact Fields Values From Custom Metadata
     String conField1 = Acuity_Setting__mdt.getInstance('Theme_Con_Field1').Value__c;
     String conField2 = Acuity_Setting__mdt.getInstance('Theme_Con_Field2').Value__c;
     String conField3 = Acuity_Setting__mdt.getInstance('Theme_Con_Field3').Value__c;
     String conField4 = Acuity_Setting__mdt.getInstance('Theme_Con_Field4').Value__c;
     
     //Fetch Deal Fields Values From Custom Metadata
     String dealField1 = Acuity_Setting__mdt.getInstance('Theme_Deal_Field1').Value__c;
     String dealField2 = Acuity_Setting__mdt.getInstance('Theme_Deal_Field2').Value__c;
     String dealField3 = Acuity_Setting__mdt.getInstance('Theme_Deal_Field3').Value__c;
     String dealField4 = Acuity_Setting__mdt.getInstance('Theme_Deal_Field4').Value__c;
     String dealField5 = Acuity_Setting__mdt.getInstance('Theme_Deal_Field5').Value__c;
     String dealField6 = Acuity_Setting__mdt.getInstance('Theme_Deal_Field6').Value__c;
     
     //Fetch Fund Fields Values From Custom Metadata
     String fundField1 = Acuity_Setting__mdt.getInstance('Theme_Fund_Field1').Value__c;
     String fundField2 = Acuity_Setting__mdt.getInstance('Theme_Fund_Field2').Value__c;
     String fundField3 = Acuity_Setting__mdt.getInstance('Theme_Fund_Field3').Value__c;
     String fundField4 = Acuity_Setting__mdt.getInstance('Theme_Fund_Field4').Value__c;
     
     //Fetch Fundraising Fields Values From Custom Metadata
     //Added by Tejaswini - Naming Convention
     String fdrField1 = Acuity_Setting__mdt.getInstance('Theme_Fundraising_Field1').Value__c;
     String fdrField2 = Acuity_Setting__mdt.getInstance('Theme_Fundraising_Field2').Value__c;
     String fdrField3 = Acuity_Setting__mdt.getInstance('Theme_Fundraising_Field3').Value__c;
     String fdrField4 = Acuity_Setting__mdt.getInstance('Theme_Fundraising_Field4').Value__c;
     String fdrField5 = Acuity_Setting__mdt.getInstance('Theme_Fundraising_Field5').Value__c;
     String fdrField6 = Acuity_Setting__mdt.getInstance('Theme_Fundraising_Field6').Value__c;
     
     //Fetch Theme Fields Values From Custom Metadata
     String themeField1 = Acuity_Setting__mdt.getInstance('Theme_Theme_Field1').Value__c;
     String themeField2 = Acuity_Setting__mdt.getInstance('Theme_Theme_Field2').Value__c;
     String themeField3 = Acuity_Setting__mdt.getInstance('Theme_Theme_Field3').Value__c;
     
     //Fetch Clip Fields Values From Custom Metadata
     String clipField1 = Acuity_Setting__mdt.getInstance('Theme_Clip_Field1').Value__c;
     String clipField2 = Acuity_Setting__mdt.getInstance('Theme_Clip_Field2').Value__c;
     String clipField3 = Acuity_Setting__mdt.getInstance('Theme_Clip_Field3').Value__c;
     

     String currentThemeName = [Select Id,Name from Theme__c where Id=:recordId].Name; // Added by Hema - 00038811 Merged by Manonit
     /**** Columns Setting for Account Grid Start****/
     if(String.isNotBlank(accField1)){
         if(accField1.split('\\.').size() == 2){
             String acctemp = fetchFieldLabel('Account', accField1.split('\\.').get(1)); //Added for Critical 00034966
             respWrapper.accColumnHeader1 = (acctemp =='Legal Name')?'Firm':acctemp; 
         }
         else if(accField1.split('\\.').size() == 1){
             respWrapper.accColumnHeader1 = fetchFieldLabel('navpeII_dev18__Theme_Relation__c', accField1.split('\\.').get(0));             
         }
         
     }
     if(String.isNotBlank(accField2)){
         if(accField2.split('\\.').size() == 2){
             respWrapper.accColumnHeader2 = fetchFieldLabel('Account', accField2.split('\\.').get(1)); 
         }
         else if(accField2.split('\\.').size() == 1){
             respWrapper.accColumnHeader2 = fetchFieldLabel('navpeII_dev18__Theme_Relation__c', accField2.split('\\.').get(0));             
         }
     }
     if(String.isNotBlank(accField3)){
         if(accField3.split('\\.').size() == 2){
             respWrapper.accColumnHeader3 = fetchFieldLabel('Account', accField3.split('\\.').get(1)); 
         }
         else if(accField3.split('\\.').size() == 1){
             respWrapper.accColumnHeader3 = fetchFieldLabel('navpeII_dev18__Theme_Relation__c', accField3.split('\\.').get(0));             
         }
     }
     if(String.isNotBlank(accField4)){
         if(accField4.split('\\.').size() == 2){
             respWrapper.accColumnHeader4 = fetchFieldLabel('Account', accField4.split('\\.').get(1)); 
         }
         else if(accField4.split('\\.').size() == 1){
             respWrapper.accColumnHeader4 = fetchFieldLabel('navpeII_dev18__Theme_Relation__c', accField4.split('\\.').get(0));             
         }
     }
     /**** Columns Setting for Account Grid End****/    
     
     /**** Columns Setting for Contact Grid Start****/ 
     if(String.isNotBlank(conField1)){
         if(conField1.split('\\.').size() == 2){
             respWrapper.conColumnHeader1 = fetchFieldLabel('Contact', conField1.split('\\.').get(1));
         }
         else if(conField1.split('\\.').size() == 1){
             respWrapper.conColumnHeader1 = fetchFieldLabel('navpeII_dev18__Theme_Relation__c', conField1.split('\\.').get(0));             
         }
     }
     if(String.isNotBlank(conField2)){
         if(conField2.split('\\.').size() == 3){
             String accTemp1 = fetchFieldLabel('Account', conField2.split('\\.').get(2)); ////Added for Critical 00034966
             respWrapper.conColumnHeader2 = (accTemp1 == 'Legal Name')?'Firm':accTemp1;
         }
         if(conField2.split('\\.').size() == 2){
             respWrapper.conColumnHeader2 = fetchFieldLabel('Contact', conField2.split('\\.').get(1));
         }
         else if(conField2.split('\\.').size() == 1){
             respWrapper.conColumnHeader2 = fetchFieldLabel('navpeII_dev18__Theme_Relation__c', conField2.split('\\.').get(0));             
         }
     }
     if(String.isNotBlank(conField3)){
         if(conField3.split('\\.').size() == 2){
             respWrapper.conColumnHeader3 = fetchFieldLabel('Contact', conField3.split('\\.').get(1));
         }
         else if(conField3.split('\\.').size() == 1){
             respWrapper.conColumnHeader3 = fetchFieldLabel('navpeII_dev18__Theme_Relation__c', conField3.split('\\.').get(0));             
         }
     }
     if(String.isNotBlank(conField4)){
         if(conField4.split('\\.').size() == 2){
             respWrapper.conColumnHeader4 = fetchFieldLabel('Contact', conField4.split('\\.').get(1));
         }
         else if(conField4.split('\\.').size() == 1){
             respWrapper.conColumnHeader4 = fetchFieldLabel('navpeII_dev18__Theme_Relation__c', conField4.split('\\.').get(0));             
         }
     }
     /**** Columns Setting for Contact Grid End****/
     
     /**** Columns Setting for Deal Grid Start****/
     if(String.isNotBlank(dealField1)){
         if(dealField1.split('\\.').size() == 2){
             respWrapper.dealColumnHeader1 = fetchFieldLabel('navpeII_dev18__Pipeline__c', dealField1.split('\\.').get(1)); 
         }
         else if(dealField1.split('\\.').size() == 1){
             respWrapper.dealColumnHeader1 = fetchFieldLabel('navpeII_dev18__Theme_Relation__c', dealField1.split('\\.').get(0));             
         }
     }
     if(String.isNotBlank(dealField2)){
         if(dealField2.split('\\.').size() == 3){
             String accTemp2 = fetchFieldLabel('Account', dealField2.split('\\.').get(2)); ////Added for Critical 00034966
             respWrapper.dealColumnHeader2 = (accTemp2 == 'Legal Name')?'Firm':accTemp2; 
         }
         if(dealField2.split('\\.').size() == 2){
             respWrapper.dealColumnHeader2 = fetchFieldLabel('navpeII_dev18__Pipeline__c', dealField2.split('\\.').get(1)); 
         }
         else if(dealField2.split('\\.').size() == 1){
             respWrapper.dealColumnHeader2 = fetchFieldLabel('navpeII_dev18__Theme_Relation__c', dealField2.split('\\.').get(0));             
         }
     }
     if(String.isNotBlank(dealField3)){
         if(dealField3.split('\\.').size() == 2){
             respWrapper.dealColumnHeader3 = fetchFieldLabel('navpeII_dev18__Pipeline__c', dealField3.split('\\.').get(1)); 
         }
         else if(dealField3.split('\\.').size() == 1){
             respWrapper.dealColumnHeader3 = fetchFieldLabel('navpeII_dev18__Theme_Relation__c', dealField3.split('\\.').get(0));             
         }
     }
     if(String.isNotBlank(dealField4)){
         if(dealField4.split('\\.').size() == 2){
             respWrapper.dealColumnHeader4 = fetchFieldLabel('navpeII_dev18__Pipeline__c', dealField4.split('\\.').get(1)); 
         }
         else if(dealField4.split('\\.').size() == 1){
             respWrapper.dealColumnHeader4 = fetchFieldLabel('navpeII_dev18__Theme_Relation__c', dealField4.split('\\.').get(0));             
         }
     }
     if(String.isNotBlank(dealField5)){
         if(dealField5.split('\\.').size() == 2){
             respWrapper.dealColumnHeader5 = fetchFieldLabel('navpeII_dev18__Pipeline__c', dealField5.split('\\.').get(1)); 
         }
         else if(dealField5.split('\\.').size() == 1){
             respWrapper.dealColumnHeader5 = fetchFieldLabel('navpeII_dev18__Theme_Relation__c', dealField5.split('\\.').get(0));             
         }
     }
     if(String.isNotBlank(dealField6)){
         if(dealField6.split('\\.').size() == 2){
             respWrapper.dealColumnHeader6 = fetchFieldLabel('navpeII_dev18__Pipeline__c', dealField6.split('\\.').get(1)); 
         }
         else if(dealField6.split('\\.').size() == 1){
             respWrapper.dealColumnHeader6 = fetchFieldLabel('navpeII_dev18__Theme_Relation__c', dealField6.split('\\.').get(0));             
         }
     }
     /**** Columns Setting for Deal Grid End****/
     
     /**** Columns Setting for Fund Grid Start****/
     if(String.isNotBlank(fundField1)){
         if(fundField1.split('\\.').size() == 2){
             respWrapper.fundColumnHeader1 = fetchFieldLabel('navpeII_dev18__Fund__c', fundField1.split('\\.').get(1)); 
         }
         else if(fundField1.split('\\.').size() == 1){
             respWrapper.fundColumnHeader1 = fetchFieldLabel('navpeII_dev18__Theme_Relation__c', fundField1.split('\\.').get(0));             
         }
     }
     if(String.isNotBlank(fundField2)){
         if(fundField2.split('\\.').size() == 2){
             respWrapper.fundColumnHeader2 = fetchFieldLabel('navpeII_dev18__Fund__c', fundField2.split('\\.').get(1)); 
         }
         else if(fundField2.split('\\.').size() == 1){
             respWrapper.fundColumnHeader2 = fetchFieldLabel('navpeII_dev18__Theme_Relation__c', fundField2.split('\\.').get(0));             
         }
     }
     if(String.isNotBlank(fundField3)){
         if(fundField3.split('\\.').size() == 2){
             respWrapper.fundColumnHeader3 = fetchFieldLabel('navpeII_dev18__Fund__c', fundField3.split('\\.').get(1)); 
         }
         else if(fundField3.split('\\.').size() == 1){
             respWrapper.fundColumnHeader3 = fetchFieldLabel('navpeII_dev18__Theme_Relation__c', fundField3.split('\\.').get(0));             
         }
     }
     if(String.isNotBlank(fundField4)){
         if(fundField4.split('\\.').size() == 2){
             respWrapper.fundColumnHeader4 = fetchFieldLabel('navpeII_dev18__Fund__c', fundField4.split('\\.').get(1)); 
         }
         else if(fundField4.split('\\.').size() == 1){
             respWrapper.fundColumnHeader4 = fetchFieldLabel('navpeII_dev18__Theme_Relation__c', fundField4.split('\\.').get(0));             
         }
     }
     /**** Columns Setting for Fund Grid End****/
     
     /**** Columns Setting for Fundraising Grid Start****/
     if(String.isNotBlank(fdrField1)){
         if(fdrField1.split('\\.').size() == 2){
             respWrapper.fdrColumnHeader1 = fetchFieldLabel('navpeII_dev18__Fundraising__c', fdrField1.split('\\.').get(1)); 
         }
         else if(fdrField1.split('\\.').size() == 1){
             respWrapper.fdrColumnHeader1 = fetchFieldLabel('navpeII_dev18__Theme_Relation__c', fdrField1.split('\\.').get(0));             
         }
     }
     if(String.isNotBlank(fdrField2)){
         if(fdrField2.split('\\.').size() == 3){
             String accTemp3 = fetchFieldLabel('Account', fdrField2.split('\\.').get(2)); ////Added for Critical 00034966
             respWrapper.fdrColumnHeader2 = (accTemp3 == 'Legal Name')?'Firm':accTemp3;
         }
         if(fdrField2.split('\\.').size() == 2){
             respWrapper.fdrColumnHeader2 = fetchFieldLabel('navpeII_dev18__Fundraising__c', fdrField2.split('\\.').get(1)); 
         }
         else if(fdrField2.split('\\.').size() == 1){
             respWrapper.fdrColumnHeader2 = fetchFieldLabel('navpeII_dev18__Theme_Relation__c', fdrField2.split('\\.').get(0));             
         }
     }
     if(String.isNotBlank(fdrField3)){
         if(fdrField3.split('\\.').size() == 3){
             respWrapper.fdrColumnHeader3 = fetchFieldLabel('navpeII_dev18__Fund__c', fdrField3.split('\\.').get(2)); 
         }
         if(fdrField3.split('\\.').size() == 2){
             respWrapper.fdrColumnHeader3 = fetchFieldLabel('navpeII_dev18__Fundraising__c', fdrField3.split('\\.').get(1)); 
         }
         else if(fdrField3.split('\\.').size() == 1){
             respWrapper.fdrColumnHeader3 = fetchFieldLabel('navpeII_dev18__Theme_Relation__c', fdrField3.split('\\.').get(0));             
         }
     }
     if(String.isNotBlank(fdrField4)){
         if(fdrField4.split('\\.').size() == 2){
             respWrapper.fdrColumnHeader4 = fetchFieldLabel('navpeII_dev18__Fundraising__c', fdrField4.split('\\.').get(1)); 
         }
         else if(fdrField4.split('\\.').size() == 1){
             respWrapper.fdrColumnHeader4 = fetchFieldLabel('navpeII_dev18__Theme_Relation__c', fdrField4.split('\\.').get(0));             
         }
     }
     if(String.isNotBlank(fdrField5)){
         if(fdrField5.split('\\.').size() == 2){
             respWrapper.fdrColumnHeader5 = fetchFieldLabel('navpeII_dev18__Fundraising__c', fdrField5.split('\\.').get(1)); 
         }
         else if(fdrField5.split('\\.').size() == 1){
             respWrapper.fdrColumnHeader5 = fetchFieldLabel('navpeII_dev18__Theme_Relation__c', fdrField5.split('\\.').get(0));             
         }
     }
     if(String.isNotBlank(fdrField6)){
         if(fdrField6.split('\\.').size() == 2){
             respWrapper.fdrColumnHeader6 = fetchFieldLabel('navpeII_dev18__Fundraising__c', fdrField6.split('\\.').get(1)); 
         }
         else if(fdrField6.split('\\.').size() == 1){
             respWrapper.fdrColumnHeader6 = fetchFieldLabel('navpeII_dev18__Theme_Relation__c', fdrField6.split('\\.').get(0));             
         }
     }
     
     /**** Columns Setting for Fundraising Grid Start****/
     
     /**** Columns Setting for Themes Grid Start****/
     if(String.isNotBlank(themeField1)){
         if(themeField1.split('\\.').size() == 2){
             respWrapper.themeColumnHeader1 = fetchFieldLabel('navpeII_dev18__Theme__c', themeField1.split('\\.').get(1)); 
         }
         else if(themeField1.split('\\.').size() == 1){
             respWrapper.themeColumnHeader1 = fetchFieldLabel('navpeII_dev18__Theme_Relation__c', themeField1.split('\\.').get(0));             
         }
         
     }
     if(String.isNotBlank(themeField2)){
         if(themeField2.split('\\.').size() == 2){
             respWrapper.themeColumnHeader2 = fetchFieldLabel('navpeII_dev18__Theme__c', themeField2.split('\\.').get(1)); 
         }
         else if(themeField2.split('\\.').size() == 1){
             respWrapper.themeColumnHeader2 = fetchFieldLabel('navpeII_dev18__Theme_Relation__c', themeField2.split('\\.').get(0));             
         }
     }
     if(String.isNotBlank(themeField3)){
         if(themeField3.split('\\.').size() == 2){
             respWrapper.themeColumnHeader3 = fetchFieldLabel('navpeII_dev18__Theme__c', themeField3.split('\\.').get(1)); 
         }
         else if(themeField3.split('\\.').size() == 1){
             respWrapper.themeColumnHeader3 = fetchFieldLabel('navpeII_dev18__Theme_Relation__c', themeField3.split('\\.').get(0));             
         }
     }
     /**** Columns Setting for Themes Grid End****/  
     
     /**** Columns Setting for Clip Grid Start****/
     if(String.isNotBlank(clipField1)){
         if(clipField1.split('\\.').size() == 2){
             respWrapper.clipColumnHeader1 = fetchFieldLabel('navpeII_dev18__Clip__c', clipField1.split('\\.').get(1)); 
         }
         else if(clipField1.split('\\.').size() == 1){
             respWrapper.clipColumnHeader1 = fetchFieldLabel('navpeII_dev18__Theme_Relation__c', clipField1.split('\\.').get(0));             
         }
         
     }
     if(String.isNotBlank(clipField2)){
         if(clipField2.split('\\.').size() == 2){
             respWrapper.clipColumnHeader2 = fetchFieldLabel('navpeII_dev18__Clip__c', clipField2.split('\\.').get(1)); 
         }
         else if(clipField2.split('\\.').size() == 1){
             respWrapper.clipColumnHeader2 = fetchFieldLabel('navpeII_dev18__Theme_Relation__c', clipField2.split('\\.').get(0));             
         }
     }
     if(String.isNotBlank(clipField3)){
         if(clipField3.split('\\.').size() == 2){
             respWrapper.clipColumnHeader3 = fetchFieldLabel('navpeII_dev18__Clip__c', clipField3.split('\\.').get(1)); 
         }
         else if(clipField3.split('\\.').size() == 1){
             respWrapper.clipColumnHeader3 = fetchFieldLabel('navpeII_dev18__Theme_Relation__c', clipField3.split('\\.').get(0));             
         }
     }
     /**** Columns Setting for Clip Grid End****/
     List<id> emptyIdList = new List<id>(); //Added by Tejaswini 00033368
     List<ConWrapper> accInfo = new List<ConWrapper>();
     List<ConWrapper> conInfo = new List<ConWrapper>();
     List<ConWrapper> dealInfo = new List<ConWrapper>();
     List<ConWrapper> fundInfo = new List<ConWrapper>();
     List<ConWrapper> fdrInfo = new List<ConWrapper>();
     List<ConWrapper> themeInfo = new List<ConWrapper>();
     List<ConWrapper> clipInfo = new List<ConWrapper>();
     Map<String, RecordType> mapRecordTypeIdVsName = new Map<String, RecordType>();
     Map<String, Account> mapAccountIdVsName = new Map<String, Account>();
     Map<String, navpeII_dev18__Fund__c> mapFundIdVsName = new Map<String, navpeII_dev18__Fund__c>();
     String themeRecordId = '%'+recordId+'%'; //Bug -00045768 Manonit Theme Page Load Issue Fix Phase 2
        
     Map<String, String> mapActIdVSActRecTask = new Map<String, String>();
     /*for(Task thisTask:[SELECT ID,Subject,Description,navpeII_dev18__Related_Associations__c FROM Task where Related_Associations__c != null AND Related_Associations__c Like :themeRecordId WITH SECURITY_ENFORCED Order By CreatedDate DESC LIMIT :(Limits.getLimitQueryRows() - Limits.getQueryRows())]){
         mapActIdVSActRecTask.put(thisTask.Id, thisTask.Description);
     }*///00045768 Bug Fix By Manonit
     Map<String, String> mapActIdVSActRecEvent = new Map<String, String>();
     /*for(Event thisEvent:[SELECT ID,Subject,Description,navpeII_dev18__Related_Associations__c FROM Event where Related_Associations__c != null AND Related_Associations__c Like :themeRecordId WITH SECURITY_ENFORCED Order By CreatedDate DESC LIMIT :(Limits.getLimitQueryRows() - Limits.getQueryRows()) ]){
         mapActIdVSActRecEvent.put(thisEvent.Id, thisEvent.Description);
     }*///00045768 Bug Fix By Manonit
        mapRecordTypeIdVsName = fetchRecordTypeInfo();
	   if(Schema.sObjectType.Theme_Relation__c.isAccessible()){ // Added by Hema - W.R.T Security Fix
     ////Added by Tejaswini - 00033368
     if(sorting == 'all' || sorting == 'account'){ //added by Tejaswini - 00034976
	 if((Schema.getGlobalDescribe().get('Account').getDescribe().isAccessible())){ // Added by Hema - W.R.T Security Fix
         if(idToSort != '' && idToSort != null){
             List<String> idToSortList=new List<String>();
             if(idToSort.contains(','))
                 idToSortList=idToSort.split(',');
             else
                 idToSortList.add(idToSort);
             respWrapper.accRecList = fetchSObjectData(accField1, accField2, accField3, accField4, '', '', 'navpeII_dev18__Account__r.navpeII_dev18__Last_Touchpoint__c, navpeII_dev18__Account__r.navpeII_dev18__Last_Touchpoint_ID__c, navpeII_dev18__Account__c, navpeII_dev18__Account__r.RecordTypeId', 'navpeII_dev18__Theme_Relation__c', ' WHERE navpeII_dev18__Theme__c =:recordId AND navpeII_dev18__Account__c != Null AND navpeII_dev18__Account__c IN: idsToSort ',idToSortList, recordId, orderbyClauseFirm);
         }
         else{           
             respWrapper.accRecList = fetchSObjectData(accField1, accField2, accField3, accField4, '', '', 'navpeII_dev18__Account__r.navpeII_dev18__Last_Touchpoint__c, navpeII_dev18__Account__r.navpeII_dev18__Last_Touchpoint_ID__c, navpeII_dev18__Account__c, navpeII_dev18__Account__r.RecordTypeId', 'navpeII_dev18__Theme_Relation__c', ' WHERE navpeII_dev18__Theme__c =:recordId AND navpeII_dev18__Account__c != Null',emptyIdList, recordId, orderbyClauseFirm);
 
         }
         System.debug('@@@@@ACCREC'+respWrapper.accRecList);
         //Bug Fix By Manonit 46125 --Start
         set<String> interactionIdAcc = new set<String>();
                 for(sObject accRec : respWrapper.accRecList){
                    interactionIdAcc.add(Schema.SObjectType.Account.Fields.Last_Touchpoint_ID__c.isAccessible()?((String.valueOf(accRec.getSObject('navpeII_dev18__Account__r').get('navpeII_dev18__Last_Touchpoint_ID__c')) != Null)?String.valueOf(accRec.getSObject('navpeII_dev18__Account__r').get('navpeII_dev18__Last_Touchpoint_ID__c')):''):'');
        }
          for(Task thisTask:[SELECT ID,Subject,Description,navpeII_dev18__Related_Associations__c FROM Task where Id IN :interactionIdAcc WITH SECURITY_ENFORCED Order By CreatedDate DESC LIMIT :(Limits.getLimitQueryRows() - Limits.getQueryRows())]){
           mapActIdVSActRecTask.put(thisTask.Id, thisTask.Description);
         }
        for(Event thisEvent:[SELECT ID,Subject,Description,navpeII_dev18__Related_Associations__c FROM Event where Id IN :interactionIdAcc WITH SECURITY_ENFORCED Order By CreatedDate DESC LIMIT :(Limits.getLimitQueryRows() - Limits.getQueryRows()) ]){
         mapActIdVSActRecEvent.put(thisEvent.Id, thisEvent.Description);
        }
        //Bug Fix By Manonit 46125 --End


     for(sObject accRec : respWrapper.accRecList){
	 if(Schema.SObjectType.Theme_Relation__c.Fields.Account__c.isAccessible()){ //Added by Hema - W.R.T Security Fix
         ConWrapper conWrapper 	       = new ConWrapper();
         conWrapper.themeRecId          = String.valueOf(accRec.get('Id'));
         conWrapper.accId 	           =  String.valueOf(accRec.get('navpeII_dev18__Account__c'));
         conWrapper.accName 	           = (accField1.split('__r.').size() == 2)?String.valueOf(accRec.getSObject('navpeII_dev18__Account__r').get(accField1.split('__r.').get(1))):String.valueOf(accRec.get(accField1));
         conWrapper.accNameRef          = '/'+conWrapper.accId;
         conWrapper.logNoteIcon         = 'utility:new_direct_message';
         conWrapper.actId               = Schema.SObjectType.Account.Fields.Last_Touchpoint_ID__c.isAccessible()?((String.valueOf(accRec.getSObject('navpeII_dev18__Account__r').get('navpeII_dev18__Last_Touchpoint_ID__c')) != Null)?String.valueOf(accRec.getSObject('navpeII_dev18__Account__r').get('navpeII_dev18__Last_Touchpoint_ID__c')):''):'';
         String lastInteractionNotes;
         if( Schema.SObjectType.Account.Fields.Last_Touchpoint_ID__c.isAccessible()   && String.valueOf(accRec.getSObject('navpeII_dev18__Account__r').get('navpeII_dev18__Last_Touchpoint_ID__c')) != Null){
             if(String.valueOf(accRec.getSObject('navpeII_dev18__Account__r').get('navpeII_dev18__Last_Touchpoint_ID__c')).startsWith('00T')){
                 if(mapActIdVSActRecTask.containsKey(String.valueOf(accRec.getSObject('navpeII_dev18__Account__r').get('navpeII_dev18__Last_Touchpoint_ID__c'))))
                     lastInteractionNotes = mapActIdVSActRecTask.get(String.valueOf(accRec.getSObject('navpeII_dev18__Account__r').get('navpeII_dev18__Last_Touchpoint_ID__c'))) ;   
             }
             else{
                 if(mapActIdVSActRecEvent.containsKey(String.valueOf(accRec.getSObject('navpeII_dev18__Account__r').get('navpeII_dev18__Last_Touchpoint_ID__c')))) // Anurag - 37930
                     lastInteractionNotes = mapActIdVSActRecEvent.get(String.valueOf(accRec.getSObject('navpeII_dev18__Account__r').get('navpeII_dev18__Last_Touchpoint_ID__c')));    
             }
             
         }
         conWrapper.actSubject 		   = lastInteractionNotes;
         conWrapper.lastInteractionDate = Schema.SObjectType.Account.Fields.Last_Touchpoint__c.isAccessible()? ((accRec.getSObject('navpeII_dev18__Account__r').get('navpeII_dev18__Last_Touchpoint__c')!=null)?String.valueOf(Date.valueOf(String.valueOf(accRec.getSObject('navpeII_dev18__Account__r').get('navpeII_dev18__Last_Touchpoint__c'))).format()):''):'';//Changed for formatting : Critical Bug by TG //String.valueOf(accRec.getSObject('Account__r').get('Last_Touchpoint__c'));
         conWrapper.accDesc             =  (fieldisAccessible(accField2)) ? (accField2.split('__r.').size() == 2)?String.valueOf(accRec.getSObject('navpeII_dev18__Account__r').get(accField2.split('__r.').get(1))):String.valueOf(accRec.get(accField2)):''; // Fixed as part of 00039349- Hema
         conWrapper.accEntityType       = (fieldisAccessible(accField3)) ?  ((accField3.split('__r.').size() == 2)?String.valueOf(accRec.getSObject('navpeII_dev18__Account__r').get(accField3.split('__r.').get(1))):String.valueOf(accRec.get(accField3))):'';
         // Modified by Hema W.r.t Locale Changes- Start
         // String temDate = String.valueOf(accRec.get(accField4)).SubStringBefore(',');
         Date tempDate = DateTime.parse(String.valueOf(accRec.get(accField4))).date();
         if(!Test.isRunningTest()){
            conWrapper.themeDate           =  tempDate.format();//Date.parse(temDate).format();
         }// Modified by Hema W.r.t Locale Changes- End
         
         conWrapper.recId2= (mapRecordTypeIdVsName.containsKey(String.valueOf(accRec.getSObject('navpeII_dev18__Account__r').get('RecordTypeId'))))?String.valueOf(mapRecordTypeIdVsName.get(String.valueOf(accRec.getSObject('navpeII_dev18__Account__r').get('RecordTypeId'))).Name):'';
         accInfo.add(conWrapper);
     }
	 }
	 }
     }
     //Added by tejaswini - 00033368
     if(sorting == 'all' || sorting == 'contact'){ //added by Tejaswini - 00034976/00033368
	 if((Schema.getGlobalDescribe().get('Contact').getDescribe().isAccessible())){ // Added by Hema - W.R.T Security Fix
     if(idToSort != '' && idToSort != null){
             List<String> idToSortList=new List<String>();
             if(idToSort.contains(','))
                 idToSortList=idToSort.split(',');
             else
                 idToSortList.add(idToSort);
                 System.debug('@@@@@'+idToSortList+'@@'+recordId);
             respWrapper.conRecList = fetchSObjectData(conField1, conField2, conField3, conField4,'', '', 'Contact__c, Contact__r.navpeII_dev18__Last_Touchpoint_ID__c, Contact__r.navpeII_dev18__Last_Touch_Point__c,navpeII_dev18__Contact__r.RecordTypeId', 'navpeII_dev18__Theme_Relation__c', ' WHERE navpeII_dev18__Theme__c =:recordId AND navpeII_dev18__Contact__c != Null AND navpeII_dev18__Contact__c IN: idsToSort ',idToSortList, recordId, orderbyClauseContact);
          

             //respWrapper.accRecList = fetchSObjectData(accField1, accField2, accField3, accField4, '', '', 'navpeII_dev18__Account__r.navpeII_dev18__Last_Touchpoint__c, navpeII_dev18__Account__r.navpeII_dev18__Last_Touchpoint_ID__c, navpeII_dev18__Account__c, navpeII_dev18__Account__r.RecordTypeId', 'navpeII_dev18__Theme_Relation__c', ' WHERE navpeII_dev18__Theme__c =:recordId AND navpeII_dev18__Account__c != Null AND navpeII_dev18__Account__c IN: idsToSort ',idToSortList, recordId, orderbyClauseFirm);
         }
         else{   
          respWrapper.conRecList = fetchSObjectData(conField1, conField2, conField3, conField4,'', '', 'Contact__c, Contact__r.navpeII_dev18__Last_Touchpoint_ID__c, Contact__r.navpeII_dev18__Last_Touch_Point__c,navpeII_dev18__Contact__r.RecordTypeId', 'navpeII_dev18__Theme_Relation__c', ' WHERE navpeII_dev18__Theme__c =:recordId AND navpeII_dev18__Contact__c != Null',emptyIdList, recordId, orderbyClauseContact);
            }//Added by Tejaswini - 00034089
     Set<Id> accIdSet = new Set<Id>();
     for(sObject conRec : respWrapper.conRecList){
         accIdSet.add( Schema.SObjectType.Account.isAccessible()?String.valueOf(conRec.getSObject('navpeII_dev18__Contact__r').get('AccountId')):'');
     }
     SObject so = Schema.getGlobalDescribe().get('Contact').newSObject();
     
     mapAccountIdVsName = fetchAccountInfoList(accIdSet);
     /* Bug Fix By Manonit 46125 */
      set<String> interactionIdCon = new set<String>();
                 for(sObject conRec : respWrapper.conRecList){
                    interactionIdCon.add(Schema.SObjectType.Contact.Fields.Last_Touchpoint_ID__c.isAccessible()?String.valueOf(conRec.getSObject('navpeII_dev18__Contact__r').get('navpeII_dev18__Last_Touchpoint_ID__c')):'');
        }
          for(Task thisTask:[SELECT ID,Subject,Description,navpeII_dev18__Related_Associations__c FROM Task where Id IN :interactionIdCon WITH SECURITY_ENFORCED Order By CreatedDate DESC LIMIT :(Limits.getLimitQueryRows() - Limits.getQueryRows())]){
           mapActIdVSActRecTask.put(thisTask.Id, thisTask.Description);
         }
        for(Event thisEvent:[SELECT ID,Subject,Description,navpeII_dev18__Related_Associations__c FROM Event where Id IN :interactionIdCon WITH SECURITY_ENFORCED Order By CreatedDate DESC LIMIT :(Limits.getLimitQueryRows() - Limits.getQueryRows()) ]){
         mapActIdVSActRecEvent.put(thisEvent.Id, thisEvent.Description);
     }
     //Bug Fix By Manonit 46125 --End
     for(sObject conRec : respWrapper.conRecList){
	 if(Schema.SObjectType.Theme_Relation__c.Fields.Contact__c.isAccessible()){   //Added by Hema - W.R.T Security Fix
         ConWrapper conWrapper = new ConWrapper();
         conWrapper.themeRecId = String.valueOf(conRec.get('Id'));
         conWrapper.conId = String.valueOf(conRec.get('navpeII_dev18__Contact__c'));
         conWrapper.conName = (conField1.split('__r.').size() == 2)?String.valueOf(conRec.getSObject('navpeII_dev18__Contact__r').get(conField1.split('__r.').get(1))):String.valueOf(conRec.get(conField1));
         conWrapper.conNameRef = '/'+String.valueOf(conRec.get('navpeII_dev18__Contact__c'));
         conWrapper.accId =  (Schema.SObjectType.Account.isAccessible() && Schema.sObjectType.Theme_Relation__c.Fields.Account__c.isAccessible())? String.valueOf(conRec.getSObject('navpeII_dev18__Contact__r').get('AccountId')):'';
         //Commented by Tejaswini - 00033368
         //mapAccountIdVsName = fetchAccountInfo(conWrapper.accId);
         String accName;
         if(Schema.SObjectType.Account.isAccessible() && Schema.sObjectType.Theme_Relation__c.Fields.Account__c.isAccessible() &&  conField2.split('\\.').size() == 3){
             if(mapAccountIdVsName.containsKey(String.valueOf(conRec.getSObject('navpeII_dev18__Contact__r').get('AccountId')))){
                 accName = String.valueOf(mapAccountIdVsName.get(String.valueOf(conRec.getSObject('navpeII_dev18__Contact__r').get('AccountId'))).get(conField2.split('\\.').get(2)));        
             }
             
         }
         else if(Schema.SObjectType.Account.isAccessible() && Schema.sObjectType.Theme_Relation__c.Fields.Account__c.isAccessible() &&  conField2.split('\\.').size() == 2){
             accName = String.valueOf(conRec.getSObject('navpeII_dev18__Contact__r').get(conField2.split('__r.').get(1)));
         }
         conWrapper.accName = accName;
         if(conWrapper.accId != null && conWrapper.accId !=''){
             conWrapper.accNameRef = '/'+conWrapper.accId;
         }
         else{
             conWrapper.accNameRef = '';    
         }
         conWrapper.accDesc = (fieldisAccessible(conField3)) ?(conField3.split('__r.').size() == 2)?String.valueOf(conRec.getSObject('navpeII_dev18__Contact__r').get(conField3.split('__r.').get(1))):String.valueOf(conRec.get(conField3)):'';// Fixed as part of 00039349- Hema
         // Modified by Hema W.r.t Locale Changes- Start
         // String temDate1 = String.valueOf(conRec.get(conField4)).SubStringBefore(',');
         Date temDate1 = DateTime.parse(String.valueOf(conRec.get(conField4))).date();
         if(!Test.isRunningTest()){
             conWrapper.themeDate = temDate1.format(); // Date.parse(temDate1).format();
         }// Modified by Hema W.r.t Locale Changes- End
         conWrapper.logNoteIcon = 'utility:new_direct_message';
         conWrapper.actId = Schema.SObjectType.Contact.Fields.Last_Touchpoint_ID__c.isAccessible()?String.valueOf(conRec.getSObject('navpeII_dev18__Contact__r').get('navpeII_dev18__Last_Touchpoint_ID__c')):'';
         String lastInteractionNotes;
         if(Schema.SObjectType.Contact.Fields.Last_Touchpoint_ID__c.isAccessible() && String.valueOf(conRec.getSObject('navpeII_dev18__Contact__r').get('navpeII_dev18__Last_Touchpoint_ID__c')) != Null){
             if(String.valueOf(conRec.getSObject('navpeII_dev18__Contact__r').get('navpeII_dev18__Last_Touchpoint_ID__c')).startsWith('00T')){
                 if(mapActIdVSActRecTask.containsKey(String.valueOf(conRec.getSObject('navpeII_dev18__Contact__r').get('navpeII_dev18__Last_Touchpoint_ID__c'))))
                     lastInteractionNotes = mapActIdVSActRecTask.get(String.valueOf(conRec.getSObject('navpeII_dev18__Contact__r').get('navpeII_dev18__Last_Touchpoint_ID__c'))) ;   
             }
             else{
                 if(mapActIdVSActRecEvent.containsKey(String.valueOf(conRec.getSObject('navpeII_dev18__Contact__r').get('navpeII_dev18__Last_Touchpoint_ID__c'))))// Anurag - 37930
                     lastInteractionNotes = mapActIdVSActRecEvent.get(String.valueOf(conRec.getSObject('navpeII_dev18__Contact__r').get('navpeII_dev18__Last_Touchpoint_ID__c')));    
             }
             
         }
         conWrapper.actSubject = lastInteractionNotes;
         conWrapper.lastInteractionDate = Schema.SObjectType.Contact.Fields.navpeII_dev18__Last_Touch_Point__c.isAccessible()?((String.valueOf(conRec.getSObject('navpeII_dev18__Contact__r').get('navpeII_dev18__Last_Touch_Point__c')) != null)?String.valueOf(Date.valueOf(String.valueOf(conRec.getSObject('navpeII_dev18__Contact__r').get('navpeII_dev18__Last_Touch_Point__c'))).format()):''):'';//Changed for formatting : Critical Bug by TG
         //String.valueOf(conRec.getSObject('Contact__r').get('navpeII_dev18__Last_Touch_Point__c'));
         if(so.getSobjectType().getDescribe().fields.getMap().containsKey('RecordTypeId')){
         conWrapper.recId2 = (mapRecordTypeIdVsName.containsKey(String.valueOf(conRec.getSObject('navpeII_dev18__Contact__r').get('RecordTypeId'))))?String.valueOf(mapRecordTypeIdVsName.get(String.valueOf(conRec.getSObject('navpeII_dev18__Contact__r').get('RecordTypeId'))).Name):'';
         }
         else{
          conWrapper.recId2=null;   
         }
         conInfo.add(conWrapper);
     }   
    }
	}
 }
 //Added by Tejaswini - 00033368
 if(sorting == 'all' || sorting == 'deal'){ //added by Tejaswini - 00034976
  if((Schema.getGlobalDescribe().get('navpeII_dev18__Pipeline__c').getDescribe().isAccessible())){ // Added by Hema - W.R.T Security Fix

      if(idToSort != '' && idToSort != null){
             List<String> idToSortList=new List<String>();
             if(idToSort.contains(','))
                 idToSortList=idToSort.split(',');
             else
                 idToSortList.add(idToSort);
                 System.debug('@@@@@'+idToSortList+'@@'+recordId);
            // respWrapper.conRecList = fetchSObjectData(conField1, conField2, conField3, conField4,'', '', 'Contact__c, Contact__r.navpeII_dev18__Last_Touchpoint_ID__c, Contact__r.navpeII_dev18__Last_Touch_Point__c,navpeII_dev18__Contact__r.RecordTypeId', 'navpeII_dev18__Theme_Relation__c', ' WHERE navpeII_dev18__Theme__c =:recordId AND navpeII_dev18__Contact__c != Null ',idToSortList, recordId, orderbyClauseContact);
             respWrapper.dealRecList = fetchSObjectData(dealField1, dealField2, dealField3, dealField4, dealField5, dealField6, 'CreatedDate, Deal__c,navpeII_dev18__Deal__r.RecordTypeId', 'navpeII_dev18__Theme_Relation__c', ' WHERE navpeII_dev18__Theme__c =:recordId AND navpeII_dev18__Deal__c != Null AND navpeII_dev18__Deal__c IN: idsToSort',idToSortList, recordId, orderbyClauseDeal);
    

             //respWrapper.accRecList = fetchSObjectData(accField1, accField2, accField3, accField4, '', '', 'navpeII_dev18__Account__r.navpeII_dev18__Last_Touchpoint__c, navpeII_dev18__Account__r.navpeII_dev18__Last_Touchpoint_ID__c, navpeII_dev18__Account__c, navpeII_dev18__Account__r.RecordTypeId', 'navpeII_dev18__Theme_Relation__c', ' WHERE navpeII_dev18__Theme__c =:recordId AND navpeII_dev18__Account__c != Null AND navpeII_dev18__Account__c IN: idsToSort ',idToSortList, recordId, orderbyClauseFirm);
         }
         else{   
          respWrapper.dealRecList = fetchSObjectData(dealField1, dealField2, dealField3, dealField4, dealField5, dealField6, 'CreatedDate, Deal__c,navpeII_dev18__Deal__r.RecordTypeId', 'navpeII_dev18__Theme_Relation__c', ' WHERE navpeII_dev18__Theme__c =:recordId AND navpeII_dev18__Deal__c != Null',emptyIdList, recordId, orderbyClauseDeal);
      } 
    //respWrapper.dealRecList = fetchSObjectData(dealField1, dealField2, dealField3, dealField4, dealField5, dealField6, 'CreatedDate, Deal__c,navpeII_dev18__Deal__r.RecordTypeId', 'navpeII_dev18__Theme_Relation__c', ' WHERE navpeII_dev18__Theme__c =:recordId AND navpeII_dev18__Deal__c != Null',emptyIdList, recordId, orderbyClauseDeal);
     //Added by Tejaswini - 00034089
     Set<Id> accIdSet = new Set<Id>();
     for(sObject dealRec : respWrapper.dealRecList){
         accIdSet.add(Schema.SObjectType.Account.isAccessible()?String.valueOf(dealRec.getSObject('Deal__r').get('navpeII_dev18__Company__c')):'');
     }
     SObject so = Schema.getGlobalDescribe().get('navpeII_dev18__Pipeline__c').newSObject();
     
     mapAccountIdVsName = fetchAccountInfoList(accIdSet);
     for(sObject dealRec : respWrapper.dealRecList){
	 if(Schema.SObjectType.Theme_Relation__c.Fields.Deal__c.isAccessible()){   //Added by Hema - W.R.T Security Fix
         ConWrapper dealWrapper = new ConWrapper();
         dealWrapper.themeRecId = String.valueOf(dealRec.get('Id'));
         dealWrapper.dealId = String.valueOf(dealRec.get('Deal__c'));
         dealWrapper.dealName = (dealField1.split('__r.').size() == 2)?String.valueOf(dealRec.getSObject('Deal__r').get(dealField1.split('__r.').get(1))):String.valueOf(dealRec.get(dealField1));
         dealWrapper.dealNameRef = '/'+dealWrapper.dealId;
         dealWrapper.accId = (Schema.SObjectType.Account.isAccessible() && Schema.sObjectType.Theme_Relation__c.Fields.Account__c.isAccessible())?String.valueOf(dealRec.getSObject('Deal__r').get('navpeII_dev18__Company__c')):'';
         //Commented by Tejaswini - 00033368
         //mapAccountIdVsName = fetchAccountInfo(dealWrapper.accId);
         String accName;
         if(Schema.SObjectType.Account.isAccessible() && Schema.sObjectType.Theme_Relation__c.Fields.Account__c.isAccessible() && dealField2.split('\\.').size() == 3){
             if(mapAccountIdVsName.containsKey(String.valueOf(dealRec.getSObject('Deal__r').get('navpeII_dev18__Company__c')))){
                 accName = String.valueOf(mapAccountIdVsName.get(String.valueOf(dealRec.getSObject('Deal__r').get('navpeII_dev18__Company__c'))).get(dealField2.split('\\.').get(2)));  
             }
         }
         else if( Schema.SObjectType.Account.isAccessible() && Schema.sObjectType.Theme_Relation__c.Fields.Account__c.isAccessible() && dealField2.split('\\.').size() == 2){
             accName = String.valueOf(dealRec.getSObject('Deal__r').get(dealField2.split('__r.').get(1)));
         }
 
         dealWrapper.accName = accName;
         if(dealWrapper.accId != Null){
             dealWrapper.accNameRef = '/'+dealWrapper.accId;    
         }
         else{
             dealWrapper.accNameRef = '';    
         }
         
         dealWrapper.dealStage =  (fieldisAccessible(dealField3)) ?  ( (dealField3.split('__r.').size() == 2)?String.valueOf(dealRec.getSObject('Deal__r').get(dealField3.split('__r.').get(1))):String.valueOf(dealRec.get(dealField3))):'';
         dealWrapper.dealComments = (fieldisAccessible(dealField4)) ? ((dealField4.split('__r.').size() == 2)?String.valueOf(dealRec.getSObject('Deal__r').get(dealField4.split('__r.').get(1))):String.valueOf(dealRec.get(dealField4))):'';
         dealWrapper.dealDateRec = (fieldisAccessible(dealField5)) ? ((dealField5.split('__r.').size() == 2)?String.valueOf(dealRec.getSObject('Deal__r').get(dealField5.split('__r.').get(1))):String.valueOf(dealRec.get(dealField5))):'';
         dealWrapper.themeDate = Date.valueOf(String.valueOf(dealRec.get(dealField6))).format();
         dealWrapper.logNoteIcon = 'utility:new_direct_message';
         if(so.getSobjectType().getDescribe().fields.getMap().containsKey('RecordTypeId')){
         dealWrapper.recId2 = (mapRecordTypeIdVsName.containsKey(String.valueOf(dealRec.getSObject('navpeII_dev18__Deal__r').get('RecordTypeId'))))?String.valueOf(mapRecordTypeIdVsName.get(String.valueOf(dealRec.getSObject('navpeII_dev18__Deal__r').get('RecordTypeId'))).Name):'';
         }
         else{
             dealWrapper.recId2=null;
         }

         dealInfo.add(dealWrapper);
     }
	 }
	 }
 }
 //Added by Tejaswini - 00033368
 if(sorting == 'all' || sorting == 'fund'){ //added by Tejaswini - 00034976
 if((Schema.getGlobalDescribe().get('navpeII_dev18__Fund__c').getDescribe().isAccessible())){ // Added by Hema - W.R.T Security Fix
  // respWrapper.fundRecList = fetchSObjectData(fundField1, fundField2, fundField3, fundField4, '', '', 'Fund__c,navpeII_dev18__Fund__r.RecordTypeId', 'navpeII_dev18__Theme_Relation__c', ' WHERE navpeII_dev18__Theme__c =:recordId AND navpeII_dev18__Fund__c != Null',null, recordId, orderbyClauseFund);
      
  if(idToSort != '' && idToSort != null){
             List<String> idToSortList=new List<String>();
             if(idToSort.contains(','))
                 idToSortList=idToSort.split(',');
             else
                 idToSortList.add(idToSort);
                 System.debug('@@@@@fundRecList'+idToSortList+'@@'+recordId);
            //respWrapper.dealRecList = fetchSObjectData(dealField1, dealField2, dealField3, dealField4, dealField5, dealField6, 'CreatedDate, Deal__c,navpeII_dev18__Deal__r.RecordTypeId', 'navpeII_dev18__Theme_Relation__c', ' WHERE navpeII_dev18__Theme__c =:recordId AND navpeII_dev18__Deal__c != Null AND navpeII_dev18__Deal__c IN: idsToSort',idToSortList, recordId, orderbyClauseDeal);
            respWrapper.fundRecList = fetchSObjectData(fundField1, fundField2, fundField3, fundField4, '', '', 'Fund__c,navpeII_dev18__Fund__r.RecordTypeId', 'navpeII_dev18__Theme_Relation__c', ' WHERE navpeII_dev18__Theme__c =:recordId AND navpeII_dev18__Fund__c != Null AND navpeII_dev18__Fund__c IN: idsToSort',idToSortList, recordId, orderbyClauseFund);
   

             //respWrapper.accRecList = fetchSObjectData(accField1, accField2, accField3, accField4, '', '', 'navpeII_dev18__Account__r.navpeII_dev18__Last_Touchpoint__c, navpeII_dev18__Account__r.navpeII_dev18__Last_Touchpoint_ID__c, navpeII_dev18__Account__c, navpeII_dev18__Account__r.RecordTypeId', 'navpeII_dev18__Theme_Relation__c', ' WHERE navpeII_dev18__Theme__c =:recordId AND navpeII_dev18__Account__c != Null AND navpeII_dev18__Account__c IN: idsToSort ',idToSortList, recordId, orderbyClauseFirm);
         }
         else{   
          respWrapper.fundRecList = fetchSObjectData(fundField1, fundField2, fundField3, fundField4, '', '', 'Fund__c,navpeII_dev18__Fund__r.RecordTypeId', 'navpeII_dev18__Theme_Relation__c', ' WHERE navpeII_dev18__Theme__c =:recordId AND navpeII_dev18__Fund__c != Null',null, recordId, orderbyClauseFund);
   }
   SObject so = Schema.getGlobalDescribe().get('navpeII_dev18__Fund__c').newSObject();
     
     for(sObject fundRec : respWrapper.fundRecList){
	 if(Schema.SObjectType.Theme_Relation__c.Fields.Fund__c.isAccessible()){
         ConWrapper fundWrapper = new ConWrapper();
         fundWrapper.themeRecId = String.valueOf(fundRec.get('Id'));
         fundWrapper.fundId = String.valueOf(fundRec.get('Fund__c'));
         fundWrapper.fundName = (fundField1.split('__r.').size() == 2)?String.valueOf(fundRec.getSObject('Fund__r').get(fundField1.split('__r.').get(1))):String.valueOf(fundRec.get(fundField1));
         fundWrapper.fundNameRef = '/'+fundWrapper.fundId;
         fundWrapper.fundVintage = (fieldisAccessible(fundField2)) ? ((fundField2.split('__r.').size() == 2)?String.valueOf(fundRec.getSObject('Fund__r').get(fundField2.split('__r.').get(1))):String.valueOf(fundRec.get(fundField2))):'';
         fundWrapper.fundClosingDate = (fieldisAccessible(fundField3)) ?  ((fundField3.split('__r.').size() == 2)?String.valueOf(fundRec.getSObject('Fund__r').get(fundField3.split('__r.').get(1))):String.valueOf(fundRec.get(fundField3))):'';
         // Modified by Hema W.r.t Locale Changes - Start  
         /* String temDate3 = (fundField4.split('__r.').size() == 2)?String.valueOf(fundRec.getSObject('Fund__r').get(fundField4.split('__r.').get(1))):String.valueOf(fundRec.get(fundField4));
         System.debug(temDate3);
         temDate3 = temDate3.SubStringBefore(',');*/
         Date temDate3 = DateTime.parse((fundField4.split('__r.').size() == 2)?String.valueOf(fundRec.getSObject('Fund__r').get(fundField4.split('__r.').get(1))):String.valueOf(fundRec.get(fundField4))).date();     
         fundWrapper.themeDate = temDate3.format();  //Date.parse(temDate3).format();//(fundField4.split('__r.').size() == 2)?String.valueOf(fundRec.getSObject('Fund__r').get(fundField4.split('__r.').get(1))):String.valueOf(fundRec.get(fundField4));
         // Modified by Hema W.r.t Locale Changes- End
         fundWrapper.logNoteIcon = 'utility:new_direct_message';
         if(so.getSobjectType().getDescribe().fields.getMap().containsKey('RecordTypeId')){
         fundWrapper.recId2 = (mapRecordTypeIdVsName.containsKey(String.valueOf(fundRec.getSObject('navpeII_dev18__Fund__r').get('RecordTypeId'))))?String.valueOf(mapRecordTypeIdVsName.get(String.valueOf(fundRec.getSObject('navpeII_dev18__Fund__r').get('RecordTypeId'))).Name):'';
         }
         else{
         fundWrapper.recId2=null;  
         }
         fundInfo.add(fundWrapper);
     }
	 }
	 }
 }
 //Added by Tejaswini - 00033368
 if(sorting == 'all' || sorting == 'fdr'){ //added by Tejaswini - 00034976
  if((Schema.getGlobalDescribe().get('navpeII_dev18__Fundraising__c').getDescribe().isAccessible())){ // Added by Hema - W.R.T Security Fix
     //respWrapper.fundraisingRecList = fetchSObjectData(fdrField1, fdrField2, fdrField3, fdrField4, fdrField5, fdrField6, 'CreatedDate, Fundraising__c,navpeII_dev18__Fundraising__r.RecordTypeId', 'navpeII_dev18__Theme_Relation__c', ' WHERE navpeII_dev18__Theme__c =:recordId AND navpeII_dev18__Fundraising__c != Null',null, recordId, orderbyClauseFundraising);
     if(idToSort != '' && idToSort != null){
             List<String> idToSortList=new List<String>();
             if(idToSort.contains(','))
                 idToSortList=idToSort.split(',');
             else
                 idToSortList.add(idToSort);
                 System.debug('@@@@@fdr'+idToSortList+'@@'+recordId);
            // respWrapper.conRecList = fetchSObjectData(conField1, conField2, conField3, conField4,'', '', 'Contact__c, Contact__r.navpeII_dev18__Last_Touchpoint_ID__c, Contact__r.navpeII_dev18__Last_Touch_Point__c,navpeII_dev18__Contact__r.RecordTypeId', 'navpeII_dev18__Theme_Relation__c', ' WHERE navpeII_dev18__Theme__c =:recordId AND navpeII_dev18__Contact__c != Null ',idToSortList, recordId, orderbyClauseContact);
             //respWrapper.dealRecList = fetchSObjectData(dealField1, dealField2, dealField3, dealField4, dealField5, dealField6, 'CreatedDate, Deal__c,navpeII_dev18__Deal__r.RecordTypeId', 'navpeII_dev18__Theme_Relation__c', ' WHERE navpeII_dev18__Theme__c =:recordId AND navpeII_dev18__Deal__c != Null AND navpeII_dev18__Deal__c IN: idsToSort',idToSortList, recordId, orderbyClauseDeal);
             respWrapper.fundraisingRecList = fetchSObjectData(fdrField1, fdrField2, fdrField3, fdrField4, fdrField5, fdrField6, 'CreatedDate, Fundraising__c,navpeII_dev18__Fundraising__r.RecordTypeId', 'navpeII_dev18__Theme_Relation__c', ' WHERE navpeII_dev18__Theme__c =:recordId AND navpeII_dev18__Fundraising__c != Null AND navpeII_dev18__Fundraising__c IN: idsToSort',idToSortList, recordId, orderbyClauseFundraising);
     

             //respWrapper.accRecList = fetchSObjectData(accField1, accField2, accField3, accField4, '', '', 'navpeII_dev18__Account__r.navpeII_dev18__Last_Touchpoint__c, navpeII_dev18__Account__r.navpeII_dev18__Last_Touchpoint_ID__c, navpeII_dev18__Account__c, navpeII_dev18__Account__r.RecordTypeId', 'navpeII_dev18__Theme_Relation__c', ' WHERE navpeII_dev18__Theme__c =:recordId AND navpeII_dev18__Account__c != Null AND navpeII_dev18__Account__c IN: idsToSort ',idToSortList, recordId, orderbyClauseFirm);
         }
         else{   
          respWrapper.fundraisingRecList = fetchSObjectData(fdrField1, fdrField2, fdrField3, fdrField4, fdrField5, fdrField6, 'CreatedDate, Fundraising__c,navpeII_dev18__Fundraising__r.RecordTypeId', 'navpeII_dev18__Theme_Relation__c', ' WHERE navpeII_dev18__Theme__c =:recordId AND navpeII_dev18__Fundraising__c != Null',null, recordId, orderbyClauseFundraising);
     } 
     
     
     //Added by Tejaswini - 00034089
     Set<Id> accIdSet = new Set<Id>();
     Set<Id> fundIdSet = new Set<Id>(); //Added By manonit for Critical 00041133 Bug
     for(sObject fundRec : respWrapper.fundraisingRecList){
        // Added by Hema - W.R.T Security Fix	
        accIdSet.add(Schema.sObjectType.Account.isAccessible()?(String.valueOf(fundRec.getSObject('Fundraising__r').get('navpeII_dev18__Legal_Name__c'))):null);
        fundIdSet.add((Schema.sObjectType.navpeII_dev18__Fund__c.isAccessible() && Schema.sObjectType.Theme_Relation__c.Fields.Fund__c.isAccessible())? String.valueOf(fundRec.getSObject('Fundraising__r').get('navpeII_dev18__Fund_Name__c')):null);
     }
     mapAccountIdVsName = fetchAccountInfoList(accIdSet);
     mapFundIdVsName = fetchFundInfoList(fundIdSet);

     SObject so = Schema.getGlobalDescribe().get('navpeII_dev18__Fundraising__c').newSObject();
     for(sObject fundRec : respWrapper.fundraisingRecList){
	  if(Schema.SObjectType.Theme_Relation__c.Fields.Fundraising__c.isAccessible()){
         ConWrapper frdWrapper = new ConWrapper();
         frdWrapper.frdId = String.valueOf(fundRec.get('Fundraising__c'));
         frdWrapper.themeRecId = String.valueOf(fundRec.get('Id'));
         frdWrapper.frdName = (fdrField1.split('__r.').size() == 2)?String.valueOf(fundRec.getSObject('Fundraising__r').get(fdrField1.split('__r.').get(1))):String.valueOf(fundRec.get(fdrField1));
         frdWrapper.frdNameRef = '/'+frdWrapper.frdId;
         frdWrapper.accId = (Schema.sObjectType.Account.isAccessible() && Schema.sObjectType.Theme_Relation__c.Fields.Account__c.isAccessible())? String.valueOf(fundRec.getSObject('Fundraising__r').get('navpeII_dev18__Legal_Name__c')):'';
         //Removed by Tejaswini - 00033368
         //mapAccountIdVsName = fetchAccountInfo(frdWrapper.accId);
         String accName;
         if(Schema.sObjectType.Account.isAccessible() && Schema.sObjectType.Theme_Relation__c.Fields.Account__c.isAccessible() && fdrField2.split('\\.').size() == 3){
             if(mapAccountIdVsName.containsKey(String.valueOf(fundRec.getSObject('Fundraising__r').get('navpeII_dev18__Legal_Name__c')))){
                 accName = String.valueOf(mapAccountIdVsName.get(String.valueOf(fundRec.getSObject('Fundraising__r').get('navpeII_dev18__Legal_Name__c'))).get(fdrField2.split('\\.').get(2)));        
             }
         }
         else if(Schema.sObjectType.Account.isAccessible() && Schema.sObjectType.Theme_Relation__c.Fields.Account__c.isAccessible() &&  fdrField2.split('\\.').size() == 2){
             accName = String.valueOf(fundRec.getSObject('Fundraising__r').get(fdrField2.split('__r.').get(1)));
         }
         frdWrapper.accName = (accName!= Null && accName != '') ? accName:'';
         if(frdWrapper.accId != Null && frdWrapper.accId != ''){
             frdWrapper.accNameRef = '/'+frdWrapper.accId;    
         }
         else{
             frdWrapper.accNameRef = '';    
         }
         //Changed By Manonit for 00041133 and 46160 criical BugFix 
         frdWrapper.fundId =  (Schema.sObjectType.navpeII_dev18__Fund__c.isAccessible() && Schema.sObjectType.Theme_Relation__c.Fields.Fund__c.isAccessible())? String.valueOf(fundRec.getSObject('Fundraising__r').get('navpeII_dev18__Fund_Name__c')):'';
         //mapFundIdVsName = fetchFundInfo(frdWrapper.fundId);*/
         String fundName;
         if(Schema.sObjectType.navpeII_dev18__Fund__c.isAccessible() && Schema.sObjectType.Theme_Relation__c.Fields.Fund__c.isAccessible() &&  fdrField3.split('\\.').size() == 3){
             if(mapFundIdVsName.containsKey(String.valueOf(fundRec.getSObject('Fundraising__r').get('navpeII_dev18__Fund_Name__c')))){
                 fundName = String.valueOf(mapFundIdVsName.get(String.valueOf(fundRec.getSObject('Fundraising__r').get('navpeII_dev18__Fund_Name__c'))).get(fdrField3.split('\\.').get(2)));       
             }
         }
         else if(Schema.sObjectType.navpeII_dev18__Fund__c.isAccessible() && Schema.sObjectType.Theme_Relation__c.Fields.Fund__c.isAccessible() &&  fdrField3.split('\\.').size() == 2){
             fundName = String.valueOf(fundRec.getSObject('Fundraising__r').get(fdrField3.split('__r.').get(1)));
         }
         frdWrapper.fundName = (fundName!= Null && fundName != '') ?fundName :'';
         if(frdWrapper.fundId != Null && frdWrapper.fundId != ''){
             frdWrapper.fundNameRef = '/'+frdWrapper.fundId;    
         }
         else{
             frdWrapper.fundNameRef = '';    
         }
         
         frdWrapper.frdStage = fieldisAccessible(fdrField4) ? ( (fdrField4.split('__r.').size() == 2)?String.valueOf(fundRec.getSObject('Fundraising__r').get(fdrField4.split('__r.').get(1))):String.valueOf(fundRec.get(fdrField4))):'';
         frdWrapper.frdStatusNote = fieldisAccessible(fdrField5) ? ((fdrField5.split('__r.').size() == 2)?String.valueOf(fundRec.getSObject('Fundraising__r').get(fdrField5.split('__r.').get(1))):String.valueOf(fundRec.get(fdrField5))):'';
         frdWrapper.themeDate = Date.valueOf((fdrField6.split('__r.').size() == 2)?String.valueOf(fundRec.getSObject('Fundraising__r').get(fdrField6.split('__r.').get(1))):String.valueOf(fundRec.get(fdrField6))).format();
         frdWrapper.logNoteIcon = 'utility:new_direct_message';

        if(so.getSobjectType().getDescribe().fields.getMap().containsKey('RecordTypeId')){
        frdWrapper.recId2 = (mapRecordTypeIdVsName.containsKey(String.valueOf(fundRec.getSObject('navpeII_dev18__Fundraising__r').get('RecordTypeId'))))?String.valueOf(mapRecordTypeIdVsName.get(String.valueOf(fundRec.getSObject('navpeII_dev18__Fundraising__r').get('RecordTypeId'))).Name):'';
        }
        else{
          frdWrapper.recId2=null;  
        }
        fdrInfo.add(frdWrapper);
         
     }
	 }
	 }
 }
     //Added by Tejaswini - 00033368
	  if((Schema.getGlobalDescribe().get('navpeII_dev18__Theme__c').getDescribe().isAccessible())){ // Added by Hema - W.R.T Security Fix
     respWrapper.themesRecList = fetchSObjectData(themeField1, themeField2, themeField3, '', '', '', 'Other_Theme__c', 'navpeII_dev18__Theme_Relation__c', ' WHERE navpeII_dev18__Theme__c =:recordId AND navpeII_dev18__Other_Theme__c != Null',null, recordId, '');
      //Added by Hema - 00038811 Merged by Manonit
          Map<String,sObject> themeRecordsMap = new Map<String,sObject>(); 
          for(sObject themeRec : respWrapper.themesRecList){
           String themeNameRec=  (themeField1.split('__r.').size() == 2)?String.valueOf(themeRec.getSObject('Other_Theme__r').get(themeField1.split('__r.').get(1))):String.valueOf(themeRec.get(themeField1));
             if(!themeRecordsMap.containsKey(themeNameRec) && currentThemeName != themeNameRec ){
                themeRecordsMap.put(themeNameRec,themeRec);
             }
         }     
     
     for(sObject themeRec : themeRecordsMap.values()){ //Modified by Hema - 00038811
	 if(Schema.SObjectType.Theme_Relation__c.Fields.Other_Theme__c.isAccessible()){
         ConWrapper themeWrapper = new ConWrapper();
         themeWrapper.themeRecId = String.valueOf(themeRec.get('Id'));
         themeWrapper.themeId = String.valueOf(themeRec.get('Other_Theme__c'));
         themeWrapper.subject = (themeField1.split('__r.').size() == 2)?String.valueOf(themeRec.getSObject('Other_Theme__r').get(themeField1.split('__r.').get(1))):String.valueOf(themeRec.get(themeField1));
         themeWrapper.subjectRef = '/'+themeWrapper.themeId;
         themeWrapper.description =  (fieldisAccessible(themeField2)) ? ((themeField2.split('__r.').size() == 2)?String.valueOf(themeRec.getSObject('Other_Theme__r').get(themeField2.split('__r.').get(1))):String.valueOf(themeRec.get(themeField2))):'';
         themeWrapper.logNoteIcon = 'utility:new_direct_message';
         themeInfo.add(themeWrapper);
     }
	 }
	 }
     //Added by Tejaswini - 00033368
	 if((Schema.getGlobalDescribe().get('navpeII_dev18__Clip__c').getDescribe().isAccessible())){ // Added by Hema - W.R.T Security Fix
     respWrapper.clipRecList = fetchSObjectData(clipField1, clipField2, clipField3, '', '', '', 'Clip__c', 'navpeII_dev18__Theme_Relation__c', ' WHERE navpeII_dev18__Theme__c =:recordId AND navpeII_dev18__Clip__c != Null',null, recordId, '');
     for(sObject clipRec : respWrapper.clipRecList){
	 if(Schema.SObjectType.Theme_Relation__c.Fields.Clip__c.isAccessible()){
         ConWrapper clipWrapper = new ConWrapper();
         clipWrapper.themeRecId = String.valueOf(clipRec.get('Id'));
         clipWrapper.clipId = String.valueOf(clipRec.get('Clip__c'));
         clipWrapper.subject = (clipField1.split('__r.').size() == 2)?String.valueOf(clipRec.getSObject('Clip__r').get(clipField1.split('__r.').get(1))):String.valueOf(clipRec.get(clipField1));
         clipWrapper.subjectRef = '/'+clipWrapper.clipId;
         clipWrapper.description = (fieldisAccessible(clipField2)) ?  ((clipField2.split('__r.').size() == 2)?String.valueOf(clipRec.getSObject('Clip__r').get(clipField2.split('__r.').get(1))):String.valueOf(clipRec.get(clipField2))):'';
         clipWrapper.logNoteIcon = 'utility:new_direct_message';
         clipInfo.add(clipWrapper);
     }
	 }
	 }
	 }
     respWrapper.conInfoWrapper = accInfo;
     respWrapper.contactInfoWrapper = conInfo;
     respWrapper.dealInfoWrapper = dealInfo;
     respWrapper.fundInfoWrapper = fundInfo;
     respWrapper.fdrInfoWrapper = fdrInfo;
     respWrapper.themeInfoWrapper = themeInfo;
     respWrapper.clipInfoWrapper = clipInfo;
     
     
     return respWrapper;
 }
 
 
 /*
     * Purpose : Fetches initial data to be used for further processing
     * Input : metadataField1    [Field 1 to process for Fundraising Contacts Section]
     *         metadataField2    [Field 2 to process for Fundraising Contacts Section]
     * 		   metadataField3    [Field 3 to process for Fundraising Contacts Section]
     *         objName           [Object to query data from]
     *         whereClause       [Where clause to be used in the SOQL query]
     *         recordId          [Record ID of the current record (Theme)]
     * Returns : Initial data to be used for further processing as a List<sObject>
     */
     //Added by Tejaswini - 00033368
 public static List<sObject> fetchSObjectData(String metadataField1, String metadataField2, String metadataField3, String metadataField4, String metadataField5, String metadataField6, String queryString, String objName, String whereClause,List<String> idsToSort, String recordId, String orderByClause){
     try {
         String fieldStr = metadataField1; 
         if(String.isNotBlank(metadataField1)  && fieldisAccessible(metadataField1)){
             fieldStr = ', FORMAT(' + metadataField1 + ')';
         }
         if(String.isNotBlank(metadataField1) && String.isNotBlank(metadataField2)  && fieldisAccessible(metadataField2)){
             fieldStr += ', FORMAT(' + metadataField2 + ')';
         }
         if(String.isNotBlank(metadataField1) && String.isNotBlank(metadataField2) && String.isNotBlank(metadataField3)  && fieldisAccessible(metadataField3)){
             fieldStr += ', FORMAT(' + metadataField3 + ')';
         }
         if(String.isNotBlank(metadataField4) && String.isNotBlank(metadataField1) && String.isNotBlank(metadataField2) && String.isNotBlank(metadataField3)  && fieldisAccessible(metadataField4)){
             fieldStr += ', FORMAT(' + metadataField4 + ')';    
         }
         if(String.isNotBlank(metadataField5) && String.isNotBlank(metadataField4) && String.isNotBlank(metadataField1) && String.isNotBlank(metadataField2) && String.isNotBlank(metadataField3)  && fieldisAccessible(metadataField5)){
             fieldStr += ', FORMAT(' + metadataField5 + ')';    
         }
         if((String.isNotBlank(metadataField1) || String.isNotBlank(metadataField2) || String.isNotBlank(metadataField3)) && String.isNotBlank(queryString)){
		  List<String> queryStringFields = queryString.split(',');
		  for(String queryStringField:queryStringFields){	
                    if(queryStringField!= null && String.isNotBlank(queryStringField) && fieldisAccessible(queryStringField)){	
                        fieldStr += ', '+ queryStringField;	
                    }	
                }
		     }
              if(fieldStr!=null && !fieldStr.startsWith(',')){	
         fieldStr = ',' + fieldStr;	
         }
         System.debug('####SELECT Id' + (String.isBlank(fieldStr) ? '' : fieldStr) + ' FROM ' + objName + whereClause + orderByClause);
         return new List<sObject>(Database.query('SELECT Id' + (String.isBlank(fieldStr) ? '' : fieldStr) + ' FROM ' + objName + whereClause + orderByClause));
     } catch (Exception e) {
         throw new AuraHandledException('Error Occured While Loading Component : <<' + e.getStackTraceString() + '>>');
     }    
 }
 
 /*
     * Purpose : To check the field accessibility
     * Input : field
     * Returns : Boolean value 
     */
  @AuraEnabled	
 public static Boolean fieldisAccessible(String field){	
  		String fieldApi=field.contains('.')?field.substringAfterLast('.'):field;	
        String fieldParent=field.contains('.')?field.substringBeforeLast('.'):'';	
        if(String.isBlank(fieldParent) &&  Schema.SObjectType.Theme_Relation__c.fields.getMap()!=null && Schema.SObjectType.Theme_Relation__c.fields.getMap().containsKey(fieldApi.toLowerCase()) && 	
           Schema.SObjectType.Theme_Relation__c.fields.getMap().get(fieldApi.toLowerCase()).getDescribe().isAccessible()){	
                system.debug('isTrue@@@ for Theme_Relation__c');	
                return True;	
       }else if( field.contains('Account__r') && Schema.SObjectType.Account.fields.getMap()!=null &&	
                     Schema.SObjectType.Account.fields.getMap().containsKey(fieldApi.toLowerCase()) &&	
                     Schema.SObjectType.Account.fields.getMap().get(fieldApi.toLowerCase()).getDescribe().isAccessible()){	
              	system.debug('isTrue@@@ for Account');	
            	return true;	
       }else if( field.contains('Contact__r')  && Schema.SObjectType.Contact.fields.getMap()!=null &&	
                     Schema.SObjectType.Contact.fields.getMap().containsKey(fieldApi.toLowerCase()) &&	
                     Schema.SObjectType.Contact.fields.getMap().get(fieldApi.toLowerCase()).getDescribe().isAccessible()){	
              	system.debug('isTrue@@@ for Contact');	
            	return true;	
       }else if( field.contains('Deal__r')  && Schema.SObjectType.navpeII_dev18__Pipeline__c.fields.getMap()!=null &&	
                     Schema.SObjectType.navpeII_dev18__Pipeline__c.fields.getMap().containsKey(fieldApi.toLowerCase()) &&	
                     Schema.SObjectType.navpeII_dev18__Pipeline__c.fields.getMap().get(fieldApi.toLowerCase()).getDescribe().isAccessible()){	
              	system.debug('isTrue@@@ for Deal');	
            	return true;	
       }else if( field.contains('Fund__r')  && Schema.SObjectType.navpeII_dev18__Fund__c.fields.getMap()!=null &&	
                     Schema.SObjectType.navpeII_dev18__Fund__c.fields.getMap().containsKey(fieldApi.toLowerCase()) &&	
                     Schema.SObjectType.navpeII_dev18__Fund__c.fields.getMap().get(fieldApi.toLowerCase()).getDescribe().isAccessible()){	
              	system.debug('isTrue@@@ for Fund');	
            	return true;	
       }else if( field.contains('Fundraising__r')  && Schema.SObjectType.navpeII_dev18__Fundraising__c.fields.getMap()!=null &&	
                     Schema.SObjectType.navpeII_dev18__Fundraising__c.fields.getMap().containsKey(fieldApi.toLowerCase()) &&	
                     Schema.SObjectType.navpeII_dev18__Fundraising__c.fields.getMap().get(fieldApi.toLowerCase()).getDescribe().isAccessible()){	
              	system.debug('isTrue@@@ for FundRaising');	
            	return true;	
       }else if( field.contains('Other_Theme__r') &&  Schema.SObjectType.Theme__c.fields.getMap()!=null &&	
                     Schema.SObjectType.Theme__c.fields.getMap().containsKey(fieldApi.toLowerCase()) &&	
                     Schema.SObjectType.Theme__c.fields.getMap().get(fieldApi.toLowerCase()).getDescribe().isAccessible()){	
              	system.debug('isTrue@@@ for Theme');	
            	return true;	
       }//Added by Hema - 00039744
     else if( field.contains('Clip__r') &&  Schema.SObjectType.Clip__c.fields.getMap()!=null &&	
                     Schema.SObjectType.Clip__c.fields.getMap().containsKey(fieldApi.toLowerCase()) &&	
                     Schema.SObjectType.Clip__c.fields.getMap().get(fieldApi.toLowerCase()).getDescribe().isAccessible()){	
              	system.debug('isTrue@@@ for Theme');	
            	return true;	
       }//Added by Hema - 00039744
     else{	
                return false;	
       }	
         	
    }
 
 /*
     * Purpose : Deleting Themes Relations
     * Input : theme relation ids to be deleted
     * Returns : deleted themes record names
     */
 @AuraEnabled
 public static String deleteThemeRelations(List<Id> themeRelToDelete){
     try{
         String strObjectApiName = 'Theme_Relation__c';
         String query = '';
         if(!themeRelToDelete.isEmpty()){
             query = 'SELECT ';
             query += 'Id, Name FROM ' + strObjectApiName ;
             //Just in case criteria field not specified then it will return all records
             query += ' where id IN: themeRelToDelete';
         }
         List<SObject> lstRecords = new List<SObject>();
         if(String.isNotBlank(query)) {
             lstRecords = Database.query(query);  
         }
         String themeRelNames = '';
         for(SObject themeRels : lstRecords){
             themeRelNames = string.valueOf(themeRels.get('Name'));
         }  
         if(Schema.sObjectType.Theme_Relation__c.isAccessible() && 
             Schema.sObjectType.Theme_Relation__c.isDeletable() &&
             Theme_Relation__c.sObjectType.getDescribe().isDeletable()){
             delete lstRecords;
             }
 
         
         return themeRelNames;
     } catch (Exception e) {
         throw new AuraHandledException('Error Occured While Loading Component : <<' + e.getStackTraceString() + '>>');
     }    
 }
 
 /*
     * Purpose : Create new Themes Relations
     * Input : theme ids and lookup field record id
     * Returns : NA
     */
 @AuraEnabled
 public static String saveThemeRelations(String fieldId, String themeId){
     try{
         Id recId = (Id)fieldId;
         String response = 'false';
         if(fieldId == null){
             response = 'Select atleast a record.';   
         }
         else{
             List<navpeII_dev18__Theme_Relation__c> thisThemeRelList = [Select id, navpeII_dev18__Theme__c, navpeII_dev18__Account__c, navpeII_dev18__Contact__c, navpeII_dev18__Deal__c, navpeII_dev18__Fund__c, navpeII_dev18__Fundraising__c, navpeII_dev18__Other_Theme__c, navpeII_dev18__Clip__c from navpeII_dev18__Theme_Relation__c where navpeII_dev18__Theme__c=:themeId];
             for(navpeII_dev18__Theme_Relation__c thisRelRec: thisThemeRelList){
                 if(thisRelRec.navpeII_dev18__Account__c == fieldId || thisRelRec.navpeII_dev18__Contact__c == fieldId || thisRelRec.navpeII_dev18__Deal__c == fieldId || thisRelRec.navpeII_dev18__Fund__c == fieldId || thisRelRec.navpeII_dev18__Fundraising__c == fieldId || thisRelRec.navpeII_dev18__Other_Theme__c == fieldId || thisRelRec.navpeII_dev18__Clip__c == fieldId){
                     response='true';
                 }
             }
             if(response == 'false'){
                 navpeII_dev18__Theme_Relation__c newThemeRel =  new navpeII_dev18__Theme_Relation__c();
                 String sObjName = recId.getSObjectType().getDescribe().getName(); 
                 if(Schema.sObjectType.Theme_Relation__c.fields.Account__c.isCreateable()){
                     if(sObjName=='Account')newThemeRel.navpeII_dev18__Account__c = recId;
                 }
                 if(Schema.sObjectType.Theme_Relation__c.fields.Contact__c.isCreateable()){
                     if(sObjName=='Contact')newThemeRel.navpeII_dev18__Contact__c = recId;
                 }
                 if(Schema.sObjectType.Theme_Relation__c.fields.Deal__c.isCreateable()){
                     if(sObjName=='navpeII_dev18__Pipeline__c')newThemeRel.navpeII_dev18__Deal__c = recId;
                 }
                 if(Schema.sObjectType.Theme_Relation__c.fields.Fund__c.isCreateable()){
                     if(sObjName=='navpeII_dev18__Fund__c')newThemeRel.navpeII_dev18__Fund__c = recId;
                 }
                 if(Schema.sObjectType.Theme_Relation__c.fields.Fundraising__c.isCreateable()){
                     if(sObjName=='navpeII_dev18__Fundraising__c')newThemeRel.navpeII_dev18__Fundraising__c = recId;
                 }
                 if(Schema.sObjectType.Theme_Relation__c.fields.Other_Theme__c.isCreateable()){
                     if(sObjName=='navpeII_dev18__Theme__c')newThemeRel.navpeII_dev18__Other_Theme__c = recId;
                 }
                 if(Schema.sObjectType.Theme_Relation__c.fields.Clip__c.isCreateable()){
                     if(sObjName=='navpeII_dev18__Clip__c')newThemeRel.navpeII_dev18__Clip__c = recId;
                 }                    
                 if(Schema.sObjectType.Theme_Relation__c.fields.Theme__c.isCreateable()){
                     newThemeRel.navpeII_dev18__Theme__c = themeId;
                 }                 
                 if(Schema.sObjectType.Theme_Relation__c.isCreateable()){
                     insert newThemeRel;
                 }
                 
                 response = [Select id, Name from navpeII_dev18__Theme_Relation__c where id=:newThemeRel.Id LIMIT 1][0].Name;
             }    
         }
         return response;
     } catch (Exception e) {
         throw new AuraHandledException('Error Occured While Loading Component : <<' + e.getStackTraceString() + '>>');
     }    
 }
 
 
 
 
 /************************* CATEGORIES SECTION : END *************************/
 
 
 /************************* WRAPPERS : START *************************/
 
 /*
     * Purpose : Wrapper for page load information
     */
 public class ResponseWrapper{
     @AuraEnabled public String namespacePrefix;         //Namespaceprefix to be used
     @AuraEnabled public String themeDescription;         //Theme Description
     @AuraEnabled public String currentRecordName;         //theme record name
     @AuraEnabled public List<String> actIdList;         //Used for Interactions Section & Contacts/Connections Section (W/O AA Field Consideration)
     @AuraEnabled public List<String> completeActIdList; //Used for Interactions Section & Contacts/Connections Section (With AA Field Consideration)
     @AuraEnabled public String themeTeamMembers;  		//Used for displaying Theme Team members on Load
     @AuraEnabled public List<ConWrapper> conInfoWrapper;//Accounts Section info
     @AuraEnabled public List<ConWrapper> contactInfoWrapper;//Contacts Section info
     @AuraEnabled public List<ConWrapper> dealInfoWrapper;//Deal Section info
     @AuraEnabled public List<ConWrapper> fundInfoWrapper;//fund Section info
     @AuraEnabled public List<ConWrapper> fdrInfoWrapper;//fdr Section info
     @AuraEnabled public List<ConWrapper> themeInfoWrapper;//fdr Section info
     @AuraEnabled public List<ConWrapper> clipInfoWrapper;//fdr Section info
     @AuraEnabled public String accColumnHeader1;  		//Used for displaying Account Header on Load
     @AuraEnabled public String accColumnHeader2;  		//Used for displaying Account Header on Load
     @AuraEnabled public String accColumnHeader3;  		//Used for displaying Account Header on Load
     @AuraEnabled public String accColumnHeader4;  		//Used for displaying Account Header on Load
     @AuraEnabled public String conColumnHeader1;  		//Used for displaying Contact Header on Load
     @AuraEnabled public String conColumnHeader2;  		//Used for displaying Contact Header on Load
     @AuraEnabled public String conColumnHeader3;  		//Used for displaying Contact Header on Load
     @AuraEnabled public String conColumnHeader4;  		//Used for displaying Contact Header on Load
     @AuraEnabled public String dealColumnHeader1;  		//Used for displaying Deal Header on Load
     @AuraEnabled public String dealColumnHeader2;  		//Used for displaying Deal Header on Load
     @AuraEnabled public String dealColumnHeader3;  		//Used for displaying Deal Header on Load
     @AuraEnabled public String dealColumnHeader4;  		//Used for displaying Deal Header on Load
     @AuraEnabled public String dealColumnHeader5;  		//Used for displaying Deal Header on Load
     @AuraEnabled public String dealColumnHeader6;  		//Used for displaying Deal Header on Load
     @AuraEnabled public String fundColumnHeader1;  		//Used for displaying Fund Header on Load
     @AuraEnabled public String fundColumnHeader2;  		//Used for displaying Fund Header on Load
     @AuraEnabled public String fundColumnHeader3;  		//Used for displaying Fund Header on Load
     @AuraEnabled public String fundColumnHeader4;  		//Used for displaying Fund Header on Load
     @AuraEnabled public String fdrColumnHeader1;  		//Used for displaying Fund Header on Load
     @AuraEnabled public String fdrColumnHeader2;  		//Used for displaying Fund Header on Load
     @AuraEnabled public String fdrColumnHeader3;  		//Used for displaying Fund Header on Load
     @AuraEnabled public String fdrColumnHeader4;  		//Used for displaying Fund Header on Load
     @AuraEnabled public String fdrColumnHeader5;  		//Used for displaying Fund Header on Load
     @AuraEnabled public String fdrColumnHeader6;  		//Used for displaying Fund Header on Load
     @AuraEnabled public String themeColumnHeader1;  	//Used for displaying Theme Header on Load
     @AuraEnabled public String themeColumnHeader2;  	//Used for displaying Theme Header on Load
     @AuraEnabled public String themeColumnHeader3;  	//Used for displaying Theme Header on Load
     @AuraEnabled public String clipColumnHeader1;  		//Used for displaying Theme Header on Load
     @AuraEnabled public String clipColumnHeader2;  		//Used for displaying Theme Header on Load
     @AuraEnabled public String clipColumnHeader3;  		//Used for displaying Theme Header on Load
     
     @AuraEnabled
     public List<Account> accRecList=new List<Account>();// stores firm data
     @AuraEnabled
     public List<Contact> conRecList=new List<contact>();// stores contact data
     @AuraEnabled
     public List<navpeII_dev18__Pipeline__c> dealRecList=new List<navpeII_dev18__Pipeline__c>(); // stores Deals data
     @AuraEnabled
     public List<navpeII_dev18__Fund__c> fundRecList=new List<navpeII_dev18__Fund__c>(); // stores Funds data
     @AuraEnabled
     public List<navpeII_dev18__Fundraising__c> fundraisingRecList=new List<navpeII_dev18__Fundraising__c>(); // stores fundraising data 
     @AuraEnabled
     public List<navpeII_dev18__Theme__c> themesRecList=new List<navpeII_dev18__Theme__c>(); // stores Theme data 
     @AuraEnabled
     public List<navpeII_dev18__Clip__c> clipRecList=new List<navpeII_dev18__Clip__c>(); // stores Clip data 
 
 }
 
 /*
     * Purpose : Wrapper for displaying fields data
     */
 public class ConWrapper{
     @AuraEnabled public String accId;                   //Record ID
     @AuraEnabled public String logNoteIcon;             //Log Notes icon name 
     @AuraEnabled public String accName;                 //Record Name
     @AuraEnabled public String accNameRef;              //Record URL
     @AuraEnabled public String accDesc;                 //Firm Description
     @AuraEnabled public String accEntityType;           //Firm Entity Type
     @AuraEnabled public List<ActivityWrapper> actWrapperList; //Activity Wrapper to show details on Interaction Notes
     @AuraEnabled public String actSubject;				//Activity Subject
     @AuraEnabled public String themeDate;           	//Theme Date
     @AuraEnabled public String lastInteractionDate;		// Firm Last Interaction Date
     @AuraEnabled public String lastInteractionNotes;		// Firm Last Interaction Notes
     @AuraEnabled public String actId;					// Firm latest Interaction activity Id
     @AuraEnabled public String recId2;                   //Record ID
     @AuraEnabled public String name2;                    //Record Name
     @AuraEnabled public String nameRef2;                 //Record URL
     @AuraEnabled public String conId;                    //Record Id
     @AuraEnabled public String conName;                  //Record Name
     @AuraEnabled public String conNameRef;               //Record URL
     @AuraEnabled public String dealId;                    //Record Id
     @AuraEnabled public String dealName;                  //Record Name
     @AuraEnabled public String dealNameRef;               //Record URL
     @AuraEnabled public String dealStage;               //Stage Deal
     @AuraEnabled public String dealComments;               //Dynamic field info
     @AuraEnabled public String dealDateRec;               //Dynamic field info
     @AuraEnabled public String fundId;                    //Record Id
     @AuraEnabled public String fundName;                  //Record Name
     @AuraEnabled public String fundNameRef;               //Record URL
     @AuraEnabled public String fundVintage;               //Record Fund Field
     @AuraEnabled public String fundClosingDate;               //Record Fund Field
     @AuraEnabled public String frdId;                    //Record Id
     @AuraEnabled public String frdName;                  //Record Name
     @AuraEnabled public String frdNameRef;               //Record URL
     @AuraEnabled public String frdStage;                 //FRD stage
     @AuraEnabled public String frdStatusNote;            //FRD status note
     @AuraEnabled public String subject;               //Dynamic field info
     @AuraEnabled public String subjectRef;               //Dynamic field themes names
     @AuraEnabled public String description;               //Dynamic field info
     @AuraEnabled public String themeId;               //Dynamic field info
     @AuraEnabled public String themeRecId;               //Dynamic field info
     @AuraEnabled public String clipId;               //Dynamic field info
     @AuraEnabled public List<String> actIdList; 		//Associated activities list
 }
 
 /*
     * Purpose : Wrapper for Interactions Section/Modal information
     */
 public class ThemeRelationsTableWrapper{
     @AuraEnabled
     public List<String> accountRecordTypeIdList=new List<string>();
     @AuraEnabled
     public List<String> contactRecordTypeIdList=new List<string>();
     @AuraEnabled
     public List<String> dealRecordTypeIdList=new List<string>();
     @AuraEnabled
     public List<String> fundRecordTypeIdList=new List<string>();
     @AuraEnabled
     public List<String> fundraisingRecordTypeIdList=new List<string>();
     @AuraEnabled
     public List<String> themesRecordTypeIdList=new List<string>();
     @AuraEnabled
     public List<String> clipsRecordTypeIdList=new List<string>();
 }
 
 
 public class ActivityWrapper{
     //Added "actDateAsLong" on 2022-09-27 to fix data sorting issue
     @AuraEnabled public String actId;       //Activity ID
     @AuraEnabled public String type;        //Activity Type
     @AuraEnabled public String iconName;    //Icon Name
     @AuraEnabled public String actDate;     //Activity Date
     @AuraEnabled public Long actDateAsLong; //Stores activity date as a numeric value
     @AuraEnabled public String subject;     //Activity Subject
     @AuraEnabled public String detail;      //Activity Description
     @AuraEnabled public List<ReferenceWrapper> attendees;   //Activity attendees & assigned to information as a wrapper list
     @AuraEnabled public List<ReferenceWrapper> references;  //Activity Name & AA field information as a wrapper list
     @AuraEnabled public ReferenceWrapper assignedToWrapper; //Activity assigned to information as a wrapper
     @AuraEnabled public String buttonTitle;  //Added for Interactions tab to display Add/Edit Button or, no button
     @AuraEnabled public Boolean isFutureActivity;   //Whether the Activity is a future activity or, not
     @AuraEnabled public String priority;    //Activity Priority
     @AuraEnabled public String actOwner;    //Activity Owner
     @AuraEnabled public String status;      //Activity Status
     @AuraEnabled public String classification;      //Activity classification
     @AuraEnabled public SObject actInfo;
 }
 
 /*
     * Purpose : Wrapper for referenced type of data like Attendees/Assigned To/Name/AA Field
     */
 public class ReferenceWrapper{
     @AuraEnabled public String name;    //Record Name
     @AuraEnabled public String nameRef; //Record URL
     @AuraEnabled public String type;    //Record Object name
     @AuraEnabled public String iconName;//Record Icon
 }
 
 /*
 * Purpose : Wrapper for storing all objects column details
 */
 public class columnListWrapper{
     @AuraEnabled
     public List<columnDetailsWrapper> accountListColumns=new List<columnDetailsWrapper>(); // Account Columns 
     @AuraEnabled
     public List<columnDetailsWrapper> contactListColumns=new List<columnDetailsWrapper>(); // Contact Columns
     @AuraEnabled
     public List<columnDetailsWrapper> dealListColumns=new List<columnDetailsWrapper>(); // Deal Columns
     @AuraEnabled
     public List<columnDetailsWrapper> fundListColumns=new List<columnDetailsWrapper>(); // Fund  columns
     @AuraEnabled
     public List<columnDetailsWrapper> fundRaisListColumns=new List<columnDetailsWrapper>(); // Fundraising columns
     @AuraEnabled
     public List<columnDetailsWrapper> themeListColumns=new List<columnDetailsWrapper>(); // theme columns
     @AuraEnabled
     public List<columnDetailsWrapper> clipListColumns=new List<columnDetailsWrapper>(); // clip columns
     @AuraEnabled
     public Map<String,String> iconMap=new Map<String,String>(); // Icon value Storage 
     @AuraEnabled
     public List<String> objectAccessList=new List<String>();
 }
     
     /*
     * Purpose : Wrapper for storing all objects column details
     */
     public class columnDetailsWrapper{  
     @AuraEnabled
     public string fieldName;
     @AuraEnabled
     public string fieldLabel;
     @AuraEnabled
     public string fieldType;
     }
 
     /*
     * Purpose : Wrapper for storing all objects column details
     */
     public class JsonResponse{
         public Colors[] colors;
         public boolean custom;
         public Icons[] icons;
         public String label;        //DemoObjects
         public String sobjectName;  //DemoObject__c
     }
     class Colors {
         @AuraEnabled public String color;    //2ECBBE
         @AuraEnabled public String context;  //primary
         @AuraEnabled public String theme;    //theme4
     }
     public class Icons{
     public String contentType;  //image/png
     public Integer height;      //32
     public Integer width;       //32
     public String theme;        //theme3
     public String url;          //https://activityassociation-dev-ed.my.salesforce.com/img/icon/reports32.png
 } 
 
 
 /************************* WRAPPERS : END *************************/
 }