/****************************************************************************************************

** Module Name : Acuity 2.0 - Acuity
** Description : Used to handle All Themes Page &  Add to Theme button logic
** Throws : NA
** Calls : NA
** Organization : Navatar Group
** Product Name & Version : Acuity 1.0
** Revision History:-
** Version    Date(YYYY-MM-DD)    Author         Description of Action
** 1.0        2022-11-14          Hema
** 2.0        2024-02-22          Manonit        Enhanced add to theme Functionality 
****************************************************************************************************/
public with sharing class NavatarAllThemesCtrl
 {
    public static  Map<Id,String>  activitiesMap = new Map<Id,String>();
    public static List<Task> completeTaskList = new List<Task>();
    public static List<Event> completeEventList = new List<Event>();
   
     /*
     * Purpose : Fetches initial data to be used for further processing
     * Input : metadataField1    
     *         metadataField2    
     * 		   metadataField3   
     *         objName           [Object to query data from]
     *         whereClause       [Where clause to be used in the SOQL query]
     *         recordList        [Record List]
     * Returns : Initial data to be used for further processing as a List<sObject>
     */
    public static List<sObject> fetchSObjectData(String metadataField1, String metadataField2, String metadataField3, String metadataField4, String metadataField5, String metadataField6, String queryString, String objName, String whereClause, List<String> recordIdList, String orderByClause){
       try {
            String fieldStr = metadataField1; 
            if(String.isNotBlank(metadataField1)){
                fieldStr = ', FORMAT(' + metadataField1 + ')';
            }
            if(String.isNotBlank(metadataField1) && String.isNotBlank(metadataField2)){
                fieldStr += ', FORMAT(' + metadataField2 + ')';
            }
            if(String.isNotBlank(metadataField1) && String.isNotBlank(metadataField2) && String.isNotBlank(metadataField3)){
                fieldStr += ',' + metadataField3 ;
            }
            if(String.isNotBlank(metadataField4) && String.isNotBlank(metadataField1) && String.isNotBlank(metadataField2) && String.isNotBlank(metadataField3)){
            	fieldStr += ', FORMAT(' + metadataField4 + ')';    
            }
            if(String.isNotBlank(metadataField5) && String.isNotBlank(metadataField4) && String.isNotBlank(metadataField1) && String.isNotBlank(metadataField2) && String.isNotBlank(metadataField3)){
            	fieldStr += ', FORMAT(' + metadataField5 + ')';    
            }
            if((String.isNotBlank(metadataField1) || String.isNotBlank(metadataField2) || String.isNotBlank(metadataField3)) && String.isNotBlank(queryString)){
            	fieldStr += ', '+ queryString;
            }
           System.debug('####SELECT Id' + (String.isBlank(fieldStr) ? '' : fieldStr) + ' FROM ' + objName  + whereClause + orderByClause);
            if(whereClause != ''){
                 return new List<sObject>(Database.query('SELECT Id' + (String.isBlank(fieldStr) ? '' : fieldStr) + ' FROM ' + objName + whereClause + orderByClause));
            }
            else{
              return new List<sObject>(Database.query('SELECT Id' + (String.isBlank(fieldStr) ? '' : fieldStr) + ' FROM ' + objName + orderByClause));   
            }
        } catch (Exception e) {
            throw new AuraHandledException('Error Occured While Loading Component : <<' + e.getStackTraceString() + '>>');
        }  
    }

     
    /*
* Purpose : get all the themes data
* Input : themeIdList     [id of the Themes which to be displayed]     
* Returns : Data displayed on table returns as AllThemePageWrapper
*/
    @AuraEnabled public static List<AllThemePageWrapper> getAllThemes(List<String> themeIdList){
        try{
            List<AllThemePageWrapper> allthemePageWrapperList = new List<AllThemePageWrapper>();
             if(schema.sobjecttype.Theme__c.isaccessible()){
            AllThemePageWrapper allThemePageWrapper = new AllThemePageWrapper(); 
            String themeField1 = Acuity_Setting__mdt.getInstance('Acuity_Theme_Field2').Value__c;
            String themeField2 = Acuity_Setting__mdt.getInstance('Acuity_Theme_Field3').Value__c;
            String themeField3 = Acuity_Setting__mdt.getInstance('Acuity_Theme_Field4').Value__c;
            String themeField4 = Acuity_Setting__mdt.getInstance('Acuity_Theme_Field5').Value__c;
          List<Sobject> sobjList = new List<Sobject>();
           if(themeIdList.size()>0 && themeIdList != Null){  
               List<String> recordIdList = themeIdList;
               sobjList = fetchSObjectData(themeField1,themeField2,themeField3,themeField4,'','','(SELECT Id,Member__r.Name FROM Theme_Teams__r)','Theme__c',' WHERE ID IN: recordIdList ',recordIdList,' ORDER BY CreatedDate DESC LIMIT 49990'); 
           }
            else{
            sobjList= fetchSObjectData(themeField1,themeField2,themeField3,themeField4,'','','(SELECT Id,Member__r.Name FROM Theme_Teams__r)','Theme__c','',themeIdList,' ORDER BY CreatedDate DESC LIMIT 49990'); 
            }
       
            for(sObject themeRec :sobjList){
                List<String> themeRelUsers = new List<String>();
                AllThemePageWrapper  tempThemeRecord =  allThemePageWrapper.clone();
                tempThemeRecord.Name= String.valueOf(themeRec.get(themeField1));
                tempThemeRecord.Id= String.valueOf(themeRec.get('Id'));
                tempThemeRecord.Description   = checkCreateableFields( Schema.sObjectType.Theme__c.getsObjectType(), new List<String>{themeField2}) ? String.valueOf(themeRec.get(themeField2)) : '';
                tempThemeRecord.CreatedBy = (String)themeRec.getSobject('CreatedBy').get('Name');
                Datetime themeValue = Datetime.valueOf(themeRec.get(themeField3));
                Date themeDate = date.newinstance(themeValue.year(), themeValue.month(), themeValue.day());
                tempThemeRecord.CreatedDate = String.valueOf(themeDate.format());
                tempThemeRecord.recordReference =  '/' + String.valueOf(themeRec.get('Id'));
                
                 if(schema.sobjecttype.Theme_Team__c.isaccessible()){
                if(themeRec.getSObjects('Theme_Teams__r') != null && themeRec.getSObjects('Theme_Teams__r').size()>0){
                    for(Theme_Team__c themeRelRec :themeRec.getSObjects('Theme_Teams__r')){
                        if(themeRelRec != null){
						 if(Schema.sObjectType.Theme_Team__c.Fields.Member__c.isAccessible()){ //  Added by Hema - W.R.T Secuity Fix 
                            themeRelUsers.add(themeRelRec.Member__r.Name);
							}
                        }
                    }
                }
             }       
                tempThemeRecord.ThemeRelationUser = themeRelUsers;
                allthemePageWrapperList.add(tempThemeRecord);
        }
        
            if(allthemePageWrapperList.size()>0){
                return allthemePageWrapperList;
            }
          }      
            return allthemePageWrapperList;
        }
        catch(Exception e) {
            throw new AuraHandledException('Error Occured While Loading Component : <<' + e.getStackTraceString() + '>>');
        }
    }
    
    /*
* Purpose : get all the themes data based on the search term
* Input : searchTerm     [themes fetched based on the search term]     
* Returns : Data displayed on table returns as AllThemePageWrapper
*/
    
    @AuraEnabled(cacheable=true) public static List<AllThemePageWrapper> getSearchedThemes(String searchTerm){
        try{
            Set<String> themeIdSet = new Set<String>();
			 List<AllThemePageWrapper> allthemePageWrapperList = new List<AllThemePageWrapper>();	
            String themeField2 = Acuity_Setting__mdt.getInstance('Acuity_Theme_Field3').Value__c;
            if(schema.sobjecttype.Theme__c.isaccessible()){
           // searchTerm = searchTerm.replaceAll('[^a-zA-Z0-9\\s+]', '');
            String searchQuery = 'FIND '+'\'*"'+String.escapeSingleQuotes(searchTerm)+'"*\'' +' IN ALL FIELDS RETURNING  navpeII_dev18__Theme__c (Id,Name';
            String searchQuery1 = 'FIND '+'\'*"'+ String.escapeSingleQuotes(searchTerm) + '*"\'' +' IN ALL FIELDS RETURNING navpeII_dev18__Theme__c (Id,Name';
			 //  Added by Hema - W.R.T Secuity Fix 	
                 if(checkCreateableFields( Schema.sObjectType.Theme__c.getsObjectType(), new List<String>{themeField2})){	
                       searchQuery +=   ','+themeField2;	
                       searchQuery1 +=   ','+themeField2; 	
                 }	
                       searchQuery +=   ')';	
                       searchQuery1 +=   ')';   	
              //  Added by Hema - W.R.T Secuity Fix

            List<Theme__c> themeList = new List<Theme__c>();
            if(Schema.sObjectType.Theme__c.isAccessible()){
                Search.SearchResults searchResultsTheme = Search.find(searchQuery,AccessLevel.USER_MODE);
                Search.SearchResults searchResultsTheme1 = Search.find(searchQuery1,AccessLevel.USER_MODE); 
                
                List<Search.SearchResult> searchResultThemelist=new List<Search.SearchResult>();
                searchResultThemelist= searchResultsTheme.get('navpeII_dev18__Theme__c');
                searchResultThemelist = searchResultsTheme1.get('navpeII_dev18__Theme__c');

                
                for(Search.SearchResult sr:searchResultThemelist){
                    navpeII_dev18__Theme__c themeRec = (navpeII_dev18__Theme__c) sr.getSObject();
                    themeList.add(themeRec);
                    themeIdSet.add(string.ValueOf(themeRec.Id));
                }
            }
          } 
            Map<String,String> themeRelMap = new Map<String,String>();
            if(schema.sobjecttype.Theme_Relation__c.isaccessible()){
            List<navpeII_dev18__Theme_Relation__c> themeRelationList = [Select Id,navpeII_dev18__Other_Theme__r.Name,navpeII_dev18__Account__r.Name,navpeII_dev18__Contact__r.Name,navpeII_dev18__Fund__r.Name,navpeII_dev18__Fundraising__r.Name,navpeII_dev18__Deal__r.Name,navpeII_dev18__Theme__r.Id,navpeII_dev18__Theme__r.Name,navpeII_dev18__Clip__r.Name from  navpeII_dev18__Theme_Relation__c Where navpeII_dev18__Theme__c != Null LIMIT 49990];
            for(navpeII_dev18__Theme_Relation__c themeRel : themeRelationList){
			
			 //Added by Hema W.R.T Security Fix	
                themeRelMap.put(themeRel.navpeII_dev18__Theme__r.Id+'-'+themeRel.Id, 	
                     ((schema.sobjecttype.Theme_Relation__c.Fields.Other_Theme__c.isaccessible())? themeRel.navpeII_dev18__Other_Theme__r.Name : '') +','+( (schema.sobjecttype.Theme_Relation__c.Fields.Account__c.isaccessible())? themeRel.navpeII_dev18__Account__r.Name: '') +','+ ((schema.sobjecttype.Theme_Relation__c.Fields.Contact__c.isaccessible())? themeRel.navpeII_dev18__Contact__r.Name: '')+','+( (schema.sobjecttype.Theme_Relation__c.Fields.Fund__c.isaccessible())? themeRel.navpeII_dev18__Fund__r.Name: '') +','+ ((schema.sobjecttype.Theme_Relation__c.Fields.Fundraising__c.isaccessible())? themeRel.navpeII_dev18__Fundraising__r.Name :'') +','+( (schema.sobjecttype.Theme_Relation__c.Fields.Deal__c.isaccessible())? themeRel.navpeII_dev18__Deal__r.Name: '')+','+( (schema.sobjecttype.Theme_Relation__c.Fields.Clip__c.isaccessible())? themeRel.navpeII_dev18__Clip__r.Name : '') );
            }
           } 
            
            if(schema.sobjecttype.Theme_team__c.isaccessible()){
            List<navpeII_dev18__Theme_team__c> themeTeamList = [Select Id,navpeII_dev18__Member__r.Name,navpeII_dev18__Theme__r.Id,navpeII_dev18__Theme__r.Name from navpeII_dev18__Theme_team__c Where navpeII_dev18__Theme__c != Null LIMIT 49990];
            for(navpeII_dev18__Theme_team__c themeUser : themeTeamList){
                if(themeUser != Null && themeRelMap.containsKey(themeUser.navpeII_dev18__Theme__r.Id)){
                    String userRec = themeRelMap.get(themeUser.navpeII_dev18__Theme__r.Id);
					 //Added by Hema W.R.T Security Fix
                    userRec += ','+ (schema.sobjecttype.Theme_team__c.Fields.Member__c.isaccessible()?themeUser.navpeII_dev18__Member__r.Name:'');
                    themeRelMap.put(themeUser.navpeII_dev18__Theme__r.Id+'-'+themeUser.Id,userRec);
                }
                else{
				//Added by Hema W.R.T Security Fix
                    themeRelMap.put(themeUser.navpeII_dev18__Theme__r.Id+'-'+themeUser.Id, (schema.sobjecttype.Theme_Team__c.Fields.Member__c.isaccessible())? themeUser.navpeII_dev18__Member__r.Name :'' );
                }
                
            }
          }      
            for(String themeId : themeRelMap.keySet() ){
                if(themeId != Null && themeRelMap.get(themeId).containsIgnoreCase(searchTerm)){
                    themeIdSet.add(themeId.split('-')[0]);
                }
            }   
            List<String> themeIdList = new List<String>();
            themeIdList.addAll(themeIdSet);
            if( themeIdList.size()>0){
                allthemePageWrapperList = getAllThemes(themeIdList);
            } 
            return allthemePageWrapperList;
        } catch(Exception e) {
            throw new AuraHandledException('Error Occured While Loading Component : <<' + e.getStackTraceString() + '>>');
        }
    }
    
    /*
* Purpose :  Wrapper Class to load the themes data
*/
    
    public class AllThemePageWrapper{
        @AuraEnabled  public string Id  ;
        @AuraEnabled  public string Name ;
        @AuraEnabled public String recordReference;
        @AuraEnabled  public string Description ;
        @AuraEnabled  public string CreatedBy ;
        @AuraEnabled  public String CreatedDate ;
        @AuraEnabled  public List<String> ThemeRelationUser ;
    }
    
    
    /*
* Purpose : Wrapper class to fetch the Interactions
*/
    
    public class ActivitiesWrapper{
        @AuraEnabled  public Boolean isInserted {get;set;}
        @AuraEnabled  public List<String> activityList  {get;set;}
        @AuraEnabled  public String themeRecName {get;set;}
    }     
    
    /*
* Purpose : Clone  the Theme Relation records based on the existing theme
* Input : existingThemeId      [Id of the Existing Theme] 
*       :  newThemeId     [Id of the new theme record]
*       : isInteraction   [check to clone interactions or not ]
* Returns : Data displayed on table returns as ActivitiesWrapper
*/
    
    @AuraEnabled  public static ActivitiesWrapper saveThemeRecord(String existingThemeId , String newThemeId ,  String themeName , String themeDescription , Boolean isDetailPage, Boolean isInteraction ){
        try{
        string sobjName ='navpeII_dev18__Theme__c';
        List<String> activityNameList = new List<String>();
        Boolean isInserted = false;
        If(existingThemeId != Null && existingThemeId != ''){
            List<navpeII_dev18__Theme_Relation__c> insertThemeRelList = new List<navpeII_dev18__Theme_Relation__c>();
            List<navpeII_dev18__Theme_Relation__c> allThemeRelations = [SELECT Id,navpeII_dev18__Contact__c,navpeII_dev18__Account__c,navpeII_dev18__Fund__c,navpeII_dev18__Fundraising__c,navpeII_dev18__Deal__c,navpeII_dev18__Clip__c,navpeII_dev18__Other_Theme__c FROM  navpeII_dev18__Theme_Relation__c WHERE navpeII_dev18__Theme__c =: existingThemeId];
            navpeII_dev18__Theme_Relation__c newThemeRel = new navpeII_dev18__Theme_Relation__c();
            
            for(navpeII_dev18__Theme_Relation__c themeRel : allThemeRelations){
                navpeII_dev18__Theme_Relation__c tempRec = newThemeRel.clone();
                
                Boolean isCreated = checkCreateableFields( Schema.sObjectType.navpeII_dev18__Theme_Relation__c.getsObjectType(), new List<String>{'navpeII_dev18__Contact__c','navpeII_dev18__Account__c','navpeII_dev18__Fund__c','navpeII_dev18__Fundraising__c','navpeII_dev18__Deal__c','navpeII_dev18__Clip__c','navpeII_dev18__Theme__c','navpeII_dev18__Other_Theme__c'});
                if(isCreated){
                    tempRec.navpeII_dev18__Contact__c = (Schema.sobjecttype.Theme_Relation__c.Fields.Contact__c.isaccessible()) ? themeRel.navpeII_dev18__Contact__c :'';
                    tempRec.navpeII_dev18__Account__c= (Schema.sobjecttype.Theme_Relation__c.Fields.Account__c.isaccessible()) ? themeRel.navpeII_dev18__Account__c :'';
                    tempRec.navpeII_dev18__Fund__c= (Schema.sobjecttype.Theme_Relation__c.Fields.Fund__c.isaccessible()) ? themeRel.navpeII_dev18__Fund__c :'';
                    tempRec.navpeII_dev18__Fundraising__c= (Schema.sobjecttype.Theme_Relation__c.Fields.Fundraising__c.isaccessible()) ? themeRel.navpeII_dev18__Fundraising__c :'';
                    tempRec.navpeII_dev18__Deal__c= (Schema.sobjecttype.Theme_Relation__c.Fields.Deal__c.isaccessible()) ? themeRel.navpeII_dev18__Deal__c :'';
                    tempRec.navpeII_dev18__Clip__c = (Schema.sobjecttype.Theme_Relation__c.Fields.Clip__c.isaccessible()) ? themeRel.navpeII_dev18__Clip__c:'';
                    if(!isDetailPage){
                        tempRec.navpeII_dev18__Theme__c = newThemeId;
                    }
                    tempRec.navpeII_dev18__Other_Theme__c = (Schema.sobjecttype.Theme_Relation__c.Fields.Other_Theme__c.isaccessible()) ? themeRel.navpeII_dev18__Other_Theme__c : '';
                    insertThemeRelList.add(tempRec);
                } 
            }
            
            if(isInteraction){
                ResponseWrapper responseWrap = new ResponseWrapper();
                //need to replace the method with Interactions logic method (Dev : Anshika)
                responseWrap = handleOnLoadInfo(existingThemeId,sobjName,newThemeId);
                if((responseWrap.taskRecordsList != NULL && !responseWrap.taskRecordsList.isEmpty()) || (responseWrap.eventRecordsList != NULL && !responseWrap.eventRecordsList.isEmpty())){
                    activityNameList = linkInteractionsToSelectedTheme(responseWrap.taskRecordsList,responseWrap.eventRecordsList,newThemeId);
                }
            }
            if(insertThemeRelList.size()>0 && Schema.sObjectType.Theme_Relation__c.isCreateable()){
                Insert insertThemeRelList; 
                isInserted = true;
            }            
        }
        String themeRecName = [SELECT Id,Name FROM navpeII_dev18__Theme__c WHERE Id =: newThemeId].Name;    
        ActivitiesWrapper actWrapper =  new ActivitiesWrapper();
        actWrapper.activityList= activityNameList;
        actWrapper.isInserted =  isInserted;
        actWrapper.themeRecName = themeRecName;
        return actWrapper;
        }
        catch(Exception e) {
           throw new AuraHandledException('Error Occured While Loading Component : <<' + e.getStackTraceString() + '>>');
        }
    } 
    
    /*
    * Phase 3 -
    * Purpose : For displaying the related objects label as an checkboxes on click of AddToTheme
    * Input : taskList      [task records from the selected record where add to theme is clicked]
            : eventList     [event records from the selected record where add to theme is clicked]
            : themeId       [themeId is record to be linked to interactions]     
    * Returns : activity list consisting of tasks, events which are updated
    */
    public static list<String> linkInteractionsToSelectedTheme(List<Task> taskList,List<Event> eventList,String themeId){
        List<String> activityNameList = new List<String>();            
        List<Task> updateTaskList = new List<Task>();
        List<Event> updateEventList = new List<Event>();
        system.debug('tsk22 '+taskList);
        if(!taskList.isEmpty()){
             for(Task tsk : taskList){ 
                 if(tsk.navpeII_dev18__Related_Associations__c != NULL && tsk.navpeII_dev18__Related_Associations__c != ' '){ 
                     //46290 Bug Fix By Manonit
                     List<String> relId = tsk.navpeII_dev18__Related_Associations__c.split(',');
                     if(!relId.contains(themeId)){ 
                         tsk.navpeII_dev18__Related_Associations__c =  (tsk.navpeII_dev18__Related_Associations__c != NULL) ? tsk.navpeII_dev18__Related_Associations__c + ','+ themeId : themeId;
                         activitiesMap.put(tsk.Id,tsk.Subject);
                         updateTaskList.add(tsk);
                     }
                }
                 else{
                  tsk.navpeII_dev18__Related_Associations__c =  (tsk.navpeII_dev18__Related_Associations__c != NULL) ? tsk.navpeII_dev18__Related_Associations__c + ','+ themeId : themeId;
                  activitiesMap.put(tsk.Id,tsk.Subject);
                  updateTaskList.add(tsk);   
                 } 
             }
        }
        if(!eventList.isEmpty()){
            for(Event evt : eventList){
                if(evt.navpeII_dev18__Related_Associations__c != NULL && evt.navpeII_dev18__Related_Associations__c != ' '){ 
                     //46290 Bug Fix By Manonit
                     List<String> relId = evt.navpeII_dev18__Related_Associations__c.split(',');
                     if(!relId.contains(themeId)){ 
                         evt.navpeII_dev18__Related_Associations__c =  (evt.navpeII_dev18__Related_Associations__c != NULL) ? evt.navpeII_dev18__Related_Associations__c + ','+ themeId : themeId;
                         activitiesMap.put(evt.Id,evt.Subject);
                         updateEventList.add(evt);
                     }
                }
                else{
                evt.navpeII_dev18__Related_Associations__c  = (evt.navpeII_dev18__Related_Associations__c != NULL) ? evt.navpeII_dev18__Related_Associations__c + ','+ themeId : themeId;
                activitiesMap.put(evt.Id,evt.Subject);
                updateEventList.add(evt);
                }    
            }
        }        
                    
        if(updateEventList.size()>0){
            system.debug('evt2 '+updateEventList +' evtSize '+updateEventList.size());
            List<String> eventActivityList=updateActivitiesRecords(updateEventList);
            activityNameList.addAll(eventActivityList);
        } 
        if(updateTaskList.size()>0){
            system.debug('evt2 '+updateTaskList +' taskSize '+updateTaskList.size());
            List<String> taskActivityList=updateActivitiesRecords(updateTaskList);
            activityNameList.addAll(taskActivityList);
        }
        return activityNameList;
    }
    /*
* Purpose : get all the themes data
* Input : themeId              [ID of the existing theme]     
*       : recId                [Sobject id from the record detail page]
*       : ObjName              [Sobject apiName]
*       : relatedObjectsList   [Selected related records checked on add to theme button]
* Returns : Returns true if records are inserted
*/
    
@AuraEnabled public static Boolean addToTheme(String themeId, String recId , String ObjName, List<String> relatedObjectsList){
    try{
        system.debug('themId '+themeId +' recid '+recId+' ObjName '+ObjName+ ' relObjects '+relatedObjectsList);
        Boolean isInserted = false;
        if(themeId != recId ){
            string namespacePrefix = getNamespacePrefix() + '__';
        List<navpeII_dev18__Theme_Relation__c> themeRelationList = new List<navpeII_dev18__Theme_Relation__c>();
        List<navpeII_dev18__Theme_Relation__c> newThemeRelationList = new List<navpeII_dev18__Theme_Relation__c>();
        list<String> activityNameList = new list<String>();
        Set<ID> sobjRecordsIdSet = new Set<Id>();
        Set<Id> advContIdsForDeal = new Set<Id>();
  
            Set<Id> allObjId = new Set<Id>();
            String queryField = ' ' ;
            String wherefield = ' ';
        //list<SObject> newSobjRecordsToInsert = new list<SObject>();
        list<Id> newSobjRecordIdToInsert = new list<Id>();
        Map<String, Set<Id>> objNameVSObjRecordsMap = new Map<String,Set<Id>>();
        Map<String, List<SObject>> relObjVsRecordsMap = new Map<String, List<SObject>>();
        Map<String,String> objNameVSFieldsMap = new Map<String,String>{
            'Account' => namespacePrefix+'Account__c',
            'Contact'=> namespacePrefix+'Contact__c',
            'navpeII_dev18__Pipeline__c' => namespacePrefix+'Deal__c',
            'navpeII_dev18__Theme__c' => namespacePrefix+'Other_Theme__c',
            'navpeII_dev18__Clip__c'  => namespacePrefix+'Clip__c',
            'navpeII_dev18__Fundraising__c' => namespacePrefix+'Fundraising__c',
            'navpeII_dev18__Fund__c' => namespacePrefix+'Fund__c'
        };
        boolean isNotExisting = false;
        String query = 'SELECT Id, '+ namespacePrefix+'Contact__c, '+ namespacePrefix+'Account__c, '+ namespacePrefix+'Fund__c, '+ namespacePrefix+'Fundraising__c, '+ namespacePrefix+'Deal__c, '+ namespacePrefix+'Clip__c, '+ namespacePrefix+'Other_Theme__c FROM  '+ namespacePrefix+'Theme_Relation__c WHERE '+ namespacePrefix+'Theme__c =: themeId';
        if(ObjName == 'Contact'){
            query += ' AND  '+ namespacePrefix + 'Contact__c =: recId ';
        }
        else if(ObjName == 'Account'){
            query += ' AND  '+ namespacePrefix + 'Account__c =: recId ';
        }
        else if(ObjName == namespacePrefix + 'Fund__c'){
            query += ' AND  '+ namespacePrefix + 'Fund__c =: recId ';
        }
        else if(ObjName == namespacePrefix + 'Fundraising__c'){
            query += ' AND  '+ namespacePrefix + 'Fundraising__c =: recId ';
        }
        else if(ObjName == namespacePrefix + 'Pipeline__c'){
            query += ' AND  '+ namespacePrefix + 'Deal__c =: recId ';
        }
        // Added clip Object Check
        else if(ObjName == namespacePrefix + 'Clip__c'){
            query += ' AND  '+ namespacePrefix + 'Clip__c =: recId ';
        }
        else if(ObjName == namespacePrefix + 'Theme__c'){
            query += ' AND  '+ namespacePrefix + 'Other_Theme__c =: recId ';
        }
        integer rangeNum = Limits.getLimitQueryRows() - Limits.getQueryRows(); 
        query += 'Limit ' + rangeNum; 
        system.debug('query '+query);


        SObjectAccessDecision securityDecision = Security.stripInaccessible(AccessType.READABLE, Database.query(query) );
        themeRelationList = securityDecision.getRecords();
         //00045614 Bug fix By Manonit
        isNotExisting = themeRelationList.isEmpty()? true : false;
        if(themeRelationList.size()>0 && relatedObjectsList.isEmpty()){
            return isInserted;
        }
        else{
            if(isNotExisting){
                newSobjRecordIdToInsert.add(recId);  
            }   
        String themeWhereClause, fundrWhereClause, dealWhereClause;
        String accRecordTypeName,clipWhereClause, dynamicQueryString;
        if(ObjName == 'Account'){
                Account accRec = [Select Id,RecordType.DeveloperName From Account Where Id =:recId WITH USER_MODE limit 1];
                if(accRec != NULL){
                    accRecordTypeName = accRec.RecordType.DeveloperName;
                    if(accRecordTypeName == 'Advisor'){
                        list<Contact> advContList = new list<Contact>([Select Id From Contact Where AccountId = :recId WITH USER_MODE Limit : Limits.getLimitQueryRows() - Limits.getQueryRows()]);
                        if(!advContList.isEmpty()){
                            for(Contact cont : advContList){
                                advContIdsForDeal.add(cont.Id);
                            }
                        }
                    }
                    
                }                      
        }
        for(String relObj : relatedObjectsList){
            if(relObj != 'Activities'){
                if(relObj == 'Account'){
                    dynamicQueryString = (ObjName == 'Contact') ? 'Select Id, AccountId From Contact Where AccountId != NULL And Id = :recId'
                                        :(ObjName == namespacePrefix + 'Pipeline__c') ? 'Select Id, ' + namespacePrefix + 'Company__c From ' + namespacePrefix + 'Pipeline__c Where Id = :recId AND ' + namespacePrefix + 'Company__c != NULL'
                                        :(ObjName == namespacePrefix + 'Fundraising__c') ? 'Select Id, ' + namespacePrefix + 'Legal_Name__c From ' + namespacePrefix + 'Fundraising__c Where Id = :recId AND ' + namespacePrefix + 'Legal_Name__c != NULL'
                                        :(ObjName == namespacePrefix + 'Theme__c') ? 'Select Id, ' + namespacePrefix + 'Account__c From ' + namespacePrefix + 'Theme_Relation__c Where '+ namespacePrefix + 'Theme__c = :recId AND ' + namespacePrefix + 'Account__c != NULL'
                                        :'';
                }
                else if(relObj == 'Contact'){
                    dynamicQueryString = (ObjName == 'Account') ? 'Select Id From Contact Where AccountId = :recId'
                                         :(ObjName == namespacePrefix + 'Theme__c') ? 'Select Id, ' + namespacePrefix + 'Contact__c From ' + namespacePrefix + 'Theme_Relation__c Where '+ namespacePrefix + 'Theme__c = :recId AND ' + namespacePrefix + 'Contact__c != NULL'
                                         :'';
                }
                else if(relObj == namespacePrefix + 'Fundraising__c' || relObj == namespacePrefix + 'Fund__c'){
                    fundrWhereClause =   (ObjName == namespacePrefix + 'Fund__c') ? 'Where ' + namespacePrefix + 'Fund_Name__c = :recId'
                                         :(accRecordTypeName != NULL && (ObjName == 'Account' && accRecordTypeName == 'Institution')) ? 'Where ' + namespacePrefix + 'Legal_Name__c = :recId'
                                         :(ObjName == namespacePrefix + 'Fundraising__c') ? 'Where Id = :recId AND ' + namespacePrefix + 'Fund_Name__c != NULL'
                                         :'';
                    dynamicQueryString = (ObjName == namespacePrefix + 'Theme__c' && relObj == namespacePrefix + 'Fundraising__c' ) ? 'Select Id, ' + namespacePrefix + 'Fundraising__c From ' + namespacePrefix + 'Theme_Relation__c Where '+ namespacePrefix + 'Theme__c = :recId AND ' + namespacePrefix + 'Fundraising__c != NULL'
                                         :(ObjName == namespacePrefix + 'Theme__c' && relObj == namespacePrefix + 'Fund__c' ) ? 'Select Id, ' + namespacePrefix + 'Fund__c From ' + namespacePrefix + 'Theme_Relation__c Where '+ namespacePrefix + 'Theme__c = :recId AND ' + namespacePrefix + 'Fund__c != NULL'
                                         :(fundrWhereClause != NULL || fundrWhereClause != '') ? 'Select Id, ' + namespacePrefix + 'Fund_Name__c From ' + namespacePrefix + 'Fundraising__c '+fundrWhereClause
                                         :'';
                }
                else if(relObj == namespacePrefix + 'Pipeline__c'){
                    dealWhereClause =    (accRecordTypeName != NULL && (ObjName == 'Account' && (accRecordTypeName == 'Company' || accRecordTypeName == 'Portfolio_Company'))) ? 'Where ' + namespacePrefix + 'Company__c = :recId'
                                         :(accRecordTypeName != NULL && (ObjName == 'Account' && accRecordTypeName == 'Intermediary')) ? 'Where ' + namespacePrefix + 'Source_Company__c = :recId'
                                         :(accRecordTypeName != NULL && (ObjName == 'Account' && accRecordTypeName == 'Private_Equity')) ? 'Where (' + namespacePrefix + 'Source_Company__c = :recId OR ' + namespacePrefix + 'Company__c = :recId)'
                                         :'';
                    dynamicQueryString = (accRecordTypeName != NULL && (ObjName == 'Account' && accRecordTypeName == 'Advisor')) ? 'Select Id, ' + namespacePrefix + 'Deal__c From ' + namespacePrefix + 'Deal_Team__c Where ' + namespacePrefix + 'Deal_Contact__c In :advContIdsForDeal AND ' + namespacePrefix + 'Deal__c != NULL'
                                         :(ObjName == namespacePrefix + 'Theme__c' ) ? 'Select Id, ' + namespacePrefix + 'Deal__c From ' + namespacePrefix + 'Theme_Relation__c Where '+ namespacePrefix + 'Theme__c = :recId AND ' + namespacePrefix + 'Deal__c != NULL'
                                         :(dealWhereClause != NULL || dealWhereClause != '') ? 'Select Id From ' + namespacePrefix + 'Pipeline__c ' + dealWhereClause
                                         :'';
                }
                else if(relObj == namespacePrefix + 'Theme__c'){
                    themeWhereClause =  (ObjName == 'Account') ? namespacePrefix + 'Account__c = :recId'
                                        :(ObjName == 'Contact') ? namespacePrefix + 'Contact__c = :recId'
                                        :(ObjName == namespacePrefix + 'Pipeline__c') ? namespacePrefix + 'Deal__c = :recId'
                                        :(ObjName == namespacePrefix + 'Fund__c') ? namespacePrefix + 'Fund__c = :recId'
                                        :(ObjName == namespacePrefix + 'Fundraising__c') ? namespacePrefix + 'Fundraising__c = :recId'
                                        :(ObjName == namespacePrefix + 'Theme__c') ? namespacePrefix + 'Theme__c = :recId'
                                        :'';
                    dynamicQueryString = (themeWhereClause != NULL || themeWhereClause != '') ? 'Select Id, ' + namespacePrefix + 'Theme__c,'+ namespacePrefix +'Other_Theme__c From ' + namespacePrefix + 'Theme_Relation__c Where ' + namespacePrefix + 'Theme__c != :themeId AND ' + namespacePrefix + 'Theme__c != NULL AND '+themeWhereClause :'';
                }
                else if(relObj == namespacePrefix + 'Clip__c'){
                    clipWhereClause = (ObjName == 'Account') ? namespacePrefix + 'Account__c = :recId'
                                      :(ObjName == 'Contact') ? namespacePrefix + 'Contact__c = :recId'
                                      :(ObjName == namespacePrefix + 'Pipeline__c') ? namespacePrefix + 'Deal__c = :recId'
                                      :(ObjName == namespacePrefix + 'Fund__c') ?  namespacePrefix + 'Fund__c = :recId'
                                      :(ObjName == namespacePrefix + 'Fundraising__c') ? namespacePrefix + 'Fundraising__c = :recId'
                                      :'';
                    dynamicQueryString = (clipWhereClause != '') ? 'Select Id, '+ namespacePrefix + 'Clip__c From ' + namespacePrefix + 'Clip_Relation__c Where ' + namespacePrefix + 'Clip__c != NULL AND '+clipWhereClause
                        :'Select Id, ' + namespacePrefix + 'Clip__c From ' + namespacePrefix + 'Theme_Relation__c Where ' + namespacePrefix + 'Theme__c = :recId AND ' + namespacePrefix + 'Clip__c != NULL';                   
                        
                }
                if(dynamicQueryString != Null || dynamicQueryString != ''){
                     rangeNum = Limits.getLimitQueryRows() - Limits.getQueryRows();
                     dynamicQueryString += ' Limit '+rangeNum;
                     system.debug('dq'+dynamicQueryString);
                    
                     SObjectAccessDecision securityDec = Security.stripInaccessible(AccessType.READABLE, Database.query(dynamicQueryString) );
                     //00045614 Bug fix By Manonit

                     relObjVsRecordsMap.put(relObj,securityDec.getRecords());
                }
            }
        }
        if(!relObjVsRecordsMap.isEmpty()){
           for(String relatedObj : relatedObjectsList){
                if(relatedObj != 'Activities'){
                    List<SObject> relObjRecords = relObjVsRecordsMap.get(relatedObj);
                    Id objFieldId;
                    if(!relObjRecords.isEmpty()){
                        Set<Id> relObjIdSet = new Set<Id>();
                        for(SObject obj : relObjRecords){
                            if(relatedObj == namespacePrefix + 'Theme__c'){
                                if(ObjName == namespacePrefix + 'Theme__c' ){
                                   objFieldId = (Id)obj.get(namespacePrefix + 'Other_Theme__c');
                                   }
                                   else{   
                                       objFieldId = (Id)obj.get(namespacePrefix + 'Theme__c');
                                   }
                            }
                            else if(relatedObj == namespacePrefix + 'Clip__c'){
                                objFieldId =  (Id)obj.get(namespacePrefix + 'Clip__c');
                            }
                            else if(ObjName == 'Contact' && relatedObj == namespacePrefix + 'Fundraising__c'){
                                objFieldId = (Id)obj.get(namespacePrefix + 'Fundraising__c');
                            }
                          /*  else if((ObjName == 'Contact' || (accRecordTypeName != NULL && (ObjName == 'Account' ))) && relatedObj == namespacePrefix + 'Pipeline__c'){
                                objFieldId =(Id)obj.get(namespacePrefix + 'Deal__c');
                            }*/ // Fixed By Manonit commented the code as it referencing old Requirement Bug Id - 44946
                            else if(ObjName == 'Contact' && relatedObj == 'Account'){
                                objFieldId =(Id)obj.get('AccountId');
                            }
                            else if(ObjName == namespacePrefix + 'Pipeline__c' && relatedObj == 'Account'){
                                objFieldId =(Id)obj.get(namespacePrefix + 'Company__c');
                            }
                            else if(ObjName == namespacePrefix + 'Pipeline__c'){
                                objFieldId =(Id)obj.get(namespacePrefix + 'Deal_Contact__c');
                            }
                            else if(ObjName == namespacePrefix + 'Fundraising__c'){
                                objFieldId = (relatedObj == namespacePrefix + 'Fund__c') ? (Id)obj.get(namespacePrefix + 'Fund_Name__c')
                                            :(relatedObj == 'Account') ? (Id)obj.get(namespacePrefix + 'Legal_Name__c')
                                            :(relatedObj == 'Contact') ? (Id)obj.get(namespacePrefix + 'Contact__c')
                                            :'';
                            }
                            else if(ObjName == namespacePrefix + 'Theme__c'){
                                if(relatedObj == 'Contact'){
                                objFieldId = (Id)obj.get(namespacePrefix + 'Contact__c');
                                }
                                else if(relatedObj == 'Account'){
                                  objFieldId = (Id)obj.get(namespacePrefix + 'Account__c');  
                                }
                                else if(relatedObj == namespacePrefix + 'Fundraising__c'){
                                  objFieldId = (Id)obj.get(namespacePrefix + 'Fundraising__c');  
                                }
                                else if(relatedObj == namespacePrefix + 'Fund__c'){
                                  objFieldId = (Id)obj.get(namespacePrefix + 'Fund__c');  
                                }
                                else if(relatedObj == namespacePrefix + 'Pipeline__c'){
                                  objFieldId = (Id)obj.get(namespacePrefix + 'Deal__c');  
                                }
                                else if(relatedObj == namespacePrefix + 'Theme__c'){
                                  objFieldId = (Id)obj.get(namespacePrefix + 'Other_Theme__c');  
                                }
                                else {
                                    objFieldId = (Id)obj.get(namespacePrefix + 'Clip__c');
                                }
                            }
                            else{
                                objFieldId = obj.Id;
                            }
                            if(objFieldId != NULL || objFieldId != ''){
                                relObjIdSet.add(objFieldId);
                                sobjRecordsIdSet.add(objFieldId);
                            }
                        }
                        objNameVSObjRecordsMap.put(relatedObj, relObjIdSet);
                        allObjId.addAll(relObjIdSet);
                    }
                }
            }
        }
        if(!objNameVSObjRecordsMap.isEmpty()){
            String queryExistingRecords;
            list<navpeII_dev18__Theme_Relation__c> existingTRRecList = new list<navpeII_dev18__Theme_Relation__c>();
            Set<Id> existingRecIdSet = new Set<Id>();
            Set<Id> relObjRecIdSet = new Set<Id>();
            queryField = namespacePrefix+'Account__c,'+namespacePrefix+'Contact__c,'+namespacePrefix+'Deal__c,'+namespacePrefix+'Other_Theme__c,'+namespacePrefix+'Clip__c,'+namespacePrefix+'Fundraising__c,'+namespacePrefix+'Fund__c';
            rangeNum = Limits.getLimitQueryRows() - Limits.getQueryRows();
            queryExistingRecords = 'Select Id, '+ queryField + ' From ' + namespacePrefix + 'Theme_Relation__c Where ' + namespacePrefix + 'Theme__c = :themeId AND ('+  namespacePrefix+'Account__c' + ' In :allObjId  OR '+ namespacePrefix+'Contact__c' + ' In :allObjId  OR '+ namespacePrefix+'Other_Theme__c' 
                                      + ' In :allObjId  OR '+ namespacePrefix+'Deal__c' + ' In :allObjId  OR '+ namespacePrefix+'Fundraising__c' + ' In :allObjId  OR '+ namespacePrefix+'Fund__c' + ' In :allObjId  OR '+ namespacePrefix+'Clip__c' + ' In :allObjId) Limit '+rangeNum;
               
               SObjectAccessDecision securityDecisionExisting = Security.stripInaccessible(AccessType.READABLE, Database.query(queryExistingRecords) );
               existingTRRecList = securityDecisionExisting.getRecords(); //	00044995 Bug Fix By Manonit 
               System.debug('@@@Removed'+securityDecisionExisting.getRemovedFields());
               if(!existingTRRecList.isEmpty()){
                   for(sObject trRec: existingTRRecList){
                       system.debug('@@@'+trRec);
                       if(securityDecisionExisting.getRemovedFields() !=null && securityDecisionExisting.getRemovedFields().size() > 0){
                       if(!securityDecisionExisting.getRemovedFields().get(namespacePrefix + 'Theme_Relation__c').contains(namespacePrefix+'Account__c')){
                       system.debug('@@@inside');
                       if(trRec.get(namespacePrefix+'Account__c') != Null && trRec.get(namespacePrefix+'Account__c') != ''){
                       existingRecIdSet.add((Id)trRec.get(namespacePrefix+'Account__c'));
                       }}
                       if(!securityDecisionExisting.getRemovedFields().get(namespacePrefix + 'Theme_Relation__c').contains(namespacePrefix+'Contact__c')){
                       if(trRec.get(namespacePrefix+'Contact__c') != Null && trRec.get(namespacePrefix+'Contact__c') != ''){
                       existingRecIdSet.add((Id)trRec.get(namespacePrefix+'Contact__c'));
                       }}
                       if(!securityDecisionExisting.getRemovedFields().get(namespacePrefix + 'Theme_Relation__c').contains(namespacePrefix+'Deal__c')){
                       if(trRec.get(namespacePrefix+'Deal__c') != Null && trRec.get(namespacePrefix+'Deal__c') != ''){
                       existingRecIdSet.add((Id)trRec.get(namespacePrefix+'Deal__c'));
                       } }
                       if(!securityDecisionExisting.getRemovedFields().get(namespacePrefix + 'Theme_Relation__c').contains(namespacePrefix+'Other_Theme__c')){
                       if(trRec.get(namespacePrefix+'Other_Theme__c') != Null && trRec.get(namespacePrefix+'Other_Theme__c') != ''){
                       existingRecIdSet.add((Id)trRec.get(namespacePrefix+'Other_Theme__c'));
                       }}
                       if(!securityDecisionExisting.getRemovedFields().get(namespacePrefix + 'Theme_Relation__c').contains(namespacePrefix+'Clip__c')){
                       if(trRec.get(namespacePrefix+'Clip__c') != Null && trRec.get(namespacePrefix+'Clip__c') != ''){
                       existingRecIdSet.add((Id)trRec.get(namespacePrefix+'Clip__c'));
                       } }
                       if(!securityDecisionExisting.getRemovedFields().get(namespacePrefix + 'Theme_Relation__c').contains(namespacePrefix+'Fundraising__c')){
                       if(trRec.get(namespacePrefix+'Fundraising__c') != Null && trRec.get(namespacePrefix+'Fundraising__c') != ''){
                       existingRecIdSet.add((Id)trRec.get(namespacePrefix+'Fundraising__c'));
                       } }
                       if(!securityDecisionExisting.getRemovedFields().get(namespacePrefix + 'Theme_Relation__c').contains(namespacePrefix+'Fund__c')){
                        if(trRec.get(namespacePrefix+'Fund__c') != Null && trRec.get(namespacePrefix+'Fund__c') != ''){
                       existingRecIdSet.add((Id)trRec.get(namespacePrefix+'Fund__c'));
                       } }
                   }//44492 Bug Fix by Manonit
                   else{
                       if(trRec.get(namespacePrefix+'Account__c') != Null && trRec.get(namespacePrefix+'Account__c') != ''){
                       existingRecIdSet.add((Id)trRec.get(namespacePrefix+'Account__c'));
                       }
                       if(trRec.get(namespacePrefix+'Contact__c') != Null && trRec.get(namespacePrefix+'Contact__c') != ''){
                       existingRecIdSet.add((Id)trRec.get(namespacePrefix+'Contact__c'));
                       }
                       if(trRec.get(namespacePrefix+'Deal__c') != Null && trRec.get(namespacePrefix+'Deal__c') != ''){
                       existingRecIdSet.add((Id)trRec.get(namespacePrefix+'Deal__c'));
                       } 
                       if(trRec.get(namespacePrefix+'Other_Theme__c') != Null && trRec.get(namespacePrefix+'Other_Theme__c') != ''){
                       existingRecIdSet.add((Id)trRec.get(namespacePrefix+'Other_Theme__c'));
                       }
                       if(trRec.get(namespacePrefix+'Clip__c') != Null && trRec.get(namespacePrefix+'Clip__c') != ''){
                       existingRecIdSet.add((Id)trRec.get(namespacePrefix+'Clip__c'));
                       }
                       if(trRec.get(namespacePrefix+'Fundraising__c') != Null && trRec.get(namespacePrefix+'Fundraising__c') != ''){
                       existingRecIdSet.add((Id)trRec.get(namespacePrefix+'Fundraising__c'));
                       }
                        if(trRec.get(namespacePrefix+'Fund__c') != Null && trRec.get(namespacePrefix+'Fund__c') != ''){
                       existingRecIdSet.add((Id)trRec.get(namespacePrefix+'Fund__c'));
                       }
                   }
                }  
               }
           for(Id objectId : sobjRecordsIdSet){
                if(!existingRecIdSet.contains(objectId) && objectId != Null ){
                    newSobjRecordIdToInsert.add(objectId);
                }
            }
        } 
        if(!newSobjRecordIdToInsert.isEmpty()){
            navpeII_dev18__Theme_Relation__c trRec ;
            
            for(Id objId : newSobjRecordIdToInsert){
                trRec = new navpeII_dev18__Theme_Relation__c();
                String obj = objId.getsobjecttype().getDescribe().getName();
                if(obj == 'Contact' && (checkCreateableFields(Schema.sObjectType.navpeII_dev18__Theme_Relation__c.getsObjectType(), new List<String>{namespacePrefix + 'Contact__c'}))){
                    trRec.navpeII_dev18__Contact__c = objId;
                }
                else if(obj == 'Account' && (checkCreateableFields(Schema.sObjectType.navpeII_dev18__Theme_Relation__c.getsObjectType(), new List<String>{namespacePrefix + 'Account__c'}))){
                    trRec.navpeII_dev18__Account__c = objId;
                }
                else if (obj == namespacePrefix + 'Pipeline__c' && (checkCreateableFields(Schema.sObjectType.navpeII_dev18__Theme_Relation__c.getsObjectType(), new List<String>{namespacePrefix + 'Deal__c'}))){
                    trRec.navpeII_dev18__Deal__c = objId;
                }
                else if(obj == namespacePrefix + 'Theme__c' && (checkCreateableFields(Schema.sObjectType.navpeII_dev18__Theme_Relation__c.getsObjectType(), new List<String>{namespacePrefix + 'Other_Theme__c'}))){
                    trRec.navpeII_dev18__Other_Theme__c = objId;
                }
                else if(obj == namespacePrefix + 'Clip__c' && (checkCreateableFields(Schema.sObjectType.navpeII_dev18__Theme_Relation__c.getsObjectType(), new List<String>{namespacePrefix + 'Clip__c'}))){
                    trRec.navpeII_dev18__Clip__c = objId;
                }
                else if(obj == namespacePrefix + 'Fundraising__c' && (checkCreateableFields(Schema.sObjectType.navpeII_dev18__Theme_Relation__c.getsObjectType(), new List<String>{namespacePrefix + 'Fundraising__c'}))){
                    trRec.navpeII_dev18__Fundraising__c = objId;
                }
                else if(obj == namespacePrefix + 'Fund__c' && (checkCreateableFields(Schema.sObjectType.navpeII_dev18__Theme_Relation__c.getsObjectType(), new List<String>{namespacePrefix + 'Fund__c'}))){
                    trRec.navpeII_dev18__Fund__c = objId;
                }
                trRec.navpeII_dev18__Theme__c = themeId;
                isInserted= true;
                newThemeRelationList.add(trRec);
            }
        }
        isInserted= true;   
        if(!newThemeRelationList.isEmpty() && Schema.sObjectType.navpeII_dev18__Theme_Relation__c.isCreateable()){
            Insert newThemeRelationList;
        }
        if(relatedObjectsList.contains('Activities')){
           ResponseWrapperAct newResponse = new ResponseWrapperAct();
            newResponse = fetchAssoActIdList(recId,ObjName,themeId,namespacePrefix);
            if(newResponse != null){
                if((newResponse.alltaskList.size() > 0 ) || (newResponse.alleventList.size() > 0 ) ){
                    activityNameList = linkInteractionsToSelectedTheme(newResponse.alltaskList,newResponse.alleventList,themeId);
                //isInserted = (!activityNameList.isEmpty()) ? true : false;
                    isInserted = true; //00046680 Bug fix By Manonit 
                }
            }            
        }
        }
    }
        return isInserted;
    }        
    catch(Exception e) {
        throw new AuraHandledException('Error Occured While Loading Component : <<' + e.getStackTraceString() + '>>');
    }
}
    
    /*
    * Phase 3 -
    * Purpose : For displaying the related objects label as an checkboxes on click of AddToTheme
    * Input : recId  [Id of the record on which add to theme is clicked]     
    * Returns : Related Objects Label dynamically and apiName as Map
    */
    @AuraEnabled
    public static Map<String,String> getRelatedObjectRecords(String recId){

        String SobjectName = Id.valueOf(recId).getSObjectType().getDescribe().getName();
        String namespacePrefix = getNamespacePrefix() +'__';
        System.debug('Sobjectname '+SobjectName);
        Set<String> sobjectApiNameList = new Set<String>();
        Map<String,String> relObjLabelVsRelObjNameMap = new Map<String,String>();
        Map<String,Schema.SObjectType> describeObjects = Schema.getGlobalDescribe();
        boolean isAccRecordTypeField = false;
        try {
            if(SobjectName == 'Account'){
                sobjectApiNameList.add('Contact');
                Map<String, SObjectField> accFieldMap = describeObjects.get('Account').getDescribe().fields.getMap();
                isAccRecordTypeField = (accFieldMap.containsKey('RecordTypeId')) ? true : false;
                if(isAccRecordTypeField){
                    Account accRec = [Select Id,RecordType.DeveloperName From Account Where Id =:recId limit 1];
                    if(accRec != NULL){
                       String recordTypeName = accRec.RecordType.DeveloperName;
                       Set<String> recordTypeSet = new Set<String>{'Company','Intermediary','Portfolio_Company','Private_Equity'};//00045546 Bug Fix By Manonit
                       if(recordTypeSet.contains(recordTypeName)){
                           sobjectApiNameList.add(namespacePrefix + 'Pipeline__c');
                        }
                       else if(recordTypeName == ('Institution')){
                           sobjectApiNameList.add(namespacePrefix + 'Fundraising__c');
                       }
                    }   
                }
            }
            else if(SobjectName == 'Contact'){
                sobjectApiNameList.add('Account');
                //sobjectApiNameList.add(namespacePrefix + 'Pipeline__c');
                //sobjectApiNameList.add(namespacePrefix + 'Fundraising__c');
            }
            else if(SobjectName == namespacePrefix + 'Pipeline__c'){
                sobjectApiNameList.add('Account');
                //sobjectApiNameList.add('Contact');
            }
            else if(SobjectName == namespacePrefix + 'Fund__c'){
                sobjectApiNameList.add(namespacePrefix + 'Fundraising__c');
            }
            else if(SobjectName == namespacePrefix + 'Fundraising__c'){
                sobjectApiNameList.add('Account');
                //sobjectApiNameList.add('Contact');
                sobjectApiNameList.add(namespacePrefix + 'Fund__c');       
            }
            else if(SobjectName == namespacePrefix + 'Theme__c' || SobjectName == namespacePrefix + 'Clip__c'){
                sobjectApiNameList.add('Account');
                sobjectApiNameList.add('Contact');
                sobjectApiNameList.add(namespacePrefix + 'Pipeline__c');
                sobjectApiNameList.add(namespacePrefix + 'Fund__c');
                sobjectApiNameList.add(namespacePrefix + 'Fundraising__c');
            }
            if(!(SobjectName == namespacePrefix + 'Clip__c')){
                sobjectApiNameList.add(namespacePrefix + 'Theme__c');
                sobjectApiNameList.add(namespacePrefix + 'Clip__c');
            }
            if(!sobjectApiNameList.isEmpty()){
                for(String objName : sobjectApiNameList){
                    Schema.DescribeSObjectResult describeResult = describeObjects.get(objName).getDescribe();
                    // 46352 and 45578 Bug Fix by Manonit
                    if(describeResult.isAccessible()){
                        relObjLabelVsRelObjNameMap.put(describeResult.getLabel(),describeResult.getName()); //00045744 and 45430 Bug Fix By Manonit
                    }
                }                
            }
            if(!(SobjectName == namespacePrefix + 'Clip__c')){
                relObjLabelVsRelObjNameMap.put('Interaction','Activities');
            }
            system.debug('map '+relObjLabelVsRelObjNameMap);
            return relObjLabelVsRelObjNameMap;
            
        } catch (Exception e) {
            throw new AuraHandledException('Error Occured While Loading Component : <<' + e.getStackTraceString() + '>> ');
        }
    }


    /*
* Purpose : Wrapper for page load information
*/
    public class ResponseWrapper{
        @AuraEnabled public String namespacePrefix;         //Namespaceprefix to be used
        @AuraEnabled public List<String> actIdList;         //Used for Interactions Section & Contacts/Connections Section (W/O AA Field Consideration)
        @AuraEnabled public List<String> completeActIdList; //Used for Interactions Section & Contacts/Connections Section (With AA Field Consideration)
        @AuraEnabled public String themeTeamMembers;  //Used for displaying Theme Team members on Load
        //Added In Phase 3
        @AuraEnabled public List<Task> taskRecordsList;    // used for linking taskRecords of the selected record
        @AuraEnabled public List<Event> eventRecordsList;  // used for linking eventRecords of the selected records

        public ResponseWrapper(){
            this.taskRecordsList = new List<Task>();
            this.eventRecordsList = new List<Event>();
        }
    }
    
    
    @AuraEnabled
    public static ResponseWrapper handleOnLoadInfo(String recordId,string currentObjName, String newThemeId){
        try {
        ResponseWrapper respWrapper = new ResponseWrapper();
        respWrapper.namespacePrefix = getNamespacePrefix() + '__';
        Map<Id,List<String>> mapThemeToThemeTeamMembers = new Map<Id,List<String>>();
        List<String> themeTeamNamesList = new List<String>();
        List<String> completeActIdList = new List<String>();
        Set<String> allActivityIdSet = new Set<String>();
        List<Task> taskRecList = new List<Task>();
        List<Event> eventRecList = new List<Event>();
        Set<Id> taskIdSet = new Set<Id>();
        Set<Id> eventIdSet = new Set<Id>();
        integer rowsLimit = Limits.getLimitQueryRows() - Limits.getQueryRows();
        if(currentObjName == 'Contact' && Schema.getGlobalDescribe().get('TaskRelation') != null){
            list<SObject> taskRelationList = new list<SObject>();
            list<SObject> eventRelationList = new list<SObject>();
            taskRelationList = Database.query('Select Id,TaskId From TaskRelation Where RelationId =:recordId And TaskId != NULL Limit '+rowsLimit, AccessLevel.USER_MODE);
            rowsLimit = Limits.getLimitQueryRows() - Limits.getQueryRows();
            eventRelationList = Database.query('Select Id, EventId From EventRelation Where RelationId = :recordID And EventId != NULL Limit '+ rowsLimit, AccessLevel.USER_MODE);
            if(!taskRelationList.isEmpty()){
                for(SObject tskRel : taskRelationList){
                   taskIdSet.add(String.valueof(tskRel.get('TaskId')));
                }
            }
            if(!eventRelationList.isEmpty()){
                for(SObject evtRel : eventRelationList){
                   eventIdSet.add(String.valueof(evtRel.get('EventId')));
                }
            }            
        }
        rowsLimit = Limits.getLimitQueryRows() - Limits.getQueryRows();
        //00045250 Bug Fix By Manonit
        taskRecList = (currentObjName == 'Contact' && !taskIdSet.isEmpty())? Database.query('Select Id ,Subject, Description ,navpeII_dev18__Related_Associations__c From Task Where Id In :taskIdSet AND TaskSubtype != \'ListEmail\' Limit '+rowsLimit, AccessLevel.USER_MODE)
                      : Database.query('SELECT ID,Subject,Description,navpeII_dev18__Related_Associations__c FROM Task where (navpeII_dev18__Related_Associations__c Like \'%'+recordId+'%\' AND (NOT navpeII_dev18__Related_Associations__c  Like \'%'+newThemeId+'%\')) Order By CreatedDate Limit '+rowsLimit, AccessLevel.USER_MODE);
        rowsLimit = Limits.getLimitQueryRows() - Limits.getQueryRows();
        eventRecList = (currentObjName == 'Contact' && !eventIdSet.isEmpty())? Database.query('Select Id, Subject, Description ,navpeII_dev18__Related_Associations__c From Event Where Id In :eventIdSet Limit '+rowsLimit, AccessLevel.USER_MODE)
                      : (Database.query('SELECT ID,Subject,Description,navpeII_dev18__Related_Associations__c FROM Event where (navpeII_dev18__Related_Associations__c Like \'%'+recordId+'%\' AND (NOT navpeII_dev18__Related_Associations__c Like \'%'+newThemeId+'%\')) Order By CreatedDate Limit '+rowsLimit, AccessLevel.USER_MODE));
        if(taskRecList.size() > 0){
            system.debug('insidetask '+taskRecList);
            respWrapper.taskRecordsList =taskRecList;
            system.debug('resp task '+respWrapper.taskRecordsList);
            for(Task thisTask : taskRecList){
                allActivityIdSet.add(thisTask.Id);
                system.debug('act '+thisTask);     
            }
        }
        if(eventRecList.size() > 0){
            system.debug('insideevt '+eventRecList);
            respWrapper.eventRecordsList= eventRecList;
            system.debug('act 33 '+respWrapper.eventRecordsList);
            for(Event thisEvent : eventRecList){
                allActivityIdSet.add(thisEvent.Id);
                system.debug('act 1'+thisEvent);
            }
        }
        if(!allActivityIdSet.isEmpty()){
            completeActIdList.addAll(allActivityIdSet);
            system.debug('actlist '+completeActIdList);
        }
        for(navpeII_dev18__Theme_Team__c thisThemeTeamRec : [SELECT id, navpeII_dev18__Member__c, navpeII_dev18__Member__r.Name, navpeII_dev18__Theme__c FROM navpeII_dev18__Theme_Team__c WHERE navpeII_dev18__Theme__c =:recordId]){
		if(Schema.sObjectType.Theme_Team__c.Fields.Member__c.isAccessible()){ //Added by Hema W.R.T Security Fix
            themeTeamNamesList.add(thisThemeTeamRec.navpeII_dev18__Member__r.Name); 
                }			
        }
        respWrapper.themeTeamMembers =  (themeTeamNamesList.size() > 0)?String.join(themeTeamNamesList, ', ') : ''; //Added by Hema W.R.T Security Fix
        respWrapper.completeActIdList = completeActIdList;
        return respWrapper;
        } catch(Exception e) {
            throw new AuraHandledException('Error Occured While Loading Component : <<' + e.getStackTraceString() + '>>');
        }
    }
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
    * Purpose : Insert the Interactions records of the existing theme to new theme
    * Input : sObjectList     [Id of the Interactions to be cloned]     
    * Returns : Activities Data which are untagged to the theme
    */
    
    public static List<String> updateActivitiesRecords( List<Sobject> sObjectList){

        try{
        List<String> activityNameList = new List<String>();
        system.debug('@listnew act '+sObjectList);
        List<Database.SaveResult> updateResults = Database.update(sObjectList, false);
        for(Integer i=0;i<updateResults.size();i++){
            if (updateResults.get(i).isSuccess()){
                updateResults.get(i).getId();
                
            }else if (!updateResults.get(i).isSuccess()){
                Database.Error error = updateResults.get(i).getErrors().get(0);
                String failedDML = error.getMessage();
              //  activityNameList.add(activitiesMap.get(sObjectList.get(i).Id));//failed record from the list
                activityNameList.add(updateResults.get(i).getId());
            }
        }
        system.debug('actvityNameList '+ activityNameList +'DML 14'+Limits.getDMLStatements() +', Soql14'+ Limits.getQueries());
        return activityNameList;
        
         }
catch(Exception e) {
throw new AuraHandledException('Error Occured While Loading Component : <<' + e.getStackTraceString() + '>>');
}
    }
    
    
    public static Boolean checkCreateableFields(Schema.SObjectType objectType, List<String> fieldNames) {
        Map<String, Schema.SobjectField> fields = objectType.getDescribe().fields.getMap();
        for (String s : fieldNames.clone() ) {
            if ((fields.get(s.toLowerCase()).getDescribe().isCreateable()) ) {
                fieldNames.remove(fieldNames.indexOf(s));
            }
        }
        if(fieldNames.size()>0)
            return false;
        else
            return true;
    }
    @AuraEnabled
    public static ThemeWrapper getThemeFields(){
        List<String> themeMetadatList = new List<String>();
         themeMetadatList.add(Acuity_Setting__mdt.getInstance('Acuity_Theme_Field1').Value__c);
         themeMetadatList.add(Acuity_Setting__mdt.getInstance('Acuity_Theme_Field2').Value__c);
          themeMetadatList.add(Acuity_Setting__mdt.getInstance('Acuity_Theme_Field3').Value__c);
          themeMetadatList.add(Acuity_Setting__mdt.getInstance('Acuity_Theme_Field4').Value__c);
          themeMetadatList.add(Acuity_Setting__mdt.getInstance('Acuity_Theme_Field4').Value__c);
         ThemeWrapper themeWrapper = new ThemeWrapper();
        themeWrapper.ThemeHeader1 = fetchFieldLabel('navpeII_dev18__Theme__c', Acuity_Setting__mdt.getInstance('Acuity_Theme_Field2').Value__c.replace('__r','__c'));
        themeWrapper.ThemeHeader2 = fetchFieldLabel('navpeII_dev18__Theme__c', Acuity_Setting__mdt.getInstance('Acuity_Theme_Field3').Value__c.replace('__r','__c')); 
        themeWrapper.ClipHeader1 =  fetchFieldLabel('navpeII_dev18__Clip__c', Acuity_Setting__mdt.getInstance('Acuity_Tagged_Clips_Field1').Value__c.replace('__r','__c'));
        themeWrapper.ClipHeader2 =  fetchFieldLabel('navpeII_dev18__Clip__c', Acuity_Setting__mdt.getInstance('Acuity_Tagged_Clips_Field2').Value__c.replace('__r','__c'));
        themeWrapper.ThemeFieldsList = themeMetadatList;
        themeWrapper.isThemeAccess = schema.sobjecttype.Theme__c.isaccessible() ? False : True ;
        themeWrapper.isClipAccess =  schema.sobjecttype.Theme__c.isaccessible()  ? False :True  ; 
        return themeWrapper;
    }
     
     
     
    /*
     * Purpose : Fetches the field label to be displayed as data table column header
     * Input : objName      [Theme]
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
     /*
* Purpose : Wrapper for Themes Field data
*/  
    public class ThemeWrapper{
        @AuraEnabled public String ThemeHeader1; 
        @AuraEnabled public String ThemeHeader2;
        @AuraEnabled public String ClipHeader1;
        @AuraEnabled public String ClipHeader2;
        @AuraEnabled public List<String> ThemeFieldsList;
        @AuraEnabled public Boolean isThemeAccess;
        @AuraEnabled public Boolean isClipAccess;
    }  
  
     @AuraEnabled
    public static String getThemeName(string themeId){
     return [SELECT Id, Name
             FROM navpeII_dev18__Theme__c
             WHERE Id =: themeId].Name;
     }


     /*----------------------------------------------Interaction Fix Start  45974 and 46278 Bug Fix by Manonit---------------------------------------*/

     //Stores the unique activity IDs
    private static Set<String> completeActIdsSet = new Set<String>();


    /*
     * Purpose : Handles the fetching of associated activity IDs
     * Input : recordId         [Record ID of the current record (Account/Contact/Deal/Fund/Fundraising/Theme)]
     *         objectApiName    [API name of the current record (Account/Contact/Deal/Fund/Fundraising/Theme)]
     *         namespacePrefix  [Namespaceprefix to be used]
     * Returns : ResponseWrapperAct containing associated activity list
     */
    private static ResponseWrapperAct fetchAssoActIdList(String recordId, String objectApiName,String newThemeId, String namespacePrefix){
        try{
            ResponseWrapperAct respWrapperAct = new ResponseWrapperAct();
                List<Task> taskList = new List<Task>();
                List<Event> eventList = new List<Event>();
                Set<String> eventIdSet = new Set<String>();
                Set<String> taskIdSet = new Set<String>();
             //respWrapperAct.namespacePrefix = getNamespacePrefix() + '__';
            if(String.escapeSingleQuotes(objectApiName).equalsIgnoreCase('Account')){
                Set<String> conIdSet = new Set<String>();
                conIdSet.addAll(fetchInitInfoToProcess('Id', 'Contact', ' WHERE AccountId = :recordId', recordId));
                //For handling events
                //46490 Bug Fix Manonit
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
                    taskIdSet = fetchActRecsToProcess(conIdSet, 'Task', ' WHERE (Relation.Type = \'Contact\') AND (Task.TaskSubtype != \'ListEmail\') AND ((RelationId IN :conIdSet) OR (Task.' + namespacePrefix + 'Related_Associations__c LIKE \'%' + String.escapeSingleQuotes(recordId) + '%\'))');
                    if(taskIdSet.size() > 0){
                          taskList = [Select Id,subject,navpeII_dev18__Related_Associations__c From Task where Id IN: taskIdSet Limit :getDynamicQueryLimit()];
                     }
                    if(taskList.size() > 0){
                        completeTaskList.addAll(taskList);
                    }
                    prepareAssoActSet('Task', '((' + namespacePrefix + 'Related_Associations__c LIKE \'%' + recordId + '%\') AND (NOT navpeII_dev18__Related_Associations__c  Like \'%'+newThemeId+'%\'))', namespacePrefix);    //For covering the scenario : Empty Name & Accounts in AA field    
                }
            } else if(String.escapeSingleQuotes(objectApiName).equalsIgnoreCase('Contact')){
                //For handling events
                eventIdSet = fetchActRecsToProcess(recordId, 'Event', ' WHERE (Event.IsChild = false) AND (RelationId = :recordId)');
                if(eventIdSet.size() > 0){
                    eventList = [Select Id,subject,navpeII_dev18__Related_Associations__c From Event where Id IN: eventIdSet Limit :getDynamicQueryLimit()]; 
                }
                if(eventList.size() > 0){
                    completeEventList.addAll(eventList);
                }
                //For handling tasks
                if(Schema.getGlobalDescribe().get('TaskRelation') != null){
                    taskIdSet = fetchActRecsToProcess(recordId, 'Task', ' WHERE (RelationId = :recordId)');
                    if(taskIdSet.size() > 0){
                        taskList = [Select Id,subject,navpeII_dev18__Related_Associations__c From Task where Id IN: taskIdSet Limit :getDynamicQueryLimit()];
                    }
                    if(taskList.size() > 0){
                        completeTaskList.addAll(taskList);
                    }

                }
            }   else if(String.escapeSingleQuotes(objectApiName).equalsIgnoreCase(namespacePrefix + 'Pipeline__c') || String.escapeSingleQuotes(objectApiName).equalsIgnoreCase(namespacePrefix + 'Theme__c')){
                //For handling events
                eventIdSet = fetchActRecsToProcess('', 'Event', ' WHERE (Event.IsChild = false) AND (Relation.Type = \'Contact\') AND (Event.' + namespacePrefix + 'Related_Associations__c LIKE \'%' + String.escapeSingleQuotes(recordId) + '%\')');
                if(eventIdSet.size() > 0){
                    eventList = [Select Id,subject,navpeII_dev18__Related_Associations__c From Event where Id IN: eventIdSet Limit :getDynamicQueryLimit()];
                }
                if(eventList.size() > 0){
                    completeEventList.addAll(eventList);
                }
                prepareAssoActSet('Event', '(' + namespacePrefix + 'Related_Associations__c LIKE \'%' + String.escapeSingleQuotes(recordId) + '%\')', namespacePrefix);    //For covering the scenario : Empty Name & Accounts in AA field
                //For handling tasks
                if(Schema.getGlobalDescribe().get('TaskRelation') != null){
                    taskIdSet = fetchActRecsToProcess('', 'Task', ' WHERE (Relation.Type = \'Contact\') AND (Task.' + namespacePrefix + 'Related_Associations__c LIKE \'%' + String.escapeSingleQuotes(recordId) + '%\')');
                    if(taskIdSet.size() > 0){
                        taskList = [Select Id,subject,navpeII_dev18__Related_Associations__c From Task where Id IN: taskIdSet Limit :getDynamicQueryLimit()];
                    }
                    if(taskList.size() > 0){
                        completeTaskList.addAll(taskList);
                    }
                    prepareAssoActSet('Task', '(' + namespacePrefix + 'Related_Associations__c LIKE \'%' + String.escapeSingleQuotes(recordId) + '%\')', namespacePrefix);     //For covering the scenario : Empty Name & Accounts in AA field
                }
            }  else if(String.escapeSingleQuotes(objectApiName).equalsIgnoreCase(namespacePrefix + 'Fund__c')){
                Set<String> fdrIdSet = new Set<String>();
                fdrIdSet.addAll(fetchInitInfoToProcess('Id', namespacePrefix + 'Fundraising__c', ' WHERE ' + namespacePrefix + 'Fund_Name__c = :recordId', recordId));

                String fdrWhereClauseStrEvent = '(Event.' + namespacePrefix + 'Related_Associations__c LIKE \'%' + String.escapeSingleQuotes(recordId) + '%\')';
                String fdrWhereClauseStrTask = '(Task.' + namespacePrefix + 'Related_Associations__c LIKE \'%' + String.escapeSingleQuotes(recordId) + '%\')';
                for(String fdrRecId : fdrIdSet){
                    fdrWhereClauseStrEvent += ' OR (Event.' + namespacePrefix + 'Related_Associations__c LIKE \'%' + String.escapeSingleQuotes(fdrRecId) + '%\')';
                    fdrWhereClauseStrTask += ' OR (Task.' + namespacePrefix + 'Related_Associations__c LIKE \'%' + String.escapeSingleQuotes(fdrRecId) + '%\')';
                }
                //For handling events 46278 Bug Fix By Manonit
                eventIdSet = fetchActRecsToProcess('', 'Event', ' WHERE (Event.IsChild = false) AND (Relation.Type = \'Contact\') AND (' + fdrWhereClauseStrEvent + ')');
                if(eventIdSet.size() > 0){
                    eventList = [Select Id,subject,navpeII_dev18__Related_Associations__c From Event where Id IN: eventIdSet Limit :getDynamicQueryLimit()];
                }
                if(eventList.size() > 0){
                    completeEventList.addAll(eventList);
                }
                prepareAssoActSet('Event', '(' + fdrWhereClauseStrEvent + ')', namespacePrefix);    //For covering the scenario : Empty Name & Accounts in AA field
                //For handling tasks
                if(Schema.getGlobalDescribe().get('TaskRelation') != null){
                    taskIdSet = fetchActRecsToProcess(fdrIdSet, 'Task', ' WHERE (Relation.Type = \'Contact\') AND (' + fdrWhereClauseStrTask + ')');
                    if(taskIdSet.size() > 0){
                        taskList = [Select Id,subject,navpeII_dev18__Related_Associations__c From Task where Id IN: taskIdSet Limit :getDynamicQueryLimit()];
                    }
                    if(taskList.size() > 0){
                        completeTaskList.addAll(taskList);
                    }
                    prepareAssoActSet('Task', '(' + fdrWhereClauseStrTask + ')', namespacePrefix);    //For covering the scenario : Empty Name & Accounts in AA field    
                }
            } else if(String.escapeSingleQuotes(objectApiName).equalsIgnoreCase(namespacePrefix + 'Fundraising__c')){
                Set<String> conIdSet = new Set<String>();
                conIdSet.addAll(fetchInitInfoToProcess(namespacePrefix + 'Contact__c', namespacePrefix + 'Fundraising_Contact__c', ' WHERE ' + namespacePrefix + 'Fundraising__c = :recordId', recordId));
                //For handling events
                eventIdSet = fetchActRecsToProcess(conIdSet, 'Event', ' WHERE (Event.IsChild = false) AND (Relation.Type = \'Contact\') AND ((RelationId IN :conIdSet) OR (Event.' + namespacePrefix + 'Related_Associations__c LIKE \'%' + String.escapeSingleQuotes(recordId) + '%\'))');
                if(eventIdSet.size() > 0){
                    eventList = [Select Id,subject,navpeII_dev18__Related_Associations__c From Event where Id IN: eventIdSet Limit :getDynamicQueryLimit()];
                 }
                if(eventList.size() > 0){
                    completeEventList.addAll(eventList);
                }
                prepareAssoActSet('Event', '(' + namespacePrefix + 'Related_Associations__c LIKE \'%' + recordId + '%\')', namespacePrefix);    //For covering the scenario : Empty Name & Accounts in AA field
                //For handling tasks
                if(Schema.getGlobalDescribe().get('TaskRelation') != null){
                    taskIdSet = fetchActRecsToProcess(conIdSet, 'Task', ' WHERE (Relation.Type = \'Contact\') AND ((RelationId IN :conIdSet) OR (Task.' + namespacePrefix + 'Related_Associations__c LIKE \'%' + String.escapeSingleQuotes(recordId) + '%\'))');
                    if(taskIdSet.size() > 0){
                        taskList = [Select Id,subject,navpeII_dev18__Related_Associations__c From Task where Id IN: taskIdSet Limit :getDynamicQueryLimit()];
                    }
                    if(taskList.size() > 0){
                        completeTaskList.addAll(taskList);
                    }
                    prepareAssoActSet('Task', '(' + namespacePrefix + 'Related_Associations__c LIKE \'%' + recordId + '%\')', namespacePrefix);    //For covering the scenario : Empty Name & Accounts in AA field    
                }
            }
            if(!completeTaskList.isEmpty() || !completeEventList.isEmpty() ){
                List<Task> taskResult = new List<Task>();
                List<Event> eventResult = new List<Event>();
                Set<Task> taskSet = new Set<Task>(completeTaskList); // To Avoid Duplicacy
                Set<Event> eventSet = new Set<Event>(completeEventList); // To Avoid Duplicacy
                
                
                taskResult.addAll(taskSet);
                eventResult.addAll(eventSet);

                respWrapperAct.alleventList = eventResult;
                respWrapperAct.alltaskList = taskResult;
                return respWrapperAct;
            } else {
                return null;
            }
        } catch (Exception e) {
            throw new AuraHandledException(' : <<' + e.getStackTraceString() + '>>');
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
            throw new AuraHandledException(' : <<' + e.getStackTraceString() + '>>');
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
            throw new AuraHandledException( ' : <<' + e.getStackTraceString() + '>>');
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

/*----------------------------------------------Interaction Fix End---------------------------------------*/


}