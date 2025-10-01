/***********************************
** Module Name : Bulk Email
** Description : featch the Data from report object and send the mail to that contact
** Throws : NA
** Calls : NA
** Test Class :  
** Organization : Navatar Group
** Product Name & Version : PE 3.5
** Revision History:-
** Version    Date            Author 
   3.5        15-July-2016    Rajnish 
   4.7.2      9-November-2022 Salauddin      
*************************************/

public with sharing class BulkEmail_Ctlr implements Database.Batchable<sObject>, Database.Stateful
{

   
    public String namspace{get;set;}                     
    public string propId{get;set;}                       
    public string locale_info{get;set;}                  
    string ids;                                              
    set<string> myString = new Set<String>();            
    public string rportsfoldername{get;set;}             
    public String createtrees{get;set;}                  // Tree struct variable    
    public string id1{get;set;}                          
    private Set<Id> folderOtherIds = new Set<Id>();      
    private Set<Id> folderListIds = new Set<Id>();       
    public String headermsg{get;set;}                    // Set the header message
    public boolean sendingFailed {get; set;}             // Send Email status
    public String contactIDString {set;get;}             // contact ids in list 
    public String errormsgfrTrigger{get;set;}            // Error message variable if error come at time trigger fair
    public string TempID {get;set;}                      // To get Template's value
    public String MassemailName {get;set;}               // To store Mass Emal Name
    public boolean chkStoreActivity{get;set;}            // Checkbox value of Store Activity at Step 3
    public boolean use_My_Signature {get; set;}          //To store use_My_Signature checkbox value true/false
    public boolean bCC_Me_On_One {get; set;}             //To store bCC_Me_On_One checkbox value true/false  
    public String successmsgTrigger{get;set;}            
    public List<emailingTemplate> emailingTemplates {get; set;}  
    private Map<Id, Folder> folderMap;                   //This is map to fetch all ids of email folders.
    public String user_locale{get; set;}                 // for get localae value..
    public string NameSpacePrefix{get; set;}             // define the namespace
    public boolean ErrorStatus{get;set;}                 // get the Errorstatus
    public string headerVal{get;set;}                     //To et selected grid column Header's value
    public list<user> user_info{get;set;}                 //To store current user id 
    public String folderId {get; set;}                    //To store selected folder id 
    public fund__c fundDetails{get;set;}                   //To store selected fund id     
    public string id2{get;set;}                           //To store Marketing Initiative id from the url   
    public integer MailCount{get;set;}                    // How many contact send the mail 
    public boolean isbcc {get; set;}
    public boolean isEmailValidate{get; set;}
    public string assineSelectedConids{get; set;}
    public string EmailConIds{get;set;}
    public integer validateEmailCount{get;set;} 
    public boolean isActiveBulkEmail{get;set;}
    
    public String[] arryServarUrl;
    public string strSourceLoc{get;set;} 
    public string SourceId{get;set;}
    
    public BulkEmail_Ctlr() 
    {
        try
        {  
            isActiveBulkEmail=false;
            chkStoreActivity=true;
            isEmailValidate=false;
            user_locale = UserInfo.getLocale();
            isbcc=true;           
            NameSpacePrefix=CommonUtility.strNameSpacePrefix;
            if(Schema.sObjectType.Org_Setting__mdt.isAccessible() && Schema.sObjectType.Org_Setting__mdt.fields.IsActive__c.isAccessible() && Schema.sObjectType.Org_Setting__mdt.fields.label.isAccessible() && Schema.sObjectType.Org_Setting__mdt.fields.DeveloperName.isAccessible()){
                List < Org_Setting__mdt > lstbulkemail = [SELECT IsActive__c,label FROM Org_Setting__mdt  where DeveloperName= 'Bulk_Email_Setting' AND IsActive__c = true limit 1];   
                if(lstbulkemail.size() > 0)
                {
                    isActiveBulkEmail=true;
                } 
            }           
            ErrorStatus = true; 
            String browserType='';  
            browserType = Apexpages.currentPage().getHeaders().get('USER-AGENT'); //gets the browser name and detail
            if( browserType!=null)
            if(browserType.contains('MSIE') )
            Apexpages.currentPage().getHeaders().put('X-UA-Compatible','IE=9');  //sets the type to IE9 for every version of 
            bCC_Me_On_One = false;
            use_My_Signature = false;
            headerVal='contact__r.LastName';
            errormsgfrTrigger='';    
            successmsgTrigger='';       
            string user_id=Userinfo.getUserId();
            user_info=[select LocaleSidKey from user where id=:user_id];
            locale_info = UserInfo.getLocale();      
            MassemailName = '';
            String conName,conAccounName,ConphoneNo,Conemail;
            emailingTemplates = new List<emailingTemplate>();     // Alphabets character for searching in the grid            
            id1 = apexpages.currentpage().getparameters().get('retURL');
            
            if(Schema.sObjectType.Folder.isAccessible() && Schema.sObjectType.Folder.fields.name.isAccessible() && Schema.sObjectType.Folder.fields.Type.isAccessible()){
                folderMap = new Map<Id, Folder>( [Select id , name from Folder where Type = 'email']);            
            }
            
            this.ETData();      
        }      
        catch(exception ex)
        {
            ErrorStatus = false; 
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,'Fund ID Or Account ID missing can not load this page.!!!'));
        } 
        createreporttree();
    }

    //@featch the folder name where rport contain    
    public string retrievenames()
    {
        set<string> fldrnames=new set<string>();
        try
        {
            list<report> lstReport =new list<report>();
            // Added for Security issue by Qadir Khan 07 DEC 2017..
            if(Schema.sObjectType.report.isAccessible() && Schema.sObjectType.report.fields.FolderName.isAccessible()){
                lstReport = [select FolderName from report order by FolderName asc];
            }
            for(report renames:lstReport)
            {
                fldrnames.add(renames.FolderName);
            }
            String fldername=json.serialize(fldrnames);
            return fldername;
        }
        catch(exception ex)
        {
            string errormsgget = ex.getMessage();
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,errormsgget));
            return null;  
        }
    }
            
    //@create the tree of folder of report        
    public void createreporttree()
    {
        map<string,list<list<string>>> mapofreports=new map<string,list<list<string>>>();  
        list<report> lstReports =new list<report>();
        if(Schema.sObjectType.report.isAccessible() && Schema.sObjectType.report.fields.FolderName.isAccessible() && Schema.sObjectType.report.fields.name.isAccessible())
            lstReports=[select id,name,foldername from report order by name Asc LIMIT:(Limits.getLimitQueryRows() - Limits.getQueryRows()) ];
        for(Report reportdara:lstReports) //(PE3.5, SK, 16Aug2017): added limit clause
        {
           
            list<string> reporlist=new list<string>();
            reporlist.add(reportdara.id);
            reporlist.add(reportdara.name);
            
            try{
                if(mapofreports.get(reportdara.foldername).size()>0){
                    list<list<string>> listdata=mapofreports.get(reportdara.foldername);
                    listdata.add(reporlist);
                    mapofreports.put(reportdara.foldername,listdata);
                }
                else{
                    list<list<string>>  listdata=new list<list<string>>();
                    listdata.add(reporlist);
                    mapofreports.put(reportdara.foldername,listdata);
                }
            }
            catch(exception ex){
                list<list<string>> listdatas=new list<list<string>>();
                listdatas.add(reporlist);
                mapofreports.put(reportdara.foldername,listdatas);                    
            }
        
        }
        createtrees='[';
        string createtree;
        for(string maps:mapofreports.keyset())
        {                    
            createtree='{id:"",text:"'+CommonUtility.replaceChars(maps)+'",cls:"",leaf:false,checked:null,expanded:true,children:[';
            string child='';    
            for(List<String> aa:mapofreports.get(maps))
            {            
            child =child+ '{id:"'+aa.get(0)+'",text:"'+CommonUtility.replaceChars(aa.get(1))+'",cls:"",leaf:true,checked:null,expanded:false},';                 
            }   
            createtree=createtree+child;
            createtree=createtree.removeEnd(',');
            createtree=createtree+']},';                    
            createtrees= createtrees+createtree;              
        }
        createtrees=createtrees.removeEnd(',');
        createtrees=createtrees+']'; 
                     
    }            
    
    
   //@  fetch the data based on reportid and report body    
   @RemoteAction
    public static String reportresponse(string reportid,string body,string counter)
    {
        try
        { 
            string responsestring;
            String sfdcBaseURL = URL.getSalesforceBaseUrl().getHost();
         
            if(counter != '1')
            {
                string EndUrl = 'https://'+sfdcBaseURL+'/services/data/v34.0/analytics/reports/'+reportId;
                HttpRequest req=new HttpRequest();                
                req.setEndPoint(EndUrl);               
                req.setHeader('Authorization',  'Bearer '+UserInfo.getSessionId());     
                req.setMethod('POST');
                req.setHeader('content-type', 'application/json');
                req.setBody(body);
                Http reqs=new Http();
                HttpResponse resp=reqs.send(req);               
                responsestring=resp.getBody(); 
                
               
            }
            else 
            {              
                string EndUrl = 'https://' + sfdcBaseURL + '/services/data/v34.0/analytics/reports/'+reportId;
                HttpRequest req = new HttpRequest();
                req.setEndPoint(EndUrl);
                req.setHeader('Authorization', 'Bearer ' + UserInfo.getSessionId());
                req.setMethod('GET');
                req.setHeader('content-type', 'application/json');
                Http reqs = new Http();
                HttpResponse resp = reqs.send(req);
                responsestring = resp.getBody();
               
            }           
            return responsestring;              
        }
        
        catch(exception e)
        {           
            string errormsgget = e.getMessage();
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,errormsgget));
            return null;      
        }
     
    } 
    
            
    // Inner class to get emailTemplates Properties
    class emailingTemplate
    { 
        public boolean isSelected {get; set;}
        public String templateId {get; set;}
        public String Name {get; set;}
        public String TemplateType {get; set;}
        public String Description {get; set;}
    }

        
    //Redirect page to Marketing Initative Detail Page 
    public Pagereference cancel()
    { 
        try
        {
          //  Pagereference pageRef= new Pagereference(id1);
            id1 = apexpages.currentpage().getparameters().get('retURL'); 
            Pagereference pageRef= new Pagereference(id1);
            pageRef.setredirect(true);
           return pageRef;
        }
        catch(exception ex)
        {         
            string errormsgget = ex.getMessage();
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,errormsgget));
            return null;    
        }
     } 
        
   //@Method to get name TemplateType Description FolderId from emailTemplate
    public void ETData()
    {
        try
        { 
            list<emailTemplate> lstemailTemplate =new list<emailTemplate>();
            if(Schema.sObjectType.emailTemplate.isAccessible() && Schema.sObjectType.emailTemplate.fields.name.isAccessible() && Schema.sObjectType.emailTemplate.fields.TemplateType.isAccessible() && Schema.sObjectType.emailTemplate.fields.Description.isAccessible() && Schema.sObjectType.emailTemplate.fields.FolderId.isAccessible())
                lstemailTemplate = [select name, TemplateType, Description, FolderId from emailTemplate Order by name LIMIT:(Limits.getLimitQueryRows() - Limits.getQueryRows()) ];
            for(emailTemplate e : lstemailTemplate) //(PE3.5, SK, 16Aug2017): added limit clause
            {
                if(!folderListIds.contains(e.FolderId))
                {
                    folderListIds.add(e.FolderId);
                }
                emailingTemplate tempE = new emailingTemplate();
                tempE.templateId = e.Id;
                tempE.Name = e.name;
                tempE.isSelected = false;
                tempE.TemplateType = e.TemplateType;
                tempE.Description = e.Description;            
                emailingTemplates.add(tempE);
            }
            for(Folder f : folderMap.values())
            {
                if(!folderListIds.contains(f.id))
                {
                    folderListIds.add(f.Id);
                }
            }
            getItems();
        }
        catch(Exception e)
        {
            string errormsgget = e.getMessage();
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,errormsgget));          
        }
       
    }
        
    //@show email template according to selaeted email template folder
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
            }
            else
            {
                options.add(new SelectOption(folderMap.get(f).id, folderMap.get(f).name));
            }
        }
        if(folderMap.size() > 0)
        {
            options.add(new SelectOption('Others', 'Others'));
        }
        return options;
    } 

   //@return Folder list
    public Set<Id> getfolderListIds()
    {
        return folderListIds;
    }

    //@return Folder list
    public Set<Id> getfolderOtherIds()
    {
        return folderOtherIds;
    }
    //4.7.2 converting method logic to Batch Class
    public Pagereference sendmassmail()
    { 
        contactIDString = assineSelectedConids;
        Set<String> contactList =new Set<String>();
        for(String idStr : contactIDString.split(',')){

            contactList.add(idStr);
        }
        Database.executeBatch(new BulkEmail_Ctlr(contactList, tempId, use_My_Signature, chkStoreActivity, bCC_Me_On_One), 5);
        return null;
    }

   @RemoteAction
   public static String GetEmailLimit()   
   {
        
        string emailString;
        String sfdcBaseURL = URL.getSalesforceBaseUrl().getHost(); 
        string EndUrl = 'https://'+sfdcBaseURL +'/services/data/v36.0/limits';
        //string EndUrl = 'https://'+instanc[1]+'.salesforce.com/services/data/v36.0/limits';
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
   
   
    public void chkEmail()
    {
        isEmailValidate=false;
        Set<Id> conidset = new Set<Id>(); // set of selaeted contactids
        integer count=0;
        
        try
        {            
            for(string strConId : assineSelectedConids.split(','))
            {     
                conidset.add(strConId); 
                count++;                
            } 
            if(Schema.sObjectType.Contact.isAccessible() && Schema.sObjectType.Contact.fields.HasOptedOutOfEmail.isAccessible() && Schema.sObjectType.Contact.fields.Email.isAccessible())
            {
                Map<Id, Contact> MapConIds = new Map<Id, Contact>([SELECT Id FROM Contact where Id In:conidset and HasOptedOutOfEmail =false and Email!=null]);
                validateEmailCount= MapConIds.size();
                if(count== MapConIds.size())
                {           
                    isEmailValidate=true;
                }
                else
                {               
                    isEmailValidate=false;
                }           
            }
        }
        catch(System.emailException e)
        {           
           ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,' '+e.getMessage()));
        }
        
    }     
    public Set<String> contactList = new Set<String>();
    public Integer senderCount = 0;
    public Integer failedRecCount = 0;
    public String errorLog = 'Record Id, Name, Error \n' ;
    public BulkEmail_Ctlr(Set<String> contactList, String tempId,Boolean use_My_Signature, Boolean chkStoreActivity, Boolean bCC_Me_On_One){
        this.contactList = contactList;
        this.tempId = tempId;
        this.use_My_Signature = use_My_Signature;
        this.chkStoreActivity = chkStoreActivity;
        this.bCC_Me_On_One = bCC_Me_On_One;
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
                message.setUseSignature(use_My_Signature);              
                message.setSaveAsActivity(chkStoreActivity);
                if(contactList.contains(conRec.Id)){
                    message.setWhatId(conRec.Id);
                }
                if(bCC_Me_On_One==true && isbcc==true)
                {
                    message.setBccSender(bCC_Me_On_One);
                }                
                else if(bCC_Me_On_One==false)
                {
                    message.setBccSender(bCC_Me_On_One);
                }                       
                messages.add(message);                
                isbcc=false;  
                contactIds.add(conRec.Id);
            }
            Messaging.SendEmailResult[] results = Messaging.sendEmail(messages,false);
            for(Messaging.SendemailResult currentResult : results){
                if(!currentResult.isSuccess()){
                    String erroLog = currentResult.getErrors()[0].getTargetObjectId()+','+conIdVsContacts.get(currentResult.getErrors()[0].getTargetObjectId()).Name+','+json.serialize(currentResult.getErrors().get(0).getMessage()).replaceAll(',', ';')+'\n';
                    errorLog = errorLog +erroLog;
                    failedRecCount++;
                }
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
            notificationEmail.setSubject('Bulk Email Notification');
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