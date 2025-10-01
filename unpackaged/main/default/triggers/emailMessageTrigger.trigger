/*
* -------------------------------------------------------------------------------------
* dummy update on Email Message related Task records to invoke the task process builder.
* on delete of email message recalculate the Contact's Last Touch point.
* -------------------------------------------------------------------------------------
* @author         Raghvendra Jha
* @modifiedBy     Raghvendra Jha
* @version        1.0
* @created        2019-11-27
* @modified       2019-11-27
*/
trigger emailMessageTrigger on EmailMessage (after insert, before delete) {
    
    if(Trigger.isinsert){
      TaskTriggerHandler.updateTask(Trigger.New);
    }
    else if(Trigger.isdelete){
       TaskTriggerHandler.onEmailMessageDel(Trigger.Old);
    }
}