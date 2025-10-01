/****************************************************************************************************

** Module Name : Activity Associations

** Description : Used to get picklist values of object field.

** Throws : NA

** Calls : NA

** Organization : Navatar Group

** Product Name & Version : Activity Associations

** Revision History:-

** Version    Date(YYYY-MM-DD)    Author         Description of Action

** 1.0        2022-08-02          Keyur

****************************************************************************************************/
public with sharing class NavatarPicklistCtrl {
    
    /****************************************************************************************************
Purpose : Save event and task record

Input : objApiName - api name of object.
fieldName - api name of picklist field.
selectedValue - selected picklist value.

Returns : String if success returns recordid else error message
****************************************************************************************************/
    @AuraEnabled
    public static List < DataWrapper> getPickListValues(String objApiName, String fieldName, string selectedValue) {
        Set<String> classificationVals=new Set<String>();
        if(fieldName.contains('Classification__c')){
            for(Acuity_Setting__mdt actSett:[SELECT DeveloperName, Value__c FROM Acuity_Setting__mdt WHERE DeveloperName LIKE 'Acuity_Activity_Classification_Value%']){
                if(actSett.Value__c!='NA')
                    classificationVals.add(actSett.Value__c);
                System.debug('classificationVals'+classificationVals);
            }
        }
        // List < Map < String, String >> options = new List < Map < String, String >> ();
        List <DataWrapper> options = new List < DataWrapper> ();
        
        // get schema of object
        Map < String, Schema.SObjectType > objGlobalMap = Schema.getGlobalDescribe();
        Schema.SObjectType objType = Schema.getGlobalDescribe().get(objApiName);
        if (objType == null) {
            return options;
        }
        Schema.DescribeSObjectResult sobjectDescribe = objType.getDescribe();
        Map < String, Schema.SObjectField > fieldMap = sobjectDescribe.fields.getMap();
        if (fieldMap.get(fieldName) == null) {
            return options;
        }
        
        DataWrapper df = new DataWrapper();
        df.label = '-None-';
        df.value = '';
        options.add(df);
        
        List < Schema.PicklistEntry > pickListValues = fieldMap.get(fieldName).getDescribe().getPickListValues();
        //get picklist value and add it in to wrapper list
        for (Schema.PicklistEntry f: pickListValues) {
            DataWrapper dw = new DataWrapper();
            /* Map < String, String > values = new Map < String, String > {
'label' => f.getLabel(),
'value' => f.getValue()
}; */
            dw.label = f.getLabel();
            dw.value = f.getValue();
            
            //if value is matched with selectedValue, mark it is already selected
            if(f.getValue() == selectedValue) {
                dw.isSelected = true;
            }
            //revert code critical Bug Fix Nikita S
                options.add(dw);
           //revert code critical Bug Fix Nikita S
        }
        return options;
    }
    
    // strore picklist values
    public class DataWrapper{
        @AuraEnabled public string label;
        @AuraEnabled public string value;
        @AuraEnabled public boolean isSelected = false;
    }
}