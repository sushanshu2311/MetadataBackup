/****************************************************************************************************

** Module Name : Vlips

** Description : Used to handle all the business logics

** Throws : NA

** Calls : NA

** Organization : Navatar Group

** Product Name & Version : Acuity

** Revision History:-

** Version    Date(YYYY-MM-DD)    Author         Description of Action

** 1.0        2022-08-02          Keyur

****************************************************************************************************/
public with sharing class NavatarClipsCtrl {

    // clips related objects
    Private Static List<String> objectAPIName = new List<String>{ 'Account', 'Contact', 'navpeII_dev18__Pipeline__c', 'navpeII_dev18__Fund__c', 'navpeII_dev18__Fundraising__c', 'navpeII_dev18__Theme__c', 'User'};

    /*****************************************************************************************************
    * @Name         :   getAccessableFields
    * @Description  :   to get the user accessable fields while doing soql
            
    Returns : string of accessable fields
    *****************************************************************************************************/
    Private static string getAccessableFields(){
        List<String> accessableFields = new List<String>();
        if(Schema.sObjectType.Account.isAccessible()){
            accessableFields.add('navpeII_dev18__Account__c');
            accessableFields.add('navpeII_dev18__Account__r.Name');
        }
        if(Schema.sObjectType.Contact.isAccessible()){
            accessableFields.add('navpeII_dev18__Contact__c');
            accessableFields.add('navpeII_dev18__Contact__r.Name');
        }
        if(Schema.sObjectType.navpeII_dev18__Pipeline__c.isAccessible()){
            accessableFields.add('navpeII_dev18__Deal__c');
            accessableFields.add('navpeII_dev18__Deal__r.Name');   
        }
        if(Schema.sObjectType.navpeII_dev18__Fund__c.isAccessible()){
            accessableFields.add('navpeII_dev18__Fund__c');
            accessableFields.add('navpeII_dev18__Fund__r.Name');
        }
        if(Schema.sObjectType.navpeII_dev18__Fundraising__c.isAccessible()){
            accessableFields.add('navpeII_dev18__Fundraising__c');
            accessableFields.add('navpeII_dev18__Fundraising__r.Name');
        }
        if(Schema.sObjectType.User.isAccessible()){
            accessableFields.add('navpeII_dev18__User__c');
            accessableFields.add('navpeII_dev18__User__r.Name');
        }

        return String.join(accessableFields, ',');
    }

    /*****************************************************************************************************
    * @Name         :   saveClipRelations
    * @Description  :   to save the clip relations based on user access
            
    Returns : list of clip relations to insert
    *****************************************************************************************************/
    Private Static void saveClipRelations(List<navpeII_dev18__Clip_Relation__c> clipRelationList){
        
        if(clipRelationList != null && !clipRelationList.isEmpty()){
            List<navpeII_dev18__Clip_Relation__c> accountRelationList = new List<navpeII_dev18__Clip_Relation__c>();
            List<navpeII_dev18__Clip_Relation__c> contactRelationList = new List<navpeII_dev18__Clip_Relation__c>();
            List<navpeII_dev18__Clip_Relation__c> dealRelationList = new List<navpeII_dev18__Clip_Relation__c>();
            List<navpeII_dev18__Clip_Relation__c> fundRelationList = new List<navpeII_dev18__Clip_Relation__c>();
            List<navpeII_dev18__Clip_Relation__c> fundreisingRelationList = new List<navpeII_dev18__Clip_Relation__c>();
            List<navpeII_dev18__Clip_Relation__c> userRelationList = new List<navpeII_dev18__Clip_Relation__c>();

            For(navpeII_dev18__Clip_Relation__c clipRelation : clipRelationList){
                
                if(clipRelation.navpeII_dev18__Account__c != null){
                    navpeII_dev18__Clip_Relation__c accountRelation = new navpeII_dev18__Clip_Relation__c();
                    accountRelation.navpeII_dev18__Clip__c = clipRelation.navpeII_dev18__Clip__c;
                    accountRelation.navpeII_dev18__Account__c = clipRelation.navpeII_dev18__Account__c;
                    accountRelationList.add(accountRelation);
                }
                else if(clipRelation.navpeII_dev18__Contact__c != null){
                    navpeII_dev18__Clip_Relation__c contactRelation = new navpeII_dev18__Clip_Relation__c();
                    contactRelation.navpeII_dev18__Clip__c = clipRelation.navpeII_dev18__Clip__c;
                    contactRelation.navpeII_dev18__Contact__c = clipRelation.navpeII_dev18__Contact__c;
                    contactRelationList.add(contactRelation);
                }
                else if(clipRelation.navpeII_dev18__Deal__c != null){
                    navpeII_dev18__Clip_Relation__c dealRelation = new navpeII_dev18__Clip_Relation__c();
                    dealRelation.navpeII_dev18__Clip__c = clipRelation.navpeII_dev18__Clip__c;
                    dealRelation.navpeII_dev18__Deal__c = clipRelation.navpeII_dev18__Deal__c;
                    dealRelationList.add(dealRelation);
                }
                else if(clipRelation.navpeII_dev18__Fund__c != null){
                    navpeII_dev18__Clip_Relation__c fundRelation = new navpeII_dev18__Clip_Relation__c();
                    fundRelation.navpeII_dev18__Clip__c = clipRelation.navpeII_dev18__Clip__c;
                    fundRelation.navpeII_dev18__Fund__c = clipRelation.navpeII_dev18__Fund__c;
                    fundRelationList.add(fundRelation);
                }
                else if(clipRelation.navpeII_dev18__Fundraising__c != null){
                    navpeII_dev18__Clip_Relation__c fundreisingRelation = new navpeII_dev18__Clip_Relation__c();
                    fundreisingRelation.navpeII_dev18__Clip__c = clipRelation.navpeII_dev18__Clip__c;
                    fundreisingRelation.navpeII_dev18__Fundraising__c = clipRelation.navpeII_dev18__Fundraising__c;
                    fundreisingRelationList.add(fundreisingRelation);
                }
                else if(clipRelation.navpeII_dev18__User__c != null){
                    navpeII_dev18__Clip_Relation__c userRelation = new navpeII_dev18__Clip_Relation__c();
                    userRelation.navpeII_dev18__Clip__c = clipRelation.navpeII_dev18__Clip__c;
                    userRelation.navpeII_dev18__User__c = clipRelation.navpeII_dev18__User__c;
                    userRelationList.add(userRelation);
                }
            }

            If(Schema.sObjectType.navpeII_dev18__Clip_Relation__c.isCreateable() && Schema.sObjectType.navpeII_dev18__Clip_Relation__c.fields.navpeII_dev18__Clip__c.isCreateable() && Schema.sObjectType.navpeII_dev18__Clip_Relation__c.fields.navpeII_dev18__Account__c.isCreateable()){
                Insert accountRelationList;
            }
            If(Schema.sObjectType.navpeII_dev18__Clip_Relation__c.isCreateable() && Schema.sObjectType.navpeII_dev18__Clip_Relation__c.fields.navpeII_dev18__Clip__c.isCreateable() && Schema.sObjectType.navpeII_dev18__Clip_Relation__c.fields.navpeII_dev18__Contact__c.isCreateable()){
                Insert contactRelationList;
            }
            If(Schema.sObjectType.navpeII_dev18__Clip_Relation__c.isCreateable() && Schema.sObjectType.navpeII_dev18__Clip_Relation__c.fields.navpeII_dev18__Clip__c.isCreateable() && Schema.sObjectType.navpeII_dev18__Clip_Relation__c.fields.navpeII_dev18__Deal__c.isCreateable()){
                Insert dealRelationList;
            }
            If(Schema.sObjectType.navpeII_dev18__Clip_Relation__c.isCreateable() && Schema.sObjectType.navpeII_dev18__Clip_Relation__c.fields.navpeII_dev18__Clip__c.isCreateable() && Schema.sObjectType.navpeII_dev18__Clip_Relation__c.fields.navpeII_dev18__Fund__c.isCreateable()){
                Insert fundRelationList;
            }
            If(Schema.sObjectType.navpeII_dev18__Clip_Relation__c.isCreateable() && Schema.sObjectType.navpeII_dev18__Clip_Relation__c.fields.navpeII_dev18__Clip__c.isCreateable() && Schema.sObjectType.navpeII_dev18__Clip_Relation__c.fields.navpeII_dev18__Fundraising__c.isCreateable()){
                Insert fundreisingRelationList;
            }
            If(Schema.sObjectType.navpeII_dev18__Clip_Relation__c.isCreateable() && Schema.sObjectType.navpeII_dev18__Clip_Relation__c.fields.navpeII_dev18__Clip__c.isCreateable() && Schema.sObjectType.navpeII_dev18__Clip_Relation__c.fields.navpeII_dev18__User__c.isCreateable()){
                Insert userRelationList;
            }

        }

    }

    /*****************************************************************************************************
    * @Name         :   getClipData
    * @Description  :   to save the selected suggession records
    Input : clipId - saved clipid.
            
    Returns : clips name and sumary data
    *****************************************************************************************************/
    @AuraEnabled
    public static navpeII_dev18__Clip__c getClipNameAndSummary(String clipId){
        try {
            List<navpeII_dev18__Clip__c> clipList = new List<navpeII_dev18__Clip__c>();
            List<String> accessableFields = new List<String>();
            if (Schema.sObjectType.navpeII_dev18__Clip__c.fields.Name.isAccessible()) {
                accessableFields.add('Name');
            }
            if (Schema.sObjectType.navpeII_dev18__Clip__c.fields.navpeII_dev18__Summary__c.isAccessible()) {
                accessableFields.add('navpeII_dev18__Summary__c');
            }
            clipList = Database.query('SELECT Id, '+String.join(accessableFields, ',')+' FROM  navpeII_dev18__Clip__c WHERE Id =:clipId');
            //clipList = [SELECT Id, Name, navpeII_dev18__Summary__c FROM  navpeII_dev18__Clip__c WHERE Id =:clipId ];
            if(!clipList.isEmpty()){
                return clipList[0];
            }else {
                return null;
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    /*****************************************************************************************************
    * @Name         :   getClipData
    * @Description  :   to save the selected suggession records
    Input : ObjectInfo - clips related objects info.
            clipId - saved clipid.
            
    Returns : clips related data
    *****************************************************************************************************/
    @AuraEnabled
    public static string getClipData(String clipId, string ObjectInfo){
        try {

            // Deserialize the objects info into wrapper .
            list<LookupWrapper> multiWrpCls = (list<LookupWrapper>)JSON.deserialize(ObjectInfo, list<LookupWrapper>.class);

            // Stores object API name vs Object Icon name
            Map<String, String> objectNameVsIcon = new Map<String, String>();

            // SOQL on navpeII_dev18__Clip__c
            List<String> accessableFieldsClip = new List<String>();
            if (Schema.sObjectType.navpeII_dev18__Clip__c.fields.Name.isAccessible()) {
                accessableFieldsClip.add('Name');
            }
            if (Schema.sObjectType.navpeII_dev18__Clip__c.fields.navpeII_dev18__Summary__c.isAccessible()) {
                accessableFieldsClip.add('navpeII_dev18__Summary__c');
            }
            if (Schema.sObjectType.navpeII_dev18__Clip__c.fields.navpeII_dev18__Notes__c.isAccessible()) {
                accessableFieldsClip.add('navpeII_dev18__Notes__c');
            }
            //navpeII_dev18__Clip__c clip = [SELECT Id, Name, navpeII_dev18__Notes__c, navpeII_dev18__Summary__c FROM  navpeII_dev18__Clip__c WHERE Id =:clipId];
            navpeII_dev18__Clip__c clip = Database.query('SELECT Id, '+String.join(accessableFieldsClip, ',')+' FROM  navpeII_dev18__Clip__c WHERE Id =:clipId');
            
            // Stores clip and theme relation records data as a wrapper.
            List<RecordWrapper> taggedRecordList = new List<RecordWrapper>();
            Map<String,List<RecordWrapper>> objVsTaggedRecords = new Map<String,List<RecordWrapper>>();

            For(LookupWrapper wrap : multiWrpCls){
                objectNameVsIcon.put(wrap.objectName, wrap.IconName);
            }

            if (Schema.sObjectType.navpeII_dev18__Theme__c.isAccessible()) {
            // SOQL on Theme relation records and stores them as a wrapper.
                For(navpeII_dev18__Theme_Relation__c themeRelation : [Select navpeII_dev18__Theme__c,navpeII_dev18__Theme__r.Name FROM navpeII_dev18__Theme_Relation__c WHERE navpeII_dev18__Clip__c =:clipId WITH SECURITY_ENFORCED ORDER BY createddate asc limit 50000]){
                    if(themeRelation.navpeII_dev18__Theme__c != null && themeRelation.isSet('navpeII_dev18__Theme__c')){
                    RecordWrapper recWrap = new RecordWrapper();
                        recWrap.Name = themeRelation.navpeII_dev18__Theme__r.Name;
                        recWrap.Id = themeRelation.navpeII_dev18__Theme__c;
                    Id recId = (Id)recWrap.Id;
                    String sObjName = recId.getSObjectType().getDescribe().getName();
                    recWrap.objectName = sObjName;
                    recWrap.iconName = objectNameVsIcon.get(sObjName);

                    list<RecordWrapper> temp = objVsTaggedRecords.get(sObjName);
                    if(temp == null){
                        temp = new list<RecordWrapper>();
                    }
                    temp.add(recWrap);
                    objVsTaggedRecords.put( sObjName, temp);
                    
                    //taggedRecordList.add(recWrap);
                }
            }
            }

            string accessableFields = getAccessableFields();

            List<navpeII_dev18__Clip_Relation__c> clipRelationList = new List<navpeII_dev18__Clip_Relation__c>();
            clipRelationList = Database.query('Select id, ' + accessableFields + ' FROM navpeII_dev18__Clip_Relation__c WHERE navpeII_dev18__Clip__c =:clipId WITH SECURITY_ENFORCED ORDER BY createddate asc limit 50000');
            // SOQL on Clip relation records and stores them as a wrapper.
            For(navpeII_dev18__Clip_Relation__c clipRelation : clipRelationList){
                
                RecordWrapper recWrap = new RecordWrapper();
                
                if(clipRelation.isSet('navpeII_dev18__Account__c') && clipRelation.navpeII_dev18__Account__c != null ){
                    recWrap.Name = clipRelation.navpeII_dev18__Account__r.Name;
                    recWrap.Id = clipRelation.navpeII_dev18__Account__c;
                }
                else if(clipRelation.isSet('navpeII_dev18__Contact__c') && clipRelation.navpeII_dev18__Contact__c != null ){
                    recWrap.Name = clipRelation.navpeII_dev18__Contact__r.Name;
                    recWrap.Id = clipRelation.navpeII_dev18__Contact__c;
                }
                else if(clipRelation.isSet('navpeII_dev18__Deal__c') && clipRelation.navpeII_dev18__Deal__c != null ){
                    recWrap.Name = clipRelation.navpeII_dev18__Deal__r.Name;
                    recWrap.Id = clipRelation.navpeII_dev18__Deal__c;
                }
                else if(clipRelation.isSet('navpeII_dev18__Fund__c') && clipRelation.navpeII_dev18__Fund__c != null ){
                    recWrap.Name = clipRelation.navpeII_dev18__Fund__r.Name;
                    recWrap.Id = clipRelation.navpeII_dev18__Fund__c;
                }
                else if(clipRelation.isSet('navpeII_dev18__Fundraising__c') && clipRelation.navpeII_dev18__Fundraising__c != null ){
                    recWrap.Name = clipRelation.navpeII_dev18__Fundraising__r.Name;
                    recWrap.Id = clipRelation.navpeII_dev18__Fundraising__c;
                }
                else if(clipRelation.isSet('navpeII_dev18__User__c') && clipRelation.navpeII_dev18__User__c != null ){
                    recWrap.Name = clipRelation.navpeII_dev18__User__r.Name;
                    recWrap.Id = clipRelation.navpeII_dev18__User__c;
                }

                if(recWrap.Id != null){
                    Id recId = (Id)recWrap.Id;
                    String sObjName = recId.getSObjectType().getDescribe().getName();
                    recWrap.objectName = sObjName;
                    recWrap.iconName = objectNameVsIcon.get(sObjName);

                    list<RecordWrapper> temp = objVsTaggedRecords.get(sObjName);
                    if(temp == null){
                        temp = new list<RecordWrapper>();
                    }
                    temp.add(recWrap);
                    objVsTaggedRecords.put( sObjName, temp);

                    //taggedRecordList.add(recWrap);
                }
            }

            for(String objName : objectAPIName){
                if(objVsTaggedRecords.get(objName) != null){
                    taggedRecordList.addAll(objVsTaggedRecords.get(objName));
                }
            }

            // Stores all clip data as a wrapper.
            clipWrapper clipWrap = new ClipWrapper();
            if(clip.isSet('name')){
            clipWrap.clipName = clip.name;
            }
            
            if( clip.navpeII_dev18__Notes__c != null &&  clip.navpeII_dev18__Notes__c != '' && clip.isSet('navpeII_dev18__Notes__c')){
                clipWrap.clipNotes = clip.navpeII_dev18__Notes__c; //replaceAll('\n','</br>')
            }else{
                clipWrap.clipNotes = '';
            }
            if(clip.isSet('navpeII_dev18__Summary__c')){
                clipWrap.clipSummary = clip.navpeII_dev18__Summary__c;
            }
            
            clipWrap.clipTaggedRecords = JSON.serialize(taggedRecordList);

            return JSON.serialize(clipWrap);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    // clip data wrapper to store clip information.
    public class clipWrapper{
        @AuraEnabled public string clipName;
        @AuraEnabled public string clipNotes;
        @AuraEnabled public string clipSummary;
        @AuraEnabled public string clipTaggedRecords;
    }

    /*****************************************************************************************************
    * @Name         :   saveSuggestion
    * @Description  :   to save the selected suggession records
    Input : selectedRecords - selected records from suggessions.
            clipId - saved clipid.
            
    Returns : true or false on DML success
    *****************************************************************************************************/
    @AuraEnabled
    public static boolean saveSuggestion(string selectedRecords, string clipId){
        try {

            // Deserialize the selected records into the respacted wrapper list
            list<RecordWrapper> selectedRecordList = (list<RecordWrapper>)JSON.deserialize(selectedRecords, list<RecordWrapper>.class);

            // stores the clip relation records which are going to insert
            List<navpeII_dev18__Clip_Relation__c> clipRelationToInsert = new List<navpeII_dev18__Clip_Relation__c>();
            // stores the theme relation records which are going to insert
            List<navpeII_dev18__Theme_Relation__c> themeRelationToInsert = new List<navpeII_dev18__Theme_Relation__c>();

            //logic to fill the list of clip and theme relation records based on selected records from screen.
            For(RecordWrapper recwrap : selectedRecordList){
                navpeII_dev18__Clip_Relation__c clipRelation = new navpeII_dev18__Clip_Relation__c();
                clipRelation.navpeII_dev18__Clip__c = clipId;

                ID recID = (Id)recWrap.Id.substring(0,15);
                String sObjName = recID.getSObjectType().getDescribe().getName();
                clipRelation.navpeII_dev18__Account__c = sObjName == 'Account' ? recWrap.Id.substring(0,15) : Null;
                clipRelation.navpeII_dev18__Contact__c = sObjName == 'Contact' ? recWrap.Id.substring(0,15) : Null;
                clipRelation.navpeII_dev18__Deal__c = sObjName == 'navpeII_dev18__Pipeline__c' ? recWrap.Id.substring(0,15) : Null;
                clipRelation.navpeII_dev18__Fund__c = sObjName == 'navpeII_dev18__Fund__c' ? recWrap.Id.substring(0,15) : Null;
                clipRelation.navpeII_dev18__Fundraising__c = sObjName == 'navpeII_dev18__Fundraising__c' ? recWrap.Id.substring(0,15) : Null;
                clipRelation.navpeII_dev18__User__c = sObjName == 'User' ? recWrap.Id.substring(0,15) : Null;

                clipRelationToInsert.add(clipRelation);

                // if record id is from theme objects fill into theme record list
                if(sObjName == 'navpeII_dev18__Theme__c'){
                    navpeII_dev18__Theme_Relation__c themeRelation = new navpeII_dev18__Theme_Relation__c();
                    themeRelation.navpeII_dev18__Clip__c = clipId;
                    themeRelation.navpeII_dev18__Theme__c = recWrap.Id.substring(0,15);
                    themeRelationToInsert.add(themeRelation);
                }
            }

            // Insert the theme relation records.
            If(!themeRelationToInsert.isEmpty() ){
                if(Schema.sObjectType.navpeII_dev18__Theme_Relation__c.isCreateable() && Schema.sObjectType.navpeII_dev18__Theme_Relation__c.fields.navpeII_dev18__Clip__c.isCreateable() && Schema.sObjectType.navpeII_dev18__Theme_Relation__c.fields.navpeII_dev18__Theme__c.isCreateable()){
                    Insert themeRelationToInsert;
                }
            }

            // Insert the Clip relation records.
            /*If(Schema.sObjectType.navpeII_dev18__Clip_Relation__c.isCreateable() && Schema.sObjectType.navpeII_dev18__Clip_Relation__c.fields.navpeII_dev18__Clip__c.isCreateable() && Schema.sObjectType.navpeII_dev18__Clip_Relation__c.fields.navpeII_dev18__Account__c.isCreateable() && Schema.sObjectType.navpeII_dev18__Clip_Relation__c.fields.navpeII_dev18__Contact__c.isCreateable() && Schema.sObjectType.navpeII_dev18__Clip_Relation__c.fields.navpeII_dev18__Deal__c.isCreateable() && Schema.sObjectType.navpeII_dev18__Clip_Relation__c.fields.navpeII_dev18__Fund__c.isCreateable() && Schema.sObjectType.navpeII_dev18__Clip_Relation__c.fields.navpeII_dev18__Fundraising__c.isCreateable() && Schema.sObjectType.navpeII_dev18__Clip_Relation__c.fields.navpeII_dev18__User__c.isCreateable()){
                Insert clipRelationToInsert;
            }*/

            if(!clipRelationToInsert.isEmpty()){
                saveClipRelations(clipRelationToInsert);
            }
            return true;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    /*****************************************************************************************************
    * @Name         :   getSuggestion
    * @Description  :   to get the suggession based on frag-drop and copy-paste
    Input : recentRecords - recent record ids from local storage (stores ids when user do drag-drop and copy-paste anything into clip).
            ObjectInfo - clip object info.
            taggedRecord - all tagged record from clip.
            
    Returns : wrapeer of suggession records
    *****************************************************************************************************/
    @AuraEnabled
    public static List<RecordWrapper> getSuggestion(string recentRecords, string ObjectInfo, string taggedRecord){
        try {
            List<RecordWrapper> recordList = new List<RecordWrapper>();

            // check if user have done any copy-paste and drag-drop while creating clip.
            if ( recentRecords != 'null' && recentRecords != null && recentRecords != ''){

                // Split records into the list
                List<String> allRecentRecordsList = recentRecords.split(',');

                //
                list<LookupWrapper> multiWrpCls = (list<LookupWrapper>)JSON.deserialize(ObjectInfo, list<LookupWrapper>.class);
                List<RecordWrapper> allTaggedRecordsList = (List<RecordWrapper>)Json.deserialize(taggedRecord, (List<RecordWrapper>.class));
                List<String> taggedRecordIds = new List<String>();
                For(RecordWrapper recWrap : allTaggedRecordsList){
                    taggedRecordIds.add(recWrap.Id.substring(0,15));
                }

                
                Map<String, Set<String>> objNameVsIdListMap = new Map<String, Set<String>>();
                For(String recID : allRecentRecordsList){
                    if(recID != '' && recID != null && recID != 'null'){
                        String sObjName = ((Id)recID).getSObjectType().getDescribe().getName();
                        Set<String> tempSet = objNameVsIdListMap.get(sObjName);
                        if(tempSet == null){
                            tempSet = new Set<String>();
                        }
                        tempSet.add(recID);
                        objNameVsIdListMap.put(sObjName, tempSet);
                    }
                }
                
                For(LookupWrapper obj : multiWrpCls){
                    if(objNameVsIdListMap.get(obj.objectName) != null){
                        set<String> recIdSet = objNameVsIdListMap.get(obj.objectName);
                        String qry = 'SELECT Id, Name FROM ' +obj.objectName+ ' WHERE id in: recIdSet';
                        List<SObject> sobjList = Database.query(string.escapesinglequotes(qry));

                        For(SObject sobj : sobjList){
                            if(!taggedRecordIds.contains(((String)sObj.get('Id')).substring(0,15) )){
                                RecordWrapper recWrap = new RecordWrapper();
                                recWrap.Name = (String)sObj.get('Name');
                                recWrap.Id = (String)sObj.get('Id');
                                
                                recWrap.objectName = obj.objectLabel;
                                recWrap.iconName = obj.IconName;
                                recordList.add(recWrap);
                            }
                        }
                    }
                    
                }
            }
            return recordList;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    /*****************************************************************************************************
    * @Name         :   saveClip
    * @Description  :   to save the clip
    Input : taggedRecord - all tagged record from clip.
            note - user input notes.
            name - user input clip name
            summary - user input clip summery.
            clipId - clip id if user clik on edit
            
    Returns : clip id
    *****************************************************************************************************/
    @AuraEnabled
    public static string saveClip(string taggedRecord, string note, string name, string summary, string clipId){
        try {

            List<RecordWrapper> allTaggedRecordsList = (List<RecordWrapper>)Json.deserialize(taggedRecord, (List<RecordWrapper>.class));

            

            navpeII_dev18__Clip__c clip = new navpeII_dev18__Clip__c();
            
          
            if(clipId != null && clipId != '' && clipId != 'undefined' ){
                
                clip.Id =clipId;
            }
            
            clip.Name = name;
            clip.navpeII_dev18__Notes__c = note;
            clip.navpeII_dev18__Summary__c = summary;

            If(Schema.sObjectType.navpeII_dev18__Clip__c.isCreateable() && Schema.sObjectType.navpeII_dev18__Clip__c.isUpdateable() &&  Schema.sObjectType.navpeII_dev18__Clip__c.fields.Id.isAccessible() && Schema.sObjectType.navpeII_dev18__Clip__c.fields.Name.isCreateable() && Schema.sObjectType.navpeII_dev18__Clip__c.fields.Name.isUpdateable() && Schema.sObjectType.navpeII_dev18__Clip__c.fields.navpeII_dev18__Notes__c.isCreateable() && Schema.sObjectType.navpeII_dev18__Clip__c.fields.navpeII_dev18__Notes__c.isUpdateable() && Schema.sObjectType.navpeII_dev18__Clip__c.fields.navpeII_dev18__Summary__c.isCreateable() && Schema.sObjectType.navpeII_dev18__Clip__c.fields.navpeII_dev18__Summary__c.isUpdateable()){
                Database.UpsertResult sr = Database.Upsert(clip, false);

                if(sr.isSuccess()){

                    List<navpeII_dev18__Clip_Relation__c> clipRelationToInsert = new List<navpeII_dev18__Clip_Relation__c>();
                    List<navpeII_dev18__Theme_Relation__c> themeRelationToInsert = new List<navpeII_dev18__Theme_Relation__c>();
    
                    Map<String, navpeII_dev18__Clip_Relation__c> savedClipRelationIdMap = new Map<String, navpeII_dev18__Clip_Relation__c>();
                    Map<String, navpeII_dev18__Theme_Relation__c> savedThemeRelationIdMap = new Map<String, navpeII_dev18__Theme_Relation__c>();
                    set<string> savedClipRelationSet = new set<string>();
    
                    if(clipId != '' && clipId != null){
                        if (Schema.sObjectType.navpeII_dev18__Theme__c.isAccessible()) {
                            For(navpeII_dev18__Theme_Relation__c themeRelation : [Select navpeII_dev18__Theme__c FROM navpeII_dev18__Theme_Relation__c WHERE navpeII_dev18__Clip__c =:clipId WITH SECURITY_ENFORCED limit 50000]){
                                if(themeRelation.isSet('navpeII_dev18__Theme__c')){
                                    savedThemeRelationIdMap.put(themeRelation.navpeII_dev18__Theme__c, themeRelation);
                                    savedClipRelationSet.add(themeRelation.navpeII_dev18__Theme__c);
                                }
                        }
                        }
                        
                        string accessableFields = getAccessableFields();
                        
                        List<navpeII_dev18__Clip_Relation__c> clipRelationList = new List<navpeII_dev18__Clip_Relation__c>();
                        clipRelationList = Database.query('Select id, ' + accessableFields + ' FROM navpeII_dev18__Clip_Relation__c WHERE navpeII_dev18__Clip__c =:clipId WITH SECURITY_ENFORCED limit 50000');

                        For(navpeII_dev18__Clip_Relation__c clipRelation : clipRelationList){
                            if(clipRelation.isSet('navpeII_dev18__Account__c')){
                                savedClipRelationIdMap.put(clipRelation.navpeII_dev18__Account__c, clipRelation);
                            }
                            if(clipRelation.isSet('navpeII_dev18__Contact__c')){
                                savedClipRelationIdMap.put(clipRelation.navpeII_dev18__Contact__c, clipRelation);
                            }
                            if(clipRelation.isSet('navpeII_dev18__Deal__c')){
                                savedClipRelationIdMap.put(clipRelation.navpeII_dev18__Deal__c, clipRelation);
                            }
                            if(clipRelation.isSet('navpeII_dev18__Fund__c')){
                                savedClipRelationIdMap.put(clipRelation.navpeII_dev18__Fund__c, clipRelation);
                            }
                            if(clipRelation.isSet('navpeII_dev18__Fundraising__c')){
                                savedClipRelationIdMap.put(clipRelation.navpeII_dev18__Fundraising__c, clipRelation);
                            }
                            if(clipRelation.isSet('navpeII_dev18__User__c')){
                                savedClipRelationIdMap.put(clipRelation.navpeII_dev18__User__c, clipRelation);
                            } 
                        }
    
                        savedClipRelationSet.addAll(savedClipRelationIdMap.keySet());
                        // remove blanks and nulls
                        savedClipRelationSet.remove('');
                        savedClipRelationSet.remove(null);
                    }
    
    
                    List<String> taggedRecordIds = new List<String>();
                    For(RecordWrapper recWrap : allTaggedRecordsList){
                        taggedRecordIds.add(recWrap.Id);
    
                        if(!savedClipRelationSet.contains(recWrap.Id)){
                            navpeII_dev18__Clip_Relation__c clipRelation = new navpeII_dev18__Clip_Relation__c();
                            clipRelation.navpeII_dev18__Clip__c = sr.getId();
    
                            ID recID = (Id)recWrap.Id.substring(0,15);
                            String sObjName = recID.getSObjectType().getDescribe().getName();
                            clipRelation.navpeII_dev18__Account__c = sObjName == 'Account' ? recWrap.Id.substring(0,15) : Null;
                            clipRelation.navpeII_dev18__Contact__c = sObjName == 'Contact' ? recWrap.Id.substring(0,15) : Null;
                            clipRelation.navpeII_dev18__Deal__c = sObjName == 'navpeII_dev18__Pipeline__c' ? recWrap.Id.substring(0,15) : Null;
                            clipRelation.navpeII_dev18__Fund__c = sObjName == 'navpeII_dev18__Fund__c' ? recWrap.Id.substring(0,15) : Null;
                            clipRelation.navpeII_dev18__Fundraising__c = sObjName == 'navpeII_dev18__Fundraising__c' ? recWrap.Id.substring(0,15) : Null;
                            //clipRelation.navpeII_dev18__Theme__c = sObjName == 'navpeII_dev18__Theme__c' ? recWrap.Id.substring(0,15) : Null;
                            clipRelation.navpeII_dev18__User__c = sObjName == 'User' ? recWrap.Id.substring(0,15) : Null;
    
                            if(sObjName != 'navpeII_dev18__Theme__c'){
                                clipRelationToInsert.add(clipRelation);
                            }
                            
                            if(sObjName == 'navpeII_dev18__Theme__c'){
                                navpeII_dev18__Theme_Relation__c themeRelation = new navpeII_dev18__Theme_Relation__c();
                                themeRelation.navpeII_dev18__Clip__c = sr.getId();
                                themeRelation.navpeII_dev18__Theme__c = recWrap.Id.substring(0,15);
                                
                                themeRelationToInsert.add(themeRelation);
                            }
    
                        }
                    }
    
                    List<navpeII_dev18__Clip_Relation__c> clipRelationToDelete = new List<navpeII_dev18__Clip_Relation__c>();
                    List<navpeII_dev18__Theme_Relation__c> themeRelationToDelete = new List<navpeII_dev18__Theme_Relation__c>();
                    For(String savedRelatonId : savedClipRelationSet){
                        if(!taggedRecordIds.contains(savedRelatonId) && savedClipRelationIdMap.get(savedRelatonId) != null){
                            clipRelationToDelete.add(savedClipRelationIdMap.get(savedRelatonId));
                        }
                        if(!taggedRecordIds.contains(savedRelatonId) && savedThemeRelationIdMap.get(savedRelatonId) != null){
                            themeRelationToDelete.add(savedThemeRelationIdMap.get(savedRelatonId));
                        }
                    }
    
                    If(!clipRelationToDelete.isEmpty() && Schema.sObjectType.navpeII_dev18__Clip_Relation__c.isAccessible() && Schema.sObjectType.navpeII_dev18__Clip_Relation__c.isDeletable()){
                            Delete clipRelationToDelete;
                        }
                    If(!themeRelationToDelete.isEmpty()  && Schema.sObjectType.navpeII_dev18__Theme_Relation__c.isAccessible() && Schema.sObjectType.navpeII_dev18__Theme_Relation__c.isDeletable()){
                            Delete themeRelationToDelete;
                        }
    
                    
                    If(!clipRelationToInsert.isEmpty()){
                        /*if(Schema.sObjectType.navpeII_dev18__Clip_Relation__c.isCreateable() && Schema.sObjectType.navpeII_dev18__Clip_Relation__c.fields.navpeII_dev18__Clip__c.isCreateable() && Schema.sObjectType.navpeII_dev18__Clip_Relation__c.fields.navpeII_dev18__Account__c.isCreateable() && Schema.sObjectType.navpeII_dev18__Clip_Relation__c.fields.navpeII_dev18__Contact__c.isCreateable() && Schema.sObjectType.navpeII_dev18__Clip_Relation__c.fields.navpeII_dev18__Deal__c.isCreateable() && Schema.sObjectType.navpeII_dev18__Clip_Relation__c.fields.navpeII_dev18__Fund__c.isCreateable() && Schema.sObjectType.navpeII_dev18__Clip_Relation__c.fields.navpeII_dev18__Fundraising__c.isCreateable() && Schema.sObjectType.navpeII_dev18__Clip_Relation__c.fields.navpeII_dev18__User__c.isCreateable()){
                            Insert clipRelationToInsert;
                        }*/
                        saveClipRelations(clipRelationToInsert);
                    }
                    If(!themeRelationToInsert.isEmpty()){
                        if(Schema.sObjectType.navpeII_dev18__Theme_Relation__c.isCreateable() && Schema.sObjectType.navpeII_dev18__Theme_Relation__c.fields.navpeII_dev18__Clip__c.isCreateable() && Schema.sObjectType.navpeII_dev18__Theme_Relation__c.fields.navpeII_dev18__Theme__c.isCreateable()){
                            Insert themeRelationToInsert;
                        }
                        
                    }
                    return sr.getId();
                }else{
                    Database.Error[] err = sr.getErrors();
                    return 'Error: '+err[0].getMessage();
                }
            }else{
                return 'Error: User does not have access to clip object' ;
            }
            
        } catch (Exception e) {
            return 'Error: '+e.getMessage();
        }
    }


    /*****************************************************************************************************
    * @Name         :   getClipsRelatedObjectInfo
    * @Description  :   to get information about ojects related to clips
    *****************************************************************************************************/
    @AuraEnabled
    public static string getClipsRelatedObjectInfo(){
        try {
            list<LookupWrapper> multiWrpCls = new list<LookupWrapper>();
            
            //objectAPIName.sort();

            for(string objName: objectAPIName){

                Boolean isCreateable = Schema.getGlobalDescribe().get(objName).getDescribe().isCreateable();
                String objLabel = Schema.getGlobalDescribe().get(objName).getDescribe().getLabel();
                    
                LookupWrapper multiLW = new LookupWrapper();
                multiLW.objectName = objName;
                multiLW.objectLabel = objLabel;
                multiLW.isCreateableAccess = isCreateable;
                multiWrpCls.add(multiLW);

            }

            List<JsonResponse> layoutInfo = (list<JsonResponse>)System.JSON.deserialize(fetchEndpointResponse('/services/data/v55.0/tabs'), List<JsonResponse>.class);
            for(LookupWrapper lookupWrap : multiWrpCls){
                for(JsonResponse tab : layoutInfo){
                    if(lookupWrap.objectName == 'navpeII_dev18__Theme__c'){
                        for(Icons icon : tab.icons){
                            if(icon.height == 0 && icon.theme == 'theme4' && tab.label.equalsIgnoreCase('Themes')){
                                lookupWrap.IconName = icon.url.split('/')[6] + ':' + (icon.url.split('/')[7]).split('\\.')[0];
                                break;
                            }
                        }
                    }
                    if(tab.sobjectName.equalsIgnoreCase(lookupWrap.objectName) || tab.label.equalsIgnoreCase(lookupWrap.objectName)){
                        for(Icons icon : tab.icons){
                            if(icon.height == 0 && icon.theme == 'theme4'){
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
            return JSON.serialize(multiWrpCls);

        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

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

    /*****************************************************************************************************
    * @Name         :   getCurrentUserInfo
    * @Description  :   to get current user info
    *****************************************************************************************************/
    @AuraEnabled
    public static RecordWrapper getCurrentUserInfo(){
        try {
            RecordWrapper usrRecWrap = new RecordWrapper();
            usrRecWrap.Name = Userinfo.getName();
            usrRecWrap.Id = Userinfo.getUserId();
            usrRecWrap.objectName = 'User';
            usrRecWrap.iconName = 'standard:user';
            usrRecWrap.isUser = true;

            return usrRecWrap;

        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    // to store setup object info
    public class LookupWrapper{
        @AuraEnabled public String pluralLabel;
        @AuraEnabled public String objectName;  
        @AuraEnabled public String IconName; 
        @AuraEnabled public String objectLabel; 
        @AuraEnabled public boolean isCreateableAccess;
    }

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

    // to store record info
    public class RecordWrapper{
        @AuraEnabled public string Name;
        @AuraEnabled public string Id;
        @AuraEnabled public string iconName;
        @AuraEnabled public string objectName;
        @AuraEnabled public boolean isUser;
    }
}