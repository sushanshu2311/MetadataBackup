/****************************************************************************************************
** Module Name : Acuity 1.0 - Acuity
** Description : Used to handle all the DML & schema related funtionalities of Acuity 1.0 Acuity.
** Throws : NA
** Calls : NA
** Organization : Navatar Group
** Product Name & Version : Acuity 1.0
** Revision History:-
** Version    Date(YYYY-MM-DD)    Author         Description of Action
** 1.0        2022-08-07          Lakshya        Acuity Phase 1
** 2.0        2022-12-04          Lakshya        Acuity Phase 2
** 2.1        2023-09-22          Lakshya        PE Patch 3 Fix
** 3.0        2024-02-13          Lakshya        Sharing Model Implementation
** 3.1        2024-02-22          Sudhanshu      Handle Custom fields of Activity Layout

****************************************************************************************************/
public with sharing class NavatarAcuityCtrl {
    //Stores the generic error message
    private final static String ERR_MSG = 'Error Occured While Loading Component';
    //Stpres the API error message
    private final static String API_ERR_MSG = 'An Error occurred in API';
    //Stores the record id vs associated activity ids set
    private static Map<String, Set<String>> objIdVsActIdsMap = new Map<String, Set<String>>();
    //Stores set of Accounts with Deals associated to them
    private static Set<String> accIdSet = new Set<String>();
    //Stores activity IDs to be used for further processing (W/O AA Field Consideration)
    private static Set<String> actIdsSet = new Set<String>();
    //Stores activity IDs to be used for further processing (With AA Field Consideration)
    private static Set<String> completeActIdsSet = new Set<String>();
    //Stores the record id vs associated deal ids set
    private static Map<String, Set<String>> objIdVsDealIdsMap = new Map<String,Set<String>>();
    //For storing last interaction info against each record
    private static Map<String, LastInteractionInfo> objIdVsLastInteractionInfoMap = new Map<String, LastInteractionInfo>();
    //For storing the set of events for which notes hasn't been added yet
    private static Set<String> unreadEventSet = new Set<String>();
    //Display custom exception for fundraising
    public class myException extends Exception {} 
    //For storing the allowed CPU time for processing the data on page load
    private static Integer ALLOWED_CPU_TIME = 9000;
    
    /************************* RG VARIABLES : START *************************/

    //get revenue grid api key from custom meta data
    private static String apiKey = [SELECT Value__c FROM RG_Setting__mdt WHERE DeveloperName = 'RG_API_Key' LIMIT 1].Value__c;
    //store this variable revenue grid api key
    private static string storeApiKey = 'ApiKey '+apiKey;
    //store this variable authorization
    private static string storeAuth = 'Authorization';
    //store this variable post mehod type
    private static string storePost = 'POST';
    //store get mehod type
    private static string storeGet = 'GET';
    //store this variable content type
    private static string storeCT = 'Content-Type';
    //store this variable application json format
    private static string storeTPJson = 'application/json';
    //store account contact activity endpoint url
    private static string accConActivityEndPoint = RG_Setting__mdt.getInstance('RG_Connection_Count').Value__c;
    //store this variable contact query endpoint url
    private static string accConQueryEndPoint = RG_Setting__mdt.getInstance('RG_AddIcon_Contact_Name').Value__c;
    //store this variable account connection endpoint url
    private static string accConnectionEndPoint = RG_Setting__mdt.getInstance('RG_Firm_Contacts').Value__c;
    //store this variable user contact interaction endpoint url
    private static string userConInterationEndPoint= RG_Setting__mdt.getInstance('RG_Int_Connection_Details').Value__c;
    //store this variable get users endpoint url
    private static string getUserEndPoint = RG_Setting__mdt.getInstance('RG_Link_SF_Outlook').Value__c;
    //store this variable contact interaction endpoint url
    private static string contInteractionEndPoint = RG_Setting__mdt.getInstance('RG_Connection_Detail').Value__c;
    //Stores the email ID vs Email count for Contacts
    private static Map<String, Integer> emailVsCount = new Map<String, Integer>();
    //Stores the email ID vs Email count for Users
    private static Map<String,Integer> userIdVsEmailCount  = new Map<String,Integer>();
    //Stores the user ID vs mailbox ID for Users
    private static Map<String,String> userIdVsMBid = new Map<String,String>();
    //store revenue grid domain name
    private static String subjectDomainName = RG_Setting__mdt.getInstance('RG_ActID').Value__c;
    // flag for apiError
    public static Boolean isApiError=false; //added by shivam
    
    /************************* RG VARIABLES : END *************************/

    /*
     * Purpose : Processes the page load info to be displayed
     * Input : recordId     [Record ID of the current record (Account/Contact/Deal/Fund/Fundraising)]
     *         objApiName   [API name of the current record (Account/Contact/Deal/Fund/Fundraising)]
     * Returns : Info to be displayed on page load as a ResponseWrapper
     */
    @AuraEnabled
    public static ResponseWrapper handleOnLoadInfo(String recordId, String objApiName){
        try {
            ResponseWrapper respWrapper = new ResponseWrapper();
            respWrapper.namespacePrefix = getNamespacePrefix() + '__';
            respWrapper.contactPluralLabel = SObjectType.Contact.getLabelPlural();
            String dealTeamObjectName =getNamespacePrefix() + '__'+'Deal_Team__c';
            SObjectType sObjType1 = ((SObject) Type.forName(dealTeamObjectName).newInstance())
                                  .getSObjectType();
            respWrapper.dealTeamPluralLabel = sObjType1.getDescribe().getLabelPlural();
            String fndRsngCntObjectName =getNamespacePrefix() + '__'+'Fundraising_Contact__c';
            SObjectType sObjType2 = ((SObject) Type.forName(fndRsngCntObjectName).newInstance())
                                  .getSObjectType();
            respWrapper.fndrgCntPluralLabel = sObjType2.getDescribe().getLabelPlural();
            List<String> conIdList = new List<String>();
            if(String.escapeSingleQuotes(objApiName).equalsIgnoreCase('Account')){
                respWrapper.conMap = fetchInitInfoToProcess('Acuity_Connection_Field1', 'Acuity_Connection_Field2', 'Contact', ' WHERE AccountId = :recordId', recordId, null);
                conIdList.addAll(respWrapper.conMap.keySet());
                respWrapper.conIdList = conIdList;
                Account acc = [SELECT Name, RecordType.DeveloperName FROM Account WHERE Id = :recordId WITH SECURITY_ENFORCED]; //Modifed by Anshika Ahuja W.R.To Bug #00034852
                respWrapper.recName = acc.Name;
                respWrapper.recType = acc.RecordType.DeveloperName;
                respWrapper.compsRefInfo = handleCompsRef(String.escapeSingleQuotes(recordId), objApiName, conIdList, null, respWrapper.namespacePrefix);
            } else if(String.escapeSingleQuotes(objApiName).equalsIgnoreCase('Contact')){
                respWrapper.conMap = fetchInitInfoToProcess('Acuity_Connection_IntTab_Field1', 'Acuity_Connection_IntTab_Field2', 'User', '', '', null);
                Contact con = [SELECT AccountId, Name, Email FROM Contact WHERE Id = :recordId WITH SECURITY_ENFORCED] ;//Modifed by Anshika Ahuja W.R.To Bug #00034852
                //Added below 2 lines on 2022-11-01 to implement Ketan's new CR to not display Contacts associated to same Account in People's tab
                conIdList.addAll((new Map<String, Contact>([SELECT Id FROM Contact WHERE AccountId = :con.AccountId])).keySet());
                respWrapper.conIdList = conIdList;
                respWrapper.recName = con.Name;
                respWrapper.accId = con.AccountId;
                respWrapper.contactEmail = con.Email;
                respWrapper.compsRefInfo = handleCompsRef(recordId, objApiName, null, respWrapper.accId, respWrapper.namespacePrefix);
            } else if(String.escapeSingleQuotes(objApiName).equalsIgnoreCase(respWrapper.namespacePrefix + 'Pipeline__c')){
                String accLookupToRemove = String.valueOf(Acuity_Setting__mdt.getInstance('Acuity_Tagged_Firms_Exclude_Logic').Value__c);//Modified by Anshika Ahuja W.R.To Naming Convention
                sObject dealRec = Database.query('SELECT Name ' + (String.isNotBlank(accLookupToRemove) ? (', ' + accLookupToRemove) : '') + ' FROM ' + respWrapper.namespacePrefix + 'Pipeline__c WHERE Id = :recordId');
                respWrapper.recName = String.valueOf(dealRec.get('Name'));
                respWrapper.compsRefInfo = handleCompsRef(String.escapeSingleQuotes(recordId), objApiName, null, (String.isNotBlank(accLookupToRemove) ? String.valueOf(dealRec.get(accLookupToRemove)) : null), respWrapper.namespacePrefix);
            } else if(String.escapeSingleQuotes(objApiName).equalsIgnoreCase(respWrapper.namespacePrefix + 'Fund__c')){
                String refField = Acuity_Setting__mdt.getInstance('Acuity_Fund_FDR_LogicField').Value__c;
                sObject fundRec = Database.query('SELECT Name, ' + refField + ' FROM ' + respWrapper.namespacePrefix + 'Fund__c WHERE Id = :recordId');
                conIdList.addAll((new Map<String, sObject>(Database.query('SELECT Id FROM ' + respWrapper.namespacePrefix + 'Fundraising__c WHERE ' + respWrapper.namespacePrefix + 'Fund_Name__c = :recordId'))).keySet());
                respWrapper.conIdList = conIdList; //Modified by Anshika Ahuja W.R.To Bug #00034429
                respWrapper.recName = String.valueOf(fundRec.get('Name'));
                respWrapper.filterValue = String.valueOf(fundRec.get(refField));
                respWrapper.compsRefInfo = handleCompsRef(String.escapeSingleQuotes(recordId), objApiName, conIdList, null, respWrapper.namespacePrefix);
            } else if(String.escapeSingleQuotes(objApiName).equalsIgnoreCase(respWrapper.namespacePrefix + 'Fundraising__c')){
                
                respWrapper.conMap = fetchInitInfoToProcess('Acuity_FDRC_Connection_Field1', 'Acuity_FDRC_Connection_Field2,Acuity_FDRC_Connection_Field3,Acuity_FDRC_Connection_Field4', respWrapper.namespacePrefix + 'Fundraising_Contact__c', ' WHERE ' + respWrapper.namespacePrefix + 'Fundraising__c = :recordId', recordId, null);//Added by Tejaswini - Naming COnventions
                conIdList.addAll(respWrapper.conMap.keySet());
                respWrapper.conIdList = conIdList;
                Set<String> parentConIdSet = new Set<String>();
                for(SObject fdrConRec : Database.query('SELECT Id, ' + respWrapper.namespacePrefix + 'Contact__c FROM ' + respWrapper.namespacePrefix +'Fundraising_Contact__c WHERE ' + respWrapper.namespacePrefix + 'Fundraising__c =: recordId')){
                    String conId = String.valueOf(fdrConRec.get(respWrapper.namespacePrefix + 'Contact__c'));
                    if(String.isNotBlank(conId)){
                        parentConIdSet.add(conId);
                    }
                }
                respWrapper.parentConIdList = new List<String>(parentConIdSet);
                system.debug('SELECT Name FROM ' + respWrapper.namespacePrefix + 'Fundraising__c WHERE Id = :recordId');
                sObject fdrRec = Database.query('SELECT Name FROM ' + respWrapper.namespacePrefix + 'Fundraising__c WHERE Id = :recordId');
                respWrapper.recName = String.valueOf(fdrRec.get('Name'));
                respWrapper.compsRefInfo = handleCompsRef(String.escapeSingleQuotes(recordId), objApiName, null, null, respWrapper.namespacePrefix);
          
            }
            List<String> actIdList = new List<String>();
            List<String> completeActIdList = new List<String>();
            if(!actIdsSet.isEmpty()){
                actIdList.addAll(actIdsSet);
            }
            if(!completeActIdsSet.isEmpty()){
                completeActIdList.addAll(completeActIdsSet);
            }
            respWrapper.actIdList = actIdList;
            respWrapper.completeActIdList = completeActIdList;
            //Modified by Omkar Yamgar W.R.To Bug# 00039803 start 
            respWrapper.acclabel = SObjectType.Account.getLabelPlural();
            respWrapper.conlabel = SObjectType.Contact.getLabelPlural();
            respWrapper.dellabel = SObjectType.navpeII_dev18__Pipeline__c.getLabelPlural();
            respWrapper.fundlabel = SObjectType.navpeII_dev18__Fund__c.getLabelPlural();
            respWrapper.themelabel = SObjectType.navpeII_dev18__Theme__c.getLabelPlural();
            respWrapper.cliplabel = SObjectType.navpeII_dev18__Clip__c.getLabelPlural();
            respWrapper.fnrlabel = SObjectType.navpeII_dev18__Fundraising__c.getLabelPlural();
            //Modified by Omkar Yamgar W.R.To Bug# 00039803 end
            return respWrapper;
        } catch(Exception e) {
            
            throw new AuraHandledException(ERR_MSG + ' : <<' + e.getStackTraceString() + '>>');
        }
    }

    /************************* COMMON METHODS : START *************************/
    
    /*
     * Purpose : Fetches namespace prefix
     * Returns : Namespaceprefix to be used as a String
     */
    public static String getNamespacePrefix(){
        try{
            return [SELECT NamespacePrefix FROM ApexClass WHERE Name = 'FileUploaderCtrl' LIMIT :(Limits.getLimitQueryRows() - Limits.getQueryRows())].NamespacePrefix;
        } catch (Exception e) {
            throw new AuraHandledException(ERR_MSG + ' : <<' + e.getStackTraceString() + '>>');
        }
    }

    /*
     * Purpose : Fetches the field label to be displayed as data table column header
     * Input : objName      [Object API name]
     *         fieldName    [Field whose label is to be fetched]
     * Returns : Field label as a String
     */
    private static String fetchFieldLabel(String objName, String fieldName){
        try {
            String fieldLabel = Schema.getGlobalDescribe().get(objName).getDescribe().fields.getMap().get(fieldName.split('\\.')[0].replace('__r','__c')).getDescribe().getLabel();
            return fieldLabel.equalsIgnoreCase('Legal Name')
                   ? 'Firm'
                   : fieldLabel;
        } catch (Exception e) {
            throw new AuraHandledException(ERR_MSG + ' : <<' + e.getStackTraceString() + '>>');
        }
    }

    /*
     * Purpose : Fetches initial data to be used for further processing
     * Input : metadataField1      [Field 1 to process for Contact/Connections Section]
     *         otherMetadataFields [Other fields as a comma separated string to process for Contact/Connections Section]
     *         objName             [Object to query data from]
     *         whereClause         [Where clause to be used in the SOQL query]
     *         recordId            [Record ID of the current record (Account/Contact)]
     *         idSet               [ID set to be worked upon]
     * Returns : Initial data to be used for further processing as a Map<String, sObject>
     */
    private static Map<String, sObject> fetchInitInfoToProcess(String metadataField1, String otherMetadataFields, String objName, String whereClause, String recordId, Set<String> idSet){
        try {
            String refField = Acuity_Setting__mdt.getInstance(metadataField1).Value__c;
            String fieldStr = refField; //Added on 2022-09-26 to create a separate string if values exist in metadata
            if(String.isNotBlank(refField)){
                fieldStr = ', FORMAT(' + refField + ')';
            }
            for(String metadataField : otherMetadataFields.split(',')){
                String refField2 = Acuity_Setting__mdt.getInstance(metadataField).Value__c;
                //Added string comparison case on 2022-09-26 to create a separate string if values exist in metadata
                if(String.isNotBlank(refField) && String.isNotBlank(refField2) && !fieldStr.contains('FORMAT(' + refField2 + ')')){
                    fieldStr += ', FORMAT(' + refField2 + ')';
                }
            }
            
            /* RG : START */
            if(String.isNotBlank(refField) && !refField.contains('Email') && (objName.equalsIgnoreCase('Contact') || objName.equalsIgnoreCase('User'))){
                fieldStr += ', Email';
                /*if(objName.equalsIgnoreCase('Contact')){//added by shivam
                    fieldStr+=',AccountId,Account.Name';
                } */
                }
            if(String.isNotBlank(refField) && !refField.contains('AccountId') && objName.equalsIgnoreCase('Contact')){//added by shivam
                fieldStr+=',AccountId,Account.Name';
            }
            //Condition for Fundraising Acuity > Fundraising_Contact__c Section
            if(String.isNotBlank(refField) && !refField.contains('navpeII_dev18__Contact__r.Email') && objName.equalsIgnoreCase('navpeII_dev18__Fundraising_Contact__c')){
                fieldStr += ', navpeII_dev18__Contact__r.Email';
            }
            /* RG : END */
            /* Last Interaction : START */
            //if(objName.equalsIgnoreCase('Contact') && !fieldStr.contains('navpeII_dev18__Last_Touch_Point__c')){
                //fieldStr += ', FORMAT(navpeII_dev18__Last_Touch_Point__c)';
            //}
            /* else if(objName.equalsIgnoreCase('User') && !fieldStr.contains('Last_Touchpoint__c')){
                fieldStr += ', FORMAT(Last_Touchpoint__c)';
            }*/
            if((objName.equalsIgnoreCase('Contact') /*|| objName.equalsIgnoreCase('User')*/) && !fieldStr.contains('navpeII_dev18__Last_Touchpoint_ID__c')){
                fieldStr += ', navpeII_dev18__Last_Touchpoint_ID__c';
            }
           String str = 'SELECT Id' + (String.isBlank(fieldStr) ? '' : String.escapeSingleQuotes(fieldStr)) + ' FROM ' + String.escapeSingleQuotes(objName) + String.escapeSingleQuotes(whereClause);
           /* Last Interaction : END */
           if(Schema.getGlobalDescribe().get(objName).getDescribe().isAccessible()){//Added as part of 39338, 39341 by Kushal
            return new Map<String, sObject>(Database.query('SELECT Id' + (String.isBlank(fieldStr) ? '' : String.escapeSingleQuotes(fieldStr)) + ' FROM ' + String.escapeSingleQuotes(objName) + String.escapeSingleQuotes(whereClause)));
           }else {
             return new Map<String, sObject>();
           }
        } catch (Exception e) {
            
            throw new AuraHandledException(ERR_MSG + ' : <<' + e.getStackTraceString() + '>>');
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
            throw new AuraHandledException(ERR_MSG + ' : <<' + e.getStackTraceString() + '>>');
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
            String sessionId = NavatarAcuityCtrl.getSessionIdFromVFPage(Page.sessionIdPage);    
            String auth = 'Bearer ' + sessionId;
            req.setHeader('Authorization', auth);
            Http http = new Http();
            HTTPResponse resp = http.send(req);
            return resp.getBody();
        } catch(Exception e) {
            throw new AuraHandledException(ERR_MSG + ' : <<' + e.getStackTraceString() + '>>');
        }
    }

    /************************* COMMON METHODS : END *************************/

    /************************* REFERENCED SECTION MAIN METHODS : START *************************/

    /*
     * Purpose : Handles the Companies Referenced information on Account & Contact objects
     * Input : recordId         [Record ID of the current record (Account/Contact/Deal/Fund/Fundraising)]
     *         objApiName       [API name of the current record (Account/Contact/Deal/Fund/Fundraising)]
     *         conIdList        [List of contacts of the Account to be processed; For Account : CR only; Null for Contact : CR]
     *         accId            [Account ID of the current contact; For Contact : CR only; Null for Account : CR]
     *         namespacePrefix  [Namespaceprefix to be used]
     * Returns : List<InfoWrapper> containing info about each record to be displayed under CR data table
     */
    private static List<InfoWrapper> handleCompsRef(String recordId, String objApiName, List<String> conIdList, String accId, String namespacePrefix){
        try {
            String refField = Acuity_Setting__mdt.getInstance('Acuity_Tagged_Firms_Field').Value__c;//Modified by Anshika Ahuja W.R.To Naming Convention
            if(String.isBlank(refField)){
                return null;
            } else {
                List<String> actIdList = new List<String>();

                if(objApiName.equalsIgnoreCase('Account')){
                    //For handling events
                    actIdList = fetchRecsToProcess(conIdList, 'Event', ' WHERE (Relation.Type = \'Contact\') AND ((RelationId IN :conIdList) OR (Event.navpeII_dev18__Related_Associations__c LIKE \'%' + String.escapeSingleQuotes(recordId) + '%\'))');
                    processCRActInfo('Event', actIdList, ' WHERE (EventId IN :actIdList)', conIdList, recordId, objApiName, namespacePrefix);
                    processCRActInfo('Event', '(navpeII_dev18__Related_Associations__c LIKE \'%' + recordId + '%\')');    //For covering the scenario : Empty Name & Accounts in AA field
                    //For handling tasks
                    if(Schema.getGlobalDescribe().get('TaskRelation') != null){
                        actIdList = fetchRecsToProcess(conIdList, 'Task', ' WHERE (Relation.Type = \'Contact\') AND ((RelationId IN :conIdList) OR (Task.navpeII_dev18__Related_Associations__c LIKE \'%' + String.escapeSingleQuotes(recordId) + '%\'))');//Removed ListEmail filtering By Harshwardhan
                        processCRActInfo('Task', actIdList, ' WHERE (TaskId IN :actIdList)', conIdList, recordId, objApiName, namespacePrefix);
                        processCRActInfo('Task', '(navpeII_dev18__Related_Associations__c LIKE \'%' + recordId + '%\')');    //For covering the scenario : Empty Name & Accounts in AA field    
                    }
                    objIdVsActIdsMap.remove(recordId);  //To remove current record id from Account
                } else if(objApiName.equalsIgnoreCase('Contact')){
                    //For handling events
                    actIdList = fetchRecsToProcess(recordId, 'Event', ' WHERE RelationId = :recordId');
                    processCRActInfo('Event', actIdList, ' WHERE (EventId IN :actIdList)', null, recordId, objApiName, namespacePrefix);
                    //For handling tasks
                    if(Schema.getGlobalDescribe().get('TaskRelation') != null){
                        actIdList = fetchRecsToProcess(recordId, 'Task', ' WHERE (RelationId = :recordId)');//Removed ListEmail filtering By Harshwardhan
                        processCRActInfo('Task', actIdList, ' WHERE (TaskId IN :actIdList)', null, recordId, objApiName, namespacePrefix);
                    }
                    objIdVsActIdsMap.remove(accId);  //To remove current record id from Contact
                } else if(objApiName.equalsIgnoreCase(namespacePrefix + 'Pipeline__c') || objApiName.equalsIgnoreCase(namespacePrefix + 'Fundraising__c')){
                    //For handling events
                    actIdList = fetchRecsToProcess('', 'Event', ' WHERE (Relation.Type = \'Contact\') AND (Event.navpeII_dev18__Related_Associations__c LIKE \'%' + String.escapeSingleQuotes(recordId) + '%\')');
                    processCRActInfo('Event', actIdList, ' WHERE (EventId IN :actIdList)', null, recordId, objApiName, namespacePrefix);
                    processCRActInfo('Event', '(navpeII_dev18__Related_Associations__c LIKE \'%' + String.escapeSingleQuotes(recordId) + '%\')');    //For covering the scenario : Empty Name & Accounts in AA field
                    //For handling tasks
                    if(Schema.getGlobalDescribe().get('TaskRelation') != null){
                        actIdList = fetchRecsToProcess('', 'Task', ' WHERE (Relation.Type = \'Contact\') AND (Task.navpeII_dev18__Related_Associations__c LIKE \'%' + String.escapeSingleQuotes(recordId) + '%\')');//Removed ListEmail filtering By Harshwardhan
                        processCRActInfo('Task', actIdList, ' WHERE (TaskId IN :actIdList)', null, recordId, objApiName, namespacePrefix);
                        processCRActInfo('Task', '(navpeII_dev18__Related_Associations__c LIKE \'%' + String.escapeSingleQuotes(recordId) + '%\')');     //For covering the scenario : Empty Name & Accounts in AA field
                    }
                    if(objApiName.equalsIgnoreCase(namespacePrefix + 'Pipeline__c')){
                        objIdVsActIdsMap.remove(accId);     //To remove the Account associated to the current Deal record
                    }
                } else if(objApiName.equalsIgnoreCase(namespacePrefix + 'Fund__c')){
                    String fdrWhereClauseStrEvent = '(Event.navpeII_dev18__Related_Associations__c LIKE \'%' + String.escapeSingleQuotes(recordId) + '%\')';
                    String fdrWhereClauseStrTask = '(Task.navpeII_dev18__Related_Associations__c LIKE \'%' + String.escapeSingleQuotes(recordId) + '%\')';
                    for(String fdrRecId : conIdList){
                        fdrWhereClauseStrEvent += ' OR (Event.navpeII_dev18__Related_Associations__c LIKE \'%' + String.escapeSingleQuotes(fdrRecId) + '%\')';
                        fdrWhereClauseStrTask += ' OR (Task.navpeII_dev18__Related_Associations__c LIKE \'%' + String.escapeSingleQuotes(fdrRecId) + '%\')';
                    }
                    //For handling events
                    actIdList = fetchRecsToProcess('', 'Event', ' WHERE (Relation.Type = \'Contact\') AND (' + fdrWhereClauseStrEvent + ')');
                    processCRActInfo('Event', actIdList, ' WHERE (EventId IN :actIdList)', null, recordId, objApiName, namespacePrefix);
                    processCRActInfo('Event', '(' + fdrWhereClauseStrEvent + ')');    //For covering the scenario : Empty Name & Accounts in AA field
                    //For handling tasks
                    if(Schema.getGlobalDescribe().get('TaskRelation') != null){
                    	actIdList = fetchRecsToProcess(conIdList, 'Task', ' WHERE (Relation.Type = \'Contact\') AND (' + fdrWhereClauseStrTask + ')');//Removed ListEmail filtering By Harshwardhan
                        processCRActInfo('Task', actIdList, ' WHERE (TaskId IN :actIdList)', null, recordId, objApiName, namespacePrefix);
                        processCRActInfo('Task', '(' + fdrWhereClauseStrTask + ')');    //For covering the scenario : Empty Name & Accounts in AA field    
                    }
                }
                String TOKEN_SOBJECT_NAME = namespacePrefix + 
                                            (namespacePrefix.equalsIgnoreCase('navpeII_dev18__')
                                             ? 'Pipeline__c'
                                             : 'Deal__c');
                processAccAssociatedToDeals(namespacePrefix, TOKEN_SOBJECT_NAME, objIdVsActIdsMap.keySet());
                return prepareFinalMap('Account', refField);
            }
        } catch (Exception e) {
            throw new AuraHandledException(ERR_MSG + ' : <<' + e.getStackTraceString() + '>>');
        }
    }

    /*
     * Purpose : Processes the activity relation records
     * Input : objName          [Activity type (Task/Event)]
     *         actIdList        [List of activities to be processed]
     *         whereClause      [Where clause to be used in the SOQL query]
     *         conIdList        [List of contacts of the Account to be processed (Only for Account Record Page; null for Contact Record Page)]
     *         recordId         [Record ID of the current record (Account/Contact/Deal/Fund/Fundraising)]
     *         objApiName       [API name of the current record (Account/Contact/Deal/Fund/Fundraising)]
     *         namespacePrefix  [Namespaceprefix to be used]
     * Returns : N/A
     */
    //private static void processCRActInfo(String objName, List<String> actIdList, String whereClause, List<String> conIdList, String recordId, String objApiName, String namespacePrefix){
    //    try {
    //        String accIdClause = (Schema.getGlobalDescribe().get('EventRelation').getDescribe().fields.getMap().get('AccountId') != null) ? (' AccountId, ') : '';
    //        for(sObject actRec : Database.query('SELECT ' + accIdClause + ' RelationId, ' + objName + 'Id, ' + objName + '.navpeII_dev18__Related_Associations__c FROM ' + objName + 'Relation' + whereClause + ' AND IsDeleted = false ALL ROWS')){
    //            String actId = String.valueOf(actRec.get(objName + 'Id'));
    //            String relAssoIds = String.valueOf(actRec.getSobject(objName).get('navpeII_dev18__Related_Associations__c'));
    //            if(String.isNotBlank(relAssoIds)){
    //                processRelObjIds(relAssoIds, actId);
    //            }
    //            //If condition for Account Record Page & else condition for Contact Record Page
    //            if(objApiName.equalsIgnoreCase('Account')){
    //                //For storing activities where contact is referenced
    //                if(conIdList.contains(String.valueOf(actRec.get('RelationId')))){
    //                    actIdsSet.add(actId);
    //                    completeActIdsSet.add(actId);
    //                }
    //                //For storing activities where account id is referenced
    //                if(String.isNotBlank(relAssoIds) && relAssoIds.contains(recordId)){
    //                    completeActIdsSet.add(actId);
    //                }
    //            } else {
    //                actIdsSet.add(actId);
    //                completeActIdsSet.add(actId);
    //            }
    //            //Added below code & moved processRelObjIds() inside if condition on 2022-09-23 to not process records with blank AccountId
    //            if(String.isNotBlank(accIdClause)){
    //            	String accountId = String.valueOf(actRec.get('AccountId'));
    //                if(String.isNotBlank(accountId)){
    //                    processRelObjIds(String.valueOf(actRec.get('AccountId')), actId);
    //                }    
    //            }
    //        }
    //    } catch (Exception e) {
    //        throw new AuraHandledException(ERR_MSG + ' : <<' + e.getStackTraceString() + '>>');
    //    }
    //}

    /*
     * Purpose : Processes the activity records
     * Input : objName        [Activity type (Task/Event)]
     *         relAssoClause  [Related Association clause to be used in the query]
     * Returns : N/A
     */
    private static void processCRActInfo(String objName, String relAssoClause){
        try {
            Integer processedRecCount = 0;
            //Added IsChild = false check on 2022-10-07 to consider only the main copy of the event record
            for(sObject actRec : Database.query('SELECT Id, navpeII_dev18__Related_Associations__c FROM ' + objName + ' WHERE ' + relAssoClause + (objName.equalsIgnoreCase('Event') ? ' AND IsChild = false' : '') + ' AND IsDeleted = false ORDER BY CreatedDate DESC ALL ROWS')){
                if(Limits.getCpuTime() < ALLOWED_CPU_TIME){
                    completeActIdsSet.add(String.valueOf(actRec.get('Id')));
                    processRelObjIds(String.valueOf(actRec.get('navpeII_dev18__Related_Associations__c')), String.valueOf(actRec.get('Id')));
                    processedRecCount++;
                } else {
                    system.debug('--->' + objName + ' > ' + processedRecCount + ' private records processed in processCRActInfo().');
                    break;
                }
            }
        } catch(Exception e) {
            throw new AuraHandledException(ERR_MSG + ' : <<' + e.getStackTraceString() + '>>');
        }
    }

    private static void processCRActInfo(String objName, List<String> actIdList, String whereClause, List<String> conIdList, String recordId, String objApiName, String namespacePrefix){
        try {
            String accIdClause = (Schema.getGlobalDescribe().get('EventRelation').getDescribe().fields.getMap().get('AccountId') != null) ? (' AccountId, ') : '';
            String isChildClause = objName.equalsIgnoreCase('Event') ? ' AND IsChild = false' : '';
            Integer processedRecCount = 0;
            for(sObject actRec : Database.query('SELECT Id, navpeII_dev18__Related_Associations__c, (SELECT ' + accIdClause + ' RelationId FROM ' + objName + 'Relations WHERE IsDeleted = false) FROM ' + objName + ' WHERE Id IN :actIdList' + isChildClause + ' AND IsDeleted = false ORDER BY CreatedDate DESC ALL ROWS')){
                if(Limits.getCpuTime() < ALLOWED_CPU_TIME){
                    String actId = String.valueOf(actRec.get('Id'));
                    String relAssoIds = String.valueOf(actRec.get('navpeII_dev18__Related_Associations__c'));
                    if(String.isNotBlank(relAssoIds)){
                        processRelObjIds(relAssoIds, actId);
                    }
                    for(sObject actRelRec : actRec.getSObjects(objName + 'Relations')){
                        //If condition for Account Record Page & else condition for Contact Record Page
                        if(objApiName.equalsIgnoreCase('Account')){
                            //For storing activities where contact is referenced
                            if(conIdList.contains(String.valueOf(actRelRec.get('RelationId')))){
                                actIdsSet.add(actId);
                                completeActIdsSet.add(actId);
                            }
                            //For storing activities where account id is referenced
                            if(String.isNotBlank(relAssoIds) && relAssoIds.contains(recordId)){
                                completeActIdsSet.add(actId);
                            }
                        } else {
                            actIdsSet.add(actId);
                            completeActIdsSet.add(actId);
                        }
                        //Added below code & moved processRelObjIds() inside if condition on 2022-09-23 to not process records with blank AccountId
                        if(String.isNotBlank(accIdClause)){
                            String accountId = String.valueOf(actRelRec.get('AccountId'));
                            if(String.isNotBlank(accountId)){
                                processRelObjIds(String.valueOf(actRelRec.get('AccountId')), actId);
                            }
                        }
                    }
                    processedRecCount++;
                } else {
                    system.debug('--->' + objName + ' > ' + processedRecCount + ' records processed in processCRActInfo().');
                    break;
                }
            }
        } catch (Exception e) {
            throw new AuraHandledException(ERR_MSG + ' : <<' + e.getStackTraceString() + '>>');
        }
    }
    /*
     * Purpose : Handles the People Referenced information on Account object
     * Input : conIdList    [List of contacts of the Account to be processed]
     *         actIdList    [Activity IDs to be processed]
     * Returns : List<InfoWrapper> containing info about each record to be displayed under PR data table
     */
    @AuraEnabled
    public static List<InfoWrapper> handlePeopleRefInfo(List<String> conIdList, List<String> actIdList){
        try {
            String refField = Acuity_Setting__mdt.getInstance('Acuity_Tagged_People_Field').Value__c;//Modified by Anshika Ahuja W.R.To Naming Convention
            if(String.isBlank(refField)){
                return null;
            } else {
                //Removed previous if else & used same logic of Account on 2022-11-01 to implement Ketan's new CR to not display Contacts associated to same Account in People's tab
                processPRActInfo('Event', conIdList, actIdList, ' WHERE EventId IN :actIdList AND RelationId NOT IN :conIdList');
                if(Schema.getGlobalDescribe().get('TaskRelation') != null){
                	processPRActInfo('Task', conIdList, actIdList, ' WHERE TaskId IN :actIdList AND RelationId NOT IN :conIdList');    
                }
                return prepareFinalMap('Contact', refField);
            }
        } catch (Exception e) {
            throw new AuraHandledException(ERR_MSG + ' : <<' + e.getStackTraceString() + '>>');
        }
    }

    /*
     * Purpose : Processes the activity relation records
     * Input : objName      [Activity type (Task/Event)]
     *         conIdList    [List of contacts of the Account to be processed (For Account Record Page only; null for Contact Record Page)]
     *         actIdList    [List of activities to be processed]
     *         whereClause  [Where clause to be used in the SOQL query]
     * Returns : N/A
     */
    private static void processPRActInfo(String objName, List<String> conIdList, List<String> actIdList, String whereClause){
        try {
            Integer processedRecCount = 0;
            for(sObject actRec : Database.query('SELECT RelationId, ' + objName + 'Id FROM ' + objName + 'Relation' + whereClause + ' AND IsDeleted = false ORDER BY CreatedDate DESC ALL ROWS')){
                if(Limits.getCpuTime() < ALLOWED_CPU_TIME){
                    processRelObjIds(String.valueOf(actRec.get('RelationId')), String.valueOf(actRec.get(objName + 'Id')));
                    processedRecCount++;
                } else {
                    system.debug('--->' + objName + ' > ' + processedRecCount + ' records processed in processPRActInfo().');
                    break;
                }
            }
        } catch (Exception e) {
            throw new AuraHandledException(ERR_MSG + ' : <<' + e.getStackTraceString() + '>>');
        }
    }

    /*
     * Purpose : Handles the Deals Referenced information on Account & Contact objects
     * Input : actIdList        [Activity IDs to be processed]
     *         namespacePrefix  [Namespaceprefix to be used]
     *         objApiName       [API name of the current record (Account/Contact/Deal/Fund/Fundraising)]
     *         recId            [Record ID of the current record (Deal/Fund)]
     *         relObjIdList     [Related object IDs of current record (Fundraising in case of Fund record)]
     *         recType          [Record type (FOr Account only)]
     * Returns : List<InfoWrapper> containing info about each record to be displayed under DR data table
     */
    @AuraEnabled
    public static List<InfoWrapper> handleDealsRefInfo(List<String> actIdList, String namespacePrefix, String objApiName, String recId, List<String> relObjIdList, String recType, Boolean isDealAccessible, Boolean displayFdrSection){
        try {
           String refField = objApiName.equalsIgnoreCase('Account') && recType.equalsIgnoreCase('Institution')
                              ? Acuity_Setting__mdt.getInstance('Acuity_Tagged_Funds_Field').Value__c//Modified by Anshika Ahuja W.R.To Naming Convention
                              : Acuity_Setting__mdt.getInstance('Acuity_Tagged_Deals_Field').Value__c;//Modified by Anshika Ahuja W.R.To Naming Convention
            if(String.isBlank(refField)){
                return null;
            } else {
                objIdVsActIdsMap = new Map<String, Set<String>>();
                String TOKEN_SOBJECT_NAME = String.escapeSingleQuotes(namespacePrefix + 
                                            (String.escapeSingleQuotes(namespacePrefix).equalsIgnoreCase('navpeII_dev18__')
                                             ? 'Pipeline__c'
                                             : 'Deal__c'));
                if(objApiName.equalsIgnoreCase('Account') || objApiName.equalsIgnoreCase('Contact')){
                    processDRActRelInfo('Event', actIdList, ' WHERE EventId IN :actIdList');
                    if(Schema.getGlobalDescribe().get('TaskRelation') != null){
                        processDRActRelInfo('Task', actIdList, ' WHERE TaskId IN :actIdList');    
                    }
                    //Added below 2 lines on 2022-09-26 to handle private activities
                    processDRActInfo('Event', actIdList, ' WHERE navpeII_dev18__Related_Associations__c != null AND Id IN :actIdList');   //For covering the scenario : Empty Name & Accounts in AA field
                    processDRActInfo('Task', actIdList, ' WHERE navpeII_dev18__Related_Associations__c != null AND Id IN :actIdList');    //For covering the scenario : Empty Name & Accounts in AA field
                } else if(objApiName.equalsIgnoreCase(TOKEN_SOBJECT_NAME)){
                    processDRActRelInfo('Event', actIdList, ' WHERE EventId IN :actIdList AND Event.navpeII_dev18__Related_Associations__c LIKE \'%' + String.escapeSingleQuotes(recId) + '%\'');
                    if(Schema.getGlobalDescribe().get('TaskRelation') != null){
                        processDRActRelInfo('Task', actIdList, ' WHERE TaskId IN :actIdList AND Task.navpeII_dev18__Related_Associations__c LIKE \'%' + String.escapeSingleQuotes(recId) + '%\'');
                    }
                    //Added below 2 lines on 2022-09-26 to handle private activities
                    processDRActInfo('Event', actIdList, ' WHERE Id IN :actIdList AND navpeII_dev18__Related_Associations__c LIKE \'%' + String.escapeSingleQuotes(recId) + '%\'');   //For covering the scenario : Empty Name & Accounts in AA field
                    processDRActInfo('Task', actIdList, ' WHERE Id IN :actIdList AND navpeII_dev18__Related_Associations__c LIKE \'%' + String.escapeSingleQuotes(recId) + '%\'');    //For covering the scenario : Empty Name & Accounts in AA field
                    objIdVsActIdsMap.remove(recId);  //To remove current record id from Deal
                } else if(objApiName.equalsIgnoreCase(namespacePrefix + 'Fund__c')){
                    String fdrWhereClauseStrEventRel = ' WHERE (EventId IN :actIdList) AND ((Event.navpeII_dev18__Related_Associations__c LIKE \'%' + String.escapeSingleQuotes(recId) + '%\')';
                    String fdrWhereClauseStrTaskRel = ' WHERE (TaskId IN :actIdList) AND ((Task.navpeII_dev18__Related_Associations__c LIKE \'%' + String.escapeSingleQuotes(recId) + '%\')';
                    String fdrWhereClauseStrEvent = ' WHERE (Id IN :actIdList) AND ((navpeII_dev18__Related_Associations__c LIKE \'%' + String.escapeSingleQuotes(recId) + '%\')';
                    String fdrWhereClauseStrTask = ' WHERE (Id IN :actIdList) AND ((navpeII_dev18__Related_Associations__c LIKE \'%' + String.escapeSingleQuotes(recId) + '%\')';
                    for(String fdrRecId : relObjIdList){
                        fdrWhereClauseStrEventRel += ' OR (Event.navpeII_dev18__Related_Associations__c LIKE \'%' + String.escapeSingleQuotes(fdrRecId) + '%\')';
                        fdrWhereClauseStrTaskRel += ' OR (Task.navpeII_dev18__Related_Associations__c LIKE \'%' + String.escapeSingleQuotes(fdrRecId) + '%\')';
                        fdrWhereClauseStrEvent += ' OR (navpeII_dev18__Related_Associations__c LIKE \'%' + String.escapeSingleQuotes(fdrRecId) + '%\')';
                        fdrWhereClauseStrTask += ' OR (navpeII_dev18__Related_Associations__c LIKE \'%' + String.escapeSingleQuotes(fdrRecId) + '%\')';
                    }
                    processDRActRelInfo('Event', actIdList, fdrWhereClauseStrEventRel + ')');
                    if(Schema.getGlobalDescribe().get('TaskRelation') != null){
                        processDRActRelInfo('Task', actIdList, fdrWhereClauseStrTaskRel + ')');
                    }
                    //Added below 2 lines on 2022-09-26 to handle private activities
                    processDRActInfo('Event', actIdList, fdrWhereClauseStrEvent + ')');   //For covering the scenario : Empty Name & Accounts in AA field
                    processDRActInfo('Task', actIdList, fdrWhereClauseStrTask + ')');    //For covering the scenario : Empty Name & Accounts in AA field
                    objIdVsActIdsMap.remove(recId);  //To remove current record id from Deal
                }
                if(objApiName.equalsIgnoreCase('Account') && recType.equalsIgnoreCase('Institution') || (objApiName.equalsIgnoreCase('Contact') && !isDealAccessible && displayFdrSection)){
                    return prepareFinalMap(namespacePrefix + 'Fund__c', refField);    
                } else {
                    return prepareFinalMap(TOKEN_SOBJECT_NAME, refField);
                }
            }
        } catch (Exception e) {
            throw new AuraHandledException(ERR_MSG + ' : <<' + e.getStackTraceString() + '>>');
        }
    }

    /*
     * Purpose : Processes the activity relation records
     * Input : objName      [Activity type (Task/Event)]
     *         actIdList    [List of activities to be processed]
     *         whereClause  [Where clause to be used in the SOQL query]
     * Returns : N/A
     */
    private static void processDRActRelInfo(String objName, List<String> actIdList, String whereClause){
        try {
            Integer processedRecCount = 0;
            for(sObject actRec : Database.query('SELECT ' + objName + '.navpeII_dev18__Related_Associations__c, ' + objName + 'Id FROM ' + objName + 'Relation' + whereClause + ' AND IsDeleted = false ORDER BY CreatedDate DESC ALL ROWS')){
                if(Limits.getCpuTime() < ALLOWED_CPU_TIME){
                    String actId = String.valueOf(actRec.get(objName + 'Id'));
                    String relAssoIds = String.valueOf(actRec.getSobject(objName).get('navpeII_dev18__Related_Associations__c'));
                    if(String.isNotBlank(relAssoIds)){
                        processRelObjIds(relAssoIds, actId);
                    }
                    processedRecCount++;
                } else {
                    system.debug('--->' + objName + ' > ' + processedRecCount + ' records processed in processDRActRelInfo().');
                    break;
                }
            }
        } catch (Exception e) {
            throw new AuraHandledException(ERR_MSG + ' : <<' + e.getStackTraceString() + '>>');
        }
    }

    /*
     * Purpose : Processes the activity records
     * Input : objName      [Activity type (Task/Event)]
     *         actIdList    [List of activities to be processed]
     *         whereClause  [Where clause to be used in the SOQL query]
     * Returns : N/A
     */
    private static void processDRActInfo(String objName, List<String> actIdList, String whereClause){
        try {
            Integer processedRecCount = 0;
            for(sObject actRec : Database.query('SELECT Id, navpeII_dev18__Related_Associations__c FROM ' + objName + whereClause + ' AND IsDeleted = false ORDER BY CreatedDate DESC ALL ROWS')){
                if(Limits.getCpuTime() < ALLOWED_CPU_TIME){
                    processRelObjIds(String.valueOf(actRec.get('navpeII_dev18__Related_Associations__c')), String.valueOf(actRec.get('Id')));
                    processedRecCount++;
                } else {
                    system.debug('--->' + objName + ' > ' + processedRecCount + ' private records processed in processDRActInfo().');
                    break;
                }
            }
        } catch(Exception e) {
            throw new AuraHandledException(ERR_MSG + ' : <<' + e.getStackTraceString() + '>>');
        }
    }

    /*
     * Purpose : Processes the related themes records
     * Input : recordId         [Record ID of the current record (Account/Contact/Deal/Fund/Fundraising)]
     *         objApiName       [API name of the current record (Account/Contact/Deal/Fund/Fundraising)]
     *         namespacePrefix  [Namespaceprefix to be used]
     * Returns : List<ReferenceWrapper> containing info about each record to be displayed under Theme Referenced data table
     */
    @AuraEnabled
    public static List<ReferenceWrapper> handleThemesRefInfo(String recordId, String objApiName, String namespacePrefix){
        try {
            String refField = Acuity_Setting__mdt.getInstance('Acuity_Tagged_Themes_Field').Value__c;//Modified by Anshika Ahuja W.R.To Naming Convention
            if(String.isBlank(refField)){
                return null;
            } else {
                List<ReferenceWrapper> themesInfoList = new List<ReferenceWrapper>();
                String lookupField = '';
                if(objApiName.equalsIgnoreCase('Account')){
                    lookupField = 'Account__c';
                } else if(objApiName.equalsIgnoreCase('Contact')){
                    lookupField = 'Contact__c';
                } else if(objApiName.equalsIgnoreCase(namespacePrefix + 'Pipeline__c')){
                    lookupField = 'Deal__c';
                } else if(objApiName.equalsIgnoreCase(namespacePrefix + 'Fund__c')){
                    lookupField = 'Fund__c';
                } else if(objApiName.equalsIgnoreCase(namespacePrefix + 'Fundraising__c')){
                    lookupField = 'Fundraising__c';
                }
                for(sObject objRec : Database.query('SELECT Theme__c, Theme__r.' + refField + ' FROM Theme_Relation__c WHERE ' + lookupField + ' =: recordId')){
                    ReferenceWrapper themeInfo = new ReferenceWrapper();
                    String themeId = String.valueOf(objRec.get('Theme__c'));
                    if(String.isNotBlank(themeId)){
                        themeInfo.name = String.valueOf(objRec.getsObject('Theme__r').get(refField));
                        themeInfo.nameRef = '/' + themeId;
                        themesInfoList.add(themeInfo);
                    }
                }
                return themesInfoList;
            }
        } catch(Exception e) {
            throw new AuraHandledException(ERR_MSG + ' : <<' + e.getStackTraceString() + '>>');
        }
    }

    /*
     * Purpose : Processes the related clips records
     * Input : recordId         [Record ID of the current record (Account/Contact/Deal/Fund/Fundraising)]
     *         objApiName       [API name of the current record (Account/Contact/Deal/Fund/Fundraising)]
     *         namespacePrefix  [Namespaceprefix to be used]
     * Returns : List<ReferenceWrapper> containing info about each record to be displayed under Clips Referenced data table
     */
    @AuraEnabled
    public static List<ClipsReferencedWrapper> handleClipsRefInfo(String recordId, String objApiName, String namespacePrefix){
        try {
            String refField = Acuity_Setting__mdt.getInstance('Acuity_Tagged_Clips_Field1').Value__c;//Modified by Anshika Ahuja W.R.To Naming Convention
            String fieldStr = 'FORMAT(Clip__r.' + refField + ')';
            if(String.isBlank(refField)){
                return null;
            } else {
                String refField2 = Acuity_Setting__mdt.getInstance('Acuity_Tagged_Clips_Field2').Value__c; //Modified by Anshika Ahuja W.R.To Naming Convention
                if(String.isNotBlank(refField2) && refField != refField2){
                    fieldStr += ', FORMAT(Clip__r.' + refField2 + ')';
                }
                if(!fieldStr.containsIgnoreCase('Notes__c')){
                    fieldStr += ', FORMAT(Clip__r.Notes__c)';
                }
                if(!fieldStr.containsIgnoreCase('CreatedDate')){
                    fieldStr += ', FORMAT(Clip__r.CreatedDate)';
                }
                List<ClipsReferencedWrapper> clipsRefWrapperList = new List<ClipsReferencedWrapper>();
                String lookupField = '';
                if(objApiName.equalsIgnoreCase('Account')){
                    lookupField = 'Account__c';
                } else if(objApiName.equalsIgnoreCase('Contact')){
                    lookupField = 'Contact__c';
                } else if(objApiName.equalsIgnoreCase(namespacePrefix + 'Pipeline__c')){
                    lookupField = 'Deal__c';
                } else if(objApiName.equalsIgnoreCase(namespacePrefix + 'Fund__c')){
                    lookupField = 'Fund__c';
                } else if(objApiName.equalsIgnoreCase(namespacePrefix + 'Fundraising__c')){
                    lookupField = 'Fundraising__c';
                }
                List<sObject> objRecList = new List<sObject>();
                objRecList = Database.query('SELECT Clip__c, ' + fieldStr + ' FROM Clip_Relation__c WHERE ' + lookupField + ' =: recordId AND Clip__c != null');
                Set<String> clipIdSet = new Set<String>();
                for(sObject objRec : objRecList){
                    clipIdSet.add(String.valueOf(objRec.get('Clip__c')));
                }
                //Tagged Info processing : Start
                Set<String> taggedObjApiNameSet = fetchTaggedObjApiNameSet(namespacePrefix);
                Map<String, String> objApiNameVsIconNameMap = new Map<String, String>();
                if(!Test.isRunningTest()){
                	objApiNameVsIconNameMap = fetchIconInfo(taggedObjApiNameSet);
                }
                    
                Map<String, List<ReferenceWrapper>> clipIdVsTaggedRecsMap = processClipsTaggedInfo(clipIdSet, objApiNameVsIconNameMap);
                //Tagged Info processing : End
                for(sObject objRec : objRecList){
                    ClipsReferencedWrapper clipsRefWrapper = new ClipsReferencedWrapper();
                    clipsRefWrapper.refWrapper = new ReferenceWrapper();
                    String clipId = String.valueOf(objRec.get('Clip__c'));
                    clipsRefWrapper.refWrapper.name = String.valueOf(objRec.getsObject('Clip__r').get(refField));
                    clipsRefWrapper.refWrapper.nameRef = '/' + clipId;
                    clipsRefWrapper.secFieldInfo = String.valueOf(objRec.getsObject('Clip__r').get(refField2));
                    clipsRefWrapper.notes = String.valueOf(objRec.getsObject('Clip__r').get('Notes__c'));
                    clipsRefWrapper.createdDate = String.valueOf(objRec.getsObject('Clip__r').get('CreatedDate'));
                    //Modified by Anshika Ahuja for Internal Sorting W.R.To Bug# 00034076 & 00034692
                    Map<String,ReferenceWrapper> sortedRefMap = new Map<String,ReferenceWrapper>();
                    List<String> sortedList = new List<String>();
                    List<ReferenceWrapper> sortedWrapList = new List<ReferenceWrapper>();
                    if(clipIdVsTaggedRecsMap.containsKey(clipId)){
                        for(ReferenceWrapper thisWrapper : clipIdVsTaggedRecsMap.get(clipId)){
                            sortedRefMap.put(thisWrapper.Name,thisWrapper);
                            sortedList.add(thisWrapper.Name);
                            sortedList.sort();   
                        }
                        for(String rec: sortedList){
                            sortedWrapList.add(sortedRefMap.get(rec));
                        }
                        clipsRefWrapper.tags = sortedWrapList;
                    }
                    
                    clipsRefWrapperList.add(clipsRefWrapper);
                }
                return clipsRefWrapperList;
            }
        } catch(Exception e) {
            throw new AuraHandledException(ERR_MSG + ' : <<' + e.getStackTraceString() + '>>');
        }
    }

    /*
     * Purpose : Processes the tagged records for given clips records
     * Input : clipIdSet               [Associated Clip record IDs to be processed]
     *         objApiNameVsIconNameMap [Map of object API name vs icon name]
     * Returns : Map<String, List<ReferenceWrapper> of clip ID vs tagged records info
     */
    private static Map<String, List<ReferenceWrapper>> processClipsTaggedInfo(Set<String> clipIdSet, Map<String, String> objApiNameVsIconNameMap){
        try {
            Map<String, List<ReferenceWrapper>> clipIdVsTaggedRecsMap = new Map<String, List<ReferenceWrapper>>();
            for(Clip_Relation__c clipRelRec : [SELECT Clip__c, Account__r.Name, Contact__r.Name, Deal__r.Name, Fund__r.Name, Fundraising__r.Name, User__r.Name FROM Clip_Relation__c WHERE Clip__c IN :clipIdSet]){
                List<ReferenceWrapper> refWrapperList = new List<ReferenceWrapper>();
                if(clipIdVsTaggedRecsMap.containsKey(clipRelRec.Clip__c)){
                    refWrapperList = clipIdVsTaggedRecsMap.get(clipRelRec.Clip__c);
                }
                Set<String> relObjApiNamesSet = new Set<String>{'Account__c', 'Contact__c', 'Deal__c', 'Fund__c', 'Fundraising__c', 'User__c'};
                for(String relObjApiName : relObjApiNamesSet){
                    if(clipRelRec.get(relObjApiName) != null){
                        ReferenceWrapper refWrap = new ReferenceWrapper();
                        String taggedRecId = String.valueOf(clipRelRec.get(relObjApiName));
                        refWrap.name = String.valueOf(clipRelRec.getSobject(relObjApiName.replace('__c', '__r')).get('Name'));
                        refWrap.nameRef = (relObjApiName != 'User__c')?'/' + taggedRecId:''; //Modified by Anshika Ahuja W.R.To Bug# 00034693
                        refWrap.type = String.valueOf(Id.valueOf(taggedRecId).getsobjecttype());
                        refWrap.iconName = relObjApiName.equalsIgnoreCase('User__c')
                                           ? 'standard:user'
                                           : objApiNameVsIconNameMap.get(refWrap.type);
                        refWrap.sortValue = getTagSortOrder(relObjApiName);
                        refWrapperList.add(refWrap);
                    }
                }
                clipIdVsTaggedRecsMap.put(clipRelRec.Clip__c, refWrapperList);
            }
            //For processing Theme tagged records
            for(Theme_Relation__c themeRelRec : [SELECT Clip__c, Theme__c, Theme__r.Name FROM Theme_Relation__c WHERE Clip__c IN :clipIdSet AND Theme__c != null]){
                List<ReferenceWrapper> refWrapperList = clipIdVsTaggedRecsMap.get(themeRelRec.Clip__c);
                ReferenceWrapper refWrap = new ReferenceWrapper();
                String taggedRecId = String.valueOf(themeRelRec.get('Theme__c'));
                refWrap.name = String.valueOf(themeRelRec.getSobject('Theme__r').get('Name'));
                refWrap.nameRef = '/' + taggedRecId;
                refWrap.type = String.valueOf(Id.valueOf(taggedRecId).getsobjecttype());
                refWrap.iconName = objApiNameVsIconNameMap.get('Themes');
                refWrap.sortValue = getTagSortOrder('Theme__c');
                refWrapperList.add(refWrap);
                clipIdVsTaggedRecsMap.put(themeRelRec.Clip__c, refWrapperList);
            }
            return clipIdVsTaggedRecsMap;
        } catch(Exception e) {
            throw new AuraHandledException(ERR_MSG + ' : <<' + e.getStackTraceString() + '>>');
        }
    }

    /************************* REFERENCED SECTION MAIN METHODS : END *************************/

    /************************* REFERENCED SECTION COMMON METHODS : START *************************/

    /*
     * Purpose : Fetches index for sorting the Clips Tagged
     * Input : objApiName      [Lookup field API name in Clip__c]
     * Returns : Sort order value
     */
    @TestVisible
    private static Integer getTagSortOrder(String objApiName){
        try{
            switch on objApiName{
                when 'Account__c'{
                    return 1;
                }
                when 'Contact__c'{
                    return 2;
                }
                when 'Deal__c'{
                    return 3;
                }
                when 'Fund__c'{
                    return 4;
                }
                when 'Fundraising__c'{
                    return 5;
                }
                when 'Theme__c'{
                    return 6;
                }
                when 'User__c'{
                    return 7;
                }
                when else{
                    return 8; //Modified by Anshika Ahuja W.R.To handle any custom object for Anurag bug #00035156
                }
            }
            
        } catch (Exception e) {
            throw new AuraHandledException(ERR_MSG + ' : <<' + e.getStackTraceString() + '>>');
        }
    }

    /*
     * Purpose : Fetches index for sorting the Tagged Records
     * Input : objApiName      [Tagged objects API Names]
     * Returns : Sort order value
     */
    //Added by Anshika Ahuja W.R.To Bug# 00033806
    @TestVisible
    private static Integer getTaggedSortOrder(String objApiName){
        try{
            switch on objApiName{
                when 'Account'{
                    return 1;
                }
                when 'Contact'{
                    return 2;
                }
                when 'navpeII_dev18__Pipeline__c'{
                    return 3;
                }
                when 'navpeII_dev18__Fund__c'{
                    return 4;
                }
                when 'navpeII_dev18__Fundraising__c'{
                    return 5;
                }
                when 'navpeII_dev18__Theme__c'{ //Modified by Omkar for Anurag Bug 00039889
                    return 6;
                }
                when 'User'{
                    return 7;
                }
                when else{
                    return 8; //Modified by Anshika Ahuja W.R.To handle any custom object for anurag bug #00035138
                }
            }
            
        } catch (Exception e) {
            throw new AuraHandledException(ERR_MSG + ' : <<' + e.getStackTraceString() + '>>');
        }
    }

    /*
     * Purpose : Finds activity records to be processed
     * Input : conIdList    [List of related records of the main object to be processed]
     *         objName      [Activity type (Task/Event)]
     *         whereClause  [Where clause to be used in the SOQL query]
     * Returns : List<String> containing activity IDs to be processed
     */
    public static List<String> fetchRecsToProcess(List<String> conIdList, String objName, String whereClause){
        try {
            List<String> actIdList = new List<String>();
            for(sObject actRec : Database.query('SELECT ' + objName + 'Id FROM ' + objName + 'Relation' + whereClause + ' AND IsDeleted = false ORDER BY CreatedDate DESC ALL ROWS')){
                actIdList.add(String.valueOf(actRec.get(objName + 'Id')));
            }
            return actIdList;
        } catch (Exception e) {
            throw new AuraHandledException(ERR_MSG + ' : <<' + e.getStackTraceString() + '>>');
        }
    }

    /*
     * Purpose : Finds activity records to be processed
     * Input : recordId     [Given object's records to be processed]
     *         objName      [Activity type (Task/Event)]
     *         whereClause  [Where clause to be used in the SOQL query]
     * Returns : List<String> containing activity IDs to be processed
     */
    public static List<String> fetchRecsToProcess(String recordId, String objName, String whereClause){
        try {
            List<String> actIdList = new List<String>();
            for(sObject actRec : Database.query('SELECT ' + objName + 'Id FROM ' + objName + 'Relation' + whereClause + ' AND IsDeleted = false ORDER BY CreatedDate DESC ALL ROWS')){
                actIdList.add(String.valueOf(actRec.get(objName + 'Id')));
            }
            return actIdList;
        } catch (Exception e) {
            throw new AuraHandledException(ERR_MSG + ' : <<' + e.getStackTraceString() + '>>');
        }
    }

    /*
     * Purpose : Maps related object along side activity IDs set
     * Input : ids      [Related Object IDs to be processed]
     *         actId    [Activity ID to be mapped]
     * Returns : N/A
     */
    private static void processRelObjIds(String ids, ID actId){
        try {
            for(String recId : ids.split(',')){
                Set<String> idSet = new Set<String>();
                if(objIdVsActIdsMap.containsKey(recId)){
                    idSet = objIdVsActIdsMap.get(recId);
                } else {
                    idSet = new Set<String>();
                }
                idSet.add(actId);
                objIdVsActIdsMap.put(recId, idSet);
            }
        } catch (Exception e) {
            throw new AuraHandledException(ERR_MSG + ' : <<' + e.getStackTraceString() + '>>');
        }
    }

    /*
     * Purpose : Maps related object along side activity IDs set
     * Input : namespacePrefix  [Namespaceprefix to be used]
     *         objName          [Deal object API name]
     *         accountIdSet     [Account IDs set to be processed]
     * Returns : N/A
     */
    private static void processAccAssociatedToDeals(String namespacePrefix, String objName, Set<String> accountIdSet){
        try {
            for(sObject objRec : Database.query('SELECT ' + namespacePrefix + 'Company__c FROM ' + objName + ' WHERE ' + namespacePrefix + 'Company__c IN :accountIdSet AND Active__c = true')){
                accIdSet.add(String.valueOf(objRec.get(namespacePrefix + 'Company__c')));
            }
        } catch(Exception e) {
            throw new AuraHandledException(ERR_MSG + ' : <<' + e.getStackTraceString() + '>>');
        }
    }

    /*
     * Purpose : Prepares final map of the data to be displayed under Referenced Section
     * Input : objName  [Relation object to be queries (Account/Contact/Deal)]
     *         refField [Referenced field to be used for displaying name kind of data]
     * Returns : List<InfoWrapper> containing info about each record to be displayed in data tables under Referenced Section
     */
    private static List<InfoWrapper> prepareFinalMap(String objName, String refField){
        try {
            List<InfoWrapper> infoWrapperList = new List<InfoWrapper>();
            List<String> objIdList = new List<String>();
            objIdList.addAll(objIdVsActIdsMap.keySet());
            for(sObject objRec : Database.query('SELECT Id, ' + refField + ' FROM ' + String.escapeSingleQuotes(objName) + ' WHERE Id IN :objIdList')){
                String recId = String.valueOf(objRec.get('Id'));
                List<String> actIdList = new List<String>();
                actIdList.addAll(objIdVsActIdsMap.get(recId));
                String refFieldValue = String.valueOf(objRec.get(refField));
                //Added above line and changed the 1st parameter of constructor to display '[No value]' in case of empty text
                infoWrapperList.add(new InfoWrapper(String.isNotBlank(refFieldValue) ? refFieldValue : '[No value]', '/' + recId, objIdVsActIdsMap.get(recId).size(), actIdList, accIdSet.contains(recId)));
            }
            return infoWrapperList;
        } catch (Exception e) {
            throw new AuraHandledException(ERR_MSG + ' : <<' + e.getStackTraceString() + '>>');
        }
    }

    /************************* REFERENCED SECTION COMMON METHODS : END *************************/

    /************************* CONTACTS/CONNECTIONS SECTION METHODS : START *************************/
    
    /*
     * Purpose : Processes info for Contacts/Connections section
     * Input : conMap           [Initial info to be used for processing final map]
     *         recordId         [Null in case of Account record Page; Contact record ID in case of Contact Page]
     *         metadataField1   [Field 1 to process for Contact/Connections Section]
     *         otherMetadataFields [Other fields to process for Contact/Connections Section]
     *         namespacePrefix  [Namespaceprefix to be used]
     *         conEmail         [Email ID of Contact]
     *         actIdList        [Activity IDs to be processed]
     *         tfVal            [Deciding parameter for Email datapoint calculation]
     *         objApiName       [API name of the current record (Account/Contact/Deal/Fund/Fundraising)]
     *         calledFrom       [Instance from where the method is being called (PageLoad/IC/EC)]
     * Returns : Info to be displayed in Contacts/Connections section as a List<ConWrapper>
     */
    @AuraEnabled
    public static ResponseWrapper processConInfo(Map<String, sObject> conMap, String recordId, String metadataField1, String otherMetadataFields, String namespacePrefix, String conEmail, List<String> actIdList, Boolean tfVal, String objApiName, String calledFrom, List<String> parentConIdList){
        try {
            ResponseWrapper respWrapper = new ResponseWrapper();
            //respWrapper.isEmailDrillDownEnabled = Boolean.valueOf(RG_Setting__mdt.getInstance('Acuity_Enable_RG_Email_Details').Value__c);
            //Replaced above line with 2 below lines by LK on 2024-10-10 to fix 00047721
            String enableRgEmailDetails = RG_Setting__mdt.getInstance('Acuity_Enable_RG_Email_Details').Value__c;
            respWrapper.isEmailDrillDownEnabled = enableRgEmailDetails == null || !enableRgEmailDetails.equalsIgnoreCase('false');
            String refField = Acuity_Setting__mdt.getInstance(metadataField1).Value__c;
            if(String.isBlank(refField)){
                return null;
            } else {
                List<String> fieldList = otherMetadataFields.split(',');
                String refField2 = Acuity_Setting__mdt.getInstance(fieldList.get(0)).Value__c;
                String refField3; //Modifed by Anshika Ahuja W.R.To Bug #00034852
                String refField4;
                if(String.isNotBlank(refField2)){
                    respWrapper.conSecDynFieldHeader = objApiName.equalsIgnoreCase(namespacePrefix + 'Fundraising__c')
                                                       ? fetchFieldLabel(calledFrom.equalsIgnoreCase('IC') ? 'User' : calledFrom.equalsIgnoreCase('PageLoad') ? namespacePrefix+'Fundraising_Contact__c' : 'Contact', refField2)
                                                       : fetchFieldLabel(calledFrom.equalsIgnoreCase('PageLoad') || calledFrom.equalsIgnoreCase('EC') ? 'Contact' : 'User', refField2);   
                }
                objIdVsActIdsMap = new Map<String, Set<String>>();
                List<ConWrapper> nonSfConWrapperList = new List<ConWrapper>();
                if(objApiName.equalsIgnoreCase('Account')){
                    //For Meeting Call Datapoint calculation
                    if(calledFrom.equalsIgnoreCase('IC')){
                        processMeetingCallInfo(actIdList, 'Event', recordId, ' WHERE EventId IN :actIdList AND (Relation.Type = \'Contact\' OR Relation.Type = \'User\')');
                        processMeetingCallInfo(actIdList, 'Task', recordId, ' WHERE TaskId IN :actIdList AND Task.TaskSubType = \'Call\'');
                    } else {
                    	processMeetingCallInfo(actIdList, 'Event', recordId, ' WHERE EventId IN :actIdList AND Relation.Type = \'Contact\'');
                        processMeetingCallInfo(actIdList, 'Task', recordId, ' WHERE TaskId IN :actIdList AND Task.TaskSubType = \'Call\' AND Relation.Type = \'Contact\'');    
                    }
                    //For Email Datapoint calculation
                    if(calledFrom.equalsIgnoreCase('IC')){// added IC removed tfval==true
                        try {
                            getUsersListOfRecords(conEmail, 'Contact', recordId, namespacePrefix); 
                        } catch(Exception e) {
                            respWrapper.apiError = true;
                        }
                    } else {
                        try {
                            if(calledFrom.equalsIgnoreCase('PageLoad')){ //removed not calledFrom.equalsIgnoreCase('EC') || Shivam
                                nonSfConWrapperList = countInboundAndOutboundMethod(recordId, namespacePrefix, conMap);
                            }
                        } catch(Exception e) {
                            respWrapper.apiError = true;
                        }
                    }
                } else if(objApiName.equalsIgnoreCase('Contact') || objApiName.equalsIgnoreCase(namespacePrefix + 'Pipeline__c')){//fixed critical Shivam bug #00035184
                    //For Meeting Call Datapoint calculation
                    processMeetingCallInfo(actIdList, 'Event', recordId, ' WHERE EventId IN :actIdList AND (Relation.Type = \'Contact\' OR Relation.Type = \'User\')');
                    processMeetingCallInfo(actIdList, 'Task', recordId, ' WHERE TaskId IN :actIdList AND Task.TaskSubType = \'Call\'');
                    //For Email Datapoint calculation
                    try {
                        getUsersListOfRecords(conEmail, 'Contact', recordId, namespacePrefix);
                    } catch(Exception e) {
                        respWrapper.apiError = true;
                    }
                } else if(objApiName.equalsIgnoreCase(namespacePrefix + 'Fundraising__c')){
                    refField3 = (fieldList.size() >= 2)?Acuity_Setting__mdt.getInstance(fieldList.get(1)).Value__c:'';
                    refField4 = (fieldList.size() >= 3)?Acuity_Setting__mdt.getInstance(fieldList.get(2)).Value__c:'';
                    if(String.isNotBlank(refField3)){
                        if(refField3.contains('__r.')){
                            respWrapper.conSecDynFieldHeader2 = fetchFieldLabel('Contact', refField3.split('__r.').get(1));    
                        }
                    }
                    if(String.isNotBlank(refField4)){
                        respWrapper.conSecDynFieldHeader3 = fetchFieldLabel(namespacePrefix+'Fundraising_Contact__c', refField4);
                    }
                    //For Meeting Call Datapoint calculation

                    System.debug('conMap '+conMap);
                    Set<String> setOfCon = new Set<String>();
                    //Moved existing code inside if clause by LK on 2024-06-10 to fix 00046059
                    if(calledFrom.equalsIgnoreCase('PageLoad')){
                    
                    for(sObject con : conMap.values()){
                        if(con.getSObject('navpeII_dev18__Contact__r').get('Id') != null){
                            setOfCon.add(String.valueOf(con.getSObject('navpeII_dev18__Contact__r').get('Id')));
                        }
                    }
                    System.debug('setOfCon '+setOfCon);
                    //Bug Id - 00042625 fixed by Deepak
                    actIdList = fetchRecsToProcess2(new List<String>(setOfCon), 'Event');
					}
					
                    processMeetingCallInfo(actIdList, 'Event', recordId, ' WHERE EventId IN :actIdList AND (Relation.Type = \'Contact\' OR Relation.Type = \'User\')');// critical resolved by Shivam bug #00035187
                    if(Schema.getGlobalDescribe().get('TaskRelation') != null){
                        //Moved existing code inside if clause by LK on 2024-06-10 to fix 00046059
                        if(calledFrom.equalsIgnoreCase('PageLoad')){
                        	actIdList = fetchRecsToProcess2(new List<String>(setOfCon), 'Task');
                        }
                        processMeetingCallInfo(actIdList, 'Task', recordId, ' WHERE TaskId IN :actIdList AND Task.TaskSubType = \'Call\'');
                    }
                    //added by Shivam
                    if(calledFrom.equalsIgnoreCase('IC')){
                        try{
                            getUsersListOfRecords(conEmail, 'Contact', recordId, namespacePrefix);
                        } catch(Exception e) {
                            respWrapper.apiError = true;
                        }
                        
                    }
                }
                //For Deal Datapoint calculation
                if(objApiName.equalsIgnoreCase('Account') || objApiName.equalsIgnoreCase('Contact')|| objApiName.equalsIgnoreCase(namespacePrefix + 'Fundraising__c') || objApiName.equalsIgnoreCase(namespacePrefix + 'Pipeline__c')){
                    if(conMap != null){
                        if(calledFrom.equalsIgnoreCase('PageLoad')){
                            getWrapperContactDealInformation(objApiName.equalsIgnoreCase('Account') ? '' : String.escapeSingleQuotes(recordId), String.escapeSingleQuotes(namespacePrefix), conMap.keySet(), calledFrom);//added CalledFrom By shivam defect #00038728
                        }else{
                            getWrapperContactDealInformation(String.escapeSingleQuotes(recordId), String.escapeSingleQuotes(namespacePrefix), conMap.keySet(), calledFrom);//added CalledFrom By shivam defect #00038728
                        }
                    }
                }
                //For Deal Datapoint calculation (Fundraising)
                if(objApiName.equalsIgnoreCase(namespacePrefix + 'Fundraising__c') && calledFrom.equalsIgnoreCase('PageLoad') ){
                    try{
                        handleFundRaisingOnLoad(recordId, calledFrom);
                    } catch(Exception e){}
                }
                /* Commented by shivam
                if((calledFrom.equalsIgnoreCase('IC') || calledFrom.equalsIgnoreCase('EC')) && conMap != null){
                    processConLastInteractionInfo(calledFrom.equalsIgnoreCase('IC') ? 'User' : 'Contact', conMap);
                } */
                //Modified w.r.to Fundraising contact section with Shivam
                List<ConWrapper> conWrapperList = objApiName.equalsIgnoreCase('Account') || objApiName.equalsIgnoreCase('Contact') || (objApiName.equalsIgnoreCase(namespacePrefix + 'Fundraising__c') && (calledFrom.equalsIgnoreCase('IC') || calledFrom.equalsIgnoreCase('EC'))) || (objApiName.equalsIgnoreCase(namespacePrefix + 'Pipeline__c')) // && calledFrom.equalsIgnoreCase('IC') shivam
                                                  ? prepareConFinalMap(conMap, refField, refField2, namespacePrefix)
                                                  : prepareFdrConFinalMap(conMap, refField, refField2, refField3, refField4, namespacePrefix);
                /* RG : START */
                if(nonSfConWrapperList != null){
                    conWrapperList.addAll(nonSfConWrapperList);
                }
                /* RG : END */
                respWrapper.conInfoWrapper = conWrapperList;
                //added by shivam
                
                if(IsApiError){
                    respWrapper.apiError = true;
                }
                return respWrapper;
            }
        } catch (Exception e) {
            throw new AuraHandledException(ERR_MSG + ' : <<' + e.getStackTraceString() + '>>');
        }
    }

    /*
     * Purpose : Processes last interaction info (Date & Note)
     * Input : objName      [Object name (User/Contact)]
     *         conIdSet     [Contact ID list to be processed (For Contact only)]
     *         actIdList    [Activity ID list to be processed]
     * Returns : N/A
     */
    /*private static void processConLastInteractionInfo(String objName, Map<String, sObject> conMap){
        try {
            //Preparing activity IDs set to be processed
            Set<String> actIdSet = new Set<String>();
            Set<String> conIdSet = new Set<String>();
            if(conMap.keySet().size() > 0){
                conIdSet.addAll(conMap.keySet());
            }
            for(sObject objRec : Database.query('SELECT Last_Touchpoint_ID__c FROM ' + objName + ' WHERE Id IN :conIdSet AND Last_Touchpoint_ID__c != null')){
                actIdSet.add(String.valueOf(objRec.get('Last_Touchpoint_ID__c')));
            }
            //Preparing activity ID vs Description map for the processed activity IDs
            Map<String, String> actIdVsNoteMap = new Map<String, String>();
            for(sObject actObjRec : Database.query('SELECT Id, Description FROM Task WHERE ID IN :actIdSet')){
                actIdVsNoteMap.put(String.valueOf(actObjRec.get('Id')), String.valueOf(actObjRec.get('Description')));
            }
            for(sObject actObjRec : Database.query('SELECT Id, Description FROM Event WHERE ID IN :actIdSet')){
                actIdVsNoteMap.put(String.valueOf(actObjRec.get('Id')), String.valueOf(actObjRec.get('Description')));
            }
            //Preparing map of the object ID vs Last Interaction Info
            String LAST_TOUCHPOINT_REF_FIELD = objName.equalsIgnoreCase('User')
                                               ? 'Last_Touchpoint__c'
                                               : 'navpeII_dev18__Last_Touch_Point__c';
            for(String recId : conMap.keySet()){
                String lastInteractionDate = String.valueOf(conMap.get(recId).get(LAST_TOUCHPOINT_REF_FIELD));
                String lastInteractionNote = actIdVsNoteMap.get(String.valueOf(conMap.get(recId).get('Last_Touchpoint_ID__c')));
                String lastInteractionId = String.valueOf(conMap.get(recId).get('Last_Touchpoint_ID__c'));
                String lastInteractionType = String.isNotBlank(lastInteractionId)
                                             ? String.valueOf(Id.valueOf(lastInteractionId).getsobjecttype())
                                             : '';
                objIdVsLastInteractionInfoMap.put(String.valueOf(recId), new LastInteractionInfo(lastInteractionDate, lastInteractionNote, lastInteractionId, lastInteractionType));
            }
        } catch (Exception e) {
            throw new AuraHandledException(ERR_MSG + ' : <<' + e.getStackTraceString() + '>>');
        }
    }
*/
    /*
     * Purpose : Handles the Internal Connections information on Contacts Section of Account & Connections Section of Contact object
     * Input : recordId          [Contact record ID]
     *         objApiName        [API name of the current record (Account/Contact/Deal/Fund/Fundraising)]
     *         namespacePrefix   [Namespaceprefix to be used]
     *         email             [Email ID of Contact]
     *         actIdList         [Activity IDs to be processed]
     * Returns : Info to be displayed on Internal Connections popup as a ResponseWrapper
     */
    @AuraEnabled
    public static ResponseWrapper handleInternalConnInfo(String recordId, String objApiName, String namespacePrefix, String email, List<String> actIdList){
        try {
            Map<String, sObject> conMap = new Map<String, sObject>();
            conMap = fetchInitInfoToProcess('Acuity_Connection_IntTab_Field1', 'Acuity_Connection_IntTab_Field2', 'User', '', '', null);
            return processConInfo(conMap, String.escapeSingleQuotes(recordId), 'Acuity_Connection_IntTab_Field1', 'Acuity_Connection_IntTab_Field2', String.escapeSingleQuotes(namespacePrefix), email, actIdList, String.isBlank(recordId), objApiName, 'IC', null);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    /*
     * Purpose : Handles the External Connections information on Contacts Section of Account & Connections Section of Contact object
     * Input : recordId          [Contact record ID]
     *         objApiName        [API name of the current record (Account/Contact/Deal/Fund/Fundraising)]
     *         namespacePrefix   [Namespaceprefix to be used]
     *         email             [Email ID of Contact]
     * Returns : Info to be displayed on External Connections popup as a ResponseWrapper
     */
    @AuraEnabled
    public static ResponseWrapper handleExternalConnInfo(String recordId, String objApiName, String namespacePrefix, String email, List<String> actIdList){
        try {
            ResponseWrapper respWrapperNonSf = new ResponseWrapper();
            try{
                respWrapperNonSf = objApiName.equalsIgnoreCase('Account')
                    ? handleExternalConnInfoRG(email, 'Acuity_Connection_ExtTab_Field1', 'Acuity_Connection_ExtTab_Field2')
                    : handleExternalConnInfoRG(email, 'Acuity_Connection_ExtTab_Field1', 'Acuity_Connection_ExtTab_Field2');
            } catch(Exception e){
                respWrapperNonSf.apiError = true;
            }

            if(respWrapperNonSf.conMap != null){
                respWrapperNonSf.conMap.putAll(getExternalConnInSf(String.escapeSingleQuotes(recordId), String.escapeSingleQuotes(namespacePrefix),actIdList));
            } else{
                respWrapperNonSf.conMap = getExternalConnInSf(String.escapeSingleQuotes(recordId), String.escapeSingleQuotes(namespacePrefix), actIdList);
            } 
            if(respWrapperNonSf != null){
                List<ConWrapper> conWrapperList = new List<ConWrapper>();
                if(respWrapperNonSf.conInfoWrapper != null){
                    conWrapperList.addAll(respWrapperNonSf.conInfoWrapper);
                }
                List<String> conIdList = new List<String>();
                if(respWrapperNonSf.conMap != null){
                    conIdList.addAll(respWrapperNonSf.conMap.keyset());
                }
                /*
                List<String> actIdList = new List<String>();
                List<String> taskIdList = new List<String>();
                List<String> evIdList = new List<String>();
                //For handling events
                evIdList = fetchRecsToProcess(conIdList, 'Event', ' WHERE (Relation.Type = \'Contact\') AND (RelationId IN :conIdList)');
                //For handling tasks
                taskIdList = fetchRecsToProcess(conIdList, 'Task', ' WHERE (Task.TaskSubType != \'ListEmail\') AND (Relation.Type = \'Contact\') AND (RelationId IN :conIdList)');
                if(evIdList.size() > 0){
                    actIdList.addAll(evIdList);
                }
                if(taskIdList.size() > 0){
                    actIdList.addAll(taskIdList);
                }
                */
                ResponseWrapper respWrapperSf = processConInfo(respWrapperNonSf.conMap, String.escapeSingleQuotes(recordId), 'Acuity_Connection_ExtTab_Field1', 'Acuity_Connection_ExtTab_Field2', String.escapeSingleQuotes(namespacePrefix), email, actIdList, String.isBlank(recordId), objApiName, 'EC', null);
                if(respWrapperSf.conInfoWrapper != null){
                    List<conWrapper> filteredCrossDomainData = filterCrossDomainData(respWrapperSf.conInfoWrapper,email,String.escapeSingleQuotes(recordId));
                    if(filteredCrossDomainData != null){
                        conWrapperList.addAll(filteredCrossDomainData);
                    }
                    //conWrapperList.addAll(respWrapperSf.conInfoWrapper);
                }
                //if(!conWrapperList.isEmpty()){ Modified by Shivam 14-04-2023
                    respWrapperSf.conInfoWrapper = conWrapperList;
                //}
                return respWrapperSf;
            } else {
                return null;
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    private static List<conWrapper> filterCrossDomainData(List<conWrapper> cnWrapper, String email,String recordId){
        List<ConWrapper> selfRemovedData = new List<ConWrapper>();
        List<ConWrapper> filteredCrossDomainData = new List<ConWrapper>();
        if(!cnWrapper.isEmpty()){
            for(ConWrapper cw : cnWrapper){
                if(! cw.recId.equals(recordId)){
                    selfRemovedData.add(cw);
                }
            }
            if(String.IsBlank(email)){
                return selfRemovedData;
            }else{
                //if(String.isBlank(apiKey)){
                    String domain = email.split('@')[1];
                    for(ConWrapper cw : selfRemovedData){
                        if(cw.email != null){                           
                            if(! String.valueOf(cw.email.split('@')[1]).equalsIgnoreCase(domain)){                             
                                filteredCrossDomainData.add(cw);
                            }
                        }else{
                            filteredCrossDomainData.add(cw);
                        }
                    //}
                }                
            }            
        }
        return filteredCrossDomainData;
    }


    /*
     * Method to fetch the External tab contacts data
    */
    public static map<String,Sobject> getExternalConnInSf(String recordId, String namespacePrefix, List<String> actIdList){
        try {
            Map<String,sObject> conMap = new Map<String,sObject>();
            if(String.isNotBlank(recordId)){
                String getDealQuery = 'Select '+String.escapeSingleQuotes(namespacePrefix)+'Deal__c From '+String.escapeSingleQuotes(namespacePrefix)+'Deal_Team__c Where '+String.escapeSingleQuotes(namespacePrefix)+'Deal_Contact__c = \''+String.escapeSingleQuotes(recordId) + '\' AND ' + String.escapeSingleQuotes(namespacePrefix) + 'Deal__c != null';
                List<sObject> contactDeals = Database.query(getDealQuery);
                List<String> dealIds = new List<String>();
                for(sObject listDeal : contactDeals){
                    dealIds.add(listDeal.get(namespacePrefix+'Deal__c').toString());
                }
                List<String> conIds = new List<String>();
                if(!dealIds.isEmpty()) {
                    String getConQuery = 'Select '+String.escapeSingleQuotes(namespacePrefix)+'Deal_Contact__c, '+String.escapeSingleQuotes(namespacePrefix)+'Deal__c From '+String.escapeSingleQuotes(namespacePrefix)+'Deal_Team__c Where '+String.escapeSingleQuotes(namespacePrefix)+'Deal__c In :dealIds';
                    List<sObject> dealsCon = Database.query(getConQuery);                    
                    for(sObject thisCase : dealsCon){
                        if(thisCase.get((namespacePrefix+'Deal_Contact__c')) != null && thisCase.get((namespacePrefix+'Deal_Contact__c')) != recordId){
                            conIds.add(thisCase.get(namespacePrefix+'Deal_Contact__c').toString());
                        }
                    }
                }               
                
                processMeetingCallInfo(actIdList, 'Event', recordId, ' WHERE EventId IN :actIdList AND Relation.Type = \'Contact\'');
                if(Schema.getGlobalDescribe().get('TaskRelation') != null){
                	processMeetingCallInfo(actIdList, 'Task', recordId, ' WHERE TaskId IN :actIdList AND Task.TaskSubType = \'Call\' AND Relation.Type = \'Contact\'');    
                }
                for(string str : objIdVsActIdsMap.keySet()){
                    if(str.startsWith('003')){
                        conIds.add(str);
                    }
                }
                
                if(conIds.size() > 0){
                    conMap = new Map<String, sObject>(Database.query('SELECT Id, AccountId, Account.Name, Email,Title,Name,phone ' +', FORMAT(' + namespacePrefix + 'Last_Touch_Point__c), Last_Touchpoint_ID__c FROM Contact WHERE Id IN :conIds LIMIT 50000'));//fixed security issue shivam  
                }
            }
        return conMap;
            
    } catch(Exception ex) {
        throw new AuraHandledException(ex.getStackTraceString());
    }
    }

    /************************* CONTACTS/CONNECTIONS SECTION MAIN METHODS : END *************************/

    /************************* CONTACTS/CONNECTIONS SECTION COMMON METHODS : START *************************/

    /*
     * Purpose : Processes info for meeting & calls datapoint
     * Input : actIdList    [Activity IDs to be processed]
     *         objName      [Activity type (Task/Event)]
     *         recordId     [Null in case of Account record Page; Contact record ID in case of Contact Page]
     *         whereClause  [Where clause to be used in the SOQL query]
     * Returns : N/A
     */
    private static void processMeetingCallInfo(List<String> actIdList, String objName, String recordId, String whereClause){
        try {
            Integer processedRecCount = 0;
            //Modified the for loop on 2022-10-06 to fix the Assigned To issue
            for(sObject actRec : Database.query('SELECT Id, OwnerId, (SELECT RelationId FROM ' + objName + 'Relations' + whereClause + ' AND IsDeleted = false) FROM ' + objName + ' WHERE Id IN :actIdList AND IsDeleted = false ALL ROWS')){
                if(Limits.getCpuTime() < ALLOWED_CPU_TIME){
                    for(sObject actRelRec : actRec.getSObjects(objName + 'Relations')){
                        processRelObjIds(String.valueOf(actRelRec.get('RelationId')), String.valueOf(actRec.get('Id')));
                        if(String.isNotBlank(recordId)){
                            processRelObjIds(String.valueOf(actRec.get('OwnerId')), String.valueOf(actRec.get('Id')));
                        }
                    }
                    processedRecCount++;
                } else {
                    system.debug('--->' + objName + ' > ' + processedRecCount + ' records processed in processMeetingCallInfo().');
                    break;
                }
            }
        } catch (Exception e) {
            throw new AuraHandledException(ERR_MSG + ' : <<' + e.getStackTraceString() + '>>');
        }
    }

    /*
     * Purpose : Processes the page load info like Contact Details / User Details to be displayed.
     * Input Parameter : AccountId / ContactId.
     * Returns : Info to be displayed on page load as a Response Wrapper.
    */
    //Shivam added RG related Changes defect #00038728
    private static void getWrapperContactDealInformation(String recordId, String namespacePrefix, Set<String> conIdSet,String calledFrom){
        try {
            if(Schema.sObjectType.navpeII_dev18__Pipeline__c.isAccessible()){    
                if(String.isNotBlank(recordId)){
                    getWrapperContactUserDealCount(String.escapeSingleQuotes(recordId), namespacePrefix, calledFrom);
                } else if(String.isBlank(recordId) && (String.isBlank(calledFrom) || (String.isNotBlank(calledFrom) && calledFrom.equalsIgnoreCase('pageLoad')))) {
                    String dealQueryString = 'Select '+String.escapeSingleQuotes(namespacePrefix)+'Deal_Contact__c, '+String.escapeSingleQuotes(namespacePrefix)+'Deal__c from '+String.escapeSingleQuotes(namespacePrefix)+'Deal_Team__c where '+String.escapeSingleQuotes(namespacePrefix)+'Deal_Contact__c IN :conIdSet AND ' + String.escapeSingleQuotes(namespacePrefix) + 'Deal__c != null';
                    List<sObject> lstDealTeams = new List<sObject>();
                    lstDealTeams = Database.query(dealQueryString);
                    for(sObject thisCase : lstDealTeams){
                        if(thisCase.get(namespacePrefix+'Deal_Contact__c') != null){
                            if(!objIdVsDealIdsMap.containsKey(thisCase.get(namespacePrefix+'Deal_Contact__c').toString())){
                                objIdVsDealIdsMap.put(thisCase.get(namespacePrefix+'Deal_Contact__c').toString(),new Set<String>());
                            }
                            if(!objIdVsDealIdsMap.get(thisCase.get(namespacePrefix+'Deal_Contact__c').toString()).contains(thisCase.get(namespacePrefix+'Deal__c').toString())){
                                objIdVsDealIdsMap.get(thisCase.get(namespacePrefix+'Deal_Contact__c').toString()).add(thisCase.get(namespacePrefix+'Deal__c').toString());
                            }
                        }
                    }
                }
            }
        } catch(Exception ex){
            throw new AuraHandledException(ex.getStackTraceString());
        }
    }

    /*
     * Purpose : Get Dynamic info for User Details to be displayed
     * Input Parameter : ContactId
     * Returns : Info to be displayed on page load as a Response Wrapper
    */
    @testVisible //Added by Shivam RG related defect #00038728
    private static void getWrapperContactUserDealCount(String recordId, String namespacePrefix, String calledFrom){
        List<ConWrapper> conWrapperUserList = new List<ConWrapper>();
        try {
            String getDealQuery = 'Select '+String.escapeSingleQuotes(namespacePrefix)+'Deal__c From '+String.escapeSingleQuotes(namespacePrefix)+'Deal_Team__c Where '+String.escapeSingleQuotes(namespacePrefix)+'Deal_Contact__c = \''+String.escapeSingleQuotes(recordId) + '\' AND ' + String.escapeSingleQuotes(namespacePrefix) + 'Deal__c != null';
            List<sObject> contactDeals = Database.query(getDealQuery);
            List<String> dealIds = new List<String>();
            for(sObject listDeal : contactDeals){
                dealIds.add(listDeal.get(namespacePrefix+'Deal__c').toString());
            }
            // Bug 00031648/00031643 fixed by Shivam +namespacePrefix+'Team_Member__r.IsActive = true';
            if(calledFrom.equalsIgnoreCase('IC') || calledFrom.equalsIgnoreCase('pageLoad')){
                String getUserQuery = 'Select '+String.escapeSingleQuotes(namespacePrefix)+'Team_Member__c, '+String.escapeSingleQuotes(namespacePrefix)+'Team_Member__r.Name, '+String.escapeSingleQuotes(namespacePrefix)+'Team_Member__r.Id, '+String.escapeSingleQuotes(namespacePrefix)+'Team_Member__r.UserRole.Name, '+String.escapeSingleQuotes(namespacePrefix)+'Deal__c From '+String.escapeSingleQuotes(namespacePrefix)+'Deal_Team__c Where '+String.escapeSingleQuotes(namespacePrefix)+'Deal__c In :dealIds';
                List<sObject> dealsUser = Database.query(getUserQuery);
                List<String> userIds = new List<String>();
                for(sObject thisCase : dealsUser){
                    if(thisCase.get(namespacePrefix+'Team_Member__c') != null){
                        if(!objIdVsDealIdsMap.containsKey(thisCase.get(namespacePrefix+'Team_Member__c').toString())){
                            objIdVsDealIdsMap.put(thisCase.get(namespacePrefix+'Team_Member__c').toString(),new Set<String>());
                        }
                        if(!objIdVsDealIdsMap.get(thisCase.get(namespacePrefix+'Team_Member__c').toString()).contains(thisCase.get(namespacePrefix+'Deal__c').toString())){
                            objIdVsDealIdsMap.get(thisCase.get(namespacePrefix+'Team_Member__c').toString()).add(thisCase.get(namespacePrefix+'Deal__c').toString());
                        }
                    }
                }
            }else if(calledFrom.equalsIgnoreCase('EC')){
                String getConQuery = 'Select '+String.escapeSingleQuotes(namespacePrefix)+'Deal_Contact__c, '+String.escapeSingleQuotes(namespacePrefix)+'Deal__c From '+String.escapeSingleQuotes(namespacePrefix)+'Deal_Team__c Where '+String.escapeSingleQuotes(namespacePrefix)+'Deal__c In :dealIds';
                List<sObject> dealsCon = Database.query(getConQuery);
                List<String> conIds = new List<String>();
                for(sObject thisCase : dealsCon){
                    if(thisCase.get(namespacePrefix+'Deal_Contact__c') != null){
                        system.debug('Shivam11'+thisCase.get(namespacePrefix+'Deal_Contact__c').toString());
                        if(!objIdVsDealIdsMap.containsKey(thisCase.get(namespacePrefix+'Deal_Contact__c').toString())){
                            objIdVsDealIdsMap.put(thisCase.get(namespacePrefix+'Deal_Contact__c').toString(),new Set<String>());
                        }
                        if(!objIdVsDealIdsMap.get(thisCase.get(namespacePrefix+'Deal_Contact__c').toString()).contains(thisCase.get(namespacePrefix+'Deal__c').toString())){
                            objIdVsDealIdsMap.get(thisCase.get(namespacePrefix+'Deal_Contact__c').toString()).add(thisCase.get(namespacePrefix+'Deal__c').toString());
                        }
                    }
                }
            }
        } catch(Exception ex) {
            throw new AuraHandledException(ex.getStackTraceString());
        }
    }

    /*
     * Purpose : Processes the page load info like Contact Details related to Deal to be displayed
     * Input Parameter : List of Deals
     * Returns : Info to be displayed on page load as a Response Wrapper
     */
    @AuraEnabled(cacheable=true)
    public static DealsWrapper getDealTeamInfo(List<String> dealList, String namespacePrefix){
        DealsWrapper dealsWrap = new DealsWrapper();
        String dealObject;
        String fields;
        String mtdRecIdentifier;
        try {
            for(Acuity_Setting__mdt connNavSttng:[Select DeveloperName, Value__c from Acuity_Setting__mdt where DeveloperName like '%Acuity_Connection_DC%']){
                mtdRecIdentifier=(connNavSttng.DeveloperName.contains('Acuity_Connection_DC')?'Acuity_Connection_DC_Field':null);
                dealObject=(connNavSttng.DeveloperName.contains('Acuity_Connection_DC')?namespacePrefix+'Pipeline__c':null);
                dealsWrap.fieldHeader1 = fetchFieldLabel(dealObject, getFieldApiName(mtdRecIdentifier+'1',''));
                dealsWrap.fieldHeader2 = fetchFieldLabel(dealObject, getFieldApiName(mtdRecIdentifier+'2',''));
                dealsWrap.fieldHeader3 = fetchFieldLabel(dealObject, getFieldApiName(mtdRecIdentifier+'3',''));
                dealsWrap.fieldHeader4 = fetchFieldLabel(dealObject, getFieldApiName(mtdRecIdentifier+'4',''));
                dealsWrap.fieldHeader5 = fetchFieldLabel(dealObject, getFieldApiName(mtdRecIdentifier+'5',''));
                dealsWrap.fieldHeader6 = fetchFieldLabel(dealObject, getFieldApiName(mtdRecIdentifier+'6',''));
                fields = getFieldApiName(mtdRecIdentifier+'1','') +','+getFieldApiName(mtdRecIdentifier+'2','') +','+getFieldApiName(mtdRecIdentifier+'3','')+',FORMAT('+getFieldApiName(mtdRecIdentifier+'4','')+')'+','+getFieldApiName(mtdRecIdentifier+'5','')+','+getFieldApiName(mtdRecIdentifier+'6','');
                break;
            }
            //bug no: 00031610/00031611/00031553 Shivam
            List<sObject> getDealData = getDealTeam(fields, dealObject, dealList,namespacePrefix);
            List<DealsInfoWrapper> objDealsInfoWrapper = new List<DealsInfoWrapper>();
            for(sObject deals : getDealData){
                DealsInfoWrapper tempObjDealsInfoWrapper = new DealsInfoWrapper();
                ReferenceWrapper objReferenceWrapperFieldInfo1 = new ReferenceWrapper();
                ReferenceWrapper objReferenceWrapperFieldInfo2 = new ReferenceWrapper();
                ReferenceWrapper objReferenceWrapperFieldInfo3 = new ReferenceWrapper();
                ReferenceWrapper objReferenceWrapperFieldInfo4 = new ReferenceWrapper();
                ReferenceWrapper objReferenceWrapperFieldInfo5 = new ReferenceWrapper();
                ReferenceWrapper objReferenceWrapperFieldInfo6 = new ReferenceWrapper();
                objReferenceWrapperFieldInfo1.name = deals.get('Name').toString();  
                objReferenceWrapperFieldInfo1.nameRef = deals.get('Id').toString();
                String parentFieldName = String.valueOf(getFieldApiName(mtdRecIdentifier+'2',''));
                String[] parentFieldTokens = parentFieldName.split('\\.');
                objReferenceWrapperFieldInfo2.name = String.valueOf(deals.getSobject(parentFieldTokens[0]).get(parentFieldTokens[1]));
                objReferenceWrapperFieldInfo2.nameRef = String.valueOf(deals.getSobject(parentFieldTokens[0]).get('Id'));
                objReferenceWrapperFieldInfo3.name = String.valueOf(deals.get(getFieldApiName(mtdRecIdentifier+'3','')));
                objReferenceWrapperFieldInfo4.name = String.valueOf(deals.get(getFieldApiName(mtdRecIdentifier+'4','')));
                String parentFieldName2 = String.valueOf(getFieldApiName(mtdRecIdentifier+'5',''));
                String[] parentFieldTokens2 = parentFieldName2.split('\\.');
                String tempToCheck = String.ValueOf(parentFieldTokens2[0]);
                if(deals.get(tempToCheck.replace('__r','__c')) != null){
                    objReferenceWrapperFieldInfo5.name = String.valueOf(deals.getSobject(parentFieldTokens2[0]).get(parentFieldTokens2[1]));
                    objReferenceWrapperFieldInfo5.nameRef = String.valueOf(deals.getSobject(parentFieldTokens2[0]).get('Id'));
                }
                String parentFieldName3 = String.valueOf(getFieldApiName(mtdRecIdentifier+'6',''));
                String[] parentFieldTokens3 = parentFieldName3.split('\\.');
                tempToCheck = String.ValueOf(parentFieldTokens3[0]);
                if(deals.get(tempToCheck.replace('__r','__c')) != null){
                    objReferenceWrapperFieldInfo6.name = String.valueOf(deals.getSobject(parentFieldTokens3[0]).get(parentFieldTokens3[1]));
                    objReferenceWrapperFieldInfo6.nameRef = String.valueOf(deals.getSobject(parentFieldTokens3[0]).get('Id'));
                }
                tempObjDealsInfoWrapper.fieldInfo1 = objReferenceWrapperFieldInfo1;
                tempObjDealsInfoWrapper.fieldInfo2 = objReferenceWrapperFieldInfo2;
                tempObjDealsInfoWrapper.fieldInfo3 = objReferenceWrapperFieldInfo3;
                tempObjDealsInfoWrapper.fieldInfo4 = objReferenceWrapperFieldInfo4;
                tempObjDealsInfoWrapper.fieldInfo5 = objReferenceWrapperFieldInfo5;
                tempObjDealsInfoWrapper.fieldInfo6 = objReferenceWrapperFieldInfo6;
                objDealsInfoWrapper.add(tempObjDealsInfoWrapper);
            }
            dealsWrap.dealsDataList = objDealsInfoWrapper;
            return dealsWrap;
        } catch(Exception ex) {
            throw new AuraHandledException(ex.getStackTraceString());
        }
    }

    /*
     * Purpose : Get Dynamic Data as per fields, object name and connection type (contact)
     * Input : Fields Name, Object Name, List of Deals
     * Returns : List of Contact Related Deals Count
     */
    @AuraEnabled(cacheable = true)
    public static List<sObject> getDealTeam(String fieldsName, String objectName, List<String> dealList,String namespacePrefix){ //bug no: 00031610/00031611/00031553 Shivam
        try {
            String queryPostFix;
            queryPostFix = 'where Id IN :dealList order by '+String.escapeSingleQuotes(namespacePrefix)+'Log_In_Date__c'+' DESC';
            String queryString = 'Select ' + String.escapeSingleQuotes(fieldsName) + ' from '+ String.escapeSingleQuotes(objectName) + ' ' + queryPostFix; 
            List<sObject> listDealTeam = Database.query(queryString);
            return listDealTeam;
        } catch(Exception ex) {
            throw new AuraHandledException(ex.getStackTraceString());
        }
    }

    /*  
     * Purpose : Get API name of Field
     * Inputs : Refrence Object Name, Metadata Field Name
     * Returns : String Contains Field API Name 
     */
    private static String getFieldApiName(String mdFieldName, String refrenceObject){
        try {
            if(refrenceObject == null || refrenceObject == ''){
                return Acuity_Setting__mdt.getInstance(mdFieldName).Value__c;
            }
            String relatedRefObj = refrenceObject.replace('__c', '__r');
            return relatedRefObj+'.'+Acuity_Setting__mdt.getInstance(mdFieldName).Value__c;
        } catch(Exception ex) {
            throw new AuraHandledException(ex.getStackTraceString());
        }
    }

    /*
     * Purpose : Prepares final map of the data to be displayed under Referenced Section
     * Input : conMap            [Initial info to be used for processing final map]
     *         refField          [Referenced field 1 to be used for displaying data in Contacts/Connections section]
     *         refField2         [Referenced field 2 to be used for displaying data in Contacts/Connections section]
     *         namespacePrefix   [Namespaceprefix to be used]
     * Returns : List<InfoWrapper> containing info about each record to be displayed in data tables under Contacts/Connections Section
     */
    public static List<ConWrapper> prepareConFinalMap(Map<String, sObject> conMap, String refField, String refField2, String namespacePrefix){
        try {
            List<ConWrapper> conInfo = new List<ConWrapper>();
            if(conMap != null){
                for(String conId : conMap.keySet()){
                    if(conId.startsWith('003') || objIdVsActIdsMap.containsKey(conId) || userIdVsEmailCount.containsKey(conId) || objIdVsDealIdsMap.containsKey(conId)){
                        List<String> actIdList = new List<String>();
                        List<String> dealIdList = new List<String>();
                        ConWrapper conWrapper = new ConWrapper();
                        conWrapper.recId = conId;
                        conWrapper.name = String.valueOf(conMap.get(conId).get(refField));
                        if(String.isNotBlank(refField2)){
                            conWrapper.fieldInfo = String.valueOf((conMap.get(conId).get(refField2)));
                        }
                        /* Meeting Count Handling : Start */
                        conWrapper.meetingCallCount = objIdVsActIdsMap.containsKey(conId)
                                                      ? objIdVsActIdsMap.get(conId).size()
                                                      : 0;
                        if(objIdVsActIdsMap.containsKey(conId)){
                            actIdList.addAll(objIdVsActIdsMap.get(conId));
                        }
                        conWrapper.meetingCallIdList = actIdList;
                        if(objIdVsLastInteractionInfoMap.containsKey(conId)){
                            conWrapper.lastInteractionDate = objIdVsLastInteractionInfoMap.get(conId).lastInteractionDate;
                            conWrapper.lastInteractionNote = objIdVsLastInteractionInfoMap.get(conId).lastInteractionNote;
                            conWrapper.lastInteractionId = objIdVsLastInteractionInfoMap.get(conId).lastInteractionId;
                            conWrapper.lastInteractionType = objIdVsLastInteractionInfoMap.get(conId).lastInteractionType;
                        }
                        /* Meeting Count Handling : End */
                        /* RG : START */
                        conWrapper.email = String.valueOf(conMap.get(conId).get('Email'));
                        if(conId.startsWith('003')){
                            conWrapper.nameRef = '/' + conId;
                            conWrapper.emailCount = String.isNotBlank(String.valueOf(conMap.get(conId).get('Email'))) && emailVsCount.containsKey(String.valueOf(conMap.get(conId).get('Email')))
                                                    ? emailVsCount.get(String.valueOf(conMap.get(conId).get('Email')))
                                                    : 0;
                            //added by shivam
                            conWrapper.firmRef =  '/'+String.valueOf(conMap.get(conId).get('AccountId'));
                            conWrapper.firmName = String.valueOf(conMap.get(conId).getSobject('Account').get('Name')); 
                            // ends Shivam 
                        } else if(conId.startsWith('005')) {
                            //Added below line on 2022-10-27 to open user's record view page & not the settings page for logged in user
                            //conWrapper.nameRef = '/lightning/r/User/'+ conId + '/view';
                            conWrapper.emailCount = userIdVsEmailCount.containsKey(String.valueOf(conMap.get(conId).get('Id')))
                                                    ? userIdVsEmailCount.get(String.valueOf(conMap.get(conId).get('Id')))
                                                    : 0;
                            conWrapper.mailboxId = String.valueOf(userIdVsMBid.get(String.valueOf(conMap.get(conId).get('Id'))));
                        }
                        /* RG : END */
                        /* Deal Count Handling : Start */
                        conWrapper.dealCount = objIdVsDealIdsMap.containsKey(conId)
                                               ? objIdVsDealIdsMap.get(conId).size()
                                               : 0;
                        if(objIdVsDealIdsMap.containsKey(conId)){
                            dealIdList.addAll(objIdVsDealIdsMap.get(conId));
                        }
                        conWrapper.dealIdList = dealIdList;
                        /* Deal Count Handling : End */
                        conWrapper.totalActCount = conWrapper.meetingCallCount + conWrapper.emailCount + conWrapper.dealCount;
                        conInfo.add(conWrapper);
                    }
                }
            }
            return conInfo;
        } catch (Exception e) {
            throw new AuraHandledException(ERR_MSG + ' : <<' + e.getStackTraceString() + '>>');
        }   
    }

    /************************* CONTACTS/CONNECTIONS SECTION COMMON METHODS : END *************************/

    /************************* RG METHODS : START *************************/

    /*
     * getUsers: get user email list from revenue grid api.
     * mailboxId : revenue grid api mailbox id
     * userEmail : user email
     * namespacePrefix : Namespaceprefix to be used
    */
    @AuraEnabled
    public static List<emailListWrapper> getUserEmailList(String mailboxId, String userEmail, String namespacePrefix){
        try {
            List<emailListWrapper> emailLst = new List<emailListWrapper>();
            if(String.IsNotBlank(apiKey)){//added by shivam 00039476/00039474/00039542
                String umbid = '"'+mailboxId+'"';
                String ue = '"'+userEmail+'"';
                Map<String,sObject> emailVsUsrCon = new Map<String,sObject>();
                String soqlCheckEmail = 'SELECT Id,Name,Email,AccountId FROM Contact LIMIT 2000';
                //store existing domain in set of string
                List<sObject> conRecordsEmails = DataBase.query(soqlCheckEmail);
                for(sObject s:conRecordsEmails){
                    emailVsUsrCon.put(string.valueOf(s.get('Email')),s);
                }
                String soqlCheckUserEmail = 'SELECT Id,Name,Email FROM User LIMIT 2000';
                //store existing domain in set of string
                List<sObject> conUserEmails = DataBase.query(soqlCheckUserEmail);
                for(sObject s:conUserEmails){
                    emailVsUsrCon.put(string.valueOf(s.get('Email')),s);
                }
                
                List<Object> rawObjLst = new List<Object>();
                
                if(ue!='' && umbid!=''){
                    HttpRequest req = new HttpRequest();
                    //set user contact interaction endpoint url
                    req.setEndpoint(userConInterationEndPoint);
                    req.setMethod(storePost);
                    req.setHeader(storeAuth,storeApiKey);
                    String sbody = '{mailboxId:'+umbid+',contact:'+ue+'}';
                    req.setBody(sbody);
                    req.setHeader(storeCT, storeTPJson);
                    req.setTimeout(120000);
                    Http h = new Http();
                    HttpResponse res = h.send(req);
                    Integer iStatusCode = res.getStatusCode();
                    if(iStatusCode == 200){//!=500 || iStatusCode!=401
                        String jsonStr = res.getBody();
                        rawObjLst = (List<Object>) JSON.deserializeUntyped(jsonStr);
                    }else{
                        IsApiError = true;//added by shivam
                        throw new AuraHandledException(API_ERR_MSG);
                    }
                }
                
                if(rawObjLst.size()>0){
                    for(Object o:rawObjLst){
                        emailListWrapper ew = new emailListWrapper();
                        Map<String, Object> row = (Map<String, Object>)o;
                        if(row.get('activityCategory')=='inboundEmails'){
                            Set<String> storeNotFoundSfEmails = new Set<String>();
                            String storeCCNames ='';
                            String storeTONames ='';
                            Map<String,String> toVsEmail = new Map<String,String>();
                            Map<String,String> ccVsEmail = new Map<String,String>();
                            List<ReferenceWrapper> rwLstTO = new List<ReferenceWrapper>();
                            List<ReferenceWrapper> rwLstCC = new List<ReferenceWrapper>();
                            String storeToEmail = String.valueOf(row.get('to'));
                            if(storeToEmail != null){
                                String removeBrackToEmail = storeToEmail.substring(1,storeToEmail.length()-1);
                                for(String tos:removeBrackToEmail.split(', ')){
                                    if(emailVsUsrCon.containsKey(tos)){
                                        sObject getName = emailVsUsrCon.get(tos);
                                        if(getName.get('Name')!=null){
                                            storeTONames+=string.valueOf(getName.get('Name'))+',';//comma added by Shivam
                                            ReferenceWrapper rw = new ReferenceWrapper();
                                            rw.name = String.valueOf(getName.get('Name'));
                                            rw.nameRef = String.valueOf(getName.get('Id')).startsWith('005') // added by Shivam for medium bug 00033991
                                                ? null : '/'+String.valueOf(getName.get('Id'));
                                            rw.iconName = String.valueOf(getName.get('Id')).startsWith('005')
                                                ? 'standard:user'
                                                : 'standard:contact';
                                            rwLstTO.add(rw);
                                        }
                                        ew.toReferences = rwLstTO;
                                        ew.toEmailNames = storeTONames.removeEnd(',');
                                    }
                                    if(!emailVsUsrCon.containsKey(tos)){
                                        storeTONames+=string.valueOf(tos)+',';
                                        ReferenceWrapper rw = new ReferenceWrapper();
                                        rw.name = String.valueOf(tos);
                                        rw.iconName = 'utility:email';
                                        rwLstTO.add(rw);
                                        ew.toReferences = rwLstTO;
                                        ew.toEmailNames = storeTONames.removeEnd(',');
                                    }
                                }
                            }
                            
                            String storeCcEmail = String.valueOf(row.get('cc'));
                            if(storeCcEmail != null){
                                String removeBrackCcEmail = storeCcEmail.substring(1,storeCcEmail.length()-1);
                                for(String tos:removeBrackCcEmail.split(', ')){
                                    if(emailVsUsrCon.containsKey(tos)){
                                        sObject getName = emailVsUsrCon.get(tos);
                                        if(getName.get('Name')!=null){
                                            storeCCNames += string.valueOf(getName.get('Name'))+',';
                                            ReferenceWrapper rw = new ReferenceWrapper();
                                            rw.name = String.valueOf(getName.get('Name'));
                                            rw.nameRef = String.valueOf(getName.get('Id')).startsWith('005') // added by Shivam for medium bug 00033991
                                                ? null : '/'+String.valueOf(getName.get('Id'));
                                            rw.iconName = String.valueOf(getName.get('Id')).startsWith('005')
                                                ? 'standard:user'
                                                : 'standard:contact';
                                            rwLstCC.add(rw);
                                        }
                                        ew.ccReferences = rwLstCC;
                                        ew.ccEmailNames = storeCCNames.removeEnd(',');
                                    }
                                    if(!emailVsUsrCon.containsKey(tos)){
                                        storeCCNames+=string.valueOf(tos)+',';
                                        ReferenceWrapper rw = new ReferenceWrapper();
                                        rw.name = String.valueOf(tos);
                                        rw.iconName = 'utility:email';
                                        rwLstCC.add(rw);
                                        ew.ccReferences = rwLstCC;
                                        ew.ccEmailNames = storeCCNames.removeEnd(',');
                                    }
                                }
                            }
                            //subjectDomainName+'/widgets/email?mailboxId='+String.valueOf(row.get('mailboxId'))+ '&internetMessageId=' +String.valueOf(row.get('activityId'));
                            //Reverted changes for 00045896 by LK on 2024-06-10
                            ew.activityId = subjectDomainName+'/widgets/email/'+String.valueOf(row.get('mailboxId'))+ '/' +String.valueOf(row.get('activityId')) + '?tags=';
                            ew.subject = String.valueOf(row.get('subject'));
                            Long at = (Long)row.get('activityTime');
                            DateTime convertDat = DateTime.newinstance(at);
                            ew.longDateTime = at; //added by Shivam
                            ew.sendEmailDate = convertDat.month()+'/'+convertDat.day()+'/'+convertDat.year(); //MMDDYYYY added by Shivam
                            ew.type = String.valueOf(row.get('activityCategory'));
                            ew.activityCategoryLabel = 'Inbound Email';
                            emailLst.add(ew);
                        }
                        if(row.get('activityCategory')=='outboundEmails'){
                            Set<String> storeNotFoundSfEmails = new Set<String>();
                            String storeCCNames ='';
                            String storeTONames ='';
                            Map<String,String> toVsEmail = new Map<String,String>();
                            Map<String,String> ccVsEmail = new Map<String,String>();
                            List<ReferenceWrapper> rwLstTO = new List<ReferenceWrapper>();
                            List<ReferenceWrapper> rwLstCC = new List<ReferenceWrapper>();
                            String storeToEmail = String.valueOf(row.get('to'));
                            if(storeToEmail != null){
                                String removeBrackToEmail = storeToEmail.substring(1,storeToEmail.length()-1);
                                for(String tos:removeBrackToEmail.split(', ')){
                                    if(emailVsUsrCon.containsKey(tos)){
                                        sObject getName = emailVsUsrCon.get(tos);
                                        if(getName.get('Name')!=null){
                                            storeTONames+=string.valueOf(getName.get('Name'))+',';//comma added by Shivam
                                            ReferenceWrapper rw = new ReferenceWrapper();
                                            rw.name = String.valueOf(getName.get('Name'));
                                            rw.nameRef = String.valueOf(getName.get('Id')).startsWith('005') // added by Shivam for medium bug 00033991
                                                ? null : '/'+String.valueOf(getName.get('Id'));
                                            rw.iconName = String.valueOf(getName.get('Id')).startsWith('005')
                                                ? 'standard:user'
                                                : 'standard:contact';
                                            rwLstTO.add(rw);
                                        }
                                        ew.toReferences = rwLstTO;
                                        ew.toEmailNames = storeTONames.removeEnd(',');
                                    }
                                    if(!emailVsUsrCon.containsKey(tos)){
                                        storeTONames+=string.valueOf(tos)+',';
                                        ReferenceWrapper rw = new ReferenceWrapper();
                                        rw.name = String.valueOf(tos);
                                        rw.iconName = 'utility:email';
                                        rwLstTO.add(rw);
                                        ew.toReferences = rwLstTO;
                                        ew.toEmailNames = storeTONames.removeEnd(',');
                                    }
                                }
                            }
                            String storeCcEmail = String.valueOf(row.get('cc'));
                            if(storeCcEmail != null){
                                String removeBrackCcEmail = storeCcEmail.substring(1,storeCcEmail.length()-1);
                                for(String tos:removeBrackCcEmail.split(', ')){
                                    if(emailVsUsrCon.containsKey(tos)){
                                        sObject getName = emailVsUsrCon.get(tos);
                                        if(getName.get('Name')!=null){
                                            storeCCNames += string.valueOf(getName.get('Name'))+',';
                                            ReferenceWrapper rw = new ReferenceWrapper();
                                            rw.name = String.valueOf(getName.get('Name'));
                                            rw.nameRef = String.valueOf(getName.get('Id')).startsWith('005') // added by Shivam for medium bug 00033991
                                                ? null : '/'+String.valueOf(getName.get('Id'));
                                            rw.iconName = String.valueOf(getName.get('Id')).startsWith('005')
                                                ? 'standard:user'
                                                : 'standard:contact';
                                            rwLstCC.add(rw);
                                        }
                                        ew.ccReferences = rwLstCC;
                                        ew.ccEmailNames = storeCCNames.removeEnd(',');
                                    }
                                    if(!emailVsUsrCon.containsKey(tos)){
                                        storeCCNames+=string.valueOf(tos)+',';
                                        ReferenceWrapper rw = new ReferenceWrapper();
                                        rw.name = String.valueOf(tos);
                                        rw.iconName = 'utility:email';
                                        rwLstCC.add(rw);
                                        ew.ccReferences = rwLstCC;
                                        ew.ccEmailNames = storeCCNames.removeEnd(',');
                                    }
                                }
                            }
                            //subjectDomainName+'/widgets/email?mailboxId='+String.valueOf(row.get('mailboxId'))+ '&internetMessageId=' +String.valueOf(row.get('activityId'));
                            //Reverted changes for 00045896 by LK on 2024-06-10
                            ew.activityId = subjectDomainName+'/widgets/email/'+String.valueOf(row.get('mailboxId'))+ '/' +String.valueOf(row.get('activityId')) + '?tags=';
                            ew.subject = String.valueOf(row.get('subject'));
                            Long at = (Long)row.get('activityTime');
                            DateTime convertDat = DateTime.newinstance(at);
                            ew.longDateTime = at; //added by Shivam
                            ew.sendEmailDate = convertDat.month()+'/'+convertDat.day()+'/'+convertDat.year(); //MMDDYYYY added by Shivam
                            ew.type = String.valueOf(row.get('activityCategory'));
                            ew.activityCategoryLabel = 'Outbound Email';
                            emailLst.add(ew);
                        }
                        if(row.get('activityCategory')=='indirectEmails'){
                            Set<String> storeNotFoundSfEmails = new Set<String>();
                            String storeCCNames ='';
                            String storeTONames ='';
                            Map<String,String> toVsEmail = new Map<String,String>();
                            List<ReferenceWrapper> rwLstTO = new List<ReferenceWrapper>();
                            Map<String,String> ccVsEmail = new Map<String,String>();
                            List<ReferenceWrapper> rwLstCC = new List<ReferenceWrapper>();
                            String storeCcEmail = String.valueOf(row.get('cc'));
                            String storeToEmail = String.valueOf(row.get('to'));
                            if(storeToEmail != null){
                                String removeBrackToEmail = storeToEmail.substring(1,storeToEmail.length()-1);
                                for(String tos:removeBrackToEmail.split(', ')){
                                    if(emailVsUsrCon.containsKey(tos)){
                                        sObject getName = emailVsUsrCon.get(tos);
                                        if(getName.get('Name')!=null){
                                            storeTONames+=string.valueOf(getName.get('Name'))+',';// comma added by Shivam
                                            ReferenceWrapper rw = new ReferenceWrapper();
                                            rw.name = String.valueOf(getName.get('Name'));
                                            rw.nameRef = String.valueOf(getName.get('Id')).startsWith('005') // added by Shivam for medium bug 00033991
                                                ? null : '/'+String.valueOf(getName.get('Id'));
                                            rw.iconName = String.valueOf(getName.get('Id')).startsWith('005')
                                                ? 'standard:user'
                                                : 'standard:contact';
                                            rwLstTO.add(rw);
                                        }
                                        ew.toReferences = rwLstTO;
                                        ew.toEmailNames = storeTONames.removeEnd(',');
                                    }
                                    if(!emailVsUsrCon.containsKey(tos)){
                                        storeTONames+=string.valueOf(tos)+',';
                                        ReferenceWrapper rw = new ReferenceWrapper();
                                        rw.name = String.valueOf(tos);
                                        rw.iconName = 'utility:email';
                                        rwLstTO.add(rw);
                                        ew.toReferences = rwLstTO;
                                        ew.toEmailNames = storeTONames.removeEnd(',');
                                    }
                                }
                            }
                            if(storeCcEmail != null){
                                String removeBrackCcEmail = storeCcEmail.substring(1,storeCcEmail.length()-1);
                                for(String tos:removeBrackCcEmail.split(', ')){
                                    if(emailVsUsrCon.containsKey(tos)){
                                        sObject getName = emailVsUsrCon.get(tos);
                                        if(getName.get('Name')!=null){
                                            storeCCNames += string.valueOf(getName.get('Name'))+',';
                                            ReferenceWrapper rw = new ReferenceWrapper();
                                            rw.name = String.valueOf(getName.get('Name'));
                                            rw.nameRef = String.valueOf(getName.get('Id')).startsWith('005') // added by Shivam for medium bug 00033991
                                                ? null : '/'+String.valueOf(getName.get('Id'));
                                            rw.iconName = String.valueOf(getName.get('Id')).startsWith('005')
                                                ? 'standard:user'
                                                : 'standard:contact';
                                            rwLstCC.add(rw);
                                        }
                                        ew.ccReferences = rwLstCC;
                                        ew.ccEmailNames = storeCCNames.removeEnd(',');
                                    }
                                    if(!emailVsUsrCon.containsKey(tos)){
                                        storeCCNames+=string.valueOf(tos)+',';
                                        ReferenceWrapper rw = new ReferenceWrapper();
                                        rw.name = String.valueOf(tos);
                                        rw.iconName = 'utility:email';
                                        rwLstCC.add(rw);
                                        ew.ccReferences = rwLstCC;
                                        ew.ccEmailNames = storeCCNames.removeEnd(',');
                                    }
                                }
                            }
                            //subjectDomainName+'/widgets/email?mailboxId='+String.valueOf(row.get('mailboxId'))+ '&internetMessageId=' +String.valueOf(row.get('activityId'));
                            //Reverted changes for 00045896 by LK on 2024-06-10
                            ew.activityId = subjectDomainName+'/widgets/email/'+String.valueOf(row.get('mailboxId'))+ '/' +String.valueOf(row.get('activityId')) + '?tags=';
                            ew.subject = String.valueOf(row.get('subject'));
                            Long at = (Long)row.get('activityTime');
                            DateTime convertDat = DateTime.newinstance(at);
                            ew.longDateTime = at; //added by Shivam
                            ew.sendEmailDate = convertDat.month()+'/'+convertDat.day()+'/'+convertDat.year(); //MMDDYYYY added by Shivam
                            ew.type = String.valueOf(row.get('activityCategory'));
                            ew.activityCategoryLabel = 'Indirect Email';
                            emailLst.add(ew);
                        }
                    }
                }
            }
            return emailLst;
        } catch(CalloutException e) {
            IsApiError = True;
            throw new AuraHandledException(API_ERR_MSG);
        } catch(Exception e) {
            throw new AuraHandledException(ERR_MSG + ' : <<' + e.getStackTraceString() + '>>');
        }
    }

    /*
     * getContacts: count inbound and outbound from revenue grid contacts and show list of contats available in salesforce.
     * accId : Account Id
     * namespacePrefix : Namespaceprefix to be used
     * conMap : Initial info to be used for processing final map
     */
    @testVisible
    private static List<ConWrapper> countInboundAndOutboundMethod(Id accId, String namespacePrefix, Map<String, sObject> conMap){
        try {
            List<ConWrapper> cwLst = new List<ConWrapper>();
            if(String.IsNotBlank(apikey)){
                Set<String> emailDomains = new Set<String>();
                //store existing domain in set of string
                for(String recId : conMap.keySet()){
                    if(conMap.get(recId).get('Email') != null) {
                        emailDomains.add(String.valueOf(conMap.get(recId).get('Email')).split('@').get(1));
                    }
                }
                List<Object> rawObjLst = new List<Object>();
                if(emailDomains.size()>0){
                    //fetch revenuegrid contact api
                    HttpRequest req = new HttpRequest();
                    //set account contact activity endpoint url
                    req.setEndpoint(accConActivityEndPoint);
                    req.setMethod(storePost);
                    req.setHeader(storeAuth,storeApiKey);
                    //store domain name comma seprated string
                    String domainStr='';
                    for(String e:emailDomains){
                        domainStr+='"'+e+'",';
                    }
                    String sbody = '{accountId:['+domainStr.removeEnd(',')+']}';
                    req.setBody(sbody);
                    req.setHeader(storeCT, storeTPJson);
                    req.setTimeout(120000);
                    Http h = new Http();
                    HttpResponse res = h.send(req);
                    Integer iStatusCode=res.getStatusCode();                
                    if(iStatusCode == 200){ //!=500 || iStatusCode!=401 || iStatusCode!=404					                   
                        String jsonStr = res.getBody();
                        rawObjLst = (List<Object>) JSON.deserializeUntyped(jsonStr);
                        //}                                        
                    }else{//added by shivam
                        IsApiError = true;
                    }
                }
                List<String> emailList = new List<String>();
                Set<String> setOfString = new Set<String>();
                //store email address setOfString variable from revenue grid
                if(rawObjLst.size()>0){
                    for(Object o:rawObjLst){
                        Map<String, Object> row = (Map<String, Object>)o;
                        emailList.add(String.valueOf(row.get('contact')));
                        if((row.get('activityCategory')=='inboundEmails') || (row.get('activityCategory')=='outboundEmails') || (row.get('activityCategory')=='indirectEmails')){
                            Integer totalCo = 0;
                            if(emailVsCount.containsKey(String.valueOf(row.get('contact')))){
                                totalCo = emailVsCount.get(String.valueOf(row.get('contact')));
                            } else {
                                totalCo = 0;
                            }
                            totalCo += Integer.valueOf(row.get('count'));
                            emailVsCount.put(String.valueOf(row.get('contact')),totalCo);
                        }
                    }
                    setOfString.addAll(emailList);
                }
                Set<String> checkEmailIsExistOrNot = new Set<String>();
                Set<String> notFoundEmailList = new Set<String>();
                //store in wrapper class get all contact match in api same as salesforce
                //checked email from salesforce if existing or not if not exist store in notFoundEmailList variable
                if(conMap.size()>0){
                    Set<String> sfEmailIdSet = new Set<String>();
                    for(String recId : conMap.keySet()){
                        String emailId = String.valueOf(conMap.get(recId).get('Email'));
                        if(String.isNotBlank(emailId)){
                            sfEmailIdSet.add(emailId);
                        }
                    }
                    for(String checkEm:emailVsCount.keySet()){
                        if(!sfEmailIdSet.contains(checkEm)){
                            notFoundEmailList.add(checkEm);
                        }
                    }
                }
                // if contact does not exist in salesforce call this api to get fullname from contacts
                if(notFoundEmailList.size()>0){
                    map<String,String> emailVsNameFromApi = new map<String,String>();
                    HttpRequest newConReq = new HttpRequest();
                    newConReq.setEndpoint(accConQueryEndPoint);
                    newConReq.setMethod(storePost);
                    newConReq.setHeader(storeAuth,storeApiKey);
                    //store email comma seprated string
                    String nfes='';
                    for(String s:notFoundEmailList){
                        nfes+='"'+s+'",';
                    }
                    String sNewConbody='{EmailAddress:{IN:['+nfes.removeEnd(',')+']}}';
                    newConReq.setBody(sNewConbody);
                    newConReq.setHeader(storeCT, storeTPJson);
                    newConReq.setTimeout(120000);
                    Http newConH = new Http();
                    HttpResponse newConRes = newConH.send(newConReq);
                    Integer iStatusCode = newConRes.getStatusCode();
                    List<Object> rawNewConObjLst = new List<Object>();
                    
                    if(iStatusCode == 200){//!=500 || iStatusCode!=401 || iStatusCode!=404){
                        String jsonNewConStr = newConRes.getBody();
                        rawNewConObjLst = (List<Object>) JSON.deserializeUntyped(jsonNewConStr);
                    }else{
                        IsApiError = true;
                    }
                    if(rawNewConObjLst.size()>0){
                        for(Object o:rawNewConObjLst){
                            ConWrapper cw =  new ConWrapper();
                            Map<String, Object> row = (Map<String, Object>)o;
                            String removeBrack = '';
                            String finalStr = '';
                            if(String.valueOf(row.get('emailAddresses'))!=null){
                                removeBrack = String.valueOf(row.get('emailAddresses'));
                                finalStr = removeBrack.substring(1,removeBrack.length()-1);
                            }
                            emailVsNameFromApi.put(finalStr,String.valueOf(row.get('fullName')));
                        }
                    }
                    for(String s : notFoundEmailList){
                        ConWrapper cw =  new ConWrapper();
                        cw.recId = '';
                        if(emailVsNameFromApi.containsKey(s)){
                            cw.name = String.valueOf(emailVsNameFromApi.get(s)) != null ? String.valueOf(emailVsNameFromApi.get(s)) : s;
                        } else{
                            cw.name = s;
                        }
                        cw.nameRef = '/';
                        cw.downloadIcon = 'utility:download';
                        cw.email = s;
                        cw.emailCount = emailVsCount.get(s);
                        //Added 3 below parameters by LK to fix 00032370
                        cw.meetingCallCount = 0;
                        cw.dealCount = 0;
                        cw.totalActCount = emailVsCount.get(s);
                        cwLst.add(cw);
                    }
                }
            }
            System.debug('cwLst ::>> '+cwLst);
            //return contact wrapper
            return cwLst;
        }  catch(CalloutException e) {
            IsApiError = true;
            throw new AuraHandledException(API_ERR_MSG);
        } catch(Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    /*
     * getUsers: check salesforce id from revenue grid match salesforce user id show user list.
     * conEmail : Contact Email
     * objectName : Object Api Name
     * recordId : Account Id
     * namespacePrefix : Namespaceprefix to be used
     */
    @AuraEnabled
    public static List<ConWrapper> getUsersListOfRecords(String conEmail, String objectName, String recordId, String namespacePrefix){
        try {
            List<ConWrapper> uwLst = new List<ConWrapper>();
            if(String.IsNotBlank(apikey)){ //added by shivam 00039476/00039474/00039542
                List<Object> rawObjLst = new List<Object>();
                Map<String,String> storeMBIds = new Map<String,String>();          
                if(conEmail != ''){
                    //fetch revenuegrid contact api
                    HttpRequest req = new HttpRequest();
                    //set account connection endpoint url
                    req.setEndpoint(accConnectionEndPoint);
                    req.setMethod(storePost);
                    req.setHeader(storeAuth,storeApiKey);        
                    String sbody = '{contact:'+'"'+conEmail+'"'+'}';
                    req.setBody(sbody);  
                    req.setHeader(storeCT, storeTPJson);
                    req.setTimeout(120000);
                    Http h = new Http();
                    HttpResponse res = h.send(req);
                    Integer iStatusCode = res.getStatusCode();
                    if(iStatusCode == 200){//!=500 || iStatusCode!=401 || iStatusCode!=404
                        String jsonStr = res.getBody();
                        rawObjLst = (List<Object>) JSON.deserializeUntyped(jsonStr);
                    }
                }
                Map<String,Integer> mailBoxIdVsCntCount = new Map<String,Integer>();
                if(rawObjLst.size()>0){
                    for(Object o:rawObjLst){
                        Map<String, Object> row = (Map<String, Object>)o;
                        if(row.get('activityCategory')=='outboundEmails' || row.get('activityCategory')=='inboundEmails' || row.get('activityCategory')=='indirectEmails'){
                            storeMBIds.put(String.valueOf(row.get('mailboxId')),String.valueOf(row.get('mailboxId')));
                            if(mailBoxIdVsCntCount.containsKey(String.valueOf(row.get('mailboxId')))){
                                Integer count=0;
                                count = mailBoxIdVsCntCount.get(String.valueOf(row.get('mailboxId')));
                            if(row.containsKey('count')){
                                count=count+Integer.valueOf(row.get('count'));
                            }
                                mailBoxIdVsCntCount.put(String.valueOf(row.get('mailboxId')),count);
                            }else{
                                Integer count=0;
                                count = Integer.valueOf(row.get('count'));
                                mailBoxIdVsCntCount.put(String.valueOf(row.get('mailboxId')),count);                            
                            }
                        }
                    }
                }                                   
                // get list of users from revenue grid api
                HttpRequest ureq = new HttpRequest();  
                //set get user endpoint url
                ureq.setEndpoint(getUserEndPoint);
                ureq.setMethod(storeGet);
                ureq.setHeader(storeAuth,storeApiKey);
                ureq.setHeader(storeCT, storeTPJson);
                ureq.setTimeout(120000);
                Http uh = new Http();
                HttpResponse ures = uh.send(ureq);
                Integer iStatusCode = ures.getStatusCode();
                List<Object> userRawObjLst = new List<Object>();
                if(iStatusCode == 200){//!=500 || iStatusCode!=401 || iStatusCode!=404
                    String ujsonStr = ures.getBody();
                    userRawObjLst = (List<Object>) JSON.deserializeUntyped(ujsonStr);
                }else{
                    IsApiError = True;//added by shivam
                }
                
                if(userRawObjLst.size()>0 && userRawObjLst!=null){
                    for(Object o:userRawObjLst){
                        Map<String, Object> row = (Map<String, Object>)o;
                        if(storeMBIds.containsKey(String.valueOf(row.get('mailboxId')))){
                            userIdVsMBid.put(String.valueOf(row.get('salesforceId')),String.valueOf(row.get('mailboxId')));
                            userIdVsEmailCount.put(String.valueOf(row.get('salesforceId')),Integer.valueOf(mailBoxIdVsCntCount.get(String.valueOf(row.get('mailboxId')))));
                        }
                    }
                }
            }
            //return this uwLst from store users list 
            return uwLst;
        } catch(CalloutException e) {
            IsApiError = True;//added by shivam
            throw new AuraHandledException('An Error occurred in API');
        } catch(Exception e) {
            throw new AuraHandledException(ERR_MSG + ' : <<' + e.getStackTraceString() + '>>');
        }
    }

    /*
     * getUsers: get contacts email list from revenue grid api.
     * conEmail : contact email
     * namespacePrefix : Namespaceprefix to be used
     */
    @AuraEnabled
    public static List<EmailListWrapper> getContactEmailList(String conEmail, String namespacePrefix,String requestBody){
        try{
            List<emailListWrapper> emailLst = new List<emailListWrapper>();
            if(String.IsNotBlank(apikey)){ //added by shivam 00039476/00039474/00039542
                Set<String> emailDomains = new Set<String>();
                String ce  = '"'+conEmail+'"';    
                Map<String,sObject> emailVsUsrCon = new Map<String,sObject>();
                
                List<Object> rawObjLst = new List<Object>();
                
                if(ce!='' && requestBody == ''){
                    //fetch revenue grid users by domain name through if domain name is availabe or not 
                    HttpRequest req = new HttpRequest();
                    //set contact interaction endpoint url
                    req.setEndpoint(contInteractionEndPoint);
                    req.setMethod(storePost);
                    req.setHeader(storeAuth,storeApiKey);
                    
                    String sbody = '{contact:'+ce+'}';
                    req.setBody(sbody);
                    req.setHeader(storeCT, storeTPJson);
                    req.setTimeout(120000);
                    Http h = new Http();
                    HttpResponse res = h.send(req);
                    Integer iStatusCode = res.getStatusCode();
                    
                    if(iStatusCode == 200){//!=500 || iStatusCode!=401
                        String jsonStr = res.getBody();  
                        rawObjLst = (List<Object>) JSON.deserializeUntyped(jsonStr);  
                    }else{
                        IsApiError = true; //added by shivam
                        throw new AuraHandledException('An Error occurred in API');
                        
                    }
                } else if(requestBody != ''){
                    String apiUrl = RG_Setting__mdt.getInstance('RG_Ext_Connection_Details').Value__c;
                    String jsonStr = getRGApiResponse(apiUrl,requestBody);
                    rawObjLst = (List<Object>) JSON.deserializeUntyped(jsonStr); 
                }
                
                String soqlCheckEmail = 'SELECT Id, Name, Email, AccountId FROM Contact LIMIT 2000';
                //store existing domain in set of string
                List<sObject> conRecordsEmails = DataBase.query(soqlCheckEmail);
                for(sObject s:conRecordsEmails){
                    emailVsUsrCon.put(string.valueOf(s.get('Email')),s);
                }
                String soqlCheckUserEmail = 'SELECT Id,Name,Email FROM User LIMIT 2000'; 
                //store existing domain in set of string
                List<sObject> conUserEmails = DataBase.query(soqlCheckUserEmail);
                for(sObject s:conUserEmails){
                    emailVsUsrCon.put(string.valueOf(s.get('Email')),s);
                }
                
                if(rawObjLst.size()>0){
                    for(Object o:rawObjLst){
                        emailListWrapper ew = new emailListWrapper();
                        Map<String, Object> row = (Map<String, Object>)o;
                        if(row.get('activityCategory')=='inboundEmails'){  
                            Set<String> storeNotFoundSfEmails = new Set<String>();
                            String storeCCNames ='';
                            String storeTONames ='';
                            String storeToEmail = String.valueOf(row.get('to'));
                            Map<String,String> toVsEmail = new Map<String,String>();
                            Map<String,String> ccVsEmail = new Map<String,String>();
                            
                            List<ReferenceWrapper> rwLstTO = new List<ReferenceWrapper>();
                            List<ReferenceWrapper> rwLstCC = new List<ReferenceWrapper>();
                            if(storeToEmail != null){
                                String removeBrackToEmail = storeToEmail.substring(1,storeToEmail.length()-1);
                                for(String tos:removeBrackToEmail.split(', ')){
                                    if(emailVsUsrCon.containsKey(tos)){
                                        sObject getName = emailVsUsrCon.get(tos);
                                        if(getName.get('Name')!=null){ 
                                            storeTONames+=string.valueOf(getName.get('Name'))+',';
                                            ReferenceWrapper rw = new ReferenceWrapper();
                                            rw.name = String.valueOf(getName.get('Name'));
                                            rw.nameRef = rw.nameRef = String.valueOf(getName.get('Id')).startsWith('005') // added by Shivam for medium bug 00033991
                                                ? null : '/'+String.valueOf(getName.get('Id'));
                                            rw.iconName = String.valueOf(getName.get('Id')).startsWith('005')
                                                ? 'standard:user'
                                                : 'standard:contact';
                                            rwLstTO.add(rw);
                                        }
                                        ew.toReferences = rwLstTO;
                                        ew.toEmailNames = storeTONames.removeEnd(',');
                                    }
                                    if(!emailVsUsrCon.containsKey(tos)){//Shivam Starts
                                        storeTONames+=string.valueOf(tos)+',';
                                        ReferenceWrapper rw = new ReferenceWrapper();
                                        rw.name = String.valueOf(tos);                                    
                                        rw.iconName = 'utility:email';
                                        rwLstTO.add(rw);
                                        ew.toReferences = rwLstTO;
                                        ew.toEmailNames = storeTONames.removeEnd(',');
                                    }
                                }
                            }
                            
                            String storeCcEmail = String.valueOf(row.get('cc'));
                            if(storeCcEmail != null){
                                String removeBrackCcEmail = storeCcEmail.substring(1,storeCcEmail.length()-1);
                                for(String tos:removeBrackCcEmail.split(', ')){
                                    if(emailVsUsrCon.containsKey(tos)){
                                        sObject getName = emailVsUsrCon.get(tos);
                                        if(getName.get('Name')!=null){
                                            storeCCNames += string.valueOf(getName.get('Name'))+',';
                                            ReferenceWrapper rw = new ReferenceWrapper();
                                            rw.name = String.valueOf(getName.get('Name'));
                                            rw.nameRef = rw.nameRef = String.valueOf(getName.get('Id')).startsWith('005') // added by Shivam for medium bug 00033991
                                                ? null : '/'+String.valueOf(getName.get('Id'));
                                            rw.iconName = String.valueOf(getName.get('Id')).startsWith('005')
                                                ? 'standard:user'
                                                : 'standard:contact';
                                            rwLstCC.add(rw);
                                        }
                                        ew.ccReferences = rwLstCC;
                                        ew.ccEmailNames = storeCCNames.removeEnd(',');
                                    }
                                    if(!emailVsUsrCon.containsKey(tos)){
                                        storeCCNames+=string.valueOf(tos)+',';
                                        ReferenceWrapper rw = new ReferenceWrapper();
                                        rw.name = String.valueOf(tos);
                                        rw.iconName = 'utility:email';
                                        rwLstCC.add(rw);
                                        ew.ccReferences = rwLstCC;
                                        ew.ccEmailNames = storeCCNames.removeEnd(',');
                                    }
                                }
                            }
                            //subjectDomainName+'/widgets/email?mailboxId='+String.valueOf(row.get('mailboxId'))+ '&internetMessageId=' +String.valueOf(row.get('activityId'));
                            //Reverted changes for 00045896 by LK on 2024-06-10
                            ew.activityId = subjectDomainName+'/widgets/email/'+String.valueOf(row.get('mailboxId'))+ '/' +String.valueOf(row.get('activityId')) + '?tags=';
                            ew.subject = String.valueOf(row.get('subject'));
                            Long at = (Long)row.get('activityTime');
                            DateTime convertDat = DateTime.newinstance(at);
                            ew.longDateTime = at; //added by Shivam
                            ew.sendEmailDate = convertDat.month()+'/'+convertDat.day()+'/'+convertDat.year(); //MMDDYYYY added by SHivam
                            ew.type = String.valueOf(row.get('activityCategory'));
                            ew.activityCategoryLabel = 'Inbound Email';
                            emailLst.add(ew);
                        }    
                        if(row.get('activityCategory')=='outboundEmails'){
                            Set<String> storeNotFoundSfEmails = new Set<String>();
                            String storeCCNames ='';
                            String storeTONames ='';
                            String storeToEmail = String.valueOf(row.get('to'));
                            Map<String,String> toVsEmail = new Map<String,String>();
                            Map<String,String> ccVsEmail = new Map<String,String>();
                            List<ReferenceWrapper> rwLstTO = new List<ReferenceWrapper>();
                            List<ReferenceWrapper> rwLstCC = new List<ReferenceWrapper>();
                            if(storeToEmail != null){
                                String removeBrackToEmail = storeToEmail.substring(1,storeToEmail.length()-1);
                                for(String tos:removeBrackToEmail.split(', ')){
                                    if(emailVsUsrCon.containsKey(tos)){
                                        sObject getName = emailVsUsrCon.get(tos);
                                        if(getName.get('Name')!=null){
                                            storeTONames+=string.valueOf(getName.get('Name'))+',';
                                            ReferenceWrapper rw = new ReferenceWrapper();
                                            rw.name = String.valueOf(getName.get('Name'));
                                            rw.nameRef = rw.nameRef = String.valueOf(getName.get('Id')).startsWith('005') // added by Shivam for medium bug 00033991
                                                ? null : '/'+String.valueOf(getName.get('Id'));
                                            rw.iconName = String.valueOf(getName.get('Id')).startsWith('005')
                                                ? 'standard:user'
                                                : 'standard:contact';
                                            rwLstTO.add(rw);
                                        }
                                        ew.toReferences = rwLstTO;
                                        ew.toEmailNames = storeTONames.removeEnd(',');
                                    }
                                    if(!emailVsUsrCon.containsKey(tos)){
                                        storeTONames+=string.valueOf(tos)+',';
                                        ReferenceWrapper rw = new ReferenceWrapper();
                                        rw.name = String.valueOf(tos);
                                        rw.iconName = 'utility:email';
                                        rwLstTO.add(rw);
                                        ew.toReferences = rwLstTO;
                                        ew.toEmailNames = storeTONames.removeEnd(',');
                                    }
                                }
                            }
                            
                            String storeCcEmail = String.valueOf(row.get('cc'));
                            if(storeCcEmail != null){
                                String removeBrackCcEmail = storeCcEmail.substring(1,storeCcEmail.length()-1);
                                for(String tos:removeBrackCcEmail.split(', ')){
                                    if(emailVsUsrCon.containsKey(tos)){
                                        sObject getName = emailVsUsrCon.get(tos);
                                        if(getName.get('Name')!=null){
                                            storeCCNames += string.valueOf(getName.get('Name'))+',';
                                            ReferenceWrapper rw = new ReferenceWrapper();
                                            rw.name = String.valueOf(getName.get('Name'));
                                            rw.nameRef = rw.nameRef = String.valueOf(getName.get('Id')).startsWith('005') // added by Shivam for medium bug 00033991
                                                ? null : '/'+String.valueOf(getName.get('Id'));
                                            rw.iconName = String.valueOf(getName.get('Id')).startsWith('005')
                                                ? 'standard:user'
                                                : 'standard:contact';
                                            rwLstCC.add(rw);
                                        }
                                        ew.ccReferences = rwLstCC;
                                        ew.ccEmailNames = storeCCNames.removeEnd(',');
                                    }
                                    if(!emailVsUsrCon.containsKey(tos)){
                                        storeCCNames+=string.valueOf(tos)+',';
                                        ReferenceWrapper rw = new ReferenceWrapper();
                                        rw.name = String.valueOf(tos);
                                        rw.iconName = 'utility:email';
                                        rwLstCC.add(rw);
                                        ew.ccReferences = rwLstCC;
                                        ew.ccEmailNames = storeCCNames.removeEnd(',');
                                    }
                                }
                            }
                            //subjectDomainName+'/widgets/email?mailboxId='+String.valueOf(row.get('mailboxId'))+ '&internetMessageId=' +String.valueOf(row.get('activityId'));
                            //Reverted changes for 00045896 by LK on 2024-06-10
                            ew.activityId = subjectDomainName+'/widgets/email/'+String.valueOf(row.get('mailboxId'))+ '/' +String.valueOf(row.get('activityId')) + '?tags=';
                            ew.subject = String.valueOf(row.get('subject'));
                            Long at = (Long)row.get('activityTime');
                            DateTime convertDat = DateTime.newinstance(at);
                            ew.longDateTime = at; //added by Shivam
                            ew.sendEmailDate = convertDat.month()+'/'+convertDat.day()+'/'+convertDat.year(); //MMDDYYYY added by SHivam
                            ew.type = String.valueOf(row.get('activityCategory'));
                            ew.activityCategoryLabel = 'Outbound Email';
                            emailLst.add(ew);
                        } 
                        if(row.get('activityCategory')=='indirectEmails'){  
                            Set<String> storeNotFoundSfEmails = new Set<String>();
                            String storeCCNames ='';
                            String storeTONames ='';//Shivam Starts
                            String storeToEmail = String.valueOf(row.get('to'));
                            Map<String,String> toVsEmail = new Map<String,String>();
                            if(storeToEmail != null){
                                String removeBrackToEmail = storeToEmail.substring(1,storeToEmail.length()-1);
                                List<ReferenceWrapper> rwLstTO = new List<ReferenceWrapper>();
                                for(String tos:removeBrackToEmail.split(', ')){
                                    if(emailVsUsrCon.containsKey(tos)){
                                        sObject getName = emailVsUsrCon.get(tos);
                                        if(getName.get('Name')!=null){
                                            storeTONames+=string.valueOf(getName.get('Name'))+',';
                                            ReferenceWrapper rw = new ReferenceWrapper();
                                            rw.name = String.valueOf(getName.get('Name'));
                                            rw.nameRef = rw.nameRef = String.valueOf(getName.get('Id')).startsWith('005') // added by Shivam for medium bug 00033991
                                                ? null : '/'+String.valueOf(getName.get('Id'));
                                            rw.iconName = String.valueOf(getName.get('Id')).startsWith('005')
                                                ? 'standard:user'
                                                : 'standard:contact';
                                            rwLstTO.add(rw);
                                        }
                                        ew.toReferences = rwLstTO;
                                        ew.toEmailNames = storeTONames.removeEnd(',');
                                    }
                                    if(!emailVsUsrCon.containsKey(tos)){
                                        storeTONames+=string.valueOf(tos)+',';
                                        ReferenceWrapper rw = new ReferenceWrapper();
                                        rw.name = String.valueOf(tos);
                                        rw.iconName = 'utility:email';
                                        rwLstTO.add(rw);
                                        ew.toReferences = rwLstTO;
                                        ew.toEmailNames = storeTONames.removeEnd(',');
                                    }
                                }
                            }
                            Map<String,String> ccVsEmail = new Map<String,String>();
                            String storeCcEmail = String.valueOf(row.get('cc'));
                            if(storeCcEmail != null){
                                String removeBrackCcEmail = storeCcEmail.substring(1,storeCcEmail.length()-1);
                                List<ReferenceWrapper> rwLstCC = new List<ReferenceWrapper>();
                                for(String tos:removeBrackCcEmail.split(', ')){
                                    if(emailVsUsrCon.containsKey(tos)){
                                        sObject getName = emailVsUsrCon.get(tos);
                                        if(getName.get('Name')!=null){
                                            storeCCNames += string.valueOf(getName.get('Name'))+',';
                                            ReferenceWrapper rw = new ReferenceWrapper();
                                            rw.name = String.valueOf(getName.get('Name'));
                                            rw.nameRef = rw.nameRef = String.valueOf(getName.get('Id')).startsWith('005') // added by Shivam for medium bug 00033991
                                                ? null : '/'+String.valueOf(getName.get('Id'));
                                            rw.iconName = String.valueOf(getName.get('Id')).startsWith('005')
                                                ? 'standard:user'
                                                : 'standard:contact';
                                            rwLstCC.add(rw);
                                        }
                                        ew.ccReferences = rwLstCC;
                                        ew.ccEmailNames = storeCCNames.removeEnd(',');
                                    }
                                    if(!emailVsUsrCon.containsKey(tos)){
                                        storeCCNames+=string.valueOf(tos)+',';
                                        ReferenceWrapper rw = new ReferenceWrapper();
                                        rw.name = String.valueOf(tos);
                                        rw.iconName = 'utility:email';
                                        rwLstCC.add(rw);
                                        ew.ccReferences = rwLstCC;
                                        ew.ccEmailNames = storeCCNames.removeEnd(',');
                                    }
                                }
                            }
                            //subjectDomainName+'/widgets/email?mailboxId='+String.valueOf(row.get('mailboxId'))+ '&internetMessageId=' +String.valueOf(row.get('activityId'));
                            //Reverted changes for 00045896 by LK on 2024-06-10
                            ew.activityId = subjectDomainName+'/widgets/email/'+String.valueOf(row.get('mailboxId'))+ '/' +String.valueOf(row.get('activityId')) + '?tags=';
                            ew.subject = String.valueOf(row.get('subject'));
                            Long at = (Long)row.get('activityTime');
                            DateTime convertDat = DateTime.newinstance(at);
                            ew.longDateTime = at; //added by Shivam
                            ew.sendEmailDate = convertDat.month()+'/'+convertDat.day()+'/'+convertDat.year(); //MMDDYYYY added by SHivam
                            ew.type = String.valueOf(row.get('activityCategory'));
                            ew.activityCategoryLabel = 'Indirect Email';
                            emailLst.add(ew);
                        }
                    }  
                }
            }
            return emailLst;
        } catch(CalloutException e) {
            IsApiError = true;//added by shivam
            throw new AuraHandledException('An Error occurred in API');
        } catch(Exception e) {
            throw new AuraHandledException(ERR_MSG + ' : <<' + e.getStackTraceString() + '>>');
        }
    }

    /*
     * conEmail : contact email
     * apiUrl : url of the api
     * storeApiKey : apikey for authorization
     */
	@AuraEnabled
    public static String getRGApiResponse(String apiUrl,String requestBody){
        String jsonStr;
        try{
            if(requestBody!='' && String.IsNotBlank(apiKey)){//added by shivam 00039476/00039474/00039542
                HttpRequest req = new HttpRequest();                
                req.setEndpoint(apiUrl);
                req.setMethod(storePost);
                req.setHeader(storeAuth,storeApiKey);
                req.setBody(requestBody);
                req.setHeader(storeCT, storeTPJson);
                req.setTimeout(120000);
                Http h = new Http();
                HttpResponse res = h.send(req);
                Integer iStatusCode = res.getStatusCode();
                if(iStatusCode == 200){//!=500 || iStatusCode!=401
                    jsonStr = res.getBody();
                }else{
                    IsApiError = true;//added by shivam
                }
            }
            return jsonStr;
        }catch(CalloutException e) {  
            IsApiError = true;//added by shivam
            throw new AuraHandledException('An Error occurred in API');
        } catch(Exception e) {
            throw new AuraHandledException(ERR_MSG + ' : <<' + e.getStackTraceString() + '>>');
        }
    }
    
    /*
     * Purpose : Handles the External Connections information on Contacts Section of Account object
     * Input : recordId          [Contact record ID]
     *         namespacePrefix   [Namespaceprefix to be used]
     *         email             [Email ID of Contact]
     *         actIdList         [Activity IDs to be processed]
     * Returns : Info to be displayed on Internal Connections popup as a ResponseWrapper
     */
    @AuraEnabled
    public static ResponseWrapper handleExternalConnInfoRG(String email, String metadataField1, String metadataField2){
        List<ConWrapper> conWrapperList = new List<ConWrapper>();
        ResponseWrapper respWrapper = new ResponseWrapper();
        //Map<String,Integer> contactVsCount = new Map<String,Integer>();
        try {
            if(String.IsNotBlank(apiKey)){//added by shivam 00039476/00039474/00039542
                if(String.isBlank(email)){
                    return respWrapper;                                
                } else {
                    String excludeDomain = email.split('@').get(1);// added by shivam for 00039948
                    String requestBody = '{contact :'+'"'+email+'",excludeDomains :["'+excludeDomain+'"]}';// added by shivam for
                    String apiUrl = RG_Setting__mdt.getInstance('RG_Ext_Connection_Count').Value__c;
                    String rgResponse = getRGApiResponse(apiUrl,requestBody);
                    List<Object> rgResponseList = (List<Object>)JSON.deserializeUntyped(rgResponse);
                    if(rgResponseList.size() > 0){
                        for(object o : rgResponseList){                        
                            Map<String, Object> row = (Map<String, Object>)o;
                            if((row.get('activityCategory')=='inboundEmails') || (row.get('activityCategory')=='outboundEmails') || (row.get('activityCategory')=='indirectEmails')){
                                Integer totalCo = 0;
                                if(emailVsCount.containsKey(String.valueOf(row.get('contact')))){
                                    totalCo = emailVsCount.get(String.valueOf(row.get('contact')));
                                } else {
                                    totalCo = 0;
                                }
                                totalCo += Integer.valueOf(row.get('count'));                
                                emailVsCount.put(String.valueOf(row.get('contact')),totalCo);
                            }
                        }
                    }
                }
                List<String> conEmails = new List<String>(emailVsCount.keyset());
                List<String> nonSfConEmails = new List<String>();
                String refField1 = String.valueOf(Acuity_Setting__mdt.getInstance(metadataField1).Value__c);
                String refField2 = String.valueOf(Acuity_Setting__mdt.getInstance(metadataField2).Value__c);
            Map<String, sObject> conMap = new Map<String, sObject>(Database.query('SELECT Id, AccountId, Account.Name, Email, ' + string.escapeSingleQuotes(refField1) + ', ' + string.escapeSingleQuotes(refField2) + ', FORMAT(navpeII_dev18__Last_Touch_Point__c), Last_Touchpoint_ID__c FROM Contact WHERE Email IN :conEmails LIMIT 50000'));//fixed security issue shivam
                Map<String,sObject> emailVsCon = new Map<String,sObject>(); 
                for(sObject s : conMap.values()){
                    emailVsCon.put(String.valueof(s.get('Email')),s);                
                }
                for(String eml :conEmails){
                    if(!emailVsCon.containsKey(eml)){
                        nonSfConEmails.add(eml);
                    }
                }
                conWrapperList.addAll(populateDataForNonSfCnt(nonSfConEmails,emailVsCount));
                respWrapper.conMap = conMap;
                respWrapper.conInfoWrapper = conWrapperList;
            }
            return respWrapper;
        } catch (Exception e) {
            throw new AuraHandledException(e.getStackTraceString());
        }
    }
    
    /*
     * Purpose : get the data of nonsf contacts
     * Input : nonSfCnt          [List of non sf contact]
     *         contactVsCount             [Email vs email count]    
     * Returns : Info to be displayed on nonsf external Contacts
     */
    @AuraEnabled
    public static List<ConWrapper> populateDataForNonSfCnt(List<String> nonSfCnt,Map<String,Integer> contactVsCount){
        List<ConWrapper> cntWrapperList = new List<ConWrapper>();
        Map<String,String> emailVsNameFromApi = new Map<String,String>(); 
        try{            
            if(nonSfCnt.size() > 0){
                emailVsNameFromApi = getNonSfCntEmailVsName(nonSfCnt);
                for(String eml : nonSfCnt){
                    ConWrapper cw =  new ConWrapper();
                    cw.recId = '';                    
                    if(emailVsNameFromApi.containsKey(eml)){                        
                        cw.name = emailVsNameFromApi.get(eml) != null ? emailVsNameFromApi.get(eml) : eml;                        
                    } else {
                        cw.name = eml;
                    }                    
                    cw.nameRef = '/';
                    cw.downloadIcon = 'utility:download';
                    cw.email = eml;
                    cw.emailCount = contactVsCount.get(eml);
                    //Added 3 below parameters by LK to fix 00032370
                    cw.meetingCallCount = 0;
                    cw.dealCount = 0;
                    cw.totalActCount = cw.emailCount+cw.meetingCallCount+cw.dealCount;//added by shivam medium bug 00034056
                    cntWrapperList.add(cw);
                }
            }
            return cntWrapperList;
        } catch(Exception e) {
            throw new AuraHandledException(e.getStackTraceString());
        }
    }
    
     /*
     * Purpose : get the data of nonsf contacts
     * Input : nonSfEmail          [List of non sf contact email]
     *             
     * Returns : map of email vs name
     */
    @AuraEnabled
    public static Map<String,String> getNonSfCntEmailVsName(List<String> nonSfEmail){
        map<String,String> emailVsNameFromApi = new map<String,String>();
        String sNewConbody;
        try{
            if(nonSfEmail.size() > 0){
                //store email comma seprated string
                String nfes='';
                for(String s:nonSfEmail){
                    nfes+='"'+s+'",';
                }
                sNewConbody='{EmailAddress:{IN:['+nfes.removeEnd(',')+']}}';
            }
            String rgResponse = getRGApiResponse(accConQueryEndPoint,sNewConbody);
            List<Object> rawNewConObjLst = (List<Object>) JSON.deserializeUntyped(rgResponse);
            if(rawNewConObjLst.size()>0){
                for(Object o:rawNewConObjLst){
                    ConWrapper cw =  new ConWrapper();
                    Map<String, Object> row = (Map<String, Object>)o;
                    String removeBrack = '';
                    String finalStr = '';
                    if(String.valueOf(row.get('emailAddresses'))!=null){
                        removeBrack = String.valueOf(row.get('emailAddresses'));  
                        finalStr = removeBrack.substring(1,removeBrack.length()-1);
                    } 
                    emailVsNameFromApi.put(finalStr,String.valueOf(row.get('fullName')));
                }
            }
            return emailVsNameFromApi;  
        }catch(Exception e){
            throw new AuraHandledException(e.getStackTraceString()); 
        }
    }
    
    /*
     * Purpose : get the data of contact contact Interaction
     * Input : contact Email          [contact email]
     *         withContactEmail  	 [email of with Contact]
     * Returns : map of email vs name
     */
    @AuraEnabled
    public Static List<EmailListWrapper> getCntCntInteractions(String cntEmail,String withCntEmail){
        try{
            List<emailListWrapper> emailLst = new List<emailListWrapper>();
            String requestBody;
            if(cntEmail !='' && withCntEmail != ''){
                requestBody = '{Contact :'+'"'+cntEmail+'",'+'withContact :'+'"'+withCntEmail+'",'+'ActivityCategory :["inboundEmails","outboundEmails","indirectEmails"]}';
            }
            emailLst = getContactEmailList('','',requestBody);
            return emailLst;
        } catch(Exception e) {
            throw new AuraHandledException(e.getStackTraceString()); 
        }   
    }

    @AuraEnabled
    public static Map<String, sObject> handleDealload(String recordId) {
        ResponseWrapper respWrapper = new ResponseWrapper();
        Set <String> idSet = new Set <String>();
        Map <String, Sobject> conMap = new Map<String, sObject>();
        String namespacePrefix = getNamespacePrefix() + '__';
        respWrapper.namespacePrefix = namespacePrefix;
        try {
            String queryString = 'Select id, ' + String.escapeSingleQuotes(namespacePrefix) + 'Deal_Contact__c from ' + String.escapeSingleQuotes(namespacePrefix) + 'Deal_Team__c Where ' + String.escapeSingleQuotes(namespacePrefix) + 'Deal_Contact__c != null AND ' + String.escapeSingleQuotes(namespacePrefix) + 'Deal__c =\'' + String.escapeSingleQuotes(recordId) + '\'';
            if(recordId != null){
            for(Sobject d: database.query(queryString)){
              idSet.add(String.valueOf(d.get(String.escapeSingleQuotes(namespacePrefix) + 'Deal_Contact__c')));
            }
            if(idSet.size() > 0){
                conMap = fetchInitInfoToProcess('Acuity_Connection_Field1', 'Acuity_Connection_Field2', 'Contact', ' WHERE id IN :idSet', null, idSet);
                String refField = Acuity_Setting__mdt.getInstance('Acuity_Connection_Field1').Value__c;
                String refField2 = Acuity_Setting__mdt.getInstance('Acuity_Connection_Field2').Value__c;
                getWrapperContactDealInformation('', String.escapeSingleQuotes(namespacePrefix), conMap.keySet(),'');
				try{
                    countInboundAndOutboundMethod(null, namespacePrefix, conMap);
                } Catch(Exception e){
                }   
                //respWrapper.conInfoWrapper = prepareConFinalMap(conMap, refField, refField2, namespacePrefix);
            }
          }
          return conMap;
        } catch(Exception e){
          throw new AuraHandledException(e.getStackTraceString());
        }
    }

    @AuraEnabled
    public static void handleFundRaisingOnLoad(String recordId, String calledFrom){
        Set<String> idSet = new Set<String>();
        Map<String, Sobject> conMap = new Map<String, sObject>();
        String namespacePrefix = getNamespacePrefix() + '__';
        try {
            if(recordId != null){
                String queryString = 'Select id, ' + String.escapeSingleQuotes(namespacePrefix) + 'Contact__c From ' + String.escapeSingleQuotes(namespacePrefix) + 'Fundraising_Contact__c Where ' + String.escapeSingleQuotes(namespacePrefix) + 'Contact__c != null AND ' + String.escapeSingleQuotes(namespacePrefix) + 'Fundraising__c =\'' + String.escapeSingleQuotes(recordId) + '\'';
                for(Sobject d: database.query(queryString)){
                    idSet.add(String.valueOf(d.get(String.escapeSingleQuotes(namespacePrefix) + 'Contact__c')));
                }
                if(idSet.size() > 0){
                    conMap = fetchInitInfoToProcess('Acuity_Connection_Field1', 'Acuity_Connection_Field2', 'Contact', ' WHERE id IN :idSet', null, idSet);
                    String refField = Acuity_Setting__mdt.getInstance('Acuity_Connection_Field1').Value__c;
                    String refField2 = Acuity_Setting__mdt.getInstance('Acuity_Connection_Field2').Value__c;
                    getWrapperContactDealInformation('', String.escapeSingleQuotes(namespacePrefix), conMap.keySet(),'');
                    countInboundAndOutboundMethod(null, namespacePrefix, conMap);
                }   
            }

        } catch (Exception e){
            throw new AuraHandledException(e.getStackTraceString());
        }
    }

    /************************* RG METHODS : END *************************/

    /************************* INTERACTIONS SECTION MAIN METHODS : START *************************/

    /*
     * Purpose : Handles the Interactions section information on Account & Contact objects
     * Input : namespacePrefix   [Namespaceprefix to be used]
     *         actIdList         [Activity IDs to be processed]
     * Returns : Final activity info as a list of ActivityWrapper
     */
    @AuraEnabled
    public static List<ActivityWrapper> handleInteractionsInfo(String namespacePrefix, List<String> actIdList, Boolean isAcuity) {
        try {
            
            Boolean isShowMore = false;
            if(!String.isBlank(namespacePrefix) && namespacePrefix.contains('-')){
                isShowMore = Boolean.valueOf(namespacePrefix.split('-')[1]);
                namespacePrefix = namespacePrefix.split('-')[0] == 'undefined' ? '' : namespacePrefix.split('-')[0];
            }
            
            if(String.isBlank(namespacePrefix)){
                namespacePrefix = getNamespacePrefix() + '__';
            }
            //Added below 2 lines on 2022-10-26 to fetch tagged objects & their icon's info
            Set<String> taggedObjApiNameSet = fetchTaggedObjApiNameSet(namespacePrefix);
            Map<String, String> objApiNameVsIconNameMap = fetchIconInfo(taggedObjApiNameSet);
            prepareUnreadEventsSet(actIdList); //Prepares the list of Events for which Add Notes has been clicked from Notification icon atleast once
            List<ActivityWrapper> actWrapper = new List<ActivityWrapper>();
            // System.debug('Limits.getCpuTime - '+ Limits.getCpuTime());
            // Bug 00047632 Fixed By Sudhanshu on 30-05-2025
            List<ActivityWrapper> evWrapper = fetchActInfo(actIdList, taggedObjApiNameSet, objApiNameVsIconNameMap, 'Event', 'WHERE (Relation.Type = \'Contact\' OR Relation.Type = \'User\')', namespacePrefix,isShowMore,isAcuity);
            actWrapper.addAll(evWrapper);
            // System.debug('Limits.getCpuTime - '+ Limits.getCpuTime());
            if(Schema.getGlobalDescribe().get('TaskRelation') != null){
                // Bug 00047632 Fixed By Sudhanshu on 30-05-2025
            List<ActivityWrapper> taskWrapper = fetchActInfo(actIdList, taggedObjApiNameSet, objApiNameVsIconNameMap, 'Task', 'WHERE (Relation.Type = \'Contact\')', namespacePrefix,isShowMore,isAcuity);
            actWrapper.addAll(taskWrapper);
            }
            return actWrapper;
        } catch (Exception e) {
            throw new AuraHandledException(ERR_MSG + ' : <<' + e.getStackTraceString() + '>>');
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
    private static Map<String, String> fetchRecsInfo(String objName, Set<String> relAssoIds){
        try {
            Map<String, String> recMap = new Map<String, String>();
            for(sObject rec : Database.query('SELECT Id, Name FROM ' + String.escapeSingleQuotes(objName) + ' WHERE Id IN :relAssoIds')){
                recMap.put(String.valueOf(rec.get('Id')), String.valueOf(rec.get('Name')));
            }
            return recMap;
        } catch (Exception e) {
            throw new AuraHandledException(ERR_MSG + ' : <<' + e.getStackTraceString() + '>>');
        }
    }

    /*
     * Purpose : Prepares the set of events which are unread
     * Input : actIdList         [Activity IDs to be processed]
     * Returns : Final activity info as a list of ActivityWrapper
     */
    private static void prepareUnreadEventsSet(List<String> actIdList){
        try {
            for(Navatar_Notification__c nnRec : [SELECT Record_ID__c FROM Navatar_Notification__c WHERE Type__c = 'Add Note' AND Record_ID__c IN :actIdList AND Read__c = false]){
                unreadEventSet.add(nnRec.Record_ID__c);
            }
        } catch (Exception e) {
            throw new AuraHandledException(ERR_MSG + ' : <<' + e.getStackTraceString() + '>>');
        }
    }

    /************************* INTERACTIONS SECTION COMMON METHODS : END *************************/
    
    /************************* INTERACTIONS PAGE MAIN METHODS : START *************************/

    /*
     * Purpose : Fetches the record Name using the record ID
     * Input : recId                [Record ID]
     *         recApiName           [Record's object's API Name]
     * Returns : Record name
     */
    //Added by LK on 2024-10-11 to fix 00047757
    @AuraEnabled
    public static String getRecName(String recId, String recApiName){
        try {
            if(String.IsNotBlank(recId) && String.isNotBlank(recApiName)){
                return fetchRecsInfo(recApiName, new Set<String>{recId}).get(recId);
            } else {
                return null;
            }
        } catch (Exception e) {
            throw new AuraHandledException(ERR_MSG + ' : <<' + e.getStackTraceString() + '>>');
        }
    }

    /*
     * Purpose : Fetches the activities information
     * Input : actIdList                [Activity IDs list to be processed]
     *         objApiNameSet            [Set of object API names to be tagged]
     *         objApiNameVsIconNameMap  [Map of object API name vs icon name]
     *         objName                  [Activity object name (Task/Event)]
     *         whereClause              [Where clause to be used in the SOQL query]
     *         namespacePrefix          [Namespaceprefix to be used]
     * Returns : Activity info as a list of ActivityWrapper of provided activity object
     */
    private static List<ActivityWrapper> fetchActInfo(List<String> actIdList, Set<String> objApiNameSet, Map<String, String> objApiNameVsIconNameMap, String objName, String whereClause, String namespacePrefix, Boolean showMore, Boolean isAcuity) {
        try {

            List<String> otherLayoutFields=getSearchableObjName();  // added by sudhanshu to get custom fields
            String taskLayoutFields=otherLayoutFields[0];
            String eventLayoutFields=otherLayoutFields[1];
            String FollowupTaskLayoutFields=otherLayoutFields[2];

            System.debug('TaskLayout===>'+taskLayoutFields);
            List<ActivityWrapper> actWrapper = new List<ActivityWrapper>();
            if(Limits.getCpuTime() < ALLOWED_CPU_TIME){
            Set<String> relAssoIdSet = new Set<String>();
            Set<String> associatedUsersIdSet = new Set<String>();
            Set<String> associatedConIdSet = new Set<String>();
            
            String lmtRec = ' ORDER BY CreatedDate DESC ' + (showMore ?' LIMIT 2500' : ' LIMIT 150');
            // Bug 00047632 Fixed by Sudhanshu on 30-05-2025
            String limitClause;
            if(isAcuity){
                limitClause = limitClause = actIdList.size() > 0
                                ? ' Where Id IN :actIdList AND IsDeleted = false ORDER BY CreatedDate DESC LIMIT 5 ALL ROWS' //Removed AND By Harshwardhan
                                : lmtRec;//Modified by Parshuram/omkar Nerella W.R.To Bug# 00039942/00039993 && Bug Fix By Manonit -45446
            }
            else{
                limitClause = actIdList.size() > 0
                                ? ' Where Id IN :actIdList AND IsDeleted = false ORDER BY CreatedDate DESC ALL ROWS' //Removed AND By Harshwardhan
                                : lmtRec;//Modified by Parshuram/omkar Nerella W.R.To Bug# 00039942/00039993 && Bug Fix By Manonit -45446
            } 
            //objApiNameSet.remove('Themes');
            objApiNameSet.remove('navpeII_dev18__Themes'); //Modified by Anshika Ahuja to load All Interactions page
            Set<String> activityIdSet = new Set<String>();
            //For processing the data of related associations field
            system.debug('@@'+'SELECT Id, OwnerId, navpeII_dev18__Related_Associations__c FROM ' + objName + limitClause);
            for(sObject actRec : Database.query('SELECT Id, OwnerId, navpeII_dev18__Related_Associations__c FROM ' + objName + limitClause)){//Removed ' WHERE (' + objName + '.' + objName + 'SubType != \'ListEmail\')'  by Harshwardhan
                String relAssoIdsStr = String.valueOf(actRec.get('navpeII_dev18__Related_Associations__c'));
                if(String.isNotBlank(relAssoIdsStr)){
                    relAssoIdSet.addAll(relAssoIdsStr.split(','));
                }
                activityIdSet.add(String.valueOf(actRec.get('Id')));
                // for(sObject actRelRec : actRec.getSObjects(objName + 'Relations')){
                //     String relId = String.valueOf(actRelRec.get('RelationId'));
                //     if(relId.startsWith('005')){
                //         associatedUsersIdSet.add(relId);
                //     } else {
                //         associatedConIdSet.add(relId);
                //     }
                // }
                associatedUsersIdSet.add(String.valueOf(actRec.get('OwnerId')));
            }
            //Added below line by Lakshya on 2023-10-27 to fetch relation records belonging to archived activities as well (00042858)
            String relationRecLimitClause = (activityIdSet.size() > 0) ? ' AND IsDeleted = false ALL ROWS' : '';
            // Added for Interaction Page - CPU Time limit
            //Added "relationRecLimitClause" in below line by Lakshya on 2023-10-27 to fetch relation records belonging to archived activities as well (00042858)
            for(sObject actRelRec : Database.query('SELECT RelationId FROM ' + objName + 'Relation WHERE ' + objName + 'Id IN :activityIdSet' + relationRecLimitClause)){//Removed ListEmail filtering by Harshwardhan
                    String relId = String.valueOf(actRelRec.get('RelationId'));
                    if(relId.startsWith('005')){
                        associatedUsersIdSet.add(relId);
                    } else {
                        associatedConIdSet.add(relId);
                    }
                }
            //Added below code on 2022-10-26 to fetch tagged records info dynamically
            //Fetching id vs name of records to be used for processing
            Map<String, String> objRecMap = new Map<String, String>();
            objRecMap.putAll(fetchRecsInfo('User', associatedUsersIdSet));
            objRecMap.putAll(fetchRecsInfo('Contact', associatedConIdSet));
            for(String objApiName : objApiNameSet){
                objRecMap.putAll(fetchRecsInfo(objApiName, relAssoIdSet));
            }
            String taskOtherField='FORMAT(ActivityDate), Status, Priority, navpeII_dev18__Classification__c';
            String eventOtherField='FORMAT(ActivityDate), FORMAT(ActivityDateTime), FORMAT(EndDateTime), IsAllDayEvent, navpeII_dev18__Classification__c';
            
            // added by sudhanshu to add custom task layout field in Query
            if(String.isNotBlank(taskLayoutFields))
            {
                Map<String, Schema.SObjectField> taskSchema = Schema.SObjectType.Task.fields.getMap();
                for(String fieldName : taskLayoutFields.split(',')){
                    // bug 00046268,46460 fixed by Sudhanshu on 23-07-2024
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
                        taskOtherField=taskOtherField+' , '+ fieldName.replace('__c','__r.Name');
                    }
                }
            }
            // added by sudhanshu to add custom Event layout field in Query
            if(String.isNotBlank(eventLayoutFields))
            {
                Map<String, Schema.SObjectField> eventSchema = Schema.SObjectType.Event.fields.getMap();
                for(String fieldName : eventLayoutFields.split(',')){
                    // bug 00046268,46460 fixed by Sudhanshu on 23-07-2024
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
                        eventOtherField=eventOtherField+' , '+ fieldName.replace('__c','__r.Name');
                    }

                }
            }


            String otherFieldStr = objName.equalsIgnoreCase('Task')
                                ? taskOtherField
                                : eventOtherField;
            if(isAcuity){
                limitClause = actIdList.size() > 0
                        ? (' WHERE Id IN :actIdList AND IsDeleted = false' + (objName.equalsIgnoreCase('Event') ? ' AND IsChild = false' : '') + ' ORDER BY CreatedDate DESC LIMIT 5 ALL ROWS')
                        : ((objName.equalsIgnoreCase('Event') ? ' WHERE IsChild = false' : '') + lmtRec);
            }
            else{
                limitClause = actIdList.size() > 0
                        ? (' WHERE Id IN :actIdList AND IsDeleted = false' + (objName.equalsIgnoreCase('Event') ? ' AND IsChild = false' : '') + ' ORDER BY CreatedDate DESC ALL ROWS')
                        : ((objName.equalsIgnoreCase('Event') ? ' WHERE IsChild = false' : '') + lmtRec);
            }
            // limitClause = actIdList.size() > 0
            //             ? (' WHERE Id IN :actIdList AND IsDeleted = false' + (objName.equalsIgnoreCase('Event') ? ' AND IsChild = false' : '') + ' ORDER BY CreatedDate DESC ALL ROWS')
            //             : ((objName.equalsIgnoreCase('Event') ? ' WHERE IsChild = false' : '') + lmtRec);// Reverted back the Order by Clause for bug id 00041938
            
            Integer processedRecCount = 0;
            system.debug('->SELECT Id, OwnerId, Owner.Name, Subject, Description, navpeII_dev18__Related_Associations__c, ' + objName + 'SubType, ' + otherFieldStr + ', (SELECT RelationId, Relation.Name FROM ' + objName + 'Relations ' + whereClause + ') FROM ' + objName + limitClause);
            for(sObject objRec : Database.query('SELECT Id, OwnerId, Owner.Name, Subject, Description, navpeII_dev18__Related_Associations__c, ' + objName + 'SubType, ' + otherFieldStr + ', (SELECT RelationId, Relation.Name FROM ' + objName + 'Relations ' + whereClause + ') FROM ' + objName + limitClause)){
                if(Limits.getCpuTime() < ALLOWED_CPU_TIME){
                    if(!isAcuity)
                    {
                        if(Limits.getHeapSize() < 5700000){
                            actWrapper.add(createActWrapper(objRec, objName, objApiNameVsIconNameMap, objRecMap));
                            processedRecCount++;
                        }
                    }
                    else{
                        actWrapper.add(createActWrapper(objRec, objName, objApiNameVsIconNameMap, objRecMap));
                        processedRecCount++;
                    }
                    
                } else {
                    system.debug('--->' + objName + ' > ' + processedRecCount + ' records processed in fetchActInfo().');
                    break;
                }
            }
            }
            return actWrapper;
        } catch (Exception e) {
            throw new AuraHandledException(ERR_MSG + ' : <<' + e.getStackTraceString() + '>>');
        }
    }


    /****************************************************************************************************
    Purpose : get set-up object and layout fields from navatar setup object

    Returns : list of strings which includes objectList and auout details
    
    Added by Sudhanshu on 01-01-2024
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
                if(String.isNotBlank(str) && str != 'ActivityDate' && str != 'Status' && str != 'Priority'  && str !='OwnerId'  && str !='navpeII_dev18__Classification__c')
                uNotes_Popup_Task_Fields+=str+',';
            }
			uNotes_Popup_Task_Fields=uNotes_Popup_Task_Fields.removeEnd(',');  //FIx for FLS issues
            for(String str:checkUpdateableFields(Schema.getGlobalDescribe().get('Event'),Notes_Popup_Event_Fields.split(',') ) ){
                // Bug 00044438 Fixed on 02-04-2024 by Sudhanshu
                if(String.isNotBlank(str) && str!= 'ActivityDate' && str!= 'ActivityDateTime' && str!= 'EndDateTime' && str!= 'StartDateTime'  && str!= 'IsAllDayEvent'  && str !='OwnerId' && str !='navpeII_dev18__Classification__c')
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
     * Purpose : Fetches the activities information as per the phrase searched
     * Input : searchTerm   [Phrase searched]
     * Returns : Activity info as a list of ActivityWrapper of provided activity object based on the search
     */
    @AuraEnabled
    public static List<ActivityWrapper> handleInteractionsSearch(String searchTerm){
        try {
            String namespacePrefix = getNamespacePrefix() + '__';
            //Added below 2 lines on 2022-10-26 to fetch tagged objects & their icon's info
            Set<String> taggedObjApiNameSet = fetchTaggedObjApiNameSet(namespacePrefix);
            Map<String, String> objApiNameVsIconNameMap = fetchIconInfo(taggedObjApiNameSet);
            taggedObjApiNameSet.remove('navpeII_dev18__Themes');
            List<ActivityWrapper> actWrapper = new List<ActivityWrapper>();
            Set<String> actIdSet = new Set<String>();
            Set<String> participantIdSet = new Set<String>();
            Map<String, Set<String>> relRecIdVsActIdSetMap = new Map<String, Set<String>>();
            Set<String> actObjSet = new Set<String>{'Event'};
            if(Schema.getGlobalDescribe().get('TaskRelation') != null){
                actObjSet.add('Task');
            }
            for(String actObjName : actObjSet){
                //For Activity OwnerID handling
                for(sObject actRec : Database.query('SELECT Id, OwnerId FROM ' + actObjName + ' WHERE Owner.Name LIKE \'%' + String.escapeSingleQuotes(searchTerm) + '%\'')){
                    participantIdSet.add(String.valueOf(actRec.get('OwnerId')));
                    actIdSet.add(String.valueOf(actRec.get('Id')));
                }
                //For Activity Contact handling
                for(sObject actRec : Database.query('SELECT ' + actObjName + 'Id, RelationId FROM ' + actObjName + 'Relation WHERE (Relation.Type = \'Contact\' OR Relation.Type = \'User\') AND (Relation.Name LIKE \'%' + String.escapeSingleQuotes(searchTerm) + '%\')')){
                    participantIdSet.add(String.valueOf(actRec.get('RelationId')));
                    actIdSet.add(String.valueOf(actRec.get(actObjName + 'Id')));
                }
                //Checking all Activities with navpeII_dev18__Related_Associations__c and creating related record vs Activity ID map
                for(sObject actRec : Database.query('SELECT Id, navpeII_dev18__Related_Associations__c FROM ' + actObjName + ' WHERE navpeII_dev18__Related_Associations__c != null')){
                    relRecIdVsActIdSetMap.putAll(processRelObjVsActIds(relRecIdVsActIdSetMap, String.valueOf(actRec.get('Id')), String.valueOf(actRec.get('navpeII_dev18__Related_Associations__c'))));
                }
            }
            //Creating map of matching activity IDs and their names
            Map<String, String> relObjIdVsNameMap = new Map<String, String>();
            Map<String, String> participantIdVsNameMap = new Map<String, String>();
            participantIdVsNameMap.putAll(fetchRecsInfo('Contact', participantIdSet));
            participantIdVsNameMap.putAll(fetchRecsInfo('User', participantIdSet));
            
            //Search String Sanitization : Start
            searchTerm = '*' + searchTerm.replaceAll('[\\p{Punct}&&[^.#$%,/;<=>@_`]]', '\\\\$0') + '*'; //Modified by Anshika Ahuja W.R.To Bug #00034508
            //Search String Sanitization : End
            String indirectQuery = 'FIND {' + searchTerm + '} IN NAME FIELDS RETURNING ';
            for(String objApiName : taggedObjApiNameSet){
                indirectQuery += objApiName + '(Id, Name), ';
            }
            indirectQuery = indirectQuery.substring(0, indirectQuery.length() - 2);
            Search.SearchResults indirectSearchResult = Search.find(indirectQuery, AccessLevel.USER_MODE);
            for(String taggedObjApiName : taggedObjApiNameSet){
                for(Search.SearchResult objSearchRes : indirectSearchResult.get(taggedObjApiName)){
                    relObjIdVsNameMap.put(String.valueOf(objSearchRes.getSObject().get('Id')), String.valueOf(objSearchRes.getSObject().get('Name')));
                }
            }

            //For processing navpeII_dev18__Related_Associations__c data
            for(String recKey : relObjIdVsNameMap.keySet()){
                if(relRecIdVsActIdSetMap.containsKey(recKey)){
                    actIdSet.addAll(relRecIdVsActIdSetMap.get(recKey));
                }
            }

            //Make search for Task/Event Subject-Description
             //Start --> Modified by Parshuram Nerella W.R.To Bug# 00039567
            Search.SearchResults searchResult ;
            if(Schema.sObjectType.Event.fields.Description.isAccessible())
            {
               searchResult = Search.find('FIND {' + searchTerm + '} IN ALL FIELDS RETURNING Task(Subject, Description, FORMAT(ActivityDate), navpeII_dev18__Related_Associations__c), Event(Subject, Description, FORMAT(ActivityDateTime), navpeII_dev18__Related_Associations__c, IsChild)', AccessLevel.USER_MODE);
            }
            else
            {
               searchResult = Search.find('FIND {' + searchTerm + '} IN ALL FIELDS RETURNING Task(Subject, FORMAT(ActivityDate), navpeII_dev18__Related_Associations__c), Event(Subject, FORMAT(ActivityDateTime), navpeII_dev18__Related_Associations__c, IsChild)', AccessLevel.USER_MODE);
            }
            //End --> Modified by Parshuram Nerella W.R.To Bug# 00039567
            for(Search.SearchResult objSearchRes : searchResult.get('Task')){
                actIdSet.add(String.valueOf(objSearchRes.getSObject().get('Id')));
            }
            for(Search.SearchResult objSearchRes : searchResult.get('Event')){
                if(!Boolean.valueOf(String.valueOf(objSearchRes.getSObject().get('IsChild')))){
                    actIdSet.add(String.valueOf(objSearchRes.getSObject().get('Id')));
                }
            }
            if(actIdSet.size() > 0){
                Set<String> relAssoIdSet = new Set<String>();
                Set<String> associatedUsersIdSet = new Set<String>();
                Set<String> associatedConIdSet = new Set<String>();
                //Task
                for(sObject actRec : Database.query('SELECT OwnerId, navpeII_dev18__Related_Associations__c, (SELECT RelationId FROM TaskRelations) FROM Task WHERE Id IN :actIdSet')){
                    String relAssoIdsStr = String.valueOf(actRec.get('navpeII_dev18__Related_Associations__c'));
                    if(String.isNotBlank(relAssoIdsStr)){
                        relAssoIdSet.addAll(relAssoIdsStr.split(','));
                    }
                    for(sObject actRelRec : actRec.getSObjects('TaskRelations')){
                        String relId = String.valueOf(actRelRec.get('RelationId'));
                        if(relId.startsWith('005')){
                            associatedUsersIdSet.add(relId);
                        } else {
                            associatedConIdSet.add(relId);
                        }
                    }
                    associatedUsersIdSet.add(String.valueOf(actRec.get('OwnerId')));
                }
                //Event
                for(sObject actRec : Database.query('SELECT OwnerId, navpeII_dev18__Related_Associations__c, (SELECT RelationId FROM EventRelations) FROM Event WHERE Id IN :actIdSet')){
                    String relAssoIdsStr = String.valueOf(actRec.get('navpeII_dev18__Related_Associations__c'));
                    if(String.isNotBlank(relAssoIdsStr)){
                        relAssoIdSet.addAll(relAssoIdsStr.split(','));
                    }
                    for(sObject actRelRec : actRec.getSObjects('EventRelations')){
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
                objRecMap.putAll(fetchRecsInfo('Contact', associatedConIdSet));
                for(String objApiName : taggedObjApiNameSet){
                    objRecMap.putAll(fetchRecsInfo(objApiName, relAssoIdSet));
                }
                String limitClause =  actIdSet.size() > 0
                                    ? ' WHERE Id IN :actIdSet'
                                    : ' LIMIT 5000';//Modified by Parshuram Nerella W.R.To Bug# 00039942
                for(sObject objRec : Database.query('SELECT Id, OwnerId, Owner.Name, Subject, Description, navpeII_dev18__Classification__c, navpeII_dev18__Related_Associations__c, TaskSubType, FORMAT(ActivityDate), Status, Priority, (SELECT RelationId, Relation.Name FROM TaskRelations WHERE (Relation.Type = \'Contact\' OR Relation.Type = \'User\')) FROM Task' + limitClause)){
                    actWrapper.add(createActWrapper(objRec, 'Task', objApiNameVsIconNameMap, objRecMap));
                }
                for(sObject objRec : Database.query('SELECT Id, OwnerId, Owner.Name, Subject, Description, navpeII_dev18__Classification__c, navpeII_dev18__Related_Associations__c, EventSubType, FORMAT(ActivityDate), FORMAT(ActivityDateTime), FORMAT(EndDateTime), IsAllDayEvent, (SELECT RelationId, Relation.Name FROM EventRelations WHERE (Relation.Type = \'Contact\')) FROM Event' + limitClause)){
                    actWrapper.add(createActWrapper(objRec, 'Event', objApiNameVsIconNameMap, objRecMap));
                }
            }
            return actWrapper;
        } catch (Exception e) {
            throw new AuraHandledException(ERR_MSG + ' : <<' + e.getStackTraceString() + '>>');
        }
    }

    /************************* INTERACTIONS PAGE MAIN METHODS : END *************************/

    /************************* INTERACTIONS PAGE COMMON METHODS : START *************************/

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
            actWrap.actInfo = objRec;                           // added by sudhansu for return all field data
            actWrap.attendees = new List<ReferenceWrapper>();
            actWrap.references = new List<ReferenceWrapper>();
            actWrap.actId = String.valueOf(objRec.get('Id'));
            actWrap.type = String.valueOf(objRec.get(actObjName + 'SubType')).replace('Event', 'Meeting').replace('ListEmail', 'List Email');
            actWrap.subject = String.isNotBlank(String.valueOf(objRec.get('Subject'))) ?
                                String.valueOf(objRec.get('Subject'))
                                : '[No subject]';
            actWrap.detail = String.valueOf(objRec.get('Description'));
            actWrap.classification = String.valueOf(objRec.get('navpeII_dev18__Classification__c'));
            actWrap.actOwner = String.valueOf(objRec.getSObject('Owner').get('Name'));
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
            if(String.isNotBlank(String.valueOf(objRec.get('navpeII_dev18__Related_Associations__c')))){
                for(String taggedRecId : String.valueOf(objRec.get('navpeII_dev18__Related_Associations__c')).split(',')){
                    ReferenceWrapper refWrap = new ReferenceWrapper();
                    String recObjName = String.valueOf(Id.valueOf(taggedRecId).getsobjecttype());
                    refWrap.name = objRecMap.get(taggedRecId);
                    refWrap.nameRef = '/' + taggedRecId;
                    refWrap.iconName = recObjName.equalsIgnoreCase('Theme__c')
                                       ? objApiNameVsIconNameMap.get('Themes')
                                       : objApiNameVsIconNameMap.get(recObjName);
                                       refWrap.sortValue = getTaggedSortOrder(recObjName); //Modified by Anshika Ahuja W.R.To Bug# 00033806
                                       if(objRecMap.get(taggedRecId) != null && refWrap.iconName != null){ //Modified by Anshika Ahuja W.R.To Anurag Security bug #00038771 + Modified by Omkar fro Resolving Anurag Critical 00039972
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
                                   refWrap.sortValue = getTaggedSortOrder(recObjName); //Modified by Anshika Ahuja W.R.To Bug# 00033806
                                   if(objRecMap.get(String.valueOf(actRelRec.get('RelationId'))) != null){ //Modified by Anshika Ahuja W.R.To Anurag Security bug #00039166
                                   actWrap.attendees.add(refWrap);
                                   }
                               }
                               //For adding Assigned To user's info
                               ReferenceWrapper refWrap = new ReferenceWrapper();
                               refWrap.name = objRecMap.get(String.valueOf(objRec.get('OwnerId')));
                               refWrap.iconName = 'standard:user';
                               //Modified by Anshika Ahuja class W.R.To Bug #00033806
                               refWrap.sortValue = getTaggedSortOrder('User');
            actWrap.attendees.add(refWrap);
            return actWrap;
        } catch (Exception e) {
            throw new AuraHandledException(ERR_MSG + ' : <<' + e.getStackTraceString() + '>>');
        }
    }

    // Bug ID : 00044238 fixed on 27-02-2024 by Sudhanshu
    private static List<String> supportedType= new List<String>{ 'COMBOBOX','STRING','TEXTAREA','EMAIL','PHONE','BOOLEAN','DATETIME','DATE','PICKLIST','REFERENCE','INTEGER','DOUBLE'};

    /*
     * Purpose : Fetches the all Task Field label
     * Input : 
     * Returns : Task Fields label
     * Added by sudhanshu on 02-01-2024
     */
    @AuraEnabled
    public static Map<string,String> getTaskLabel(){
        Map<String,String> taskLable= new Map<String,String>();
        Map <String,Schema.SObjectType> gd = Schema.getGlobalDescribe();
        Schema.SObjectType sobjType = gd.get('Task');
        Schema.DescribeSObjectResult r = sobjType.getDescribe();
        Map<String, Schema.SObjectField> MapofField = r.fields.getMap();
        for(String fieldName : MapofField.keySet()) 
        {
            Schema.SObjectField field = MapofField.get(fieldName);
            String fieldType = String.valueOf(field.getDescribe().getType());
            Schema.DescribeFieldResult F = field.getDescribe();
            if(supportedType.contains(fieldType))       // Bug ID : 00044238 fixed on 27-02-2024 by Sudhanshu
            {
                taskLable.put(F.getName(), F.getLabel()+'@@@'+fieldType); // Bug 00046116,00045381 &46310 fixed by Sudhanshu 28-06-2024
            }
        }
        return taskLable;
    }

    /*
     * Purpose : Fetches the all Event Field label
     * Input : 
     * Returns : Event Fields label
     * Added by sudhanshu on 02-01-2024
     */
    @AuraEnabled
    public static Map<string,String> getEventLabel(){
        Map<String,String> eventLable= new Map<String,String>();
        Map <String,Schema.SObjectType> gd = Schema.getGlobalDescribe();
        Schema.SObjectType sobjType = gd.get('Event');
        Schema.DescribeSObjectResult r = sobjType.getDescribe();
        Map<String, Schema.SObjectField> MapofField = r.fields.getMap();
        for(String fieldName : MapofField.keySet()) 
        {
            Schema.SObjectField field = MapofField.get(fieldName);
            String fieldType = String.valueOf(field.getDescribe().getType());
            Schema.DescribeFieldResult F = field.getDescribe();
            if(supportedType.contains(fieldType))       // Bug ID : 00044238 fixed on 27-02-2024 by Sudhanshu
            {
                eventLable.put(F.getName(), F.getLabel()+'@@@'+fieldType);  // Bug 00046116 & 46310 fixed by Sudhanshu 28-06-2024
            } 
        }
        return eventLable;
    }

    /*
     * Purpose : Fetches the icon name
     * Input : subType      [Task/Event subtype]
     * Returns : Icon name
     */
    public static String fetchIconName(String subType){
        try {
            switch on subType{
                when 'Event'{
                    return 'utility:event';
                }
                when 'Task'{
                    return 'utility:task';
                }
                when 'Call'{
                    return 'utility:log_a_call';
                }
                when 'ListEmail'{
                    return 'standard:list_email';//Phase 3 Critical Bug - 00045489
                }
                when else{
                    return 'utility:email';
                }
            }
        } catch (Exception e) {
            throw new AuraHandledException(ERR_MSG + ' : <<' + e.getStackTraceString() + '>>');
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
            throw new AuraHandledException(ERR_MSG + ' : <<' + e.getStackTraceString() + '>>');
        }
    }

    /*
     * Purpose : Fetches info of icons of objects to be tagged
     * Input : objApiNameSet    [Set of object API names to be tagged]
     * Returns : Map of tagged object's API names vs icon name
     */
    private static Map<String, String> fetchIconInfo(Set<String> objApiNameSet){
        try {
            objApiNameSet.addAll(new Set<String>{'Contact', 'navpeII_dev18__Themes'});
            Map<String, String> objApiNameVsIconNameMap = new Map<String, String>();
            List<JsonResponse> layoutInfo = (list<JsonResponse>)System.JSON.deserialize(fetchEndpointResponse('/services/data/v55.0/tabs'), List<JsonResponse>.class);
            for(String objApiName : objApiNameSet){
                for(JsonResponse tab : layoutInfo){
                    if(tab.sobjectName.equalsIgnoreCase(objApiName) || tab.label.equalsIgnoreCase(objApiName)){
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
            throw new AuraHandledException(ERR_MSG + ' : <<' + e.getStackTraceString() + '>>');
        }
    }

    /*
     * Purpose : Creates map of Related object IDs vs the Activities set where it is associated with
     * Input : relRecIdVsActIdMap   [Related record ID vs Activity ID]
     *         actId                [Activity ID]
     *         relAssoIds           [Related Association IDs]
     * Returns : Map of Related object IDs vs the Activities set where it is associated with
     */
    private static Map<String, Set<String>> processRelObjVsActIds(Map<String, Set<String>> relRecIdVsActIdMap, String actId, String relAssoIds){
        try {
            for(String relRecId : relAssoIds.split(',')){
                Set<String> idSet = new Set<String>();
                if(relRecIdVsActIdMap.containsKey(relRecId)){
                    idSet = relRecIdVsActIdMap.get(relRecId);
                } else {
                    idSet = new Set<String>();
                }
                idSet.add(actId);
                relRecIdVsActIdMap.put(relRecId, idSet);
            }
            return relRecIdVsActIdMap;
        } catch (Exception e) {
            throw new AuraHandledException(ERR_MSG + ' : <<' + e.getStackTraceString() + '>>');
        }
    }

    /************************* INTERACTIONS PAGE COMMON METHODS : END *************************/

    /************************* DEALS SECTION MAIN METHODS : START *************************/

    /*
     * Purpose : Handles the Deals Section info on Account & Contact pages
     * Input : recordId         [Record ID of the current record (Account/Contact/Deal/Fund/Fundraising)]
     *         objApiName       [API name of the current record (Account/Contact/Deal/Fund/Fundraising)]
     *         recTypeDevName   [Developer Name of record type]
     *         namespacePrefix  [Namespaceprefix to be used]
     *         conIdList        [Contact ID list]
     *         dealSecTabValue  [Tab value in Deals Section]
     *         dealSecSortValue [Field identifier for sorting]
     *         dealSecSortDir   [Sort Direction]
     * Returns : Final Deals Wrapper
     */
    @AuraEnabled
    public static DealsWrapper processDealSecInfo(String recordId, String objApiName, String recTypeDevName, String namespacePrefix, List<String> conIdList, String dealSecTabValue, String dealSecSortValue, String dealSecSortDir, Boolean isDealAccessible, Boolean displayFdrSection) {
        try{
            DealsWrapper dealWrapper = new DealsWrapper();
            String objToQuery;
            String metadataIdentifier;
            String logicField;
            String query = 'SELECT Id';
            String whereClause;
            Set<String> dealIdSet = new Set<String>();
            Set<String> fdrIdSet = new Set<String>();
            
            if(objApiName.equalsIgnoreCase('Account')){
                for(Acuity_Setting__mdt acuitySetting : [SELECT DeveloperName, Value__c FROM Acuity_Setting__mdt WHERE DeveloperName LIKE 'Acuity_Firm_Deal%']){
                    if(recTypeDevName == acuitySetting.Value__c){
                        switch on acuitySetting.DeveloperName{
                            when 'Acuity_Firm_Deal_RecordType1', 'Acuity_Firm_Deal_RecordType2', 'Acuity_Firm_Deal_RecordType4', 'Acuity_Firm_Deal_RecordType5', 'Acuity_Firm_Deal_RecordType6'{
                                dealWrapper.displayToggle = false;
                                dealWrapper.title = SObjectType.navpeII_dev18__Pipeline__c.getLabelPlural();
                                dealWrapper.sortByField = namespacePrefix + 'Log_In_Date__c';
                                objToQuery = namespacePrefix + 'Pipeline__c';
                                metadataIdentifier = 'Acuity_Firm_Contact_Deal';
                            }
                            when 'Acuity_Firm_Deal_RecordType3'{
                                dealWrapper.displayToggle = true;
                                dealWrapper.title = SObjectType.navpeII_dev18__Fundraising__c.getLabelPlural();
                                dealWrapper.sortByField = namespacePrefix + 'Stage__c';
                                objToQuery = String.escapeSingleQuotes(namespacePrefix) + 'Fundraising__c';
                                metadataIdentifier = 'Acuity_Firm_FDR';
                            }
                        }
                        //For header where clause formation
                        switch on acuitySetting.DeveloperName{
                            when 'Acuity_Firm_Deal_RecordType1'{
                                logicField = String.valueOf(Acuity_Setting__mdt.getInstance('Acuity_Firm_Deal_RecordType1_LogicField').Value__c);
                                for(sObject objRec : Database.query('SELECT ' + String.escapeSingleQuotes(namespacePrefix) + 'Deal__c FROM ' + String.escapeSingleQuotes(namespacePrefix) + 'Deal_Team__c WHERE ' + logicField + ' IN :conIdList')){
                                    dealIdSet.add(String.valueOf(objRec.get(namespacePrefix + 'Deal__c')));
                                }
                                whereClause = ' WHERE Id IN :dealIdSet';
                            }
                            when 'Acuity_Firm_Deal_RecordType2'{
                                logicField = String.valueOf(Acuity_Setting__mdt.getInstance('Acuity_Firm_Deal_RecordType2_LogicField').Value__c);
                                whereClause = ' WHERE ' + logicField + '=: recordId';
                            }
                            when 'Acuity_Firm_Deal_RecordType3'{
                                logicField = String.valueOf(Acuity_Setting__mdt.getInstance('Acuity_Firm_Deal_RecordType3_LogicField').Value__c);
                                whereClause = ' WHERE ' + logicField + '=: recordId AND ' + namespacePrefix + 'Fund_Name__r.' + namespacePrefix + 'Investment_Category__c = \'' + dealSecTabValue + '\'';
                            }
                            when 'Acuity_Firm_Deal_RecordType4'{
                                logicField = String.valueOf(Acuity_Setting__mdt.getInstance('Acuity_Firm_Deal_RecordType4_LogicField').Value__c);
                                whereClause = ' WHERE ' + logicField + '=: recordId';
                            }
                            when 'Acuity_Firm_Deal_RecordType5'{
                                logicField = String.valueOf(Acuity_Setting__mdt.getInstance('Acuity_Firm_Deal_RecordType5_LogicField').Value__c);
                                for(sObject objRec : Database.query('SELECT ' + String.escapeSingleQuotes(namespacePrefix) + 'Deal__c FROM ' + String.escapeSingleQuotes(namespacePrefix) + 'Financing__c WHERE ' + logicField + '=: recordId AND ' + String.escapeSingleQuotes(namespacePrefix) + 'Deal__c != null')){
                                    dealIdSet.add(String.valueOf(objRec.get(namespacePrefix + 'Deal__c')));
                                }
                                whereClause = ' WHERE Id IN :dealIdSet';
                            }
                            when 'Acuity_Firm_Deal_RecordType6'{
                                logicField = String.valueOf(Acuity_Setting__mdt.getInstance('Acuity_Firm_Deal_RecordType6_LogicField').Value__c);
                                whereClause = ' WHERE ' + logicField + '=: recordId';
                            }
                        }
                        //For displaying sorting
                        dealWrapper.displaySorting = !(acuitySetting.DeveloperName.equalsIgnoreCase('Acuity_Firm_Deal_RecordType1') || acuitySetting.DeveloperName.equalsIgnoreCase('Acuity_Firm_Deal_RecordType5'));
                        break;
                    }
                }
            } else if(objApiName.equalsIgnoreCase('Contact')){
                dealWrapper.displaySorting = true;

                if(isDealAccessible){
                    dealWrapper.title = SObjectType.navpeII_dev18__Pipeline__c.getLabelPlural();
                    dealWrapper.displayToggle = false;
                    dealWrapper.sortByField = namespacePrefix + 'Log_In_Date__c';
                    objToQuery = namespacePrefix + 'Pipeline__c';
                    metadataIdentifier = 'Acuity_Firm_Contact_Deal';
                    logicField = String.valueOf(Acuity_Setting__mdt.getInstance('Acuity_Contact_Deal_LogicField1').Value__c);
                    //Forming the 2nd logic for Contacts
                    String logicField2 = String.valueOf(Acuity_Setting__mdt.getInstance('Acuity_Contact_Deal_LogicField2').Value__c);
                    for(sObject objRec : Database.query('SELECT ' + namespacePrefix + 'Deal__c FROM ' + namespacePrefix + 'Deal_Team__c WHERE ' + logicField2 + '=: recordId')){
                        dealIdSet.add(String.valueOf(objRec.get(namespacePrefix + 'Deal__c')));
                    }
                    whereClause = ' WHERE ' + logicField + '=: recordId OR Id IN :dealIdSet';
                } else if(!isDealAccessible && displayFdrSection) {
                    dealWrapper.title = SObjectType.navpeII_dev18__Fundraising__c.getLabelPlural();
                    dealWrapper.displayToggle = true;
                    dealWrapper.sortByField = namespacePrefix + 'Stage__c';
                    objToQuery = String.escapeSingleQuotes(namespacePrefix) + 'Fundraising__c';
                    metadataIdentifier = 'Acuity_Contact_FDR';
                    for(sObject objRec : Database.query('SELECT Id, '+ namespacePrefix +'Fundraising__c, '+namespacePrefix+'Contact__c FROM '+namespacePrefix+'Fundraising_Contact__c WHERE '+namespacePrefix+'Contact__c =: recordId')){
                        fdrIdSet.add(String.valueOf(objRec.get(namespacePrefix +'Fundraising__c')));
                    }
                    whereClause = ' WHERE Id IN: fdrIdSet AND ' + namespacePrefix + 'Fund_Name__r.' + namespacePrefix + 'Investment_Category__c = \'' + dealSecTabValue + '\'';
                }
            }
            //Creating the table headers
            String fieldApiName1 = Acuity_Setting__mdt.getInstance(metadataIdentifier+'_Field1').Value__c;
            //For Co-Investment
            if((metadataIdentifier.equalsIgnoreCase('Acuity_Firm_FDR') || metadataIdentifier.equalsIgnoreCase('Acuity_Contact_FDR')) && dealSecTabValue.equalsIgnoreCase('Co-investment')){
                fieldApiName1 = Acuity_Setting__mdt.getInstance(metadataIdentifier+'_Field5').Value__c;
            }
            if(String.isBlank(fieldApiName1)){
                return null;
            } else {
                Map<String, Schema.SObjectField> field = Schema.getGlobalDescribe().get(objToQuery).getDescribe().fields.getMap();
                String fieldApiName2;
                String fieldApiName3;
                String fieldApiName4;
                String refField1 = Acuity_Setting__mdt.getInstance(metadataIdentifier+'_Field2').Value__c;
                String refField2 = Acuity_Setting__mdt.getInstance(metadataIdentifier+'_Field3').Value__c;
                String refField3 = Acuity_Setting__mdt.getInstance(metadataIdentifier+'_Field4').Value__c;
                Boolean isAccess;
                isAccess = field.get(refField1).getDescribe().isAccessible();
                if(isAccess) {
                    fieldApiName2 = Acuity_Setting__mdt.getInstance(metadataIdentifier+'_Field2').Value__c;
                }
                isAccess = field.get(refField2).getDescribe().isAccessible();
                if(isAccess) {
                    fieldApiName3 = Acuity_Setting__mdt.getInstance(metadataIdentifier+'_Field3').Value__c;
                }
                isAccess = field.get(refField3).getDescribe().isAccessible();
                if(isAccess) {
                    fieldApiName4 = Acuity_Setting__mdt.getInstance(metadataIdentifier+'_Field4').Value__c;
                }
                dealWrapper.fieldHeader1 = fetchFieldLabel(objToQuery, fieldApiName1);
                query += ', ' + fieldApiName1;
                if(String.isNotBlank(fieldApiName2)){
                    dealWrapper.fieldHeader2 = fetchFieldLabel(objToQuery, fieldApiName2);
                    query += ', FORMAT(' + fieldApiName2 + ')';
                }
                if(String.isNotBlank(fieldApiName3)){
                    dealWrapper.fieldHeader3 = fetchFieldLabel(objToQuery, fieldApiName3);
                    query += ', FORMAT(' + fieldApiName3 + ')';
                }
                if(String.isNotBlank(fieldApiName4)){
                    dealWrapper.fieldHeader4 = fetchFieldLabel(objToQuery, fieldApiName4);
                    query += ', FORMAT(' + fieldApiName4 + ')';
                }
                //Sort Value
                switch on dealSecSortValue{
                    //Updated Date Received as part of 00035324 by Virendra
                    when 'Date Received'{
                        dealSecSortValue = String.escapeSingleQuotes(namespacePrefix) + (String.escapeSingleQuotes(objToQuery).containsIgnoreCase('Pipeline__c')
                                           ? 'Log_In_Date__c'
                                           : 'Target_Close_Date__c');
                    }
                    when 'Target Close Date'{
                        dealSecSortValue = String.escapeSingleQuotes(namespacePrefix) + (String.escapeSingleQuotes(objToQuery).containsIgnoreCase('Pipeline__c')
                                           ? 'Log_In_Date__c'
                                           : 'Target_Close_Date__c');
                    }
                    when 'Stage'{
                        dealSecSortValue = String.escapeSingleQuotes(namespacePrefix) + 'Stage__c';
                    }
                    //Added by LK on 2024-04-11 to fix 00044468 & 00044480
                    when else {
                        dealSecSortValue = String.escapeSingleQuotes(namespacePrefix) + 'Stage__c';
                    }
                }
                //Creating the table data
                if (objApiName.equalsIgnoreCase('Contact') && !isDealAccessible && displayFdrSection) {
                    query += ' FROM ' + String.escapeSingleQuotes(objToQuery) +  whereClause 
                           + ' ORDER BY ' + dealSecSortValue + ' ' + String.escapeSingleQuotes(dealSecSortDir) + ' NULLS LAST';
                } else {
                    query += ' FROM ' + String.escapeSingleQuotes(objToQuery) + (String.isNotBlank(logicField) && String.isNotBlank(whereClause) ? whereClause : '') 
                           + ' ORDER BY ' + dealSecSortValue + ' ' + String.escapeSingleQuotes(dealSecSortDir) + ' NULLS LAST';
                }
                
                List<DealsInfoWrapper> dealsDataList = new List<DealsInfoWrapper>();
                Boolean isObjectAccess = objToQuery.contains('Fundraising__c') ? Schema.sObjectType.navpeII_dev18__Fundraising__c.isAccessible() : Schema.sObjectType.navpeII_dev18__Pipeline__c.isAccessible();
                if(isObjectAccess) {
                    for(sObject objRec : Database.query(query)){
                        DealsInfoWrapper dealInfoWrap = new DealsInfoWrapper();
                        dealInfoWrap.fieldInfo1 = new ReferenceWrapper();
                        dealInfoWrap.fieldInfo2 = new ReferenceWrapper();
                        dealInfoWrap.fieldInfo3 = new ReferenceWrapper();
                        dealInfoWrap.fieldInfo4 = new ReferenceWrapper();
                        if(!((metadataIdentifier.equalsIgnoreCase('Acuity_Firm_FDR') || metadataIdentifier.equalsIgnoreCase('Acuity_Contact_FDR')) && dealSecTabValue.equalsIgnoreCase('Co-investment'))){
                            dealInfoWrap.fieldInfo1.name = String.valueOf(objRec.get(fieldApiName1));
                            dealInfoWrap.fieldInfo1.nameRef = '/' + String.valueOf(objRec.get('Id'));
                        } else {
                            String objName = fieldApiName1.split('\\.')[0];
                            if(objRec.getSObject(objName) != null){
                                dealInfoWrap.fieldInfo1.name = String.valueOf(objRec.getSObject(objName).get('Name'));
                                dealInfoWrap.fieldInfo1.nameRef = '/' + String.valueOf(objRec.get(objName.replace('__r', '__c')));
                            }
                        }
                        if(String.isNotBlank(fieldApiName2)){
                            dealInfoWrap.fieldInfo2.name = String.valueOf(objRec.get(fieldApiName2));
                        }
                        if(String.isNotBlank(fieldApiName3)){
                            dealInfoWrap.fieldInfo3.name = String.valueOf(objRec.get(fieldApiName3));
                        }
                        if(String.isNotBlank(fieldApiName4)){
                            dealInfoWrap.fieldInfo4.name = String.valueOf(objRec.get(fieldApiName4));
                        }
                        dealsDataList.add(dealInfoWrap);
                    }
                }
                dealWrapper.dealsDataList = dealsDataList;
                return dealWrapper;
            }
        } catch(Exception e) {
            throw new AuraHandledException(ERR_MSG + ' : <<' + e.getStackTraceString() + '>>');
        }
    }

    /************************* DEALS SECTION MAIN METHODS : END *************************/

    /************************* FUNDRAISING ACUITY > CONTACT SECTION MAIN METHODS : START *************************/

    /*
     * Purpose : Prepares final map of the data to be displayed under Referenced Section
     * Input : conMap            [Initial info to be used for processing final map]
     *         refField          [Referenced field 1 to be used for displaying data in Contacts/Connections section]
     *         refField2         [Referenced field 2 to be used for displaying data in Contacts/Connections section]
     *         namespacePrefix   [Namespaceprefix to be used]
     * Returns : List<InfoWrapper> containing info about each record to be displayed in data tables under Contacts/Connections Section
     */
    private static List<ConWrapper> prepareFdrConFinalMap(Map<String, sObject> conMap, String refField, String refField2, String refField3, String refField4, String namespacePrefix){
        try {
            List<ConWrapper> conInfo = new List<ConWrapper>();
            string recId = '';
            String sObjName = '';
            Id recordId; 
            if(conMap != null){//added by Shivam
                for(String conId : conMap.keySet()){
                List<String> actIdList = new List<String>();
                List<String> dealIdList = new List<String>();
                ConWrapper conWrapper = new ConWrapper();
                conWrapper.frcId = conId;
                if(String.isNotBlank(refField)){
                    if(refField.contains('__r.')){
                        recId = String.valueOf((conMap.get(conId).get(refField.split('__r.').get(0)+'__c')));
                        recordId = (Id)recId;
                        sObjName = recordId.getSObjectType().getDescribe().getName();
                        conWrapper.recId = recordId;
                        conWrapper.name = fetchFieldData(sObjName, recordId, refField.split('__r.').get(1));
                        conWrapper.nameRef = '/' + recordId;
                    }
                }
                if(String.isNotBlank(refField2)){
                    if(refField2.contains('__r.')){
                        recId = String.valueOf((conMap.get(conId).get(refField2.split('__r.').get(0)+'__c')));
                        recordId = (Id)recId;
                        sObjName = recordId.getSObjectType().getDescribe().getName();
                        conWrapper.recId2 = recordId;
                        conWrapper.name2 = fetchFieldData(sObjName, recordId, refField2.split('__r.').get(1));
                        conWrapper.nameRef2 = '/' + recordId;
                    }
                }
                if(String.isNotBlank(refField3)){
                    if(refField3.contains('__r.')){
                        recId = String.valueOf((conMap.get(conId).get(refField3.split('__r.').get(0)+'__c')));
                        recordId = (Id)recId;
                        sObjName = recordId.getSObjectType().getDescribe().getName();
                        conWrapper.fieldInfo2 = fetchFieldData(sObjName, recordId, refField3.split('__r.').get(1));
                    } else {
                        conWrapper.fieldInfo2 = String.valueOf((conMap.get(conId).get(refField3)));     
                    }
                }
                if(String.isNotBlank(refField4)){
                    if(refField4.contains('__r.')){
                        recId = String.valueOf((conMap.get(conId).get(refField4.split('__r.').get(0)+'__c')));
                        recordId = (Id)recId;
                        sObjName = recordId.getSObjectType().getDescribe().getName();
                        conWrapper.fieldInfo3 = fetchFieldData(sObjName, recordId, refField4.split('__r.').get(1));    
                    } else {
                        conWrapper.fieldInfo3 = String.valueOf((conMap.get(conId).get(refField4)));        
                    }
                }
                /* Meeting Count Handling : Start */
                conWrapper.meetingCallCount = objIdVsActIdsMap.containsKey(String.valueOf(conMap.get(conId).get(namespacePrefix+'Contact__c')))
                                                ? objIdVsActIdsMap.get(String.valueOf(conMap.get(conId).get(namespacePrefix+'Contact__c'))).size()
                                                : 0;
                conWrapper.meetingCallIdList = objIdVsActIdsMap.containsKey(String.valueOf(conMap.get(conId).get(namespacePrefix+'Contact__c')))
                                               ? new List<String>(objIdVsActIdsMap.get(String.valueOf(conMap.get(conId).get(namespacePrefix+'Contact__c'))))
                                               : new List<String>();
                if(objIdVsActIdsMap.containsKey(String.valueOf(conMap.get(conId).get(namespacePrefix+'Contact__c')))){
                    actIdList.addAll(objIdVsActIdsMap.get(String.valueOf(conMap.get(conId).get(namespacePrefix+'Contact__c'))));
                }
                conWrapper.meetingCallIdList = actIdList;
                /* Meeting Count Handling : End */
                
                /* Deal Count Handling : Start */
                conWrapper.dealCount = objIdVsDealIdsMap.containsKey(String.valueOf(conMap.get(conId).get(namespacePrefix+'Contact__c')))
                                        ? objIdVsDealIdsMap.get(String.valueOf(conMap.get(conId).get(namespacePrefix+'Contact__c'))).size()
                                        : 0;
                if(objIdVsDealIdsMap.containsKey(String.valueOf(conMap.get(conId).get(namespacePrefix+'Contact__c')))){
                    dealIdList.addAll(objIdVsDealIdsMap.get(String.valueOf(conMap.get(conId).get(namespacePrefix+'Contact__c'))));
                }
                conWrapper.dealIdList = dealIdList;
                /* Deal Count Handling : End */
                /* RG : START */
                //Merged with Shivam for Deals and Mails count 15-12-2022
                String conEmail = String.valueOf(conMap.get(conId).getSObject(namespacePrefix+'Contact__r').get('Email'));                
                conWrapper.email = conEmail;
                conWrapper.emailCount = emailVsCount.containsKey(conEmail)
                                        ? emailVsCount.get(conEmail)
                                        : 0;
                conWrapper.mailboxId = String.valueOf(userIdVsMBid.get(String.valueOf(conMap.get(conId).get('navpeII_dev18__Contact__c'))));
                /* RG : END */
                conWrapper.totalActCount = conWrapper.meetingCallCount + conWrapper.dealCount + conWrapper.emailCount;
                conInfo.add(conWrapper);
            }
            }            
            return conInfo;
        } catch (Exception e) {
            throw new AuraHandledException(ERR_MSG + ' : <<' + e.getStackTraceString() + '>>');
        }   
    }
	
    /************************* FUNDRAISING ACUITY > CONTACT SECTION MAIN METHODS : END *************************/

    /************************* FUNDRAISING ACUITY > CONTACT SECTION COMMON METHODS : START *************************/

    /*
     * Purpose : To get the record details 
     * Input : objectName            [Name of the object - Contact/Institution]
     *         recordId          	 [record id]
     *         fieldName		     [api name of the referenced field]
     * Returns : String				 Returns field value
     */
    private static String fetchFieldData(String objectName, String recordId, String fieldName){
    	try {
            SObject sobjRec = Database.query('SELECT Id, ' + String.escapeSingleQuotes(fieldName) + ' FROM ' + String.escapeSingleQuotes(objectName) + ' WHERE ID=:recordId'); 
            return (String.valueOf(sobjRec.get(fieldName)));    
        } catch(Exception e) {
            throw new AuraHandledException(ERR_MSG + ' : <<' + e.getStackTraceString() + '>>');
        }
    }

    /*
     * Purpose : Delete Fundraising Contact Record
     * Input   : List<Id>           [Ids of Fundraising Contacts]
     * Returns : String				Returns deleted fundraising Contacts names
     */
    @AuraEnabled
    public static String deleteFundraisingContactRecord(List<Id> frcIdsList) {
        try{
            String strObjectApiName = getNamespacePrefix() + '__' + 'Fundraising_Contact__c';
            String query = 'SELECT ';
            query += 'Id, Name FROM ' + strObjectApiName ;
            //Just in case criteria field not specified then it will return all records
            if(!frcIdsList.isEmpty()){
                query += ' where id IN: frcIdsList WITH SECURITY_ENFORCED';
            }
            List<navpeII_dev18__Fundraising_Contact__c> lstRecords = new List<navpeII_dev18__Fundraising_Contact__c>(); //Modified by Anshika Ahuja W.R.To Bug # 00034869
            if(String.isNotBlank(query)) {
                lstRecords = Database.query(query);  
            }
            String fundraisingContactNames = '';
            for(SObject dealTeam : lstRecords){
                fundraisingContactNames = string.valueOf(dealTeam.get('Name'));
            } 
            if (navpeII_dev18__Fundraising_Contact__c.sObjectType.getDescribe().isDeletable()) {  //Modified by Anshika Ahuja W.R.To Bug # 00034869
                if(!Test.isRunningTest()){
                	delete lstRecords;    
                }
            } 
            return fundraisingContactNames;    
        } catch(Exception e){
            //return null;
            //Updated error msg body by LK on 2024-05-24 to fix 00044998
            throw new AuraHandledException(ERR_MSG + ' : <<' + e.getMessage() + '>>');
        }
    }

    /************************* FUNDRAISING ACUITY > CONTACT SECTION COMMON METHODS : END *************************/
    
    /******************** FIRM (PRIVATE EQUITY) ACUITY > DEAL SECTION MAIN METHODS : START ********************/

    /*
    * Purpose : Processes info for Contacts/Connections section
    * Input : recordId         [Record ID]
    *         metadataField1   [Field 1 to process for Deal Section]
    *         metadataField2   [Field 2 to process for Deal Section]
    *         metadataField3   [Field 3 to process for Deal Section]
    *         metadataField4   [Field 4 to process for Deal Section]
    *         namespacePrefix  [Namespaceprefix to be used]
    *         valueSorting     [Order (ASC/DESC)]
    *         fieldNameForSort [Field based on which the sorting is to be done]
    *         criteriaField    [Tab value (Fund/Sourced)]
    * Returns : Final Deals Wrapper
    */
    @AuraEnabled
    public static ResponseWrapper processDealInfo(String recordId, String metadataField1, String metadataField2, String metadataField3, String metadataField4, String namespacePrefix, String valueSorting, String fieldNameForSort, String criteriaField){
        Map<String, sObject> dealMap = new Map<String, sObject>();
        try {
            String refField1 = Acuity_Setting__mdt.getInstance(metadataField1).Value__c;
            String refField2 = Acuity_Setting__mdt.getInstance(metadataField2).Value__c;
            String refField3 = Acuity_Setting__mdt.getInstance(metadataField3).Value__c;
            String refField4 = Acuity_Setting__mdt.getInstance(metadataField4).Value__c;
            String refField5;
            String refField6;
            String otherMetadataFields = String.isNotBlank(metadataField2) ? metadataField2 : '';
            otherMetadataFields += (String.isNotBlank(metadataField3) ? (',' + metadataField3) : '');
            otherMetadataFields += (String.isNotBlank(metadataField4) ? (',' + metadataField4) : '');
            String orderBy = '';
            if(!(String.isEmpty(valueSorting) && String.isEmpty(fieldNameForSort))){
                if(fieldNameForSort == 'stage') {
                    String fieldApiNameForSort = refField2;
                    orderBy += ' ORDER BY ' +fieldApiNameForSort+ ' '+valueSorting + ' NULLS LAST '; 
                } else if(fieldNameForSort == 'date') {
                    String fieldApiNameForSort = refField4;
                    orderBy += ' ORDER BY ' +fieldApiNameForSort+' '+valueSorting + ' NULLS LAST ';
                }
            }
            ResponseWrapper respWrapper = new ResponseWrapper();
            if(criteriaField == 'Funds') {
                refField5 = Acuity_Setting__mdt.getInstance('Acuity_Firm_Deal_RecordType7_LogicField1').Value__c;
                dealMap = fetchInitInfoToProcess(metadataField1, otherMetadataFields, namespacePrefix + 'Pipeline__c', '  WHERE ' + refField5 + ' = :recordId ' + orderBy, recordId, null);
            } else if(criteriaField == 'Sourced') {
                refField6 = Acuity_Setting__mdt.getInstance('Acuity_Firm_Deal_RecordType7_LogicField2').Value__c;
                dealMap = fetchInitInfoToProcess(metadataField1, otherMetadataFields, namespacePrefix + 'Pipeline__c', '  WHERE ' + refField6 + ' = :recordId ' + orderBy, recordId, null);
            }
            String objectName = namespacePrefix + 'Pipeline__c';
            Map<String, Schema.SObjectField> field = Schema.getGlobalDescribe().get(objectName).getDescribe().fields.getMap();
            Schema.DisplayType fieldType;
            if(String.isNotBlank(refField2)){
                fieldType = field.get(refField2.replace('__r.Name','__c')).getDescribe().getType(); // or getSOAPType()
                respWrapper.conSecDynFieldHeader = fetchFieldLabel(objectName, refField2) + ';' + refField2 + ';' + String.valueOf(fieldType);
 		    }
            if(String.isNotBlank(refField3)){
                fieldType = field.get(refField3.replace('__r.Name','__c')).getDescribe().getType(); // or getSOAPType()
                respWrapper.conSecDynFieldHeader2 = fetchFieldLabel(objectName, refField3) +';' + refField3 + ';' + String.valueOf(fieldType);
            }
            if(String.isNotBlank(refField4)){
                fieldType = field.get(refField4.replace('__r.Name','__c')).getDescribe().getType(); // or getSOAPType()
                respWrapper.conSecDynFieldHeader3 = fetchFieldLabel(objectName, refField4) +';' + refField4 + ';' + String.valueOf(fieldType);
            }
            List<DealTeamWrapper> dealWrapperList = prepareDealFinalMap(refField1, refField2, refField3, refField4, namespacePrefix,dealMap);
            respWrapper.title = SObjectType.navpeII_dev18__Pipeline__c.getLabelPlural();
            respWrapper.dealInfoWrapper = dealWrapperList;
            return respWrapper;
        } catch (Exception e) {
            throw new AuraHandledException(ERR_MSG + ' : <<' + e.getStackTraceString() + '>>');
        }
    }

    /*
    * Purpose : Prepares final map of the data to be displayed under Referenced Section
    * Input : fundraisingMap    [Initial info to be used for processing final map]
    *         refField          [Referenced field 1 to be used for displaying data in Contacts/Connections section]
    *         refField2         [Referenced field 2 to be used for displaying data in Contacts/Connections section]
    *         namespacePrefix   [Namespaceprefix to be used]
    * Returns : List<InfoWrapper> containing info about each record to be displayed in data tables under Contacts/Connections Section
    */
    public static List<DealTeamWrapper> prepareDealFinalMap(String refField1, String refField2, String refField3, String refField4, String namespacePrefix, Map<String, sObject> dealMap){
        try {
            List<DealTeamWrapper> dealInfo = new List<DealTeamWrapper>();
            string recId = '';
            String sObjName='';
            Id recordId;
            for(String dealId : dealMap.keySet()){
                List<String> actIdList = new List<String>();
                List<String> dealIdList = new List<String>();
                DealTeamWrapper dealWrapper = new DealTeamWrapper();
                dealWrapper.Id = dealId;
                if(String.isNotBlank(refField1)){
                    if(refField1.contains('__r.')){
                        recId = String.valueOf((dealMap.get(dealId).get(refField1.split('__r.').get(0)+'__c')));
                        recordId = (Id)recId;
                        sObjName = recordId.getSObjectType().getDescribe().getName();
                        dealWrapper.recId = recordId;
                        dealWrapper.name = fetchFieldData(sObjName, recordId, refField1.split('__r.').get(1));
                        dealWrapper.nameRef = '/' + recordId;
                    } else {
                        dealWrapper.recId = dealId;
                        dealWrapper.name = String.valueOf((dealMap.get(dealId).get(refField1)));     
                        dealWrapper.nameRef = '/' + dealId;
                    }
                }
                if(String.isNotBlank(refField2)){
                    if(refField2.contains('__r.')){
                        recId = String.valueOf((dealMap.get(dealId).get(refField2.split('__r.').get(0)+'__c')));
                        recordId = (Id)recId;
                        sObjName = recordId.getSObjectType().getDescribe().getName();
                        dealWrapper.fieldInfo = fetchFieldData(sObjName, recordId, refField2.split('__r.').get(1));
                    } else {
                        dealWrapper.fieldInfo = String.valueOf((dealMap.get(dealId).get(refField2)));     
                    }
                }
                if(String.isNotBlank(refField3)){
                    if(refField3.contains('__r.')){
                        recId = String.valueOf((dealMap.get(dealId).get(refField3.split('__r.').get(0)+'__c')));
                        recordId = (Id)recId;
                        sObjName = recordId.getSObjectType().getDescribe().getName();
                        dealWrapper.fieldInfo2 = fetchFieldData(sObjName, recordId, refField3.split('__r.').get(1));
                    } else {
                        dealWrapper.fieldInfo2 = String.valueOf((dealMap.get(dealId).get(refField3)));     
                    }
                }
                if(String.isNotBlank(refField4)){
                    if(refField4.contains('__r.')){
                        recId = String.valueOf((dealMap.get(dealId).get(refField4.split('__r.').get(0)+'__c')));
                        recordId = (Id)recId;
                        sObjName = recordId.getSObjectType().getDescribe().getName();
                        dealWrapper.fieldInfo3 = date.parse(fetchFieldData(sObjName, recordId, refField4.split('__r.').get(1)));    
                    } else {
                        if(dealMap.get(dealId).get(refField4) != null) {
                            dealWrapper.fieldInfo3 = date.parse(String.valueOf((dealMap.get(dealId).get(refField4))));        
                        }
                    }
                }
                dealInfo.add(dealWrapper);
            }
            return dealInfo;
        } catch (Exception e) {
            throw new AuraHandledException(ERR_MSG + ' : <<' + e.getStackTraceString() + '>>');
        }   
    }
    
    /******************** FIRM (PRIVATE EQUITY) ACUITY > DEAL SECTION MAIN METHODS : END ********************/

    /******************** DEAL ACUITY > DEAL TEAM (INTERNAL) SECTION MAIN METHODS : START ********************/

    @AuraEnabled
    public static ResponseWrapper processDealTeamInfo(String recordId, String metadataField1, String metadataField2, String metadataField3, String namespacePrefix, String criteriaField){
        Map<String, sObject> dealTeamMap = new Map<String, sObject>();
        try {
            String refField1 = Acuity_Setting__mdt.getInstance(metadataField1).Value__c;
            String refField2 = Acuity_Setting__mdt.getInstance(metadataField2).Value__c;
            String refField3 = Acuity_Setting__mdt.getInstance(metadataField3).Value__c;
            String refField4;
            String refField6;
            String otherMetadataFields = String.isNotBlank(metadataField2) ? metadataField2 : '';
            otherMetadataFields += (String.isNotBlank(metadataField3) ? (',' + metadataField3) : '');
            ResponseWrapper respWrapper = new ResponseWrapper();
            if(criteriaField == 'Internal'){
                refField4 = Acuity_Setting__mdt.getInstance('Acuity_DealTeam_FieldLogic').Value__c;
                dealTeamMap = fetchInitInfoToProcess(metadataField1,otherMetadataFields, namespacePrefix + 'Deal_Team__c', '  WHERE ' + refField4 + ' = :recordId AND ' + refField1 + '!= null', recordId, null);
            } 
            String objectName = namespacePrefix+'Deal_Team__c';
            Map<String, Schema.SObjectField> field = Schema.getGlobalDescribe().get(objectName).getDescribe().fields.getMap();
            Schema.DisplayType fieldType;
            if(String.isNotBlank(refField1)){
                fieldType = field.get(refField1.replace('__r.Name','__c')).getDescribe().getType();
                respWrapper.conSecDynFieldHeader = fetchFieldLabel(objectName, refField1) + ';' + refField1 + ';' + String.valueOf(fieldType);
            }
            if(String.isNotBlank(refField2)){
                fieldType = field.get(refField2.replace('__r.Title','__c')).getDescribe().getType();
                respWrapper.conSecDynFieldHeader2 = fetchFieldLabel(objectName, refField2) +';' + refField2 + ';' + String.valueOf(fieldType);
            }
            if(String.isNotBlank(refField3)){
                fieldType = field.get(refField3.replace('__r.Name','__c')).getDescribe().getType();
                respWrapper.conSecDynFieldHeader3 = fetchFieldLabel(objectName, refField3) +';' + refField3 + ';' + String.valueOf(fieldType);
            }
            List<DealTeamWrapper> dealTeamWrapperList = prepareDealTeamFinalMap(refField1, refField2, refField3, namespacePrefix, dealTeamMap);
            respWrapper.dealInfoWrapper = dealTeamWrapperList;
            return respWrapper;
        } catch (Exception e) {
            throw new AuraHandledException(ERR_MSG + ' : <<' + e.getStackTraceString() + '>>');
        }
    }

    private static List<DealTeamWrapper> prepareDealTeamFinalMap(String refField1, String refField2, String refField3, String namespacePrefix, Map<String, sObject> dealTeamMap){
        try {
            List<DealTeamWrapper> dealTeamInfo = new List<DealTeamWrapper>();
            String recId = '';
            String sObjName='';
            Id recordId;
            for(String dealTeamId : dealTeamMap.keySet()){
                List<String> actIdList = new List<String>();
                List<String> dealIdList = new List<String>();
                DealTeamWrapper dealWrapper = new DealTeamWrapper();
                dealWrapper.Id = dealTeamId;
                if(String.isNotBlank(refField1)){
                    if(refField1.contains('__r.')){
                        recId = String.valueOf((dealTeamMap.get(dealTeamId).get(refField1.split('__r.').get(0)+'__c')));
                        recordId = (Id)recId;
                        sObjName = recordId.getSObjectType().getDescribe().getName();
                        dealWrapper.name = fetchFieldData(sObjName, recordId, refField1.split('__r.').get(1));
                    } else {
                        dealWrapper.name = String.valueOf((dealTeamMap.get(dealTeamId).get(refField1)));     
                    }
                }
                if(String.isNotBlank(refField2)){
                    if(refField2.contains('__r.')){
                        recId = String.valueOf((dealTeamMap.get(dealTeamId).get(refField2.split('__r.').get(0)+'__c')));
                        recordId = (Id)recId;
                        sObjName = recordId.getSObjectType().getDescribe().getName();
                        dealWrapper.fieldInfo = fetchFieldData(sObjName, recordId, refField2.split('__r.').get(1));
                    } else {
                        dealWrapper.fieldInfo = String.valueOf((dealTeamMap.get(dealTeamId).get(refField2)));     
                    }
                }
                if(String.isNotBlank(refField3)){
                    if(refField3.contains('__r.')){
                        recId = String.valueOf((dealTeamMap.get(dealTeamId).get(refField3.split('__r.').get(0)+'__c')));
                        recordId = (Id)recId;
                        sObjName = recordId.getSObjectType().getDescribe().getName();
                        dealWrapper.fieldInfo2 = fetchFieldData(sObjName, recordId, refField3.split('__r.').get(1));
                    } else {
                        dealWrapper.fieldInfo2 = String.valueOf((dealTeamMap.get(dealTeamId).get(refField3)));     
                    }
                }
                dealTeamInfo.add(dealWrapper);
            }
            return dealTeamInfo;
        } catch (Exception e) {
            throw new AuraHandledException(ERR_MSG + ' : <<' + e.getStackTraceString() + '>>');
        }   
    }
     
    @AuraEnabled
    public static String deleteDealTeamRecord(String namespacePrefix, List<Id> idsToDelete){
        try{
            String strObjectApiName = String.escapeSingleQuotes(namespacePrefix) + 'Deal_Team__c';
            String query = '';
            if(!idsToDelete.isEmpty()){
                query = 'SELECT ';
                query += 'Id, Name FROM ' + String.escapeSingleQuotes(strObjectApiName) ;
                //Just in case criteria field not specified then it will return all records
                query += ' where id IN: idsToDelete LIMIT 10000';
            }
            List<navpeII_dev18__Deal_Team__c> lstRecords = new List<navpeII_dev18__Deal_Team__c>(); //Modified by Anshika Ahuja W.R.To Bug # 00034869       
            if(String.isNotBlank(query)) {
                lstRecords = Database.query(query);  
            }
            String dealTeamName = '';
            for(SObject dealTeam : lstRecords){
                dealTeamName = string.valueOf(dealTeam.get('Name'));
            } 
            If(!lstRecords.isEmpty() && navpeII_dev18__Deal_Team__c.sObjectType.getDescribe().isDeletable()) {  //Modified by Anshika Ahuja W.R.To Bug # 00034869   
                delete lstRecords;
            }
            return dealTeamName;
        } catch (Exception e) {
            //Updated error msg body by LK on 2024-05-24 to fix 00044998
            throw new AuraHandledException(ERR_MSG + ' : <<' + e.getMessage() + '>>');
        }
    }
    
    /******************** DEAL ACUITY > DEAL TEAM (INTERNAL) SECTION MAIN METHODS : END ********************/

    /******************** DEAL ACUITY > DEAL TEAM (EXTERNAL) SECTION MAIN METHODS : START ********************/

    /*
     * Purpose : Handles the Companies Referenced information on Account & Contact objects
     * Input : recordId     [Record ID of the current record (Account/Contact)]
     *         conIdList    [List of contacts of the Account to be processed; For Account : CR only; Null for Contact : CR]
     *         accId        [Account ID of the current contact; For Contact : CR only; Null for Account : CR]
     *         namespacePrefix  [Namespaceprefix to be used]
     * Returns : List<InfoWrapper> containing info about each record to be displayed under CR data table
     */
    //public static List<String> fetchRecsToProcess2(List<String> conIdList){
    //    try {
    //        List<String> actIdList = new List<String>();
    //        List<String> actIdList1 = new List<String>();
    //        List<String> actIdList2 = new List<String>();
    //        for(sObject ev : Database.query('SELECT EventId, RelationId FROM EventRelation WHERE (Relation.Type = \'Contact\') AND (RelationId IN :conIdList) AND (IsDeleted = false) ALL ROWS')){
    //            actIdList1.add(String.valueOf(ev.get('EventId')));
    //            processRelObjIds(String.valueOf(ev.get('RelationId')), String.valueOf(ev.get('EventId')));
    //        }
    //        actIdList.addAll(actIdList1);
    //        if(Schema.getGlobalDescribe().get('TaskRelation') != null){
    //        	for(sObject ev : Database.query('SELECT TaskId, RelationId FROM TaskRelation WHERE (Task.TaskSubType != \'ListEmail\') AND (Relation.Type = \'Contact\') AND (RelationId IN :conIdList) AND (IsDeleted = false) ALL ROWS')){
    //                actIdList2.add(String.valueOf(ev.get('TaskId')));
    //                processRelObjIds(String.valueOf(ev.get('RelationId')), String.valueOf(ev.get('TaskId')));
    //            }
    //            actIdList.addAll(actIdList2);    
    //        }
    //        return actIdList;
    //    } catch (Exception e) {
    //        throw new AuraHandledException(ERR_MSG + ' : <<' + e.getStackTraceString() + '>>');
    //    }
    //}

    public static List<String> fetchRecsToProcess2(List<String> conIdList, String objApiName){
        try {
            List<String> actIdList = new List<String>();
            //List<String> actIdList1 = new List<String>();
            //List<String> actIdList2 = new List<String>();
            if(objApiName.equalsIgnoreCase('Event')){
            for(sObject ev : Database.query('SELECT EventId, RelationId FROM EventRelation WHERE (Relation.Type = \'Contact\') AND (RelationId IN :conIdList) AND (IsDeleted = false) ALL ROWS')){
                actIdList.add(String.valueOf(ev.get('EventId')));
                //Commented below line by LK to fix 00042607 on 2023-10-18
                //processRelObjIds(String.valueOf(ev.get('RelationId')), String.valueOf(ev.get('EventId')));
            }
            //actIdList.addAll(actIdList);
            } else if(objApiName.equalsIgnoreCase('Task')){
            if(Schema.getGlobalDescribe().get('TaskRelation') != null){
                for(sObject ev : Database.query('SELECT TaskId, RelationId FROM TaskRelation WHERE (Relation.Type = \'Contact\') AND (RelationId IN :conIdList) AND (IsDeleted = false) ALL ROWS')){
                    actIdList.add(String.valueOf(ev.get('TaskId')));
                    //Commented below line by LK to fix 00042607 on 2023-10-18
                    //processRelObjIds(String.valueOf(ev.get('RelationId')), String.valueOf(ev.get('TaskId')));
                }
                //actIdList.addAll(actIdList2);    
            }
            }            
            return actIdList;
        } catch (Exception e) {
            throw new AuraHandledException(ERR_MSG + ' : <<' + e.getStackTraceString() + '>>');
        }
    }
    
    @AuraEnabled
    public static ResponseWrapper processDealTeamEXTInfo(String recordId, String metadataField1, String metadataField2, String metadataField3, String metadataField4, String namespacePrefix){
        try{
            ResponseWrapper respWrapper = new ResponseWrapper();
            List<String> conIdList = new List<String>();
            //respWrapper.isEmailDrillDownEnabled = Boolean.valueOf(RG_Setting__mdt.getInstance('Acuity_Enable_RG_Email_Details').Value__c);
            //Replaced above line with 2 below lines by lK on 2024-10-10 to fix 00047721
            String enableRgEmailDetails = RG_Setting__mdt.getInstance('Acuity_Enable_RG_Email_Details').Value__c;
            respWrapper.isEmailDrillDownEnabled = enableRgEmailDetails == null || !enableRgEmailDetails.equalsIgnoreCase('false');
            String refField1 = Acuity_Setting__mdt.getInstance(metadataField1).Value__c;
            String refField2 = Acuity_Setting__mdt.getInstance(metadataField2).Value__c;
            String refField3 = Acuity_Setting__mdt.getInstance(metadataField3).Value__c;
            String refField4 = Acuity_Setting__mdt.getInstance(metadataField4).Value__c;
            String otherMetadataFields = String.isNotBlank(metadataField2) ? metadataField2 : '';
            otherMetadataFields += (String.isNotBlank(metadataField3) ? (',' + metadataField3) : '');
            otherMetadataFields += (String.isNotBlank(metadataField4) ? (',' + metadataField4) : '');
            respWrapper.conMap = fetchInitInfoToProcess(metadataField1, otherMetadataFields, namespacePrefix + 'Deal_Team__c', '  WHERE ' + namespacePrefix + 'Deal__c = :recordId AND ' + namespacePrefix + 'Deal_Contact__c != null', recordId, null);
            conIdList.addAll(respWrapper.conMap.keySet()); // Returns Deal Team record ids VS Deal Team Records
            respWrapper.conIdList = conIdList;
            Set<String> parentConIdSet = new Set<String>();
            for(SObject dealTeamRec : Database.query('Select Id, ' + string.escapesinglequotes(namespacePrefix) + 'Deal_Contact__c FROM ' + string.escapesinglequotes(namespacePrefix) + 'Deal_Team__c WHERE ' + string.escapesinglequotes(namespacePrefix) + 'Deal__c =:recordId')){ //Modified by Anshika Ahuja W.R.To Bug #00034852
                String conId = String.valueOf(dealTeamRec.get(namespacePrefix + 'Deal_Contact__c'));
                if(String.isNotBlank(conId)){
                    parentConIdSet.add(conId);
                }
            }
            respWrapper.parentConIdList = new List<String>(parentConIdSet);
            if(String.isNotBlank(refField2)){
                respWrapper.conSecDynFieldHeader = fetchFieldLabel('Account', 'Name');
            }
            if(String.isNotBlank(refField3)){
                respWrapper.conSecDynFieldHeader2 = fetchFieldLabel('Contact', refField3.split('__r.').get(1));    
            }
            if(String.isNotBlank(refField4)){
                respWrapper.conSecDynFieldHeader3 = fetchFieldLabel(namespacePrefix+'Deal_Team__c', refField4);
            }
            //Commented below line by LK to fix 00042607 on 2023-10-18
            //objIdVsActIdsMap = new Map<String, Set<String>>();
            List<String> activityIdList = new List<String>();
            //For Meeting Call Datapoint calculation
            List<String> eventIdList = new List<String>();
            eventIdList = fetchRecsToProcess2(new List<String>(parentConIdSet), 'Event');
            processMeetingCallInfo(eventIdList, 'Event', recordId, ' WHERE EventId IN :respWrapper.actIdList AND Relation.Type = \'Contact\'');
            if(eventIdList != null && eventIdList.size() > 0){
                activityIdList.addAll(eventIdList);
                eventIdList.clear();
            }
            List<String> taskIdList = new List<String>();
            taskIdList = fetchRecsToProcess2(new List<String>(parentConIdSet), 'Task');
            processMeetingCallInfo(taskIdList, 'Task', recordId, ' WHERE TaskId IN :respWrapper.actIdList AND Task.TaskSubType = \'Call\' AND Relation.Type = \'Contact\'');
            if(taskIdList != null && taskIdList.size() > 0){
                activityIdList.addAll(taskIdList);
                taskIdList.clear();
            }
            respWrapper.actIdList = activityIdList;
            //For Deal & Email Datapoint
            Map<String, sObject> conIdVsRecMap = handleDealload(recordId);
            List<ConWrapper> conWrapperList = prepareDealTeamEXTMap(respWrapper.conMap, refField1, refField2, refField3, refField4, namespacePrefix, parentConIdSet, respWrapper.actIdList, conIdVsRecMap);
            respWrapper.conInfoWrapper = conWrapperList;
            //added by shivam
            If(IsApiError){
                respWrapper.apiError = true;
            }
            return respWrapper;
        } catch(Exception e) {
            throw new AuraHandledException(ERR_MSG + ' : <<' + e.getStackTraceString() + '>>');
    	}    
    }
    
    private static List<ConWrapper> prepareDealTeamEXTMap(Map<String, sObject> conMap, String refField1, String refField2, String refField3, String refField4, String namespacePrefix, Set<String> parentConIdSet, List<String> actIdList, Map<String, sObject> conIdVsRecMap){
        try {
            List<ConWrapper> conInfo = new List<ConWrapper>();
            string recId = '';
            String sObjName='';
            Id recordId;
            List<String> actIdList2 = new List<String>();
            set<String> conIdSet = new set<String>();
            for(String conId : conMap.keySet()){
                conIdSet.add(String.valueOf(conMap.get(conId).get(namespacePrefix+'Deal_Contact__c')));
            }
            Map<String,UserRecordAccess> recordVsAccessDetails = new Map<String,UserRecordAccess>();
            List<UserRecordAccess> acessList = [SELECT RecordId, HasReadAccess, HasTransferAccess, MaxAccessLevel
                                                FROM UserRecordAccess
                                                WHERE UserId = :UserInfo.getUserId()
                                                AND RecordId IN :  conIdSet];
            for(UserRecordAccess ura : acessList){
                recordVsAccessDetails.put(ura.RecordId,ura);
            }
            for(String conId : conMap.keySet()){
                //List<String> actIdList = new List<String>();
                if(recordVsAccessDetails.get(String.valueOf(conMap.get(conId).get(namespacePrefix+'Deal_Contact__c'))).HasReadAccess){
                    List<String> dealIdList = new List<String>();
                    ConWrapper conWrapper = new ConWrapper();
                    conWrapper.frcId = conId;
                    if(String.isNotBlank(refField1)){
                        if(refField1.contains('__r.')){
                            recId = String.valueOf(conMap.get(conId).get(refField1.split('\\.').get(0).replace('__r', '__c')));
                            recordId = Id.valueOf(recId);
                            sObjName = recordId.getSObjectType().getDescribe().getName();
                            conWrapper.recId = recordId;
                            conWrapper.name = fetchFieldData(sObjName, recordId, refField1.split('__r.').get(1));
                            conWrapper.nameRef = '/' + recordId;
                        }
                    }
                    if(String.isNotBlank(refField2)){
                        if(refField2.contains('__r.')){
                            recId = String.valueOf((conMap.get(conId).get(refField2.split('__r.').get(0)+'__c')));
                            recordId = Id.valueOf(recId);
                            sObjName = recordId.getSObjectType().getDescribe().getName();
                            conWrapper.recId2 = recordId;
                            string name2 = fetchFieldData(sObjName, recordId, refField2.split('__r.').get(1));
                            conWrapper.name2 = fetchFieldData('Account', name2, 'Name');
                            conWrapper.nameRef2 = '/' + name2; //Modified by Anshika Ahuja W.R.To Bug #00033516
                        }
                    }
                    if(String.isNotBlank(refField3)){
                        if(refField3.contains('__r.')){
                            recId = String.valueOf((conMap.get(conId).get(refField3.split('__r.').get(0)+'__c')));
                            recordId = Id.valueOf(recId);
                            sObjName = recordId.getSObjectType().getDescribe().getName();
                            conWrapper.fieldInfo2 = fetchFieldData(sObjName, recordId, refField3.split('__r.').get(1));
                        } else {
                            conWrapper.fieldInfo2 = String.valueOf((conMap.get(conId).get(refField3)));     
                        }
                    }
                    if(String.isNotBlank(refField4)){
                        if(refField4.contains('__r.')){
                            recId = String.valueOf((conMap.get(conId).get(refField4.split('__r.').get(0)+'__c')));
                            recordId = Id.valueOf(recId);
                            sObjName = recordId.getSObjectType().getDescribe().getName();
                            conWrapper.fieldInfo3 = fetchFieldData(sObjName, recordId, refField4.split('__r.').get(1));
                        } else {
                            conWrapper.fieldInfo3 = String.valueOf((conMap.get(conId).get(refField4)));        
                        }
                    }
                    conWrapper.meetingCallCount = objIdVsActIdsMap.containsKey(String.valueOf(conMap.get(conId).get(namespacePrefix+'Deal_Contact__c')))
                        ? objIdVsActIdsMap.get(String.valueOf(conMap.get(conId).get(namespacePrefix+'Deal_Contact__c'))).size()
                        : 0;
                    conWrapper.meetingCallIdList = objIdVsActIdsMap.containsKey(String.valueOf(conMap.get(conId).get(namespacePrefix+'Deal_Contact__c')))
                        ? new List<String>(objIdVsActIdsMap.get(String.valueOf(conMap.get(conId).get(namespacePrefix+'Deal_Contact__c'))))
                        : new List<String>();
                    /* RG : START */
                    
                    
                    String conEmailId = String.valueOf(conIdVsRecMap.get(String.valueOf(conMap.get(conId).get(namespacePrefix + 'Deal_Contact__c'))).get('Email'));                                        
                    conWrapper.email = conEmailId;
                    conWrapper.emailCount = String.isNotBlank(conEmailId) && emailVsCount.containsKey(conEmailId)
                        ? emailVsCount.get(conEmailId)
                        : 0;
                    /* RG : END */
                    /* Deal Count Handling : Start */
                    String contactId = String.valueOf(conMap.get(conId).get(namespacePrefix + 'Deal_Contact__c'));
                    conWrapper.dealCount = objIdVsDealIdsMap.containsKey(contactId)
                        ? objIdVsDealIdsMap.get(contactId).size()
                        : 0;
                    if(objIdVsDealIdsMap.containsKey(contactId)){
                        dealIdList.addAll(objIdVsDealIdsMap.get(contactId));
                    }
                    conWrapper.dealIdList = dealIdList;
                    /* Deal Count Handling : End */
                    conWrapper.totalActCount = conWrapper.meetingCallCount + conWrapper.emailCount + conWrapper.dealCount;
                    conInfo.add(conWrapper);
                }
            }
            return conInfo;
        } catch (Exception e) {
            system.debug('Shivam' +e.getMessage() + ' '+ e.getLinenumber());
            throw new AuraHandledException(ERR_MSG + ' : <<' + e.getStackTraceString() + '>>'+e.getLinenumber()+'  '+ e.getMessage());
        }
    }

    /******************** DEAL ACUITY > DEAL TEAM (EXTERNAL) SECTION MAIN METHODS : END ********************/

    /******************** FUND ACUITY > FUNDRAISING SECTION MAIN METHODS : START ********************/

    @AuraEnabled
    public static ResponseWrapper processFdrInfo(String recordId, String namespacePrefix,String filterValue, String valueSorting, String fieldNameForSort){
        try {
            String refField  = Acuity_Setting__mdt.getInstance('Acuity_Fund_FDR_Field1').Value__c;
            String refField2 = Acuity_Setting__mdt.getInstance('Acuity_Fund_FDR_Field2').Value__c;
            String refField3 = Acuity_Setting__mdt.getInstance('Acuity_Fund_FDR_Field3').Value__c;
            String refField4 = Acuity_Setting__mdt.getInstance('Acuity_Fund_FDR_Field4').Value__c;
            String refField5 = Acuity_Setting__mdt.getInstance('Acuity_Fund_FDR_Field5').Value__c;
            String refField6 = Acuity_Setting__mdt.getInstance('Acuity_Fund_FDR_Field6').Value__c;
            String refField7 = Acuity_Setting__mdt.getInstance('Acuity_Fund_FDR_Field7').Value__c;
            String refField8;
            String orderBy = '';
            ResponseWrapper respWrapper = new ResponseWrapper();
            String objectName = namespacePrefix+'Fundraising__c';
            Map<String, Schema.SObjectField> field = Schema.getGlobalDescribe().get(objectName).getDescribe().fields.getMap();
            Schema.DisplayType fieldType;
            Boolean isAccess ;
        	
            if(!(String.isEmpty(valueSorting) && String.isEmpty(fieldNameForSort))){
                if(fieldNameForSort == 'stage') {
                    String fieldApiNameForSort = refField3;
                   	isAccess = field.get(refField3.replace('__r.Name','__c')).getDescribe().isAccessible();
                    if(isAccess) {
                       orderBy += ' ORDER BY ' + fieldApiNameForSort + ' ' + valueSorting + ' NULLS LAST ';  
                    }
                } else if(fieldNameForSort == 'date') {
                    String fieldApiNameForSort = refField5;
                    isAccess = field.get(refField5.replace('__r.Name','__c')).getDescribe().isAccessible();
                    if(isAccess) {
                       orderBy += ' ORDER BY ' + fieldApiNameForSort + ' ' + valueSorting + ' NULLS LAST ';  
                    }
                	}
            }
            Map<String, sObject> fundraisingMap = fetchInitInfoToProcess('Acuity_Fund_FDR_Field1', 'Acuity_Fund_FDR_Field2,Acuity_Fund_FDR_Field3,Acuity_Fund_FDR_Field4,Acuity_Fund_FDR_Field5,Acuity_Fund_FDR_Field6,Acuity_Fund_FDR_Field7,Acuity_Fund_FDR_Field8', namespacePrefix + 'Fundraising__c', ' WHERE ' + namespacePrefix + 'Fund_Name__c = :recordId' + orderBy, recordId, null);
if(String.isNotBlank(refField2)){
  System.debug(refField2);
  isAccess = field.get(refField2.replace('__r.Name','__c')).getDescribe().isAccessible();
  if(isAccess) {
    fieldType = field.get(refField2.replace('__r.Name','__c')).getDescribe().getType(); // or getSOAPType()
    respWrapper.conSecDynFieldHeader = fetchFieldLabel(objectName, refField2) + ';' + refField2 + ';' +fieldType;
  }else{
    respWrapper.conSecDynFieldHeader = '';
  }
}
if(String.isNotBlank(refField3)){
  isAccess = field.get(refField3.replace('__r.Name','__c')).getDescribe().isAccessible();
  if(isAccess) {
    fieldType = field.get(refField3.replace('__r.Name','__c')).getDescribe().getType(); // or getSOAPType()
    respWrapper.conSecDynFieldHeader2 = fetchFieldLabel(objectName, refField3) +';' + refField3 + ';' +fieldType;
  }else{
    respWrapper.conSecDynFieldHeader2 = '';
  }
}
if(String.isNotBlank(refField4)){
  isAccess = field.get(refField4.replace('__r.Name','__c')).getDescribe().isAccessible();
  if(isAccess) {
    fieldType = field.get(refField4.replace('__r.Name','__c')).getDescribe().getType(); // or getSOAPType()
    respWrapper.conSecDynFieldHeader3 = fetchFieldLabel(objectName, refField4) +';' + refField4 +  ';' +fieldType;
  }else{
    respWrapper.conSecDynFieldHeader3 = '';
  }
}
if(String.isNotBlank(refField5)){
  isAccess = field.get(refField5.replace('__r.Name','__c')).getDescribe().isAccessible();
  if(isAccess) {
    fieldType = field.get(refField5.replace('__r.Name','__c')).getDescribe().getType(); // or getSOAPType()
    respWrapper.conSecDynFieldHeader4 = fetchFieldLabel(objectName, refField5) +';' + refField5 +  ';' +fieldType;
  }else{
    respWrapper.conSecDynFieldHeader4 = '';
  }
}
if(String.isNotBlank(refField6)){
  isAccess = field.get(refField6.replace('__r.Name','__c')).getDescribe().isAccessible();
  if(isAccess) {
    fieldType = field.get(refField6.replace('__r.Name','__c')).getDescribe().getType(); // or getSOAPType()
    respWrapper.conSecDynFieldHeader5 = fetchFieldLabel(objectName, refField6) +';' + refField6 + ';' +fieldType;
  }else{
    respWrapper.conSecDynFieldHeader5 = '';
  }
}
if(String.isNotBlank(refField7)){
  isAccess = field.get(refField7.replace('__r.Name','__c')).getDescribe().isAccessible();
  if(isAccess) {
    fieldType = field.get(refField7.replace('__r.Name','__c')).getDescribe().getType(); // or getSOAPType()
    respWrapper.conSecDynFieldHeader6 = fetchFieldLabel(objectName, refField7) +';' + refField7 + ';' +fieldType;
  }else{
    respWrapper.conSecDynFieldHeader6 = '';
  }
}
            if(filterValue != Acuity_Setting__mdt.getInstance('Acuity_Fund_FDR_LogicField_Value1').Value__c ) {
                refField8 = Acuity_Setting__mdt.getInstance('Acuity_Fund_FDR_Field8').Value__c;
                if(String.isNotBlank(refField8)){
                    fieldType = field.get(refField8.replace('__r.Name','__c')).getDescribe().getType(); // or getSOAPType()
                    respWrapper.conSecDynFieldHeader7 = fetchFieldLabel(objectName, refField8) +';' + refField8 + ';' +fieldType;
                }  
            }
            List<FundraisingWrapper> funWrapperList = prepareFundraisingFinalMap(refField, refField2, refField3, refField4, refField5, refField6, refField7, refField8, namespacePrefix, fundraisingMap);
            respWrapper.funInfoWrapper = funWrapperList;
            return respWrapper;
        } 
        catch (Exception e) {//Added by Kushal as part of 00035038
            throw new AuraHandledException(ERR_MSG + ' : <<' + e.getStackTraceString() + '>>');
        } 
    }

    public static List<FundraisingWrapper> prepareFundraisingFinalMap(String refField, String refField2, String refField3, String refField4, String refField5, String refField6, String refField7, String refField8, String namespacePrefix, Map<String, sObject> fundraisingMap){
        try {
            List<FundraisingWrapper> funInfo = new List<FundraisingWrapper>();
            string recId = '';
            String sObjName = '';
            Id recordId;
            for(String conId : fundraisingMap.keySet()){
                List<String> actIdList = new List<String>();
                List<String> dealIdList = new List<String>();
                FundraisingWrapper funWrapper = new FundraisingWrapper();
                funWrapper.Id = conId;
                if(String.isNotBlank(refField)){
                    if(refField.contains('__r.')){
                        recId = String.valueOf((fundraisingMap.get(conId).get(refField.split('__r.').get(0)+'__c')));
                        if(String.isNotBlank(recId)){
                            recordId = (Id)recId;
                        }
                        sObjName = recordId.getSObjectType().getDescribe().getName();
                        funWrapper.recId = recordId;
                        funWrapper.name = fetchFieldData(sObjName, recordId, refField.split('__r.').get(1));
                        funWrapper.nameRef = '/' + recordId;
                    } else {
                        funWrapper.recId = conId;
                        funWrapper.name = String.valueOf((fundraisingMap.get(conId).get(refField)));     
                        funWrapper.nameRef = '/' + conId;
                    }
                }
                if(String.isNotBlank(refField2)){
                    if(refField2.contains('__r.')){
                        recId = String.valueOf((fundraisingMap.get(conId).get(refField2.split('__r.').get(0)+'__c')));
                        if(String.isNotBlank(recId)){
                            recordId = (Id)recId;
                        }
                        sObjName = recordId.getSObjectType().getDescribe().getName();
                        funWrapper.recId2 = recordId;
                        funWrapper.name2 = fetchFieldData(sObjName, recordId, refField2.split('__r.').get(1));
                        funWrapper.nameRef2 = '/' + recordId;
                    }
                }
                if(String.isNotBlank(refField3)){
                    if(refField3.contains('__r.')){
                        recId = String.valueOf((fundraisingMap.get(conId).get(refField3.split('__r.').get(0)+'__c')));
                        if(String.isNotBlank(recId)){
                            recordId = (Id)recId;
                        }
                        sObjName = recordId.getSObjectType().getDescribe().getName();
                        funWrapper.fieldInfo = fetchFieldData(sObjName, recordId, refField3.split('__r.').get(1));
                    } else {
                        funWrapper.fieldInfo = String.valueOf((fundraisingMap.get(conId).get(refField3)));     
                    }
                }
                if(String.isNotBlank(refField4)){
                    if(refField4.contains('__r.')){
                        recId = String.valueOf((fundraisingMap.get(conId).get(refField4.split('__r.').get(0)+'__c')));
                        if(String.isNotBlank(recId)){
                            recordId = (Id)recId;
                        }
                        sObjName = recordId.getSObjectType().getDescribe().getName();
                        funWrapper.fieldInfo2 = fetchFieldData(sObjName, recordId, refField4.split('__r.').get(1));    
                    } else {
                        funWrapper.fieldInfo2 = String.valueOf((fundraisingMap.get(conId).get(refField4)));        
                    }
                    
                }
                if(String.isNotBlank(refField5)){
                    if(refField5.contains('__r.')){
                        recId = String.valueOf((fundraisingMap.get(conId).get(refField5.split('__r.').get(0)+'__c')));
                        if(String.isNotBlank(recId)){
                            recordId = (Id)recId;
                        }
                        sObjName = recordId.getSObjectType().getDescribe().getName();
                        funWrapper.fieldInfo3 = date.parse(fetchFieldData(sObjName, recordId, refField5.split('__r.').get(1)));    
                    } else { 
                        if(fundraisingMap.get(conId).get(refField5) != null) {
                        	funWrapper.fieldInfo3 = date.parse(String.valueOf((fundraisingMap.get(conId).get(refField5))));  
                        }
                    }
                    
                }
                if(String.isNotBlank(refField6)){
                    if(refField6.contains('__r.')){
                        recId = String.valueOf((fundraisingMap.get(conId).get(refField6.split('__r.').get(0)+'__c')));
                        if(String.isNotBlank(recId)){
                            recordId = (Id)recId;
                        }
                        sObjName = recordId.getSObjectType().getDescribe().getName();
                        funWrapper.fieldInfo4 = fetchFieldData(sObjName, recordId, refField6.split('__r.').get(1));    
                    } else {
                        funWrapper.fieldInfo4 = String.valueOf((fundraisingMap.get(conId).get(refField6)));        
                    }
                    
                }
                if(String.isNotBlank(refField7)){
                    if(refField7.contains('__r.')){
                        recId = String.valueOf((fundraisingMap.get(conId).get(refField7.split('__r.').get(0)+'__c')));
                        if(String.isNotBlank(recId)){
                            recordId = (Id)recId;
                        }
                        sObjName = recordId.getSObjectType().getDescribe().getName();
                        funWrapper.fieldInfo5 = fetchFieldData(sObjName, recordId, refField7.split('__r.').get(1));    
                    } else {
                        funWrapper.fieldInfo5 = String.valueOf((fundraisingMap.get(conId).get(refField7)));        
                    }
                }
                if(String.isNotBlank(refField8)){
                    if(refField8.contains('__r.')){
                        recId = String.valueOf((fundraisingMap.get(conId).get(refField8.split('__r.').get(0)+'__c')));
                        recordId = (Id)recId;
                        //Added by Kushal as part of 00035038
                        if(recordId != null) {
                            sObjName = recordId.getSObjectType().getDescribe().getName();
                            funWrapper.recId3 = recordId;
                            funWrapper.name3 = fetchFieldData(sObjName, recordId, refField8.split('__r.').get(1));
                            funWrapper.nameRef3 = '/' + recordId;
                        }
                    }
                }
                funInfo.add(funWrapper);
            }
            return funInfo;
        } catch (Exception e) {//Added by Kushal as part of 00035038
            throw new AuraHandledException(ERR_MSG + ' : <<' + e.getStackTraceString() + '>>');
        }   
    }
    
    @AuraEnabled
    public static void deleteFundraisingRecord(List<Id> idsToDelete, String namespacePrefix){
        try{
            String query = 'SELECT Id, Name FROM ' +  String.escapeSingleQuotes(namespacePrefix) + 'Fundraising__c';
            if(!idsToDelete.isEmpty()){
                query += ' where id IN: idsToDelete LIMIT 10000 ';
            }
            List<SObject> lstRecords = new List<SObject>();
            if(String.isNotBlank(query)) {
                lstRecords = Database.query(query);  
            }
            If(!lstRecords.isEmpty() && Schema.sObjectType.navpeII_dev18__Fundraising__c.isDeletable()){
                delete lstRecords;
            }
        } catch (Exception e) {
            //Updated error msg body by LK on 2024-05-24 to fix 00044998
            throw new AuraHandledException(ERR_MSG + ' : <<' + e.getMessage() + '>>');
        }
    }

    /******************** FUND ACUITY > FUNDRAISING SECTION MAIN METHODS : END ********************/

    /******************** FILE PREVIEW > START ********************/
    @AuraEnabled
    public static List<ViewScreenFileWrapper> getFileList(String activityId) {
        List<ViewScreenFileWrapper> fileWrapperList = new List<ViewScreenFileWrapper>();
        if(String.isNotBlank(activityId)) {
            List<ContentDocumentLink> cdlList = [SELECT ContentDocumentId, LinkedEntityId, ContentDocument.Title, Id
                       							 FROM ContentDocumentLink WHERE 
                       							 LinkedEntityId =:activityId];
            Map<String,String> documentIdSet = new Map<String,String>();
            for(ContentDocumentLink cdl : cdlList) {
                documentIdSet.put(cdl.ContentDocumentId, cdl.Id);
            }
            for(ContentVersion cv: [SELECT Id, ContentDocumentId, COntentDocument.Title, ContentSize,FileExtension from ContentVersion 
                                   	WHERE ContentDocumentId IN: documentIdSet.keySet()
                                   ]
               ) {
                   ViewScreenFileWrapper fileWrapper = new ViewScreenFileWrapper();
                  // Bug 45755 fixed by Sudhanshu 06/06/2024
                   if(cv.COntentDocument.Title.contains('.'+cv.FileExtension))
                   {
                    fileWrapper.title = cv.COntentDocument.Title;
                   }
                   else{
                    fileWrapper.title = cv.COntentDocument.Title+ '.'+cv.FileExtension;
                   }
                //    fileWrapper.title = cv.COntentDocument.Title+ '.'+cv.FileExtension;
                   fileWrapper.size = fileSizeToString(cv.ContentSize);
                   fileWrapper.contentDocumentId = cv.ContentDocumentId;
                   fileWrapper.versionId = cv.Id;
                   fileWrapper.linkId = documentIdSet.get(cv.ContentDocumentId);
                 //  fileWrapper.fileNameWithExtension= cv.COntentDocument.Title+'.'+cv.FileExtension; //Added By Manonit for Extension type on UI
                   if(cv.COntentDocument.Title.contains('.'+cv.FileExtension))
                   {
                   		fileWrapper.fileNameWithExtension= cv.COntentDocument.Title; //Added By Manonit for Extension type on UI
                   }
                   else{
                    	fileWrapper.fileNameWithExtension= cv.COntentDocument.Title+'.'+cv.FileExtension; //Added By Manonit for Extension type on UI
                   }
                   fileWrapper.FileExtension = cv.FileExtension;
                   fileWrapperList.add(fileWrapper);
                   
               }
              /* List<Attachment> attachmentLst = [Select Id, Name, ParentId, BodyLength from Attachment where ParentId =:activityId  LIMIT :(Limits.getLimitQueryRows() - Limits.getQueryRows())]; // Modified by anurag for resolving crtical bug 00039479            
               for(Attachment atch : attachmentLst){
                ViewScreenFileWrapper fileWrapper = new ViewScreenFileWrapper();
                fileWrapper.title = atch.Name;
                fileWrapper.contentDocumentId = atch.ParentId;
                fileWrapper.size = fileSizeToString(atch.BodyLength);
                fileWrapperList.add(fileWrapper);
            }*/
            //Commented the Code As per converstion with rex
        }
        return fileWrapperList;
    }

    @AuraEnabled
    public static void deleteActivity(String actId) {
        if(actId.startsWith('00T'))
        { 
            try{
                    List<Task> taskToDelete = [SELECT Id, WhatId FROM Task WHERE Id = :actId LIMIT 1];
                    
                    // Check if the task exists and is not archived
                    if (taskToDelete.size() > 0) {
                        // Delete the task
                        delete taskToDelete;
                    }
            }
            catch(Exception ex){
                throw new AuraHandledException(ex.getMessage());
            }
        }
        else if (actId.startsWith('00U')){
            try{
                    List<Event> eventToDelete = [SELECT Id, WhatId FROM Event WHERE Id = :actId  LIMIT 1];
                    
                    // Check if the Event exists and is not archived
                    if (eventToDelete.size() > 0) {
                        // Delete the task
                        delete eventToDelete;
                    }
            }
            catch(Exception ex){
                throw new AuraHandledException(ex.getMessage());
            }
        }
    }

    /*****************************************************************************************************
    * @Name         :   checkArchiveData
    * @Description  :   Method to check Activity Archive or not
    * @Param        :   recordId: id of record
    *****************************************************************************************************/
    @AuraEnabled
    public static boolean checkArchiveData(String recordId){
        boolean isArchive;
        if(recordId.startsWith('00T')){
            isArchive = [SELECT Id, IsArchived FROM Task WHERE Id = :recordId AND IsDeleted = false ALL ROWS].IsArchived;
        }else{
            isArchive = [SELECT Id, IsArchived FROM Event WHERE Id = :recordId AND IsDeleted = false ALL ROWS].IsArchived;
        }
        return isArchive;
    }


    @AuraEnabled
    public static void deleteAttachment(String fileId ){
        try {
            // Assuming you have the ContentDocument Id stored in a variable called contentDocumentId
            String contentDocumentId = fileId;
            System.debug('actId : '+fileId);
            // Query the ContentDocument object to find the document
            List<ContentDocument> documentToDelete = [SELECT Id FROM ContentDocument WHERE Id = :contentDocumentId LIMIT 1];

            // Check if the document exists
            if(documentToDelete.size() > 0) {
                // Delete the document
                delete documentToDelete;
                System.debug('ContentDocument deleted successfully.');
            } 
            else{
                throw new AuraHandledException('Some Error Occured');
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

// added by Sudhanshu for Citadel CR
    @AuraEnabled
    public static List<String> fetchFlowNames(String objectName){
        try{
            string nameSpacePrefix = getNamespacePrefix() + '__';
            String fieldFlowNames = '';
            if(objectName == NamespacePrefix+'Pipeline__c')
            {
                fieldFlowNames = Acuity_Setting__mdt.getInstance('Acuity_Flow_Deal').Value__c;
            }
            if(objectName == NamespacePrefix+'Fund__c')
            {
                fieldFlowNames = Acuity_Setting__mdt.getInstance('Acuity_Flow_Fund').Value__c;
            }
            if(objectName == NamespacePrefix+'Fundraising__c')
            {
                fieldFlowNames = Acuity_Setting__mdt.getInstance('Acuity_Flow_Fundraising').Value__c;
            }

            List<String> flowList = fieldFlowNames.split(',');
            
            return flowList;
        }
        catch(Exception ex){
            throw new AuraHandledException(ex.getMessage());
        }
    }
    
    public class ViewScreenFileWrapper{
        @AuraEnabled
        public String title;
        @AuraEnabled
        public String size;
        @AuraEnabled
        public String contentDocumentId;
        @AuraEnabled
        public String versionId;
         @AuraEnabled
        public String linkId;// Content DOcument Link Id
         @AuraEnabled
        public String fileNameWithExtension;
        @AuraEnabled 
        public String FileExtension;
    }
    
    public static String fileSizeToString(Long Value)
    {
        if (Value < 1024)
            return string.valueOf(Value) + ' Bytes';
        else
            if (Value >= 1024 && Value < (1024*1024))
        {
            Decimal kb = Decimal.valueOf(Value);
            kb = kb.divide(1024,2);
            return string.valueOf(kb) + ' KB';
        }
        else
            if (Value >= (1024*1024) && Value < (1024*1024*1024))
        {
            Decimal mb = Decimal.valueOf(Value);
            mb = mb.divide((1024*1024),2);
            return string.valueOf(mb) + ' MB';
        }
        else
        {
            Decimal gb = Decimal.valueOf(Value);
            gb = gb.divide((1024*1024*1024),2);
            return string.valueOf(gb) + ' GB';
        }    
    }
    /******************** FILE PREVIEW > START ********************/

    /************************* WRAPPERS : START *************************/
    
    /*
     * Purpose : Wrapper for Referenced Section information
     */
    public class InfoWrapper{
        @AuraEnabled public String name;                //Record Name
        @AuraEnabled public String nameRef;             //Record ID
        @AuraEnabled public Integer count;              //Associated activities count
        @AuraEnabled public List<String> actIdList;     //Associated activities list
        @AuraEnabled public Boolean isAssociatedToDeal; //Stores true if Account is associated to a deal else, false (For CR only)

        public InfoWrapper(String name, String nameRef, Integer count, List<String> actIdList, Boolean isAssociatedToDeal){
            this.name = name;
            this.nameRef = nameRef;
            this.count = count;
            this.actIdList = actIdList;
            this.isAssociatedToDeal = isAssociatedToDeal;
        }
    }

    /*
     * Purpose : Wrapper for page load information
     */
    public class ResponseWrapper{
        @AuraEnabled public List<InfoWrapper> compsRefInfo; //Referenced Section : CR Info
        @AuraEnabled public List<String> conIdList;         //Processed contact IDs info    [Feasible for Account record page]
        @AuraEnabled public String namespacePrefix;         //Namespaceprefix to be used
        @AuraEnabled public Map<String, sObject> conMap;    //Stores contact records info
        @AuraEnabled public List<ConWrapper> conInfoWrapper;//Contacts/Connections Section info
        @AuraEnabled public String conSecDynFieldHeader;    //Header for dynamic column in Contacts/Connections Section
        @AuraEnabled public String accId;                   //Account record ID     [Feasible for Account record page]
        @AuraEnabled public String contactEmail;            //Stores contact's email ID [Feasible for Contact record page]
        @AuraEnabled public String recName;                 //Record Name of current record page
        @AuraEnabled public List<String> actIdList;         //Used for Interactions Section & Contacts/Connections Section (W/O AA Field Consideration)
        @AuraEnabled public List<String> completeActIdList; //Used for Interactions Section & Contacts/Connections Section (With AA Field Consideration)
        @AuraEnabled public Boolean apiError;               //Used to identify api error if occured on load by Shivam
        @AuraEnabled public String recType;                 //Used to store record type of Account; Only valid for Account
        @AuraEnabled public List<String> parentConIdList;   //Used by Anshika to store the Contact of Fdr Contact
        @AuraEnabled public String conSecDynFieldHeader2;   //2nd Header for dynamic column in Fdr Acuity > Fdr Contact Section
        @AuraEnabled public String conSecDynFieldHeader3;   //3rd Header for dynamic column in Fdr Acuity > Fdr Contact Section
        @AuraEnabled public List<DealTeamWrapper> dealInfoWrapper;  //Firm (PE) Acuity Deal Team Info Wrapper
        @AuraEnabled public String fieldApiName;			//API NAME of Fields in fundraising column
        @AuraEnabled public String filterValue;			    //filter value to filter on
        @AuraEnabled public String conSecDynFieldHeader4;   //4th Header for dynamic column in Fund Acuity > Fdr Section
        @AuraEnabled public String conSecDynFieldHeader5;   //5th Header for dynamic column in Fund Acuity > Fdr Section
        @AuraEnabled public String conSecDynFieldHeader6;   //6th Header for dynamic column in Fund Acuity > Fdr Section
        @AuraEnabled public String conSecDynFieldHeader7;   //7th Header for dynamic column in Fund Acuity > Fdr Section
        @AuraEnabled public List<FundraisingWrapper> funInfoWrapper;//fundraising wrapper Section info
        @AuraEnabled public String acclabel;
        @AuraEnabled public String conlabel;
        @AuraEnabled public String dellabel;
        @AuraEnabled public String fundlabel;
        @AuraEnabled public String themelabel;
        @AuraEnabled public String cliplabel;
        @AuraEnabled public String fnrlabel;
        @AuraEnabled public String title;           //Stores header of Deals Section
        @AuraEnabled public String contactPluralLabel;
        @AuraEnabled public String dealTeamPluralLabel;
        @AuraEnabled public String fndrgCntPluralLabel;
        @AuraEnabled public Boolean isEmailDrillDownEnabled;//Switch for email drill down
    }

    /*
     * Purpose : Wrapper for Contacts/Connections Section information
     */
    public class ConWrapper{
        @AuraEnabled public String recId;                   //Record ID
        @AuraEnabled public String name;                    //Record Name
        @AuraEnabled public String nameRef;                 //Record URL
        @AuraEnabled public String fieldInfo;               //Dynamic field info
        @AuraEnabled public Integer meetingCallCount;       //Meeting Call count
        @AuraEnabled public List<String> meetingCallIdList; //Associated meetings & calls IDs
        @AuraEnabled public Integer totalActCount;          //Total activities count
        @AuraEnabled public Integer emailCount;             //Email count
        @AuraEnabled public String email;                   //Email ID for RG data fetching
        @AuraEnabled public String downloadIcon;            //Download icon name (Blank if icon isnt to be displayed)
        @AuraEnabled public String mailboxId;               //Mailbox ID for RG data fetching
        @AuraEnabled public Integer dealCount;              //Deal count
        @AuraEnabled public List<String> dealIdList;        //Associated deals IDs
        @AuraEnabled public String lastInteractionDate;     //Last Interaction Date
        @AuraEnabled public String lastInteractionNote;     //Last Interaction Note
        @AuraEnabled public String lastInteractionId;       //Last Interaction ID
        @AuraEnabled public String lastInteractionType;     //Last Interaction Type
        @AuraEnabled public String frcId;                   //Record ID of Fundraising Contact [Fdr Acuity > Fdr Con Section Only]
        @AuraEnabled public String recId2;                  //Record ID
        @AuraEnabled public String name2;                   //Record Name of 2nd field
        @AuraEnabled public String nameRef2;                //Record URL of 2nd field
        @AuraEnabled public String fieldInfo2;              //Dynamic field info of 3rd field
        @AuraEnabled public String fieldInfo3;              //Dynamic field info of 4th field
        @AuraEnabled public String firmName;                //Company Name
        @AuraEnabled public String firmRef;					//company name reference
    }

    /*
     * Purpose : Wrapper for Interactions Section/Modal information
     */
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
        @AuraEnabled public String buttonTitle;         //Added for Interactions tab to display Add/Edit Button or, no button
        @AuraEnabled public Boolean isFutureActivity;   //Whether the Activity is a future activity or, not
        @AuraEnabled public String priority;    //Activity Priority
        @AuraEnabled public String actOwner;    //Activity Owner
        @AuraEnabled public String status;      //Activity Status
        @AuraEnabled public String classification;      //Activity classification
        @AuraEnabled public SObject actInfo;     // Added by Sudhanshu for hold query Result
    }

    /*
     * Purpose : Wrapper for referenced type of data like Attendees/Assigned To/Name/AA Field
     */
    public class ReferenceWrapper{
        @AuraEnabled public String name;    //Record Name
        @AuraEnabled public String nameRef; //Record URL
        @AuraEnabled public String type;    //Record Object name
        @AuraEnabled public String iconName;//Record Icon
        @AuraEnabled public Integer sortValue;//Index value [Used for sorting]
    }

    /*
     * Purpose : Wrapper for Deals Section info
     */
    public class DealsInfoWrapper{
        @AuraEnabled public ReferenceWrapper fieldInfo1;    //Stores info of 1st column
        @AuraEnabled public ReferenceWrapper fieldInfo2;    //Stores info of 2nd column
        @AuraEnabled public ReferenceWrapper fieldInfo3;    //Stores info of 3rd column
        @AuraEnabled public ReferenceWrapper fieldInfo4;    //Stores info of 4th column
        @AuraEnabled public ReferenceWrapper fieldInfo5;    //Stores info of 5th column
        @AuraEnabled public ReferenceWrapper fieldInfo6;    //Stores info of 6th column
    }

    /*
     * Purpose : Wrapper for Deals Datapoint/Modal info
     */
    public class DealsWrapper{
        @AuraEnabled public List<DealsInfoWrapper> dealsDataList;   //Stores info of Deals
        @AuraEnabled public String fieldHeader1;    //Stores column header label of 1st column
        @AuraEnabled public String fieldHeader2;    //Stores column header label of 2nd column
        @AuraEnabled public String fieldHeader3;    //Stores column header label of 3rd column
        @AuraEnabled public String fieldHeader4;    //Stores column header label of 4th column
        @AuraEnabled public String fieldHeader5;    //Stores column header label of 4th column
        @AuraEnabled public String fieldHeader6;    //Stores column header label of 4th column
        @AuraEnabled public String title;           //Stores header of Deals Section
        @AuraEnabled public Boolean displayToggle;  //True if toggle is to be displayed
        @AuraEnabled public Boolean displaySorting; //True if sorting is to be displayed
        @AuraEnabled public String sortByField;     //Default sort by field
        @AuraEnabled public Boolean isFieldTypeURL2;  //Stores column header type (url/text) of 2nd column	
        @AuraEnabled public Boolean isFieldTypeURL3;  //Stores column header type (url/text) of 3rd column	
        @AuraEnabled public Boolean isFieldTypeURL4;  //Stores column header type (url/text) of 4th column
    }

    /*
     * Purpose : Wrapper for Emails Datapoint/Modal info
     */
    public class EmailListWrapper{
        @AuraEnabled public String type;            //Stores activity category api name (Inbound/Outbound/Indirect)
        @AuraEnabled public String activityCategoryLabel; //Stores activity category label (Inbound/Outbound/Indirect)
        @AuraEnabled public String subject;         //Stores email subject
        @AuraEnabled public String activityId;      //Stores activity ID from RG
        @AuraEnabled public String toEmailNames;    //Stores email names of people marked in TO
        @AuraEnabled public String ccEmailNames;    //Stores email names of people marked in CC
        @AuraEnabled public String bccEmailNames;   //Stores email names of people marked in BCC
        @AuraEnabled public String sendEmailDate;   //Stores sent email date
        @AuraEnabled public Long longDateTime;      //added by Shivam
        //@AuraEnabled public Boolean apiError;      //added by Shivam
        @AuraEnabled public List<ReferenceWrapper> toReferences;   //Stores user and contact detail
        @AuraEnabled public List<ReferenceWrapper> ccReferences;   //Stores user and contact detail
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

    /*
     * Purpose : Clips Referenced Wrapper
     */
    public class ClipsReferencedWrapper{
        @AuraEnabled public ReferenceWrapper refWrapper;
        @AuraEnabled public String secFieldInfo;
        @AuraEnabled public String notes;
        @AuraEnabled public String createdDate;
        @AuraEnabled public List<ReferenceWrapper> tags;
    }

    /*
     * Purpose : Last Interaction Info Wrapper
     */
    public class LastInteractionInfo{
        @AuraEnabled public String lastInteractionDate;
        @AuraEnabled public String lastInteractionNote;
        @AuraEnabled public String lastInteractionId;
        @AuraEnabled public String lastInteractionType;

        public LastInteractionInfo(String lastInteractionDate, String lastInteractionNote, String lastInteractionId, String lastInteractionType){
            this.lastInteractionDate = lastInteractionDate;
            this.lastInteractionNote = lastInteractionNote;
            this.lastInteractionId = lastInteractionId;
            this.lastInteractionType = lastInteractionType;
        }
    }

    /*
     * Purpose : Wrapper for Firm (Private Equity) > Deals Section & Deal Acuity > Deal Team (Internal)
     */
    public class DealTeamWrapper{
        @AuraEnabled public String Id;          //Record ID
        @AuraEnabled public String recId;       //Record ID
        @AuraEnabled public String name;        //Record Name
        @AuraEnabled public String nameRef;     //Record URL
        @AuraEnabled public String recId2;      //Record ID
        @AuraEnabled public String fieldInfo;   //Dynamic field info
        @AuraEnabled public String fieldInfo2;  //Dynamic field info
        @AuraEnabled public date fieldInfo3;    //Dynamic field info
    }

    /*
    * Purpose : Wrapper for Fundraising Section information
    */
    public class FundraisingWrapper{
        @AuraEnabled public String Id;          //Record ID
        @AuraEnabled public String recId;       //Record ID
        @AuraEnabled public String name;        //Record Name
        @AuraEnabled public String nameRef;     //Record URL
        @AuraEnabled public String recId2;      //Record ID
        @AuraEnabled public String name2;       //Record Name
        @AuraEnabled public String nameRef2;    //Record URL
        @AuraEnabled public String recId3;      //Record ID
        @AuraEnabled public String name3;       //Record Name
        @AuraEnabled public String nameRef3;	//Record URL
        @AuraEnabled public String fieldInfo;   //Dynamic field info
        @AuraEnabled public String fieldInfo2;  //Dynamic field info
        @AuraEnabled public date fieldInfo3;    //Dynamic field info
        @AuraEnabled public String fieldInfo4;	//Dynamic field info
        @AuraEnabled public String fieldInfo5;	//Dynamic field info
    }

    /************************* WRAPPERS : END *************************/
}