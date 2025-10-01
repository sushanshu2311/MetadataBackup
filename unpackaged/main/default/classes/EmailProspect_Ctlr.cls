/*************************************************
********************************
** Module Name : EmailProspect_Ctlr
** Description : Listed Below
    1. Making sObject Describe Calls and return Field Labels with API Names.
    2. Create sObject Icon URL, and return sObjectVsIconURL.
    3. Get & return NameSpace from Org.
** Throws : NA
** Calls : NA
** Organization : Navatar Group
** Product Name & Version : PE 3.5
** Revision History:-
** Version Date         Author              Description of Action
** 3.5     06/06/2016   Faizan Nusrat 
**         2022-02-22   Lakshya Kanchan     Added batch class related code to send emails in batch
*************************************************
********************************/
public with sharing class EmailProspect_Ctlr implements Database.Batchable<sObject>, Database.Stateful
{
    public String MIid{get;set;}
    public boolean ErrorStatus{get;set;}            // get the Errorstatus
    public List<Marketing_Initiative__c> MIlist{get;set;}
    public string proptxtdata{get;set;}
    public boolean ErrorStatusInsufficient{get;set;}   // for ID in URL
    public string ErrorVal{get;set;}
    public string MIName{get;set;}
    public string locale_info{get;set;}  //TO store locale information
    public string user_locale{get;set;}  // To get locale value
    Public string folderId{get;set;}  //To store selected folder id
    private Set<Id> folderListIds = new Set<Id>();  //List of all folders's ids
    public List<emailingTemplate> emailingTemplates {get; set;}  // public Boolean emailSendStatus{get;set;}
    private Map<Id, Folder> folderMap;   //This is map to fetch all ids of email folders.
    private Set<Id> folderOtherIds = new Set<Id>(); 
    public boolean isSendingFailed{get;set;}
    public boolean isCurrency{get;set;}
    public string fundid{get;set;}
    public string localeString{get;set;}  /*variable  to check locale of the user  */
    public string tempId{get;set;}  //To get Template's value
    public boolean isBCC_Me_On_One {get; set;}  //To store isBCC_Me_On_One checkbox value true/false
    public boolean isUse_My_Signature {get; set;}  //To store isUse_My_Signature checkbox value true/false
    public boolean isbcc {get; set;}
    //public String MassemailName {get; set;}  //To store Mass Emal Name
    public String errormsgfrTrigger{get;set;}
    public String headermsg{get;set;} // Set the header message
    public String contactIDString {set;get;} 
    public string uithemes{get;set;}
    public boolean isSuccessmsgTrigger{get;set;}  // Set the error message
    public Boolean Store_as_an_activity {get; set;}  //  Checkbox value of Store Activity
    //public String MarProId {get;set;} 
    public boolean urlNotExist{get;set;}
     public string returnURL{get;set;}
    public String Namespaceprefix1_new {get;set;}
    public string strCurrencySystembol{get;set;}/*variable  to check default currency of the user  */
    public string instanceNames {get;set;}
    public string keyprfx{get;set;}
    /*
    @Description: EmailProspect_Ctlr constructor .
    */
    public EmailProspect_Ctlr (ApexPages.StandardSetController controller) 
    {
        try
        {
            folderMap = new Map<Id, Folder>();
            isSuccessmsgTrigger=false;
            strCurrencySystembol = UserInfo.getDefaultCurrency();
            localeString=UserInfo.getLocale();
            emailingTemplates = new List<emailingTemplate>();
            instanceNames = [select InstanceName from Organization limit 1].InstanceName;
            keyprfx=Marketing_Initiative__c.sobjecttype.getDescribe().getKeyPrefix();
            
            isbcc=true;
            ErrorStatus = true;
            ErrorStatusInsufficient= false;
            isUse_My_Signature = false;
            locale_info = UserInfo.getLocale();
            locale_info = UserInfo.getLocale();
            uithemes = UserInfo.getUiThemeDisplayed();
            Namespaceprefix1_new = CommonUtility.strNameSpacePrefix;
            // Added by sameer Security issue
            id MIid_temp = ApexPages.currentPage().getParameters().get('id'); 
            MIid= string.valueOf(MIid_temp);
            //MIid= ApexPages.currentPage().getParameters().get('id'); 
            returnURL= apexpages.currentpage().getparameters().get('retURL');
            if(Schema.sObjectType.Marketing_Initiative__c.isAccessible() && Schema.sObjectType.Marketing_Initiative__c.fields.name.isAccessible())
                MIlist=[Select id,name from Marketing_Initiative__c where id=:MIid];
            if(MIlist.size() > 0)
            {
                MIName=MIlist[0].Name;
            }
            isCurrency= Schema.getGlobalDescribe().containsKey('CurrencyType');
            if(Schema.sObjectType.Folder.isAccessible() && Schema.sObjectType.Folder.fields.name.isAccessible() && Schema.sObjectType.Folder.fields.Type.isAccessible())
                folderMap = new Map<Id, Folder>( [Select id , name from Folder where Type = 'Email']);
            if(folderMap.size() > 0){}
                    
            if(MIid== null || MIid== '')
            {   
                ErrorStatusInsufficient= true;
            }
            
            this.ETData();
        }
        catch(exception ex)
        {
            ErrorStatusInsufficient=true;
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,'MI ID missing can not load this page.!!!'));
        }
    }
    
    /*
    @Description: Inner class to get emailTemplates Properties.
    */
    class emailingTemplate
    { 
        public boolean isSelected {get; set;}
        public String templateId {get; set;}
        public String Name {get; set;}
        public String TemplateType {get; set;}
        public String Description {get; set;}
    }
    
    /*
    @Description: This method is getting the Template Name, Id, Type and Description from emailTemplate Limit taken is 100.
    */
    public void ETData()
    { 
        //Added By Qadir Khan for PE 3.5 08 DEC 2017.
        list<emailTemplate> lstEmailTemp = new list<emailTemplate>();
        if(Schema.sObjectType.emailTemplate.isAccessible() && Schema.sObjectType.emailTemplate.fields.name.isAccessible() && Schema.sObjectType.emailTemplate.fields.TemplateType.isAccessible() && Schema.sObjectType.emailTemplate.fields.Description.isAccessible() && Schema.sObjectType.emailTemplate.fields.FolderId.isAccessible()){
            lstEmailTemp = [select name, TemplateType, Description, FolderId from emailTemplate Order by name limit 100];
        }
        for(emailTemplate e : lstEmailTemp)
        {
            if(!folderListIds.contains(e.FolderId))
            folderListIds.add(e.FolderId);
            emailingTemplate tempE = new emailingTemplate();
            tempE.templateId = e.Id;
            tempE.Name = e.name;
            tempE.isSelected = false;
            tempE.TemplateType = e.TemplateType;
            tempE.Description = e.Description;            
            emailingTemplates.add(tempE);
        }
        for(Folder f : folderMap.values())
            if(!folderListIds.contains(f.id))
            folderListIds.add(f.Id);       
    }
    
    /*
    @Description: This List contains the email templates according to folder selected.
    */
    public List<SelectOption> getItems()
    {        
        List<SelectOption> options = new List<SelectOption>();
        folderOtherIds = new Set<Id>();
        options.add(new SelectOption('All', 'All'));
        for(String f : folderListIds)
        {
            if(folderMap.get(f) == null)
            {
                folderOtherIds.add(f);
            }else
                options.add(new SelectOption(folderMap.get(f).id, folderMap.get(f).name));
        }
        if(folderMap.size() > 0)
            options.add(new SelectOption('Others', 'Others'));
        return options;
    } 
    
    public Set<Id> getfolderListIds()
    {
        return folderListIds;
    }
    
    public Set<Id> getfolderOtherIds()
    {
        return folderOtherIds;
    }
    
    /*
    @Description: Method to send mass mail.
    */
    public string selectedContact{get;set;}
    //Modified by Lakshya on 2022-02-28 to implement batch class
    public PageReference sendmassmail(){
        isSendingFailed = false;
        errormsgfrTrigger = '';
        headermsg = '';
        contactIDString = selectedContact;
        isSuccessmsgTrigger = true;
        Map<String, String> conIdVsWhatIdMap = new Map<String, String>();
        for(String idStr : contactIDString.split(',')){
            String whatId = idStr.split('@@')[0];
            String conId = idStr.split('@@')[1];
            conIdVsWhatIdMap.put(conId, whatId);
        }
        Database.executeBatch(new EmailProspect_Ctlr(conIdVsWhatIdMap, tempId, isUse_My_Signature, Store_as_an_activity, (isBCC_Me_On_One == true && isbcc == true)), 5);
        return null;
    }
    
    /*
    @Description: Redirect page to Marketing Initative Detail Page.
    */    
    public Pagereference cancel()
    { 
        try
        {
            Pagereference pageRef= new Pagereference('/'+MIid);
            pageRef.setredirect(true);
            return pageRef;
        }
        catch(exception ex)
        {         
          return null;
        }
    }

    @RemoteAction
    public static String GetEmailLimit()   
    {
        try
        {
            string emailString='';       
            string EndUrl = 'https://'+URL.getSalesforceBaseUrl().getHost()+'/services/data/v36.0/limits';
            HttpRequest req=new HttpRequest();          
            req.setEndPoint(EndUrl);            
            req.setHeader('Authorization',  'Bearer '+UserInfo.getSessionId());                
            req.setMethod('GET');
            req.setHeader('content-type', 'application/json');          
            Http reqs=new Http();
            HttpResponse resp=reqs.send(req);
            emailString=resp.getBody();                      
            return emailString; 
        }
        catch(exception e)
        {            
            string errormsgget = e.getMessage();
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,errormsgget));
            return null;      
        }       
    }
    //Added below code by Lakshya on 2022-02-28 to implement batch apex
    public Set<String> contactList = new Set<String>();
    public Map<String, String> conIdVsWhatIdMap = new Map<String, String>();
    public Integer senderCount = 0;
    public Integer failedRecCount = 0;
    public String errorLog = 'Record Id, Name, Error \n' ;
    public EmailProspect_Ctlr(Map<String, String> conIdVsWhatIdMap, String tempId, Boolean isUse_My_Signature, Boolean Store_as_an_activity, Boolean isBCC_Me_On_One){
        this.conIdVsWhatIdMap = conIdVsWhatIdMap;
        this.contactList = conIdVsWhatIdMap.keySet();
        this.tempId = tempId;
        this.isUse_My_Signature = isUse_My_Signature;
        this.Store_as_an_activity = Store_as_an_activity;
        this.isBCC_Me_On_One = isBCC_Me_On_One;
    }
    
    public Database.QueryLocator start(Database.BatchableContext bc){
        String query = 'SELECT Id, Name FROM Contact WHERE Id IN:contactList AND HasOptedOutOfEmail = false AND Email!=null AND IsEmailBounced = false';
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext bc, List<Contact> contacts){
        try{
            senderCount +=contacts.size();
            Map<Id, Contact> conIdVsContacts = new Map<Id, Contact>(contacts);
            Messaging.SingleEmailMessage[] messages = new List<Messaging.SingleEmailMessage>();
            Set<Id> contactIds = new Set<Id>();
            for (Contact conRec : contacts){
                Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
                message.setTemplateId(tempId);
                message.setTargetObjectId(conRec.Id);
                message.setWhatId(conIdVsWhatIdMap.get(conRec.Id));
                message.setUseSignature(isUse_My_Signature);
                message.setSaveAsActivity(Store_as_an_activity);
                message.setBccSender(isBCC_Me_On_One);
                messages.add(message);
                isBCC_Me_On_One = false;
                contactIds.add(conRec.Id);
            }
            Messaging.SendEmailResult[] results = Messaging.sendEmail(messages,false);

            Map<ID, navpeII_dev18__Marketing_Prospect__c> updateConIdVsRecMap = new Map<ID, navpeII_dev18__Marketing_Prospect__c>();
            for(navpeII_dev18__Marketing_Prospect__c mp : [SELECT Id, Name, navpeII_dev18__Contact__c, navpeII_dev18__Last_Mass_Email__c FROM navpeII_dev18__Marketing_Prospect__c WHERE navpeII_dev18__Contact__c IN: contactIds]){
                mp.navpeII_dev18__Last_Mass_Email__c = System.now();
                updateConIdVsRecMap.put(mp.navpeII_dev18__Contact__c, mp);
            }

            for(Messaging.SendemailResult currentResult : results){
                if(!currentResult.isSuccess()){
                    String erroLog = currentResult.getErrors()[0].getTargetObjectId()+','+conIdVsContacts.get(currentResult.getErrors()[0].getTargetObjectId()).Name+','+json.serialize(currentResult.getErrors().get(0).getMessage()).replaceAll(',', ';')+'\n';
                    errorLog = errorLog +erroLog;
                    failedRecCount++;
                    updateConIdVsRecMap.remove(currentResult.getErrors()[0].getTargetObjectId());
                }
            }
            if(updateConIdVsRecMap.size() > 0){
                DataBase.SaveResult[] srUPDMPS = DataBase.update(updateConIdVsRecMap.values(),false);
            }
        }
        catch(System.emailException e){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,' '+e.getMessage()));
        }
    }

    public void finish(Database.BatchableContext bc){
        AsyncApexJob currentBatch = [Select Id, Status from AsyncApexJob where Id = :bc.getJobId()];
        
        User u = [SELECT Id,Name FROM User WHERE Id=:userinfo.getUserId()];

        if(currentBatch.Status == 'Completed'){
            Messaging.SingleEmailMessage notificationEmail = new Messaging.SingleEmailMessage();
            notificationEmail.setSubject('Email Prospects Notification');
            notificationEmail.setBccSender(false);
            notificationEmail.setUseSignature(false);
            notificationEmail.setToAddresses(new String[] {u.Id});
            if(failedRecCount > 0){
                Messaging.EmailFileAttachment csvAttc = new Messaging.EmailFileAttachment();
                csvAttc.setFileName('FailedContacts.csv');
                csvAttc.setBody(Blob.valueOf(errorLog));
                notificationEmail.setFileAttachments(new Messaging.EmailFileAttachment[]{csvAttc});
                if(failedRecCount == senderCount){
                    notificationEmail.setPlainTextBody('Your bulk email request has been processed. Email could not be sent to '+failedRecCount+' recipient(s). Please refer to the attached issues file for more details.\n\nThanks');
                } else {
                    notificationEmail.setPlainTextBody('Your bulk email request has been processed. Emails have been sent successfully to '+(senderCount-failedRecCount)+' recipient(s) but could not be sent to '+failedRecCount+' recipient(s). Please refer to the attached issues file for more details.\n\nThanks');
                }
            } else {
                notificationEmail.setPlainTextBody('Your bulk email request has been processed. Emails have been sent successfully to '+(senderCount-failedRecCount)+' recipient(s).\n\nThanks');
            }
            Messaging.SendEmailResult[] results = Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{notificationEmail},false);
        }    
    }
}