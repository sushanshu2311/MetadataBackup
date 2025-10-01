/*************************************************
********************************
** Module Name : IndividualInvestorSetup_Ctlr
** Description : This apex class is responsible for following things.
    1. Get Object API Name, Label  dynamically, and bind values on the page.
    2. Get IconURL of sObject dynamically and bind with fields.
** Throws : NA
** Calls : NA
** Test Class :  Not yet**
** Organization : Navatar Group
** Product Name & Version : PE 3.5
** Revision History:-
** Version Date         Author 
** 3.5     06/06/2016   Faiz Ahmed 
*************************************************
********************************/

public with sharing class IndividualInvestorSetup_Ctlr 
{
    public string selField{get;set;}                                /*Property to get value from page.*/
    public string APIsOfSelectedValues{get;set;}                    /*API names of selected sObjects and Their Field Labels.*/
    public Map<string, string> FieldLabelVsApi{get;set;}            /*This Map will hold objApiNameVsFieldApiName as a key AND ObjectLabelVsFieldLabel as a value, coming from Utility class; eg: Account:AccountNumber=Institution:Institution Number*/
    public Map<string, string> sObjNameVsIconURL{get;set;}          /*This Map will hold objectApiName its ImageURL in SF, coming from utility.*/
    public String strNameSpace{get;set;}                            /*Get NameSpace Dynamically*/
    public String iisSavedValues{get;set;}                          /*It will hold all the values saved in IIS at backend.*/  
    public Boolean isIICreation{get;set;}                           /*It will identify checkbox will be true/false, on the basis of Org_Setting__mdt.*/
    public List<Navatar_Setup__c> lstNavSetup;                      /*It will hold the stored setting of Org_Setting__mdt in IIS variable. */
    public List<Org_Setting__mdt> lstOrgSett;                       /*It holds Org Setting Values.*/
    public string contactIconUrl{get;set;}                          /*It holds the IconURL of contact.*/
    public string accountIconUrl{get;set;}                          /*It holds the IconURL of account.*/
    public string revertToDefaultData{get;set;}                     /*It contains default values that will restore the default fields.*/
    public boolean isAdminSettingOn{get;set;}                       /*Show check/uncheck on the basis of admin settings.*/
    public String strPageName{get;set;}
    public String strAccountLabel{get;set;}
    public String strContactLabel{get;set;}
    /*@Description: Non Parameterized Constructor of Class, execute on page load.*/
    public IndividualInvestorSetup_Ctlr()
    {
        try
        {
            SObjectType accountType = Schema.getGlobalDescribe().get('Contact');
            Map<String,Schema.SObjectField> mfields = accountType.getDescribe().fields.getMap();
            
            isAdminSettingOn = true;
            lstOrgSett = new List<Org_Setting__mdt>();
            strNameSpace = CommonUtility.strNameSpacePrefix;
            strNameSpace = strNameSpace.toLowerCase();
            lstNavSetup = new List<Navatar_Setup__c>();
            isIICreation = false;
            strPageName = '';
            strAccountLabel='';
            strContactLabel='';
            
            // SK: 7Dec2017
            if(Schema.sObjectType.Org_Setting__mdt.isAccessible() && Schema.sObjectType.Org_Setting__mdt.Fields.IsActive__c.isAccessible()
                && Schema.sObjectType.Org_Setting__mdt.Fields.Label.isAccessible() && Schema.sObjectType.Org_Setting__mdt.Fields.DeveloperName.isAccessible()
                
            ){
                lstOrgSett = [SELECT label, IsActive__c, developername  FROM Org_Setting__mdt where developername ='Ind_Inv_Creation' LIMIT 1];
            }
            
            if(lstOrgSett.size() > 0)
                isIICreation = lstOrgSett[0].IsActive__c;
            
            // SK: 7Dec2017
            if(Schema.sObjectType.Navatar_Setup__c.isAccessible() && Schema.sObjectType.Navatar_Setup__c.Fields.IIS__c.isAccessible() && 
                Schema.sObjectType.Navatar_Setup__c.Fields.Admin_Setting__c.isAccessible()
            ){
                lstNavSetup = [SELECT IIS__c FROM Navatar_Setup__c where admin_setting__c = true LIMIT 1];
            }
            
            if(lstNavSetup.size() > 0)
                iisSavedValues = lstNavSetup[0].IIS__c;
            else
                isAdminSettingOn = false;
            describeAndExtractSObjectData();
        }
        catch (Exception ex) 
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Exception in Constructor : '+ex)); 
        }
    }

    /*
        @Description: This method will extract all the details (sObject Fields API Names & SF IconURL) from the Describe Call, coming from CommontUtility.
        @Parameter: No parameter required.
    */
    public void describeAndExtractSObjectData() 
    {
        try 
        {
            FieldLabelVsApi = new Map<string, string>();
            sObjNameVsIconURL = new Map<string, string>();
            list<string> lstObject = new list<string>();
            lstObject.add('Account');
            lstObject.add('Contact');
            FieldLabelVsApi = CommonUtility.describeSObject(lstObject);
            sObjNameVsIconURL = CommonUtility.describeSFTabs(lstObject);
            for(string objName : lstObject)
            {
            List<Schema.DescribeSObjectResult> describeSobjectsResult = Schema.describeSObjects(new List<String>{objName }); // this can accept list of strings, we describe only one object here
            if(objName == 'Account')
             strAccountLabel  = describeSobjectsResult[0].getLabel();
            else if(objName == 'Contact')
             strContactLabel  = describeSobjectsResult[0].getLabel(); 
            }
            Set<String> splitAccountContact = new Set<string>();
            
            if(FieldLabelVsApi.size() > 0)   
            { 
                revertToDefaultData='';
                string revertToDefaultDataAcc='';
                string revertToDefaultDataCon='';
                
                list <String> lstNonShowContactFileds = new list <String>();
                lstNonShowContactFileds.add('Salutation');
                lstNonShowContactFileds.add('FirstName');
                lstNonShowContactFileds.add('LastName');
                lstNonShowContactFileds.add('Description');
                lstNonShowContactFileds.add('Phone');
                lstNonShowContactFileds.add('Fax');
                lstNonShowContactFileds.add('MobilePhone');
                lstNonShowContactFileds.add('Email');
                lstNonShowContactFileds.add('MailingCity');
                lstNonShowContactFileds.add('MailingState');
                lstNonShowContactFileds.add('MailingCountry');
                lstNonShowContactFileds.add('MailingPostalCode');
                lstNonShowContactFileds.add('MailingStreet');
                lstNonShowContactFileds.add('OtherCity');
                lstNonShowContactFileds.add('OtherCountry');
                lstNonShowContactFileds.add('OtherPostalCode');
                lstNonShowContactFileds.add('OtherState');
                lstNonShowContactFileds.add('OtherStreet');
                lstNonShowContactFileds.add('AccountId');
                lstNonShowContactFileds.add('Account');
                lstNonShowContactFileds.add('MailingLatitude');
                lstNonShowContactFileds.add(strNameSpace+'Exact_Position__Latitude__s');
                lstNonShowContactFileds.add('OtherLatitude');
                lstNonShowContactFileds.add('MailingLongitude');
                lstNonShowContactFileds.add(strNameSpace+'Exact_Position__Longitude__s');
                lstNonShowContactFileds.add('OtherLongitude');
                lstNonShowContactFileds.add('OwnerId');
                
                list <String> lstNonShowAccountFileds = new list <String>();
                lstNonShowAccountFileds.add('Name');
                lstNonShowAccountFileds.add('BillingStreet');
                lstNonShowAccountFileds.add('BillingCity');
                lstNonShowAccountFileds.add('BillingState');
                lstNonShowAccountFileds.add('BillingPostalCode');
                lstNonShowAccountFileds.add('BillingCountry');
                lstNonShowAccountFileds.add('IsCustomerPortal');
                lstNonShowAccountFileds.add('ShippingCity');
                lstNonShowAccountFileds.add('ShippingState');
                lstNonShowAccountFileds.add('ShippingCountry');
                lstNonShowAccountFileds.add('ShippingPostalCode');
                lstNonShowAccountFileds.add('ShippingStreet');
                lstNonShowAccountFileds.add('Description');
                lstNonShowAccountFileds.add('BillingLatitude');
                lstNonShowAccountFileds.add('BillingLongitude');
                lstNonShowAccountFileds.add('BillingGeocodeAccuracy');
                lstNonShowAccountFileds.add('ShippingLatitude');
                lstNonShowAccountFileds.add('ShippingLongitude');
                
                
               /*Keys holds the sObjectApiNameVsFieldApiName*/
                for(string FieldKeys : FieldLabelVsApi.keyset() )
                {   
                     
                     string FieldKeysTemp = FieldKeys.replace(strNameSpace,'');
                     String[] arrayObjectApi = FieldKeysTemp.split(':');
                     
                     if(arrayObjectApi[0] == 'Contact')
                     {
                        for(String nonShowFieledObj : lstNonShowContactFileds)
                        {
                            if(arrayObjectApi[1] == nonShowFieledObj)
                            {
                                FieldLabelVsApi.remove(FieldKeys);
                                FieldLabelVsApi.remove(FieldKeysTemp);
                            }
                        }                           
                     }
                     else if(arrayObjectApi[0] == 'Account')
                     {
                         for(String nonShowFieledObj : lstNonShowAccountFileds)
                         {
                            if(arrayObjectApi[1] == nonShowFieledObj)
                            {  
                                FieldLabelVsApi.remove(FieldKeys);
                                FieldLabelVsApi.remove(FieldKeysTemp);
                            } 
                         }
                     }
                    
                    if( (FieldKeys.indexOf('Account:') > -1 && FieldKeys.indexOf('fund_types__c') > -1)  || (FieldKeys.indexOf('Account:') > -1 && FieldKeys.indexOf('industries__c') > -1) )
                    {
                        revertToDefaultDataAcc = revertToDefaultDataAcc + FieldKeys+',';
                    }
                    else if(FieldKeys.indexOf('Contact:assistantname') > -1 || FieldKeys.indexOf('Contact:assistantphone') > -1 )
                    {
                        revertToDefaultDataCon = FieldKeys +',' +revertToDefaultDataCon;
                    }
                }
                
                revertToDefaultData = revertToDefaultDataAcc.removeEnd(',') +';' + revertToDefaultDataCon.removeEnd(',');
            }
            
           /*Extract sObject Icons & assign to property.*/
            
            if(sObjNameVsIconURL.size() > 0 )
            {
                if(sObjNameVsIconURL.containsKey('Account'))
                    accountIconUrl = sObjNameVsIconURL.get('Account');
                if(sObjNameVsIconURL.containsKey('Contact'))
                    contactIconUrl = sObjNameVsIconURL.get('Contact');
            }
            
        } 
        catch (Exception ex) 
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Exception in describeAndExtractSObjectData : '+ex)); 
        }
    }
    
    /*
        @Description: On click of RevertToDefault button, it will restore the default values.
    */
    public pageReference revertToDefaultAct()
    {
        try
        {
            if(lstNavSetup.Size()>0)
            {
                
                if(Schema.sObjectType.Navatar_Setup__c.fields.IIS__c.isUpdateable()){
                    lstNavSetup[0].IIS__c = revertToDefaultData;
                }
                if(Schema.sObjectType.Navatar_Setup__c.isUpdateable()){
                    update lstNavSetup;
                }
            }
            PageReference ReturnPage = new PageReference('/apex/Individual_Investor_setup'); 
            ReturnPage.setRedirect(true); 
            return ReturnPage; 
        }
        catch(Exception ex)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Error in restoreToDefaultAct : '+ex)); 
            return null; 
        }
    }
    
    /*
        @Description: Method called on click of Save button.
        @Parameter1: API Names of selected values, sObjectAPINameVsFieldAPIName, coming from page. eg: Account:AccountSource
    */
    public pageReference saveIISetupAct()
    {
        try
        {
            if(lstOrgSett.size() > 0)
            {
                CustomMetadataService.updateMetadata(new List<SObject> {lstOrgSett[0]}, isIICreation);
            }
            if(lstNavSetup.Size()>0)
            {
                
                if(Schema.sObjectType.Navatar_Setup__c.fields.IIS__c.isUpdateable()){
                    lstNavSetup[0].IIS__c = APIsOfSelectedValues;
                }
                if(Schema.sObjectType.Navatar_Setup__c.isUpdateable()){
                    update lstNavSetup;
                }
            }
            PageReference ReturnPage = new PageReference('/apex/Individual_Investor_setup'); 
            ReturnPage.setRedirect(true); 
            return ReturnPage; 
        }
        catch(Exception ex)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Exception in saveIISetupAct : '+ex)); 
            return null; 
        }
    }
     /*
    @Description: Method called on click page name to redirect page.   
    */ 
    public PageReference redirectpage() {
        PageReference pageRef = new PageReference('/apex/'+strPageName+'');
        pageRef.setRedirect(true);
        return pageRef;
    }
    
    public PageReference onCancel(){
        PageReference orderPage = new PageReference('/apex/Individual_Investor_setup');
        orderPage.setRedirect(true);
        return orderPage;         
    }
}