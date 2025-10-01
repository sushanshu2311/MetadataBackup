/****************************************************************************************************
** Module Name : Add to Fund - Acuity
** Description : Used to handle all the DML & schema related funtionalities of Add To Fund on Navatar Research & Navatar Theme Acuity
** Throws : NA
** Calls : NA
** Organization : Navatar Group
** Product Name & Version : Acuity 3.0
** Revision History:-
** Version    Date(YYYY-MM-DD)    Author         Description of Action
** 1.0        2024-03-08          Lakshya        Acuity Phase 3
****************************************************************************************************/
public with sharing class NavatarResearchAddToFundCtrl {
    // method is responsible of the Creating fund record functionality
	/* ******
     * method used in navatarResearchAdvanceResultLwc 
	 *  dealname : storing fund Name
	 */
    @AuraEnabled
    public static string createFund(string fundRec){
        try {
            navpeII_dev18__Fund__c fund = (navpeII_dev18__Fund__c)JSON.deserialize(fundRec, navpeII_dev18__Fund__c.class);
            Database.SaveResult sr = Database.insert(fund, false);
            return sr.getId();
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    // method is responsible of the Create fund's fdr functionality
	/* ******
     * method used in navatarResearchAdvanceResultLwc 
	 *  fundId : storing fund id
	 *  fundName : storing fund name
     *  accList : storing selected account id
	 */
    @AuraEnabled
    public static string createFdr(string fundId, String fundName, string accList){
        try {
            Integer successInsertRecCount = 0;
            List<String> accIdList = (List<String>)JSON.deserialize(accList, List<String>.class);
            List<navpeII_dev18__Fundraising__c> fdrListToInsert = new List<navpeII_dev18__Fundraising__c>();
            if(!accIdList.isEmpty()){
                List<Account> accObjList = new List<Account>();
                accObjList = [SELECT Id, Name FROM Account WHERE Id in:accIdList LIMIT :(Limits.getLimitQueryRows() - Limits.getQueryRows())];
                for(Account acc : accObjList){
                    navpeII_dev18__Fundraising__c fdr = new navpeII_dev18__Fundraising__c();
                    fdr.Name = acc.Name + ' - ' + fundName;//Modified by LK on 2024-05-08 to fix 00045092
                    fdr.navpeII_dev18__Fund_Name__c = fundId;
                    fdr.navpeII_dev18__Legal_Name__c = acc.Id;
                    fdrListToInsert.add(fdr);
                }
                
                Database.SaveResult[] srList =  Database.insert(fdrListToInsert, false);
                for(Database.SaveResult sr : srList){
                    if(sr.isSuccess()){
                        successInsertRecCount++;
                    } else {
                        system.debug('-->' + sr);
                    }
                }
            }
            return fdrListToInsert.size() == successInsertRecCount ? 'success' : ((successInsertRecCount > 0) ? 'Some records failed to insert!' : 'failure');
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
            List<String> accIdList = (List<String>)JSON.deserialize(accList, List<String>.class);
            List<navpeII_dev18__Fundraising__c> fdrListToInsert = new List<navpeII_dev18__Fundraising__c>();
            if(!accIdList.isEmpty()){
                List<Account> accObjList = new List<Account>();
                List<navpeII_dev18__Fundraising__c> fdrList = new List<navpeII_dev18__Fundraising__c>();
                List<String> createdFdrAccList = new List<String>();
                fdrList = [SELECT Id, navpeII_dev18__Legal_Name__c FROM navpeII_dev18__Fundraising__c WHERE navpeII_dev18__Legal_Name__c IN :accIdList AND navpeII_dev18__Fund_Name__c =:fundId Limit : Limits.getLimitQueryRows() - Limits.getQueryRows()];
                for(navpeII_dev18__Fundraising__c fdr : fdrList){
                    createdFdrAccList.add(String.valueOf(fdr.navpeII_dev18__Legal_Name__c).substring(0,15));
                }
                accObjList = [SELECT Id, Name FROM Account WHERE Id in:accIdList LIMIT :(Limits.getLimitQueryRows() - Limits.getQueryRows())];
                
                for(Account acc : accObjList){
                    if(!createdFdrAccList.contains(String.valueOf(acc.id).substring(0,15))){
                        navpeII_dev18__Fundraising__c fdr = new navpeII_dev18__Fundraising__c();
                        fdr.Name = acc.Name + ' - ' + fundName;//Modified by LK on 2024-05-08 to fix 00045092
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

    //Method for checking accouts related contact present 
    /* accIdList : account ids list*/
    @AuraEnabled
    public static string getConFromAcc(List<String> accIdList){
        List<Contact> cons = [Select Id,Name From Contact Where AccountId In:accIdList];
        if(cons.size()>0){
            return 'proceed';
        }
        else{
            return 'decline';
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
            List<navpeII_dev18__Fundraising_Contact__c> fdrConListToInsert = new List<navpeII_dev18__Fundraising_Contact__c>();
            if(!accIdList.isEmpty()){
                List<navpeII_dev18__Fundraising__c> fdrList = new List<navpeII_dev18__Fundraising__c>();
                Map<Id,Account> accObjList = new Map<Id,Account>([SELECT Id, recordtypeid, recordtype.name FROM account WHERE id in:accIdList Limit : Limits.getLimitQueryRows() - Limits.getQueryRows()]);
                Map<String, String> createdFdrAccList = new Map<String, String>();
                
                fdrList = [SELECT Id, navpeII_dev18__Legal_Name__c FROM navpeII_dev18__Fundraising__c WHERE navpeII_dev18__Legal_Name__c IN :accIdList AND navpeII_dev18__Fund_Name__c =:fundId Limit : Limits.getLimitQueryRows() - Limits.getQueryRows()];
                For(navpeII_dev18__Fundraising__c fdr : fdrList){
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
                for(Database.SaveResult sr : srList){
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

    // method is responsible of the creating Fundraising Contacts for Fund
	/* ******
     * method used in addContactsQuickLwc 
	 *  fundId : storing fund id
	 *  wrapperStr : object of row's account id, role field value, contact id
	 *  accountIds :storing selected account id
	 */
    @AuraEnabled
    public static string createSelectedFdrCon(String wrapperStr, String fundId, string accountIds ){
        try {
            List<String> accIds = (List<String>)JSOn.deserialize(accountIds, List<String>.class);
            List<FdrConWrapper> fdrConWrapperList = (List<FdrConWrapper>)JSON.deserialize(wrapperStr, List<FdrConWrapper>.class);
            List<navpeII_dev18__Fundraising__c> fdrList = new List<navpeII_dev18__Fundraising__c>();
            List<navpeII_dev18__Fundraising_Contact__c> fdrConListToInsert = new List<navpeII_dev18__Fundraising_Contact__c>();
            List<navpeII_dev18__Fundraising_Contact__c> fdrConListSaved = new List<navpeII_dev18__Fundraising_Contact__c>();
            Map<String, String> createdFdrAccList = new Map<String, String>();
            
            fdrList = [SELECT Id, navpeII_dev18__Legal_Name__c FROM navpeII_dev18__Fundraising__c WHERE navpeII_dev18__Legal_Name__c in:accIds AND navpeII_dev18__Fund_Name__c =:fundId Limit : Limits.getLimitQueryRows() - Limits.getQueryRows()];
            For(navpeII_dev18__Fundraising__c fdr : fdrList){
                createdFdrAccList.put(fdr.navpeII_dev18__Legal_Name__c, fdr.id);
            }

            List<string> fdrConAccIds = new List<string>();
            fdrConListSaved = [SELECT Id, navpeII_dev18__Contact__c FROM navpeII_dev18__Fundraising_Contact__c WHERE navpeII_dev18__Fundraising__c =:createdFdrAccList.values() Limit : Limits.getLimitQueryRows() - Limits.getQueryRows()];
            For(navpeII_dev18__Fundraising_Contact__c fdrCon : fdrConListSaved){
                fdrConAccIds.add(fdrCon.navpeII_dev18__Contact__c);
            }
            For(FdrConWrapper fcw: fdrConWrapperList){
                if(!fdrConAccIds.contains(fcw.conId)){
                    navpeII_dev18__Fundraising_Contact__c fdrCon = new navpeII_dev18__Fundraising_Contact__c();
                    fdrCon.navpeII_dev18__Institution__c = fcw.accId;
                    fdrCon.navpeII_dev18__Contact__c = fcw.conId;
                    fdrCon.navpeII_dev18__Fundraising__c = createdFdrAccList.get(fcw.accId);
                    fdrCon.navpeII_dev18__Role__c = fcw.roleName;//Replaced "fcw.fdrConName" with "fcw.roleName" by LK on 2024-05-21 to fix 00045885
                    fdrConListToInsert.add(fdrCon);
                }
            }
            Database.SaveResult[] srList = Database.Insert(fdrConListToInsert);
            List<String> successIds = new List<String>();
            for(Database.SaveResult sr : srList){
                if(sr.isSuccess()){
                    successIds.add(sr.getId());
                }
            }

            List<navpeII_dev18__Fundraising_Contact__c> newFdrConList = new List<navpeII_dev18__Fundraising_Contact__c>();
            newFdrConList = [SELECT Id, navpeII_dev18__Contact__c FROM navpeII_dev18__Fundraising_Contact__c WHERE Id in:successIds Limit : Limits.getLimitQueryRows() - Limits.getQueryRows()];
            List<FdrConWrapper> fdrConList = new List<FdrConWrapper>();
            For(navpeII_dev18__Fundraising_Contact__c fdrCon : newFdrConList){
                FdrConWrapper fcw = new FdrConWrapper();
                fcw.conId = fdrCon.navpeII_dev18__Contact__c;
                fcw.fdrConId = fdrCon.id;
                fdrConList.add(fcw);
            }
            return JSON.serialize(fdrConList);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    // method is responsible of getting role picklist value 
    //used in addContactsQuickLwc
    @AuraEnabled
    public static string getDefaultRole(){
        try {
            String defaultVal;
            Schema.DescribeFieldResult F = navpeII_dev18__Fundraising_Contact__c.navpeII_dev18__Role__c.getDescribe();
            List <Schema.PicklistEntry> pickVals = F.getPicklistValues();        
            for (Schema.PicklistEntry pv: pickVals) {
                if (pv.isDefaultValue()) {
                    defaultVal = pv.getValue();
                }    
            }
            return defaultVal;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    // method is responsible of getting fund name
	/* ******
     * method used in addContactsQuickLwc 
	 *  fundId : storing fund id
	 */
    @AuraEnabled
    public static string getFundName(string fundId){
        try {
            return [SELECT Id, Name from navpeII_dev18__Fund__c WHERE Id =: fundId ].Name;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    //Fetches allowed record types info for Create/Add Fund
    //Added below code by LK on 2024-04-11 to fix 00044462, 00044460
    @AuraEnabled(cacheable=true)
    public static List<RecordTypeWrapper> fetchAllowedAccRecTypeList(){
        try {
            Set<String> allowedAccRecTypeApiNamesSet = new Set<String>{'Individual_Investor', 'Institution', 'LimitedPartner'};
            List<RecordTypeWrapper> recTypeWrapperList = new List<RecordTypeWrapper>();
            for(RecordTypeInfo recTypeInfo: Schema.Account.SobjectType.getDescribe().getRecordTypeInfos()) {
                if(recTypeInfo.isAvailable() && recTypeInfo.isActive() && allowedAccRecTypeApiNamesSet.contains(recTypeInfo.getDeveloperName())) {
                    RecordTypeWrapper recTypeWrapper = new RecordTypeWrapper();
                    recTypeWrapper.recTypeId = recTypeInfo.getRecordTypeId();
                    recTypeWrapper.name = recTypeInfo.getName();
                    recTypeWrapperList.add(recTypeWrapper);
                }
            }
            return (recTypeWrapperList.size() > 0) ? recTypeWrapperList : null;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    public class FdrConWrapper{
        @AuraEnabled public string conId;
        @AuraEnabled public string fdrConId;
        @AuraEnabled public string accId;
        @AuraEnabled public string roleName;//Replaced "fdrConName" with "roleName" by LK on 2024-05-21 to fix 00045885
    }

    //Added below code by LK on 2024-04-11 to fix 00044462, 00044460
    public class RecordTypeWrapper{
        @AuraEnabled public String recTypeId;
        @AuraEnabled public String name;
    }
}