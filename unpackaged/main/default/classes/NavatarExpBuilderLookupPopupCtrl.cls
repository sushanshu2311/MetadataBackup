/*
Class : NavatarExpBuilderLookupPopupCtrl 
Created By : Ehatsham
Created Date: 02-Dec-2020
Purpose: the class is serving to provide data against some field which are either of type refernce/picklist/multipicklist/user
used By : PicklistPopupLwc.lwc component (As of Now)
*/
public with sharing class NavatarExpBuilderLookupPopupCtrl {
    
    @auraEnabled(cacheable=true)
    public static responseData getLookUpValues(string objectname,string pickval,string datatype,string operation)
    {responseData response = new responseData();
        try{
        integer index =0;
        
        string  NamespacePrefix1 = [SELECT NamespacePrefix FROM ApexClass WHERE Name = 'FileUploaderCtrl'].NamespacePrefix + '__';
        system.debug('NamespacePrefix1'+NamespacePrefix1);
        system.debug('obj name '+objectname);
        boolean isReferenceField = false;
        string strQryobjName='';
        string secondnameobject = getObjApiName(objectname.toUpperCase(),NamespacePrefix1.toUpperCase());
        //string secondnameobject = objectname;
        response.objectname = secondnameobject;
        system.debug('second obj ---> '+secondnameobject);
        if(dataType=='REFERENCE' && !pickval.tolowercase().endsWith('__c') && !pickval.tolowercase().endsWith('id') && !pickval.tolowercase().endsWith('__r'))
            pickval = pickval+'Id';
        if(pickval.tolowercase().endsWith('__r'))
            pickval=pickval.replace('__r','__c');
        
        if(secondnameobject=='' || secondnameobject ==null){
            response.responseMessage = 'Object name is blank.';
        }
        else  if(pickval=='' || pickval==null){
            response.responseMessage = 'Picklist name is blank.';
        }
        else{
            Map<String, Schema.SObjectField> fieldsMap = new Map<String, Schema.SObjectField>();
            List<SObjectField> ObjField = new List<SObjectField>();
            List<SelectOption> fieldsvalues = new List<SelectOption>();
            string queryObjectName = secondnameobject;
            system.debug('queryObjectName'+queryObjectName);
            fieldsMap =  Schema.getGlobalDescribe().get(queryObjectName).getDescribe().fields.getMap();
            Schema.SObjectField f21 = fieldsMap.get('Name');
            
            ObjField = fieldsMap.values();
            
            if(pickval == 'RecordType.name'){
                pickval = 'RecordTypeId';
            }
            string pickval_new ='';
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
                Schema.SObjectField f = fieldsMap.get(picklistvalue2);
                string fdataType = f.getDescribe().getType()==null  ?'': String.Valueof(f.getDescribe().getType()).toUpperCase();
                if(f.getDescribe().getType()!=null && 
                   (fdataType == 'BOOLEAN' ||fdataType == 'PICKLIST' ||  fdataType == 'REFERENCE' || fdataType == 'MULTIPICKLIST')
                  )
                {
                    if (fdataType == 'PICKLIST')
                    {
                        
                        List<Schema.PicklistEntry> ple = f.getDescribe().getPicklistValues();
                        
                        for(Schema.PicklistEntry p : ple){
                            response.lookupvalues.add(new options(p.getLabel(),index++,p.value)); //Modified by Anshika Ahuja W.R.To bug no-00029513 Dated 23-3-2021
                        }
                        dataType= 'PICKLIST'  ;     
                        response.title = 'Select the Picklist Values to Add Below';
                    }
                    else if (fdataType == 'MULTIPICKLIST')
                    {
                        List<Schema.PicklistEntry> ple = f.getDescribe().getPicklistValues();
                        for(Schema.PicklistEntry p : ple)
                            response.lookupvalues.add(new options(p.value,index++,p.value));   
                        dataType= 'MULTIPICKLIST'  ;   
                        response.title = 'Select the Picklist Values to Add Below';
                    }
                    else if(fdataType == 'BOOLEAN')
                    {
                        response.lookupvalues.add(new options('True',index++,'1')); 
                        
                        response.lookupvalues.add(new options('False',index++,'0')); 
                        dataType=  'BOOLEAN'   ;     
                        response.title = 'Select the Picklist Values to Add Below';
                    }
                    else if(fdataType == 'REFERENCE')
                    {
                        isReferenceField = true;
                        list<Schema.SObjectType> queryObject = f.getDescribe().getReferenceTo();
                        list<sObject> datalist = new list<sObject>();
                        
                        
                        if(picklistvalue2 != 'RecordTypeId')
                        {
                            string strQryobjAPIName= string.valueOf(queryObject[0]);
                            strQryobjName = Schema.describeSObjects(new List<String>{strQryobjAPIName})[0].getLabel();
                            response.title = 'Select the '+strQryobjName+ '(s) to Add Below';
                            response.objectname = string.valueOf(queryObject[0]);
                            // SK: 21Dec2017
                            SObjectType sObjectType = Schema.getGlobalDescribe().get( String.ValueOf(queryObject[0]) );
                            if(sObjectType.getDescribe().isAccessible()){
                                datalist =  Database.query(String.escapeSingleQuotes('select id,name from '+queryObject[0]+' limit 1000'));
                            }
                        }
                        else
                        {
                            string mainquery='select id,name from RecordType where SobjectType=\''+String.escapeSingleQuotes(queryObjectName)+'\' and IsActive = true limit 1000';
                            if(Schema.sObjectType.RecordType.isAccessible()){
                                datalist =  Database.query(mainquery); 
                                response.objectname = 'RecordType';                                
                            }                           
                        }               
                        if(datalist.size()>0)
                        {
                            for (sObject d : datalist)
                            {
                                if(d.get('Name')!= null && d.get('Name')!='')
                                    response.lookupvalues.add(new options((String)d.get('Name'),index++,(String)d.get('Id')));
                            }
                        }
                        dataType='REFERENCE' ;   
                        
                    }
                    else
                    {
                        response.responseMessage ='Invalid Field';
                    }
                }
            }
            System.debug('lookupvalues'+response.LookupValues.size());
        }
        
        response.responseMessage = response.responseMessage == ''?'Success':response.responseMessage;
        return response;
    }catch(Exception e){
      system.debug('Error Occured While Loading Component : <<'+e.getMessage()+e.getLineNumber()+'>>');
      return response;
    }
    }
    
    @auraEnabled(cacheable = true)
    public static responseData SearchItem(string searchparam,string objname,String currentIndex){
        integer index = Integer.valueOf(currentIndex);
        responseData response = new responseData();
        try
        {            // SK: 21Dec2017
            SObjectType sObjectType = Schema.getGlobalDescribe().get( objname );
            
            list<sObject> datalist = new list<sObject>(); 
            if(searchparam !=''){
                datalist =  Database.query('select id,name from '+String.escapeSingleQuotes(objname)+' where name like \'%'+String.escapeSingleQuotes(searchParam)+'%\' limit 1000'); 
            }
            else{
                datalist =  Database.query(String.escapeSingleQuotes('select id,name from '+objname+' limit 1000'));
            }
            for (sObject d : datalist){
                if(d.get('Name')!= null && d.get('Name')!='')
                    response.lookupvalues.add(new options((String)d.get('Name'),index++,(String)d.get('Id'))); 
            }
            response.responseMessage =   response.lookupvalues.size()>0 ?'Success':'No Data Found';
        }
        catch(Exception e){
            response.responseMessage = e.getMessage();
        }
        return response;
    }
    private static string getObjApiName(string objectname,string NamespacePrefix1){
        system.debug('getOBJ API NAME--->'+objectname);
        string objName='';
        if(objectname.equalsIgnoreCase('ACCOUNT')){
        objName='Account';}
        else if(objectname.equalsIgnoreCase('CONTACT')){
        objName= 'Contact';}
        else if(objectname.equalsIgnoreCase('Contact Role')){
        objName= NamespacePrefix1+'Contact_Role__c';}
        else if(objectname.equalsIgnoreCase('Target')){
        objName= NamespacePrefix1+'Target__c';}
        else if(objectname.equalsIgnoreCase('navpeII_dev18__FUND__C') || objectname.equalsIgnoreCase('FUND')){
        objName= NamespacePrefix1+'fund__c';}
        else if(objectname.equalsIgnoreCase('navpeII_dev18__FUNDRAISING__C') || objectname.equalsIgnoreCase('FUNDRAISING')){
        objName= NamespacePrefix1+'fundraising__c';}
        else if(objectname.equalsIgnoreCase('FUNDRAISING CONTACT')){
        objName= NamespacePrefix1+'Fundraising_Contact__c';}
        else if(objectname.equalsIgnoreCase('DEAL')){
            objName= NamespacePrefix1+'Pipeline__c';}
        //Modified 'Marketing Prospects' to 'Marketing Prospect' by Lakshya on 20211007 to support lookup values displaying for Marketing_Prospect__c object
        else if(objectname.equalsIgnoreCase('Marketing_Prospect__c') || objectname.equalsIgnoreCase('Marketing Prospect')){
            //Added NamespacePrefix1 by Lakshya on 20211007 to support lookup values displaying for Marketing_Prospect__c object
            objName= NamespacePrefix1 + 'Marketing_Prospect__c';
        }else if(objectname.equalsIgnoreCase('navpeII_dev18__PIPELINE__C') || objectname.equalsIgnoreCase('PIPELINE')){
            objName= NamespacePrefix1+'Pipeline__c';
        }
        else{
        objName='';
        }
        return objName;
    }
    
    public class responseData{
        @auraEnabled 
        public String responseMessage;
        @auraEnabled 
        public String objectname; 
        @auraEnabled 
        public String title;
        @auraEnabled  
        public list<options> lookupvalues;
        public responseData()
        {
            this.responseMessage = ''; 
            this.objectname = '';
            this.LookupValues = new List<options>();
            
        }
    }
    public class options{
        @auraEnabled
        public string label;
        @auraEnabled
        public Integer index;
        @auraEnabled public String Id;
        @auraEnabled public boolean checked;
        public options(string label,Integer index,String Id)
        {
            this.label = label;
            this.index = index;
            this.Id = Id;
        }
    }
    
    
}