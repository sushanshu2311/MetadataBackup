/****************************************************************************************************
    ** Module Name : Clip Relation Trigger
    ** Description : Used to handle clip relation record creation
    ** Throws : NA
    ** Calls : NA
    ** Organization : Navatar Group
    ** Product Name & Version : Connections 2.0
    ** Revision History:-
    ** Version    Date(YYYY-MM-DD)    Author         Description of Action
    ** 1.0        2022-11-25          Adil           handle onInsert of Clip Relation to create notification records
    ** 2.0        2023-02-23          Pavani         Created the clipRelationTrigger with new name
****************************************************************************************************/
trigger NavatarClipRelationTrigger on Clip_Relation__c (after insert) {
    if(Trigger.isAfter && Trigger.isInsert) {
        NavatarClipRelationHandler.onAfterInsert(Trigger.newMap);
    }
}