/****************************************************************************************************
** Module Name : Acuity 2.0 - Acuity
** Description : Used to handle Theme Team on Theme record page Acuity 2.0.
** Throws : NA
** Calls : NA
** Organization : Navatar Group
** Product Name & Version : Acuity 2.0
** Revision History:-
** Version    Date(YYYY-MM-DD)    Author         Description of Action
** 1.0        2022-11-30          Virendra Kumar
****************************************************************************************************/
public with sharing class NavatarThemeTeamCtrl {
    
    /*
* Purpose : Fetches initial data to be used for further processing
* Input : metadataField1    [Field 1 to process for Theme Relation Section]
*         metadataField2    [Field 2 to process for Theme Relation Section]
* 		   metadataField3    [Field 3 to process for Theme Relation Section]
*         objName           [Object to query data from]
*         whereClause       [Where clause to be used in the SOQL query]
*         recordId          [Record ID of the current record (Theme)]
*         respWrapper       [ResponseWrapper of info to be sent to LWC]
* Returns : Initial data to be used for further processing as a Map<String, sObject>
*/
    @AuraEnabled
    public static ResponseWrapper getThemeTeams(String recordId){
        try {
            List<String> themeTeamList = new List<String>();
            List<ConWrapper> relatedTeamDetails = new List<ConWrapper>();         
            
            ResponseWrapper respWrapper = new ResponseWrapper();       
            
            respWrapper.themeTeamMap = fetchInitInfoToProcess('Acuity_ThemeTeam_Field1', 'Acuity_ThemeTeam_Field2', 'Acuity_ThemeTeam_Field3','navpeII_dev18__Theme_Team__c', '  WHERE ' + 'navpeII_dev18__Theme__c = :recordId', recordId, respWrapper);
            themeTeamList.addAll(respWrapper.themeTeamMap.keySet()); // Returns Theme Team record ids
            respWrapper.themeTeamList = themeTeamList;
            return respWrapper;
        } catch(Exception e) {
            throw new AuraHandledException('Error Occured While Loading Component : <<' + e.getStackTraceString() + '>>');
        }
    }
    
    
    /*
    * Purpose : Fetches initial data to be used for further processing
    * Input : metadataField1    [Field 1 to process for Theme Team Section]
    *         metadataField2    [Field 2 to process for Theme Team Section]
    * 		   metadataField3    [Field 3 to process for Theme Team Section]
    *         objName           [Object to query data from]
    *         whereClause       [Where clause to be used in the SOQL query]
    *         recordId          [Record ID of the current record (Theme)]
    *         respWrapper       [ResponseWrapper of info to be sent to LWC]
    * Returns : Initial data to be used for further processing as a Map<String, sObject>
    */
    public static Map<String, sObject> fetchInitInfoToProcess(String metadataField1, String metadataField2, String metadataField3, String objName, String whereClause, String recordId, ResponseWrapper respWrapper){
        
        String refField = Acuity_Setting__mdt.getInstance(metadataField1).Value__c;
        String fieldStr = refField; 
        if(String.isNotBlank(refField)){
            fieldStr = ', FORMAT(' + refField + ')';
        }
        
        String refField2 = Acuity_Setting__mdt.getInstance(metadataField2).Value__c;
        if(String.isNotBlank(refField) && String.isNotBlank(refField2)){
            fieldStr += ', FORMAT(' + refField2 + ')';
        }
        
        String refField3 = Acuity_Setting__mdt.getInstance(metadataField3).Value__c;
        if(String.isNotBlank(refField) && String.isNotBlank(refField2) && String.isNotBlank(refField3)){
            fieldStr += ', FORMAT(' + refField3 + ')';
        }
        String query = 'SELECT Id' + (String.isBlank(fieldStr) ? '' : fieldStr) + ' FROM ' + objName + whereClause;
        
        return new Map<String, sObject>(Database.query(String.escapeSingleQuotes(query)));
        
    }
    
    /*
    * Purpose : Processes info for Theme Team section
    *         metadataField1   [Field 1 to process for Team Section]
    *         metadataField2   [Field 2 to process for Team Section]
    *         metadataField2   [Field 3 to process for Team Section]
    * Returns : Info to be displayed in Team section as a List<ConWrapper>
    */
    @AuraEnabled
    public static ResponseWrapper processConInfo(Map<String, sObject> themeTeamMap, String metadataField1, String metadataField2, String metadataField3){
        try {
            ResponseWrapper respWrapper = new ResponseWrapper();
            String refField = Acuity_Setting__mdt.getInstance(metadataField1).Value__c;
            String refField2 = Acuity_Setting__mdt.getInstance(metadataField2).Value__c;
            String refField3 = Acuity_Setting__mdt.getInstance(metadataField3).Value__c;
            if(String.isNotBlank(refField)){
                respWrapper.conFieldHeader1 = fetchFieldLabel('User', refField.split('__r.').get(1));
            }
            
            if(String.isNotBlank(refField2)){
                respWrapper.conFieldHeader2 = fetchFieldLabel('User', refField2.split('__r.').get(1));   
            }
            if(String.isNotBlank(refField3)){
                if(refField3.contains('__r.') && refField3.split('__r.').get(1) != 'Name'){
                    respWrapper.conFieldHeader3 = fetchFieldLabel('User', refField3.split('__r.').get(1));    
                }else {
                    respWrapper.conFieldHeader3 = fetchFieldLabel('navpeII_dev18__Theme_Team__c', refField3);
                }
                
            }
            system.debug('refField-->'+refField);
            system.debug('refField2-->'+refField2);
            system.debug('refField3-->'+refField3);
            //}
            List<ConWrapper> conWrapperList = prepareConFinalMap(themeTeamMap, refField, refField2, refField3);
            respWrapper.conInfoWrapper = conWrapperList;
            
            return respWrapper;
            
        } catch (Exception e) {
            throw new AuraHandledException('Error Occured While Loading Component : <<' + e.getStackTraceString() + '>>');
        }
    }
    
    /*
* Purpose : Delete Theme team Record
* Input   : List<Id>           [Ids of Theme team]
* Returns : String				Returns deleted Theme team names
*/
    @AuraEnabled
    public static String deleteSelectedThemeTeam(List<Id> selectedTeamMemIds) {
        try{
            String strObjectApiName = 'navpeII_dev18__Theme_Team__c';
            String query = 'SELECT ';
            query += 'Id, Name FROM ' + strObjectApiName ;
            //Just in case criteria field not specified then it will return all records
            if(!selectedTeamMemIds.isEmpty()){
                query += ' where id IN: selectedTeamMemIds';
            }
            List<SObject> lstRecords = new List<SObject>();
            if(String.isNotBlank(query)) {
                lstRecords = Database.query(String.escapeSingleQuotes(query));  
            }
            String themeTeamMemName = '';
            for(SObject themeTeamRec : lstRecords){
                themeTeamMemName = string.valueOf(themeTeamRec.get('Name'));
            }   
              
            if(Theme_Team__c.sObjectType.getDescribe().isDeletable()){
                delete lstRecords;
            }
            return themeTeamMemName;    
        } 
        catch(Exception e){
            throw new AuraHandledException('Error Occured While Deleting : <<' + e.getStackTraceString() + '>>');
        }
        
    }
    
    public static List<ConWrapper> prepareConFinalMap(Map<String, sObject> themeTeamMap, String refField, String refField2, String refField3){
        
        List<ConWrapper> conInfo = new List<ConWrapper>();
        string recId = '';
        String sObjName='';
        Id recordId;
        for(String themeRelationId : themeTeamMap.keySet()){
            List<String> actIdList = new List<String>();
            List<String> dealIdList = new List<String>();
            ConWrapper conWrapper = new ConWrapper();
            conWrapper.Id = themeRelationId;
            //conWrapper.name = String.valueOf(themeTeamMap.get(themeRelationId).get(refField));
            if(String.isNotBlank(refField)){
                if(refField.contains('__r.')){
                    recId = String.valueOf((themeTeamMap.get(themeRelationId).get(refField.split('__r.').get(0)+'__c')));
                    if(recId != null) {
                        recordId = (Id)recId;
                        sObjName = recordId.getSObjectType().getDescribe().getName();
                        conWrapper.fieldInfo1 = fetchFieldData(sObjName, recordId, refField.split('__r.').get(1));
                    }else {
                        conWrapper.fieldInfo1 = '';
                    }
                    
                }
                else{
                    conWrapper.fieldInfo1 = String.valueOf((themeTeamMap.get(themeRelationId).get(refField)));     
                }
            }
            
            if(String.isNotBlank(refField2)){
                if(refField2.contains('__r.')){
                    recId = String.valueOf((themeTeamMap.get(themeRelationId).get(refField2.split('__r.').get(0)+'__c')));
                    if(recId != null) {
                        recordId = (Id)recId;
                        sObjName = recordId.getSObjectType().getDescribe().getName();
                        conWrapper.fieldInfo2 = fetchFieldData(sObjName, recordId, refField2.split('__r.').get(1));
                    }else {
                        conWrapper.fieldInfo2 = '';
                    }
                }
                else{
                    conWrapper.fieldInfo2 = String.valueOf((themeTeamMap.get(themeRelationId).get(refField2)));     
                }
            }
            if(String.isNotBlank(refField3)){
                if(refField3.contains('__r.')){
                    recId = String.valueOf((themeTeamMap.get(themeRelationId).get(refField3.split('__r.').get(0)+'__c')));
                    if(recId != null) {
                        recordId = (Id)recId;
                        sObjName = recordId.getSObjectType().getDescribe().getName();
                        conWrapper.fieldInfo3 = fetchFieldData(sObjName, recordId, refField3.split('__r.').get(1));
                    }else {
                        conWrapper.fieldInfo3 = '';
                    }
                }
                else{
                    conWrapper.fieldInfo3 = String.valueOf((themeTeamMap.get(themeRelationId).get(refField3)));     
                }
            }
            conInfo.add(conWrapper);
            
        }
        return conInfo;
    }
    
    public static String fetchFieldData(String objectName, String recordId, String fieldName){
        
        String query = 'SELECT Id, ' + fieldName + ' FROM ' + objectName + ' WHERE ID =: recordId';
        if(objectName == 'User') {
            query = query + ' AND IsActive = true';
        }

        List<SObject> sobjRec = Database.query(String.escapeSingleQuotes(query)); 
        if(!sobjRec.isEmpty()) {
            return (String.valueOf(sobjRec[0].get(fieldName)));
        }
        return null;
    }
    
    /*
    * Purpose : Fetches the field label to be displayed as data table column header
    * Input : objName      [Contact]
    *         fieldName    [Field whose label is to be fetched]
    * Returns : Field label as a String
    */
    public static String fetchFieldLabel(String objName, String fieldName){
        return Schema.getGlobalDescribe().get(objName).getDescribe().fields.getMap().get(fieldName.split('\\.')[0].replace('__r','__c')).getDescribe().getLabel();
        
    }
    
    /************************* WRAPPERS : START *************************/
    
    /*
    * Purpose : Wrapper for page load information
    */
    public class ResponseWrapper{
        @AuraEnabled public List<ConWrapper> conInfoWrapper; 
        @AuraEnabled public Map<String, sObject> themeTeamMap;
        @AuraEnabled public List<String> themeTeamList;
        @AuraEnabled public String conFieldHeader1;
        @AuraEnabled public String conFieldHeader2;
        @AuraEnabled public String conFieldHeader3;      
    }
     	
    /*
    * Purpose : Wrapper for Fundraising Contacts Section information
    */
    public class ConWrapper{
        @AuraEnabled public String Id;                   //Record ID
        @AuraEnabled public String fieldInfo1;               //Dynamic field info
        @AuraEnabled public String fieldInfo2;               //Dynamic field info
        @AuraEnabled public String fieldInfo3;               //Dynamic field info
    }
}