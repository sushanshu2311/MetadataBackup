/******************************************************************************
** Module Name : EmailFundraisingContact
** Description : Send the mail of more the one contact at time
** Throws : NA
** Calls : NA
** Test Class :  
** Organization : Navatar Group
** Product Name & Version : PE 3.5 
** Revision History:- 
** Version     Date            Author    Description
   3.5         04-July-2016    Rajnish
   4.7         08-July-2021    Aditya    Show error message in mobile for Vf page
*********************************************************************************/

global with sharing class MassEmailFundraising
{   
    public boolean ErrorStatus{get;set;}            // get the Errorstatus   
    public String field {set;get;}                             
    public String value {set;get;}                  
    public String field_allchar {set;get;}          
    public String contactIDString {set;get;}       
    public fund__c fundDetails{get;set;}            
    public String fundId{get;set;}                  
    public String errormsgfrTrigger{get;set;}       
    public String successmsgTrigger{get;set;}       
    public String headermsg{get;set;}              
    public List<emailingTemplate> emailingTemplates {get; set;}   // public Boolean emailSendStatus{get;set;}
    public string locale_info{get;set;}            
    public list<user> user_info{get;set;}           //current user id 
    public string headerVal{get;set;}              
    public string TempID {get;set;}                 //To get Template's value   
    public String SelectedfolderId {get; set;}      //To store selected folder id  
    public String MassemailName {get; set;}           
    public string FId{get;set;}                    //to get the fund id from url
    public string InstId{get;set;}                 //to get the account id from url
    private Map<Id, Folder> folderMap;             //This is map to fetch all ids of email folders. 
    public Set<Id> folderListIds {get;set;}
    public Set<Id> folderOtherIds {get;set;}
    public integer count{get;set;}                 
    public boolean mailBcc {get; set;}              
    public boolean bCC_Me_On_One {get; set;}        
    public boolean use_My_Signature {get; set;}     
    public boolean sendingFailed {get; set;}        
    public string NameSpacePrefix{get; set;}        
    public String user_locale{get; set;}            
    public boolean Fundraising_Contact_Status{get;set;}    
    public boolean Fundraising_Contact_Status_isAccessible{get;set;} 
    public boolean Fundraising_Contact_Status_isCreateable{get;set;}   
    public boolean chkStoreActivity{get;set;}         
    public boolean isCurrency{get;set;}             
    public string localeString{get;set;}            
    public string strCurrencySystembol{get;set;}    //variable  to check default currency of the user 
    public string proptxtdata{get;set;}             // use in advance filter logic
    public string ErrorVal{get;set;}                // use in advance filter logic
    public string InstitutionId{get;set;}           
    public Account InstitutionDetails{get;set;}
    public boolean isFundid{get;set;}
    public boolean isInstId{get;set;}
    public boolean isbcc {get; set;}
    public string strCtrlerrorMessage{get;set;}      // strore catch exception message
    public string selectConIdFundrasingId{get;set;}
    public Boolean isMobile { get; set; }    // to check if the device is mobile, added by Aditya PEv4.7 8 July 2021
    
    global massemailFundraising(ApexPages.StandardSetController controller)
    {
        try
        {
           
            strCtrlerrorMessage='';
            folderListIds = new Set<Id>();
            folderOtherIds =new Set<Id>();  
            
            isFundid=false;
            isInstId=false;
            isbcc=true;
            string user_id=Userinfo.getUserId();
            isMobile = UserInfo.getUiTheme() == 'Theme4t'; // to check if the device is mobile, added by Aditya PEv4.7 8 July 2021
            locale_info = UserInfo.getLocale();
           
            NameSpacePrefix=CommonUtility.strNameSpacePrefix;
            isCurrency=Schema.getGlobalDescribe().containsKey('CurrencyType');
            strCurrencySystembol = UserInfo.getDefaultCurrency();
            bCC_Me_On_One = false;
            use_My_Signature = false;
            chkStoreActivity=true;
            ErrorStatus = true; 
            String browserType='';  
            browserType = Apexpages.currentPage().getHeaders().get('USER-AGENT'); //gets the browser name and detail
            if(browserType!=null)
            {
                if(browserType.contains('MSIE') )
                {
                    Apexpages.currentPage().getHeaders().put('X-UA-Compatible','IE=9');  //sets the type to IE9 for every version of IE browse  by default all operator should be equals 
                }
            }
            fundDetails = new fund__c(); 
            InstitutionDetails =new  Account();         
            headerVal='contact__r.LastName';
            errormsgfrTrigger='';    
            successmsgTrigger='';  
            
            if(Schema.sObjectType.User.isAccessible() && Schema.sObjectType.User.fields.LocaleSidKey.isAccessible()){
                user_info=[select LocaleSidKey from user where id=:user_id];           
            }
            
            locale_info = UserInfo.getLocale();      
            MassemailName = '';
            String conName,conAccounName,ConphoneNo,Conemail;
            emailingTemplates = new List<emailingTemplate>();       // Alphabets character for searching in the grid
            //added by sameer
            id fId_temp = ApexPages.currentPage().getParameters().get('Fid');
            id InstId_temp = ApexPages.currentPage().getParameters().get('Lid');
            
            FId = string.valueOf(fId_temp);
            InstId = string.valueOf(InstId_temp);
            /*FId=ApexPages.currentPage().getParameters().get('Fid');     // fetch the Account id from url
            InstId=ApexPages.currentPage().getParameters().get('Lid'); // fetch the Fund id from url*/
            
            // SK: 7Dec2017
            if(Schema.sObjectType.Folder.isAccessible() && Schema.sObjectType.Folder.Fields.Name.isAccessible() && 
                Schema.sObjectType.Folder.Fields.Type.isAccessible() )
            {
                folderMap = new Map<Id, Folder>( [Select id , name from Folder where Type = 'email']);
            }
            
            this.ETData();
            fundId= FId;
            InstitutionId=InstId;
           
            if(FId !=null && FId !='null' && FId !='')
            {                            
                 // SK: 7Dec2017
                if(Schema.sObjectType.Fund__c.isAccessible() && Schema.sObjectType.Fund__c.Fields.Name.isAccessible() && 
                    Schema.sObjectType.Fund__c.Fields.Fund_Type__c.isAccessible() )
                {
                    fundDetails = [select id, name, Fund_type__c from Fund__c WHERE id =: fundId limit 1];
                }
                 isFundid=true;
            
            }
            
            if(InstId !=null && InstId !='null' && InstId !='')             
            {   
                // SK: 7Dec2017
                if(Schema.sObjectType.Account.isAccessible() && Schema.sObjectType.Account.fields.RecordTypeId.isAccessible() && 
                    Schema.sObjectType.Account.Fields.Name.isAccessible() )
                {
                    InstitutionDetails = [select id, Name,RecordTypeId from Account WHERE id =: InstitutionId limit 1];  
                }
                
                isInstId=true;
            }               
           
        }      
        catch(exception ex)
        {
            ErrorStatus = false;
            strCtrlerrorMessage='Invalid Id';
        
        }
    } 
    
    //@Inner class to get emailTemplates Properties
    class emailingTemplate
    { 
        public boolean isSelected {get; set;}
        public String templateId {get; set;}
        public String Name {get; set;}
        public String TemplateType {get; set;}
        public String Description {get; set;}
    }

    
  //@Redirect page to Marketing Initative Detail Page 
    public Pagereference cancel()
    { 
        strCtrlerrorMessage='';
        try
        {
            if(FId !=null)
            {
                Pagereference pageRef= new Pagereference('/'+FId);
                pageRef.setredirect(true);
                return pageRef; 
            }
            else if(InstId !=null)
            {
                Pagereference pageRef= new Pagereference('/'+InstId);
                pageRef.setredirect(true);
                return pageRef; 
            }
            else
            {
                return null;
            }
            
           
        }
        catch(exception ex)
        {
            strCtrlerrorMessage=ex.getMessage();
            return null;
        }
    } 
   //Method to get name TemplateType Description FolderId from emailTemplate
    public void ETData()
    { 
        strCtrlerrorMessage='';
        try
        {
            // SK: 7Dec2017
            List<EmailTemplate> emailTempLst = new List<EmailTemplate>();
            if(Schema.sObjectType.EmailTemplate.isAccessible() && Schema.sObjectType.EmailTemplate.Fields.name.isAccessible() && 
                Schema.sObjectType.EmailTemplate.Fields.TemplateType.isAccessible() && Schema.sObjectType.EmailTemplate.Fields.FolderId.isAccessible() && Schema.sObjectType.EmailTemplate.Fields.Description.isAccessible())
            {
                emailTempLst = [select name, TemplateType, Description, FolderId from emailTemplate Order by name LIMIT:(Limits.getLimitQueryRows() - Limits.getQueryRows()) ];
            }
            
            for(emailTemplate e : emailTempLst){ //(PE3.5, SK, 16Aug2017): added limit clause
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
            for(Folder f : folderMap.values()){
                if(!folderListIds.contains(f.id))
                    folderListIds.add(f.Id);
            }
            getItems();
        }
        catch(exception ex)
        {
            strCtrlerrorMessage=ex.getMessage();            
        }
       
    }
    // show email template according to selaeted email template folder
    public List<SelectOption> getItems()
    { 
        strCtrlerrorMessage='';
        try
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
        catch(exception ex)
        {
            strCtrlerrorMessage=ex.getMessage();
            return null;
        }
        
    } 
    
    public Pagereference sendmassmail()
    {
        sendingFailed = false;
        integer Sendmailcount = 0;        
        Set<Id> setFCIds = new Set<Id>();
        try
        {       
            List<String> lstConId= selectConIdFundrasingId.split(',');
            List<String> lstConId1= new List<String>(); 
            List<String> lstConId2= new List<String>(); 
            Integer i=1;            
            
            for(String str: lstConId)
            {
                if(i<=50)
                {
                    lstConId1.add(str);     
                    i++;
                }
                else
                {
                    lstConId2.add(str);     
                    i++;
                }               
            }
            
            Messaging.SingleEmailMessage[] messages =new List<Messaging.SingleEmailMessage>();
            
            for (string conid : lstConId1)
            {                            
                Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();             
                
                message.setTemplateId(TempID);
                message.setTargetObjectId(conid.split('@@')[0]);
                message.setWhatId(conid.split('@@')[1]);              
                message.setUseSignature(use_My_Signature);              
                message.setSaveAsActivity(chkStoreActivity);
                if(bCC_Me_On_One==true && isbcc==true)
                {
                    message.setBccSender(bCC_Me_On_One);
                }                
                else if(bCC_Me_On_One==false)
                {
                    message.setBccSender(bCC_Me_On_One);
                }                       
                messages.add(message);               
                setFCIds.add(conid.split('@@')[2]);
                Sendmailcount++;
                isbcc=false;                
            } 
            count=Sendmailcount;
            
            List<Fundraising_Contact__c> lstFCRecords = new List<Fundraising_Contact__c>();
            for(Id fcId:setFCIds)
            {
                Fundraising_Contact__c fcObj = new Fundraising_Contact__c(id=fcId);
                if(Schema.sObjectType.Fundraising_Contact__c.fields.Last_Email_Sent__c.isUpdateable()){
                    fcObj.Last_Email_Sent__c=System.now(); 
                }
                lstFCRecords.add(fcObj);
            }
            if(lstFCRecords.size()>0)
            {
                if(Schema.sObjectType.Fundraising_Contact__c.isUpdateable()){
                    update lstFCRecords;
                }
            }               
                
                
            string ischk;
            Messaging.SendEmailResult[] results = Messaging.sendEmail(messages,false); 
            for(Messaging.SendemailResult currentResult: results)
            {
                ischk+= currentResult.isSuccess();               
            
            }
            if(ischk.contains('true') && lstConId1.size()>1)
            {               
                count=Sendmailcount+lstConId2.size();               
                sendFinalMail(lstConId2,TempID,use_My_Signature,chkStoreActivity,bCC_Me_On_One,isbcc);                      
            
            }           
            return null;
        }
        catch(System.emailException e)
        {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,' '+e.getMessage()));
            return null;
        }
    }
    
    @Future(callout=true)
    public static void sendFinalMail(List<string> selectedConId1,string TempID1,boolean use_My_Signature1,boolean chkStoreActivity1,boolean bCC_Me_On_One1, boolean isbcc1)
    {        
        set<Id> SetFCIds = new Set<Id>();
        try
        {    
           
            Messaging.SingleEmailMessage[] messages =new List<Messaging.SingleEmailMessage>();
            
            for (string conid : selectedConId1)
            {                            
                Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();             
                message.setTemplateId(TempID1);
                message.setTargetObjectId(conid.split('@@')[0]);
                message.setWhatId(conid.split('@@')[1]);                     
                message.setUseSignature(use_My_Signature1);              
                message.setSaveAsActivity(chkStoreActivity1);
                if(bCC_Me_On_One1==true && isbcc1==true)
                {
                    message.setBccSender(bCC_Me_On_One1);
                }                
                else if(bCC_Me_On_One1==false)
                {
                    message.setBccSender(bCC_Me_On_One1);
                }                       
                messages.add(message);                 
                SetFCIds.add(conid.split('@@')[2]);
                isbcc1=false;                
            } 
            
            string ischk;
            Messaging.SendEmailResult[] results = Messaging.sendEmail(messages,false);          
            
            for(Messaging.SendemailResult currentResult: results)
            {
                ischk+= currentResult.isSuccess();          
            }
           
           
            List<Fundraising_Contact__c> lstFCRec=new List<Fundraising_Contact__c>();
            
            for(Id fcid:SetFCIds)
            {
                Fundraising_Contact__c objfc= new Fundraising_Contact__c(Id=fcid);
                if(Schema.sObjectType.Fundraising_Contact__c.fields.Last_Email_Sent__c.isUpdateable()){
                    objfc.Last_Email_Sent__c=System.now();
                }
                lstFCRec.add(objfc);
            }
           
            if(lstFCRec.size() > 0)
            {
                if(Schema.sObjectType.Fundraising_Contact__c.isUpdateable()){
                    update lstFCRec;
                }
            }
        }
        catch(System.emailException e)
        {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,' '+e.getMessage()));
          
        }
    }
    
   // get No of email limit
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
   

}