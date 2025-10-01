/*
    Developer               :   Sameer Rath
    Product Version         :   PE 3.0
    Date of Creation        :   23/01/2015
    Date of Last Update     :   10/09/2015
    Last Updated By         :   Sameer Rath
    Purpose of Creation     :   Listed below:
                                1. Describe sObject operation of related object and get the metadata of fields like [picklist, multipicklist] . 
*/
public with sharing class DescribeSobjectTest
{
    public list<string> lookupvalue{get;set;}
    public list<sObject> datalist{get;set;}
    Map<String, Schema.SObjectField> M;
    public List<SObjectField> ObjField{get;set;}
    public List<SelectOption> fieldsvalues{get;set;}
    public string pagename{get;set;}
    public string datatype_f{get;set;}
    public string operation{get;set;}
    public string pickval{get;set;}
    public string pickval_new{get;set;}
    public string objectname{get;set;}
    public string queryObjectstr{get;set;}
    public string secondnameobject{get;set;}
    public String NamespacePrefix1{get;set;}
    public string inputValue{get;set;}
    public boolean isReferenceField{get;set;}
    public string strQryobjName{get;set;}
    public string strQryobjAPIName{get;set;}
    
    public DescribeSobjectTest()
    {
        NamespacePrefix1 = getorgnamespace();
        isReferenceField = false;
        strQryobjName ='';
        objectname = ApexPages.currentPage().getParameters().get('Akobjectt');
        
        if(objectname=='Account')
        {
            secondnameobject='Account';
        }
         else if(objectname=='Contact')
        {
            secondnameobject= 'Contact';
        }
        else if(objectname=='fund')
        {
            secondnameobject= 'fund__c';
        }
        else if(objectname=='fundraising')
        {
            secondnameobject= 'fundraising__c';
        }
        else if(objectname=='Fundraising Contact')
        {
            secondnameobject= 'Fundraising_Contact__c';
        }
        else if(objectname=='Marketing_Prospect__c'|| objectname=='Marketing Prospects')
        {
            secondnameobject= 'Marketing_Prospect__c';
        }
        else
        {
            secondnameobject=null;
        }
        pickval = ApexPages.currentPage().getParameters().get('pickval');
        datatype_f = ApexPages.currentPage().getParameters().get('datatype_f');
        operation = ApexPages.currentPage().getParameters().get('operation');
        if(datatype_f=='REFERENCE' && !pickval.tolowercase().endsWith('__c') && !pickval.tolowercase().endsWith('id') && !pickval.tolowercase().endsWith('__r'))
            pickval = pickval+'Id';
        if(pickval.tolowercase().endsWith('__r'))
            pickval=pickval.replace('__r','__c');
        if(secondnameobject=='' || secondnameobject ==null)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Object name is blank.'));
        }
        else  if(pickval=='' || pickval==null)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Picklist name is blank.'));
        }
        else
        {
            lookupvalue = new list<string>();             
            M = new Map<String, Schema.SObjectField>();
            ObjField = new List<SObjectField>();
            fieldsvalues = new List<SelectOption>();
            pagename = ApexPages.currentPage().getParameters().get('page');     
            queryObjectstr = secondnameobject;
            
            if(queryObjectstr == 'Contact')
            {
                M = Schema.SObjectType.Contact.fields.getMap();
            }   
            if(queryObjectstr == 'Fund__c')
            {
                M = Schema.SObjectType.Fund__c.fields.getMap();
            }
            if(queryObjectstr == 'Fundraising__c')
            {
                M = Schema.SObjectType.Fundraising__c.fields.getMap();
            }
             if(queryObjectstr == 'Fundraising_Contact__c')
            {
                M = Schema.SObjectType.Fundraising_Contact__c.fields.getMap();
            }
             if(queryObjectstr == 'Account')
            {
                M = Schema.SObjectType.Account.fields.getMap();
            }
             if(queryObjectstr == 'Marketing_Prospect__c')
            {
                M = Schema.SObjectType.Marketing_Prospect__c.fields.getMap();
            }
            Schema.SObjectField f21 = M.get('Name');

            ObjField = M.values();
            
            if(pickval == 'RecordType.name'){
                pickval = 'RecordTypeId';
            }
            for(integer j = 0 ; j < ObjField.size() ; j++)
            {
                String str = String.Valueof(ObjField[j]);
                if(str==pickval)
                {
                    pickval_new=str;
                }
                fieldsvalues.add(new SelectOption(str,str)); 
            }
            
            string picklistvalue2 =pickval_new;
            
            
            if(picklistvalue2 != null)
            {
                
                if(NamespacePrefix1 != ''){
                    if(picklistvalue2.contains(NamespacePrefix1))
                        picklistvalue2 = picklistvalue2.replace(NamespacePrefix1,'');
                }
                
                Schema.SObjectField f = M.get(picklistvalue2);
                if(String.Valueof(f.getDescribe().getType()) == 'BOOLEAN' || String.Valueof(f.getDescribe().getType()) == 'PICKLIST' ||  String.Valueof(f.getDescribe().getType()) == 'REFERENCE' || String.Valueof(f.getDescribe().getType()) == 'MULTIPICKLIST')
                {
                    if (String.Valueof(f.getDescribe().getType()) == 'PICKLIST')
                    {
                        lookupvalue = new List<String>();
                        List<Schema.PicklistEntry> ple = f.getDescribe().getPicklistValues();
                        
                        for(Schema.PicklistEntry p : ple)
                        lookupvalue.add(p.value);   
                        datatype_f= 'PICKLIST'  ;     
                    }
                    else if (String.Valueof(f.getDescribe().getType()) == 'MULTIPICKLIST')
                    {
                        lookupvalue = new List<String>();
                        List<Schema.PicklistEntry> ple = f.getDescribe().getPicklistValues();
                        for(Schema.PicklistEntry p : ple)
                        lookupvalue.add(p.value);   
                        datatype_f= 'MULTIPICKLIST'  ;     
                    }
                    else if(String.Valueof(f.getDescribe().getType()) == 'BOOLEAN')
                    {
                        lookupvalue = new List<String>();
                        lookupvalue.add('True');
                        lookupvalue.add('False');
                        datatype_f=  'BOOLEAN'   ;     
                    }
                    else if(String.Valueof(f.getDescribe().getType()) == 'REFERENCE')
                    {
                        lookupvalue = new List<String>();
                        isReferenceField = true;
                        list<Schema.SObjectType> queryObject = f.getDescribe().getReferenceTo();
                        list<sObject> datalist = new list<sObject>();
                        
                        if(picklistvalue2 != 'RecordTypeId')
                        {
                            strQryobjAPIName= string.valueOf(queryObject[0]);
                            strQryobjName = Schema.describeSObjects(new List<String>{strQryobjAPIName})[0].getLabel();
                            
                            // SK: 21Dec2017
                            SObjectType sObjectType = Schema.getGlobalDescribe().get( String.ValueOf(queryObject[0]) );
                            if(sObjectType.getDescribe().isAccessible()){
                                datalist =  Database.query('select id,name from '+queryObject[0]+' limit 1000');
                            }
                        }
                        else
                        {
                            string mainquery='select id,name from RecordType where SobjectType=\''+queryObjectstr+'\' and IsActive = true limit 1000';
                            if(Schema.sObjectType.RecordType.isAccessible()){
                                datalist =  Database.query(mainquery); 
                            }                           
                        }               
                        if(datalist.size()>0)
                        {
                            for (sObject d : datalist)
                            {
                             lookupvalue.add((String)d.get('Name'));
                            }
                        }
                        datatype_f='REFERENCE' ;   
                        
                    }
                   else
                    {
                       ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Invalid Field')); 
                    }
                }
            }
        }
    }
    
    
    public void SearchItem(){
        try
        {
            // SK: 21Dec2017
            SObjectType sObjectType = Schema.getGlobalDescribe().get( strQryobjAPIName );
            
            list<sObject> datalist = new list<sObject>(); 
            lookupvalue = new List<String>(); 
            if(inputValue !=''){
                datalist =  Database.query('select id,name from '+strQryobjAPIName+' where name like \'%'+String.escapeSingleQuotes(inputValue)+'%\' limit 1000');   //(PE3.5, SK, 11Aug2017): added String.escapeSingleQuotes()

            }
            else{
                datalist =  Database.query('select id,name from '+strQryobjAPIName+' limit 1000');
            }
            for (sObject d : datalist){
                lookupvalue.add((String)d.get('Name'));
            }
        }
        catch(Exception e){
        }
    }

    public string getorgnamespace()
    {
        String TOKEN_SOBJECT_NAME = 'Fund__c';
        integer indexOfToken = -1;
        String namespsacePrefix = null;
        for ( Schema.SObjectType typ : Schema.getGlobalDescribe().values() )
        {
            String sobjName = String.valueOf(typ);
            if (sobjName != null)
            {
                indexOfToken = sobjName.indexOf(TOKEN_SOBJECT_NAME);
            }
            if (indexOfToken != -1)
            {
                namespsacePrefix = sobjName.substring(0, indexOfToken);
                break;
            }
        }
        return namespsacePrefix;
    }   

}