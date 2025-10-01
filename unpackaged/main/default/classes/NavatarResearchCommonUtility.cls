/*********************************************************************************
** @Module Name : ActivityAssociationLightning
** @Description : This class is used for common methods referenced across module.
** @Organization : Navatar Group
** @Revision History:-
** @Version Date(YYYY-MM-DD)          Author                  
** 1.0     2018-04-05             Akash Punera
** 		   2022-10-06			  Anshika Ahuja  Removed Follow Up Event Button #00031520
*********************************************************************************/

public Without Sharing class NavatarResearchCommonUtility {
    
    
    public static String getSessionIdFromVFPage(PageReference visualforcePage){
        if(test.isRunningTest()){
            return 'SessionIdForTestClass';
        }
        String content = visualforcePage.getContent().toString();
        return content.substring(content.indexOf('Session_Id_Start_Here') + 'Session_Id_Start_Here'.length(), content.indexOf('Session_Id_End_Here'));
    }
    
    public static String getDescribeResponse(String endPointURL){
        HttpRequest req = new HttpRequest();
        string domainUrl=URL.getSalesforceBaseUrl().toExternalForm();
        req.setEndpoint(domainUrl+endPointURL);
        req.setMethod('GET');
        String sessionId = NavatarResearchCommonUtility.getSessionIdFromVFPage(Page.sessionIdPage);    
        String autho ='Bearer '+ sessionId;
        req.setHeader('Authorization', autho);
        Http http = new Http();
        HTTPResponse resp = http.send(req);
        return resp.getBody();
    }
    
    /*****************************************************************************************************
* @Name         :   getDescribeResponseForRectype
* @Description  :   Method to return map of objectName¤RecordTypeId and JSON Response body
* @Parameter    :   mapObjectToRecordTypeId - Map of object to recordTypeId Set.
*****************************************************************************************************/
    public static Map<String,String> getDescribeResponseForRectype(Map<String,Set<id>> mapObjectToRecordTypeId){
        //Domain url of current organization
        String domainUrl = URL.getSalesforceBaseUrl().toExternalForm();
        
        //Map objectname¤recordtypeId to response
        Map<String,String> mapObjectToRecordType = new Map<String,String>();
        
        //Get session Id to make API call from VF page
        String sessionId = getSessionIdFromVFPage(Page.sessionIdPage); 
        
        Http http;
        HttpRequest req;
        HTTPResponse resp;
        
        //Iterate over all objects (listObjects)
        for(String objectName : mapObjectToRecordTypeId.keySet()){
            //Iterate over all record types (passed to method as parameter) of provided object in object name
            for(id recordTypeId : mapObjectToRecordTypeId.get(objectName)){
                req = new HttpRequest();
                
                //Set end point for the http request using domain usl and compact layout url
                req.setEndpoint(domainUrl+ COMPACT_LAYOUT_CALLOUT_ENDPOINT(objectName)+recordTypeId);
                
                req.setMethod('GET');
                String autho ='Bearer '+ sessionId;
                req.setHeader('Authorization', autho);
                http = new Http();
                resp = http.send(req);
                if(resp.getStatusCode() == 200 && resp.getBody()!=''){
                    mapObjectToRecordType.put(objectName+'¤'+recordTypeId, resp.getBody());
                }
            }
            req = new HttpRequest();
            
            //Set end point to get the primary compact layout for the object
            req.setEndpoint(domainUrl+ PRIMARY_COMPACT_LAYOUT_ENDPOINT(objectName));
            
            req.setMethod('GET');
            String autho ='Bearer '+ sessionId;
            req.setHeader('Authorization', autho);
            http = new Http();
            resp = http.send(req);
            if(resp.getStatusCode() == 200 && resp.getBody()!=''){
                //Add default layout to be used in case no record type is present on object
                mapObjectToRecordType.put(objectName+'¤primary',resp.getBody());    
            }
            
        }
        return mapObjectToRecordType;
    }
    
    
    /*****************************************************************************************************
* @Name         :   getFieldSetForAllRecordTypes
* @Description  :   Method to return map of objectName and setof fields
*****************************************************************************************************/
    public static Map<String,Set<String>> getFieldSetForAllRecordTypes(){
        
        //Map of object to set of fields to be queried
        Map<String,Set<String>> mapFieldSet = new Map<String,Set<String>>();
        
        //Map of object to recortTypeSet
        Map<String,Set<id>> mapObjectToRecordTypeSet = new Map<String,Set<id>>();
        
        //Field items returned from Compact layout response
        List<NavatarResearchCommonUtility.cls_fieldItems> fieldItemsList =  new List<NavatarResearchCommonUtility.cls_fieldItems>();
        
        //Map object to compactlayout response
        Map<String,String> mapObjectToCompactLayoutRes = new Map<String,String>();
        
        //Instead of 2 describe calls on task and event, query record type from RecordType
        List<RecordType> listRecordType = [ SELECT  id,SobjectType 
                                           FROM    RecordType
                                           WHERE   SobjectType = 'Task' OR SobjectType = 'Event'];
        
        //Add blank values to Map to get response in case no record type is assigned
        mapObjectToRecordTypeSet.put('Task', new Set<Id>());
        mapObjectToRecordTypeSet.put('Event', new Set<Id>());
        //mapObjectToRecordTypeSet.put('EmailMessage', new Set<Id>());
        
        //START changes for adding list email compact layout to timeline
        if(Schema.sObjectType.ListEmail.isAccessible()){
            mapObjectToRecordTypeSet.put('ListEmail', new Set<Id>());
        }
        //END changes for adding list email compact layout to timeline
        
        //Create map of object to record type ids
        for(RecordType objRt : listRecordType){
            if(mapObjectToRecordTypeSet.containsKey(objRt.SobjectType)){
                Set<id> tempSet = mapObjectToRecordTypeSet.get(objRt.SobjectType);
                tempSet.add(objRt.id);
                mapObjectToRecordTypeSet.put(objRt.SobjectType, tempSet);
            }else{
                mapObjectToRecordTypeSet.put(objRt.SobjectType,new Set<Id>{objRt.id});    
            }
            
        }
        
        //Get map of objectName¤recordtypeId to Compact Layout responses
        mapObjectToCompactLayoutRes = getDescribeResponseForRectype(mapObjectToRecordTypeSet);
        
        //CompondLayoutWrapper class variable
        NavatarResearchCommonUtility.CompoundLayoutWrapper objCompactLayoutWrapper;
        
        //Iterate on all Compact layout responses
        for(String strKey : mapObjectToCompactLayoutRes.keySet()){
            objCompactLayoutWrapper = new NavatarResearchCommonUtility.CompoundLayoutWrapper();
            objCompactLayoutWrapper = (NavatarResearchCommonUtility.CompoundLayoutWrapper)JSON.deserialize(mapObjectToCompactLayoutRes.get(strKey),NavatarResearchCommonUtility.CompoundLayoutWrapper.class);
            fieldItemsList = objCompactLayoutWrapper.fieldItems ;
            
            for(NavatarResearchCommonUtility.cls_fieldItems fld : fieldItemsList){
                for(NavatarResearchCommonUtility.cls_layoutComponents cl : fld.layoutComponents){
                    if(cl.details != null ){
                        if(mapFieldSet.containsKey(strKey.split('¤')[0])){
                            Set<String> tempSet = mapFieldSet.get(strKey.split('¤')[0]);
                            tempSet.add(cl.details.name);
                            mapFieldSet.put(strKey.split('¤')[0],tempSet); 
                        }else{
                            mapFieldSet.put(strKey.split('¤')[0],new Set<String>{cl.details.name});
                        }
                        
                    }  
                }
                
            }
        }
        return mapFieldSet;
    }
    
    private static Map<String,String> localeToDateTimeFmtMap;
    private static String userLocale  = UserInfo.getLocale(); 
    
    /***************************************************************************************************** 
* @Description: Returns date format (e.g dd/mm/yyyy) depending on users locale, returns BLANK if users
*               locale is not present in the map.
*****************************************************************************************************/
    public static String getUserDateFormat() {
        String dateFormat;
        getLocaleToDateTimeFmtMap();
        if (!localeToDateTimeFmtMap.containsKey(userLocale)){
            dateFormat = '';
        }else{
            dateFormat = localeToDateTimeFmtMap.get(userLocale).substringBefore(' h');
        }
        return dateFormat;
    }
    
    /***************************************************************************************************** 
* @Description: Returns datetime format (e.g M/d/yyyy hh.mm.ss) depending on users locale, returns BLANK if users
*                locale is not present in the map.
*****************************************************************************************************/
    public static String getUserDateTimeFormat() {
        String dateTimeFormat;
        getLocaleToDateTimeFmtMap();
        if (!localeToDateTimeFmtMap.containsKey(userLocale)){
            dateTimeFormat = '';
        }else{
            dateTimeFormat = localeToDateTimeFmtMap.get(userLocale);
        }
        return dateTimeFormat;
    }
    /***************************************************************************************************** 
* @Description: Returns a map of user locale | datetime format for that locale
*****************************************************************************************************/
    public static Map<String,String> getLocaleToDateTimeFmtMap () {
        if (localeToDateTimeFmtMap == null){
            localeToDateTimeFmtMap  = new Map<String,String> {
                'ar'            => 'hh:mm a | dd/MM/yyyy',
                    'ar_AE'         => 'hh:mm a | dd/MM/yyyy',
                    'ar_BH'         => 'hh:mm a | dd/MM/yyyy',
                    'ar_JO'         => 'hh:mm a | dd/MM/yyyy',
                    'ar_KW'         => 'hh:mm a | dd/MM/yyyy',
                    'ar_LB'         => 'hh:mm a | dd/MM/yyyy',
                    'ar_SA'         => 'hh:mm a | dd/MM/yyyy',
                    'bg_BG'         => 'H:mm | yyyy-M-d',
                    'ca'            => 'HH:mm | dd/MM/yyyy',
                    'ca_ES'         => 'HH:mm | dd/MM/yyyy',
                    'ca_ES_EURO'    => 'HH:mm | dd/MM/yyyy',
                    'cs'            => 'HH:mm | d.M.yyyy',
                    'cs_CZ'         => 'HH:mm | d.M.yyyy',
                    'da'            => 'HH:mm | dd-MM-yyyy',
                    'da_DK'         => 'HH:mm | dd-MM-yyyy',
                    'de'            => 'HH:mm | dd.MM.yyyy',
                    'de_AT'         => 'HH:mm | dd.MM.yyyy',
                    'de_AT_EURO'    => 'HH:mm | dd.MM.yyyy',
                    'de_CH'         => 'HH:mm | dd.MM.yyyy',
                    'de_DE'         => 'HH:mm | dd.MM.yyyy', //modified for timeline view for German (Germany)
                    'de_DE_EURO'    => 'HH:mm | dd.MM.yyyy',
                    'de_LU'         => 'HH:mm | dd.MM.yyyy',
                    'de_LU_EURO'    => 'HH:mm | dd.MM.yyyy',
                    'el_GR'         => 'HH:mm | d/M/yyyy', 
                    'en_AU'         => 'HH:mm | d/MM/yyyy', //modified for timeline view for English (Australia)
                    'en_B'          => 'HH:mm | M/d/yyyy',
                    'en_BM'         => 'HH:mm | M/d/yyyy',
                    'en_CA'         => 'HH:mm | dd/MM/yyyy',
                    'en_GB'         => 'HH:mm | dd-MMM-yyyy', //modified for timeline view for English (United Kingdom)
                    'en_GH'         => 'HH:mm | M/d/yyyy',
                    'en_ID'         => 'HH:mm | M/d/yyyy',
                    'en_IE'         => 'HH:mm | dd/MM/yyyy',
                    'en_IN'         => 'hh:mm a | dd MMM, yyyy',
                    'en-IN'         => 'HH:mm | dd/MM/yyyy',
                    'en_IE_EURO'    => 'HH:mm | dd/MM/yyyy',
                    'en_NZ'         => 'HH:mm | d/MM/yyyy',
                    'en_SG'         => 'HH:mm | M/d/yyyy',
                    'en_US'         => 'h:mm a | MMM d, yyyy', //modified for timeline view for English (United States)
                    'en_ZA'         => 'HH:mm | yyyy/MM/dd',
                    'es'            => 'HH:mm | d/MM/yyyy',
                    'es_AR'         => 'HH:mm | dd/MM/yyyy',
                    'es_BO'         => 'HH:mm | dd-MM-yyyy',
                    'es_CL'         => 'HH:mm | dd-MM-yyyy',
                    'es_CO'         => 'HH:mm | d/MM/yyyy',
                    'es_CR'         => 'HH:mm | dd/MM/yyyy',
                    'es_EC'         => 'HH:mm | dd/MM/yyyy',
                    'es_ES'         => 'HH:mm | d/MM/yyyy',
                    'es_ES_EURO'    => 'HH:mm | d/MM/yyyy',
                    'es_GT'         => 'HH:mm | d/MM/yyyy',
                    'es_HN'         => 'HH:mm | MM-dd-yyyy',
                    'es_MX'         => 'HH:mm | d/MM/yyyy',
                    'es_PE'         => 'HH:mm | dd/MM/yyyy',
                    'es_PR'         => 'HH:mm | MM-dd-yyyy',
                    'es_PY'         => 'HH:mm | dd/MM/yyyy',
                    'es_SV'         => 'HH:mm | MM-dd-yyyy',
                    'es_UY'         => 'HH:mm | dd/MM/yyyy',
                    'es_VE'         => 'HH:mm | dd/MM/yyyy',
                    'et_EE'         => 'HH:mm | d.MM.yyyy',
                    'fi'            => 'HH:mm | d.M.yyyy',
                    'fi_FI'         => 'HH:mm | d.M.yyyy',
                    'fi_FI_EURO'    => 'HH:mm | d.M.yyyy',
                    'fr'            => 'HH:mm | dd/MM/yyyy',
                    'fr_BE'         => 'HH:mm | d/MM/yyyy',
                    'fr_CA'         => 'HH:mm | yyyy-MM-dd',
                    'fr_CH'         => 'HH:mm | dd.MM.yyyy',
                    'fr_FR'         => 'HH:mm | d MMM yyyy', //modified for timeline view for French (France)
                    'fr_FR_EURO'    => 'HH:mm | dd/MM/yyyy',
                    'fr_LU'         => 'HH:mm | dd/MM/yyyy',
                    'fr_MC'         => 'HH:mm | dd/MM/yyyy',
                    'hr_HR'         => 'HH:mm | yyyy.MM.dd',
                    'hu'            => 'HH:mm | yyyy.MM.dd',
                    'hy_AM'         => 'HH:mm | M/d/yyyy',
                    'is_IS'         => 'HH:mm | d.M.yyyy',
                    'it'            => 'HH:mm | dd/MM/yyyy',
                    'it_CH'         => 'HH:mm | dd.MM.yyyy',
                    'it_IT'         => 'HH:mm | dd/MM/yyyy',
                    'iw'            => 'HH:mm | dd/MM/yyyy',
                    'iw_IL'         => 'HH:mm | dd/MM/yyyy',
                    'ja'            => 'HH:mm | yyyy/MM/dd',
                    'ja_JP'         => 'HH:mm | yyyy/MM/dd',
                    'kk_KZ'         => 'HH:mm | M/d/yyyy',
                    'km_KH'         => 'HH:mm | M/d/yyyy',
                    'ko'            => 'HH:mm | yyyy. M. d',
                    'ko_KR'         => 'HH:mm | yyyy. M. d',
                    'lt_LT'         => 'HH:mm | yyyy.M.d',
                    'lv_LV'         => 'HH:mm | yyyy.d.M',
                    'ms_MY'         => 'HH:mm | dd/MM/yyyy',
                    'nl'            => 'HH:mm | d-M-yyyy',
                    'nl_BE'         => 'HH:mm | d/MM/yyyy',
                    'nl_NL'         => 'HH:mm | d-M-yyyy',
                    'nl_SR'         => 'HH:mm | d-M-yyyy',
                    'no'            => 'HH:mm | dd.MM.yyyy',
                    'no_NO'         => 'HH:mm | dd.MM.yyyy',
                    'pl'            => 'HH:mm | yyyy-MM-dd',
                    'pt'            => 'HH:mm | dd-MM-yyyy',
                    'pt_AO'         => 'HH:mm | dd-MM-yyyy',
                    'pt_BR'         => 'HH:mm | dd/MM/yyyy',
                    'pt_PT'         => 'HH:mm | dd-MM-yyyy',
                    'ro_RO'         => 'HH:mm | dd.MM.yyyy',
                    'ru'            => 'HH:mm | dd.MM.yyyy',
                    'sk_SK'         => 'HH:mm | d.M.yyyy',
                    'sl_SI'         => 'HH:mm | d.M.y',
                    'sv'            => 'HH:mm | yyyy-MM-dd',
                    'sv_SE'         => 'HH:mm | yyyy-MM-dd',
                    'th'            => 'HH:mm | M/d/yyyy',
                    'th_TH'         => 'HH:mm | d/M/yyyy',
                    'tr'            => 'HH:mm | dd.MM.yyyy',
                    'ur_PK'         => 'HH:mm | M/d/yyyy',
                    'vi_VN'         => 'HH:mm | dd/MM/yyyy',
                    'zh'            => 'HH:mm | yyyy-M-d',
                    'zh_CN'         => 'HH:mm | yyyy-M-d',
                    'zh_HK'         => 'HH:mm | yyyy-M-d',
                    'zh_TW'         => 'HH:mm | yyyy/M/d'
                    };
                        }
        return localeToDateTimeFmtMap;
    }
    
    /*****************************************************************************************************
* @Name         :   getFormattedDate
* @Description  :   Method to format string based on users locale
* @Parameter    :   dt - Activity date time.
*                   userDateTimeFormat - DateTimeFormat required for User's locale
*                   activitySubType - sub type of activity (i.e. Task,event,call or Email)
*                   isAllDayEvent - to check if it is an all day event
*****************************************************************************************************/
    public static string getFormattedDate(DateTime dt, string userDateTimeFormat, string activitySubType, boolean isAllDayEvent){
        Boolean isFrenchLocale = false;
        Map<String,String> mapEngMonthToFrenchMonth;
        if(userinfo.getLocale() == 'fr_FR'){
            isFrenchLocale = true;
            mapEngMonthToFrenchMonth = new Map<String,String>{
                'Jan'               => 'janv.',
                    'Feb'               => 'févr.',
                    'Mar'               => 'mars',
                    'Apr'               => 'avr.',
                    'May'               => 'mai',
                    'Jun'               => 'juin',
                    'Jul'               => 'juil.',
                    'Aug'               => 'août',
                    'Sep'               => 'sept.',
                    'Oct'               => 'oct.',
                    'Nov'               => 'nov.',
                    'Dec'               => 'déc.'
                    };
                        }
        string strDate;
        string strTime;
        Date actDate = date.newinstance(dT.year(), dT.month(), dT.day());
        
        //If no format is defined for user locale show default format
        if(String.isBlank(userDateTimeFormat)){
            strDate = dt.format();
        }
        //If format is defined for user locale get the format from Date Util
        else{
            strDate = dt.format(userDateTimeFormat);
        }
        //get time from DateTime
        if(strDate.split('|').size() > 1 ){
            strTime = strDate.split('\\|')[0];
        }
        
        //For call and task remove time from strDate
        if(!activitySubType.equalsIgnoreCase('Event') && !activitySubType.equalsIgnoreCase('list_email') && !activitySubType.equalsIgnoreCase('Email') && strDate.split('|').size()>1){
            if(strDate.split('\\|').size() > 1){
                strDate = strDate.split('\\|')[1];
            }
        }
        
        //For all day event show All-Day Event | Date as strDate
        if(activitySubType.equalsIgnoreCase('Event') && isAllDayEvent && strDate.split('|').size()>1){
            strTime = 'All-Day '+findObjectLabels()[2].split('¤')[0]+' ';
            //To resolve issue with date time showing 1 day less for all day event when time is 00
            actDate = actDate.addDays(1);
            //To resolve date issue with All day events
            if(String.isBlank(userDateTimeFormat)){
                strDate = dt.format();
            }else{
                strDate = dt.formatGmt(userDateTimeFormat);
            }
            if(strDate.split('\\|').size() > 1){ 
                strDate = 'All-Day '+findObjectLabels()[2].split('¤')[0] +'  | '+strDate.split('\\|')[1];
            }else{
                strDate = 'All-Day '+findObjectLabels()[2].split('¤')[0];
            }
        }
        
        //Set date as today
        if(Date.today() == actDate){
            strDate = (activitySubType.equalsIgnoreCase('Event') || activitySubType.equalsIgnoreCase('Email') || activitySubType.equalsIgnoreCase('list_email'))? strTime + '| Today' : 'Today';
        }
        //Set date as yesterday
        else if(Date.today().addDays(-1) == actDate){
            strDate = (activitySubType.equalsIgnoreCase('Event') || activitySubType.equalsIgnoreCase('Email') || activitySubType.equalsIgnoreCase('list_email'))? strTime + '| Yesterday' : 'Yesterday';
        }
        //Set date as tomorrow
        else if(Date.today().addDays(1) == actDate){
            strDate = (activitySubType.equalsIgnoreCase('Event') || activitySubType.equalsIgnoreCase('Email') || activitySubType.equalsIgnoreCase('list_email'))? strTime + '| Tomorrow' : 'Tomorrow';
        }
        List<String> setOfSeperators = new List<String>{',','.','/','-','.',', ',' '};
            for(String sptr : setOfSeperators){ 
                //Remove year from date for activities in current year
                if(strDate.containsIgnoreCase(sptr+string.valueOf(Date.today().year()))){
                    strDate = strDate.remove(sptr+string.valueOf(Date.today().year()));
                }else if(strDate.containsIgnoreCase(string.valueOf(Date.today().year())+sptr)){
                    strDate = strDate.remove(sptr+string.valueOf(Date.today().year())+sptr);
                }
            }
        
        if(isFrenchLocale && strDate != null ){
            for(String month : mapEngMonthToFrenchMonth.keyset()){
                if(strDate.contains(month)){
                    strDate = strDate.replace(month, mapEngMonthToFrenchMonth.get(month));
                    
                }
            }
        }
        return strDate;
    }
    
    /*****************************************************************************************************
* @Name         :   findObjectNameFromRecordIdPrefix
* @Description  :   Method to Get record name based on record id prefix
* @Param        :   idPrefix - id or prefix of record id
*                   gd  -   global describe from schema
*****************************************************************************************************/
    public static String findObjectNameFromRecordIdPrefix(String idPrefix, Map<String, Schema.SObjectType> gd){
        String objectName = '';
        try{
            //Get prefix from record ID assuming that at least 3 characters are passed
            //String myIdPrefix = String.valueOf(recordIdOrPrefix).substring(0,3);
            
            //Loop through all the sObject types returned by Schema
            for(Schema.SObjectType stype : gd.values()){
                Schema.DescribeSObjectResult r = stype.getDescribe();
                String prefix = r.getKeyPrefix();
                
                //Check if the prefix matches with requested prefix
                if(prefix!=null && prefix.equals(idPrefix)){
                    objectName = r.getName();
                    break;
                }
            }
        }catch(Exception e){
            System.debug(e);
        }
        return objectName;
    }
    
    
    /***************************************************************************************************** 
* @Description: Classes for parsing compact layout response 
*****************************************************************************************************/
    public class CompoundLayoutWrapper{
        public cls_fieldItems[] fieldItems;
        public String id;   
        public String label;
        public String name; 
        public String objectType;
        
    }
    
    public class cls_fieldItems {
        public String label;    
        public cls_layoutComponents[] layoutComponents;
        
    }
    public class cls_layoutComponents {
        public cls_details details;
        
    }
    
    public class cls_details {
        public String label;    
        public String name; 
        public String type; 
        
    }
    
    
    /***************************************************************************************************** 
* @Description: Classes for parsing page layout response 
*****************************************************************************************************/
    public class layoutWrapperClass{
        public cls_recordTypeMappings[] recordTypeMappings;
    } 
    
    public class cls_recordTypeMappings {
        public String layoutId; //00h7F000002oTgOQAU
        public boolean master;
        public String name; //RT1
        public String recordTypeId; //0127F000000ZXEjQAO
    }
    
    public class actionsWrapperClass{
        public cls_Metadata Metadata;
    }
    
    public class cls_Metadata {
        public cls_platformActionList platformActionList;
        public cls_quickActionList quickActionList;
    }
    
    public class cls_platformActionList {
        public cls_platformActionListItems[] platformActionListItems;
    }
    public class cls_platformActionListItems {
        public String actionName;   //FeedItem.TextPost
        public String actionType;   //QuickAction
    }
    
    public class cls_quickActionList {
        public cls_quickActionListItems[] quickActionListItems;
    }
    public class cls_quickActionListItems {
        public String quickActionName;  //FeedItem.TextPost
    }
    
    /***************************************************************************************************** 
* @Description: Classes for parsing Task page layout response 
*****************************************************************************************************/
    
    public class pageLayoutWrapper{
        @AuraEnabled public cls_editLayoutSections[] editLayoutSections;
        //Changes for button layout parsing
        public ButtonLayoutSection buttonLayoutSection;
    }
    
    public class cls_editLayoutSections {
        @AuraEnabled public Integer columns; //2
        @AuraEnabled public String heading;  //Task Information
        @AuraEnabled public cls_layoutRows[] layoutRows;
        @AuraEnabled public String layoutSectionId;  //01B7F00000AnPi4UAF
        @AuraEnabled public String parentLayoutId;   //00h7F000002oTgXQAU
        @AuraEnabled public boolean useHeading;
    }
    
    public class cls_layoutRows {
        @AuraEnabled public cls_layoutItems[] layoutItems;
    }
    public class cls_layoutItems {
        @AuraEnabled public String label;    //Assigned To
        @AuraEnabled public cls_tasklayoutComponents[] layoutComponents;
        @AuraEnabled public boolean required;
        @AuraEnabled public boolean editableForNew; //isEditable
    }
    public class cls_tasklayoutComponents {
        @AuraEnabled public cls_taskdetails details;
        @AuraEnabled public String value;    //OwnerId
    }
    public class cls_taskdetails { 
        @AuraEnabled public boolean createable;
        @AuraEnabled public String[] referenceTo;
        @AuraEnabled public String type; //reference
        @AuraEnabled public boolean dependentPicklist;
        @AuraEnabled public String controllerName;
        @AuraEnabled public String length;
        @AuraEnabled public Integer scale;
        @AuraEnabled public cls_picklistValues[] picklistValues;
    }
    public class cls_picklistValues {
        @AuraEnabled public String value;
    }
    //For Button Parsing
    public class ButtonLayoutSection
    {
        public List<DetailButton> detailButtons { get; set; }
    }
    public class DetailButton
    {
        public string label { get; set; }
        public string name { get; set; }
    }
    
    /***************************************************************************************************** 
* @Description  : Returns mapofId to sobject to get name of particluar record
* @Parameter    : Map of object name vs record ids for that object
*                
*****************************************************************************************************/
    public static Map<Id, Sobject> getSobjectRecords(Map<String, Set<id>> objNamevsRecIds){
        
        Map<Id, Sobject> recIDvsRecord = new Map<Id, Sobject>();
        try{
            for(String objName :objNamevsRecIds.keyset()){
                Set<id> recIds = objNamevsRecIds.get(objName);
                 
                Map<Id, Sobject> tempRecIDvsRecord = new Map<Id, Sobject>(Database.query(String.escapeSingleQuotes('SELECT Id, Name FROM '+objName+' WHERE Id IN '+':recIds'))); //Added by keyur for Security Fix #00031825
                if(tempRecIDvsRecord.size() > 0)
                    recIDvsRecord.putAll(tempRecIDvsRecord);
            }
            return recIDvsRecord;
        }catch(Exception ex){
            return null;
        }
    }
    
    
    /***************************************************************************************************** 
* @Description  : returns picklist Wrapper           
*****************************************************************************************************/
    public class PicklistEntryWrapper{
        @AuraEnabled public String active;
        @AuraEnabled public String defaultValue;
        @AuraEnabled public String label;
        @AuraEnabled public String value;
        @AuraEnabled public String validFor;
    }
    
    public static String COMPACT_LAYOUT_CALLOUT_ENDPOINT(String objectName){
        return '/services/data/v50.0/sobjects/'+objectName+'/describe/compactLayouts/';   // change api varsion to 50 as some fields of compact layout is not available in api v41, changed by Anirudh Raturi in AA v3.0 on 09-02-2020
    }
    public static String PRIMARY_COMPACT_LAYOUT_ENDPOINT(String objectName){
        return '/services/data/v50.0/sobjects/'+objectName+'/describe/compactLayouts/primary';  // change api varsion to 50 as some fields of compact layout is not available in api v41, changed by Anirudh Raturi in AA v3.0 on 09-02-2020
    }
    
    /***************************************************************************************************** 
* @Description  : returns custom lookup search layout wrapper            
*****************************************************************************************************/
    public class searchLayoutWrapper{
        @AuraEnabled public cls_searchColumns[] searchColumns;
    }
    public class cls_searchColumns {
        @AuraEnabled public String label;   //Name
        @AuraEnabled public String name;    //Name
        @AuraEnabled public String field;    //Name
    }
    
    /********************************************************************************************************************
* @Description : Class to parse JSON for Layout
*******************************************************************************************************************/
    public class Urls
    {
        public string layout { get; set; }
    }
    
    public class RecordTypeMapping
    {
        public boolean active { get; set; }
        public boolean available { get; set; }
        public boolean defaultRecordTypeMapping { get; set; }
        public string layoutId { get; set; }
        public boolean master { get; set; }
        public string name { get; set; }
        //public List<object> picklistsForRecordType { get; set; }
        public string recordTypeId { get; set; }
        public Urls urls { get; set; }
    }
    
    public class RootObject
    {
        //public object layouts { get; set; }
        public List<RecordTypeMapping> recordTypeMappings { get; set; }
        public List<boolean> recordTypeSelectorRequired { get; set; }
    }
    
    /******************************************************************************************************************
* @Description: Method to create recordtype to Layout map
*****************************************************************************************************************/
    Public static map<String,Set<String>> createRecordTypeToButtonMap(Boolean taskPermission, Boolean eventPermission){
        
        //Domain url of current organization
        String domainUrl = URL.getSalesforceBaseUrl().toExternalForm();
        
        //Map objectname¤recordtypeId to response
        Map<String,Set<String>> mapRecordTypeToButton = new Map<String,Set<String>>();
        
        Map<String,String> mapRecordTypeToLayoutId = new Map<String,String>();
        
        //Map<String,String> mapRecordTypeToLightButtonAPI = new Map<String,List<String>>();
        
        //Get session Id to make API call from VF page
        String sessionId = getSessionIdFromVFPage(Page.sessionIdPage); 
        
        Http http = new Http();
        HttpRequest req = new HttpRequest();
        HTTPResponse resp = new HttpResponse();
        for(String objType : new List<String>{'task','event'}){
            //Set end point for the http request using domain usl and compact layout url
            req.setEndpoint(domainUrl+'/services/data/v41.0/sobjects/'+objType+'/describe/layouts');
            
            Http httpLayout = new Http();
            HttpRequest reqLayout = new HttpRequest();
            HTTPResponse respLayout = new HttpResponse();
            
            req.setMethod('GET');
            String autho ='Bearer '+ sessionId;
            req.setHeader('Authorization', autho);
            resp = http.send(req);
            RootObject layoutRootNode = (RootObject)JSON.deserialize(resp.getBody(),RootObject.class);
            
            //New logic for getting buttons from lightning action
            for(RecordTypeMapping rtm : layoutRootNode.RecordTypeMappings){
                mapRecordTypeToLayoutId.put(rtm.recordTypeId, rtm.layoutId);
            }
            for(String recordTypeId : mapRecordTypeToLayoutId.keySet()){
                String endpointurl ='/services/data/v41.0/tooling/sobjects/Layout/'+mapRecordTypeToLayoutId.get(recordTypeId);
                String actionResponse = NavatarResearchCommonUtility.getDescribeResponse(endpointurl);
                NavatarResearchCommonUtility.actionsWrapperClass act = (NavatarResearchCommonUtility.actionsWrapperClass)System.JSON.deserialize(actionResponse ,  NavatarResearchCommonUtility.actionsWrapperClass.class);
                Set<string> actionList = new Set<string>();
                
                //Check if platform actions is present
                if(act.Metadata.platformActionList != null){
                    NavatarResearchCommonUtility.cls_platformActionListItems[] platactionlistItems = act.Metadata.platformActionList.platformActionListItems;
                    for(NavatarResearchCommonUtility.cls_platformActionListItems actionItem:platactionlistItems){
                        if(actionItem.actionType == 'StandardButton'){
                            if((actionItem.actionName.equalsIgnoreCase('edit') || actionItem.actionName.equalsIgnoreCase('Delete') || (actionItem.actionName.equalsIgnoreCase('FollowupTask') && objType == 'Task')) 
                                && ((objType == 'task' && taskPermission) || (objType == 'event' && eventPermission))){
                                    if(actionItem.actionName.equalsIgnoreCase('edit')){
                                        actionList.add('Edit');
                                    }else if(actionItem.actionName.equalsIgnoreCase('delete')){
                                        actionList.add('Delete');
                                    }else if(actionItem.actionName.equalsIgnoreCase('FollowupTask')){
                                        actionList.add('FollowupTask');
                                    }
                            }
                        }
                    }
                }//In case buttons are not overridden
                else{
                    if((objType == 'task' && taskPermission) || (objType == 'event' && eventPermission)){
                        actionList.add('Edit');
                        actionList.add('Delete');
                        if(objType == 'task'){
                            actionList.add('Follow_Up_Task'); // FollowupTask
                        }
                        
                    }
                }
                if(actionList.size() > 0){
                    Set<String> sortedList = new Set<string>();
                    if(actionList.contains('Edit')){
                        sortedList.add('Edit');
                    }
                    if(actionList.contains('Delete')){
                        sortedList.add('Delete');
                    }
                    if(actionList.contains('Follow_Up_Task')){
                        sortedList.add('Follow_Up_Task'); // FollowupTask
                    }
                    
                    mapRecordTypeToButton.put(recordTypeId+'¤'+objType,sortedList);
                }
            }
        }
        
        return mapRecordTypeToButton;
    }
    /**********************************************************************************************************************
* @Description : method to delete record if the object is visible and deletable
* @Param : recordid to be deleted
**********************************************************************************************************************/ 
    public static void deleteRecord(id recordId){
        try{
            Boolean hasDeleteAccess = [SELECT recordid, HasDeleteAccess 
                                       FROM UserRecordAccess 
                                       WHERE UserId = :UserInfo.getUserId() 
                                       AND RecordId = : recordId].HasDeleteAccess;
            system.debug('hasDeleteAccess'+hasDeleteAccess);
            if(recordId.getSObjectType().getDescribe().isDeletable() && hasDeleteAccess){
                system.debug('hasDeleteAccess3333'+hasDeleteAccess);
                Database.delete(recordId);
            }else{
                
                throw new AuraHandledException('Exception occured: delete permission not assigned');
            }
        }catch(DMLException ex){
            throw new AuraHandledException('Exception occured:' + ex.getDmlMessage(0));
        }
        catch(Exception ex){
            system.debug('ddd'+ ex.getMessage() +'stack'+ ex.getStackTraceString());
            throw new AuraHandledException('Exception occured:' + ex.getMessage());
        }
    }
    
    // used to get Record Id and record name after passing related Associations record Ids Set.
    public static Map<Id, Sobject> populateObjectToSobjectMap(set<String> relatedAssociations){
        try{
            
            Map<String, Schema.SObjectType> gd;
            Map<String,string> PrefixToObjNameMap = new Map<String,String>(); //Variable to store prefix ids to avoid describe calls for same object
            map<String,Set<Id>> ObjectnametoSetRecIdsMap = new map<String,Set<Id>>();
            map<Id,Sobject> mapIdtosobjectName = new map<Id,Sobject>();
            if(gd==null){
                gd =  Schema.getGlobalDescribe(); 
            }
            for(String relatedRecordId : relatedAssociations){
                //Get prefix to get object name
                String prefix = relatedRecordId.substring(0,3);
                String objectName = '';
                
                //Check if map already contains prefix object
                if(PrefixToObjNameMap.containsKey(prefix)){
                    //Store object name
                    objectName = PrefixToObjNameMap.get(prefix);
                    if(gd.get(objectName).getDescribe().isAccessible()){
                        //Check if objectToSetId contains object
                        if(ObjectnametoSetRecIdsMap.containsKey(objectName)){
                            Set<Id> tempSet = ObjectnametoSetRecIdsMap.get(objectName);
                            tempSet.add(relatedRecordId);
                            ObjectnametoSetRecIdsMap.put(objectName,tempSet);
                        }else{
                            ObjectnametoSetRecIdsMap.put(objectName,new Set<Id>{relatedRecordId});
                        }
                    }
                }
                //Else make describe call and add to map
                else{
                    objectName = NavatarResearchCommonUtility.findObjectNameFromRecordIdPrefix(prefix,gd);
                    if(gd.get(objectName).getDescribe().isAccessible()){
                        //Add object name and related id to map
                        ObjectnametoSetRecIdsMap.put(objectName, new Set<Id>{relatedRecordId});
                        //add prefix and object name value to map
                        PrefixToObjNameMap.put(prefix,objectName);
                    }
                }
                
                
            }
            
            if(ObjectnametoSetRecIdsMap != null){
                mapIdtosobjectName =  NavatarResearchCommonUtility.getSobjectRecords(ObjectnametoSetRecIdsMap);
            }
            
            return mapIdtosobjectName ;
        }
        catch(Exception ex){
            system.debug('Exception::'+ex.getLineNumber()+':'+ex);
            return null ;
        }
    }
    
    /*****************************************************************************************************
* @Name         :   findObjectLabels
* @Description  :   return list of labels for activity, task and event
*                   This method is used in multiple association popup
*****************************************************************************************************/ 
    @AuraEnabled
    public static List<string> findObjectLabels(){
        //add labeld in sequence for activity, task and event
        List<String> labelList = new List<String>();
        
        //Get labes from describe call
        List<Schema.DescribeSObjectResult> describeSobjectsResult = Schema.describeSObjects(new List<String>{'OpenActivity','Task','Event'});
        
        //Add labels to list
        for(Integer i=0; i< describeSobjectsResult.size(); i++){
            //For Openactivity get plural label
            if(i==0){
                labelList.add(describeSobjectsResult[i].getLabelPlural().remove('Open').trim() +'¤'+ describeSobjectsResult[i].getLabel().remove('Open').trim());
            }else{
                labelList.add(describeSobjectsResult[i].getLabel()+'¤'+describeSobjectsResult[i].getLabelPlural());    
            }
        }
        
        return labelList;
    }
    public static boolean isPackageAccessible(string namespacePrifx){
        list<UserPackageLicense> userPackages = new list<UserPackageLicense>([select Id, PackageLicense.NamespacePrefix, UserId 
                                                                              from UserPackageLicense where userid=: Userinfo.getUserId() and PackageLicense.NamespacePrefix =:namespacePrifx]);
        return (userPackages!=null && userPackages.size()>0);
    }
}