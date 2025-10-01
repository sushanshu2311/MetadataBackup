/****************************************************************************************************

** Module Name : Quick Create Contact

** Description : Used for ContactQuickCreate component.

** Throws : NA

** Calls : NA

** Organization : Navatar Group

** Revision History:-

** Version    Date(YYYY-MM-DD)    Author         Description of Action

** 1.0        2022-11-2022         Nikita Suresh

****************************************************************************************************/

public with sharing class NavatarCreateMenuContactCtrl {
    public static final String DUMMY_ACCOUNT_NAME = 'Dummy Account';
 /*
     * Purpose : returns metadata fields label
     * Input :   
     * Returns : List of labels
*/    
    @AuraEnabled(cacheable=true)
     public static List<String> getMetaDataFields(){
       Map<String, Acuity_Setting__mdt> metadataFieldsAPiNames = new Map<String, Acuity_Setting__mdt>();  
       List<String> firmLabels = new List<String>();
        metadataFieldsAPiNames=Acuity_Setting__mdt.getAll();
        firmLabels.add(String.valueOf(metadataFieldsAPiNames.get('Acuity_QC_Contact_Field1').value__c));
        firmLabels.add(String.valueOf(metadataFieldsAPiNames.get('Acuity_QC_Contact_Field2').value__c));
         firmLabels.add(String.valueOf(metadataFieldsAPiNames.get('Acuity_QC_Contact_Field3').value__c));
         firmLabels.add(String.valueOf(metadataFieldsAPiNames.get('Acuity_QC_Contact_Field4').value__c));
         String legalName = (String.valueOf(metadataFieldsAPiNames.get('Acuity_QC_Contact_Field5').value__c));
         String lastName = (String.valueOf(metadataFieldsAPiNames.get('Acuity_QC_Contact_Field2').value__c));
        Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
         Schema.SObjectType contactSchema = schemaMap.get('Contact');
         firmLabels.add(contactSchema.getDescribe().fields.getMap().get(legalName).getDescribe().getLabel());
         firmLabels.add(contactSchema.getDescribe().fields.getMap().get(lastName).getDescribe().getLabel());
         return firmLabels;  
    }
    
    /*
     * Purpose : creating new contact record
     * Input :   
     * Returns : returns newly created contact details
*/ 
    
    @AuraEnabled
    public static Contact insertContactRecord(String accountId,String accountName,String record){
        Map<String, object> deserialized = (Map<String, object>) JSON.deserializeUntyped(record);
        Contact con = New Contact();
        String newAccountId;
        try {
            con.LastName =  String.valueof(deserialized.get('lastName'));
            con.Email = String.valueof(deserialized.get('email'));
            con.Phone =  String.valueof(deserialized.get('phone'));
            con.FirstName = String.valueof(deserialized.get('firstName'));            
            if(String.isNotBlank(accountName) && accountName != Null){
               newAccountId = createAccountRecord(accountName);
               con.AccountId = newAccountId;
            }
            else if(String.isNotBlank(accountId)){
                con.AccountId = accountId;
            }      
            else{
                String dummyAccountId = getDummyAccountId();
                if(String.isBlank(dummyAccountId) && dummyAccountId == Null){
                    con.AccountId = createAndReturnDummmyAccountId(); 
                }else{
                    con.AccountId = dummyAccountId;
                }                          
            } 
             if(Schema.sObjectType.Contact.isCreateable()){
                 if(Schema.sObjectType.Contact.fields.AccountId.isCreateable() && Schema.sObjectType.Contact.fields.LastName.isCreateable() && Schema.sObjectType.Contact.fields.Email.isCreateable() &&
                  Schema.sObjectType.Contact.fields.Phone.isCreateable() && Schema.sObjectType.Contact.fields.FirstName.isCreateable()){
                       insert con; 
                   }
        }
        } catch (Exception e) {
            //Updated error msg by LK on 2024-10-21 to fix 00047931
            String errMsg = e.getMessage().containsIgnoreCase('DUPLICATES_DETECTED') ? 'DUPLICATES_DETECTED' : e.getStackTraceString();
            throw new AuraHandledException('Error Occured While Loading Component : <<' + errMsg + '>>');
        }
        return con;
            
    }
    
    /*
     * Purpose : returns Dummy Account Id 
     * Input :   
     * Returns : String of Account Id
*/

    private static String getDummyAccountId() {
        String accountId;
        List<Account> dummyAccount = [SELECT Id, Name from ACCOUNT where Name LIKE '%Dummy Account%' WITH SECURITY_ENFORCED LIMIT 1];
        if(!dummyAccount.isEmpty()) {
            accountId = dummyAccount[0].Id;
        }
        return accountId;
       /* else {
            return createAndReturnDummmyAccountId();
        }*/
    }
/*
    
    /*
     * Purpose : Creates DUmmy Account Record if not Present
     * Input :   
     * Returns : New created Account Id
*/
    
     private static String createAndReturnDummmyAccountId() {
        Account newDummyAccount = new account(name = DUMMY_ACCOUNT_NAME);
        try{
        if(Schema.sObjectType.Account.isCreateable()){
            if(Schema.sObjectType.Account.fields.name.isCreateable()){
                 insert newDummyAccount;
            }
        }
        }catch (Exception e) {
            throw new AuraHandledException('Error Occured While Loading Component : <<' + e.getStackTraceString() + '>>');
        }     
        return newDummyAccount.Id;
    }
    
   
    private static String createAccountRecord(String accountName){
        Account newAccount = New Account();
        try{
        newAccount.Name = accountName;
        if(Schema.sObjectType.Account.isCreateable()){
            if(Schema.sObjectType.Account.fields.Name.isCreateable()){
                insert newAccount; 
            }
        }
        }catch (Exception e) {
            throw new AuraHandledException('Error Occured While Loading Component : <<' + e.getStackTraceString() + '>>');
        } 
        return newAccount.Id;
    }
    

}