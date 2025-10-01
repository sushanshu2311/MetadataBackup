/****************************************************************************************************
** Module Name : Acuity 2.0 - Theme-Deal Trigger
** Description : 
** Throws : NA
** Calls : NA
** Organization : Navatar Group
** Product Name & Version : Acuity 2.0
** Revision History:-
** Version    Date(YYYY-MM-DD)    Author         Description of Action
** 1.0        2022-11-18          Anmol
** 1.0        2022-11-22          Adil           handle onUpdate to create notification records
****************************************************************************************************/
trigger NavatarDealTrigger on navpeII_dev18__Pipeline__c (before insert, after insert,after update) {
    if(Trigger.isInsert && Trigger.isBefore){
        NavatarDealTriggerHandler.OnBeforeInsrtDeal(Trigger.New);
    }
    else if(Trigger.isInsert && Trigger.isAfter){
        NavatarDealTriggerHandler.OnAfterInsrtDeal(Trigger.New);
    }
    else if(Trigger.isAfter && Trigger.isUpdate) {
        NavatarDealTriggerHandler.onAfterUpdate(Trigger.newMap, Trigger.oldMap);
    }
}