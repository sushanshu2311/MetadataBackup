/****************************************************************************************************
** Module Name : Acuity 2.0 - Theme-Deal Trigger
** Description : Handler class for Record Triggered automation of adding Company on Deals(s) and 
**					adding Theme(s) to the Deal(s) refered by the Company.
** Throws : NA
** Calls : NA
** Organization : Navatar Group
** Product Name & Version : Acuity 2.0
** Revision History:-
** Version    Date(YYYY-MM-DD)    Author         Description of Action
** 1.0        2022-11-18          Anmol
** 2.0        2022-11-25          Adil Aleem   
****************************************************************************************************/
public with sharing class NavatarDealTriggerHandler{
    /*
* Purpose : Checks whether Company is Tagged to Deal, 
if not, no operation performed.
* Returns : nothing
*/
    public static void onBeforeInsrtDeal(List<navpeII_dev18__Pipeline__c> dealTriggerList){
        //Deal4Company:Start
        Map<navpeII_dev18__Pipeline__c,Account> dealIdVsCompanyNameMap=new Map<navpeII_dev18__Pipeline__c,Account>();
        List<navpeII_dev18__Pipeline__c> updatedDealList=new List<navpeII_dev18__Pipeline__c>();
        //End
        
        for(navpeII_dev18__Pipeline__c deal:dealTriggerList){
            if(String.isBlank(deal.navpeII_dev18__Company__c)){
                Account acc=new Account(name=deal.Name,isAutoCreated__c=true);
                dealIdVsCompanyNameMap.put(deal,acc);
            }
        }
        //Deal4Company:Start
        if(dealIdVsCompanyNameMap.size()>0 && Schema.sObjectType.Account.isCreateable()){
            try{
                insert dealIdVsCompanyNameMap.values();
            }
            catch(Exception e){
                System.debug('Error while saving Account record(s): '+e.getMessage());
            }
            
            for(navpeII_dev18__Pipeline__c deal:dealIdVsCompanyNameMap.keySet()){
                if(Schema.sObjectType.navpeII_dev18__Pipeline__c.fields.navpeII_dev18__Company__c.isUpdateable())
                    deal.navpeII_dev18__Company__c=dealIdVsCompanyNameMap.get(deal).Id;
                updatedDealList.add(deal);
            }
            if(updatedDealList.size()>0 && Schema.sObjectType.navpeII_dev18__Pipeline__c.isUpdateable()){
                try{
                    update updatedDealList;
                }
                catch(Exception e){
                    System.debug('Error while saving Deal record(s): '+e.getMessage());
                }
            }
        }
        //End
    }
        /*
* Purpose : Checks whether Company is Tagged to Deal, 
if yes, checks whether a Theme is Tagged to the Company,
if yes checks whether Deal linked to the Company is linked to the Theme
if no, no operation performed.
* Returns : nothing
*/
    public static void onAfterInsrtDeal(List<navpeII_dev18__Pipeline__c> dealTriggerList){
        //Deal4Theme:Start
        Map<Id,Set<Id>> accountIdVsDealIdsMap=new Map<Id,Set<Id>>();
        Map<Id,Set<Id>> themeIdVsDealIdsMap=new Map<Id,Set<Id>>();
        Set<Id> dealIds=new Set<Id>();
        List<navpeII_dev18__Theme_Relation__c> insertThemeRelation=new List<navpeII_dev18__Theme_Relation__c>();
        //End
        for(navpeII_dev18__Pipeline__c deal:dealTriggerList){
            if(String.isNotBlank(deal.navpeII_dev18__Company__c)){
                if(accountIdVsDealIdsMap.containsKey(deal.navpeII_dev18__Company__c)){
                    Set<Id> dupePipeSet=accountIdVsDealIdsMap.get(deal.navpeII_dev18__Company__c);
                    accountIdVsDealIdsMap.remove(deal.navpeII_dev18__Company__c);
                    dupePipeSet.add(deal.Id);
                    accountIdVsDealIdsMap.put(deal.navpeII_dev18__Company__c, dupePipeSet);
                }
                else{
                    Set<Id> newPipeSet=new Set<Id>();
                    newPipeSet.add(deal.Id);
                    accountIdVsDealIdsMap.put(deal.navpeII_dev18__Company__c, newPipeSet);
                }
            }
        }
        //Deal4Theme:Start
        for(navpeII_dev18__Theme_Relation__c tr: [Select Id,navpeII_dev18__Deal__c,navpeII_dev18__Account__c,navpeII_dev18__Theme__c from navpeII_dev18__Theme_Relation__c where navpeII_dev18__Account__c IN: accountIdVsDealIdsMap.keySet() WITH SECURITY_ENFORCED]){
            if(accountIdVsDealIdsMap.containsKey(tr.navpeII_dev18__Account__c)){
                Set<Id> removePipeSet=accountIdVsDealIdsMap.get(tr.navpeII_dev18__Account__c);
                accountIdVsDealIdsMap.remove(tr.navpeII_dev18__Account__c);
                removePipeSet.remove(tr.navpeII_dev18__Deal__c);
                accountIdVsDealIdsMap.put(tr.navpeII_dev18__Account__c, removePipeSet);
                themeIdVsDealIdsMap.put(tr.navpeII_dev18__Theme__c,removePipeSet);
            }
        }
        for(navpeII_dev18__Theme_Relation__c tr:[Select Id,navpeII_dev18__Deal__c,navpeII_dev18__Account__c,navpeII_dev18__Theme__c from navpeII_dev18__Theme_Relation__c where navpeII_dev18__Theme__c IN: themeIdVsDealIdsMap.keySet() AND navpeII_dev18__Deal__c!=null WITH SECURITY_ENFORCED]){
            if(themeIdVsDealIdsMap.containsKey(tr.navpeII_dev18__Theme__c)){
                Set<Id> removePipeSet=themeIdVsDealIdsMap.get(tr.navpeII_dev18__Theme__c);
                themeIdVsDealIdsMap.remove(tr.navpeII_dev18__Theme__c);
                removePipeSet.remove(tr.navpeII_dev18__Deal__c);
                themeIdVsDealIdsMap.put(tr.navpeII_dev18__Theme__c, removePipeSet);
            }
        }
        for(Id themeId:themeIdVsDealIdsMap.keySet()){
            if(themeIdVsDealIdsMap.get(themeId).size()>0)
                for(Id dealId:themeIdVsDealIdsMap.get(themeId)){
                    navpeII_dev18__Theme_Relation__c tr=new navpeII_dev18__Theme_Relation__c(Theme__c=themeId,Deal__c=dealId);
                    insertThemeRelation.add(tr);
                }
        }
        if(insertThemeRelation.size()>0 && Schema.sObjectType.Theme_Relation__c.isCreateable()){
            try{
                insert insertThemeRelation;
            }
            catch(Exception e){
                System.debug('Error while saving Theme relation record(s): '+e.getMessage());
            }
        }
        //End
    }

    /*****************************************************************************************************
    * @Name         :   onAfterUpdate
    * @Description  :   Method to handle after update of Deal
    * @Parameter    :   Map<Id , navpeII_dev18__Pipeline__c > , Map<Id , navpeII_dev18__Pipeline__c >
    *****************************************************************************************************/
    public static void onAfterUpdate(Map<Id , navpeII_dev18__Pipeline__c> newRecordMap, Map<Id , navpeII_dev18__Pipeline__c> oldRecordMap){
        Map<String , Boolean> notificationSettings = NavatarUtility.isNotificationAllowed();
        if(notificationSettings.containsKey('info') && notificationSettings.get('info')){
            createInfoNotification(newRecordMap , oldRecordMap);
        }     
    }

     /*****************************************************************************************************
    * @Name         :   createInfoNotification
    * @Description  :   Method to create Info Notification record based on addition of deal/theme
    * @Parameter    :   Map<Id , navpeII_dev18__Pipeline__c > , Map<Id , navpeII_dev18__Pipeline__c >
    *****************************************************************************************************/
    private static void createInfoNotification(Map<Id , navpeII_dev18__Pipeline__c> newRecordMap, Map<Id , navpeII_dev18__Pipeline__c> oldRecordMap){
        Set<String> excludeStages = new Set<String>{Acuity_Setting__mdt.getInstance('Acuity_Inactive_Deal_StageValue1').Value__c
                                                    , Acuity_Setting__mdt.getInstance('Acuity_Inactive_Deal_StageValue2').Value__c 
                                                    , Acuity_Setting__mdt.getInstance('Acuity_Inactive_Deal_StageValue3').Value__c
                                                    , Acuity_Setting__mdt.getInstance('Acuity_Inactive_Deal_StageValue4').Value__c
                                                    , Acuity_Setting__mdt.getInstance('Acuity_Inactive_Deal_StageValue5').Value__c
                                                    , Acuity_Setting__mdt.getInstance('Acuity_Inactive_Deal_StageValue6').Value__c
                                                    , Acuity_Setting__mdt.getInstance('Acuity_Inactive_Deal_StageValue7').Value__c
                                                    , Acuity_Setting__mdt.getInstance('Acuity_Inactive_Deal_StageValue8').Value__c
                                                    , Acuity_Setting__mdt.getInstance('Acuity_Inactive_Deal_StageValue9').Value__c
                                                    , Acuity_Setting__mdt.getInstance('Acuity_Inactive_Deal_StageValue10').Value__c}; 

        Map<String , List<String>> accountUserMap = new Map<String , List<String>>();
        Set<String> existingNotificationSet = new Set<String>();
        List<Navatar_Notification__c> notificationList = new List<Navatar_Notification__c>(); 

        Map<Id , navpeII_dev18__Pipeline__c> dealMap = new  Map<Id , navpeII_dev18__Pipeline__c>([SELECT Id, navpeII_dev18__Company__c, Active__c,navpeII_dev18__Company__r.OwnerId,
                                                                                        navpeII_dev18__Company__r.Name, navpeII_dev18__Company__r.isAutoCreated__c
                                                                                        FROM  navpeII_dev18__Pipeline__c
                                                                                        WHERE ID IN :newRecordMap.values()]);

        AggregateResult[] results =  [SELECT count(id) , ParentId  
                                    FROM navpeII_dev18__Pipeline__History  
                                    WHERE ParentId IN :dealMap.keySet() 
                                    GROUP BY ParentId 
                                    HAVING COUNT(Id) = 1];
        
        for (AggregateResult ar : results)  {
            String dealId = (String) ar.get('ParentId');
            if(newRecordMap != null && oldRecordMap != null 
              && newRecordMap.containsKey(dealId) && oldRecordMap.containsKey(dealId)
              && (excludeStages == null || !excludeStages.contains(newRecordMap.get(dealId).navpeII_dev18__Stage__c))
              && newRecordMap.get(dealId).navpeII_dev18__Stage__c != oldRecordMap.get(dealId).navpeII_dev18__Stage__c
              && dealMap.containsKey(dealId) && dealMap.get(dealId).navpeII_dev18__Company__r.Name == newRecordMap.get(dealId).Name
              &&  dealMap.get(dealId).navpeII_dev18__Company__r.isAutoCreated__c)  {
                if(!accountUserMap.containsKey( dealMap.get(dealId).navpeII_dev18__Company__r.OwnerId)) {
                    accountUserMap.put(newRecordMap.get(dealId).navpeII_dev18__Company__c , new List<String>{newRecordMap.get(dealId).CreatedById});
                } else {
                    accountUserMap.get(newRecordMap.get(dealId).navpeII_dev18__Company__c).add(newRecordMap.get(dealId).CreatedById);
                }
                
            }
        }

        for(Navatar_Notification__c nn :[SELECT Id, Record_ID__c, User__c, Type__c FROM Navatar_Notification__c WHERE Record_ID__c IN :accountUserMap.keySet()]){
            if(nn.Record_ID__c != null && nn.User__c != null) {
                existingNotificationSet.add(nn.Record_ID__c + '-' + nn.User__c + '-' + nn.Type__c);
            }   
        }

        for(String accId : accountUserMap.keySet()){ 
            for(String usr : accountUserMap.get(accId)){
                String key = accId + '-' + usr + '-' + NavatarConstants.ACCOUNT_INFO;
                if(!existingNotificationSet.contains(key)){
                    Navatar_Notification__c nn = new Navatar_Notification__c();
                    if (Schema.sObjectType.Navatar_Notification__c.fields.Record_ID__c.isCreateable()) {
                        nn.Record_ID__c = accId;
                    }
                    if (Schema.sObjectType.Navatar_Notification__c.fields.User__c.isCreateable()) {
                        nn.User__c = usr;
                    }    
                    if (Schema.sObjectType.Navatar_Notification__c.fields.Type__c.isCreateable()) {
                        nn.Type__c = NavatarConstants.ACCOUNT_INFO;
                    }    
                    notificationList.add(nn);         
                }
            }  
        } 
             
        if(!notificationList.isEmpty() && Schema.getGlobalDescribe().get('navpeII_dev18__Navatar_Notification__c').getDescribe().isCreateable()){
            Database.insert(notificationList , false);
        }    
    }
}