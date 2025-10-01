/****************************************************************************************************
** Module Name : Acuity 2.0 - Theme Team Trigger
** Description : 
** Throws : NA
** Calls : NA
** Organization : Navatar Group
** Product Name & Version : Acuity 2.0
** Revision History:-
** Version    Date(YYYY-MM-DD)    Author         Description of Action
** 1.0        2022-12-27          Virendra Kumar          Theme Team Trigger
****************************************************************************************************/
trigger NavatarThemeTeamTrigger on Theme_Team__c (before insert, before update) {
    if(trigger.isbefore) {
        if(trigger.isinsert || trigger.isupdate){
            NavatarThemeTeamHandler.duplicateCheckBasedOnMemberAndRole(trigger.new , trigger.oldMap);
        }
    }
}