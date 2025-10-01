/***********************************
** Module Name : MassEmail_CC_ID
** Description : This class is used by four page to send email in bulk.
** Throws : NA
** Calls : NA
** Test Class :  
** Organization : Navatar Group
** Product Name & Version : PE 3.5 
** Revision History:- 
** Version     Date            Author 
   3.5         04-July-2016    Lalit
*************************************/

public with Sharing class MassEmail_CC_ID{
    
    public string nameSpacePrefix{get;set;}
    public string queryString{get;set;}
    public string typeOfPage{get;set;}
    public string pageName{get;set;} 
    public string objectPassToWrenchComponent{get;set;}
    public string sendingFailed{get;set;}
    public string fundid{get;set;}
    public string tempId{get;set;}    
     
    public MassEmail_CC_ID(){
       try{ 
         initMethod();
       }
       catch (Exception objExcp) {
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, objExcp.getMessage()));
        }
         
    }
    
    public void initMethod(){
        try
        {
            ID id = ApexPages.currentPage().getParameters().get('id');
            string recID= ApexPages.currentPage().getParameters().get('id');
            string pageNameR= ApexPages.currentPage().getParameters().get('pn');
            nameSpacePrefix= CommonUtility.strNameSpacePrefix;  
            
            string objectName='';
            objectPassToWrenchComponent='';
           
            if(pageNameR!= null && pageNameR=='FD' && recID!='' && recID!= null)
            {
                queryString= 'select id,name,'+nameSpacePrefix+'Commitment__c from '+nameSpacePrefix+'Investor_Distribution__c where '+nameSpacePrefix+'Fund_Distribution__c=\''+recID+'\'';        
                
                // SK: 7Dec2017
                Fund_Distribution__c fd = new Fund_Distribution__c();
                if(Schema.sObjectType.Fund_Distribution__c.isAccessible() && Schema.sObjectType.Fund_Distribution__c.fields.Fund_Name__c.isAccessible() && Schema.sObjectType.Fund__c.fields.Name.isAccessible() && Schema.sObjectType.Fund_Distribution__c.Fields.Name.isAccessible() )
                {
                    fd = [select id, name,Fund_Name__r.name from Fund_Distribution__c where id=:recID];
                }
                
                string queryRec= 'select id,name from '+nameSpacePrefix+'Fund_Distribution__c where id=\''+String.escapeSingleQuotes(recID)+'\'';
                
                // SK: 7Dec2017
                List<Fund_Distribution__c> lstSobject = new List<Fund_Distribution__c>();
                if(Schema.sObjectType.Fund_Distribution__c.isAccessible()){
                    lstSobject = Database.query(queryRec);
                }
                
                typeOfPage='Emailing Investor Distribution Notice(s) of Fund Distribution ID '+lstSobject[0].name+' for Fund - '+fd.Fund_Name__r.name;
                objectPassToWrenchComponent= 'Contact:Commitment__c:Investor_Distribution__c';
            }
            else if(pageNameR!= null && pageNameR=='ID' && recID!='' && recID!= null)
            {
                // SK: 7Dec2017
                Investor_Distribution__c idr = new Investor_Distribution__c(); 
                if(Schema.sObjectType.Investor_Distribution__c.isAccessible() && Schema.sObjectType.Investor_Distribution__c.fields.Fund_Distribution__c.isAccessible() && Schema.sObjectType.Fund_Distribution__c.fields.Fund_Name__c.isAccessible() && Schema.sObjectType.Fund__c.fields.Name.isAccessible()&& 
                    Schema.sObjectType.Investor_Distribution__c.Fields.Name.isAccessible())
                {
                    idr = [select id,name,Fund_Distribution__r.Fund_Name__r.name from Investor_Distribution__c where id=:recID];
                }
                
                queryString= 'select id,name,'+nameSpacePrefix+'Commitment__c from '+nameSpacePrefix+'Investor_Distribution__c where id=\''+recID+'\'';        
                string queryRec= 'select id,name from '+nameSpacePrefix+'Investor_Distribution__c where id=\''+String.escapeSingleQuotes(recID)+'\'';  //(PE3.5, SK, 11Aug2017): added String.escapeSingleQuotes()
                
                // SK: 7Dec2017
                List<Investor_Distribution__c> lstSobject = new List<Investor_Distribution__c>(); 
                if(Schema.sObjectType.Investor_Distribution__c.isAccessible()){
                    lstSobject = Database.query(queryRec);
                }
                
                typeOfPage='Emailing Investor Distribution Notice(s) of Investor Distribution ID '+lstSobject[0].name+' for Fund - '+idr.Fund_Distribution__r.Fund_Name__r.name;
                objectPassToWrenchComponent= 'Contact:Commitment__c:Investor_Distribution__c';
            }        
            else if(pageNameR!= null && pageNameR=='DD' && recID!='' && recID!= null)
            {
                // SK: 7Dec2017
                Fund_Drawdown__c fds = new Fund_Drawdown__c(); 
                if(Schema.sObjectType.Fund_Drawdown__c.isAccessible() && Schema.sObjectType.Fund__c.fields.name.isAccessible() && Schema.sObjectType.Fund_Drawdown__c.fields.Fund_Name__c.isAccessible() && Schema.sObjectType.Fund_Drawdown__c.Fields.Name.isAccessible())
                {
                    fds = [select id,name,Fund_Name__r.name from Fund_Drawdown__c where id=:recID];
                }
                
                queryString= 'Select Id,Name,'+nameSpacePrefix+'Commitment__c from '+nameSpacePrefix+'Capital_Call__c where '+nameSpacePrefix+'Fund_Drawdown__c=\''+recID+'\'';            
                string queryRec= 'select id,name from '+nameSpacePrefix+'Fund_Drawdown__c where id=\''+String.escapeSingleQuotes(recID)+'\'';  //(PE3.5, SK, 11Aug2017): added String.escapeSingleQuotes()
                
                // SK: 7Dec2017
                List<Fund_Drawdown__c> lstSobject = new List<Fund_Drawdown__c>(); 
                if(Schema.sObjectType.Fund_Drawdown__c.isAccessible()){
                    lstSobject = Database.query(queryRec);
                }
                
                typeOfPage='Emailing Capital Call Notice(s) of Fund Drawdown ID '+lstSobject[0].name+' for Fund - '+fds.Fund_Name__r.name;
                objectPassToWrenchComponent= 'Contact:Commitment__c:Capital_Call__c';
            }
            else if(pageNameR!= null && pageNameR=='CC' && recID!='' && recID!= null)
            {
                // SK: 7Dec2017
                Capital_Call__c ccc = new Capital_Call__c(); 
                if(Schema.sObjectType.Capital_Call__c.isAccessible() && Schema.sObjectType.Capital_Call__c.fields.Fund_Drawdown__c.isAccessible() && Schema.sObjectType.Fund_Drawdown__c.fields.Fund_Name__c.isAccessible() && Schema.sObjectType.Fund__c.fields.Name.isAccessible() && Schema.sObjectType.Capital_Call__c.Fields.Name.isAccessible())
                {
                    ccc = [select id,name,Fund_Drawdown__r.Fund_Name__r.name from Capital_Call__c where id=:recID];
                }
                
                queryString= 'Select Id,Name,'+nameSpacePrefix+'Commitment__c from '+nameSpacePrefix+'Capital_Call__c where id=\''+recID+'\'';            
                string queryRec= 'select id,name from '+nameSpacePrefix+'Capital_Call__c where id=\''+String.escapeSingleQuotes(recID)+'\'';   //(PE3.5, SK, 11Aug2017): added String.escapeSingleQuotes()
                
                // SK: 7Dec2017
                List<Capital_Call__c> lstSobject = new List<Capital_Call__c>(); 
                if(Schema.sObjectType.Capital_Call__c.isAccessible()){
                    lstSobject= Database.query(queryRec);
                }
                
                typeOfPage='Emailing Capital Call Notice(s) of Capital Call ID '+lstSobject[0].name+' for Fund - '+ccc.Fund_Drawdown__r.Fund_Name__r.name;
                objectPassToWrenchComponent= 'Contact:Commitment__c:Capital_Call__c';
            }
        }
        catch (Exception objExcp) {
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, objExcp.getMessage()));
        }      
    
    }

}