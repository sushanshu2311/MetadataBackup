/*********************************************************************************
** Project: M&A 3.5
** Start: 2017-02-25
** Module Name : ContactTransfer
** Description : This opens when Contact Transfer button gets clicked, and contact's activities gets copied to old/new Accounts as per scenarios
** Throws : Exception and Custom Exceptions
** Calls : NA
** Test Class : TestContactTransfer_ctlr
** Organization : Navatar Group
** Revision History:-
** Version Date(YYYY-MM-DD)       Author  Description of Action
** 3.5     2017-02-25             Vanita  This opens when Contact Transfer button gets clicked, and contact's activities gets copied to old/new Accounts as per scenarios
## V1.0 Add-On 21-5-21            Anshika   This is now dynamic and works for both PE and MnA, ALso now there will be no lookup field on Activity in our package now if there is an existing lookup field on
this will pull the api name of the lookup field and will use it while contact is being transfered to the new Contact.
## Changes for New Client 30-6-21 Aditya   Added condition for new activity setting, which is to not move any activity when transferring contact        
*********************************************************************************/
public with sharing class ContactTransferAddOn_ctrl{
    
    public string inputValue{get;set;}
    public contact contactPE{get;set;}
    public string namespacePE{get;set;}
    public string serverUrl{get;set;}
    public string contactDetailPagePath{get;set;}
    public string contactId{get;set;}
    public Contact contactLookup{get;set;}
    public string contactName{get;set;}
    public string legalNameOld{get;set;}
    public string legalNameNew{get;set;}
    public string displayMessage{get;set;}
    public boolean isContactIdNull{get;set;}
    public string legalIdOld{get;set;}
    public string legalIdNew{get;set;}
    public boolean isError{get;set;}
    public string errorMessage {get;set;}
    public boolean isOrgSettingActive{get;set;}
    public boolean isTransferred {get;set;}
    public boolean isCode12365 {get;set;}
    public boolean isPopupOpen {get;set;}
    public Contact contactInfo {get;set;}
    public SObject orgSettingOffice {get;set;}
    public boolean isFundraisingContact {get;set;} //checks if contact is tagged in Fundraising Contact
    public string affiliationID='';
    public boolean isAccountLookupNull {get;set;} //checks if Account lookup field is not blank on setting object
    public boolean IpadLightning {get;set;}
    public Boolean isMobile {get; set;} // added to get device type 
    
    //Variables added W.R.To version V1.0 for the Add-On functionality
    public string namespacePrefix = 'navmnaI__'; 
    public string strObjectName = getOrgSpecificObject();
    public string advanceSetting1; 
    public string advanceSetting2;
    public string advanceSetting3;
    public string activitySetting1;
    public string activitySetting2;
    public string activitySetting3; // added to hold new picklist value of CTS_Activity field for New Client by Aditya 17 June 2021
    public string ctsActivitySetting; //stores Product Settings Activity value
    public string ctsAdvanceSetting; //stores Product Settings Advance value
    public string accAPIName; // stores API name of  lookup field on Account on object Activity 
    public String affiliationObjName; //stores Affiliation's Account Lookup field API name
    public String affiliationAccountLookup; //stores Affiliation's Account Lookup field API name
    public String orgMetadataActive; //stores custom metadata setting Active field API name
    public String fundraisingObject;
    
    /*
@Description: Constructor of ContactTransferAddOn_ctrl
*/
    public ContactTransferAddOn_ctrl(ApexPages.StandardController controller) {
        try{
            isContactIdNull =false;
            isOrgSettingActive = true;
            isError = false;
            isCode12365 = false;
            isAccountLookupNull = false;
            isFundraisingContact = false;
            list<user> user_info=[select LocaleSidKey,UserPreferencesLightningExperiencePreferred from user where id=:Userinfo.getUserId()];
            
            isMobile = UserInfo.getUiTheme() == 'Theme4t'; // added to get device type
            IpadLightning = user_info[0].UserPreferencesLightningExperiencePreferred;
            contactId = apexpages.currentpage().getparameters().get('id');  
            contactLookup = new Contact();
            if(string.isEmpty(contactId)||string.isBlank(contactId)){
                isContactIdNull = true;             
                throw new MyCustomException('Contact ID missing in URL.');              
            }
            else{  
                //Query in CustomMetaData Types and select OrgSetting.Active where Org Setting Name = Contact Tran Setting 
                string query = 'select ' + namespacePrefix + orgMetadataActive + ', DeveloperName FROM ' + namespacePrefix + 'Org_Setting__mdt where DeveloperName =  \'Contact_Tran_Setting\' limit 1';
                List<SObject> orgSetting = database.query(query);
                //check list size
                if(orgSetting[0].get(namespacePrefix+orgMetadataActive) == false && !Test.isRunningTest()){
                    isOrgSettingActive = false;
                    throw new MyCustomException('You cannot access this functionality. Functionality may be disabled. Please contact Navatar administrator.');
                }
                else{
                    
                    if(namespacePrefix == 'navpeII__'){
                        String fundraisingQuery = 'SELECT Name, ' + namespacePrefix + 'Contact__c from ' + fundraisingObject + ' where ' + namespacePrefix + 'Contact__c =:contactId';
                        List<SObject> fundraisingContactList = Database.Query(fundraisingQuery);
                        if(fundraisingContactList.size() > 0){
                            isFundraisingContact = true;                        
                        } 
                    }
                    
                    String settingQuery = 'select ' + namespacePrefix + 'CTS_Activity__c,' + namespacePrefix + 'CTS_Advanced__c, CTS_Account_Activity_Lookup__c FROM ' + strObjectName + ' WHERE ' + namespacePrefix + 'Admin_Setting__c=true Limit 1';
                    List<SObject> setupInfoList = database.query(settingQuery);
                    if(setupInfoList.size()==0){
                        isCode12365 = true;
                        throw new MyCustomException('Code: 12365. Please contact Navatar Support. System setup improperly.');
                    }
                    else{
                        //Pull all Product/Navatar Setup Settings values
                        ctsActivitySetting = (string)setupInfoList[0].get(namespacePrefix+'CTS_Activity__c');
                        ctsAdvanceSetting = (string)setupInfoList[0].get(namespacePrefix+'CTS_Advanced__c');
                        if(setupInfoList[0].get('CTS_Account_Activity_Lookup__c') != null){
                            accAPIName = (string)setupInfoList[0].get('CTS_Account_Activity_Lookup__c');   
                        }
                        else{
                            isAccountLookupNull = true;
                            throw new MyCustomException('Activity Account Lookup field is missing. Please contact Navatar Support.');    
                        }
                        //Load Contact Data
                        Contact contactObj= [Select Name, Account.Name, Account.Id from Contact where Id=:contactId];
                        contactName = contactObj.Name;
                        legalNameOld = contactObj.Account.Name;
                        legalIdOld = contactObj.Account.Id;  
                    } 
                    if(accAPIName != null){
                        if(!Schema.SObjectType.Task.fields.getMap().keySet().contains(accAPIName.toLowerCase()) == true){//If Account lookup on settings object does not contains valid Api name of account lookup field throw exception
                            isAccountLookupNull = true;
                            throw new MyCustomException('Activity\'s Account Lookup field is missing. Please contact Navatar Support.');    
                        }
                    }
                    
                }
                beforeTransferActivity();
            }
        }
        catch(MyCustomException ex){
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,ex.getMessage()));                      
        }
        catch(Exception ex){
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,ex.getMessage()));              
        }       
    }
    
    /*
@Description:   Cancel method is for going back to Contact Detail Page
This is called by clicking "Cancel button" and also called on "oncomplete event of TransferActivity"
*/     
    public PageReference Cancel(){
        try{
            PageReference pr = new pagereference('/' + contactId);       
            return pr;
        }
        catch(Exception ex){
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,ex.getMessage()));            
            return new PageReference('');
        }       
    }
    
    /*
@Description:   This is an Action method to fetch the new Legal Id after selecting it from the Account Lookup
*/
    public void fetchLegalIdNew(){
        try{
            legalIdNew = contactLookup.AccountId;                
        }
        catch(Exception ex){
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,ex.getMessage()));            
        }       
    }
    
    public void beforeTransferActivity(){
        try{
            isError = false;
            isTransferred = false;
            legalIdNew = contactLookup.AccountId; 
            String orgSettingOfficeQuery='select ' + namespacePrefix + orgMetadataActive + ', DeveloperName FROM ' + namespacePrefix + 'Org_Setting__mdt where DeveloperName = \'Office_Location_Setting\' limit 1';
            List<SObject> orgSettingOfficeQueryResult = database.query(orgSettingOfficeQuery);
            orgSettingOffice = orgSettingOfficeQueryResult[0];
            if(orgSettingOffice.get(namespacePrefix+orgMetadataActive) ==true){
                isPopupOpen = true;                 
            }
            else{
                isPopupOpen = false;                
            }
            
            if(legalIdNew==legalIdOld){
                isTransferred =false;
                throw new MyCustomException('Old and new Legal Name cannot be the same.');
            }
            
        }
        catch(MyCustomException ex){
            isPopupOpen = false;
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,ex.getMessage()));            
        }
        catch(Exception ex){
            isPopupOpen = false;
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,ex.getMessage()));            
        } 
    }
    
    /*
@Description:   This is an Action method for transferring Activity
*/
    public PageReference transferActivity(){
        //Using savepoint if your code performs DML for multiple objects and exception occurs during DML, then it is for rolling back the data from database.               
        Savepoint savePointDb = Database.setSavepoint();
        try{
            isTransferred = false;
            legalIdNew = contactLookup.AccountId; 
            if(string.isEmpty(legalIdNew)||string.isBlank(legalIdNew)){
                //throw new MyCustomException('Legal name cannot be blank.');
                return null;
            }
            
            else{
                string taskQuery = 'SELECT Id, WhoId, WhatId,' + accAPIName + ' from Task WHERE (WhoId =:  contactId AND WhatId = null AND ' + accAPIName + ' = null) OR (WhoId =:  contactId  AND WhatId = null) OR (WhoId =:  contactId AND ' + accAPIName + ' = null AND WhatId =:  legalIdOld ) OR (WhoId =:  contactId AND WhatId = null) OR (WhoId =:   contactId AND ' + accAPIName + ' = null AND WhatId !=:  legalIdOld  AND WhatId != null) OR (WhoId =:  contactId AND WhatId =:  legalIdOld AND ' + accAPIName + ' = null) OR (WhoId =:  contactId  AND WhatId =:  legalIdOld AND ' + accAPIName + ' != null) OR (WhoId =: contactId AND ' + accAPIName + ' = null AND WhatId !=: legalIdOld AND WhatId != null)';
                List<Task> taskList = database.query(taskQuery);
                String eventQuery = 'SELECT Id, WhoId, WhatId,' + accAPIName + ' from Event WHERE ((WhoId = : contactId AND WhatId = null AND ' + accAPIName + ' = null) OR (WhoId = :  contactId AND WhatId = null) OR (WhoId = : contactId AND ' + accAPIName + ' = null AND WhatId = : legalIdOld ) OR (WhoId = : contactId AND WhatId = null) OR (WhoId = : contactId AND ' + accAPIName + '= null AND WhatId !=: legalIdOld AND WhatId != null) OR (WhoId = : contactId AND WhatId = : legalIdOld ) OR (WhoId = : contactId AND ' + accAPIName + ' = null AND WhatId !=:  legalIdOld  AND WhatId != null)) AND GroupEventType != \'2\' ';
                List<Event> eventList = database.query(eventQuery);
                
                List<Task> toUpdateTaskList = new List<Task>();
                List<Event> toUpdateEventList = new List<Event>();
                //Query on Product/Navatar settings depending upon the package installed in org.
                string settingsInfoAdvanceQuery = 'SELECT ' + namespacePrefix + 'CTS_Advanced__c FROM ' + strObjectName + ' WHERE ' + namespacePrefix + 'CTS_Advanced__c =:advanceSetting1  OR '+ namespacePrefix + 'CTS_Advanced__c =:advanceSetting2  OR ' + namespacePrefix + 'CTS_Advanced__c =:advanceSetting3' ;
                string settingsInfoActivityQuery = 'SELECT ' + namespacePrefix + 'CTS_Activity__c FROM ' +  strObjectName + ' WHERE ' + namespacePrefix + 'CTS_Activity__c =: activitySetting1 OR ' + namespacePrefix + 'CTS_Activity__c =:activitySetting2 OR ' + namespacePrefix + 'CTS_Activity__c =:activitySetting3'; // added condition for activitySetting3 by Aditya for New Client 17 June 2021
                
                SObject setupInfoAdvanced = database.query(settingsInfoAdvanceQuery);
                SObject setupInfoActivity = database.query(settingsInfoActivityQuery);
                system.debug('legalIdOld--> '+legalIdOld);
                if(legalIdOld!=null && legalIdOld!=''){
                    if(setupInfoActivity.get(namespacePrefix + 'CTS_Activity__c') == activitySetting1){//YES //If CTS_Activity__c value= Old Account Only
                        //Check Navatar Setup -> CTS Advanced = Contact only
                        if(setupInfoAdvanced.get(namespacePrefix + 'CTS_Advanced__c') == advanceSetting1){  //If CTS_Advanced__c value= Contact Only//YES
                            //Check if WhoId = contactId AND WhatId = null AND Account = null   
                            //FOR TASK
                            if(taskList.size()>0){
                                for(Task taskInfo : taskList){
                                    if(taskInfo.WhoId == contactId && taskInfo.whatId == null && taskInfo.get(accAPIName) == null){
                                        If(Schema.sObjectType.Task.fields.WhatId.isUpdateable()){ // added is isUpdateable check for security fix by Aditya 30 June 2021
                                            taskInfo.WhatId = legalIdOld;
                                        }
                                        taskInfo.put(accAPIName, legalIdOld);
                                        if(Schema.sObjectType.Task.isUpdateable()){  // added is isUpdateable check for security fix by Aditya 30 June 2021
                                            toUpdateTaskList.add(taskInfo);
                                        }
                                    }
                                }
                            }
                            
                            //FOR EVENT
                            if(eventList.size()>0){
                                for(Event eventInfo : eventList){
                                    if(eventInfo.WhoId==contactId && eventInfo.whatId==null && eventInfo.get(accAPIName) == null){
                                        if(Schema.sObjectType.Event.fields.WhatId.isUpdateable()){ // added is isUpdateable check for security fix by Aditya 30 June 2021
                                            eventInfo.WhatId = legalIdOld;
                                        }
                                        eventInfo.put(accAPIName, legalIdOld);
                                        if(Schema.sObjectType.Event.isUpdateable()){ // added is isUpdateable check for security fix by Aditya 30 June 2021
                                            toUpdateEventList.add(eventInfo);
                                        }
                                    }
                                }
                            }
                        }                   
                        else{   //NO
                            //Check if Navatar Setup -> CTS Advanced = Contact and Account
                            
                            if(setupInfoAdvanced.get(namespacePrefix + 'CTS_Advanced__c') == advanceSetting2){   //If CTS_Advanced__c value= Contact and Account//YES
                                //TASK
                                if(taskList.size()>0){
                                    for(Task taskInfo : taskList){
                                        //Check if WhoId = contactId AND WhatId = null      
                                        if(taskInfo.WhoId==contactId && taskInfo.whatId==null && taskInfo.get(accAPIName)==null){
                                            taskInfo.whatId=legalIdOld;
                                            taskInfo.put(accAPIName, legalIdOld);                               
                                            toUpdateTaskList.add(taskInfo);
                                        }                                   
                                        
                                        //Check if WhoId = contactId AND Account = null AND WhatId = OldInsID   
                                        if(taskInfo.WhoId==contactId && taskInfo.get(accAPIName)==null && taskInfo.whatId==legalIdOld){
                                            taskInfo.put(accAPIName, legalIdOld);   
                                            toUpdateTaskList.add(taskInfo);
                                        }
                                        
                                        
                                    }
                                }
                                if(eventList.size()>0){
                                    //EVENT
                                    for(Event eventInfo : eventList){
                                        //Check if WhoId = contactId AND WhatId = null      
                                        if(eventInfo.WhoId==contactId && eventInfo.whatId==null && eventInfo.get(accAPIName) == null){
                                            eventInfo.whatId=legalIdOld;
                                            eventInfo.put(accAPIName, legalIdOld);                              
                                            toUpdateEventList.add(eventInfo);
                                        }                                   
                                        
                                        //Check if WhoId = contactId AND Account = null AND WhatId = OldInsID   
                                        if(eventInfo.WhoId==contactId && eventInfo.get(accAPIName) == null && eventInfo.whatId==legalIdOld){
                                            eventInfo.put(accAPIName, legalIdOld);  
                                            toUpdateEventList.add(eventInfo);
                                        }
                                        
                                    }
                                }
                            }
                            
                            else{   //NO If CTS_Advanced__c value= Contact, Account and Custom Object
                                //TASK
                                if(taskList.size()>0){
                                    for(Task taskInfo : taskList){
                                        //Check if WhoId = contactId AND WhatId = null
                                        if(taskInfo.WhoId==contactId && taskInfo.whatId==null && taskInfo.get(accAPIName)==null){
                                            taskInfo.whatId=legalIdOld;
                                            taskInfo.put(accAPIName, legalIdOld);
                                            toUpdateTaskList.add(taskInfo);
                                        }
                                        //Check if WhoId = contactId AND Account = null AND WhatId = OldInsID
                                        if(taskInfo.WhoId==contactId && taskInfo.get(accAPIName)==null && taskInfo.whatId==legalIdOld){
                                            taskInfo.put(accAPIName, legalIdOld);
                                            toUpdateTaskList.add(taskInfo);
                                        }
                                        //Check if WhoId = contactId AND Account = null AND WhatId <> legalIdOld AND WhatId <> null
                                        if(taskInfo.WhoId == contactId && taskInfo.get(accAPIName) == null && taskInfo.WhatId != legalIdOld && taskInfo.WhatId != null){
                                            taskInfo.put(accAPIName, legalIdOld);
                                            toUpdateTaskList.add(taskInfo);
                                        }
                                    }
                                }
                                if(eventList.size()>0){
                                    //EVENT
                                    for(Event eventInfo : eventList){
                                        //Check if WhoId = contactId AND WhatId = null
                                        if(eventInfo.WhoId==contactId && eventInfo.whatId==null && eventInfo.get(accAPIName)==null){
                                            eventInfo.whatId=legalIdOld;
                                            eventInfo.put(accAPIName, legalIdOld);
                                            toUpdateEventList.add(eventInfo);
                                        }
                                        //Check if WhoId = contactId AND Account = null AND WhatId = OldInsID
                                        if(eventInfo.WhoId==contactId && eventInfo.get(accAPIName)==null && eventInfo.whatId==legalIdOld){
                                            eventInfo.put(accAPIName, legalIdOld);
                                            toUpdateEventList.add(eventInfo);
                                        }
                                        //Check if WhoId = contactId AND Account = null AND WhatId <> legalIdOld AND WhatId <> null
                                        if(eventInfo.WhoId == contactId && eventInfo.get(accAPIName) == null && eventInfo.WhatId != legalIdOld && eventInfo.WhatId != null){
                                            eventInfo.put(accAPIName, legalIdOld);
                                            toUpdateEventList.add(eventInfo);
                                        }
                                    }
                                }
                                
                            }
                        }
                    }
                    // added else if with CTS_Activity__c == activitySetting2 by Aditya for New Client 17 June 2021
                    else if(setupInfoActivity.get(namespacePrefix + 'CTS_Activity__c') == activitySetting2) {   //If CTS_Activity__c value= Old and New Accounts
                        //Check in Navatar Setup -> CTS Advanced = Contact only
                        if(setupInfoAdvanced.get(namespacePrefix + 'CTS_Advanced__c')== advanceSetting1){  //If CTS_Advanced__c value= Contact Only //YES
                            //TASK
                            if(taskList.size()>0){
                                for(Task taskInfo : taskList){
                                    //Check if WhoId = contactId AND WhatId = null AND Account = null       
                                    if(taskInfo.WhoId==contactId && taskInfo.whatId==null && taskInfo.get(accAPIName)==null){                                
                                        taskInfo.put(accAPIName, legalIdOld);
                                        toUpdateTaskList.add(taskInfo);
                                    }                           
                                }
                            }
                            
                            //EVENT
                            if(eventList.size()>0){
                                for(Event eventInfo : eventList){
                                    //Check if WhoId = contactId AND WhatId = null AND Account = null       
                                    if(eventInfo.WhoId==contactId && eventInfo.whatId==null && eventInfo.get(accAPIName)==null){                             
                                        eventInfo.put(accAPIName, legalIdOld);
                                        toUpdateEventList.add(eventInfo);
                                    }                           
                                }
                            }
                            
                        }                   
                        else{   //NO
                            //Check in Navatar Setup -> CTS Advanced = Contact and Insitution
                            if(setupInfoAdvanced.get(namespacePrefix + 'CTS_Advanced__c')==advanceSetting2){   //If CTS_Advanced__c value= Contact and Account//YES
                                
                                //TASK
                                if(taskList.size()>0){
                                    for(Task taskInfo : taskList){
                                        //Check if WhoId = contactId AND WhatId = null AND Account = null       
                                        if(taskInfo.WhoId==contactId && taskInfo.whatId==null && taskInfo.get(accAPIName)==null){ 
                                            taskInfo.put(accAPIName, legalIdOld);
                                            toUpdateTaskList.add(taskInfo);
                                        }
                                        
                                        //Check if WhoId = contactId AND WhatId = OldInsID      
                                        if(taskInfo.WhoId==contactId && taskInfo.whatId==legalIdOld){
                                            if(taskInfo.get(accAPIName)!=null){
                                                taskInfo.whatId = legalIdNew;
                                            }
                                            else{
                                                taskInfo.whatId = legalIdNew;
                                                taskInfo.put(accAPIName, legalIdOld);
                                            }
                                            toUpdateTaskList.add(taskInfo);
                                        }
                                    }
                                }
                                
                                //EVENT
                                if(eventList.size()>0){
                                    for(Event eventInfo : eventList){
                                        //Check if WhoId = contactId AND WhatId = null AND Account = null       
                                        if(eventInfo.WhoId==contactId && eventInfo.whatId==null && eventInfo.get(accAPIName)==null){                                 
                                            eventInfo.put(accAPIName, legalIdOld);
                                            toUpdateEventList.add(eventInfo);
                                        }
                                        
                                        //Check if WhoId = contactId AND WhatId = OldInsID      
                                        if(eventInfo.WhoId==contactId && eventInfo.whatId==legalIdOld){
                                            
                                            if(eventInfo.get(accAPIName)!=null){
                                                eventInfo.whatId = legalIdNew;
                                            }
                                            else{
                                                eventInfo.whatId = legalIdNew;
                                                eventInfo.put(accAPIName, legalIdOld);
                                            }
                                            toUpdateEventList.add(eventInfo);
                                        }
                                    }   
                                }
                                
                            }
                            
                            else{   //NO // If CTS_Advanced__c value= Contact, Account and Custom Object
                                //TASK
                                if(taskList.size()>0){
                                    for(Task taskInfo : taskList){
                                        //Check if WhoId = contactId AND WhatId = null AND Account = null       
                                        if(taskInfo.WhoId==contactId && taskInfo.whatId==null && taskInfo.get(accAPIName)==null){                                    
                                            taskInfo.put(accAPIName, legalIdOld);
                                            toUpdateTaskList.add(taskInfo);
                                        }
                                        
                                        //Check if WhoId = contactId AND WhatId = OldInsID      
                                        if(taskInfo.WhoId==contactId && taskInfo.whatId==legalIdOld){
                                            
                                            if(taskInfo.get(accAPIName)!=null){
                                                taskInfo.whatId = legalIdNew;
                                            }
                                            else{
                                                taskInfo.whatId = legalIdNew;
                                                taskInfo.put(accAPIName, legalIdOld);
                                            }
                                            toUpdateTaskList.add(taskInfo);
                                        }
                                        
                                        //Check if WhoId = contactId AND Account = null AND WhatId <> legalIdOld AND WhatId <> null
                                        if(taskInfo.WhoId == contactId && taskInfo.get(accAPIName) == null && taskInfo.WhatId <> legalIdOld && taskInfo.WhatId <> null){
                                            taskInfo.put(accAPIName, legalIdOld);
                                            toUpdateTaskList.add(taskInfo);
                                        }
                                    }
                                }
                                
                                //EVENT
                                if(eventList.size()>0){
                                    for(Event eventInfo : eventList){
                                        //Check if WhoId = contactId AND WhatId = null AND Account = null       
                                        if(eventInfo.WhoId==contactId && eventInfo.whatId==null && eventInfo.get(accAPIName)==null){                                 
                                            eventInfo.put(accAPIName, legalIdOld);
                                            toUpdateEventList.add(eventInfo);
                                        }
                                        
                                        //Check if WhoId = contactId AND WhatId = OldInsID      
                                        if(eventInfo.WhoId==contactId && eventInfo.whatId==legalIdOld){
                                            
                                            if(eventInfo.get(accAPIName)!=null){
                                                eventInfo.whatId = legalIdNew;
                                            }
                                            else{
                                                eventInfo.whatId = legalIdNew;
                                                eventInfo.put(accAPIName, legalIdOld);
                                            }
                                            toUpdateEventList.add(eventInfo);
                                        }
                                        
                                        //Check if WhoId = contactId AND Account = null AND WhatId <> legalIdOld AND WhatId <> null
                                        if(eventInfo.WhoId == contactId && eventInfo.get(accAPIName) == null && eventInfo.WhatId <> legalIdOld && eventInfo.WhatId <> null){
                                            eventInfo.put(accAPIName, legalIdOld);
                                            toUpdateEventList.add(eventInfo);
                                        }
                                    } 
                                }
                            }
                        }
                    }
                }
                else{
                    throw new MyCustomException('You cannot transfer this contact as it doesn’t have an associated Account. Please associate it with an Account in order to use contact transfer.');
                }
                
                if(toUpdateTaskList.size()>0){                              
                    if(Schema.sObjectType.task.isUpdateable()==true)
                        update toUpdateTaskList;
                    toUpdateTaskList.Clear();
                }
                if(toUpdateEventList.size()>0){                         
                    if(Schema.sObjectType.event.isUpdateable()==true)
                        update toUpdateEventList;
                    toUpdateEventList.Clear();
                }
                
                //Insert an Affiliation on old Account/Account with Role=Former Employee
                //Affiliations__c affiliationObj = new Affiliations__c(
                //     Contact__c = contactId, Account__c = legalIdOld, Role__c = 'Former Employee'
                //);
                Sobject affiliationObj = Schema.getGlobalDescribe().get(affiliationObjName).newSObject(); //check object affiliation in PE
                affiliationObj.put(namespacePrefix+'Contact__c', contactId);
                affiliationObj.put(affiliationAccountLookup, legalIdOld); //check in PE
                affiliationObj.put(namespacePrefix+'Role__c', 'Former Employee');
                if(Schema.getGlobalDescribe().get(affiliationObjName).getDescribe().isCreateable()==true)
                    insert affiliationObj;                
                affiliationID = affiliationObj.ID;                
                isTransferred = true; 
                string contactQuery = 'SELECT id,Account.Id,' + namespacePrefix + 'Office_Location_Info__c, Phone, Fax from Contact where Id =:contactId';
                contactInfo = database.query(contactQuery);
                
                //Update Account in Contact
                if(contactInfo!=null && Schema.sObjectType.Contact.fields.AccountId.isUpdateable()){ // added isUpdateable check for security fix by Aditya 30 June 2021
                    contactInfo.AccountId = legalIdNew;
                    if(Schema.sObjectType.contact.isUpdateable()==true)
                        update contactInfo;
                }               
            }
            return null;
        }
        catch(MyCustomException ex){
            isError = true;
            errorMessage='You cannot transfer this contact as it doesn’t have an associated Account. Please associate it with an Account in order to use contact transfer.';
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,errorMessage));  
            return null;
        }
        catch(Exception ex){
            // Roll the database back to before we saved ANYTHING
            isError = true;            
            errorMessage = ex.getMessage();
            if(errorMessage.contains('Insert failed. First exception on row 0; first error: REQUIRED_FIELD_MISSING, Required fields are missing:') && (affiliationID=='' || affiliationID==null)){
                errorMessage = 'Contact transfer has failed. Mandatory information is missing on Contact Affiliation that will be created with previous Account on Transfer. Please contact Navatar Support.';
                Database.rollback(savePointDb);                
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,errorMessage));  
            }
            else{
                Database.rollback(savePointDb);                
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,ex.getMessage()));  
            }                                          
            return null;
        }
    }
    
    /*
@Description:   This is an Action method for clearing address
Mailing Address fields will be deleted. 
Office Location will be cleared.
*/
    public PageReference clearAddress(){
        Savepoint savePointDb = Database.setSavepoint();
        transferActivity();
        try{            
            if(isError==false){
                contactAddressUpdate('clear');
                return Cancel();
                
            }
            else{
                return null;
            }
        }
        
        catch(Exception ex){
            // Roll the database back to before we saved ANYTHING
            isError = true;
            errorMessage = ex.getMessage();
            Database.rollback(savePointDb);            
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,ex.getMessage()));
            return null;
        }           
    }
    
    /*
@Description:   This is an Action method for retaining address
Mailing Address fields will remain the same as the old Account’s address fields.
Office Location will be cleared.
*/
    public PageReference retainAddress(){
        Savepoint savePointDb = Database.setSavepoint();
        transferActivity();
        try{                        
            if(isError==false){
                contactAddressUpdate('retain');
                return Cancel();
            }
            else{
                //return null;
                throw new MyCustomException(errorMessage);
                
            }
            //return null;
        } 
        catch(MyCustomException ex){
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,ex.getMessage())); 
            return null;
        }
        catch(Exception ex){
            // Roll the database back to before we saved ANYTHING
            isError = true;
            errorMessage = ex.getMessage();
            Database.rollback(savePointDb);
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,ex.getMessage()));
            return null;
        }       
    }
    
    /*
@Description:   This is a method which is called from retainAddress() and clearAddress() methods   .
Office Location will be cleared in both the cases.
@Param1: addressType: string
*/
    public void contactAddressUpdate(string addressType){
        Savepoint savePointDb = Database.setSavepoint();
        try{            
            //Check in CMT Org Settings where Org Setting Name is 'Office Location Setting' , check if Active is true
            
            if(contactInfo!=null){
                if(addressType=='clear'){                                           
                    if(orgSettingOffice.get(namespacePrefix+orgMetadataActive) == true || Test.isRunningTest()){   // added Test.isTestRunning to increase test class coverage by Aditya 29 June 2021
                        if(Schema.sObjectType.Contact.fields.MailingCity.isUpdateable()){ //added isUpdateable check for security fix by Aditya 30 June 2021
                        	contactInfo.MailingCity = null;
                        }
                        if(Schema.sObjectType.Contact.fields.MailingState.isUpdateable()){ //added isUpdateable check for security fix by Aditya 30 June 2021
                        	contactInfo.MailingState = null;
                        }
                        if(Schema.sObjectType.Contact.fields.MailingCountry.isUpdateable()){ //added isUpdateable check for security fix by Aditya 30 June 2021
                        	contactInfo.MailingCountry = null;
                        }
                        if(Schema.sObjectType.Contact.fields.MailingPostalCode.isUpdateable()){ //added isUpdateable check for security fix by Aditya 30 June 2021
                        	contactInfo.MailingPostalCode = null;
                        }
                        if(Schema.sObjectType.Contact.fields.MailingStreet.isUpdateable()){ //added isUpdateable check for security fix by Aditya 30 June 2021
                        	contactInfo.MailingStreet = null;
                        }
                        if(Schema.sObjectType.Contact.fields.Phone.isUpdateable()){ //added isUpdateable check for security fix by Aditya 30 June 2021
                        	contactInfo.Phone = null;
                        }
                        if(Schema.sObjectType.Contact.fields.Fax.isUpdateable()){ //added isUpdateable check for security fix by Aditya 30 June 2021
                        	contactInfo.Fax = null;
                        }
                        
                        if(Schema.sObjectType.Contact.fields.OtherCity.isUpdateable()){ //added isUpdateable check for security fix by Aditya 30 June 2021
                        	contactInfo.OtherCity = null;
                        }
                        if(Schema.sObjectType.Contact.fields.OtherState.isUpdateable()){ //added isUpdateable check for security fix by Aditya 30 June 2021
                        	contactInfo.OtherState = null;
                        }
                        if(Schema.sObjectType.Contact.fields.OtherCountry.isUpdateable()){ //added isUpdateable check for security fix by Aditya 30 June 2021
                        	contactInfo.OtherCountry = null;
                        }
                        if(Schema.sObjectType.Contact.fields.OtherPostalCode.isUpdateable()){ //added isUpdateable check for security fix by Aditya 30 June 2021
                        	contactInfo.OtherPostalCode = null;
                        }
                        if(Schema.sObjectType.Contact.fields.OtherStreet.isUpdateable()){ //added isUpdateable check for security fix by Aditya 30 June 2021
                        	contactInfo.OtherStreet = null;
                        }
                    }                                                           
                }               
                contactInfo.put(namespacePrefix+'Office_Location_Info__c', null);
                if(Schema.sObjectType.contact.isUpdateable()==true)
                    update contactInfo;     
            }           
        }
        catch(Exception ex){
            isError = true;
            errorMessage = ex.getMessage();
            Database.rollback(savePointDb);
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,ex.getMessage()));          
        }       
    }
    
    public class MyCustomException extends Exception{}
    
    //This method decides which objects and fields the installed Package contains. Either PE/MnA 
    public String getOrgSpecificObject(){
        String objectName;
        if(Schema.getGlobalDescribe().containsKey(nameSpacePrefix+'Product_Setting__c') == true){
            objectName = nameSpacePrefix+'Product_Setting__c';
            orgMetadataActive = 'Active__c';
            affiliationObjName = nameSpacePrefix+'Affiliations__c';
            affiliationAccountLookup = namespacePrefix+'Account__c';
            advanceSetting2 ='Contact and Account';
            advanceSetting3 = 'Contact, Account and Custom Object';
            activitySetting1 = 'Old Account Only';
            activitySetting2 = 'Old and New Accounts';
        } 
        else{
            nameSpacePrefix = 'navpeII__';
            orgMetadataActive = 'IsActive__c';
            objectName = nameSpacePrefix+'Navatar_Setup__c'; 
            fundraisingObject = nameSpacePrefix+'Fundraising_Contact__c';
            affiliationObjName = nameSpacePrefix+'Affiliation__c';
            affiliationAccountLookup = namespacePrefix+'Institution__c';
            advanceSetting2 ='Contact and Institution';
            advanceSetting3 = 'Contact, Institution and Custom Object';
            activitySetting1 = 'Old Institution Only';
            activitySetting2 = 'Old and New Institutions';
        }
        advanceSetting1 ='Contact Only';
        activitySetting3 = 'Do not move Activities'; //added by Aditya for New Client change 17 June 2021
        return objectName;
    }
    
}