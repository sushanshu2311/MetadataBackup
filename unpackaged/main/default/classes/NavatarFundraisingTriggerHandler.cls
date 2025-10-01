/**
* --------------------------------------------------------------------------------------------------
* Handler class designed to calculate the Last Touch point from Fundraising based on lasttouchpoint & 
* update Last Touch Point date and Id on Fund.
* --------------------------------------------------------------------------------------------------
* @author         Deepak Singh
* @version        1.0
* @created        2024-03-21
* @testClass      
* @organization   Navatar Group
*/
public without sharing class NavatarFundraisingTriggerHandler {

    //Method to Update Last Touchpoint Date on Fund
    public static void updateFund(List<Id> fundIds) {
        List<navpeII_dev18__Fund__c> updFundLists = new List<navpeII_dev18__Fund__c>();
        if(fundIds.size()>0){

            // Bug Id - 00045806 to fix API name and Label
            String fundqueryForFdr='Select Id,navpeII_dev18__Last_Touch_Point__c,navpeII_dev18__Last_Touchpoint_ID__c, (Select '
                +' navpeII_dev18__Last_Touchpoint_ID__c,navpeII_dev18__Last_Touch_Point__c from navpeII_dev18__Fundraising__r where navpeII_dev18__Last_Touch_Point__c!=null '
                +' ORDER BY navpeII_dev18__Last_Touch_Point__c DESC LIMIT 1) from navpeII_dev18__Fund__c where Id IN: fundIds';
            List<navpeII_dev18__Fund__c> fdrLTPFundLst = Database.Query(fundqueryForFdr);
            // for(navpeII_dev18__Fund__c fd : [Select Id,navpeII_dev18__Last_Touch_Point__c,navpeII_dev18__Last_Touch_Id__c, (Select navpeII_dev18__Last_Touch_Id__c,navpeII_dev18__Last_Touch_Point__c from navpeII_dev18__Fundraising__r where navpeII_dev18__Last_Touch_Point__c!=null 
            //  ORDER BY navpeII_dev18__Last_Touch_Point__c DESC LIMIT 1) from navpeII_dev18__Fund__c where Id IN: fundIds]){
            for(navpeII_dev18__Fund__c fd : fdrLTPFundLst){    
                if(Schema.SObjectType.navpeII_dev18__Fund__c.fields.navpeII_dev18__Last_Touch_Point__c.isUpdateable()){
                    if(fd.navpeII_dev18__Fundraising__r.size()>0) {
                        fd.navpeII_dev18__Last_Touch_Point__c=fd.navpeII_dev18__Fundraising__r[0].navpeII_dev18__Last_Touch_Point__c;
                        fd.navpeII_dev18__Last_Touchpoint_ID__c=fd.navpeII_dev18__Fundraising__r[0].navpeII_dev18__Last_Touchpoint_ID__c;
                    }
                    else{
                        fd.navpeII_dev18__Last_Touch_Point__c=null;
                        fd.navpeII_dev18__Last_Touchpoint_ID__c=null;
                    }
                    updFundLists.add(fd);
                }
            }
        }
        
        //Checking if List is not empty and current User has permission to Update Fund
        if(updFundLists.size() > 0 && Schema.sObjectType.navpeII_dev18__Fund__c.isUpdateable()) {
            try{
                Database.SaveResult[] srList=Database.update(updFundLists);
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
                System.debug('Fundraising Trigger has '+successCount+' successful updations & '+failCount+' failed updations on Fund!');
            }
            catch(Exception e){
                System.debug('Error in Updating Fund:: '+e.getMessage()+' at line '+e.getLineNumber());
            }
        }
    }
}