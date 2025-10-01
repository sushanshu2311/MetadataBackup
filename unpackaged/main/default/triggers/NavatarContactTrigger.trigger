/**
* --------------------------------------------------------------------------------------------------
* Trigger designed to call its handler class for Last Touchpoint calculation on Account.
* --------------------------------------------------------------------------------------------------
* @author         Anmol Uppal
* @modifiedBy     Anmol Uppal
* @version        1.0
* @created        2023-01-23
* @modified       2023-01-23
* @testClass      NavatarContactTriggerHandler_Test
* @handlerClass   NavatarContactTriggerHandler
* @organization   Navatar Group
*/
trigger NavatarContactTrigger on Contact (after insert,after update, after delete, after undelete) {
    if(Trigger.isAfter){
        if(!Trigger.isDelete)
            NavatarContactTriggerHandler.OnAfterInsUpdUnDel(Trigger.New,Trigger.oldMap);
            else if(Trigger.isDelete)
            NavatarContactTriggerHandler.OnAfterDel(Trigger.Old,Trigger.oldMap);
    }
}