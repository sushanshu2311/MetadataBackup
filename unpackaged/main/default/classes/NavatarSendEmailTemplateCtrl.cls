public with sharing class NavatarSendEmailTemplateCtrl {

    /*returns the folderlist along template list*/    
    @auraEnabled(cacheable=true)
    public static responsedata retrievefolders(String emailData){        
        Set<Id> folderotherIds = new Set<Id>();
        boolean anyTemplateWithoutFolder = false;
        set<Id>templatewithfolderIds = new set<Id>();
        responsedata response = new responsedata();
        Map<Id,folder>folderMap;
        response.options.add(new options('All','All'));
        
        try{
            List<EmailTemplate> emailTempLst = new List<EmailTemplate>();
            if(Schema.sObjectType.Folder.isAccessible() && Schema.sObjectType.Folder.Fields.Name.isAccessible() && 
                Schema.sObjectType.Folder.Fields.Type.isAccessible() )
            {
                folderMap = new Map<Id,folder> ([Select id , name from Folder where Type IN ('email','EmailTemplate')]);/* Modified by Anshika Ahuja */
            }
            if(Schema.sObjectType.EmailTemplate.isAccessible() && Schema.sObjectType.EmailTemplate.Fields.name.isAccessible() && 
                Schema.sObjectType.EmailTemplate.Fields.TemplateType.isAccessible() && Schema.sObjectType.EmailTemplate.Fields.FolderId.isAccessible() && Schema.sObjectType.EmailTemplate.Fields.Description.isAccessible())
            {
                emailTempLst = [select name, TemplateType, Description, FolderId,FolderName from emailTemplate Order by name LIMIT:(Limits.getLimitQueryRows() - Limits.getQueryRows()) ];
            }
            system.debug('size '+emailTempLst.size());
            
            for(emailTemplate e : emailTempLst){
                emailingTemplate tempE = new emailingTemplate();
                tempE.templateId = e.Id;
                //Replaced emailData.split('@@')[0] with emailData.split('@@')[1] by Lakshya to resolve 00030421
                //tempE.templateurl = '/'+e.Id+'/s?TemplateType=0&ids='+e.Id+'&id='+e.Id+'&previewMode=1&recipient_type_id='+emailData.split('@@')[1];/*Modified by Anshika Ahuja as all email type folders were not displaying in the list*/
                tempE.Name = e.name;
                tempE.folderId = e.folderId;
                tempE.TemplateType = e.TemplateType;
                tempE.Description = e.Description;            
                if(foldermap.get(e.FolderId) == null){
                    anyTemplateWithoutFolder = true;
                    tempE.hasFolder = false;                    
                }else if(foldermap.get(e.FolderId)!=null){         
                    tempE.hasFolder = true;
                    if(!templatewithfolderIds.contains(e.FolderId))
                    { templatewithfolderIds.add(e.FolderId);
                        response.options.add(new options(e.FolderName,e.FolderId));
                    }              
                }  
                response.emailingTemplates.add(tempE);                
            }
            if(anyTemplateWithoutFolder) 
                response.options.add(new options('Others','Others'));           
            
            response.responseMsg = 'Success';
        }catch(exception ex){
            System.debug('ex > '+ex.getMessage());
            response.responseMsg = ex.getMessage();
        }
        return response;     
    }
    
    /*parent wrapper to store data of options and template*/
    public class responsedata{
        @auraenabled   public string responseMsg='';
        @auraenabled   public list<options> options = new list<options>();
        @auraenabled   public list<emailingTemplate> emailingTemplates = new List<emailingTemplate>();
    }
    
    /*wrapper to store folder data*/
    public class options{
        @auraenabled public string label;
        @auraenabled public string value;
        public options(string label,string value){
            this.label = label;
            this.value= value;
        }
    }
    
    /*wrapper to store template data*/
    public class emailingTemplate
    { 
        @auraenabled  public String templateId {get; set;}
        @auraenabled  public String folderId {get;set;}
        @auraenabled   public String Name {get; set;}
        @auraEnabled   public String templateurl{get;set;}
        @auraenabled   public String TemplateType {get; set;}
        @auraenabled   public String Description {get; set;}
        @auraenabled   public boolean hasfolder {get;set;}
    }
}