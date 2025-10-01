/**
* --------------------------------------------------------------------------------------------------
* Handler class designed to calculate the Last Touch point from Contact based on lasttouchpoint & 
* update Last Touch Point date and Id on Account.
* --------------------------------------------------------------------------------------------------
* @author         Anmol Uppal
* @modifiedBy     Anmol Uppal
* @version        1.0
* @created        2023-01-23
* @modified       2023-01-23
* @testClass      NavatarContactTriggerHandler_Test
* @organization   Navatar Group
*/
public without sharing class NavatarContactTriggerHandler {
    public static void OnAfterDel(List<Contact> oldContactList, Map<Id, Contact> oldContactMap) {
        Set<Id> accountIds = new Set<Id>();//Set for Accounts related to the Tasks in Trigger
        
        //Iterate all Contacts in Trigger 
        for(Contact oContact : oldContactList) {
            // Condition to check relevant Contacts 
            if((Trigger.isdelete) ) {
                accountIds.add(oContact.AccountId);
            }
        }
        
        if(accountIds.size()>0)
            updateAccounts(accountIds);
    }
    public static void OnAfterInsUpdUnDel(List<Contact> newContactList, Map<Id, Contact> oldContactMap) {
        Set<Id> accountIds = new Set<Id>();//Set for Accounts related to the Tasks in Trigger
        
        //Iterate all Contacts in Trigger 
        for(Contact nContact : newContactList) {
            if(((Trigger.isinsert || Trigger.isundelete) && nContact.navpeII_dev18__Last_Touch_Point__c != null && nContact.AccountId!=null) || 
               (Trigger.isupdate && ( oldContactMap.get(nContact.Id).AccountId != nContact.AccountId ||
                                     (nContact.navpeII_dev18__Last_Touch_Point__c != oldContactMap.get(nContact.Id).navpeII_dev18__Last_Touch_Point__c)))) {
                                         if(Trigger.isupdate && oldContactMap.get(nContact.Id).AccountId != nContact.AccountId)
                                             accountIds.add(oldContactMap.get(nContact.Id).AccountId);
                                         accountIds.add(nContact.AccountId);
                                     }
        }
        
        if(accountIds.size()>0)
            updateAccounts(accountIds);
    }
    //Method to Update Last Touchpoint Date on Accounts
    public static void updateAccounts(Set<Id> accountIds) {
        List<Account> updAccountLists = new List<Account>();
        if(accountIds.size()>0){
            String accountQueryforContact='Select Id,navpeII_dev18__Last_Touchpoint__c,navpeII_dev18__Last_Touchpoint_ID__c, (Select '
                +' navpeII_dev18__Last_Touchpoint_ID__c,navpeII_dev18__Last_Touch_Point__c from Contacts where navpeII_dev18__Last_Touch_Point__c!=null '
                +' ORDER BY navpeII_dev18__Last_Touch_Point__c DESC LIMIT 1) from Account where Id IN: accountIds';
            List<Account> conLastTouchPointAccList = Database.Query(accountQueryforContact);
            for(Account acc : conLastTouchPointAccList){
                if(Schema.SObjectType.Account.fields.navpeII_dev18__Last_Touchpoint__c.isUpdateable()){
                    if(acc.Contacts.size()>0) {
                        acc.navpeII_dev18__Last_Touchpoint__c=acc.Contacts[0].navpeII_dev18__Last_Touch_Point__c;
                        acc.navpeII_dev18__Last_Touchpoint_ID__c=acc.Contacts[0].navpeII_dev18__Last_Touchpoint_ID__c;
                    }
                    else{
                        acc.navpeII_dev18__Last_Touchpoint__c=null;
                        acc.navpeII_dev18__Last_Touchpoint_ID__c=null;
                    }
                    updAccountLists.add(acc);
                }
            }
        }
        
        //Checking if List is not empty and current User has permission to Update Accounts
        if(updAccountLists.size() > 0 && Schema.sObjectType.Account.isUpdateable()) {
            try{
                Database.SaveResult[] srList=Database.update(updAccountLists);
                Integer successCount=0;
                Integer failCount=0;
                for(Database.SaveResult sr:srList){
                    if(sr.isSuccess()){
                        successCount+=1;
                    }
                    else{
                        failCount+=1;
                    }
                }
                System.debug('Contact Trigger has '+successCount+' successful updations & '+failCount+' failed updations on Pipeline!');
            }
            catch(Exception e){
                System.debug('Error in Updating Accounts:: '+e.getMessage()+' at line '+e.getLineNumber());
            }
        }
    }
}