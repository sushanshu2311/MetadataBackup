/****************************************************************************************************

** Module Name : Quick Create Firm

** Description : Used for firmQuicCreate component.

** Throws : NA

** Calls : NA

** Organization : Navatar Group

** Revision History:-

** Version    Date(YYYY-MM-DD)    Author         Description of Action

** 1.0        2022-11-2022         Nikita Suresh

****************************************************************************************************/





public with sharing class NavatarCreateMenuFirmCtrl {
  
    
    /*
     * Purpose : returns userAvailable recordTypes
     * Input :   
     * Returns : List of RecordTypes
*/ 
    
   // @AuraEnabled
    private static List<RecordTypeOptionWrapper> getUserAvailableAccountRecordTypes() {
        Schema.DescribeSObjectResult objectInfo = Account.SObjectType.getDescribe();
        List<RecordTypeOptionWrapper> recTypeOptions = new List<RecordTypeOptionWrapper>();
        try{
        List<Schema.RecordTypeInfo> recordTypes = objectInfo.getRecordTypeInfos();
        system.debug('recordTypes'+recordTypes);    
        for(RecordTypeInfo recType : recordTypes) {
            if(recType.isAvailable() && recType.getName() != 'Limited Partner' && recType.getName() != 'Master') {
                recTypeOptions.add(
                    new RecordTypeOptionWrapper(recType.getName(), recType.getRecordTypeId(), recType.isDefaultRecordTypeMapping())
                );
            }
        }
       } catch (Exception e) {            
            throw new AuraHandledException('Error Occured While Loading Component : <<' + e.getStackTraceString() + '>>');
        } 
        return recTypeOptions;
    }
    
    public class RecordTypeOptionWrapper {
        @AuraEnabled
        public String label{get; private set;}
        @AuraEnabled
        public String value{get; private Set;}
        @AuraEnabled
        public Boolean isDefaultRecordType{get; private Set;}
        public RecordTypeOptionWrapper(String recTypeLabel, String recTypeId, Boolean isDefaultRecordType) {
            this.label = recTypeLabel;
            this.value = recTypeId;
            this.isDefaultRecordType = isDefaultRecordType;
        }
    }
    
    /*
     * Purpose : To insert firm record
     * Input :   
     * Returns : returns newly created Account record details
*/ 
    
 
    @AuraEnabled
    public static Account insertRecord(String recordTypeId,String name){
         Account acc = new Account();
       try{
           acc.Name = name;
           acc.RecordTypeId = recordTypeId;
           if(Schema.sObjectType.Account.isCreateable()){
               if(Schema.sObjectType.Account.fields.Name.isCreateable() && Schema.sObjectType.Account.fields.RecordTypeId.isCreateable()){
                  insert acc; 
               }            
           }
       }catch(exception e){
            throw new AuraHandledException('Error Occured While Loading Component : <<' + e.getStackTraceString() + '>>'+e.getLineNumber());
       }
         return acc;
    }
    
     /*
     * Purpose : to get metadataFields
     * Input :   
     * Returns : returns list of metadaFields
*/ 
    
  //  @AuraEnabled
    private static List<String> getMetaDataFields(){
       Map<String, Acuity_Setting__mdt> metadataFieldsAPiNames = new Map<String, Acuity_Setting__mdt>();  
       List<String> firmLabels = new List<String>();
        try{
        metadataFieldsAPiNames=Acuity_Setting__mdt.getAll();
       firmLabels.add(String.valueOf(metadataFieldsAPiNames.get('Acuity_QC_Firm_Field1').value__c));
        String recordType = (String.valueOf(metadataFieldsAPiNames.get('Acuity_QC_Firm_Field2').value__c));
        String nameLabel = (String.valueOf(metadataFieldsAPiNames.get('Acuity_QC_Firm_Field1').value__c));
        Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        Schema.SObjectType leadSchema = schemaMap.get('Account');
         firmLabels.add(leadSchema.getDescribe().fields.getMap().get(recordType).getDescribe().getLabel());
         firmLabels.add(leadSchema.getDescribe().fields.getMap().get(nameLabel).getDescribe().getLabel());
        }catch (Exception e) {
            throw new AuraHandledException('Error Occured While Loading Component : <<' + e.getStackTraceString() + '>>');
        }    
        return firmLabels;  
    }
    
    public class responseWrapper{
      @AuraEnabled public List<RecordTypeOptionWrapper> getUserDetails;
     @AuraEnabled public List<String> getFieldLabels;
        
    }
    
    /*
     * Purpose : to get recordTypes and MetadataFields in one method
     * Input :   
     * Returns : returns wrapper with recordTypes and metadataFields
  */ 
    
    @AuraEnabled(cacheable=true)
    public static responseWrapper getResponceData(){
         responseWrapper response = new responseWrapper();
        try{ 
       response.getUserDetails = getUserAvailableAccountRecordTypes();
       response.getFieldLabels = getMetaDataFields();
        }catch(Exception e) {
            throw new AuraHandledException('Error Occured While Loading Component : <<' + e.getStackTraceString() + '>>');
        }         
       return  response;
    }
   
}