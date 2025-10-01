public with sharing class NavatarSendEmailContactsCtrl {
    
    public static string getOrgNamespace()
    {
        String TOKEN_SOBJECT_NAME = 'Theme__c';
        integer indexOfToken = -1;
        String namespsacePrefix = null;
        try
        {
            for( Schema.SObjectType typ : Schema.getGlobalDescribe().values())
            {
                String sobjName = String.valueOf(typ);
                if(sobjName != null)
                {
                    indexOfToken = sobjName.indexOf(TOKEN_SOBJECT_NAME);
                }
                if(indexOfToken != -1)
                {
                    namespsacePrefix = sobjName.substring(0, indexOfToken);
                    break;
                }
            }
        }
        Catch(Exception ex)
        {
            system.debug('Exception in getOrgNamespace function of Class CommonUtility'+ex);
        }
        return namespsacePrefix;
    }

    /* Fetches the namespace & checks for user permissions */
    @AuraEnabled
    public static ResponseWrapper init(String themeId){
        ResponseWrapper response = new ResponseWrapper();
        try{
            String namespacePrefix = getOrgNamespace();
            response.namespacePrefix = namespacePrefix != null ? namespacePrefix : '';
            String query = 'SELECT Id, Name ' +
                           'FROM ' + response.namespacePrefix + 'Theme__c ' +
                           'WHERE Id =: themeId';
            response.miName = (String)Database.query(query)[0].get('Name');

                response.errMsg = null;
        } catch(Exception ex) {
            response.errMsg = ex.getMessage() + ' --> ' + ex.getStackTraceString();
        }
        return response;
    }

    /* Fetches the saved data from config object */
    @AuraEnabled
    public static QueryWrapper fetchNavatarSetupData(String namespacePrefix){
        QueryWrapper queryResponse = new QueryWrapper();
        String DEFAULT_FIELDS_STR = 'Contact:Name:Full Name:String,Contact:Email:Email:Email,Contact:Phone:Business Phone:Phone,' +
                                    namespacePrefix + 'Theme__c:' + namespacePrefix + 'Account_Name__c:Account Name:String,' +
                                    namespacePrefix + 'Theme__c:' + namespacePrefix + 'Status__c:Status:Picklist,' +
                                    namespacePrefix + 'Theme__c:' + namespacePrefix + 'Last_Mass_Email__c:Last Mass Email:Datetime';
        try{
            if(!String.isEmpty(namespacePrefix)){
                String objApiName = namespacePrefix.containsIgnoreCase('pe') ? 'Navatar_Setup__c' : 'Product_Setting__c';
                String query = 'SELECT Id, ' + namespacePrefix + 'Email_Prospect_Setting__c ' +
                               'FROM ' + namespacePrefix + objApiName + ' ' +
                               'WHERE OwnerId = \'' + UserInfo.getUserId() + '\'';
                List<sObject> setup = Database.query(query);

                if(setup != null && setup.size() > 0){
                    if(setup[0].get(namespacePrefix + 'Email_Prospect_Setting__c') != null && setup[0].get(namespacePrefix + 'Email_Prospect_Setting__c') != ''){
                        queryResponse.fieldStr = (String)setup[0].get(namespacePrefix + 'Email_Prospect_Setting__c');
                    } else {
                        queryResponse.fieldStr = DEFAULT_FIELDS_STR;
                    }
                } else {
                    queryResponse.fieldStr = DEFAULT_FIELDS_STR;
                }
                queryResponse.defaultFieldStr = DEFAULT_FIELDS_STR;
                queryResponse.errMsg = null;
            }
        } catch(Exception ex) {
            queryResponse.errMsg = ex.getMessage() + ' --> ' + ex.getStackTraceString();
        }
        return queryResponse;
    }

    /* Fetches the main query data after filtering prospects */
    @AuraEnabled
    public static QueryWrapper fetchMainQueryData(String mainQuery, List<String> existingIdSet){
        QueryWrapper queryResponse = new QueryWrapper();
        try{
            System.debug('mainQuery > '+mainQuery);
            queryResponse.queryResult = new List<sObject>(Database.query(mainQuery));
            queryResponse.errMsg = null;
        } catch(Exception ex) {
            queryResponse.errMsg = ex.getMessage() + ' --> ' + ex.getStackTraceString();
        }
        return queryResponse;
    }

    /*returns the salesforce org limits*/
    @auraEnabled
    public static String getEmailLimit()   
    {
        try
        {
            string emailString='';    
            string endpoint='/services/data/v50.0/limits';
            HttpRequest req = new HttpRequest();
            string domainUrl=URL.getSalesforceBaseUrl().toExternalForm();
            req.setEndpoint(domainUrl+endpoint);
            req.setMethod('GET');  
            String autho ='Bearer '+ getSessionIdFromVFPage();
            req.setHeader('Authorization', autho);
            Http http = new Http();
            HTTPResponse resp = http.send(req);
            return resp.getBody();
        }
        catch(exception e)
        {            
            System.debug('Caught Exception===='+e);
            return null;      
        }       
    }
    
	//to get session id in lwc
    //get session id
    public static String getSessionIdFromVFPage(){
        String content = Page.sessionIdPage.getContent().toString();
        return content.substring(content.indexOf('Session_Id_Start_Here') + 'Session_Id_Start_Here'.length(), content.indexOf('Session_Id_End_Here'));
    }    
    
    //This method is used to call sendEmail batch class.
    @auraEnabled
    public static String sendMassMail(List<String> contactList, String templateId, Boolean bCC_Me_On_One, Boolean use_My_Signature, Boolean Store_as_an_activity){
        Integer emailBatchSize = 200;
        System.debug(contactList);
        //Added new Set<Id>() by Lakshya 20211014 to match SendEmailBatch parameter list
        Database.executeBatch(new NavatarSendEmailBatchCtrl(contactList, new Set<Id>(), templateId, use_My_Signature, Store_as_an_activity, bCC_Me_On_One), emailBatchSize);
        return null;        
    }
    
        /*
    executeQuery1: Used to process Advance Filter Data to create Where Clause
    getqueryjson : - Advance Filter conditions.
    pageName :- Page Name for Advance Filter
    FilterString : -  if Any Filter logic mentioned in Advance Filter
    */
    @auraEnabled
    public static QueryWrapper executeQuery1(string getqueryjson,string pageName,string FilterString){
        QueryWrapper response = new QueryWrapper();
        try{
            response.whereClause = NavatarCommonUtilityCtrl.executeQuery1(getqueryjson,pageName,FilterString);
            response.errMsg = null;
        }catch(Exception Ex){
            response.errMsg = Ex.getMessage()+' - '+Ex.getStackTraceString();
        }
        return response;
    }
    
    public class ResponseWrapper{
        @AuraEnabled public String namespacePrefix;             // Stores the namespace prefix
        @AuraEnabled public String errMsg;                      // Stores the error message
        @AuraEnabled public String miName;                      // Stores the current marketing initiative's name
    }

    public class QueryWrapper{
        @AuraEnabled public List<sObject> queryResult;  // Stores the queried data
        @AuraEnabled public String whereClause;         // Stores the where clause of the main query
        @AuraEnabled public String fieldStr;            // Stores the current fields info as a string
        @AuraEnabled public String defaultFieldStr;     // Stores the default fields info as a string
        @AuraEnabled public String errMsg;              // Stores the error message
    }
}