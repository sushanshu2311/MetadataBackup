/*************************************************
********************************
** Module Name : CommonUtility
** Description : Listed Below
    1. Making sObject Describe Calls and return Field Labels with API Names.
    2. Create sObject Icon URL, and return sObjectVsIconURL.
    3. Get & return NameSpace from Org.
** Throws : NA
** Calls : NA
** Test Class :  Not yet**
** Organization : Navatar Group
** Product Name & Version : PE 3.5
** Revision History:-
** Version Date         Author 
** 3.5     06/06/2016   Faiz Ahmed 
*************************************************
********************************/

public with sharing class CommonUtility
{
    public static string strNameSpacePrefix = getorgnamespace();
    public static string strOrgNameSpacePrefix = getLoggedInOrgNameSpace();
    public static boolean isPipelineTrigerRun = true;    
    public static string oldAccountPiplineFieldName = 'Company_Name__c'; //Added property for old field API(MasterLookup)  in PE v4.5 By Rahulk 
    public static string newAccountPiplineFieldName = 'Company__c';//Added property for new field API(Lookup)  in PE v4.5 By Rahulk

    public CommonUtility(){}
    /*
    @Description: This Method takes list of sObject as a parameter, & return MAP of FieldApiVsFieldName.
    @Parameter1: List of String type (sObject API Name), which contains name of sObject.
    */
    public static Map<string, string> describeSObject(List<String> lstsObject)
    {
        Map<string, string> FieldLabelVsApi = new Map<string, string>();
        
        try
        {
            for(string objName : lstsObject)
            {
                List<Schema.DescribeSObjectResult> describeSobjectsResult = Schema.describeSObjects(new List<String>{objName }); // this can accept list of strings, we describe only one object here
                
                String objectLabel = describeSobjectsResult[0].getLabel();
                
                Map <String, Schema.SObjectField> fieldMap = new Map <String, Schema.SObjectField>();
                fieldMap = Schema.getGlobalDescribe().get(objName).getDescribe().fields.getMap();
                for(Schema.SObjectField sField : fieldMap.Values()) 
                {
                    schema.DescribeFieldResult dField = sField.getDescribe();
                    
                    if(dField.isUpdateable() && dField.isAccessible())
                    {
                       String fieldApiNameLower = dfield.getName(); //Code added by Sachin Kumar 28-Sept-2016
                       fieldApiNameLower = fieldApiNameLower.toLowerCase();
                     
                       if(dField.isHtmlFormatted() !=true)
                          FieldLabelVsApi.put(objName+':'+fieldApiNameLower, objectLabel +':'+dfield.getLabel());
                    }                       
                }
            }
        }
        Catch(Exception ex)
        {
            string errormsgget = ex.getMessage();
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,errormsgget));
        }
        return FieldLabelVsApi;
    }
    

    /*
    @Description: This Method takes list of sObject as a parameter, & return MAP of sObjectNameVsIconURL.
    @Parameter1: List of String type (sObject API Name), which contains name of sObject.
    */
    public static Map<string, string> describeSFTabs(List<String> sObjList)
    {
        Map<string, string> sObjNameVsIconURL = new Map<string, string>();
        try
        {
            List<Schema.DescribeTabSetResult> tabSetDesc = Schema.describeTabs();
            for(DescribeTabSetResult tsr : tabSetDesc) 
            {
                //if( tsr.getLabel() == 'Sales' )
              
                List<Schema.DescribeTabResult> tabDesc = tsr.getTabs();
                map<string ,string> mapSobjectTab = new map<string ,string>();
                
                for(Schema.DescribeTabResult tr : tabDesc) 
                {
                    mapSobjectTab.put(tr.getSobjectName().toLowerCase(),tr.getIconUrl());
                }                   
                
                for(string objName : sObjList)
                {
                    if(mapSobjectTab.keySet().contains(objName.toLowerCase())){                     
                        sObjNameVsIconURL.put(objName, mapSobjectTab.get(objName.toLowerCase()));                           
                    }                   
                }
               
            }
        }
        Catch(Exception ex)
        {
            string errormsgget = ex.getMessage();
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,errormsgget));
        }
        return sObjNameVsIconURL;
    }

    /*
    @Description: This Method return NameSpace of the current org dynamically.
    */
    public static string getOrgNamespace()
    {
        String TOKEN_SOBJECT_NAME = 'Partnership__c';
        integer indexOfToken = -1;
        String namespsacePrefix = null;
        try
        {
            for( Schema.SObjectType typ : Schema.getGlobalDescribe().values() )
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
            string errormsgget = ex.getMessage();
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,errormsgget));
        }
        return namespsacePrefix;
    }  
    
    /*
    @Description: This Method returns FieldAPIName as a key and FieldDataType as a value.
    @Paramtere: List of String type (sObject API Name), which contains name of sObject.
    */
    public static Map<string, string> getFieldNameVsDataType(List<String> lstsObject)
    {
        try
        {
            Map<string, string> FieldApiNameVsDataType = new Map<string, string>(); 
            for(string objName : lstsObject)
            {
                List<Schema.DescribeSObjectResult> describeSobjectsResult = Schema.describeSObjects(new List<String>{objName}); // this can accept list of strings, we describe only one object here
                String objectLabel = describeSobjectsResult[0].getLabel();
                Map <String, Schema.SObjectField> fieldMap = new Map <String, Schema.SObjectField>();
                fieldMap = Schema.getGlobalDescribe().get(objName).getDescribe().fields.getMap();
                for(Schema.SObjectField sField : fieldMap.Values()) 
                {
                    schema.DescribeFieldResult dField = sField.getDescribe();
                    if(dField.isUpdateable() && dField.isAccessible())
                        FieldApiNameVsDataType.put(objName, dfield.getName());
                    
                }
            }
            return FieldApiNameVsDataType;
        }
        Catch(Exception ex)
        {
            string errormsgget = ex.getMessage();
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,errormsgget));
            return null;
        }
    }
    
    /*
        @Description: This Method return Org NameSpace of the current org dynamically.
    */
    public static string getLoggedInOrgNameSpace() {
        String strOrgNamespace = '';
        try
        {
            if([SELECT NamespacePrefix FROM Organization Limit 1].NamespacePrefix != null){ //(PE3.5, SK, 16Aug2017): added limit clause
                strOrgNamespace = [SELECT NamespacePrefix FROM Organization Limit 1].NamespacePrefix+'__'; //(PE3.5, SK, 16Aug2017): added limit clause
            }               
        }
        Catch(Exception ex)
        {
           string errormsgget = ex.getMessage();
           ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,errormsgget));
        }
        return strOrgNamespace;
    }
    
    
    // HTML Encode the special characters
    public Static String replaceChars(String strToChange)
    {          
        try
        {
            if(strToChange!='' && strToChange!=null)
            {               
                return strToChange.Replace('\r',' ').replace('"','&#34;').replace('<','&#60;').replace('>','&#62;').replace('\'','&#39;').replace(',','&#44;').replace('-','&#45;').replace('/','&#47;').replace('\\','&#92;').replace('^','&#94;').replace('_','&#95;').replace('`','&#96;').replace('~','&#126;').replace('<br>','').replace('<?', '&#60;&#63;').replace('!', '&#33;').replace('\n',' ').replace('$','&#36;');
            }
            else
                return null;
        }
        catch(Exception ex)
        {
            string errormsgget = ex.getMessage();
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,errormsgget));
            return null;            
        } 
    }
    
    //Fixing for instance name - Sheetal Dagar   
    public static string strServerURL(){
        String ServerUrl='';        
        string nameSpacePrefix='c.';        
        String currPage = ApexPages.currentPage().getURL();
        Organization org = [SELECT InstanceName FROM Organization where id = :userinfo.getOrganizationId() limit 1];
        
        ApexClass cs =[select NamespacePrefix from ApexClass where Name =:'clsPEFundNothingEnabled'];
        if(cs.NamespacePrefix!=null)
            nameSpacePrefix= cs.NamespacePrefix +'.';
        
        if(org != null && String.isNotBlank(org.InstanceName) && String.isNotBlank(currPage))
        {
             ServerUrl=nameSpacePrefix+org.InstanceName.toLowerCase()+'.visual.force.com';
        }
        return ServerUrl;
    }

    /*
     * Method Name:- chkmasterLookupInPiplineAPI
     * @Description: This Method return Current API name (beetween Account and Piplline relationship) of the current org dynamically.
     * Version:- PE v4.5
     */
    public static String  chkmasterLookupInPiplineAPI()
    {

        if(Schema.getGlobalDescribe().get(strNameSpacePrefix+'Pipeline__c').getDescribe().fields.getMap().containsKey(strNameSpacePrefix+oldAccountPiplineFieldName)){
            return  oldAccountPiplineFieldName;
         }else{
           return  newAccountPiplineFieldName; 
        } 
    }
    /*
     * Method Name:- getPipelineAccRelationName
     * @Description: This Method return Relationship Name beetween Account and Piplline.
     * Version:- PE v4.5
     */
    
    public static String getPipelineAccRelationName() {
        Map<String, Schema.SObjectField> fieldsMap = Schema.getGlobalDescribe().get(strNameSpacePrefix+'Pipeline__c').getDescribe().fields.getMap();

        if (fieldsMap.containsKey(strNameSpacePrefix + oldAccountPiplineFieldName)) {
            return getChildRelationshipName('Account__c', fieldsMap.get(strNameSpacePrefix + oldAccountPiplineFieldName));
        } else{
            return getChildRelationshipName('Account__c', fieldsMap.get(strNameSpacePrefix + newAccountPiplineFieldName));
        }
    }
    /*
     * Method Name:- getChildRelationshipName
     * @Description: This Method return Relationship Name which is belong to Account.
     * Version:- PE v4.5
     */
    public static String getChildRelationshipName(String objectName, Schema.SObjectField fieldName) {
        Schema.ChildRelationship[] relations = Schema.getGlobalDescribe().get('Account').getDescribe().getChildRelationships();

        for (Schema.ChildRelationship relation : relations) {
            if (relation.getField() == fieldName) {
                return relation.getRelationshipName();
            }
        }
        return null;
    }
}