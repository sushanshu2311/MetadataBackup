/**
* --------------------------------------------------------------------------------------------------
* Apex class designed to calculate the Last Touch point from task based activity date field and update
* Last Touch Point date and Last Touch Point Id on Contact.
* --------------------------------------------------------------------------------------------------
* @author         Priyank Kumar
* @modifiedBy     Samiulla Pathan: added Backend Tagging while merge// 18-july-2023 Anmol & Ehatsham
* @version        1.0
* @created        2019-11-21
* @modified       2019-11-24/2023-07-18
** Version    Date(YYYY-MM-DD)    Author         Description of Action
** 1.0        2022-11-21          Adil             Acuity Phase 1
** 2.0        2024-03-06          Sudhanshu        Added Check for Review Tag

*/

public with sharing class NavatarTaskTriggerHandler{
    // Bug 00047745,00047554 fixed by Sudhanshu
    public static String globalExclusionString='Capital Project Group Partner Partners Next Work America Systems Credit Active First Business company services Service companies products consulting growth water direct food sales Health corp healthcare finance management enterprises marketing will care family brokers Adam Allan Alex Andrew Anna Anne Anthony Barry Bill Brad Brenda Brian Carl Caroline Cathy Charles Chris Christopher Cook Craig Cynthia Daniel Dave David Donald Doug Elizabeth Eric Frank Fred Gary George Greg Gregory Harry Henry Jack Jackie James Jason Jeff Jeffrey Jennifer Jeremy Jill John Jonathan Jones Joseph Josh Julie Julia Karen Kevin Mark Michael Michelle Mike Nancy Nick Nicholas Paul Peter Phil Philip Richard Robert Ronald Roger Scott Smith Stephen Steve Steven Susan Thomas Todd William corporation International solutions manufacturing technologies chemicals equity technology american packaging industrial industrials speciality energy software office manufacturer corporate investments securities supply polymers GmbH Boston research distributor commercial data California Alliance consumer Spectrum Canada Europe Berlin access Acquisition Advisors advisory asset Associates bank banking Board building case center Chicago Clinical Dental Development devices Diagnostic diagnostics diversified doctor endowment engineering European financial focus foundation France Fund funds German Germany glass high home hospital income industry information innovation insurance invest investing investment investor investors labs level Life Limited London managed Market markets Medical medicine Miami Morgan national network Opportunities opportunity Part pension people performance pharma plan Private process product provider quality real reinsurance School science Sciences source SPAC Special state strategic strategies strategy Summit system team three time total transaction trust University value venture ventures well with world Aaron Alexander Bell Berg best Brown Clark Frederik Harris Howard Kelly Marc Martin Marvin Matt Miller Murphy Patel Patrick Ryan Simon Taylor Tony west Williams holding Frankfurt young Ernst instruments Media general biopharma Vision future implants Legal clinics design centre Scientific small Dutch Belgium cell computer electronic training plus brothers innovative MedTech control Austria online productions travel Roland integrated partnership materials video biotechnologies clinic Labor early retail test price point Stefan Christian Philippe Dirk global Firm Biotech tech surgical drug digital consultants consultancy line dynamics trading discovery imaging managers Institute executive human pharmaceutical info therapy link factory white exchange automotive agency trade heart applied resources micro wave brain distribution deal Industries college Street pipeline security great City transportation power branded platform infrastructure flow Park logistics contractor chain chemical Rental public auto Hill parts heavy electrical brand brands holdings contract fire meat employees below record assets specialty division steel electronics call acquisitions advanced segment long facility United River house facilities stores Post customer environmental businesses operations cash place waste Asia space paper hotel natural premium hotels storage light union risk maintenance transport production super double fuel base wood technical professional core defense wireless staffing country label legacy estate gold Retirement institutional County founders South education proprietary delivery press event delta action Restaurant Party material communication practice communications dealer Pizza restaurants unit franchise franchisee units king fitness forward Wealth Arthur Stein Michel Markus Stephan Erik Sean Andy Bryan Justin Derek Matthew Bruce Lewis Jamie Stanley Edward Kyle Jordan Rich Johnson Rick Dennis Graham Larry Arnold page ball Jose list Andreas Philipp Oliver Nicole Amanda Davis Stephens Clay Jake Timothy Douglas Tests construction equipment mezzanine Planning portfolio support radio adhesives north safety pipe fruit alternative Butler Coast Cohen Compensation fixed from Gilde Merck metal molecular Novartis Plastics preferred Purpose sense Therapeutics Arnoud Hans Schoot vliet Vries Warren willem Wright this Utrecht Oncology Benelux Hamburg Nordic cancer Gruppe open Kapital chance York Have Grery close interim spin gene search voor PortCo payment machine benefit Impact Road master based floor Cable mail personal color mobile related full coffee rock kitchen guys client profile Pieter Hugo Frans Lars Wolfgang Tobias Rene Francois Christoph Florian does here';
    public static String emaiStartWith = 'From:';//Samiulla: BackendTagging
    public static String taskSubTypeStr = 'Email';//Samiulla: BackendTagging
    //Find the Last Touch Point based on Task's ActivityDate and update the same on Contact.
    //00039504 added by pavani
    private static Map<String , Boolean> notificationSettings = NavatarUtility.isNotificationAllowed();
    //Adding Namespace variable
    public static string strOrgSpacePrefix = CommonUtility_EdgeMenu.strOrgNameSpacePrefix;
    public static string strPackNameSpacePrefix = CommonUtility_EdgeMenu.strNameSpacePrefix;
    
    public static void OnAfterInsUpdDelNew(List<Task> newTaskList, Map<Id, Task> oldTaskMap){
        Map<Id,Task> taskMapBT = new Map<Id,Task>();//Samiulla: BackendTagging
        Set<Id> taskIds = new Set<Id>();

        Set<Id> contactIds = new Set<Id>();
		//added by Pavani for bug 00033760
        if(newTaskList.size()==1){
            if(Trigger.isAfter && (Trigger.isInsert || Trigger.isUpdate)){
                Task newTask= newTaskList[0];
                Task oldTask=oldTaskMap!=null?oldTaskMap.containsKey(newTask.Id)?oldTaskMap.get(newTask.Id):null:null;
                if(!String.isBlank(newTask.Related_Associations__c)&&(oldTask==null || 
                (oldTask!=null && oldTask.Related_Associations__c!= newTask.Related_Associations__c))
                //00039504 added by pavani
                && notificationSettings.containsKey('info') && notificationSettings.get('info')){
                    
                    createNewInfoNotification(newTask,oldTask);
                }
                
            }
            if(!Trigger.isUpdate){//Parallel Project changes: Backend Tagging will not work in Update Scenario
        for(Task oTask : newTaskList){
			
            taskMapBT.put(oTask.Id, otask);//Samiulla: Backend Tagging
         }   
        if(taskMapBT.size()>0){//Samiulla: BackendTagging
            System.debug('review ==> '+notificationSettings.get('review'));
            if(notificationSettings.containsKey('review') && notificationSettings.get('review')){
                System.debug('review ==> '+notificationSettings.get('review'));
                handleDescriptionInsert(taskMapBT);
            }
        }
            }
        }//00033760 end								  
        
        
        
    }

/****************************************************************************************************
** Module Name : BackEnd Tagging
** Description : This class will filter all the contact and first users which user has not tagged in the outlook mail.
** Throws : NA
** Calls : NA
** Organization : Navatar Group
** Product Name & Version : Acuity 2.0
** Revision History:-
** Version    Date(YYYY-MM-DD)    Author         Description of Action
** 1.0        2022-11-17          Samiulla  
****************************************************************************************************/
    
    /****************************************************************************************************
    Purpose : filter the description and find the list of potential Firm and Contact. If record found, 
                return the Assignee id, Related Association List and task Id
    Input : Task entry
    Returns : Json of data
    ****************************************************************************************************/
    public static void handleDescriptionInsert(Map<Id,Task> records) {
        Set<String> allDescriptionsText = new Set<String>();
        //Exclusion List changes: started
        Set<String> clientExclusionSet = new Set<String>();
        String exclusionField = strOrgSpacePrefix != null ? strOrgSpacePrefix+'Notes_Tag_Exclusion_List__c' : 'Notes_Tag_Exclusion_List__c';
        if(Schema.getGlobalDescribe().get(strPackNameSpacePrefix+'Navatar_Setup__c').getDescribe().fields.getMap().containsKey(exclusionField)){
            List<sObject> lst = new List<sObject>();//Long Text Area: max
            String strQuery = 'SELECT Id,'+exclusionField+' FROM '+strPackNameSpacePrefix+'Navatar_Setup__c Where '+strPackNameSpacePrefix+'Admin_Setting__c = true Order by CreatedDate ASC LIMIT 1';
            lst = Database.query(string.escapesinglequotes(strQuery));
            if(lst[0].get((exclusionField)) != null){
                String exclusionStr = lst[0].get((exclusionField)).toString();
                clientExclusionSet.addAll(exclusionStr.trim().split(','));
            }
        }
        Set<String> exclusionSet = new Set<String>();
        for(String str1 : globalExclusionString.split(' ')){
            exclusionSet.add(str1.trim().toLowerCase());
        }
        if(clientExclusionSet.size() > 0){
            for(String str1 : clientExclusionSet){
                exclusionSet.add(str1.trim().toLowerCase());
            }
        }
        //ended
        for(Id recId : records.keySet()) {
            //Check for description is starts with 'From:''
            String description = records.get(recId).Description;
            String taskSubTypeStrLcl = records.get(recId).TaskSubtype;
            if(String.isNotBlank(description) && description.startsWithIgnoreCase(emaiStartWith) && taskSubTypeStrLcl == taskSubTypeStr){
                String tempDesc=records.get(recId).Description;
                tempDesc=tempDesc.replace('\n',' ');
                allDescriptionsText.addAll(tempDesc.split(' '));
            }else{
                return;
            }
        }
        Integer i=0;
        Pattern specialCharPattern = Pattern.compile('[^a-zA-Z0-9]');
        Pattern emailPattern = Pattern.compile('^[a-zA-Z0-9._|\\\\%# `=?&/$^*!}{+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,4}$');
        Pattern weblinkPattern = Pattern.compile('(^((http|https)://)??(www[.])??([a-zA-Z0-9]|-)+?([.][a-zA-Z0-9(-|/|=|?)??]+?)+?$)');
        Pattern digitPattern = Pattern.compile('[0-9]');
        Pattern alphaPattern = Pattern.compile('[a-zA-Z]');
        List<String> containsStrList=new List<String>{'.com','https://','http://','www.','https:'};
        String REPLACE = '\\\\$0';
        Set<String> searchTermSet=new Set<String>();
        for(String str : allDescriptionsText) {
            String tempStr=str.stripHtmlTags();
            tempStr.trim();
            Boolean tobeSkipped=false;
            for(String s:containsStrList){
                if(tempStr.indexOf(s)!=-1){
                    tobeSkipped=true;
                }
            }
            if(tobeSkipped){
                continue;
            }
            if(tempStr.length()>3 && tempStr.length() < 45 && !exclusionSet.contains(tempStr.toLowerCase()) && !emailPattern.matcher(tempStr).matches() && !weblinkPattern.matcher(tempStr).matches() && !(digitPattern.matcher(tempStr).find() && specialCharPattern.matcher(tempStr).find() && !alphaPattern.matcher(tempStr).find())) {
                searchTermSet.add(tempStr);//escaped special chars.replaceAll('[^a-zA-Z0-9]', REPLACE)
            }
            
        }containsStrList.clear();
        allDescriptionsText.clear();
        Set<String> soslLikeWords = new Set<String>();
        Set<String> soslINWords = new Set<String>();
        String soslSearchString = '';
        For(String str : searchTermSet){
            str.replace('\\\\','\\');
            if(str != null && str!= '' && str != ' ' && str != '\n'){
                // Start Code Optimization
                 String soslStr = str;
                
                Boolean checkSpl = false;
                soslINWords.add(soslStr);
                if(soslStr.indexOf('\\') == -1){

                    String soslWord = '% '+soslStr;
                    soslLikeWords.add(soslWord);
                    soslWord = soslStr+' %';
                    soslLikeWords.add(soslWord);
                    soslWord = '% '+soslStr+' %';
                    soslLikeWords.add(soslWord);
           
                    Matcher patternMatcher = specialCharPattern.matcher(soslStr);
                    Boolean hasSpecialChars = patternMatcher.find();

                    checkSpl = hasSpecialChars ? soslStr.indexOf('\'') != -1 ? true : false : true;                       
                    
                }else{
                    
                    
                    checkSpl = true;
                }
                // End Code Optimization
                
                if(soslSearchString.length() < 3980){
                    if(soslSearchString == ''){
                        soslSearchString = soslSearchString + str.trim();
                    }else{
                        soslSearchString = soslSearchString + ' OR ' + str.trim();
                    }
                }else{
                    system.debug('in else=='+soslSearchString);
                    soslSearchString = '';
                }
            }
        
        }searchTermSet.clear();
        
        /*
        List<List <sObject>> accQuery = search.query('FIND \''+ soslSearchString + '\' in NAME fields RETURNING Account(Id , Name )');
        List<List <sObject>> conQuery = search.query('FIND \''+ soslSearchString + '\' in NAME fields RETURNING Contact(Id , Name Where name like :soslLikeWords OR Name IN :soslINWords)');

        List<Account> accounts = new List<Account>();
        for(List<SOBject> sRec:accQuery){
            accounts.addAll((List<Account>)sRec);
        }
        List<Contact> contacts = new List<Contact>();
        for(List<SOBject> sRec:conQuery){
            contacts.addAll((List<COntact>)sRec);
        }*/
        List<Account> accounts = (List<Account>)[FIND :soslSearchString in NAME fields RETURNING Account(Name, Id Where name like :soslLikeWords OR Name IN :soslINWords)][0];
        List<Contact> contacts = (List<Contact>)[FIND :soslSearchString in NAME fields RETURNING Contact(Name, Id Where name like :soslLikeWords OR Name IN :soslINWords)][0];

        soslSearchString='';
        Set<String> existingIds = new Set<String>();
                for(Account acc : accounts) {
            System.debug(acc.Id);
                        existingIds.add(acc.Id);
        }accounts.clear();
                for(Contact contactRec : contacts) {
                        existingIds.add(contactRec.Id);
        }contacts.clear();
        if(!existingIds.isEmpty()){
            // Updated for Task Resolution
            Set<Id> recSet = records.keySet();
            String query = 'SELECT Id, RelationId, TaskId, IsWhat, AccountId FROM TaskRelation WHERE TaskId IN :recSet';            
            //Replace list by Set for existingIds
            for(SObject sobj : Database.query(query)){
                    System.debug(existingIds.contains(String.valueOf(sobj.get('RelationId'))));
                    if(existingIds.contains(String.valueOf(sobj.get('RelationId')))){
                        existingIds.remove(String.valueOf(sobj.get('RelationId')));
                }
            }
        }
       //00039502 ADDED BY PAVANI
        if(!existingIds.isEmpty() && notificationSettings.containsKey('action') && notificationSettings.get('action')){
            insertNavatarNotification(records);
        }
    }

    /****************************************************************************************************
    Purpose : this method will insert record in notificati  on object

    Input : list of RecordWrapper

    Returns : 
    ****************************************************************************************************/
    public static void insertNavatarNotification(Map<Id,Task> records){
        try{
            List<Navatar_Notification__c> navatarNotificationList = new List<Navatar_Notification__c>();
            List<Navatar_Notification__c> readExistinRecords = [SELECT Id FROM Navatar_Notification__c WHERE Record_ID__c IN: records.keySet() AND Type__c =:'Add Tag' ];
            if(readExistinRecords.isEmpty()){
            for(Id recId : records.keySet()) {
                 //owner id is assignee id for which outloop email was sent from
                Navatar_Notification__c navatarNotification = new Navatar_Notification__c();
                if (Schema.sObjectType.Navatar_Notification__c.fields.Record_ID__c.isCreateable()) {
                    navatarNotification.Record_ID__c = records.get(recId).Id;
                }
                Id objId = (Id)records.get(recId).OwnerId;
                String sObjName = objId.getSObjectType().getDescribe().getLabel();
                //check for object type. Object name should be User.
                if(sObjName == 'User' && Schema.sObjectType.Navatar_Notification__c.fields.User__c.isCreateable()){
                   
                     navatarNotification.User__c = records.get(recId).OwnerId;
                    
                }
                if (Schema.sObjectType.Navatar_Notification__c.fields.Type__c.isCreateable()) {
                    navatarNotification.Type__c = 'Add Tag';
                }
              
                navatarNotificationList.add(navatarNotification);
    
            }
            //added schema check as part of security fix by pavani
            if(!navatarNotificationList.isEmpty() && Schema.getGlobalDescribe().get('navpeII_dev18__Navatar_Notification__c').getDescribe().isCreateable()){
               insert navatarNotificationList;
            }
        }
        }catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
    }//Samiulla: Backend Tagging: End
/****************************************************************************************************
    Purpose : Creates Info notification for deal and theme when tagged  a task

    Input : New Task Record and Old Task Record
    //added by Pavani for bug 00033760
    *******************************************************************************************************/
    public static void createNewInfoNotification(Task newTask,Task oldTask){
        String oldRelatedAssosciations= (oldTask!=null && String.isNotBlank(oldTask.Related_Associations__c))? oldTask.Related_Associations__c:'';
        //checking if newly tagged record
        List<String> newTaggedRecords = new List<String>();
        if(newTask!=Null){
            newTaggedRecords.addAll(newTask.Related_Associations__c.split(','));
        }
        List<Navatar_Notification__c> notificationList = new List<Navatar_Notification__c>();
        Set<Id> dealIds = new Set<Id>();
        Set<Id> themeIds = new Set<Id>();
        if(newTaggedRecords.size()>0 ){
            for(String tag:newTaggedRecords){
                String objectName = Id.valueOf(tag).getSobjectType().getDescribe().getName();
                if((objectName == 'navpeII_dev18__Pipeline__c'||objectName == 'Pipeline__c') && !oldRelatedAssosciations.contains(tag)){
                    dealIds.add(tag);
                }else if((objectName == 'navpeII_dev18__Theme__c' || objectName == 'Theme__c') && !oldRelatedAssosciations.contains(tag)){
                    themeIds.add(tag);
                }
            }
        }
       if(themeIds.size()>0){
            //calling method on Event trigger helper to check if any existing notifications are available
            notificationList.addAll(prepareNotificationForThemeRelation(themeIds,newTask));
        }
        if(dealIds.size()>0){
            notificationList.addAll(prepareNotificationForDealTeam(dealIds,newTask));
        }
        if(!notificationList.isEmpty() && Schema.getGlobalDescribe().get('navpeII_dev18__Navatar_Notification__c').getDescribe().isCreateable()){
            Database.insert(notificationList , false);
        } 
        
    }
     /*****************************************************************************************************
    * @Name         :   prepareNotificationForThemeRelation
    * @Description  :   Method to prepare Theme Activity Info Notification record based on theme ids
    * @Parameter    :   Set<Id>
    //added by Pavani for bug 00033760 
    *****************************************************************************************************/
    private static List<Navatar_Notification__c> prepareNotificationforThemeRelation(Set<Id> themeIds, Task activity){
        Set<String> existingNotificationSet = new Set<String>();
        List<Navatar_Notification__c> notificationList = new List<Navatar_Notification__c>();
        //added  stripInaccessible by Pavani w.r.t security fix  
        for(SObject notif :Security.stripInaccessible(AccessType.READABLE,
                        [SELECT Id, Record_ID__c, User__c 
                        FROM Navatar_Notification__c 
                        WHERE Record_ID__c IN :themeIds]).getRecords()){
            Navatar_Notification__c nn = (Navatar_Notification__c)notif;
            if(nn.isSet('Record_ID__c') && nn.Record_ID__c != null && nn.isSet('User__c') &&  nn.User__c != null) {
                existingNotificationSet.add(nn.Record_ID__c + '-' + nn.User__c + '-' + nn.Type__c);
            }   
        }
        if(Schema.SObjectType.Theme__c.isAccessible() && 
        Schema.SObjectType.Theme_Team__c.isAccessible()){
            List<Theme_Team__c> themeTeamList = [SELECT Id, Theme__c, Member__c FROM Theme_Team__c WHERE Theme__c IN : themeIds
                                                AND Member__c!=null];
            SObjectAccessDecision ttReadDecision = Security.stripInaccessible(AccessType.READABLE,themeTeamList);
            for(SObject themeteam : ttReadDecision.getRecords()){
                Theme_Team__c tr = (Theme_Team__c)themeteam;
                if(Schema.SObjectType.Theme_Team__c.fields.Theme__c.isAccessible() &&
                    Schema.SObjectType.Theme_Team__c.fields.Member__c.isAccessible()){ 
                    String key = tr.Theme__c + '-' + tr.Member__c  + '-' + NavatarConstants.THEME_ACTIVITY_INFO;
                    if(!existingNotificationSet.contains(key) && activity.OwnerId != tr.Member__c){
                        Navatar_Notification__c nn = new Navatar_Notification__c();
                        if (Schema.sObjectType.Navatar_Notification__c.fields.Record_ID__c.isCreateable()) {
                            nn.Record_ID__c = activity.Id;
                        }
                        if (Schema.sObjectType.Navatar_Notification__c.fields.User__c.isCreateable()) {
                    nn.User__c = tr.navpeII_dev18__Member__c;
                        }    
                        if (Schema.sObjectType.Navatar_Notification__c.fields.Type__c.isCreateable()) {
                            nn.Type__c = NavatarConstants.THEME_ACTIVITY_INFO;
                        }    
                        notificationList.add(nn);         
                    }
                }
            }
        }
        return  notificationList;
    }
      /*****************************************************************************************************
    * @Name         :   prepareNotificationForDealTeam
    * @Description  :   Method to prepare Deal Activity Info Notification record based on deal ids
    * @Parameter    :   Set<Id>
    //added by Pavani for bug 00033760
    *****************************************************************************************************/
    private static List<Navatar_Notification__c> prepareNotificationForDealTeam(Set<Id> dealIds, Task activity){
        Set<String> existingNotificationSet = new Set<String>();
        List<Navatar_Notification__c> notificationList = new List<Navatar_Notification__c>(); 
        //added  stripInaccessible by Pavani w.r.t security fix 
        for(SObject notif :Security.stripInaccessible(AccessType.READABLE,
                        [SELECT Id, Record_ID__c, User__c 
                        FROM Navatar_Notification__c 
                        WHERE Record_ID__c IN :dealIds]).getRecords()){
            Navatar_Notification__c nn = (Navatar_Notification__c)notif;
            if(nn.isSet('Record_ID__c') && nn.Record_ID__c != null && nn.isSet('User__c') && nn.User__c != null) {
                existingNotificationSet.add(nn.Record_ID__c + '-' + nn.User__c + '-' + nn.Type__c);
            }   
        }
        if(Schema.SObjectType.navpeII_dev18__Pipeline__c.isAccessible() && 
        Schema.SObjectType.navpeII_dev18__Deal_Team__c.isAccessible()){
            List<navpeII_dev18__Deal_Team__c> dealTeamList = [SELECT Id, navpeII_dev18__Deal__c, navpeII_dev18__Team_Member__c FROM navpeII_dev18__Deal_Team__c WHERE navpeII_dev18__Deal__c IN : dealIds
                                                        AND navpeII_dev18__Team_Member__c!=null];	
            SObjectAccessDecision dtReadDecision = Security.stripInaccessible(AccessType.READABLE,dealTeamList);
            for(SObject dealteam : dtReadDecision.getRecords()){ 
                navpeII_dev18__Deal_Team__c dt = (navpeII_dev18__Deal_Team__c)dealteam;
                if(Schema.SObjectType.navpeII_dev18__Deal_Team__c.fields.navpeII_dev18__Deal__c.isAccessible() &&
                    Schema.SObjectType.navpeII_dev18__Deal_Team__c.fields.navpeII_dev18__Team_Member__c.isAccessible() ){
                    String key = dt.navpeII_dev18__Deal__c + '-' + dt.navpeII_dev18__Team_Member__c  + '-' + NavatarConstants.DEAL_ACTIVITY_INFO;
                    if(!existingNotificationSet.contains(key) && activity.OwnerId != dt.navpeII_dev18__Team_Member__c){
                        Navatar_Notification__c nn = new Navatar_Notification__c();
                        if (Schema.sObjectType.Navatar_Notification__c.fields.Record_ID__c.isCreateable()) {
                            nn.Record_ID__c = activity.Id;
                        }
                        if (Schema.sObjectType.Navatar_Notification__c.fields.User__c.isCreateable()) {
                            nn.User__c = dt.navpeII_dev18__Team_Member__c;
                        }
                        if (Schema.sObjectType.Navatar_Notification__c.fields.Type__c.isCreateable()) {
                            nn.Type__c = NavatarConstants.DEAL_ACTIVITY_INFO;
                        }    
                        notificationList.add(nn);         
                    }
                }
            }
        }
        return  notificationList;
    }
																			
}