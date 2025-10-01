/****************************************************************************************************
** Module Name : Acuity 2.0 - Theme-Add To Fund 
** Description : Controller Class For storing related Firms Info of The theme in wrapper containing info regarding recordType, recordTypeId, Name , Account Id
** Throws : NA
** Calls : NA
** Organization : Navatar Group
** Product Name & Version : Acuity 2.0
** Revision History:-
** Version    Date(YYYY-MM-DD)    Author         Description of Action
** 1.0        2024-03-08          Lakshya        Acuity Phase 3
****************************************************************************************************/

public with sharing class NavatarThemeAddToFundCtrl {//Changed Naming convention
    /*
     * Purpose : To Count Related Accounts Contacts
     * Input : accIds  [List of Selected Accounts]     
     * Returns : Returns true/false on the basis of Contacts count to redirect the screen to next popup
     */
    @AuraEnabled
    public static boolean getAccountsContacts(list<Id> accIds){
        try {
            Integer contactsListSize = [Select Id From Contact Where AccountId IN :accIds].size();
            if(contactsListSize > 0 ){
                return true;
            }
            return false;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    /*
     * Purpose : Fetches the Firms Related To The Theme Record
     * Input : recordId     [Record ID of the current record (Theme)]     
     * Returns : Info to be used for displaying the available records of firm as record type by returning FirmWrapper
     */
    @AuraEnabled(cacheable = true)
    public static string getThemeRelatedAccountRecords(string recId){
        try {
            String accField1 = Acuity_Setting__mdt.getInstance('Theme_Acc_Field1').Value__c;
            List<navpeII_dev18__Theme_Relation__c> relAccRecList = new List<navpeII_dev18__Theme_Relation__c>();
            String query = 'Select Id, '+accField1+', navpeII_dev18__Account__c, Account__r.RecordTypeId, Account__r.RecordType.Name From navpeII_dev18__Theme_Relation__c Where navpeII_dev18__Theme__c = :recId And navpeII_dev18__Account__c != NULL LIMIT ' + (Limits.getLimitQueryRows() - Limits.getQueryRows());
            relAccRecList = Database.query(query);

            List<FirmWrapper> firmRecordsList = new List<FirmWrapper>();
                For(navpeII_dev18__Theme_Relation__c tr : Database.query(query)){
                    FirmWrapper fw = new FirmWrapper();
                    fw.accRecTypeName = tr.navpeII_dev18__Account__r.RecordType.Name;
                    fw.accName = tr.navpeII_dev18__Account__r.Name;
                    fw.accountId = tr.navpeII_dev18__Account__c;
                    fw.accRecordTypeId = tr.navpeII_dev18__Account__r.RecordTypeId;
                    firmRecordsList.add(fw);
                }
           return JSON.serialize(firmRecordsList);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    // method is responsible of the Add to Fund functionality
	/* ******
     * method used in navatarResearchAdvanceResultLwc 
	 *  fundId : storing fund id
     *  fundName : storing fund name
	 *  accList : storing selected account id
	 */
    @AuraEnabled
    public static string addToFundFdr(string fundId, String fundName, string accList){
        try {
            Integer successInsertRecCount = 0;
            List<navpeII_dev18__Fundraising__c> fdrListToInsert = new List<navpeII_dev18__Fundraising__c>();            
            List<String> accIdList = (List<String>)JSON.deserialize(accList, List<String>.class);
            if(!accIdList.isEmpty()){
                List<Account> accObjList = new List<Account>();
                List<navpeII_dev18__Fundraising__c> fdrList = new List<navpeII_dev18__Fundraising__c>();
                List<String> createdFdrAccList = new List<String>();
                
                fdrList = [SELECT Id, navpeII_dev18__Legal_Name__c FROM navpeII_dev18__Fundraising__c WHERE navpeII_dev18__Legal_Name__c in:accIdList AND navpeII_dev18__Fund_Name__c =:fundId Limit : Limits.getLimitQueryRows() - Limits.getQueryRows()];
                for(navpeII_dev18__Fundraising__c fdr : fdrList){
                    createdFdrAccList.add(String.valueOf(fdr.navpeII_dev18__Legal_Name__c).substring(0,15));
                }
                accObjList = [SELECT Id, Name FROM account WHERE Id in:accIdList Limit : Limits.getLimitQueryRows() - Limits.getQueryRows()];
                
                For(Account acc : accObjList){
                    if(!createdFdrAccList.contains(String.valueOf(acc.id).substring(0,15))){
                        navpeII_dev18__Fundraising__c fdr = new navpeII_dev18__Fundraising__c();
                        fdr.Name = fundName + '-' + acc.Name;
                        fdr.navpeII_dev18__Fund_Name__c = fundId;
                        fdr.navpeII_dev18__Legal_Name__c = acc.Id;
                        fdrListToInsert.add(fdr);
                    }
                }
                Database.SaveResult[] srList =  Database.insert(fdrListToInsert, false);
                for(Database.SaveResult sr : srList){
                    if(sr.isSuccess()){
                        successInsertRecCount++;
                    }
                }
            }
            return fdrListToInsert.size() == successInsertRecCount ? 'success' : ((successInsertRecCount > 0) ? 'Some records failed to insert!' : 'failure');
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    // method is responsible of the creating Fundraising Contacts for Fund
	/* ******
     * method used in navatarResearchAdvanceResultLwc 
	 *  fundId : storing fund id
	 *  accList : storing selected account id
	 */
    @AuraEnabled
    public static string createFdrCon(string fundId, string accList){
        try {
            Integer successInsertRecCount = 0;
            List<String> accIdList = (List<String>)JSON.deserialize(accList, List<String>.class);
            List<String> fdrConList = new List<String>();
            List<navpeII_dev18__Fundraising_Contact__c> fdrConListToInsert = new List<navpeII_dev18__Fundraising_Contact__c>();
            if(!accIdList.isEmpty()){
                List<navpeII_dev18__Fundraising__c> fdrList = new List<navpeII_dev18__Fundraising__c>();
                Map<Id,Account> accObjList = new Map<Id,Account>([SELECT Id, Name FROM Account WHERE id in:accIdList LIMIT : Limits.getLimitQueryRows() - Limits.getQueryRows()]);
                Map<String, String> createdFdrAccList = new Map<String, String>();
                
                fdrList = [SELECT Id, navpeII_dev18__Legal_Name__c FROM navpeII_dev18__Fundraising__c WHERE navpeII_dev18__Legal_Name__c in:accIdList AND navpeII_dev18__Fund_Name__c =:fundId Limit : Limits.getLimitQueryRows() - Limits.getQueryRows()];
                for(navpeII_dev18__Fundraising__c fdr : fdrList){
                    createdFdrAccList.put(fdr.navpeII_dev18__Legal_Name__c, fdr.id);
                }
                //start changes for bug #00041204 fixes by salauddin sheikh
                List<navpeII_dev18__Fundraising_Contact__c> fdrConListSaved = new List<navpeII_dev18__Fundraising_Contact__c>();
                List<string> fdrConAccIds = new List<string>();
                fdrConListSaved = [SELECT Id, navpeII_dev18__Contact__c FROM navpeII_dev18__Fundraising_Contact__c WHERE navpeII_dev18__Fundraising__c =:createdFdrAccList.values() Limit : Limits.getLimitQueryRows() - Limits.getQueryRows()];
                for(navpeII_dev18__Fundraising_Contact__c fdrCon : fdrConListSaved){
                    fdrConAccIds.add(fdrCon.navpeII_dev18__Contact__c);
                }
                  //end changes for bug #00041204 fixes by salauddin sheikh
                for(Contact con : [SELECT id,accountid FROM contact WHERE accountid in:accObjList.keySet() Limit : Limits.getLimitQueryRows() - Limits.getQueryRows()]){
                    if(!fdrConAccIds.contains(con.id)){     //added for bug #00041204 fixes by salauddin sheikh
                    navpeII_dev18__Fundraising_Contact__c fdrCon = new navpeII_dev18__Fundraising_Contact__c();
                    fdrCon.navpeII_dev18__Institution__c = con.accountid;
                    fdrCon.navpeII_dev18__Contact__c = con.id;
                    fdrCon.navpeII_dev18__Fundraising__c = createdFdrAccList.get(con.accountid);
                    fdrConListToInsert.add(fdrCon);
                    }
                }
                Database.SaveResult[] srList =  Database.insert(fdrConListToInsert, false);
                for(database.SaveResult sr : srList){
                    if(sr.isSuccess()){
                        successInsertRecCount++;
                    }
                }
            }
            return fdrConListToInsert.size() == successInsertRecCount ? 'success' : ((successInsertRecCount > 0) ? 'Some records failed to insert!' : 'failure');
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    //Wrapper to store the available firm records of theme
    public class FirmWrapper{
        @AuraEnabled public string accRecTypeName;
        @AuraEnabled public string accName;
        @AuraEnabled public string accountId;
        @AuraEnabled public string accRecordTypeId;
    }
}