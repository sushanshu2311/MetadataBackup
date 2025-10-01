/***********************************
** Module Name : MassEmail_CC_ID
** Description : This class is used to handle SendMassMail component to send email in Bulk.
** Throws : NA
** Calls : NA
** Test Class :  
** Organization : Navatar Group
** Product Name & Version : PE 3.5 
** Revision History:- 
** Version     Date            Author 
   3.5         04-July-2016    Lalit
*************************************/

public with sharing class MassEmail_DD_FD{
    
    public string selectedFolderId{get;set;}
    public Set<Id> folderListIds {get;set;} 
    private Map<Id, Folder> folderMap; 
    public boolean successmsgTrigger{get;set;}
    public boolean isbcc {get; set;}
    public boolean bCC_Me_On_One {get; set;}
    public boolean use_My_Signature {get; set;}
    public List<emailingTemplate> emailingTemplates {get; set;}
    public Set<Id> folderOtherIds {get;set;}
    public string returnURL{get;set;}
    public boolean Store_as_an_activity{get;set;}
    
    public boolean sendingFailed{get;set;}
    public string fundid{get;set;}
    public string tempId{get;set;}   
    public boolean isCurrency{get;set;}
    public string strCurrencySystembol{get;set;}/*variable  to check default currency of the user  */
    public string localeString{get;set;}  /*variable  to check locale of the user  */
    public string locale_info{get;set;}  //TO store locale information
    public string user_locale{get;set;}  // To get locale value
    public boolean ErrorStatusInsufficient{get;set;}
    public boolean urlNotExist{get;set;}
    public string pageN{get;set;}
    public string strRecordId{get;set;}
   
    public MassEmail_DD_FD()
    {
        try
        {
         folderListIds = new Set<Id>();
         folderOtherIds =new Set<Id>();
         successmsgTrigger=false;
         ErrorStatusInsufficient= false;
         isCurrency= Schema.getGlobalDescribe().containsKey('CurrencyType');
         strCurrencySystembol = UserInfo.getDefaultCurrency();
         localeString=UserInfo.getLocale();
         locale_info = UserInfo.getLocale();
         user_locale = UserInfo.getLocale();
         string id= ApexPages.currentpage().getparameters().get('id');
         strRecordId = ApexPages.currentpage().getparameters().get('id');
         returnURL= '/'+id;
         emailingTemplates = new List<emailingTemplate>();
         isbcc=true;
         use_My_Signature = false;
         
         // SK: 7Dec2017
         if( Schema.sObjectType.Folder.isAccessible() && Schema.sObjectType.Folder.Fields.Name.isAccessible() && Schema.sObjectType.Folder.Fields.Type.isAccessible() ){
             folderMap = new Map<Id,Folder>([Select id,name from Folder where Type='Email']);
         }
         
         string pageName= apexpages.currentpage().getparameters().get('pn');
        
         if(pageName!= null && pageName!='' && (pageName=='ID' || pageName=='FD')){
             if(Schema.sObjectType.Investor_Distribution__c.isAccessible() && Schema.sObjectType.Correspondence_List__c.isAccessible()){
                if(Schema.sObjectType.Contact.isAccessible() && Schema.sObjectType.Contact.Fields.Email.isAccessible() && Schema.sObjectType.Contact.Fields.HasOptedOutOfEmail.isAccessible() && Schema.sObjectType.Contact.Fields.AccountId.isAccessible()){
                    ErrorStatusInsufficient= true;
                }
                else{
                    ErrorStatusInsufficient= false;
                }                
             }           
         }
         else if(pageName!= null && pageName!='' && (pageName=='DD' || pageName=='CC')){
             if(Schema.sObjectType.Capital_Call__c.isAccessible() && Schema.sObjectType.Correspondence_List__c.isAccessible()){
                if(Schema.sObjectType.Contact.isAccessible() && Schema.sObjectType.Contact.Fields.Email.isAccessible() && Schema.sObjectType.Contact.Fields.HasOptedOutOfEmail.isAccessible() && Schema.sObjectType.Contact.Fields.AccountId.isAccessible()){
                    ErrorStatusInsufficient= true;
                }
                else{
                    ErrorStatusInsufficient= false;
                }                
             }  
             
         }
         
         if(pageName== null || pageName=='' || id== null || id== '' || (id != null && !isValidSalesforceId(id))){
             returnURL='/';
             urlNotExist= true;
             ErrorStatusInsufficient= false;
         }
         
         this.ETData();
       }
       catch(exception e)
       {           
            string errormsgget = 'Invalid Id';
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,errormsgget));
                  
       }
    }
    
    //Record Id validation check.
    public static Boolean isValidSalesforceId( String recordId){
        try 
        {
            Id id = recordId;                
            return true;
        } 
        catch ( Exception e ){
            return false;
        }
    }
    
    public void ETData()
    {
        try
        {
            // SK: 7Dec2017
            List<EmailTemplate> emailTempLst = new List<EmailTemplate>();
            if( Schema.sObjectType.EmailTemplate.isAccessible() && Schema.sObjectType.EmailTemplate.Fields.Name.isAccessible() && 
                Schema.sObjectType.EmailTemplate.Fields.TemplateType.isAccessible() && Schema.sObjectType.EmailTemplate.Fields.Description.isAccessible() && Schema.sObjectType.EmailTemplate.Fields.FolderId.isAccessible())
            {
                emailTempLst = [select id,name,TemplateType,Description,FolderId from EmailTemplate order by name limit 100];
            }
            
            for(EmailTemplate et : emailTempLst)
            {
                if(!folderListIds.contains(et.FolderId)){
                    folderListIds.add(et.FolderId);
                }
                emailingTemplate ete= new emailingTemplate();
                ete.isSelected= false;
                ete.templateId= et.id;
                ete.Name = et.name;
                ete.TemplateType = et.TemplateType;
                ete.Description = et.Description; 
                emailingTemplates.add(ete); 
            }
            
            for(Folder f : folderMap.values()){
                if(!folderListIds.contains(f.id)){
                    folderListIds.add(f.Id);    
                }
            }
        }
        catch(exception e)
        {           
            string errormsgget = e.getMessage();
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,errormsgget));
        }        
    }
    
    public List<SelectOption> getItems(){
        try{
        List<SelectOption> option= new List<SelectOption>();
        folderOtherIds= new Set<Id>();
        option.add(new SelectOption('All','All'));
        for(String fId: folderListIds){
            if(folderMap.get(fId)== null){
                folderOtherIds.add(fId);
            }
            else{
                option.add(new SelectOption(folderMap.get(fId).id,folderMap.get(fId).name));
            }
        }
        option.add(new SelectOption('Others','Others'));
        return option;
        }
       catch(exception e)
       {           
            string errormsgget = e.getMessage();
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,errormsgget));
            return null;      
       }
    }
    
    public PageReference goToMainPage(){
        try{
        PageReference pr= new PageReference('/'+apexpages.currentpage().getparameters().get('id'));
        pr.setRedirect(true);
        return pr;
        }
        catch(exception e)
       {           
            string errormsgget = e.getMessage();
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,errormsgget));
            return null;      
       }
    }
    
    public PageReference cancel(){
        try{
        Pagereference pr= new PageReference('/'+apexpages.currentpage().getparameters().get('id'));
        pr.setRedirect(true);
        return pr;
        }
        catch(exception e)
        {           
            string errormsgget = e.getMessage();
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,errormsgget));
            return null;      
        }
    }
    
    public string errormsgfrTrigger{get;set;}
    public string headermsg,contactIDString;
    public string selectedConId{get;set;}
    
    public void sendmassmail()
    {
        boolean successCHK= false;
        sendingFailed = false;
        errormsgfrTrigger= '';
        headermsg= '';
         
        
        try{  
            List<String> lstCOnId= selectedConId.split(',');
            List<String> lstConId1= new List<String>(); 
            List<String> lstConId2= new List<String>(); 
            Integer i=1;    
                
            for(String str: lstCOnId){
                if(i<=50){
                    lstConId1.add(str);     
                    i++;
                }
                else{
                    lstConId2.add(str);     
                    i++;
                }               
            }
                
                
            Messaging.SingleEmailMessage[] messages =new List<Messaging.SingleEmailMessage>();            
            for (string c : lstConId1)
            {
                Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
                message.setTemplateId(TempID);
                message.setTargetObjectId(c.split('@@')[0]);
                message.setWhatId(c.split('@@')[1]);
                message.setUseSignature(use_My_Signature);
                message.setSaveAsActivity(Store_as_an_activity);
                
                if(bCC_Me_On_One==true && isbcc==true){
                    message.setBccSender(bCC_Me_On_One);
                }                
                else if(bCC_Me_On_One==false){
                    message.setBccSender(bCC_Me_On_One);
                }           
                 
                messages.add(message);
                isbcc=false;
            } 
            
            string ischk;
            Messaging.SendEmailResult[] results = Messaging.sendEmail(messages,false);
            
            for(Messaging.SendemailResult currentResult: results){
                ischk+= currentResult.isSuccess();
            }
            
            if(ischk.contains('true'))
            {
                successCHK=true;
            }
            else
            {
                successCHK=false;
            }
         
            if(successCHK ==true)
            {
                successmsgTrigger= true;               
            }
            else
            {
                successmsgTrigger=false;
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL, 'You have reached the daily mass email limit; reduce the number of contacts. For further details contact your Navatar Administrator.' ));
            }
            
            
            if(successCHK=true && lstCOnId.size()>50){
                sendFinalMail(lstConId2,TempID,use_My_Signature,Store_as_an_activity,bCC_Me_On_One,isbcc);                      
            }
                
            
        }
        catch(Exception e){
            successmsgTrigger=false;
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL, 'You have reached the daily mass email limit; reduce the number of contacts. For further details contact your Navatar Administrator.' ));
            
        }
        
        
    }
  
    @Future(callout=true)
    public static void sendFinalMail(List<string> selectedConId1,string TempID1,boolean use_My_Signature1,boolean Store_as_an_activity1,boolean bCC_Me_On_One1, boolean isbcc1){
        try
        {  
            boolean successCHK= false;
            
            Messaging.SingleEmailMessage[] messages =new List<Messaging.SingleEmailMessage>();
            
            for (string c : selectedConId1)
            {
                Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
                message.setTemplateId(TempID1);
                message.setTargetObjectId(c.split('@@')[0]);
                message.setWhatId(c.split('@@')[1]);
                message.setUseSignature(use_My_Signature1);
                message.setSaveAsActivity(Store_as_an_activity1);
                
                if(bCC_Me_On_One1==true && isbcc1==true){
                    message.setBccSender(bCC_Me_On_One1);
                }                
                else if(bCC_Me_On_One1==false){
                    message.setBccSender(bCC_Me_On_One1);
                }
                 
                messages.add(message);
                isbcc1=false;
            }
                
            string ischk;
            Messaging.SendEmailResult[] results = Messaging.sendEmail(messages,false);
            
            for(Messaging.SendemailResult currentResult: results){
                ischk+= currentResult.isSuccess();
            }
        
        }
       catch(exception e)
       {           
            string errormsgget = e.getMessage();
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,errormsgget));
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
    
    class emailingTemplate{
        public boolean isSelected{get;set;}
        public String templateId {get; set;}
        public String Name {get; set;}
        public String TemplateType {get; set;}
        public String Description {get; set;}
    }
    
}