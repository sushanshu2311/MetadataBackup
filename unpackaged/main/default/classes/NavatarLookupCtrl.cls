/****************************************************************************************************

** Module Name : Activity Associations

** Description : Used to search record from objects that are used in AA.

** Throws : NA

** Calls : NA

** Organization : Navatar Group

** Product Name & Version : Activity Associations

** Revision History:-

** Version    Date(YYYY-MM-DD)    Author         Description of Action

** 1.0        2022-08-02          Keyur

****************************************************************************************************/
public with sharing class NavatarLookupCtrl {

    /****************************************************************************************************
    Purpose : get related data on search

    Input : searchString - inputed string from lwc
            searchObjects - all the setup objects from navatar setup objec used for activity association

    Returns : serialized string of matched reocrds
    ****************************************************************************************************/
    
    @AuraEnabled(cacheable=true)
    public static String getRelatedData(String searchString, String searchObjects) {
        try {

            // make searchString
            string soqlSearch = string.escapesinglequotes(searchString);
            searchString = '%' +searchString + '%';

            list<LookupWrapper> multiWrpCls = (list<LookupWrapper>)JSON.deserialize(searchObjects, list<LookupWrapper>.class);
            List<RecordWrapper> recordList = new List<RecordWrapper>();
            system.debug('multiWrpCls=='+multiWrpCls);

            List<string> soslObjList = new List<string>();
            Map<String, String> objNameVsObjIcon = new Map<String, String>();

            //generate dynamic sosl based on set-up objects of AA.
            For(LookupWrapper obj : multiWrpCls){
                objNameVsObjIcon.put(obj.objectName, obj.IconName);
                boolean isObjAccess = Schema.getGlobalDescribe().get(obj.objectName).getDescribe().isAccessible();
                if(isObjAccess){
                    // Bug 00047979 fixed by sudhanshu
                    string str = '';
                    if(obj.objectName == 'Contact')
                    {
                        str = string.escapesinglequotes(obj.objectName)+' ( ID, Name, Account.Name Where name like \''+String.escapeSingleQuotes(searchString) +'\')';
                    }
                    else{
                        str = string.escapesinglequotes(obj.objectName)+' ( ID, Name Where name like \''+String.escapeSingleQuotes(searchString) +'\')';
                    }
                    soslObjList.add(str);
                }
            }
            system.debug('soslObjList=='+soslObjList);
            List<List <sObject>> myQuery=new List<List <sObject>>();
            if(String.isNotBlank(soqlSearch) && soqlSearch.length()>2){
                string soslQry = 'FIND \''+ String.escapeSingleQuotes(soqlSearch) + '\'  IN ALL FIELDS RETURNING ' +  string.join(soslObjList,',');
            system.debug('soslQry=='+soslQry);
            myQuery = search.query(soslQry);
        }
            
            //get data from sosl result and store it on wrapperList
            For(List <sObject> sobjlist : myQuery){
                For(SObject sObj : sObjList){
                    RecordWrapper recWrap = new RecordWrapper();
                    recWrap.Name = (String)sObj.get('Name');
                    recWrap.Id = (String)sObj.get('Id');

                    Id recId = (String)sObj.get('Id');
                    String sObjName = recId.getSObjectType().getDescribe().getName();

                    //recWrap.iconName = objNameVsObjIcon.get(sObjName);
                    if(sObjName == 'User'){
                        recWrap.iconName = 'standard:user';
                    }else {
                        recWrap.iconName = objNameVsObjIcon.get(sObjName);
                    }
                    recWrap.objectName = sObjName;
                    // Bug 00047979 fixed by sudhanshu
                    recWRap.isContact = sObjName == 'Contact' ? true : false ;
                    if(sObjName == 'Contact'){
                        recWrap.actName = (string)sObj.getSObject('Account').get('Name');
                    }
                    recordList.add(recWrap);
                }
            }
            system.debug('recordList=='+recordList);

            return JSON.serialize(recordList);

        } catch (Exception e) {
            System.debug('==='+e);
            throw new AuraHandledException(e.getMessage());
        }
    }

    // to store the record data of matched records
    public class RecordWrapper{
        @AuraEnabled public string Name;
        @AuraEnabled public string Id;
        @AuraEnabled public string iconName;
        @AuraEnabled public string objectName;
        // Added By Sudhanshu to show account name of contact record
        @AuraEnabled public boolean isContact;
        @AuraEnabled public String actName;
    }

    // to store the data of AA set-up objects
    public class LookupWrapper{
        @AuraEnabled public String pluralLabel;
        @AuraEnabled public String objectName;  
        @AuraEnabled public String IconName; 
        @AuraEnabled public String objectLabel; 
        @AuraEnabled public boolean isCreateableAccess;
    }

}