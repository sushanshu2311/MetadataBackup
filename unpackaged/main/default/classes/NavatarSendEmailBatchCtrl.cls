public with sharing class NavatarSendEmailBatchCtrl implements Database.Batchable<sObject>, Database.Stateful {
    List<String> contactList = new List<String>();
    Set<Id> conrolset = new Set<Id>();
    String templateId;
    Boolean use_My_Signature; 
    Boolean chkStoreActivity;
    Boolean bCC_Me_On_One;
    Boolean isbcc;
    Integer senderCount = 0;
    Integer failedRecCount = 0;
    String errorLog = 'Record Id, Name , Error \n' ;
    
    
    public NavatarSendEmailBatchCtrl(List<String> contactList, Set<Id> conrolSet, String templateId, Boolean use_My_Signature, Boolean chkStoreActivity, Boolean bCC_Me_On_One){ 
        this.contactList = contactList;
        this.conrolSet = conrolSet;
        this.templateId = templateId;
        this.use_My_Signature = use_My_Signature;
        this.chkStoreActivity = chkStoreActivity;
        this.bCC_Me_On_One = bCC_Me_On_One;
        this.isbcc = true;
    }
    
    /**
* This method create the library if absent, query the records and pass it for operations into batches.
*/
    public Database.QueryLocator start(Database.BatchableContext bc) {
        system.debug('####query '+contactList);
        String query = 'SELECT Id, Name FROM Contact WHERE Id IN:contactList AND HasOptedOutOfEmail = false AND Email!=null AND IsEmailBounced = false';
        
        return Database.getQueryLocator(query);
    }
    
    /**
* This method process the batches comes from the start method.
*/
    public void execute(Database.BatchableContext bc, List<Contact> contacts) {
        try
        {    
            senderCount +=contacts.size();
            Map<Id, Contact> conIdVsContacts = new Map<Id, Contact>(contacts);
            Messaging.SingleEmailMessage[] messages =new List<Messaging.SingleEmailMessage>();
            
            for (Contact conRec : contacts)
            {                            
                Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();             
                message.setTemplateId(templateId);
                message.setTargetObjectId(conRec.Id);               
                message.setUseSignature(use_My_Signature);              
                message.setSaveAsActivity(chkStoreActivity);
                message.setBccSender(bCC_Me_On_One);                     
                messages.add(message);
                bCC_Me_On_One = false;
            }
            Messaging.SendEmailResult[] results = Messaging.sendEmail(messages,false);
            System.debug(results);
            for(Messaging.SendemailResult currentResult: results)
            {
                if(!currentResult.isSuccess()){
                    String erroLog = currentResult.getErrors()[0].getTargetObjectId()+','+conIdVsContacts.get(currentResult.getErrors()[0].getTargetObjectId()).Name+','+json.serialize(currentResult.getErrors().get(0).getMessage()).replaceAll(',', ';')+'\n';                    
                    errorLog = errorLog +erroLog;
                    failedRecCount++;
                }
                else if(currentResult.isSuccess()){
                    /*list<navmnaI__Contact_Role__c> updateLMES=[select id,navmnaI__Last_Mass_Email__c from navmnaI__Contact_Role__c where navmnaI__Contact_Role__c.id in :conrolset]; 
                        if(updateLMES.size()>0)
                        {
                            for(navmnaI__Contact_Role__c comr: updateLMES)
                            {
                                comr.navmnaI__Last_Mass_Email__c= System.now(); //update LME field of contact role.
                            }
                            update updateLMES;
                        }*/
                }
            }			
        }
        catch(System.emailException e)
        {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,' '+e.getMessage()));
        }
    }
    
    public void finish(Database.BatchableContext bc) {
        AsyncApexJob currentBatch = [Select Id, Status from AsyncApexJob where Id = :bc.getJobId()];  
        //Check if batch is completed than send email notification.
        if(currentBatch.Status == 'Completed') {       
            Messaging.SingleEmailMessage notificationEmail = new Messaging.SingleEmailMessage();  
            notificationEmail.setSubject('Bulk Email Notification');
            notificationEmail.setBccSender(false);
            notificationEmail.setUseSignature(false);
            notificationEmail.setToAddresses(new String[] {userinfo.getUserId()});
            If(failedRecCount > 0){
                Messaging.EmailFileAttachment csvAttc = new Messaging.EmailFileAttachment();
                csvAttc.setFileName('FailedContacts.csv');
                csvAttc.setBody(Blob.valueOf(errorLog));
                notificationEmail.setFileAttachments(new Messaging.EmailFileAttachment[]{csvAttc});
                if(failedRecCount == senderCount){
                    notificationEmail.setPlainTextBody('Your bulk email request has been processed. Email could not be sent to '+failedRecCount+' recipient(s). Please refer to the attached issues file for more details.\n\nThanks');
                }
                else{
                    notificationEmail.setPlainTextBody('Your bulk email request has been processed. Emails have been sent successfully to '+(senderCount-failedRecCount)+' recipient(s) but could not be sent to '+failedRecCount+' recipient(s). Please refer to the attached issues file for more details.\n\nThanks');
                }
            }
            else{
                notificationEmail.setPlainTextBody('Your bulk email request has been processed. Emails have been sent successfully to '+(senderCount-failedRecCount)+' recipient(s).\n\nThanks');
            }        
            Messaging.SendEmailResult[] results = Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{notificationEmail},false); 
        }
    }    
}