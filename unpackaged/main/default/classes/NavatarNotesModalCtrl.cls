/****************************************************************************************************

** Module Name : Activity Associations

** Description : Used to handle all the DML & schema related funtionalities of Activity Associations.

** Throws : NA

** Calls : NA

** Organization : Navatar Group

** Product Name & Version : Connections 2.0 

** Revision History:-

** Version    Date(YYYY-MM-DD)    Author         Description of Action

** 1.0        2022-08-02          Keyur/Yash/Anmol
** 1.1        2023-10-27          Lakshya        PE Patch 3 Fix
** 2.0        2024-02-22          Sudhanshu      Handle Activity Layout fields
** 2.1        2024-04-02          Deepak          Bug Fix Phase 3 CR - 00041270 
****************************************************************************************************/
// 31563, 31526,31558 added because AA runs on without sharing. so timeline has all records and need to display all records 
public without sharing class NavatarNotesModalCtrl {
    public static string strOrgSpacePrefix = CommonUtility_EdgeMenu.strOrgNameSpacePrefix;
    public static string strPackNameSpacePrefix = CommonUtility_EdgeMenu.strNameSpacePrefix;
    /*****************************************************************************************************
    * @Name         :   checkEditAccess
    * @Description  :   Method to check if user has edit access on selected record
    * @Param        :   recordId: id of record to check access
    *****************************************************************************************************/
    @AuraEnabled
    public static boolean checkEditAccess(Id recordId){
        boolean hasEditAccess = [SELECT HasEditAccess, HasDeleteAccess, recordId
                                FROM    UserRecordAccess
                                WHERE   userID = :userInfo.getUserId()
                                AND     recordId = :recordId].HasEditAccess;
        return hasEditAccess;
    }

    /*****************************************************************************************************
    * @Name         :   checkEditAccess
    * @Description  :   Method to check if user has edit access on selected record
    * @Param        :   recordId: id of record to check access
    *****************************************************************************************************/
    @AuraEnabled
    public static boolean checkDeleteAccess(Id recordId){
        boolean HasDeleteAccess = [SELECT HasEditAccess, HasDeleteAccess, recordId
                                FROM    UserRecordAccess
                                WHERE   userID = :userInfo.getUserId()
                                AND     recordId = :recordId].HasDeleteAccess;
        return HasDeleteAccess;
    }
    /****************************************************************************************************
    Purpose : get default tagged record on new event

    Input : recId - rec id list of record(s).
            searchObjects - all the setup objects from navatar setup objec used for activity association

    Returns : String of all default records
    ****************************************************************************************************/
    @AuraEnabled
    public static string getDefaultTaggedRecordList(List<string> recIdList, string searchObjects){
        try {
            List<RecordWrapper> recordList = new List<RecordWrapper>();
            List<SObject> objList = new List<SObject>();
            Map<String,String> recIdVSObjName=new Map<String,String>();

            if(recIdList.size()>0){
                for(String sRec:recIdList){
                //Id myId = (Id)recId;
                //String sObjName = myId.getSObjectType().getDescribe().getName();
                    recIdVSObjName.put(sRec,Id.valueOf(sRec).getSObjectType().getDescribe().getName());
                }
                list<LookupWrapper> multiWrpCls = (list<LookupWrapper>)JSON.deserialize(searchObjects, list<LookupWrapper>.class);

                Map<String, String> objNameVsObjIcon = new Map<String, String>();
                For(LookupWrapper obj : multiWrpCls){
                    objNameVsObjIcon.put(obj.objectName, obj.IconName);
                }
                // Bug 00045258,0045790 Fixed by Sudhanshu on 23-05-2024
                Set<String> recIdVSObjSet = new Set<String>(recIdVSObjName.values());

                for(String sObjName:recIdVSObjSet){
                    String qry = 'SELECT Id, Name FROM '+sObjName+ ' WHERE Id IN: recIdList WITH USER_MODE';
                    List<SObject> sObjRes = Database.query(string.escapesinglequotes(qry));
                    objList.addAll(sObjRes);
                }
                
                if(objList.size()>0) {
                    for(SObject obj:objList){
                    RecordWrapper recWrap = new RecordWrapper();
                    recWrap.Name = (String)obj.get('Name');
                    recWrap.Id = (String)obj.get('Id');
                    recWrap.objectName = recIdVSObjName.get((String)obj.get('Id'));
                    recWrap.iconName = objNameVsObjIcon.get(recIdVSObjName.get((String)obj.get('Id')));
                    recordList.add(recWrap);
                    }
                }

            }

            /* RecordWrapper recWrap = new RecordWrapper();
            recWrap.Name = Userinfo.getName();
            recWrap.Id = Userinfo.getUserId();
            recWrap.objectName = 'User';
            //recWrap.iconName = objNameVsObjIcon.get(sObjName);
            recordList.add(recWrap); */

            return JSON.serialize(recordList);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    /****************************************************************************************************
    Purpose : get default tagged record on new event

    Input : recId - rec id of record.
            searchObjects - all the setup objects from navatar setup objec used for activity association

    Returns : String of all default records
    ****************************************************************************************************/
    @AuraEnabled
    public static string getDefaultTaggedRecords(string recId, string searchObjects){
        try {
            List<RecordWrapper> recordList = new List<RecordWrapper>();
            List<SObject> objList = new List<SObject>();

            if(recId != null & recId != ''){
                Id myId = (Id)recId;
                String sObjName = myId.getSObjectType().getDescribe().getName();
                list<LookupWrapper> multiWrpCls = (list<LookupWrapper>)JSON.deserialize(searchObjects, list<LookupWrapper>.class);

                Map<String, String> objNameVsObjIcon = new Map<String, String>();
                For(LookupWrapper obj : multiWrpCls){
                    objNameVsObjIcon.put(obj.objectName, obj.IconName);
                }
                String qry = 'SELECT Id, Name FROM '+sObjName+ ' WHERE Id=:recId WITH USER_MODE';
                objList = Database.query(string.escapesinglequotes(qry));

                if(objList != null && !objList.isEmpty()) {
                    RecordWrapper recWrap = new RecordWrapper();
                    recWrap.Name = (String)objList[0].get('Name');
                    recWrap.Id = (String)objList[0].get('Id');
                    recWrap.objectName = sObjName;
                    recWrap.iconName = objNameVsObjIcon.get(sObjName);
                    recordList.add(recWrap);
                }

            }

            /* RecordWrapper recWrap = new RecordWrapper();
            recWrap.Name = Userinfo.getName();
            recWrap.Id = Userinfo.getUserId();
            recWrap.objectName = 'User';
            //recWrap.iconName = objNameVsObjIcon.get(sObjName);
            recordList.add(recWrap); */

            return JSON.serialize(recordList);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static string getSubjectFieldLabel(){
        try {
            return Schema.getGlobalDescribe().get('Event').getDescribe().fields.getMap().get('Subject').getDescribe().getLabel();
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    @AuraEnabled
    public static string saveSuggessionRecods(string recId, String allTaggedRecords, string extraTaggedRecord, String objectName, boolean isDescriptionUsed, string commentStr, string savedFollowUpIds){
        try {
            if(recId != null && recId != ''){
                List<String> followupIds = new List<String>();
                if(savedFollowUpIds.trim() != ''){
                    followupIds = savedFollowUpIds.trim().split(',');
                }
                String backlash = '\n';
                String backlashReplacement = '---n';
                commentStr = commentStr.replaceAll('</br>','\n');
                commentStr = commentStr.replaceAll('<br>','');
                commentStr = commentStr.replaceAll('</p>','\n');
                commentStr = commentStr.replaceAll('<p>','');
                commentStr = commentStr.replaceAll(backlash,backlashReplacement);
                commentStr = commentStr.stripHtmlTags();
                commentStr = commentStr.replaceAll(backlashReplacement, backlash);
                
                if(commentStr != null){
                    if(commentStr.split('--------------------------------------------------------------------------------').size()>1){
                        commentStr = commentStr.split('--------------------------------------------------------------------------------')[1].trim();
                    }
                }
                
                boolean isObjAccess = Schema.getGlobalDescribe().get(objectName).getDescribe().isAccessible();
                if(isObjAccess){
                    string qry = 'Select Id, navpeII_dev18__Related_Associations__c From ' +objectName+ ' WHERE Id =:recId  WITH USER_MODE';
                    List<SObject> recList = Database.query(String.escapeSingleQuotes(qry));

                    if(recList != null && !recList.isEmpty()){

                        List<RecordWrapper> allTaggedRecordsList = (List<RecordWrapper>)Json.deserialize(allTaggedRecords, (List<RecordWrapper>.class));
                        List<RecordWrapper> extraTaggedRecordList = (List<RecordWrapper>)Json.deserialize(extraTaggedRecord, (List<RecordWrapper>.class));

                        // collects all associaion and contacts id from tagged records
                        set<String> associationsSet = new set<String>();
                        set<String> contactsSet = new set<String>();

                        // collects all associaion and contacts names from tagged records
                        List<String> contactsNameSet = new List<String>();
                        List<String> associationsNameSet = new List<String>();

                        For(RecordWrapper recWrap : allTaggedRecordsList){
                            if(recWrap.Id.startsWith('003') ){   //|| recWrap.Id.startsWith('005')
                                contactsSet.add(recWrap.Id);
                                contactsNameSet.add(recWrap.Name);
                            }
                            else if(recWrap.Id.startsWith('005')){}
                            else{
                                associationsSet.add(recWrap.Id);
                                associationsNameSet.add(recWrap.Name);
                            }
                        }
                        
                        system.debug('test size '+extraTaggedRecordList.size());

                        For(RecordWrapper recWrap : extraTaggedRecordList){
                            system.debug('recWRap '+recWrap);
                            if(recWrap.Id.startsWith('003') ){   //|| recWrap.Id.startsWith('005')
                                contactsSet.add(recWrap.Id);
                                contactsNameSet.add(recWrap.Name);
                            }else if(recWrap.Id.startsWith('005')){}
                            else{
                                associationsSet.add(recWrap.Id);
                                associationsNameSet.add(recWrap.Name);
                            }
                        }

                        // cobverting set to list to make string
                        List<String> associationsList = new List<String>();
                        associationsList.addAll(associationsSet);
                        System.debug('associationsList=='+associationsList);
                        if(associationsList.size() > 13){
                            return 'Error: Related Association(s) limit reached.';//Fixed by Sudhanshu for 47754
                        }

                        List<String> contactsList = new List<String>();
                        contactsList.addAll(contactsSet);
                        System.debug('contactsList=='+contactsList);
                        if(contactsList.size() > 50){
                            return 'Error: Limit of 50 Contact reached.';//Fixed by Sudhanshu for 47565
                        }

                        sObject sObj;
                        if(objectName == 'Event'){
                            //Event ev = new Event();
                            sObj = Schema.getGlobalDescribe().get('Event').newSObject();
                        }
                        if(objectName == 'Task'){
                            //Event ev = new Event();
                            sObj = Schema.getGlobalDescribe().get('Task').newSObject();
                        }

                        // if it is in edit mode recordid will be stored to update that reocord
                        if(recId != '' && recId != null){
                            sObj.put('Id',recId);
                        }

                        if(isDescriptionUsed){
                            commentStr = 'Related Contacts: ' +String.join(contactsNameSet,',')+ '\n Related Associations: ' +String.join(associationsNameSet,',')+'\n--------------------------------------------------------------------------------\n'+commentStr;
                        }
                        sObj.put('Description',commentStr);
                        sObj.put('navpeII_dev18__Related_Associations__c',string.join(associationsList, ','));

                        Boolean isAccess = false;
                        if(recId != '' && recId != null){
                            isAccess = Schema.getGlobalDescribe().get(objectName).getDescribe().isUpdateable();
                        }else{
                            isAccess = Schema.getGlobalDescribe().get(objectName).getDescribe().isCreateable();
                        }

                        if(isAccess){
                            update sObj;
                        }

                        if(objectName == 'Event'){
                            List<sObject> erList = new List<sObject>();
                            Schema.SObjectType st = Schema.getGlobalDescribe().get('EventRelation');
                            For(String conId : contactsList){       
                                sObject er = st.newSobject();
                                er.put('EventId',recId);
                                er.put('RelationId',conId);
                                if(Schema.getGlobalDescribe().get('EventRelation').getDescribe().fields.getMap().get('IsInvitee') != null){
                                    er.put('IsInvitee',false);
                                }
                                if(Schema.getGlobalDescribe().get('EventRelation').getDescribe().fields.getMap().get('IsParent') != null){
                                    er.put('isParent',true);
                                }
                                erList.add(er);
                            }

                            Boolean isERUpdateable = (Schema.getGlobalDescribe().get('EventRelation')!=null && Schema.getGlobalDescribe().get('EventRelation').getDescribe().isCreateable());
                            system.debug('isERUpdateable=='+isERUpdateable);
                            if(isERUpdateable){
                                Database.SaveResult[] erSaveList = Database.Insert(erList, false);
                                for(Database.SaveResult sr : erSaveList){
                                    if(sr.isSuccess()){
                                        system.debug('= success=='+sr.getId());
                                    }else{
                                        system.debug('= error=='+sr.getErrors());
                                    }
                                }
                            }
                        }

                        if(objectName == 'Task'){
                            List<sObject> tRelList = new List<sObject>();
                            Schema.SObjectType st = Schema.getGlobalDescribe().get('TaskRelation');
                            if(st != null){
                            	For(String conId : contactsList){       
                                    sObject tr = st.newSobject();      
                                    tr.put('TaskId',recId);
                                    tr.put('RelationId',conId);
                                    tRelList.add(tr);
                                }    
                            }
                            Boolean isTRUpdateable = (Schema.getGlobalDescribe().get('TaskRelation')!=null && Schema.getGlobalDescribe().get('TaskRelation').getDescribe().isCreateable());
                            system.debug('isTRUpdateable=='+isTRUpdateable);
                            if(isTRUpdateable){
                                Database.SaveResult[] trSaveList = Database.Insert(tRelList, false,AccessLevel.SYSTEM_MODE);//Bug # 00039849
                                for(Database.SaveResult sr : trSaveList){
                                    if(sr.isSuccess()){
                                        system.debug('=success=='+sr.getId());
                                    }else{
                                        system.debug('= error=='+sr.getErrors());
                                    }
                                }
                            }
                            //return 'success';
                        }
                    
                        if(!followupIds.isEmpty()){
                            List<Task> followuptaskToUpdate = new List<Task>();
                            for(String taskId : followupIds){
                                if(checkUpdateableFields(Schema.getGlobalDescribe().get('Task'),
                                                         new List<String>{'Description','navpeII_dev18__Related_Associations__c'})==new List<String>{'Description','navpeII_dev18__Related_Associations__c'}){//,'id' removed for critical bug by Anmol
                                task tsk = new Task();
                                tsk.id = taskId;
                                tsk.put('Description',''); // Bug 00048343 fixed by Sudhanshu
                                tsk.put('navpeII_dev18__Related_Associations__c',string.join(associationsList, ','));
                                followuptaskToUpdate.add(tsk);
                                }
                            }
                            List<sObject> tRelList = new List<sObject>();
                            Schema.SObjectType st = Schema.getGlobalDescribe().get('TaskRelation');
                            if(st != null){
                                for(String taskId : followupIds){
                                    For(String conId : contactsList){       
                                        sObject tr = st.newSobject();      
                                        tr.put('TaskId',taskId);
                                        tr.put('RelationId',conId);
                                        tRelList.add(tr);
                                    }
                                }
                            }
                            if(Schema.getGlobalDescribe().get('Task').getDescribe().isUpdateable()){Database.update(followuptaskToUpdate,false);}
                            if(Schema.getGlobalDescribe().get('TaskRelation')!=null && Schema.getGlobalDescribe().get('TaskRelation').getDescribe().isCreateable()){Database.SaveResult[] trSaveList = Database.Insert(tRelList, false,AccessLevel.SYSTEM_MODE);}//Bug # 00039849
                        }
                    }
                }else{
                    return 'error';
                }
                }
                
            return 'success';
        } catch (Exception e) {
            system.debug('(error'+e.getStackTraceString()+' '+e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }
    }
    /****************************************************************************************************
    Purpose : Save event and task record

    Input : commentStr - description data from lwc.
            allTaggedRecords - all tagged record from event or task.
            recordId - recordid of record if it from new recordId is null
            extraTaggedRecord - tagged record from event or task from suggession popup.
            objectName - event or task.
            otherFielddData - all other fields data.
            subject - subject of record.
            isDescriptionUsed - if true stores description with related record and associations and false it won't

    Returns : String if success returns recordid else error message
    ****************************************************************************************************/
    @AuraEnabled
    public static List<string> saveRecord(string commentStr, String allTaggedRecords, String recordId, string extraTaggedRecord, string objectName, string otherFielddData, String currentObject, string subject, string taskType, boolean isDescriptionUsed, string followUpTasksStr, boolean isSaveFollowup, boolean isRichTxtEnable, string richTxtDescription){
        try {

            system.debug('allTaggedRecords=='+allTaggedRecords);
            system.debug('extraTaggedRecord=='+extraTaggedRecord);
            system.debug('otherFielddData=='+otherFielddData);
            system.debug('commentStr=='+commentStr);
            system.debug('currentObject=='+currentObject);
            system.debug('followUpTasksStr=='+followUpTasksStr);

            String backlash = '\n';
            String backlashReplacement = '---n';

//Rich Textarea Requirement - Deepak
        //    commentStr = commentStr.replaceAll('</br>','\n');
        //    commentStr = commentStr.replaceAll('<br>','');
        //    commentStr = commentStr.replaceAll('</p>','\n');
        //    commentStr = commentStr.replaceAll('<p>','');
        //    commentStr = commentStr.replaceAll('&nbsp;' , ' ');
            commentStr = commentStr.replaceAll(backlash,backlashReplacement);
           commentStr = commentStr.stripHtmlTags();  // added by Sudhanshu
            commentStr = commentStr.replaceAll(backlashReplacement, backlash);

            if(commentStr != null){
                if(commentStr.split('--------------------------------------------------------------------------------').size()>1){
                    commentStr = commentStr.split('--------------------------------------------------------------------------------')[1].trim();
                }
            }
            
            // deserialize all strings in to wrapper
            List<RecordWrapper> allTaggedRecordsList = (List<RecordWrapper>)Json.deserialize(allTaggedRecords, (List<RecordWrapper>.class));
            List<RecordWrapper> extraTaggedRecordList = (List<RecordWrapper>)Json.deserialize(extraTaggedRecord, (List<RecordWrapper>.class));
            List<FieldWrapper> otherFielddDataList = (List<FieldWrapper>)Json.deserialize(otherFielddData, (List<FieldWrapper>.class));
            List<followupTaskWrapper> followupTaskList = (List<followupTaskWrapper>)Json.deserialize(followUpTasksStr, (List<followupTaskWrapper>.class));

            for(followupTaskWrapper fw : followupTaskList){
                system.debug('fw=='+fw);
            } 

            // collects all associaion and contacts id from tagged records
            set<String> associationsSet = new set<String>();
            set<String> contactsSet = new set<String>();
            set<String> userSet = new set<String>();

            // collects all associaion and contacts names from tagged records
            List<String> contactsNameSet = new List<String>();
            List<String> associationsNameSet = new List<String>();

            For(RecordWrapper recWrap : allTaggedRecordsList){
                if(recWrap.Id.startsWith('003') ){   //|| recWrap.Id.startsWith('005')
                    contactsSet.add(recWrap.Id);
                    contactsNameSet.add(recWrap.Name);
                }else if(recWrap.Id.startsWith('005')){
                    userSet.add(recWrap.Id);
                }else{
                    associationsSet.add(recWrap.Id);
                    associationsNameSet.add(recWrap.Name);
                }
            }

            For(RecordWrapper recWrap : extraTaggedRecordList){
                if(recWrap.Id.startsWith('003') ){   //|| recWrap.Id.startsWith('005')
                    contactsSet.add(recWrap.Id);
                    contactsNameSet.add(recWrap.Name);
                }else if(recWrap.Id.startsWith('005')){
                    userSet.add(recWrap.Id);
                }
                else{
                    associationsSet.add(recWrap.Id);
                    associationsNameSet.add(recWrap.Name);
                }
            }
            system.debug('associationsSet=='+associationsSet);
            system.debug('contactsSet=='+contactsSet);

            // cobverting set to list to make string
            List<String> associationsList = new List<String>();
            associationsList.addAll(associationsSet);

            if(associationsList.size() > 13){
                //below line changed for Bug # 00037939 by Anmol
                return new List<String>{'Error: Related Association(s) limit reached.'};   // Bug 00047142 Fixed by Sudhanshu
            }

            List<String> contactsList = new List<String>();
            contactsList.addAll(contactsSet);
            if(contactsList.size() > 50){
                //below line changed for Bug # 00037939 by Anmol
                return new List<String>{'Error: Limit of 50 Contact reached.'}; // Bug 00047936 fixed by Sudhanshu
            }

            // initializing sobjects
            sObject sObj;
            if(currentObject == 'Event'){
                //Event ev = new Event();
                sObj = Schema.getGlobalDescribe().get('Event').newSObject();
            }
            if(currentObject == 'Task'){
                //Event ev = new Event();
                sObj = Schema.getGlobalDescribe().get('Task').newSObject();
                if(taskType =='Call'){
                    sObj.put('Type', 'Call');
                    sObj.put('TaskSubtype', 'Call');
                }
            }

            // if it is in edit mode recordid will be stored to update that reocord
            if(recordId != '' && recordId != null){
                sObj.put('Id',recordId);
            }

            if(isDescriptionUsed){
                commentStr = 'Related Contacts: ' +String.join(contactsNameSet,',')+ '\n Related Associations: ' +String.join(associationsNameSet,',')+'\n--------------------------------------------------------------------------------\n'+commentStr;
            }
            // creating comment as pr requirement. allAssociation names + all contacts name + comments
            
            
            sObj.put('Description',commentStr);
            sObj.put('subject',subject);
            sObj.put('navpeII_dev18__Related_Associations__c',string.join(associationsList, ','));

            // get all data from other fields
            for(FieldWrapper fw : otherFielddDataList){

                if( fw.fieldType == 'STRING' || fw.fieldType == 'PICKLIST' || fw.fieldType == 'REFERENCE' || fw.fieldType == 'TEXTAREA' || fw.fieldType == 'EMAIL'|| fw.fieldType == 'PHONE'){
                    if(fw.fieldValue != null && fw.fieldValue != ''){
                        sObj.put(fw.fieldAPI, String.valueOf(fw.fieldValue));
                    }
                    else{
                        sObj.put(fw.fieldAPI, Null);
                    }
                }
                if( fw.fieldType == 'BOOLEAN'){
                    if(fw.booleanValue != null){
                        sObj.put(fw.fieldAPI, Boolean.valueOf(fw.booleanValue));
                    }else{
                        sObj.put(fw.fieldAPI, Null);
                    }
                    
                }
                if( fw.fieldType == 'DATETIME'){
                    if(fw.dateTimeValue != null){
                        sObj.put(fw.fieldAPI, DateTime.valueOf(fw.dateTimeValue));
                    }else{
                        sObj.put(fw.fieldAPI, Null);
                    }
                }
                if( fw.fieldType == 'DATE'){
                    if(fw.dateValue != null){
                        sObj.put(fw.fieldAPI, Date.valueOf(fw.dateValue));
                    }else{
                        sObj.put(fw.fieldAPI, Null);
                    }
                }

                if(fw.fieldType == 'INTEGER' ){
                    if(fw.numberValue != null ){
                        sObj.put(fw.fieldAPI, Integer.valueOf(fw.numberValue));
                    }else{
                        sObj.put(fw.fieldAPI, Null);
                    }
                }
                if(fw.fieldType == 'DOUBLE'){
                    if(fw.numberValue != null ){
                        sObj.put(fw.fieldAPI, Double.valueOf(fw.numberValue));
                    }else{
                        sObj.put(fw.fieldAPI, Null);
                    }
                }
            }
            system.debug('ev===='+Json.serialize(sObj));

            Boolean isAccess = false;
            if(recordId != '' && recordId != null){
                isAccess = Schema.getGlobalDescribe().get(currentObject).getDescribe().isUpdateable();
            }else{
                isAccess = Schema.getGlobalDescribe().get(currentObject).getDescribe().isCreateable();
            }

            system.debug('=isAccess==='+isAccess);
            List<string> folloupTaskIds = new List<string>();
            if(isAccess){
                //Fix for Bug # 00035388 by Anmol Started
                if(taskType!=null && taskType=='Call' && 
                (!sObj.isSet('Status') || !sObj.isSet('status'))){
                sObj.put('Status', 'Completed');
            }//Fix for Bug # 00035388 by Anmol ended
                Database.UpsertResult urRes = Database.Upsert(sObj, false);

                if(urRes.isSuccess()){
                    // Added by Sudhanshu
                    if(Schema.sObjectType.navpeII_dev18__Note__c.isAccessible())
                    {
                        List<navpeII_dev18__Note__c> noteList = new List<navpeII_dev18__Note__c>();
                        if(isRichTxtEnable)
                        {
                            System.debug('richTxtDescription ==>'+richTxtDescription);
                            System.debug('richTxtDescriptionID ==>'+urRes.getId());
                            navpeII_dev18__Note__c richtxt = new navpeII_dev18__Note__c();
                            if(Schema.sObjectType.navpeII_dev18__Note__c.fields.navpeII_dev18__Activity_ID__c.isUpdateable()){
                                richtxt.navpeII_dev18__Activity_ID__c = urRes.getId();
                            }
                            if(Schema.sObjectType.navpeII_dev18__Note__c.fields.navpeII_dev18__Description__c.isUpdateable()){
                                richtxt.navpeII_dev18__Description__c = richTxtDescription;
                            }
                            noteList.add(richtxt);

                            if(noteList.size() > 0)
                            {
                                try{

                                    SObjectField field = navpeII_dev18__Note__c.navpeII_dev18__Activity_ID__c;
                                    if(Schema.sObjectType.navpeII_dev18__Note__c.isUpdateable()){
                                        List<Database.UpsertResult> urRes1 = Database.Upsert(noteList, field,false);
                                    }
                                    // upsert noteList;
                                } catch (DmlException e) {
                                    // Handle any DML exceptions
                                    System.debug('Error during upsert operation: ' + e.getMessage());
                                }
                            }
                        }
                    }

                    
                    sObject relObj;
                    if(currentObject == 'Event'){
                        List<sObject> erList = new List<sObject>();
                        List<sObject> attendeeERList = new List<sObject>();
                        // Bug 48199 Fixed by Sudhanshu
                        List<Id> erToDeleteList = new List<Id>(); // List to store records for deletion
                        Schema.SObjectType st = Schema.getGlobalDescribe().get('EventRelation');
                        For(String conId : contactsList){       
                            sObject er = st.newSobject();
                            er.put('EventId',urRes.getId());
                            er.put('RelationId',conId);
                            if(Schema.getGlobalDescribe().get('EventRelation').getDescribe().fields.getMap().get('IsInvitee') != null){
                            	er.put('IsInvitee',false);    
                            }
                            if(Schema.getGlobalDescribe().get('EventRelation').getDescribe().fields.getMap().get('isParent') != null){
                                er.put('isParent',true);
                            }
                            erList.add(er);
                        }


                        if(!userSet.isEmpty()){
                            Event eve = [Select Id, Ownerid FROM event WHERE id=:urRes.getId()][0];
                            String isInviteeCheck = (Schema.getGlobalDescribe().get('EventRelation').getDescribe().fields.getMap().get('IsInvitee') != null) ? ' AND IsInvitee = true ' : '';
                            List<sObject> erRelList = Database.query('SELECT Id, relationid FROM EventRelation WHERE EventId =:recordId ' + isInviteeCheck + ' WITH USER_MODE');
                            For(sObject erRel : erRelList){
                                // Bug 48199 Fixed By Sudhanshu
                                if(String.valueOf(erRel.get('relationid')).startsWith('003') && contactsList.contains(String.valueOf(erRel.get('relationid')))){
                                    sObject er = st.newSobject();
                                    er.put('id',erRel.id);
                                    if(Schema.getGlobalDescribe().get('EventRelation').getDescribe().fields.getMap().get('IsInvitee') != null){
                                    	er.put('IsInvitee',true);    
                                    }
                                    if(Schema.getGlobalDescribe().get('EventRelation').getDescribe().fields.getMap().get('isParent') != null){
                                        er.put('isParent',true);
                                    }
                                    attendeeERList.add(er);
                                }
                                else 
                                if(String.valueOf(erRel.get('relationid')).startsWith('003') && !contactsList.contains(String.valueOf(erRel.get('relationid'))))
                                {
                                    system.debug('erRel Con not found -> ' + erRel);
                                    erToDeleteList.add(erRel.Id);
                                }
                            }
                            Database.SaveResult[] erAttendeeSaveList = Database.update(attendeeERList);
                            // Bug 48199 Fixed By Sudhanshu
                            if (!erToDeleteList.isEmpty()) {
                                system.debug('Deleting EventRelation records -> ' + erToDeleteList);
                                Database.DeleteResult[] erDeleteResults = Database.delete(erToDeleteList, false);
                            }
                        }
                        
                        Boolean isERUpdateable = (Schema.getGlobalDescribe().get('EventRelation')!=null && Schema.getGlobalDescribe().get('EventRelation').getDescribe().isCreateable());
                        system.debug('isERUpdateable=='+isERUpdateable);
                        if(isERUpdateable){
                            if(recordId != '' && recordId != null && Schema.getGlobalDescribe().get('EventRelation').getDescribe().isDeletable()){
                                //Database.delete(Database.query('SELECT Id FROM EventRelation WHERE EventId ='+String.escapeSingleQuotes(recordId)+' and createdbyid ='+userinfo.getUserId()+' AND IsInvitee = false'));
                                String uId = userinfo.getUserId();
                                String isInviteeCheckStr = (Schema.getGlobalDescribe().get('EventRelation').getDescribe().fields.getMap().get('IsInvitee') != null) ? (' AND IsInvitee = false ') : '';
                                List<sObject> eRelationList=Database.query('SELECT Id FROM EventRelation WHERE EventId =:recordId and createdbyid =:uId ' + isInviteeCheckStr);
                                //Replaced above 2 lines with below line by LK on 2024-12-04 to fix 00048199
                                //List<sObject> eRelationList=Database.query('SELECT Id FROM EventRelation WHERE EventId =:recordId and createdbyid =:uId');
                                Database.delete(eRelationList);
                            }
                            
                            Database.SaveResult[] erSaveList = Database.Insert(erList, false);
                            for(Database.SaveResult sr : erSaveList){
                                if(sr.isSuccess()){
                                    system.debug('= success=='+sr.getId());
                                }else{
                                    system.debug('= error=='+sr.getErrors());
                                }
                            }
                        }
                        
                    }
                    if(currentObject == 'Task'){
                        List<sObject> tRelList = new List<sObject>();
                        Schema.SObjectType st = Schema.getGlobalDescribe().get('TaskRelation');
                        For(String conId : contactsList){       
                            if(st != null){
                            	sObject tr = st.newSobject();      
                                tr.put('TaskId',urRes.getId());
                                tr.put('RelationId',conId);
                                tRelList.add(tr);    
                            }
                        }
                        Boolean isTRUpdateable = (Schema.getGlobalDescribe().get('TaskRelation')!=null && Schema.getGlobalDescribe().get('TaskRelation').getDescribe().isCreateable());
                        system.debug('isTRUpdateable=='+isTRUpdateable);
                        if(isTRUpdateable){
                            if(recordId != '' && recordId != null && Schema.getGlobalDescribe().get('TaskRelation').getDescribe().isDeletable()){
                                //List<sObject> tRelationList=Database.query('SELECT Id FROM TaskRelation WHERE TaskId ='+String.escapeSingleQuotes(recordId)+' and createdbyid ='+userinfo.getUserId()+' AND isWhat = false');
                                String uId = userinfo.getUserId();
                                List<sObject> tRelationList=Database.query('SELECT Id FROM TaskRelation WHERE TaskId =:recordId and createdbyid =:uId AND isWhat = false');
                                Database.delete(tRelationList,AccessLevel.SYSTEM_MODE);//Bug # 00039849
                                    //[SELECT Id FROM TaskRelation WHERE TaskId =:recordId and createdbyid =: userinfo.getUserId() AND isWhat = false]
                            }
                            Database.SaveResult[] trSaveList = Database.Insert(tRelList, false,AccessLevel.SYSTEM_MODE);//Bug # 00039849
                            for(Database.SaveResult sr : trSaveList){
                                if(sr.isSuccess()){
                                    system.debug('=success=='+sr.getId());
                                }else{
                                    system.debug('= error=='+sr.getErrors());
                                }
                            }
                        }
                    }
                    if(isSaveFollowup){
                        List<Task> followupTaskListIns = new List<Task>();
                        for(followupTaskWrapper ftw : followupTaskList){
                            Task t = new Task();
                            t.put('navpeII_dev18__Related_Associations__c',string.join(associationsList, ','));
                            //31741 to add comment in followup task
                            // t.put('Description',commentStr);
                            // Bug 00047426 fixed by Sudhanshu on 07-10-2024
                            t.put('Description','');
                            for(FieldWrapper fw : ftw.data){
                                system.debug('FoolowUP Field ==> '+fw.fieldType);
                                system.debug('FoolowUP value ==> '+fw.fieldValue);
                                if( fw.fieldType == 'STRING' || fw.fieldType == 'PICKLIST' || fw.fieldType == 'REFERENCE' || fw.fieldType == 'COMBOBOX' || fw.fieldType == 'TEXTAREA' || fw.fieldType == 'EMAIL' || fw.fieldType == 'PHONE'){
                                    if(fw.fieldValue != null && fw.fieldValue != ''){
                                        t.put(fw.fieldAPI, String.valueOf(fw.fieldValue));
                                    }else{
                                        t.put(fw.fieldAPI, Null);
                                    }
                                }
                                if( fw.fieldType == 'BOOLEAN'){
                                    if(fw.booleanValue != null){
                                        t.put(fw.fieldAPI, Boolean.valueOf(fw.booleanValue));
                                    }else{
                                        t.put(fw.fieldAPI, Null);
                                    }
                                    
                                }
                                if( fw.fieldType == 'DATETIME'){
                                    if(fw.dateTimeValue != null){
                                        t.put(fw.fieldAPI, DateTime.valueOf(fw.dateTimeValue));
                                    }else{
                                        t.put(fw.fieldAPI, Null);
                                    }
                                }
                                if( fw.fieldType == 'DATE'){
                                    if(fw.dateValue != null){
                                        t.put(fw.fieldAPI, Date.valueOf(fw.dateValue));
                                    }else{
                                        t.put(fw.fieldAPI, Null);
                                    }
                                }
                
                                if(fw.fieldType == 'INTEGER' ){
                                    if(fw.numberValue != null ){
                                        t.put(fw.fieldAPI, Integer.valueOf(fw.numberValue));
                                    }else{
                                        t.put(fw.fieldAPI, Null);
                                    }
                                }
                                if(fw.fieldType == 'DOUBLE'){
                                    if(fw.numberValue != null ){
                                        t.put(fw.fieldAPI, Double.valueOf(fw.numberValue));
                                    }else{
                                        t.put(fw.fieldAPI, Null);
                                    }
                                }
                            }
                            followupTaskListIns.add(t);
                        } 
    
                        if(!followupTaskListIns.isEmpty()){
    
                            Database.SaveResult[] followupTaskResult = Database.Insert(followupTaskListIns, false);
                            for(Database.SaveResult sr : followupTaskResult){
                                if(sr.isSuccess()){
                                    folloupTaskIds.add(sr.getId());
                                    system.debug('=success=='+sr.getId());
                                }else{
                                    system.debug('= error=='+sr.getErrors());
                                }
                            }
    
                            List<sObject> folloTaskRelList = new List<sObject>();
                            Schema.SObjectType st = Schema.getGlobalDescribe().get('TaskRelation');
                            if(st != null){
                                For(String taskId : folloupTaskIds){
                                    For(String conId : contactsList){       
                                        sObject tr = st.newSobject();
                                        tr.put('TaskId',taskId);
                                        tr.put('RelationId',conId);
                                        folloTaskRelList.add(tr);
                                    }
                                }    
                            }
                            Database.SaveResult[] trSaveList = Database.Insert(folloTaskRelList, false,AccessLevel.SYSTEM_MODE);//Bug # 00039849
                            for(Database.SaveResult sr : trSaveList){
                                if(sr.isSuccess()){
                                    system.debug('=success=='+sr.getId());
                                }else{
                                    system.debug('= error=='+sr.getErrors());
                                    //below line changed for Bug # 00037939 by Anmol
                                    return new List<String>{'Error:Error Occured While Loading Component :'+urRes.getErrors()};
                                }
                            }
                        }
                    }
                    


                }else{
                    system.debug('urRes.getId=='+urRes.getErrors());
                    Database.Error[] err = urRes.getErrors();
                    if(err[0].getMessage().contains('Event duration cannot be negative')){
                        //return 'Error:Review the errors on this page.The Record provided contains field(s) with invalid data';
                        //below line changed for Bug # 00037939 by Anmol
                        return new List<String>{'Error: '+err[0].getMessage()};
                    }else if(err[0].getMessage().contains('data value too large')){
                        //below line changed for Bug # 00037939 by Anmol
                        System.debug('Error Message ==> '+err[0].getMessage());
                        // bug 	00045496,00047450 fixed by sudhanshu on 17-05-2024
                        return new List<String>{'Error: Exceeded Notes Limit (32,000 chars). Please save notes with less content.'};
                    }
                    else if(err[0].getMessage().contains('last longer than 14 days.')){
                        //below line changed for Bug # 00037939 by Anmol
                        return new List<String>{'Error: '+err[0].getMessage()};
                    }
                    else{
                        //below line changed for Bug # 00037939 by Anmol
                        return new List<String>{'Error: Error Occured While Loading Component :'+urRes.getErrors()};
                    }
                    
                }
                system.debug('urRes.getId=='+urRes.getId());
                //changed for Bug # 00037939 by Anmol started
                Map<String,String> folloupTaskIdsVsSubMap=new Map<String,String>();
                for(Task t: [Select Id, Subject from Task where Id IN: folloupTaskIds]){
                    folloupTaskIdsVsSubMap.put(t.Id,t.Subject);
                }
                String serialisedMap=JSON.serialize(folloupTaskIdsVsSubMap);
                //changed for Bug # 00037939 by Anmol ended
                // Bug 00047995 Fixed by Sudhanshu 
                return new List<String>{urRes.getId()+'#'+String.join(folloupTaskIds, ','), serialisedMap,commentStr}; 
            }else{
                //below line changed for Bug # 00037939 by Anmol
                return new List<String>{'Error:<b>Looks like there\'s a problem</b>. You do not have the level of access necessary to perform the operation you requested. Please contact the owner of the record or your administrator if access is necessary.'};
            }

            
        } catch (Exception e) {
            system.debug('error=='+e.getMessage()+'=='+e.getLineNumber());
            throw new AuraHandledException(e.getMessage());
        }
    }

    /*****************************************************************************************************
    * @Name         :   checkRichTextDesp
    * @Description  :   Method to check Rich Text area field to show or hide
    * @Param        :   
    *****************************************************************************************************/
    @AuraEnabled
    public static List<NotesWrapper> checkRichTextDesp(String recordId){
        System.debug('recordId == > '+recordId);
        List<NotesWrapper> notesWrap = new List<NotesWrapper>();
        String refField = Acuity_Setting__mdt.getInstance('Acuity_Enable_Notes_RTA').Value__c;
        
         
            NotesWrapper notesList = new NotesWrapper();
            notesList.isRichText = refField.toLowerCase();
            if(refField.toLowerCase() == 'true' && !String.isBlank(recordId) ){
                List<navpeII_dev18__Note__c> actDesp = [SELECT navpeII_dev18__Activity_ID__c, navpeII_dev18__Description__c  FROM navpeII_dev18__Note__c WHERE navpeII_dev18__Activity_ID__c = : recordId];
                if(actDesp.size() > 0){
                    notesList.id = actDesp[0].navpeII_dev18__Activity_ID__c ;
                    
                    notesList.richDescription = String.isBlank(actDesp[0].navpeII_dev18__Description__c) ? '' : actDesp[0].navpeII_dev18__Description__c ;
                    // actIdVsDespMap.put(actDesp.navpeII_dev18__Activity_ID__c,actDesp.navpeII_dev18__Description__c);
                }
                else{
                    notesList.richDescription   =   '';
                }
            }
            notesWrap.add(notesList);
        return notesWrap;
    }

    //followup task wrapper
    public class followupTaskWrapper{
        @AuraEnabled public string id;
        @AuraEnabled public List<FieldWrapper> data;
    }

    // to store record data
    public class DataWrapper{
        @AuraEnabled public string subject;
        @AuraEnabled public string description;
        @AuraEnabled public String allTaggedRecordsList;
        @AuraEnabled public String allOtherFields;
        @AuraEnabled public String followupTaskFields;
        @AuraEnabled public String descRecords; 
        @AuraEnabled public String hiddenTaggedList; // Bug 00046172,00046179 fixed by Sudhanshu on 15-07-2024
    }

    /* //wrpper to store left and right fieldNames
    public class fieldRowWrapper{
        @AuraEnabled public FieldWrapper leftField;
        @AuraEnabled public FieldWrapper rightField;
    }
 */
    // to store all the fields schema of record layout
    public class FieldWrapper{
        @AuraEnabled public string fieldLabel;
        @AuraEnabled public string fieldAPI;
        @AuraEnabled public string fieldType;
        @AuraEnabled public string lwcFieldClass;

        @AuraEnabled public boolean isRequired = false;


        @AuraEnabled public string fieldValue;
        @AuraEnabled public boolean isText = false;
        @AuraEnabled public boolean isPicklist = false;
        @AuraEnabled public boolean isCombobox = false;
        @AuraEnabled public boolean isReference = false;
        @AuraEnabled public string referenceObjName;

        @AuraEnabled public boolean booleanValue = false;
        @AuraEnabled public boolean isBoolean = false;

        @AuraEnabled public Date dateValue;
        @AuraEnabled public boolean isDate = false;
        
        @AuraEnabled public DateTime dateTimeValue;
        @AuraEnabled public boolean isDateTime = false;

        @AuraEnabled public boolean isNumber = false;
        @AuraEnabled public decimal numberValue;

        @AuraEnabled public boolean isLeftField = false;
        @AuraEnabled public boolean isRightField = false;

        @AuraEnabled public boolean isTextArea = false;
        @AuraEnabled public boolean isEmail = false;
        @AuraEnabled public boolean isPhone = false;

    }


    /****************************************************************************************************
    Purpose : get event and task record

    Input : recordId - recordid of record if it from new recordId is null
            searchObjects - all the setup objects from navatar setup objec used for activity association
            currentObject - name of object we are creating record. event or task
            taskLayoutFields - fields to show in advance  for task- layout fields.
            eventLayoutFields - fields to show in advance part for event- layout fields.

    Returns : all the record data with its schema
    ****************************************************************************************************/
    @AuraEnabled
    public static string getRecordData(String recordId, String searchObjects, String currentObject, string taskLayoutFields, String eventLayoutFields, String taskType, string followUpTaskFields){
        try {
            
            // to store all data
            DataWrapper ew = new DataWrapper();
            // Map<String, String> fieldLabelMap = new Map<String, String>
            // {'Assigned To ID' => 'Assigned To',
            //     'Start Date Time' => 'Date',
            //     'End Date Time' => 'End',
            //     'Due Date Only' => 'Due Date'};
                    
                    // stores all layout fields to show in the advance part.
                    string fieldNames = '';
            string followUpFieldNames = '';
            followUpFieldNames = followUpTaskFields;
            Map<String, Schema.SObjectField> M;
            if(currentObject == 'Event'){
                //fieldNames = 'ownerid,Location,IsReminderSet,ActivityDateTime,Test_Date__c,Meeting_Type__c,Type,Institution__c,DurationInMinutes,Test_Number__c';
                fieldNames = eventLayoutFields;
                M = Schema.SObjectType.Event.fields.getMap();
            }
            if(currentObject == 'Task'){
                //fieldNames = 'ownerid,Status,IsRecurrence,Test_Date__c,Meeting_Type__c,Type,Institution__c,RecurrenceInterval,Test_Number__c';
                fieldNames = taskLayoutFields;
                M = Schema.SObjectType.Task.fields.getMap();
            }
            // creating the metadata of layout fields like type, name , apiname and values of fields.
            List<FieldWrapper> fieldWrapList = new list<FieldWrapper>();
            List<FieldWrapper> followupFieldsWrap = new list<FieldWrapper>();
            
            Map<String, Object> defaultValueMap = new Map<String, Object>();
            defaultValueMap = getDefaultValues(currentObject,fieldNames.split(','));
            
            // Integer count = 1;
            //fieldNames=fieldNames.toLowerCase().deleteWhitespace();
            List<String> fieldNameList=fieldNames.split(',');
            System.debug(taskType);
            if(taskType=='Call' || taskType=='Email'){
                if(fieldNameList.contains('Status'))
                    fieldNameList.remove(fieldNameList.indexOf('Status'));
                if(fieldNameList.contains('Priority'))
                    fieldNameList.remove(fieldNameList.indexOf('Priority'));
            }
            System.debug(fieldNameList);
            fieldWrapList = setFieldValue(fieldNameList,taskType,currentObject,defaultValueMap,false,M);

           
            
            if(currentObject == 'Event'){
                M = Schema.SObjectType.Task.fields.getMap();
                defaultValueMap = getDefaultValues('Task',followUpFieldNames.split(','));
            }

            
            followupFieldsWrap = setFieldValue(followUpFieldNames.split(','),taskType,currentObject,defaultValueMap,true,M);
            
            
            
            
            
            
            List<RecordWrapper> recordList = new List<RecordWrapper>();
            List<RecordWrapper> descRecordList = new List<RecordWrapper>();
            string description = '';
            List<Id> notAccessibleIdsSet=new List<Id>();    // Bug 00046172,00046179 fixed by Sudhanshu on 15-07-2024
            
            // if it is in edit mode then get all the data of respective object and store in wrapper
            if(recordId != null && recordId != ''){
                Id recrId = (Id)recordId;
                String objectName = recrId.getSObjectType().getDescribe().getName();
                String qury = 'SELECT Id, Owner.Name, Description, Subject, navpeII_dev18__Related_Associations__c, ' +fieldNames.removeEnd(',')+ ' FROM ' +objectName+ ' WHERE Id =:recordId WITH USER_MODE';
                List<sObject> objList = Database.query(string.escapesinglequotes(qury));
                
                for(FieldWrapper fWrap : fieldWrapList){
                    
                    if( fWrap.fieldType == 'STRING' ){
                        fWrap.fieldValue = (String)objList[0].get(fWrap.fieldAPI);
                    }
                    if( fWrap.fieldType == 'TEXTAREA' ){
                        fWrap.fieldValue = (String)objList[0].get(fWrap.fieldAPI);
                    }
                    if( fWrap.fieldType == 'EMAIL' ){
                        fWrap.fieldValue = (String)objList[0].get(fWrap.fieldAPI);
                    }
                    if( fWrap.fieldType == 'PHONE' ){
                        fWrap.fieldValue = (String)objList[0].get(fWrap.fieldAPI);
                    }
                    if( fWrap.fieldType == 'BOOLEAN'){
                        fWrap.booleanValue = (boolean)objList[0].get(fWrap.fieldAPI);
                    }
                    if( fWrap.fieldType == 'DATETIME'){
                        fWrap.dateTimeValue = (DateTime)objList[0].get(fWrap.fieldAPI);
                    }
                    if( fWrap.fieldType == 'DATE'){
                        fWrap.dateValue = (Date)objList[0].get(fWrap.fieldAPI);
                    }
                    if( fWrap.fieldType == 'PICKLIST'){
                        if(fWrap.fieldAPI.contains('lassification')){//fixed by Sudhanshu for critical bug: 00046148, 00047050
                            fWrap.fieldValue = (String)objList[0].get(fWrap.fieldAPI) != null ? (String)objList[0].get(fWrap.fieldAPI) : '';
                        }
                        else{
                            fWrap.fieldValue = (String)objList[0].get(fWrap.fieldAPI);
                        }
                    }
                    if( fWrap.fieldType == 'REFERENCE'){
                        if((String)objList[0].get(fWrap.fieldAPI) != null && (String)objList[0].get(fWrap.fieldAPI) != ''){
                            fWrap.fieldValue = (String)objList[0].get(fWrap.fieldAPI);
                        }
                    }
                    if(fWrap.fieldType == 'INTEGER' || fWrap.fieldType == 'DOUBLE'){
                        fWrap.isNumber = true;
                        fWrap.numberValue = (Decimal)objList[0].get(fWrap.fieldAPI);
                    }
                }
                if(currentObject == 'Event' && fieldNames.contains('IsAllDayEvent')){
                    if(objList[0].get('IsAllDayEvent') != null){
                        if((Boolean)(objList[0].get('IsAllDayEvent'))){
                            for(FieldWrapper fWrap : fieldWrapList){
                                if( fWrap.fieldType == 'DATETIME' && ( fWrap.fieldAPI.equalsIgnoreCase('StartDateTime') || fWrap.fieldAPI.equalsIgnoreCase('EndDateTime')) ){
                                    fWrap.fieldType = 'DATE';
                                    fWrap.isDateTime = false;
                                    fWrap.dateTimeValue = null;
                                    fWrap.isDate = true;
                                    if(objList[0].get(fWrap.fieldAPI) != null){
                                        datetime dt = (DateTime)objList[0].get(fWrap.fieldAPI);
                                        fWrap.dateValue = date.newinstance(dT.year(), dT.month(), dT.day()).addDays(1);
                                    }
                                    
                                }
                            }
                        }
                    }
                }
                
                
                //List<Event> evList = [SELECT Id, Description, Subject, navpeII_dev18__Related_Associations__c FROM Event WHERE Id =:recordId];
                Map<String,String> objnamevsId = new Map<String,String>();
                
                ew.subject = (String)objList[0].get('Subject');
                
                // extract comment from description field
                if(objList[0].get('Description') != null){
                    //description = ((String)objList[0].get('Description')).replaceAll('\n','</br>');
                    description = ((String)objList[0].get('Description')).replaceAll('</br>','\n');
                }
                
                /* if(!objList.isEmpty() &&  objList[0].get('Description') != null){
if(String.valueOf(objList[0].get('Description')).split('--------------------------------------------------------------------------------').size()>1){
description = String.valueOf(objList[0].get('Description')).split('--------------------------------------------------------------------------------')[1].trim();
}else{
description = (String)objList[0].get('Description');
}
} */
                
                // deserialize set-up objects to get icon-name from wrapper
                list<LookupWrapper> multiWrpCls = (list<LookupWrapper>)JSON.deserialize(searchObjects, list<LookupWrapper>.class);
                Map<String, String> objNameVsObjIcon = new Map<String, String>();
                For(LookupWrapper obj : multiWrpCls){
                    objNameVsObjIcon.put(obj.objectName, obj.IconName);
                }

                // creating map of each objects with there ids.
                Map<String, List<String>> ObjNameVSWhatid = new Map<String, List<String>>();
                if(objList[0].get('navpeII_dev18__Related_Associations__c') != null){
        
                    Set<Id> uniqueRAIdsSet=new Set<Id>();
                    for(String raId : String.valueOf(objList[0].get('navpeII_dev18__Related_Associations__c')).split(',')){
                        uniqueRAIdsSet.add(raId);
                    }
                    Set<Id> accessibleIdsSet=new Set<Id>();
                    for(UserRecordAccess accessibleRec: [SELECT RecordId FROM UserRecordAccess WHERE UserId =: userInfo.getUserId() AND RecordId IN: uniqueRAIdsSet AND HasReadAccess = true]){
                        accessibleIdsSet.add(accessibleRec.RecordId);
                    }
                    // Bug 00046172,00046179 fixed by Sudhanshu on 15-07-2024
                    for (ID item : uniqueRAIdsSet) {
                        if (!accessibleIdsSet.contains(item)) {
                            notAccessibleIdsSet.add(item);
                        }
                    }
                    
                    for(Id whatid : accessibleIdsSet){
    
                        Id recId = (Id)whatid;
                        String sObjName = recId.getSObjectType().getDescribe().getName();
                        List<String> temp = ObjNameVSWhatid.get(sObjName);
                        if(temp == null){
                            temp = new List<String>();
                        }
                        temp.add(whatid);
                        ObjNameVSWhatid.put(sObjName,temp);
                    }
                }
               
                // query all the objects and store values in wrapper to show the as tagged records
                For(String objName : ObjNameVSWhatid.keySet()){
                    if(Limits.getQueries() >= Limits.getLimitQueries()){
                        break;
                    }
                    List<String> recordIds = ObjNameVSWhatid.get(objName);
                    String qry = 'SELECT Id, Name FROM ' +objName+ ' WHERE id in: recordIds WITH USER_MODE';
                    List<SObject> sobjList = Database.query(string.escapesinglequotes(qry));
                    
                    For(SObject sobj : sobjList){
                        objnamevsId.put( String.valueOf(sobj.get('Id')), String.valueOf(sobj.get('Name')) );
                        
                        RecordWrapper recWrap = new RecordWrapper();
                        recWrap.Name = (String)sObj.get('Name');
                        recWrap.Id = (String)sObj.get('Id');
                        recWrap.objectName = objName;
                        recWrap.iconName = objNameVsObjIcon.get(objName);
                        recordList.add(recWrap);
                    }
                }


                //00031653 added to owner user in tagged section
                if(recordId != null && recordId != ''){
                    RecordWrapper usrRecWrap = new RecordWrapper();
                    usrRecWrap.Name = test.isRunningTest() ? '' : (String) objList[0].getSobject('Owner').get('Name');
                    usrRecWrap.Id = (String) objList[0].get('Ownerid');
                    usrRecWrap.objectName = 'User';
                    usrRecWrap.iconName = 'standard:user';
                    usrRecWrap.isUser = true;
                    recordList.add(usrRecWrap); 
                }else{
                    RecordWrapper usrRecWrap = new RecordWrapper();
                    usrRecWrap.Name = Userinfo.getName();
                    usrRecWrap.Id = Userinfo.getUserId();
                    usrRecWrap.objectName = 'User';
                    usrRecWrap.iconName = 'standard:user';
                    usrRecWrap.isUser = true;
                    recordList.add(usrRecWrap); 
                }
                
                
                // get all the relations from task and store values in wrapper to show the as tagged records
                if(objectName == 'Task'){
                    //List<sObject> trelationList=Database.query('SELECT relationid,relation.name FROM Taskrelation WHERE taskid ='+String.escapeSingleQuotes(recordId)+' AND isWhat = false');
                    if(Schema.getGlobalDescribe().get('TaskRelation') != null){
                    	List<sObject> trelationList=Database.query('SELECT relationid,relation.name FROM Taskrelation WHERE taskid =:recordId AND isWhat = false');
                        For(sObject trelation : trelationList){
                        objnamevsId.put( String.valueOf(trelation.get('relationid')), 
                                        String.valueOf(trelation.getSObject('relation').get('name')));
                        RecordWrapper recWrap = new RecordWrapper();
                        recWrap.Name = String.valueOf(trelation.getSObject('relation').get('name'));
                        recWrap.Id = String.valueOf(trelation.get('relationid'));
                        Id recId = (Id)trelation.get('relationid');
                        String sObjName = recId.getSObjectType().getDescribe().getName();       // Bug 00044510 Fixed by Sudhanshu on 24-05-2024
                        System.debug('sObjName ==> '+sObjName);
                        recWrap.objectName = sObjName;
                        
                        if(sObjName == 'User'){
                            recWrap.iconName = 'standard:user';
                        }else {
                            recWrap.iconName = objNameVsObjIcon.get(sObjName);
                        }
                        
                        recordList.add(recWrap);
                    }    
                    }
                }

                // get all the relations from event and store values in wrapper to show the as tagged records
                if(objectName == 'Event'){
                    string ownerID = (String) objList[0].get('Ownerid');
                    String isWhatClause = (Schema.getGlobalDescribe().get('EventRelation').getDescribe().fields.getMap().get('IsWhat') != null) ? (' AND isWhat = false ') : '';
                    List<sObject> erelationList = Database.query('SELECT relationid,relation.name,eventId FROM eventrelation WHERE eventid  =:recordId ' + isWhatClause + ' and relationid != :ownerID WITH USER_MODE');
                    For(sObject erelation : erelationList){
                        objnamevsId.put( String.valueOf(erelation.get('relationid')), 
                                        String.valueOf(erelation.getsObject('relation').get('name')));
                        RecordWrapper recWrap = new RecordWrapper();
                        recWrap.Name = String.valueOf(erelation.getsObject('relation').get('name'));
                        recWrap.Id = String.valueOf(erelation.get('relationid'));
                        Id recId = (Id)erelation.get('relationid');
                        String sObjName = recId.getSObjectType().getDescribe().getName();       // Bug 00044510 Fixed by Sudhanshu on 24-05-2024
                        recWrap.objectName = sObjName;
                        if(sObjName == 'User'){
                            recWrap.iconName = 'standard:user';
                        }else {
                            recWrap.iconName = objNameVsObjIcon.get(sObjName);
                        }
                        //recWrap.iconName = objNameVsObjIcon.get(sObjName);
                        //00031486 added to make user unremovable
                        if(recWrap.Id.startsWith('005')){
                            recWrap.isUser = true;
                        }
                        recordList.add(recWrap);
                    }
                }
                
                // check if associated record is in comments, if yes make that name as clickable
                //Map<String,String> savedRelatedRecords = new Map<String,String>();
                System.debug('objnamevsId=='+objnamevsId);
                System.debug('description=='+description);
                For(String recId : objnamevsId.keySet()){
                    if(description.contains(objnamevsId.get(recId))){
                        //description = description.replace(recName, '<a href="' +URL.getSalesforceBaseUrl().toExternalForm()+'/'+objnamevsId.get(recName)+'" rel="noopener noreferrer" target="_blank">'+recName+ '</a>');
                        //system.debug('description=='+description);
                        //savedRelatedRecords.put(recName, objnamevsId.get(recName));
                        RecordWrapper recWrap = new RecordWrapper();
                        recWrap.Name = objnamevsId.get(recId);
                        recWrap.Id = recId;
                        descRecordList.add(recWrap);
                    }
                } 
            }
            
            System.debug('descRecordList=='+descRecordList);
            
            ew.description = description;
            ew.allTaggedRecordsList = JSON.serialize(recordList);
            ew.allOtherFields = JSON.serialize(fieldWrapList);
            ew.descRecords = JSON.serialize(descRecordList);
            ew.followupTaskFields = JSON.serialize(followupFieldsWrap);
            ew.hiddenTaggedList = JSON.serialize(notAccessibleIdsSet);  // Bug 00046172,00046179 fixed by Sudhanshu on 15-07-2024
            
            //ew.fieldListLeft = JSON.serialize(fieldWrapListLeft);
            //ew.fieldListRight = JSON.serialize(fieldWrapListRight);
            
            system.debug('JSON.serialize(followupFieldsWrap)=='+JSON.serialize(followupFieldsWrap));
            return JSON.serialize(ew);
        } catch (Exception e) {
            system.debug('error=='+e.getMessage()+'=='+e.getLineNumber());
            throw new AuraHandledException(e.getMessage());
        }
    }

    public static List<FieldWrapper> setFieldValue(List<String> fieldList,String taskType,String currentObject,Map<String, Object> defaultValueMap, Boolean isFollowUp,Map<String, Schema.SObjectField> M)
    {
        Map<String, String> fieldLabelMap = new Map<String, String>
            {'Assigned To ID' => 'Assigned To',
                'Start Date Time' => 'Date',
                'End Date Time' => 'End',
                'Due Date Only' => 'Due Date'};
        List<FieldWrapper> fieldWrapList = new list<FieldWrapper>();
        Integer count = 1;
        FieldWrapper fWrap = new FieldWrapper();
        // Bug ID : 00044237 fixed on 27-02-2024 by Sudhanshu
        List<String> supportedType= new List<String>{ 'COMBOBOX','STRING','TEXTAREA','EMAIL','PHONE','BOOLEAN','DATETIME','DATE','PICKLIST','REFERENCE','INTEGER','DOUBLE'};
        for(String fieldName : fieldList){
            fWrap = new FieldWrapper();
            system.debug('fieldName=='+fieldName);    
            Schema.SObjectField field = M.get(fieldName);
            Schema.DisplayType FldType = field.getDescribe().getType();
            system.debug('FldType=='+FldType);
            
            
            fWrap.fieldLabel = fieldLabelMap.containsKey(m.get(fieldName).getDescribe().getLabel()) 
                ? fieldLabelMap.get(m.get(fieldName).getDescribe().getLabel())
                :  m.get(fieldName).getDescribe().getLabel();
            if((taskType=='Call' || taskType=='Email' || currentObject == 'Event')&&fWrap.fieldLabel=='Due Date'){
                fWrap.fieldLabel='Date';
            }
            fWrap.fieldAPI = fieldName;
            if(isFollowUp == true)
            {
                fWrap.lwcFieldClass = fieldName+'followup';
            }
            else {
                fWrap.lwcFieldClass = fieldName;
            }
            fWrap.fieldType = String.valueOf(field.getDescribe().getType());
            if( fWrap.fieldType == 'COMBOBOX' ){
                fWrap.isCombobox = true;
                fWrap.fieldValue = defaultValueMap.get(fieldName) != null ? (String)defaultValueMap.get(fieldName) : null;
                fWrap.isRequired = M.get(fieldName).getDescribe().isNillable()== false ? true : false;
            }
            if( fWrap.fieldType == 'STRING' ){
                fWrap.isText = true;
                fWrap.fieldValue = defaultValueMap.get(fieldName) != null ? (String)defaultValueMap.get(fieldName) : null;
                fWrap.isRequired = M.get(fieldName).getDescribe().isNillable()== false ? true : false;
            }
            if( fWrap.fieldType == 'TEXTAREA' ){
                fWrap.isTextArea = true;
                fWrap.fieldValue = defaultValueMap.get(fieldName) != null ? (String)defaultValueMap.get(fieldName) : null;
                fWrap.isRequired = M.get(fieldName).getDescribe().isNillable()== false ? true : false;
            }
            if( fWrap.fieldType == 'EMAIL' ){
                fWrap.isEmail = true;
                fWrap.fieldValue = defaultValueMap.get(fieldName) != null ? (String)defaultValueMap.get(fieldName) : null;
                fWrap.isRequired = M.get(fieldName).getDescribe().isNillable()== false ? true : false;
            }
            if( fWrap.fieldType == 'PHONE' ){
                fWrap.isPhone = true;
                fWrap.fieldValue = defaultValueMap.get(fieldName) != null ? (String)defaultValueMap.get(fieldName) : null;
                fWrap.isRequired = M.get(fieldName).getDescribe().isNillable()== false ? true : false;
            }

            if( fWrap.fieldType == 'BOOLEAN'){
                fWrap.isBoolean = true;
                fWrap.booleanValue = defaultValueMap.get(fieldName) != null ? (Boolean)defaultValueMap.get(fieldName) : null;
                fWrap.isRequired = M.get(fieldName).getDescribe().isNillable()== false ? true : false;
            }
            if( fWrap.fieldType == 'DATETIME'){
                fWrap.isDateTime = true;
                fWrap.dateTimeValue = defaultValueMap.get(fieldName) != null ? (DateTime)defaultValueMap.get(fieldName) : null;
                fWrap.isRequired = M.get(fieldName).getDescribe().isNillable()== false ? true : false;
                if(isFollowUp == false)
                {
                    if( fieldName == 'StartDateTime'){
                        fWrap.dateTimeValue = system.now();
                        fWrap.isRequired = true;
                    }
                    if( fieldName == 'EndDateTime'){
                        fWrap.dateTimeValue = system.now().addHours(1);
                        fWrap.isRequired = true;
                    }
                }
            }
            if( fWrap.fieldType == 'DATE'){
                fWrap.isDate = true;
                if(currentObject == 'Task' && fieldName.equalsIgnoreCase('ActivityDate') && isFollowUp == false){// && taskType =='Call' Critical Bug Nikita S
                    fWrap.dateValue = System.today();
                }else{
                    fWrap.dateValue = defaultValueMap.get(fieldName) != null ? (Date)defaultValueMap.get(fieldName) : null;
                }
                fWrap.isRequired = M.get(fieldName).getDescribe().isNillable()== false ? true : false;
            }
            if( fWrap.fieldType == 'PICKLIST'){
                fWrap.isPicklist = true;
                if(isFollowUp == true){
                    if(fieldName.contains('lassification')){//fixed by Sudhanshu for critical bug: 00046148, 00047050
                        fWrap.fieldValue = '';
                    }
                    else{
                        fWrap.fieldValue = defaultValueMap.get(fieldName) != null ? (String)defaultValueMap.get(fieldName) : null;
                    }
                }
                else{
                    if(currentObject == 'Task' && fieldName == 'Status' && taskType =='Call'){
                        fWrap.fieldValue = 'Completed';
                    }
                    else if(fieldName.contains('lassification')){//fixed by Nikita S for critical bug: 34598
                        fWrap.fieldValue = '';
                    }
                    else{
                        fWrap.fieldValue = defaultValueMap.get(fieldName) != null ? (String)defaultValueMap.get(fieldName) : null;
                    }
                }
                
                if( fieldName.equalsIgnoreCase('Status') || fieldName.equalsIgnoreCase('Priority')){
                    fWrap.isRequired = true;
                }
                else {
                    fWrap.isRequired = M.get(fieldName).getDescribe().isNillable()== false ? true : false;
                }
                
            }
            if( fWrap.fieldType == 'REFERENCE'){
                fWrap.isReference = true;
                
                if(fieldName.equalsIgnoreCase('ownerid')){
                    fWrap.fieldValue = userinfo.getUserId();
                    fWrap.referenceObjName = 'User';
                    fWrap.isRequired = true;
                }else{
                    Schema.DescribeFieldResult f = Schema.getGlobalDescribe().get(currentObject).getDescribe().fields.getMap().get(fieldName).getDescribe();

                    for(Schema.SObjectType reference : f.getReferenceTo()) {
                        fWrap.referenceObjName = reference.getDescribe().getName();
                        fWrap.isRequired = M.get(fieldName).getDescribe().isNillable()== false ? true : false;
                        break;
                    }
                }
            }
            if(fWrap.fieldType == 'INTEGER' || fWrap.fieldType == 'DOUBLE'){
                fWrap.isNumber = true;
                fWrap.numberValue = defaultValueMap.get(fieldName) != null ? (Decimal)defaultValueMap.get(fieldName) : null;
                fWrap.isRequired = M.get(fieldName).getDescribe().isNillable()== false ? true : false;
            }
            if( math.mod(count,2) != 0 ){
                fWrap.isLeftField = true;
            }else{
                fWrap.isRightField = true;
            }

            if(supportedType.contains(fWrap.fieldType))         // Bug ID : 00044237 fixed on 27-02-2024 by Sudhanshu
            {
                fieldWrapList.add(fWrap);
                count++;
            }
        }
        return fieldWrapList;
    }
    
    /****************************************************************************************************
    Purpose : get Suggestions based on the comments

    Input : commentStr - text from descriprion field.
            searchObjects - all the setup objects from navatar setup objec used for activity association
            allTaggedRecords -  all tagged record from lwc.

    Returns : serialized string of matched reocrds
    ****************************************************************************************************/
    @AuraEnabled
    public static String getSuggestions(string commentStr, string searchObjects, String allTaggedRecords){
        try {
            system.debug('searchable objects '+searchObjects);
            List<RecordWrapper> recordList = new List<RecordWrapper>();
            if(commentStr.length() > 3){
                List<RecordWrapper> allTaggedRecordsList = (List<RecordWrapper>)Json.deserialize(allTaggedRecords, (List<RecordWrapper>.class));
                Set<String> clientExclusionSet = new Set<String>();
              //  string strOrgSpacePrefix = CommonUtility_EdgeMenu.strOrgNameSpacePrefix;
              //  string strPackNameSpacePrefix = CommonUtility_EdgeMenu.strNameSpacePrefix;
               // String exclusionField = strNameSpacePrefix+'Notes_Tag_Exclusion_List__c';
               // bug 00045756 fixed by sudhanshu on 20-05-2024
                String exclusionField = strPackNameSpacePrefix != null ? strPackNameSpacePrefix+'Notes_Tag_Exclusion_List__c' : 'Notes_Tag_Exclusion_List__c';
                if(Schema.getGlobalDescribe().get(strPackNameSpacePrefix+'Navatar_Setup__c').getDescribe().fields.getMap().containsKey(exclusionField)){
                    List<sObject> lst = new List<sObject>();
                    String strQuery = 'SELECT Id,'+exclusionField+' FROM '+strPackNameSpacePrefix+'Navatar_Setup__c Where '+strPackNameSpacePrefix+'Admin_Setting__c = true Order by CreatedDate ASC LIMIT 1';
                    lst = Database.query(string.escapesinglequotes(strQuery));
                    if(lst[0].get((exclusionField)) != null){
                        String exclusionStr = lst[0].get((exclusionField)).toString();
                        clientExclusionSet.addAll(exclusionStr.trim().split(','));
                    }
                }
                // get ids of already tagged records.
                Set<String> taggedRecordIds = new Set<String>();
                For(RecordWrapper recWrap : allTaggedRecordsList){
                    taggedRecordIds.add(recWrap.Id.substring(0,15));
                }
                
                Map<String, String> objNameVsObjIcon = new Map<String, String>();
                
                // remove all html tags, "or" and "and " from string.
                commentStr = commentStr.stripHtmlTags();
                system.debug('commentStr=='+commentStr);

                
                List<String> searchStringSplitList = commentStr.split(' ');
                Set<String> searchStringList = new Set<String>();

                Set<String> searchStringSplit = new set<String>();
                searchStringSplit.addAll(searchStringSplitList);
                // create search string by concating "OR" we have limit of 4000 char for sosl so if single string size is morre then 3980 we store other values in new string.
                Set<String> soslLikeWords = new Set<String>();
                Set<String> soslINWords = new Set<String>();
                String soslSearchString = '';
                Set<String> finalComStr = new Set<String>();
                
                if(clientExclusionSet.size() > 0){
                    Set<String> exclusionSet = new Set<String>();
                    for(String str1 : clientExclusionSet){
                        exclusionSet.add(str1.trim().toLowerCase());
                    }
                    System.debug('1391 '+exclusionSet);
                    for(String str : searchStringSplit){
                        if(!exclusionSet.contains(str.toLowerCase())){
                            finalComStr.add(str);
                        }
                    }
                    searchStringSplit = finalComStr;
                }

                System.debug(searchStringSplit+'  '+finalComStr);
                Pattern specialCharPattern = Pattern.compile('[^a-zA-Z0-9]');
                For(String str : searchStringSplit){
                    if(str != null && str!= '' && str != ' ' && str != '\n'){
                        // Start Code Optimization
                        String soslStr = str;
                        
                        //Boolean checkSpl = false;
                        soslINWords.add(soslStr);
                       // if(soslStr.indexOf('\\') == -1){

                        String soslWord = '% '+soslStr;
                        soslLikeWords.add(soslWord);
                        soslWord = soslStr+' %';
                        soslLikeWords.add(soslWord);
                        soslWord = '% '+soslStr+' %';
                        soslLikeWords.add(soslWord);

                            Matcher patternMatcher = specialCharPattern.matcher(soslStr);
                            Boolean hasSpecialChars = patternMatcher.find();
                           // if(!soslStr.isAsciiPrintable()){
                                
                            //checkSpl = hasSpecialChars ? soslStr.indexOf('\'') != -1 ? true : false : true;                       
                            
                        /*}
                        else{
                            
                            System.debug('1447 '+soslStr);
                            checkSpl = true;
                        }*/
                        
                        // End Code Optimization
                        
                       // if(checkSpl){
                        if(soslStr.indexOfAny('\\())') == -1){//Bug fixed - 00041270 Phase 3
                        if(soslSearchString.length() < 3980){
                            if(soslSearchString == ''){
                                soslSearchString = soslSearchString + string.escapesinglequotes(str.trim());
                            }else{
                                soslSearchString = soslSearchString + ' OR ' + string.escapesinglequotes(str.trim());
                            }
                        }else{
                            system.debug('in else=='+soslSearchString);
                            searchStringList.add(soslSearchString);
                            soslSearchString = '';
                        }
                    }
                    //}
                    }
                }
                system.debug('str=='+searchStringList.size());
                searchStringList.add(soslSearchString);
                Set<string> foundIds = new Set<string>();
                // search all data based on search string.
                list<LookupWrapper> multiWrpCls = (list<LookupWrapper>)JSON.deserialize(searchObjects, list<LookupWrapper>.class);
                For(String soqlSearch : searchStringList){
                    System.debug('@@@ '+soqlSearch);
                    //soqlSearch = soqlSearch.replace('-', '\\-');
                    List<string> soslObjList = new List<string>();
                    For(LookupWrapper obj : multiWrpCls){
                        //00031532 -- added to show object icon
                        System.debug('@@@ '+obj.objectName);
                        if(obj.objectName != strPackNameSpacePrefix+'Fundraising__c'){
                        objNameVsObjIcon.put(obj.objectLabel, obj.IconName);
                        boolean isObjAccess = Schema.getGlobalDescribe().get(obj.objectName).getDescribe().isAccessible();
                        if(isObjAccess){
                            string str = '';
                                str = string.escapesinglequotes(obj.objectName)+' ( ID, Name Where name like :soslLikeWords OR Name IN :soslINWords )';
                            soslObjList.add(str);
                        }
                    }
                    }
                    System.debug('soslLikeWords=== '+soslLikeWords);
                    system.debug('soslObjList=='+soslObjList);
                    string soslQry = 'FIND \''+ soqlSearch + '\'  IN NAME FIELDS RETURNING ' +  string.join(soslObjList,',');
                    system.debug('soslQry=='+soslQry);
                    List<List <sObject>> myQuery = search.query(soslQry+' WITH USER_MODE');

                    
                    // store matched data in wrapper
                    for(list<sObject> objectList : myQuery) {
                        for(sObject sobj : objectList) {
                            system.debug('sobj=='+sobj);
                            RecordWrapper recWrap = new RecordWrapper();
                            // check if match records is already tagged or not. it yes do not store in wrapper.
                            if(  !taggedRecordIds.contains(((String)sObj.get('ID')).substring(0,15)) && !foundIds.contains(((String)sObj.get('ID')).substring(0,15))  ){
                                foundIds.add(((String)sObj.get('ID')).substring(0,15));
                                recWrap.Name = (String)sObj.get('Name');
                                recWrap.Id = (String)sObj.get('Id');
                                Id recId = (Id)sObj.get('Id');
                                String sObjName = recId.getSObjectType().getDescribe().getLabel();
                                recWrap.objectName = sObjName;
                                // bug 	00047558 fixed by Sudhanshu
                                String sObjApiName = recId.getSObjectType().getDescribe().getName();
                                recWrap.objectApiName = sObjApiName;
                                recWrap.iconName = objNameVsObjIcon.get(sObjName);
                                recordList.add(recWrap);
                            }
                        }
                    }
                }
            }

            return JSON.serialize(recordList);

        } catch (Exception e) {
            system.debug('e=='+e);
            system.debug('e=='+e.getLineNumber());
            throw new AuraHandledException(e.getMessage());
        }
    }


    
    /****************************************************************************************************
    Purpose : get related data on press of @

    Input : searchString - inputed string after @
            searchObjects - all the setup objects from navatar setup objec used for activity association

    Returns : serialized string of matched reocrds
    ****************************************************************************************************/
    @AuraEnabled
    public static String getRelatedData(String searchString, String searchObjects, String allTaggedRecords){
        try {

            List<RecordWrapper> allTaggedRecordsList = (List<RecordWrapper>)Json.deserialize(allTaggedRecords, (List<RecordWrapper>.class));
            // get ids of already tagged records.
            List<String> taggedRecordIds = new List<String>();
            For(RecordWrapper recWrap : allTaggedRecordsList){
                if(recWrap.Id != null){
                    taggedRecordIds.add(recWrap.Id.substring(0,15));
                }
            }

            system.debug('taggedRecordIds=='+taggedRecordIds);
            // make searchString 
            string soqlSearch = string.escapesinglequotes(searchString);
            searchString = '%' +string.escapesinglequotes(searchString) + '%';

            list<LookupWrapper> multiWrpCls = (list<LookupWrapper>)JSON.deserialize(searchObjects, list<LookupWrapper>.class);
            List<RecordWrapper> recordList = new List<RecordWrapper>();
            system.debug('multiWrpCls=='+multiWrpCls);

            List<string> soslObjList = new List<string>();
            Map<String, String> objNameVsObjIcon = new Map<String, String>();

            //generate dynamic sosl based on set-up objects of AA.
            For(LookupWrapper obj : multiWrpCls){
                objNameVsObjIcon.put(obj.objectName, obj.IconName);
                boolean isObjAccess = Schema.getGlobalDescribe().get(obj.objectName).getDescribe().isAccessible();
                if(isObjAccess){
                    // Bug 00047979 fixed by sudhanshu
                    if(obj.objectName == 'Contact'){
                        string str = string.escapesinglequotes(obj.objectName)+' ( ID, Name, Account.Name Where name like \''+searchString +'\')';
                        soslObjList.add(str);
                    }
                    else{
                        string str = string.escapesinglequotes(obj.objectName)+' ( ID, Name Where name like \''+searchString +'\')';
                        soslObjList.add(str);
                    }
                    
                }
            }
            system.debug('soslObjList=='+soslObjList);
            string soslQry = 'FIND \''+ soqlSearch + '\'  IN ALL FIELDS RETURNING ' +  string.join(soslObjList,',');
            system.debug('soslQry=='+soslQry);
            List<List <sObject>> myQuery = search.query(soslQry);

            //get data from sosl result and store it on wrapperList
            For(List <sObject> sobjlist : myQuery){
                For(SObject sObj : sObjList){
                    //if(!taggedRecordIds.contains(((String)sObj.get('ID')).substring(0,15))){
                        RecordWrapper recWrap = new RecordWrapper();
                        recWrap.Name = (String)sObj.get('Name');
                        recWrap.Id = (String)sObj.get('Id');
    
                        Id recId = (String)sObj.get('Id');
                        String sObjName = recId.getSObjectType().getDescribe().getName();
    
                        recWrap.iconName = objNameVsObjIcon.get(sObjName);
                        // Bug 00047979 fixed by sudhanshu
                        recWrap.isContact = sObjName == 'Contact' ? true : false ;
                        if(sObjName == 'Contact')
                        {
                            recWrap.actName = (String)sObj.getSObject('Account').get('Name');
                        }
                        recordList.add(recWrap);
                    //}
                    
                }
            }
            system.debug('recordList=='+recordList);

            return JSON.serialize(recordList);

        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    /****************************************************************************************************
    Purpose : get set-up object and layout fields from navatar setup object

    Returns : list of strings which includes objectList and auout details
    ****************************************************************************************************/
    @AuraEnabled
    public static List<string> getSearchableObjName(String recordIdval){
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
            
            
            list<String> objectAPIName = new list<String>();
            for(integer i=0;i<RAS.split(',').size();i++){
                String keyPrefix = RAS.split(',')[i];
                for( Schema.SObjectType obj : Schema.getGlobalDescribe().Values() ){
                    String prefix = obj.getDescribe().getKeyPrefix();
                    if(prefix!= null && prefix.equals(keyPrefix)){
                        objectAPIName.add(obj.getDescribe().getName());
                        break;
                    }
                }
            }
            //removal of CommonUtility as its deprecated Code by Anmol
            objectAPIName.sort();
            list<LookupWrapper> multiWrpCls = new list<LookupWrapper>();
            
            for(string objName: objectAPIName){

                Boolean isCreateable = Schema.getGlobalDescribe().get(objName).getDescribe().isCreateable();
                String objLabel = Schema.getGlobalDescribe().get(objName).getDescribe().getLabel();
                    
                LookupWrapper multiLW = new LookupWrapper();
                multiLW.objectName = objName;
                multiLW.objectLabel = objLabel;
                multiLW.isCreateableAccess = isCreateable;
                multiWrpCls.add(multiLW);
            }
            //Code change for 00033911 started: by Anmol
            List<JsonResponse> layoutInfo = (list<JsonResponse>)System.JSON.deserialize(fetchEndpointResponse('/services/data/v55.0/tabs'), List<JsonResponse>.class);
            for(LookupWrapper lookupWrap : multiWrpCls){
                for(JsonResponse tab : layoutInfo){
                    System.debug('tab.label=='+tab.label);
                    if(lookupWrap.objectName == 'navpeII_dev18__Theme__c'){
                        for(Icons icon : tab.icons){
                            if(icon.height == 0 && icon.theme == 'theme4' && tab.label.equalsIgnoreCase('Themes')){
                                //objApiNameVsIconNameMap.put(objApiName, icon.url.split('/')[6] + ':' + (icon.url.split('/')[7]).split('\\.')[0]);
                                lookupWrap.IconName = icon.url.split('/')[6] + ':' + (icon.url.split('/')[7]).split('\\.')[0];
                                break;
                            }
                        }
                    }
                    if(tab.sobjectName.equalsIgnoreCase(lookupWrap.objectName) || tab.label.equalsIgnoreCase(lookupWrap.objectName)){
                        for(Icons icon : tab.icons){
                            if(icon.height == 0 && icon.theme == 'theme4'){
                                //objApiNameVsIconNameMap.put(objApiName, icon.url.split('/')[6] + ':' + (icon.url.split('/')[7]).split('\\.')[0]);
                                lookupWrap.IconName = icon.url.split('/')[6] + ':' + (icon.url.split('/')[7]).split('\\.')[0];
                                break;
                            }
                        }
                    }
                    else{
                        if(lookupWrap.objectName == 'User'){
                            lookupWrap.IconName = 'standard:user';
                        }
                    }
                }
            }
            //Code change for 00033911 ended: by Anmol
            ////added code for Security Fix checking Updateable:started
            String uNotes_Popup_Task_Fields='';
            String uNotes_Popup_Event_Fields='';
            String uNotes_Popup_FollowUp_Task_Fields='';
            if(String.isBlank(recordIdval)){
            for(String str:checkCreateableFields(Schema.getGlobalDescribe().get('Task'),Notes_Popup_Task_Fields.split(',') ) ){
                if(String.isNotBlank(str))
                uNotes_Popup_Task_Fields+=str+',';
            }
			uNotes_Popup_Task_Fields=uNotes_Popup_Task_Fields.removeEnd(','); //FIx for FLS issues
            for(String str:checkCreateableFields(Schema.getGlobalDescribe().get('Event'),Notes_Popup_Event_Fields.split(',') ) ){
                if(String.isNotBlank(str))
                uNotes_Popup_Event_Fields+=str+',';
            }
			uNotes_Popup_Event_Fields=uNotes_Popup_Event_Fields.removeEnd(',');  //FIx for FLS issues
            for(String str:checkCreateableFields(Schema.getGlobalDescribe().get('Task'),Notes_Popup_FollowUp_Task_Fields.split(',') ) ){
                if(String.isNotBlank(str))
                uNotes_Popup_FollowUp_Task_Fields+=str+',';
            }
			uNotes_Popup_FollowUp_Task_Fields=uNotes_Popup_FollowUp_Task_Fields.removeEnd(',');  //FIx for FLS issues
        }
        else{
            for(String str:checkUpdateableFields(Schema.getGlobalDescribe().get('Task'),Notes_Popup_Task_Fields.split(',') ) ){
                if(String.isNotBlank(str))
                uNotes_Popup_Task_Fields+=str+',';
            }
			uNotes_Popup_Task_Fields=uNotes_Popup_Task_Fields.removeEnd(',');  //FIx for FLS issues
            for(String str:checkUpdateableFields(Schema.getGlobalDescribe().get('Event'),Notes_Popup_Event_Fields.split(',') ) ){
                if(String.isNotBlank(str))
                uNotes_Popup_Event_Fields+=str+',';
            }
			uNotes_Popup_Event_Fields=uNotes_Popup_Event_Fields.removeEnd(',');  //FIx for FLS issues
            for(String str:checkUpdateableFields(Schema.getGlobalDescribe().get('Task'),Notes_Popup_FollowUp_Task_Fields.split(',') ) ){
                if(String.isNotBlank(str))
                uNotes_Popup_FollowUp_Task_Fields+=str+',';
            }
			uNotes_Popup_FollowUp_Task_Fields=uNotes_Popup_FollowUp_Task_Fields.removeEnd(','); //FIx for FLS issues
        }
            //added code for Security Fix checking Updateable:ended
            return new List<String>{JSON.serialize(multiWrpCls), uNotes_Popup_Task_Fields, uNotes_Popup_Event_Fields, uNotes_Popup_FollowUp_Task_Fields, AD_Switcher};
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    //Code change for 00033911 started: by Anmol
    /*
     * Purpose : Fetches response on hitting the API
     * Input : endpointUrl       [Endpoint URL to hit]
     * Returns : Response on hitting the API
     */
    public static String fetchEndpointResponse(String endpointUrl){
        try {
            HttpRequest req = new HttpRequest();
            String domainUrl = URL.getSalesforceBaseUrl().toExternalForm();
            req.setEndpoint(domainUrl + endpointUrl);
            req.setMethod('GET');
            String sessionId = getSessionIdFromVFPage(Page.sessionIdPage);    
            String auth = 'Bearer ' + sessionId;
            req.setHeader('Authorization', auth);
            Http http = new Http();
            HTTPResponse resp = new HTTPResponse();
            if(!Test.isRunningTest()){
                resp = http.send(req);
            }else{
                resp = new HTTPResponse();
                resp.setBody('[{"colors":[{"color":"48c7c8","context":"primary","theme":"theme4"},{"color":"2AABAB","context":"primary","theme":"theme3"}],"custom":true,"iconUrl":"https://navatar-1f--lakshya.sandbox.my.salesforce.com/img/icon/plane32.png","icons":[{"contentType":"image/png","height":32,"theme":"theme3","url":"https://navatar-1f--lakshya.sandbox.my.salesforce.com/img/icon/plane32.png","width":32},{"contentType":"image/png","height":16,"theme":"theme3","url":"https://navatar-1f--lakshya.sandbox.my.salesforce.com/img/icon/plane16.png","width":16},{"contentType":"image/svg+xml","height":0,"theme":"theme4","url":"https://navatar-1f--lakshya.sandbox.my.salesforce.com/img/icon/t4v35/custom/custom20.svg","width":0},{"contentType":"image/png","height":60,"theme":"theme4","url":"https://navatar-1f--lakshya.sandbox.my.salesforce.com/img/icon/t4v35/custom/custom20_60.png","width":60},{"contentType":"image/png","height":120,"theme":"theme4","url":"https://navatar-1f--lakshya.sandbox.my.salesforce.com/img/icon/t4v35/custom/custom20_120.png","width":120}],"label":"All Interactions","miniIconUrl":"https://navatar-1f--lakshya.sandbox.my.salesforce.com/img/icon/plane16.png","name":"All_Interactions","sobjectName":"0RbDN000000Kz6f","url":"https://navatar-1f--lakshya.sandbox.my.salesforce.com/servlet/servlet.Integration?lid=01rDN0000008Vv5&eid=0RbDN000000Kz6f&ic=1&linkToken=VmpFPSxNakF5TXkwd01pMHhNRlF4TURveE1EbzFOUzQzTlRWYSxEbVJLY1BpZXBsbHRIX3ZvUTFGd3MzLFlXWmtNR0po"},{"colors":[{"color":"7F8DE1","context":"primary","theme":"theme4"},{"color":"236FBD","context":"primary","theme":"theme3"}],"custom":false,"iconUrl":"https://navatar-1f--lakshya.sandbox.my.salesforce.com/img/icon/accounts32.png","icons":[{"contentType":"image/png","height":32,"theme":"theme3","url":"https://navatar-1f--lakshya.sandbox.my.salesforce.com/img/icon/accounts32.png","width":32},{"contentType":"image/png","height":16,"theme":"theme3","url":"https://navatar-1f--lakshya.sandbox.my.salesforce.com/img/icon/accounts16.png","width":16},{"contentType":"image/svg+xml","height":0,"theme":"theme4","url":"https://navatar-1f--lakshya.sandbox.my.salesforce.com/img/icon/t4v35/standard/account.svg","width":0},{"contentType":"image/png","height":60,"theme":"theme4","url":"https://navatar-1f--lakshya.sandbox.my.salesforce.com/img/icon/t4v35/standard/account_60.png","width":60},{"contentType":"image/png","height":120,"theme":"theme4","url":"https://navatar-1f--lakshya.sandbox.my.salesforce.com/img/icon/t4v35/standard/account_120.png","width":120}],"label":"Firms","miniIconUrl":"https://navatar-1f--lakshya.sandbox.my.salesforce.com/img/icon/accounts16.png","name":"standard-Account","sobjectName":"Account","url":"https://navatar-1f--lakshya.sandbox.my.salesforce.com/001/o"},{"colors":[{"color":"d58a6a","context":"primary","theme":"theme4"},{"color":"C39567","context":"primary","theme":"theme3"}],"custom":true,"iconUrl":"https://navatar-1f--lakshya.sandbox.my.salesforce.com/img/icon/insect32.png","icons":[{"contentType":"image/png","height":32,"theme":"theme3","url":"https://navatar-1f--lakshya.sandbox.my.salesforce.com/img/icon/insect32.png","width":32},{"contentType":"image/png","height":16,"theme":"theme3","url":"https://navatar-1f--lakshya.sandbox.my.salesforce.com/img/icon/insect16.png","width":16},{"contentType":"image/svg+xml","height":0,"theme":"theme4","url":"https://navatar-1f--lakshya.sandbox.my.salesforce.com/img/icon/t4v35/custom/custom34.svg","width":0},{"contentType":"image/png","height":60,"theme":"theme4","url":"https://navatar-1f--lakshya.sandbox.my.salesforce.com/img/icon/t4v35/custom/custom34_60.png","width":60},{"contentType":"image/png","height":120,"theme":"theme4","url":"https://navatar-1f--lakshya.sandbox.my.salesforce.com/img/icon/t4v35/custom/custom34_120.png","width":120}],"label":"All Themes","miniIconUrl":"https://navatar-1f--lakshya.sandbox.my.salesforce.com/img/icon/insect16.png","name":"All_Themes","sobjectName":"0RbDN000000KzM2","url":"https://navatar-1f--lakshya.sandbox.my.salesforce.com/servlet/servlet.Integration?lid=01rDN0000008Vxp&eid=0RbDN000000KzM2&ic=1&linkToken=VmpFPSxNakF5TXkwd01pMHhNRlF4TURveE1EbzFOUzQzTlRWYSxEbVJLY1BpZXBsbHRIX3ZvUTFGd3MzLFlXWmtNR0po"}]');
                resp.setStatusCode(200);
            }
            return resp.getBody();
        } catch(Exception e) {
            throw new AuraHandledException( ' : <<' + e.getStackTraceString() + '>>');
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
            throw new AuraHandledException(' : <<' + e.getStackTraceString() + '>>');
        }
    }
    //Code change for 00033911 ended: by Anmol

    // tp store record info
    public class RecordWrapper{
        @AuraEnabled public string Name;
        @AuraEnabled public string Id;
        @AuraEnabled public string iconName;
        @AuraEnabled public string objectName;
        @AuraEnabled public boolean isUser;
        // added by Sudhanshu 47979
        @AuraEnabled public boolean isContact;
        @AuraEnabled public String actName;
        @AuraEnabled public String objectApiName;   // bug 	00047558 fixed by Sudhanshu
    }

    // to store setup object info
    public class LookupWrapper{
        @AuraEnabled public String pluralLabel;
        @AuraEnabled public String objectName;  
        @AuraEnabled public String IconName; 
        @AuraEnabled public String objectLabel; 
        @AuraEnabled public boolean isCreateableAccess;
    }

    // to store api response
    public class FromJSON{
        public cls_colors[] colors;
        public boolean custom;
        public cls_icons[] icons;
        public String label;    //DemoObjects
        public String sobjectName;  //DemoObject__c
    }
    class Cls_colors {
        public String color;    //2ECBBE
        public String context;  //primary
        public String theme;    //theme4
    }
    //Code change for 00033911 started: by Anmol
    /*
     * Purpose : Wrapper to store API response
     */
    public class JsonResponse{
        public Colors[] colors;
        public boolean custom;
        public Icons[] icons;
        public String label;        //DemoObjects
        public String sobjectName;  //DemoObject__c
    }
    /*
     * Purpose : Child wrapper of JsonResponse
     */
    public class Colors{
        public String color;    //2ECBBE
        public String context;  //primary
        public String theme;    //theme4
    }

    /*
     * Purpose : Child wrapper of JsonResponse
     */
    public class Icons{
        public String contentType;  //image/png
        public Integer height;      //32
        public Integer width;       //32
        public String theme;        //theme3
        public String url;          //https://activityassociation-dev-ed.my.salesforce.com/img/icon/reports32.png
    }
    //Code change for 00033911 ended: by Anmol
    class Cls_icons {
        public String contentType;  //image/png
        public Integer height;  //32
        public String theme;    //theme3
        public String url;  //https://activityassociation-dev-ed.my.salesforce.com/img/icon/reports32.png
        public Integer width;   //32
    }

    /****************************************************************************************************
    Purpose : get default values of fields

    Input : objectName - name of object
            lstofApi - list of fields to get default values.

    Returns : map of fieldname and its value
    ****************************************************************************************************/
    @AuraEnabled
    public static Map<String, Object> getDefaultValues(string objectName, list<string> lstofApi){
        Map<String, Schema.SObjectField> fieldMap = new Map<String, Schema.SObjectField>();

        //get schema of object
        fieldMap = Schema.getGlobalDescribe().get(objectName).getDescribe().fields.getMap();
        Map<String, Object> defaultValueMap = new Map<String, Object>();
        for(Schema.SObjectField sField : fieldMap.Values()) 
        {
            Schema.DescribeFieldResult dField = sField.getDescribe();                  
            Date mydate;
            DateTime dateTimeValue;
            String dateTimeInString = '';
            String dateInString = '';
            
            //get the field a[i anme from list and create map of fieldapi abd value.
            if( lstofApi.contains(dField.getname()) )
            {
                String strType = String.valueof(dField.getType());
                try
                {   
                    if(dfield.getName() != 'IsReminderSet'){
                        if( String.IsBlank(dfield.getDefaultValueFormula()) && !String.IsBlank(String.valueOf(dfield.getDefaultValue())) &&  
                           (strType == 'STRING' || strType == 'URL' || strType == 'EMAIL' || strType == 'PHONE' || strType == 'PICKLIST' || strType == 'TEXTAREA' || strType == 'COMBOBOX') )
                        {
                            defaultValueMap.put(dfield.getName(), String.valueOf(dfield.getDefaultValue()).removeStart('"').removeStart('\'').removeEnd('"').removeEnd('\'') );
                        }
                        if(!String.IsBlank(dfield.getDefaultValueFormula()) && (strType == 'STRING' || strType == 'URL' || strType == 'EMAIL' || strType == 'PHONE' || strType == 'PICKLIST' || strType == 'TEXTAREA' || strType == 'COMBOBOX') )
                        {
                            defaultValueMap.put(dfield.getName(), dfield.getDefaultValueFormula().removeStart('"').removeStart('\'').removeEnd('"').removeEnd('\'') );
                        } 
                        else if(!String.IsBlank(dfield.getDefaultValueFormula()) && (strType == 'INTEGER') )
                        {  
                            defaultValueMap.put(dfield.getName(), Integer.valueof(dfield.getDefaultValueFormula() ));
                        }
                        else if(!String.IsBlank(dfield.getDefaultValueFormula()) && (strType == 'DOUBLE') )
                        {  
                            defaultValueMap.put(dfield.getName(), DOUBLE.valueof(dfield.getDefaultValueFormula() ));
                        }
                        else if(!String.IsBlank(String.valueOf(dfield.getDefaultValue())) && (strType == 'BOOLEAN') )
                        {  
                            defaultValueMap.put(dfield.getName(), Boolean.valueof(dfield.getDefaultValue()));
                        }
                        else if(!String.IsBlank(dfield.getDefaultValueFormula()) && (strType == 'CURRENCY' || strType == 'PERCENT') )
                        {                      
                            defaultValueMap.put(dfield.getName(), Decimal.valueOf(dfield.getDefaultValueFormula() ));
                        }   
                        if(!String.IsBlank(dfield.getDefaultValueFormula()) && strType == 'PHONE')
                        {
                            defaultValueMap.put(dfield.getName(), String.valueOf(dfield.getDefaultValueFormula().remove('"').remove('\'')) );
                        }                 
                        else if(!String.IsBlank(dfield.getDefaultValueFormula()) && strType == 'DATE')
                        {                                           
                            dateInString = dfield.getDefaultValueFormula();                          
                            dateInString = dateInString.toLowerCase();
                            String tempDateVal = dateInString.replace('today()', '').replace('now()', '').replaceAll( '\\s+', '');
                            if(dateInString.startsWith('(')){
                                dateInString = dateInString.substring(1,dateInString.length()-1);
                                tempDateVal = tempDateVal.substring(1,tempDateVal.length()-1);
                            }
                            mydate = Date.Valueof(dateInString.replace('today()', ''+System.Today()+'').replace('now()', ''+System.now()+''));
                            if(tempDateVal != null && tempDateVal !=''){
                                mydate= mydate.addDays(integer.valueof(tempDateVal));
                            }
                            defaultValueMap.put(dfield.getName(), mydate);
                        }
                        else if(!String.IsBlank(dfield.getDefaultValueFormula()) && strType == 'DATETIME')
                        {    
                            dateInString = dfield.getDefaultValueFormula();                            
                            dateInString = dateInString.toLowerCase();
                            string tempDateVal = dateInString.replace('today()', '').replace('now()', '').replaceAll( '\\s+', '');
                            dateInString = dateInString.replace('today()', ''+System.Today()+'').replace('now()', ''+System.now()+'');
                            if(dateInString.startsWith('(')){
                                dateInString = dateInString.substring(1,dateInString.length()-1);
                                tempDateVal = tempDateVal.substring(1,tempDateVal.length()-1);
                            }
                            dateTimeValue = DateTime.valueOfGMT(dateInString.replace('today()', ''+System.Today()+'').replace('now()', ''+System.now()+''));
                            if(tempDateVal != null && tempDateVal !=''){
                                dateTimeValue = dateTimeValue.addDays(integer.valueof(tempDateVal));
                            }
                            string mydtstring = dateTimeValue.format(); 
                            Datetime dt = DateTime.parse(mydtstring);
                            defaultValueMap.put(dfield.getName(), dt);
                        } 
                    }
                    
                }
                catch(Exception ex){
                    throw new AuraHandledException(ex.getMessage());
                }
            }
        }
        return defaultValueMap;
    }

    @AuraEnabled
    public static Datetime adjustEventStartEndDate(Datetime startDate){
        try {
            return startDate.addHours(1);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static Date getTodayDate(){
        try {
            return system.today();
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static List<Datetime> getEventDateTime(){
        try {
            List<Datetime> timeList = new List<Datetime>();
            timeList.add(system.now());
            timeList.add(system.now().addHours(1));
            return timeList;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    /*****************************************************************************************************
    * @Name         :   getObjectName
    * @Description  :   Method to get thename of objecton the basis of recordId
    * @Param        :   recordId: id of record to get the object name
    *****************************************************************************************************/
    @AuraEnabled
    public static String getObjectName(Id recordId){
        if(recordId != null){
            return null;
        }
        else{
             String sObjName = recordId.getSObjectType().getDescribe().getName();
            return sObjName;
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
    private static List<String> checkCreateableFields(Schema.SObjectType objectType, List<String> fieldNames) {
        Map<String, Schema.SobjectField> fields = objectType.getDescribe().fields.getMap();
        //System.debug('Before: '+fieldNames);
        for (String s : fieldNames.clone() ) {
            //System.debug(fields.keySet());
            if (!(fields.get(s.toLowerCase()).getDescribe().isCreateable()) ) {
                System.debug(s+' '+fieldNames);
                fieldNames.remove(fieldNames.indexOf(s));
            }
        }
        //System.debug('After: '+fieldNames);
        return fieldNames;
    }

    /* Added below method by Lakshya on 2023-11-03 to check if activity is archived or, not */
    @AuraEnabled
    public static String checkActivityArchivedState(String activityId, String activityType){
        try {
            List<sObject> activityList = new List<sObject>();
            activityList = Database.query('SELECT IsArchived FROM ' + activityType + ' WHERE Id =: activityId AND IsDeleted = false ALL ROWS');
            return ((activityList.size() > 0) ? (String.valueOf(activityList.get(0).get('IsArchived'))) : 'true');
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }


    /*****************************************************************************************************
    * @Name         :   checkSuggestedTag
    * @Description  :   Method to check Suggested tag Enabled Or not
    * @Param        :   
    *****************************************************************************************************/
    @AuraEnabled
    public static String checkSuggestedTag(){
        String refField = Acuity_Setting__mdt.getInstance('Acuity_Enable_Notes_Suggested_Tag').Value__c;
        return refField.toLowerCase();
    }

    /*****************************************************************************************************
    * @Name         :   saveRtaToggleStatus
    * @Description  :   Method to save the RTA toggle status for the specific user
    * @Param        :   N/A
    *****************************************************************************************************/
    //Added by Sudhanshu on 2024-10-24 for RTA toggle status 47978
    @AuraEnabled
    public static void saveRtaToggleStatus(Boolean rtaToggleStatus){
        try {
            User u = [SELECT Id, navpeII_dev18__Enable_RTA_Toolbar__c FROM User WHERE Id =:UserInfo.getUserId()];
            u.navpeII_dev18__Enable_RTA_Toolbar__c = rtaToggleStatus;
            Database.update(u, true);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    /*****************************************************************************************************
    * @Name         :   checkRtaToggleStatus
    * @Description  :   Method to check if user has enabled the RTA toggle
    * @Param        :   N/A
    *****************************************************************************************************/
    @AuraEnabled
    public static boolean checkRtaToggleStatus(){
        try {
            return [SELECT navpeII_dev18__Enable_RTA_Toolbar__c FROM User WHERE Id =:UserInfo.getUserId()].navpeII_dev18__Enable_RTA_Toolbar__c;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    

    public class NotesWrapper
    {
        @AuraEnabled public id id;

        @AuraEnabled public String isRichText;

        @AuraEnabled public String richDescription;
    }
}