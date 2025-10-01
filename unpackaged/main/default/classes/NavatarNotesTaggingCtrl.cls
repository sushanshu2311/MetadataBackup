/****************************************************************************************************
** Module Name : Acuity 2.0 - Notes Tagging
** Description : Used to handle the Phase 2 Notes Tagging Quick Create Functionality.
** Throws : NA
** Calls : NA
** Organization : Navatar Group
** Product Name & Version : Acuity 1.0
** Revision History:-
** Version    Date(YYYY-MM-DD)    Author         Description of Action
** 1.0        2022-11-17          Yash           Initial Version
****************************************************************************************************/
public with sharing class NavatarNotesTaggingCtrl {
    public static final String SAVE_ERR_MSG = 'Error Occured While Saving Files';
    /*
     * Purpose : Returns the Firm Record Types available for User
     * Input :   
     * Returns : RecordTypeOptionWrapper List
*/
    @AuraEnabled
    public static List<RecordTypeOptionWrapper> getUserAvailableAccountRecordTypes() {
        try{
            Schema.DescribeSObjectResult objectInfo = Account.SObjectType.getDescribe();
            List<RecordTypeOptionWrapper> recTypeOptions = new List<RecordTypeOptionWrapper>();
            List<Schema.RecordTypeInfo> recordTypes = objectInfo.getRecordTypeInfos();
            for(RecordTypeInfo recType : recordTypes) {
                if(recType.isAvailable()) {
                    //Critical fix Nikita S
                    if(recType.isAvailable() && recType.getName() != 'Master'){
                    recTypeOptions.add(
                        new RecordTypeOptionWrapper(recType.getName(), recType.getRecordTypeId(), recType.isDefaultRecordTypeMapping())
                    );
                    }
                }
            }
            return recTypeOptions;
            
        }catch(Exception ex) {
            throw new AuraHandledException(NavatarConstants.ACCOUNT_REC_TYPE_ERROR_MSG+ex.getMessage());
        }
        
    }
/*
     * Purpose : Recor type options Wrapper to return the record type name, id and if record type is default.
*/   
    public class RecordTypeOptionWrapper {
        @AuraEnabled
        public String recTypeLabel{get; private set;}
        @AuraEnabled
        public String recTypeId{get; private Set;}
        @AuraEnabled
        public Boolean isDefaultRecordType{get; private Set;}
        public RecordTypeOptionWrapper(String recTypeLabel, String recTypeId, Boolean isDefaultRecordType) {
            this.recTypeLabel = recTypeLabel;
            this.recTypeId = recTypeId;
            this.isDefaultRecordType = isDefaultRecordType;
        }
    }
    
/*
     * Purpose : Request Wrapper of Quick create records coming from LWC.
*/   

    public class QuickRequestWrapper {
        @AuraEnabled
        public Integer index{get;set;}
        @AuraEnabled
        public String name{get;set;}
        @AuraEnabled
        public String objectType{get;set;}
        @AuraEnabled
        public String accountRecType{get;set;}
        @AuraEnabled
        public String accountId{get;set;}
        @AuraEnabled
        public String searchAccountText{get;set;}
    }
/*
     * Purpose : Creates the Accopunt and Contact Records
     * Input :   a serialize JSON structure of type QuickRequestWrapper
     * Returns : ResponseWrapper
*/

    @AuraEnabled
    public static ResponseWrapper createAccountContactRecords(String jsonCreateString) {
        ResponseWrapper responseObject = new ResponseWrapper();
        Savepoint sp = Database.setSavepoint();
        try{
            Map<Integer, Account> newAccountIndexMap = new Map<Integer, Account>();
            List<String> searchAccountsList = new List<String>();
            Map<Integer, QuickRequestWrapper> requestContactIndexMap = new Map<Integer, QuickRequestWrapper>();
            if(String.isNotBlank(jsonCreateString)) {
                List<QuickRequestWrapper> requestWrapperList = 
                    (List<QuickRequestWrapper>) JSON.deserialize(jsonCreateString, List<QuickRequestWrapper>.class);
                for(QuickRequestWrapper requestObj : requestWrapperList) {
                    if(requestObj.objectType == NavatarConstants.ACCOUNT_API_NAME) {
                        Account associatedAccount = returnAccountInstance(requestObj.name);
                        associatedAccount.RecordTypeId = requestObj.accountRecType;
                        newAccountIndexMap.put(requestObj.index, associatedAccount);
                    }
                    else if(requestObj.objectType == NavatarConstants.CONTACT_API_NAME){
                        requestContactIndexMap.put(requestObj.index, requestObj);
                        searchAccountsList.add(requestObj.searchAccountText);
                    }
                }
                List<SuccessResponseWrapper> sucessWrapperList = new List<SuccessResponseWrapper>();
                List<ErrorResponseWrapper> errorWrapperList = new List<ErrorResponseWrapper>();
                if(Schema.sObjectType.Account.isCreateable()) {
                    insert newAccountIndexMap.values();
                }
                
                for(Account acc : newAccountIndexMap.values()) {
                    SuccessResponseWrapper sucessRecord = new SuccessResponseWrapper();
                    sucessRecord.objectType = NavatarConstants.ACCOUNT_API_NAME;
                    sucessRecord.successRecordId = acc.Id;
                    sucessRecord.successRecordName = acc.Name;
                    sucessWrapperList.add(sucessRecord);

                }
                if(!requestContactIndexMap.isEmpty()) {
                    List<Contact> contacts = quickCreateContactRecords(requestContactIndexMap, searchAccountsList);
                    List<Database.SaveResult> saveContactResult = new List<Database.SaveResult>();
                    if(Schema.sObjectType.Contact.isCreateable()) {
                        saveContactResult = Database.insert(contacts, false);
                    }
                    set<Id> successContactRecordsId = new Set<Id>();
                    for(Database.SaveResult sr : saveContactResult) {
                        if(sr.isSuccess()) {
                            successContactRecordsId.add(sr.getId());
                        }
                        else {
                            errorWrapperList.add(new ErrorResponseWrapper('Error in Saving Record','Error'));
                        }
                    }
                    if(!successContactRecordsId.isEmpty()) {
                        List<Contact> newInsertedAccount = [SELECT Id, Name from Contact WHERE Id IN :successContactRecordsId];
                        for(Contact contact : newInsertedAccount) {
                            SuccessResponseWrapper sucessRecord = new SuccessResponseWrapper();
                            sucessRecord.objectType = NavatarConstants.CONTACT_API_NAME;
                            sucessRecord.successRecordId = contact.Id;
                            sucessRecord.successRecordName = contact.Name;
                            sucessWrapperList.add(sucessRecord);
                        }
                    }

                }
                responseObject.successRecords = sucessWrapperList;
                responseObject.errorObject = errorWrapperList;
            }
        }catch(Exception ex) {
            Database.rollback(sp);
            ErrorResponseWrapper errorObj = new ErrorResponseWrapper(ex.getMessage(), 'Error in creating Records');
            responseObject.errorObject = new List<ErrorResponseWrapper>{errorObj};
            responseObject.isError = true;
        }
        return responseObject;
    }
/*
     * Purpose : Creates the Contact Instances according to scenarios 
     * Input :   List of contact
     * Returns : Map<Integer, QuickRequestWrapper>
*/

    private static List<Contact> quickCreateContactRecords(
        Map<Integer, QuickRequestWrapper> requestContactIndexMap,
        List<String> searchAccountsList
    ) {
        Map<String, Account> accountNameMap = new Map<String, Account>();
        String dummyAccountId = getDummyAccountId();
        if(!searchAccountsList.isEmpty()) {
            accountNameMap = getAllSearchedAccounts(searchAccountsList);
        }
        Map<Integer, Account> accountIndexMap = new Map<Integer, Account>();
        Map<Integer, Contact> contactIndexMap = new Map<Integer, Contact>();
        for(Integer index : requestContactIndexMap.keySet()) {
            QuickRequestWrapper requestObj = requestContactIndexMap.get(index);
            Contact contactRec = new Contact();
            
            if(String.isNotBlank(requestObj.accountId)) {
                if(checkCreateableFields(Schema.getGlobalDescribe().get('Contact'),
            new List<String>{'AccountId','LastName'})){
                contactRec.AccountId = requestObj.accountId;
                contactRec.LastName = requestObj.name;
            }
            }
            else if(String.isBlank(requestObj.accountId) && String.isBlank(requestObj.searchAccountText)) {
                if(checkCreateableFields(Schema.getGlobalDescribe().get('Contact'),
            new List<String>{'AccountId','LastName'})){
                contactRec.AccountId = dummyAccountId;
                contactRec.LastName = requestObj.name;
            }
            }
            else if(String.isBlank(requestObj.accountId) && String.isNotBlank(requestObj.searchAccountText)) {
                if(checkCreateableFields(Schema.getGlobalDescribe().get('Contact'),
            new List<String>{'AccountId','LastName'})){
                contactRec.LastName = requestObj.name;
                contactRec.AccountId = (accountNameMap.containsKey(requestObj.searchAccountText)) ? accountNameMap.get(requestObj.searchAccountText).Id : null;
                if(!accountNameMap.containsKey(requestObj.searchAccountText)) {
                    Account acc = returnAccountInstance(requestObj.searchAccountText);
                    accountIndexMap.put(index, acc);
                }
            }
            }
            contactIndexMap.put(index, contactRec);
        }

        if(!accountIndexMap.isEmpty()) {
            insert accountIndexMap.values();
            for(Integer accMapIndex : accountIndexMap.keySet()) {
                Contact associatedContact = contactIndexMap.get(accMapIndex);
                associatedContact.AccountId = accountIndexMap.get(accMapIndex).Id;
                contactIndexMap.put(accMapIndex, associatedContact);
            }
        }

        return contactIndexMap.values();
    }
/*
     * Purpose : Search on all Accounts related with Name 
     * Input :   List of Name strings
     * Returns : Map of Name and Account
*/

    private static Map<String, Account> getAllSearchedAccounts(List<String> searchAccountList) {
        Map<String, Account> accountMap = new Map<String, Account>();
        List<Account> accounts = [SELECT Id, Name from Account WHERE Name IN : searchAccountList];
        for(Account acc : accounts) {
            accountMap.put(acc.Name, acc);
        }
        return accountMap;
    }
/*
     * Purpose : returns DUmmy Account Id 
     * Input :   
     * Returns : String of Account Id
*/
    
    private static String getDummyAccountId() {
        List<Account> dummyAccount = [SELECT Id, Name from ACCOUNT where Name LIKE '%Dummy Account%' WITH USER_MODE LIMIT 1 ];
        if(!dummyAccount.isEmpty()) {
            return dummyAccount[0].Id;
        }
        else {
            return createAndReturnDummmyAccountId();
        }
    }
/*
     * Purpose : Creates DUmmy Account Record if not Present
     * Input :   
     * Returns : New created Account Id
*/
    
    private static String createAndReturnDummmyAccountId() {
        Account newDummyAccount = returnAccountInstance(NavatarConstants.DUMMY_ACCOUNT_NAME);
        if(Schema.sObjectType.Account.isCreateable()) {
            insert newDummyAccount;
        }
        
        return newDummyAccount.Id;
    }
/*
     * Purpose : Creates and Return Account Instances
     * Input :   Account Name
     * Returns : Account Instance
*/
    
    private static Account returnAccountInstance(String accName) {
        Account newAccount = new Account();
        if(checkCreateableFields(Schema.getGlobalDescribe().get('Account'),
        new List<String>{'Name'})){
            newAccount.Name = accName;
        }
        return newAccount;
    }
/*
     * Purpose : Success Wrapper for NewlyCreatedRecords.
*/   

    public class SuccessResponseWrapper {
        @AuraEnabled
        public String objectType{get;set;}
        @AuraEnabled
        public String successRecordId{get; set;}
        @AuraEnabled
        public String successRecordName{get; set;}
    }
/*
     * Purpose : Error Wrapper for NewlyCreatedRecords.
*/   

    public class ErrorResponseWrapper {
        @AuraEnabled
        public String errorMessage{get;set;}
        @AuraEnabled
        public String errorTitle{get; set;}
        public ErrorResponseWrapper(String errorMessage, String errorTitle) {
            this.errorMessage = errorMessage;
            this.errorTitle = errorTitle;
        }
    }
/*
     * Purpose : Response Wrapper returning for for NewlyCreatedRecords.
*/ 
    public class ResponseWrapper {
        @AuraENabled
        public Boolean isError{get;set;}
        @AuraENabled
        public List<SuccessResponseWrapper> successRecords{get; set;}
        @AuraENabled
        public List<ErrorResponseWrapper> errorObject{get; set;}
        public ResponseWrapper() {
            isError = false;
            successRecords = new List<SuccessResponseWrapper>();
            errorObject = new List<ErrorResponseWrapper>();
        }
    }
/*
     * Purpose : Returns all Contacts Information for Deal team and Fund Team creation 
     * Input :   List of Contact Ids
     * Returns : String of Account Id
*/
    
    
    @AuraEnabled
    public static List<TeamMappingWrapper> getRelatedContactsDetails(List<String> contactIds) {
        try{
            List<TeamMappingWrapper> teamWrapperList = new List<TeamMappingWrapper>();
            if(!contactIds.isEmpty()) {
                List<Contact> contacts = [SELECT Id, Name, Account.Name, AccountId  from Contact WHERE Id IN : contactIds];
                Integer index = 0;
                for(Contact conRec : contacts) {
                    TeamMappingWrapper newWrapperRecord = new TeamMappingWrapper();
                    newWrapperRecord.index = index;
                    newWrapperRecord.conId = conRec.Id;
                    newWrapperRecord.conName = conRec.Name;
                    newWrapperRecord.accName = conRec.Account.Name;
                    newWrapperRecord.isSelected = false;
                    newWrapperRecord.role = '';
                    teamWrapperList.add(newWrapperRecord);
                    index++;
                }
                
            }
            return teamWrapperList;
            
        }catch(Exception ex) {
            throw new AuraHandledException(NavatarConstants.DEAL_TEAM_CREATE_ERROR_MSG+ex.getMessage());
        }
        
    } 
/*
     * Purpose : Returns all Contacts Information for Deal team and Fund Team creation 
     * Input :   List of Contact Ids
     * Returns : String of Account Id
*/
    
    @AuraEnabled
    public static void createDealTeamRecords(String dealJSONString, List<String> dealRecordsId) {
        try{
            if(String.isNotBlank(dealJSONString)) {
                List<TeamMappingWrapper> contactWrapperList = 
                    (List<TeamMappingWrapper>)JSON.deserialize(dealJSONString, List<TeamMappingWrapper>.class);
                Map<String, TeamMappingWrapper> contactTeamWrapperMap = new Map<String, TeamMappingWrapper>();
                for(TeamMappingWrapper wrapper : contactWrapperList) {
                    contactTeamWrapperMap.put(wrapper.conId, wrapper);
                }
                Map<String, List<String>> dealsExistingContactMap = new Map<String,List<String>>();
                for(navpeII_dev18__Deal_Team__c dealTeam : getExistingDealTeamMembers(dealRecordsId)) {
                    if(!dealsExistingContactMap.containsKey(dealTeam.navpeII_dev18__Deal__c)) {
                        dealsExistingContactMap.put(dealTeam.navpeII_dev18__Deal__c, new List<String>());
                    }
                    dealsExistingContactMap.get(dealTeam.navpeII_dev18__Deal__c).add(dealTeam.navpeII_dev18__Deal_Contact__c);
                    
                }
                List<navpeII_dev18__Deal_Team__c> newTeamList = new List<navpeII_dev18__Deal_Team__c>();
                for(String dealId : dealRecordsId) {
                    List<String> associatedTeamContactsIds = new List<String>();
                    if(dealsExistingContactMap.containsKey(dealId)) {
                        associatedTeamContactsIds = dealsExistingContactMap.get(dealId);
                    }
                    for(String contactId : contactTeamWrapperMap.keySet()) {
                        if((!associatedTeamContactsIds.isEmpty() && !associatedTeamContactsIds.contains(contactId)) || associatedTeamContactsIds.isEmpty()
                        && checkCreateableFields(Schema.getGlobalDescribe().get('navpeII_dev18__Deal_Team__c'),
                        new List<String>{'navpeII_dev18__Deal__c','navpeII_dev18__Deal_Contact__c','navpeII_dev18__Team_Member_Role__c'})) {
                            navpeII_dev18__Deal_Team__c dealTeamRec = new navpeII_dev18__Deal_Team__c();
                            dealTeamRec.navpeII_dev18__Deal__c = dealId;
                            dealTeamRec.navpeII_dev18__Deal_Contact__c = contactId;
                            dealTeamRec.navpeII_dev18__Team_Member_Role__c = contactTeamWrapperMap.get(contactId).role;
                            newTeamList.add(dealTeamRec);
                        }
                    }
                }
                if(!newTeamList.isEmpty() && Schema.getGlobalDescribe().get('navpeII_dev18__Deal_Team__c').getDescribe().isCreateable()) {
                    insert newTeamList;
                }
            }
        }catch(Exception ex) {
            throw new AuraHandledException(NavatarConstants.DEAL_TEAM_CREATE_ERROR_MSG+ex.getMessage());
        }
        
    }
/*
     * Purpose : Returns all Contacts Information for Deal team and Fund Team creation 
     * Input :   List of Contact Ids
     * Returns : String of Account Id
*/
    
    @AuraEnabled
    public static void createFundTeamRecords(String fundJSONString, List<String> fundRecordIds) {
        try{
            if(String.isNotBlank(fundJSONString)) {
                List<TeamMappingWrapper> contactWrapperList = 
                    (List<TeamMappingWrapper>)JSON.deserialize(fundJSONString, List<TeamMappingWrapper>.class);
                Map<String, TeamMappingWrapper> contactTeamWrapperMap = new Map<String, TeamMappingWrapper>();
                for(TeamMappingWrapper wrapper : contactWrapperList) {
                    contactTeamWrapperMap.put(wrapper.conId, wrapper);
                }
                Map<String, List<String>> fundExistingContactMap = new Map<String,List<String>>();
                for(navpeII_dev18__Fundraising_Contact__c fundTeam : getExistingFundTeamMembers(fundRecordIds)) {
                    if(!fundExistingContactMap.containsKey(fundTeam.navpeII_dev18__Fundraising__c)) {
                        fundExistingContactMap.put(fundTeam.navpeII_dev18__Fundraising__c, new List<String>());
                    }
                    fundExistingContactMap.get(fundTeam.navpeII_dev18__Fundraising__c).add(fundTeam.navpeII_dev18__Contact__c);
                    
                }
                List<navpeII_dev18__Fundraising_Contact__c> newTeamList = new List<navpeII_dev18__Fundraising_Contact__c>();
                for(String fundId : fundRecordIds) {
                    List<String> associatedTeamContactsIds = new List<String>();
                    if(fundExistingContactMap.containsKey(fundId)) {
                        associatedTeamContactsIds = fundExistingContactMap.get(fundId);
                    }
                    for(String contactId : contactTeamWrapperMap.keySet()) {
                        if((!associatedTeamContactsIds.isEmpty() && !associatedTeamContactsIds.contains(contactId)) || associatedTeamContactsIds.isEmpty()
                        && checkCreateableFields(Schema.getGlobalDescribe().get('navpeII_dev18__Fundraising_Contact__c'),
                        new List<String>{'navpeII_dev18__Fundraising__c','navpeII_dev18__Contact__c','navpeII_dev18__Role__c'})) {
                            navpeII_dev18__Fundraising_Contact__c fundTeamRec = new navpeII_dev18__Fundraising_Contact__c();
                            fundTeamRec.navpeII_dev18__Fundraising__c = fundId;
                            fundTeamRec.navpeII_dev18__Contact__c = contactId;
                            fundTeamRec.navpeII_dev18__Role__c = contactTeamWrapperMap.get(contactId).role;
                            newTeamList.add(fundTeamRec);
                        }
                    }
                }
                if(!newTeamList.isEmpty() && Schema.getGlobalDescribe().get('navpeII_dev18__Fundraising_Contact__c').getDescribe().isCreateable()) {
                    insert newTeamList;
                }
            }
        }catch(Exception ex) {
            throw new AuraHandledException(NavatarConstants.DEAL_TEAM_CREATE_ERROR_MSG+ex.getMessage());
        }
    }
/*
     * Purpose : Returns all DealTeamContacts Information for Deal team creation 
     * Input :   List of Deal Ids
     * Returns : List of Deal Team 
*/
    @TestVisible
    private static List<navpeII_dev18__Deal_Team__c> getExistingDealTeamMembers(List<String> dealRecordIds) {
        return [SELECT Id,navpeII_dev18__Deal_Contact__c, navpeII_dev18__Deal__c from navpeII_dev18__Deal_Team__c WHERE navpeII_dev18__Deal__c IN: dealRecordIds WITH USER_MODE];
    }
/*
     * Purpose : Returns all FundRaising COntacts  Information for Fund Team creation 
     * Input :   List of Fund Ids
     * Returns : List of Fund raising Contacts
*/
    
    private static List<navpeII_dev18__Fundraising_Contact__c> getExistingFundTeamMembers(List<String> fundRecordIds) {
        return [SELECT Id,navpeII_dev18__Contact__c, navpeII_dev18__Fundraising__c from navpeII_dev18__Fundraising_Contact__c WHERE navpeII_dev18__Fundraising__c IN: fundRecordIds WITH USER_MODE];
    }
    
/*
     * Purpose : TeamMappingWrapper Wrapper returning for for Deal and Fund Team Create.
*/
    
    public class TeamMappingWrapper {
        @AuraENabled
        public Integer index;
        @AuraENabled
        public String conId;
        @AuraENabled
        public String conName;
        @AuraENabled
        public String accName;
        @AuraENabled
        public Boolean isSelected;
        @AuraENabled
        public String role;
        
    }
    
    @AuraENabled
    public static List<SObject> getActivityData(String activityId, String objectName) {
        try{
            String recordId = activityId;
            ////added code for Security Fix checking Updateable:started
            String activityFields=checkAccessableFields(Schema.getGlobalDescribe().get(objectName),'CreatedDate,ActivityDate,CreatedById');
            activityFields=activityFields.replace('CreatedById','CreatedBy.Name');
            //Bug #00039983:started
            String updatedActivityFields='';
            for(String s:activityFields.removeEnd(',').split(',')){
                if(s.containsIgnoreCase('date')){
                    updatedActivityFields+='FORMAT('+s+'),';
                }
                else
                updatedActivityFields+=s+',';
            }
            //Bug #00039983:ended
            // Rich text functionality
            // Bug 00047559 Fixed by Sudhanshu
            String queryString = 'SELECT ID,Description,Owner.Name '+updatedActivityFields.removeEnd(',')+' from '+String.escapeSingleQuotes(objectName)+' WHERE ID=\''+String.escapeSingleQuotes(activityId)+'\'';
            ////added code for Security Fix checking Updateable:ended
            system.debug('query '+queryString);
            List<sObject> objectRecord = Database.query(queryString);
            return objectRecord;            
        }catch(Exception ex) {
            system.debug('ex '+ex.getLineNumber());
            throw new AuraHandledException(SAVE_ERR_MSG + ' : <<' + ex.getStackTraceString() + '>>');
            //return null;            
        }
    }
/*
 * File Save Wrapper
*/
    
    public class FileWrapper {
        @AuraEnabled
        public String recordId;
        @AuraEnabled
        public Integer index;
        @AuraEnabled
        public STring filename;
        @AuraEnabled
        public String base64;
    }
/*
     * Purpose : To save file records for an Activity
     * Input :   File data, Activity Id
     * Returns : Null
*/
    
    @AuraEnabled
    public static void saveFilesData(String fileJsonString, String activityId) {
        try {
            Map<Integer, ContentVersion> fileDataMap = new Map<Integer, ContentVersion>();
            List<String> fieldsToInsert=new List<String>();
            List<ContentDocumentLink > cdlList = new List<ContentDocumentLink>();
            if(String.isNotBlank(fileJsonString)) {
                List<FileWrapper> fileWrapperList = 
                    (List<FileWrapper>) JSON.deserialize(fileJsonString, List<FileWrapper>.class);
                for(FileWrapper file : fileWrapperList) {
                    COntentVersion cv = new ContentVersion();
                    cv.VersionData = EncodingUtil.base64Decode(file.base64);
                    cv.Title = file.filename;
                    cv.PathOnClient = file.filename;
                    fileDataMap.put(file.index, cv);
                }
                
                if(!fileDataMap.isEmpty()) {
                    insert fileDataMap.values();
                    Map<Integer, String> versionIdMap = new Map<Integer, String>();
                    Map<String, String> versionIdContentIdMap = new Map<String, String>();
                    for(Integer indexVar : fileDataMap.keySet()) {
                        versionIdMap.put(indexVar, fileDataMap.get(indexVar).Id);
                    }
                    for(ContentVersion cv: [SELECT Id, ContentDocumentId from ContentVersion Where ID IN:versionIdMap.values() WITH USER_MODE]) {
                        versionIdContentIdMap.put(cv.Id, cv.ContentDocumentId);
                    }
                    for(Integer indexVar : fileDataMap.keySet()) {
                        ContentVersion cv= fileDataMap.get(indexVar);
                        fieldsToInsert.add('ContentDocumentId');
                        fieldsToInsert.add('LinkedEntityId');
                        fieldsToInsert.add('ShareType');
                        cdlList.add(new ContentDocumentLink(
                            ContentDocumentId = versionIdContentIdMap.get(versionIdMap.get(indexVar)),
                            LinkedEntityId = activityId,
                            ShareType = 'V'
                        ));
                        
                    }
                    if(!cdlList.isEmpty() && Schema.getGlobalDescribe().get('ContentDocumentLink').getDescribe().isCreateable() 
                    && checkCreateableFields(Schema.getGlobalDescribe().get('ContentDocumentLink'),fieldsToInsert)) {
                        insert cdlList;
                    }
                    
                }
            }
        }catch(Exception ex) {
            system.debug('exception '+ex.getMessage()+' '+ex.getLineNumber());
            throw new AuraHandledException(SAVE_ERR_MSG + ' : <<' + ex.getStackTraceString() + '>>');
        }
    }
    private static Boolean checkCreateableFields(Schema.SObjectType objectType, List<String> fieldNames) {
        Map<String, Schema.SobjectField> fields = objectType.getDescribe().fields.getMap();
        //System.debug('Before: '+fieldNames);
        for (String s : fieldNames.clone() ) {
            //System.debug(fields.keySet());
            if ((fields.get(s.toLowerCase()).getDescribe().isCreateable()) ) {
                //System.debug(s+' '+fieldNames);
                fieldNames.remove(fieldNames.indexOf(s));
            }
        }
        //System.debug('After: '+fieldNames);
        if(fieldNames.size()>0)
            return false;
        else
            return true;
    }
    private static String checkAccessableFields(Schema.SObjectType objectType, String fieldNames) {
        Map<String, Schema.SobjectField> fields = objectType.getDescribe().fields.getMap();
        String accessableFields='';
        for (String s : fieldNames.split(',') ) {
            if ((fields.get(s.toLowerCase()).getDescribe().isAccessible()) ) {
                accessableFields+=','+s;
            }
        }
        return accessableFields;
    }
}