/****************************************************************************************************

** Module Name : New Fundraising Activity

** Description : Used for fundraisingComp component.

** Throws : NA

** Calls : NA

** Organization : Navatar Group

** Revision History:-

** Version    Date(YYYY-MM-DD)    Author         Description of Action

** 1.0        2022-11-2022         Nikita Suresh

****************************************************************************************************/


public with sharing class NavatarAcuityFundraisingPopupCtrl {
    
    private static Map<String, Acuity_Setting__mdt> metadataFieldsAPiNames=new Map<String, Acuity_Setting__mdt>();
    private static String investmentCategory;
    
   
    
     /****************************************************************************************************
    Purpose : to get fund record details

    Input : recordId - the recordId of which details are needed

    Returns : List - one record with List 
    ****************************************************************************************************/
       
    public static fundWrapper getFund(Id recordId){
         String objectName = getNamespacePrefix()+'__Fund__c';
         String investmentCategory = [SELECT Value__c FROM Acuity_Setting__mdt WHERE DeveloperName = 'Acuity_FDR_PopUp_FundCreation3'].Value__c;
         fundWrapper fundWrap = new fundWrapper();
        try{ 
         fundWrap.investmenCategoryType = [SELECT Value__c FROM Acuity_Setting__mdt WHERE DeveloperName = 'Acuity_FDR_PopUp_Fund_InvetmentCategory2'].Value__c;
         fundWrap.portFoloioCompany = [SELECT Value__c FROM Acuity_Setting__mdt WHERE DeveloperName = 'Acuity_FDR_CompField_ValidationValue1'].Value__c;
         fundWrap.company = [SELECT Value__c FROM Acuity_Setting__mdt WHERE DeveloperName = 'Acuity_FDR_CompField_ValidationValue2'].Value__c;
         fundWrap.institution = [SELECT Value__c FROM Acuity_Setting__mdt WHERE DeveloperName = 'Acuity_FDR_LegalField_ValidationValue1'].Value__c;        
         fundWrap.limitedPartner = [SELECT Value__c FROM Acuity_Setting__mdt WHERE DeveloperName = 'Acuity_FDR_LegalField_ValidationValue2'].Value__c;
         fundWrap.investmentFundType = [SELECT Value__c FROM Acuity_Setting__mdt WHERE DeveloperName = 'Acuity_FDR_PopUp_Fund_InvetmentCategory1'].Value__c;
            if(Schema.sObjectType.navpeII_dev18__Fund__c.fields.navpeII_dev18__Investment_Category__c.isAccessible()){
                 String query = 'Select Id,Name,'+investmentCategory+' From '+objectName+' where Id = \''+String.escapeSingleQuotes(recordId)+'\' WITH SECURITY_ENFORCED';
         fundWrap.fund = Database.query(query);
            }else{
               String query = 'Select Id,Name From '+objectName+' where Id = \''+String.escapeSingleQuotes(recordId)+'\' WITH SECURITY_ENFORCED'; 
               fundWrap.fund = Database.query(query);
               
            }
        }catch(exception e){
          
            throw new AuraHandledException('Error Occured While Loading Component : <<' + e.getStackTraceString() + '>>');
        }    
        return fundWrap;
    }
    
 
/****************************************************************************************************
    Purpose : To set metadata fields

    Returns : List<String> - List of metadata fields
    ****************************************************************************************************/    
    
    public static List<String> setMetadataFieldsData(){ 
      List<String> fundLabels = new List<String>();
        try{
        String objectName = getNamespacePrefix()+'__Fundraising__c';   
        metadataFieldsAPiNames=Acuity_Setting__mdt.getAll();
        fundLabels.add(String.valueOf(metadataFieldsAPiNames.get('Acuity_FDR_PopUp_Field1').value__c));
        fundLabels.add(String.valueOf(metadataFieldsAPiNames.get('Acuity_FDR_PopUp_Field2').value__c));
        fundLabels.add(String.valueOf(metadataFieldsAPiNames.get('Acuity_FDR_PopUp_Field3').value__c));
        fundLabels.add(String.valueOf(metadataFieldsAPiNames.get('Acuity_FDR_PopUp_Field4').value__c));
        fundLabels.add(String.valueOf(metadataFieldsAPiNames.get('Acuity_FDR_PopUp_Field5').value__c));
        String legalName = (String.valueOf(metadataFieldsAPiNames.get('Acuity_FDR_PopUp_Field6').value__c));
        String company = (String.valueOf(metadataFieldsAPiNames.get('Acuity_FDR_PopUp_Field7').value__c));
         Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
         Schema.SObjectType leadSchema = schemaMap.get(objectName);
        fundLabels.add(leadSchema.getDescribe().fields.getMap().get(legalName).getDescribe().getLabel());
        fundLabels.add(leadSchema.getDescribe().fields.getMap().get(company).getDescribe().getLabel());
        fundLabels.add(String.valueOf(metadataFieldsAPiNames.get('Acuity_FDR_PopUp_Field6').value__c));    
        }catch(exception e){
            throw new AuraHandledException('Error Occured While Loading Component : <<' + e.getStackTraceString() + '>>');
        }          
        return fundLabels; 
        
    } 
    
    @AuraEnabled(cacheable=true)
    public static referenceWrapper getFundData(Id recordId){
        referenceWrapper reference = new referenceWrapper();
        reference.fundData = getFund(recordId);
        reference.labels = setMetadataFieldsData();
        return reference;
    }    

  
    /****************************************************************************************************
    Purpose : To insert new fundraising record

    Returns : object record - returns inserted record
    ****************************************************************************************************/ 
    @AuraEnabled
    public static sObject createFundRaising(String record,String fundRaisingName,Id fundName,Id legalId,String fundNewName,String legalNewName,String companyNewName,String tabChangeValue){
        Map<String, object> deserialized = (Map<String, object>) JSON.deserializeUntyped(record);
         metadataFieldsAPiNames=Acuity_Setting__mdt.getAll();
        String objectName = getNamespacePrefix()+'__Fundraising__c';
        sObject sObj = Schema.getGlobalDescribe().get(objectName).newSObject();
        String fundraisingFundName = (String.valueOf(metadataFieldsAPiNames.get('Acuity_FDR_PopUp_Field1').value__c));
        String companyName = (String.valueOf(metadataFieldsAPiNames.get('Acuity_FDR_PopUp_Field7').value__c));
        String legalName = (String.valueOf(metadataFieldsAPiNames.get('Acuity_FDR_PopUp_Field6').value__c));
        String closingName = (String.valueOf(metadataFieldsAPiNames.get('Acuity_FDR_PopUp_Field3').value__c));
        String stageName = (String.valueOf(metadataFieldsAPiNames.get('Acuity_FDR_PopUp_Field2').value__c));
        String likelyAmount = (String.valueOf(metadataFieldsAPiNames.get('Acuity_FDR_PopUp_Field5').value__c));
        String closingDate = (String.valueOf(metadataFieldsAPiNames.get('Acuity_FDR_PopUp_Field4').value__c));
        String fundRaisingNameField = (String.valueOf(metadataFieldsAPiNames.get('Acuity_QC_Firm_Field1').value__c));
        
        String fundNewId;
        String legalNewId;
        String companyId;
           try{ 
               if(String.isNotBlank(fundNewName)){
                 fundNewId = createFundRecord(fundNewName,tabChangeValue);
                   sObj.put(fundraisingFundName,fundNewId);
               }else{
                   sObj.put(fundraisingFundName,fundName);
               } 
                sObj.put(fundRaisingNameField,fundRaisingName);
               if(String.isNotBlank(companyNewName)){
                   companyId = createRecordCompany(companyNewName);
                   sObj.put(companyName,companyId);
               }else{
                  sObj.put(companyName,String.valueof(deserialized.get('companyId')));
               } 
             if(String.isNotBlank(legalNewName)){
                 legalNewId = createLegalRecord(legalNewName);
                  sObj.put(legalName,legalNewId);               
             }else{
                  sObj.put(legalName,legalId);
             }
              sObj.put(closingName,String.valueof(deserialized.get('closingField')));  
              sObj.put(stageName,String.valueof(deserialized.get('stage')));
              sObj.put(likelyAmount, Integer.valueOf(deserialized.get('likelyAmountField')));
              sObj.put(closingDate,deserialized.get('closingDateField')!=null?Date.valueOf(String.valueOf(deserialized.get('closingDateField'))):null);
              if(Schema.sObjectType.navpeII_dev18__Fundraising__c.isCreateable()){
             insert sobj;
              }
          }catch(exception e){
            throw new AuraHandledException('Error Occured While Loading Component : <<' +e.getMessage()+ '>>');
        }
        return sobj;
    }
    
    @AuraEnabled(cacheable=true)
    public static fundWrapper getFirm(Id recordId){
         fundWrapper fundWrap = new fundWrapper();
         fundWrap.portFoloioCompany = [SELECT Value__c FROM Acuity_Setting__mdt WHERE DeveloperName = 'Acuity_FDR_CompField_ValidationValue1'].Value__c;
         fundWrap.company = [SELECT Value__c FROM Acuity_Setting__mdt WHERE DeveloperName = 'Acuity_FDR_PopUp_Field3'].Value__c;
         String query = 'Select Id,Name From Account where Id = \''+String.escapeSingleQuotes(recordId)+'\''; 
         fundWrap.firm = Database.query(query); 
         return fundWrap;
    }
    
     public class fundWrapper{
     @AuraEnabled public String investmenCategoryType;
     @AuraEnabled public String portFoloioCompany;
     @AuraEnabled public String company;
     @AuraEnabled public String institution;
     @AuraEnabled public String limitedPartner;
     @AuraEnabled public String investmentFundType;    
     @AuraEnabled Public List<sObject> fund = new List<sObject>();  
     @AuraEnabled public List<Account> firm = New List<Account>();
         
}
    
    public class referenceWrapper{
        @AuraEnabled public fundWrapper fundData;
        @AuraEnabled public List<String> labels;
    }
    
     /****************************************************************************************************
    Purpose : To get Record Type Name

    Returns : Record Type Name
    ****************************************************************************************************/ 
    
/*    @AuraEnabled
    public static String getRecordTypeName(Id recordId){
        List<Account> accounts = New List<Account>();
        String recordTypeName;
        try{
            accounts = [Select Id,Name,RecordType.Name from Account where Id =: recordId WITH SECURITY_ENFORCED];
           recordTypeName = accounts[0].RecordType.Name;
        }catch(exception e){             
            throw new AuraHandledException('Error Occured While Loading Component : <<' + e.getStackTraceString() + '>>');
        }
        return recordTypeName;
    }*/
    
     /****************************************************************************************************
    Purpose : To insert new fund record

    Returns : Returns Id of the newly created fund record
    ****************************************************************************************************/ 
    
     @TestVisible
    private static String createFundRecord(String fundName,String tabValue){
        String objectName = getNamespacePrefix()+'__Fund__c';
        sObject sObj = Schema.getGlobalDescribe().get(objectName).newSObject();
         metadataFieldsAPiNames=Acuity_Setting__mdt.getAll();
         try{
        String fundNewName = (String.valueOf(metadataFieldsAPiNames.get('Acuity_FDR_PopUp_FundCreation1').value__c));
        String fundType = (String.valueOf(metadataFieldsAPiNames.get('Acuity_FDR_PopUp_FundCreation2').value__c));
        String investmentCategory = (String.valueOf(metadataFieldsAPiNames.get('Acuity_FDR_PopUp_FundCreation3').value__c));
        sObj.put(fundNewName,fundName);
        sobj.put(fundType,'Fund');
        sobj.put(investmentCategory,tabValue);
         if(Schema.sObjectType.navpeII_dev18__Fund__c.isCreateable()){
               insert sobj;
         }
         } catch (Exception e) {
          throw new AuraHandledException('Error Occured While Loading Component : <<' + e.getStackTraceString() + '>>');
        }
        return sobj.Id;
    }
    
     /****************************************************************************************************
    Purpose : To insert new Company record

    Returns :Returns Id of the newly created company record
    ****************************************************************************************************/ 
     @TestVisible
    private static String createRecordCompany(String company){
        Account acc = new Account();
          Id compRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Company').getRecordTypeId();
         try{
             acc.Name = company;
             acc.RecordTypeId = compRecordTypeId;
              if(Schema.sObjectType.Account.isCreateable()){
                   if(Schema.sObjectType.Account.fields.Name.isCreateable() && Schema.sObjectType.Account.fields.RecordTypeId.isCreateable()){
              insert acc;
            }
          }
        } catch (Exception e) {
            throw new AuraHandledException('Error Occured While Loading Component : <<' + e.getStackTraceString() + '>>');
        }
        return acc.Id; 
    }

   /****************************************************************************************************
    Purpose : To insert new Firm record

    Returns : Returns Id of the newly created Firm record
    ****************************************************************************************************/ 
    @TestVisible
    private static String createLegalRecord(String accountName){
          Account acc = new Account();
          Id instiRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Institution').getRecordTypeId();
        try{
             acc.Name = accountName;
             acc.RecordTypeId = instiRecordTypeId;
              if(Schema.sObjectType.Account.isCreateable()){
                  if(Schema.sObjectType.Account.fields.Name.isCreateable() && Schema.sObjectType.Account.fields.RecordTypeId.isCreateable()){
                      insert acc;
                  }
            }   
        } catch (Exception e) {
            throw new AuraHandledException('Error Occured While Loading Component : <<' + e.getStackTraceString() + '>>');
        }
        return acc.Id;
    }
    
     /****************************************************************************************************
    Purpose : To get fund record details

    Returns : Returns List of sObject 
    ****************************************************************************************************/ 
    
    @AuraEnabled
    public static List<sObject> getFundRecordDetails(Id fundId){
        List<sObject> fundData = New List<sObject>();
        String objectName = getNamespacePrefix()+'__Fund__c';
        sObject sObj = Schema.getGlobalDescribe().get(objectName).newSObject();
        metadataFieldsAPiNames=Acuity_Setting__mdt.getAll(); 
        String investmentCategory = (String.valueOf(metadataFieldsAPiNames.get('Acuity_FDR_PopUp_FundCreation3').value__c));
         if(Schema.sObjectType.navpeII_dev18__Fund__c.fields.navpeII_dev18__Investment_Category__c.isAccessible()){
               String query = 'Select Id,Name,'+investmentCategory+' From '+objectName+' where Id = \''+String.escapeSingleQuotes(fundId)+'\' WITH SECURITY_ENFORCED';
               fundData = Database.query(query); 
            }else{
               String query = 'Select Id,Name From '+objectName+' where Id = \''+String.escapeSingleQuotes(fundId)+'\' WITH SECURITY_ENFORCED';
               fundData = Database.query(query); 
            }
       //String query = 'Select Id,Name,'+investmentCategory+' From '+objectName+' where Id = \''+String.escapeSingleQuotes(fundId)+'\'';
       // List<sObject> fundData = Database.query(query); 
        return fundData;
    }
    
    /****************************************************************************************************
    Purpose : To get namespace prefix

    Returns : returns namespace prefix
    ****************************************************************************************************/
    
    private static String getNamespacePrefix(){
        try{ 
            return [SELECT NamespacePrefix FROM ApexClass WHERE Name = 'FileUploaderCtrl'].NamespacePrefix;
        } catch (Exception e) {
            throw new AuraHandledException('ERR_MSG' + ' : <<' + e.getStackTraceString() + '>>');
        }
    }
  
}