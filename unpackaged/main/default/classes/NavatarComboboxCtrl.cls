/****************************************************************************************************
** Module Name : Acuity 2.0 - Acuity
** Description : Used to handle Add to theme Acuity 2.0 Acuity.
** Throws : NA
** Calls : NA
** Organization : Navatar Group
** Product Name & Version : Acuity 2.0
** Revision History:-
** Version    Date(YYYY-MM-DD)    Author         Description of Action
** 1.0        2022-11-16          Anshika Ahuja
****************************************************************************************************/

public with sharing class NavatarComboboxCtrl { //Added by Tejaswini - Naming Convention
    // Method to fetch lookup search result   
     @AuraEnabled(cacheable=true)
     public static list<sObject> fetchLookupData(string searchKey , string sObjectApiName) {    
         List < sObject > returnList = new List < sObject > ();
 
         string sWildCardText = '%' + searchKey + '%';
         string sQuery = 'Select Id,Name From ' + sObjectApiName + ' Where Name Like : sWildCardText order by createdDate DESC LIMIT 5';
         List <sObject> tempList = database.query(String.escapeSingleQuotes(sQuery));
         for (sObject obj: tempList) {
             returnList.add(obj);
         }
         return returnList;
     }
     
     // Method to fetch lookup default value 
     @AuraEnabled
     public static sObject fetchDefaultRecord(string recordId , string sObjectApiName) {
         string sRecId = recordId;    
         string sQuery = 'Select Id,Name From ' + sObjectApiName + ' Where Id = : sRecId LIMIT 1';
         sObject tempObj = database.query(String.escapeSingleQuotes(sQuery));
         //for (sObject obj: database.query(sQuery)) {            return obj;        }
         if(tempObj!=null)
             return tempObj;
         else
             return null;
     }
     
 }