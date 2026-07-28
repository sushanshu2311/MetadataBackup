/****************************************************************************************************
** Module Name : Acuity 2.0 - Activity Trigger
** Description : 
** Throws : NA
** Calls : NA
** Organization : Navatar Group
** Product Name & Version : Acuity 2.0
** Revision History:-
** Version    Date(YYYY-MM-DD)    Author         Description of Action
** 1.0        2022-11-18          Anmol
****************************************************************************************************/
trigger NavatarTaskRelationTrigger on TaskRelationChangeEvent (after insert) {
    list<string> taskIds = new List<String>();
    for(TaskRelationChangeEvent tr : Trigger.new){
        EventBus.ChangeEventHeader header = tr.ChangeEventHeader;
        if(header.changeType == 'CREATE' && String.valueOf(tr.RelationId).startsWith('003')){
            taskIds.addAll(header.recordIds);
        }
    }
    if(taskIds.size()>0){
            navpeII.NavatarTaskEventRelationHandler.onInsrtUpdteActivity(taskIds);
    }
}