/****************************************************************************************************
** Module Name : Acuity 2.0 - Activity Trigger
** Description : Handler class for Record Triggered automation of adding Contacts on Task(s) and Event(s)
** Throws : NA
** Calls : NA
** Organization : Navatar Group
** Product Name & Version : Acuity 2.0
** Revision History:-
** Version    Date(YYYY-MM-DD)    Author         Description of Action
** 1.0        2022-11-18          Anmol			 Created Handler for Automatic tagging of Active Deals & Fundraisings
** 2.0        2023-01-23          Anmol			 Added logic for LTP
** 2.0        2024-03-23          Deepak Singh   Added logic for LTP Fundraising and Deal
****************************************************************************************************/
global with sharing class NavatarTaskEventRelationHandler {
    public static Boolean recursionchk = true;
    public static Boolean taskEventchk = true;//new
    /*
* Purpose : Fetches namespace prefix
* Returns : Namespaceprefix to be used as a String
*/
    global static String getNamespacePrefix(){
        try{
            return [SELECT NamespacePrefix FROM ApexClass WHERE Name = 'FileUploaderCtrl'].NamespacePrefix;
        } catch (Exception e) {
            System.debug('Error Occured While Loading Component : <<' + e.getStackTraceString() + '>>');
            return null;
        }
    }
    //Added by LK on 2024-10-29 to fix 00047981
    @InvocableMethod(label = 'Update LTP when event expires')
    global static void processRelationIds(List<List<String>> relationRecordsIdList){
        List<String> finalRelRecsIdList = new List<String>();
        for(List<String> relRecsIdList : relationRecordsIdList){
            finalRelRecsIdList.addAll(relRecsIdList);
        }
        NavatarTaskEventRelationHandler.onInsrtUpdteActivity(finalRelRecsIdList);
    }
    
    /*
* Purpose : Runs when a Contact is Tagged to the Task
Checks whether all the Deals & Fundraisings are tagged to the Task in Related_Asspciations
if yes, no operation performed
if no, Deals and Fundraisings are tagged to the Task in Related_Associations.
* Returns : nothing
*/
global static void onInsrtUpdteActivity(List<String> activityIdList){
        try{
            String nSpace=String.escapeSinglequotes(getNamespacePrefix());
            Map<Id,List<Id>> activityVsContactIdsMap=new Map<Id,List<Id>>();
            Map<Id,String> contactVsDealIdsMap=new Map<Id,String>();
            Map<Id,String> contactVsFdrIdsMap=new Map<Id,String>();
            Set<Id> conIdsSet=new Set<Id>();
            Set<Id> taskIdsSet=new Set<Id>();
            Set<Id> allTaskIdsSet=new Set<Id>();
            Set<Id> userIdsSet=new Set<Id>();
            Set<Id> eventIdsSet=new Set<Id>();
            Set<Id> allEventIdsSet=new Set<Id>();
            Map<Id,List<Id>> contactVsActIdsMap=new Map<Id,List<Id>>();
            Map<Id,List<Id>> userVsActIdsMap=new Map<Id,List<Id>>();
            Map<Id,Date> contactVsLTPDate= new Map<Id,Date>();
            Map<Id,Id> contactVsLTPId= new Map<Id,Id>();
            Map<Id,Date> userVsLTPDate= new Map<Id,Date>();
            Map<Id,Id> userVsLTPId= new Map<Id,Id>();
            List<Task> updatedTaskList=new List<Task>();
            List<Event> updatedEventList=new List<Event>();
            Integer limitExistForQuery = 0;

            if(activityIdList!=null && activityIdList.size()>0 && String.valueOf(Id.valueOf(activityIdList[0]).getSObjectType())=='TaskRelation'){
                    List<Sobject> taskRelationList = new List<Sobject>();
                    taskRelationList = Database.query('Select Id, RelationId, TaskId from TaskRelation where Id IN: activityIdList AND Task.TaskSubType != \'ListEmail\' AND isWhat = false WITH SECURITY_ENFORCED Limit 2000');
                    for(Sobject tr:taskRelationList){
                    if(String.valueOf(tr.get('RelationId')).startsWith('003')){
                        conIdsSet.add(string.valueof(tr.get('RelationId')));
                        taskIdsSet.add(String.valueof(tr.get('TaskId')));
                        String TaskID = String.valueof(tr.get('TaskId'));
                        if(!activityVsContactIdsMap.containsKey(TaskID)){
                            List<Id> taskIdList=new List<Id>();
                            taskIdList.add(String.valueof(tr.get('RelationId')));
                            activityVsContactIdsMap.put(String.valueof(tr.get('TaskId')),taskIdList);
                        }
                        else{
                            string Ids = String.valueof(tr.get('TaskId'));
                            List<Id> taskIdList2=activityVsContactIdsMap.get(Ids);
                            String Ids1 = String.valueof(string.valueof(tr.get('TaskId')));
                            activityVsContactIdsMap.remove(Ids1);
                            taskIdList2.add(String.valueof(tr.get('RelationId')));
                            activityVsContactIdsMap.put(String.valueof(tr.get('TaskId')),taskIdList2);
                        }
                    }
                }
                
                if(conIdsSet.size()>0 && taskIdsSet.size()>0){
                    //all Tasks of this contact
                    if(Schema.getGlobalDescribe().get('TaskWhoRelation') != null){
                        limitExistForQuery  = Limits.getLimitQueryRows() - Limits.getQueryRows();
                        //string limitNumber = string.valueOf(limitExistForQuery);
                        List<Sobject> eventRelationList = new List<Sobject>();
                        eventRelationList = Database.query('Select Id, RelationId,TaskId from TaskWhoRelation where RelationId IN: conIdsSet WITH SECURITY_ENFORCED Limit:limitExistForQuery');
                    for(Sobject twr:eventRelationList){
                        if(String.valueOf(twr.get('RelationId')).startsWith('003')){
                            allTaskIdsSet.add(String.valueof(twr.get('TaskId')));
                            if(!contactVsActIdsMap.containsKey(String.Valueof(twr.get('RelationId')))){
                                List<String> taskIdStringList=new List<String>();
                                taskIdStringList.add(String.valueof(twr.get('TaskId')));
                                contactVsActIdsMap.put(String.valueof(twr.get('RelationId')), taskIdStringList);
                            }
                            else{
                                List<String> taskIdString2List=contactVsActIdsMap.get(String.valueof(twr.get('RelationId')));
                                taskIdString2List.add(String.valueof(twr.get('TaskId')));
                                contactVsActIdsMap.remove(String.valueof(twr.get('RelationId')));
                                contactVsActIdsMap.put(String.valueof(twr.get('RelationId')), taskIdString2List);
                            }
                            }
                        }
                    }
                    limitExistForQuery=Limits.getLimitQueryRows()-Limits.getQueryRows();
                    for(Task t: [Select Id, ActivityDate,navpeII_dev18__Is_Touchpoint_New__c from Task where Id IN: allTaskIdsSet And ActivityDate <= :Date.today() WITH SECURITY_ENFORCED ORDER BY ActivityDate ASC Limit:limitExistForQuery]){//Bug -45613, 45712 By Harshwardhan
                        for(String conIdStr:contactVsActIdsMap.keySet()){
                            if((!t.navpeII_dev18__Is_Touchpoint_New__c || t.ActivityDate == null) && contactVsActIdsMap.get(conIdStr).contains(t.Id)){
                                contactVsActIdsMap.get(conIdStr).remove(contactVsActIdsMap.get(conIdStr).indexOf(t.Id));
                            }
                            else{
                                    if(contactVsActIdsMap.get(conIdStr).contains(t.Id)){//bug 45613 Change
                                        contactVsLTPDate.put(conIdStr,t.ActivityDate);
                                        contactVsLTPId.put(conIdStr,t.Id);
                                    }
                            }
                        }
                    }
                    limitExistForQuery  = Limits.getLimitQueryRows() - Limits.getQueryRows();
                    if(Schema.getGlobalDescribe().get('EventRelation') != null){
                        List<Sobject> eventRelationList = new List<Sobject>();
                    eventRelationList = Database.query('Select Id, RelationId,EventId from EventRelation where RelationId IN: conIdsSet WITH SECURITY_ENFORCED Limit:limitExistForQuery');
                        for(Sobject ewr:eventRelationList){
                        if(String.valueOf(ewr.get('RelationId')).startsWith('003')){
                            allEventIdsSet.add(string.valueof(ewr.get('EventId')));
                            //String eventIdString = String.valueof(ewr.get('RelationId'));
                            if(!contactVsActIdsMap.containsKey(String.valueof(ewr.get('RelationId')))){
                                List<String> eventIdStringList=new List<String>();
                                eventIdStringList.add(String.valueof(ewr.get('EventId')));
                                contactVsActIdsMap.put(String.valueof(ewr.get('RelationId')), eventIdStringList);
                            }
                            else{
                                //String ewrRelationId = string.valueOf(ewr.get('RelationId'));
                                List<String> eventIdString2List=contactVsActIdsMap.get(string.valueOf(ewr.get('RelationId')));
                                eventIdString2List.add(String.valueof(ewr.get('EventId')));
                                contactVsActIdsMap.remove(string.valueOf(ewr.get('RelationId')));
                                contactVsActIdsMap.put(String.valueof(ewr.get('RelationId')), eventIdString2List);
                            }
                            }
                        }
                    }
                    limitExistForQuery=Limits.getLimitQueryRows()-Limits.getQueryRows();
                    for(Event e: [Select Id, EndDateTime,navpeII_dev18__Is_Touchpoint_New__c from Event where ID IN: allEventIdsSet And EndDateTime <= :DateTime.now() WITH SECURITY_ENFORCED ORDER BY EndDateTime ASC Limit:limitExistForQuery]){//Bug -00045613,45712 By harshwardhan
                        for(String conIdStr:contactVsActIdsMap.keySet()){
                            if((!e.navpeII_dev18__Is_Touchpoint_New__c || e.EndDateTime == null) && contactVsActIdsMap.get(conIdStr).contains(e.Id)){
                                contactVsActIdsMap.get(conIdStr).remove(contactVsActIdsMap.get(conIdStr).indexOf(e.Id));
                            }
                            else{
                                if((contactVsLTPDate.containsKey(conIdStr) && contactVsActIdsMap.get(conIdStr).contains(e.Id) && contactVsLTPDate.get(conIdStr)<e.EndDateTime.date()) || !contactVsLTPDate.containsKey(conIdStr)){//bug 45613,45712 change
                                    contactVsLTPDate.put(conIdStr,e.EndDateTime.date());
                                    contactVsLTPId.put(conIdStr,e.Id);
                                }
                            }
                        }
                    }
                    //Update ltp when contact's previous past/current call/meeting is changed to future and no other past or current task/meeting is there
                    for(String constr : contactVsActIdsMap.keySet()){
                        if(!contactVsLTPDate.containsKey(constr)){
                            contactVsLTPDate.put(constr,null);
                            contactVsLTPId.put(constr,null);
                        }
                    }
                    system.debug('@newltp1 '+ contactVsLTPDate + ' @newltp2 '+ contactVsActIdsMap +'@newltp3' + contactVsLTPId);
                    List<Contact> updContacts=new List<Contact>();
                    for(String strContact : contactVsLTPDate.keyset())
                    {
                        contact con = new contact(Id=strContact);
                        if(contactVsLTPDate.get(strContact) !=null && contactVsLTPDate.get(strContact) != null && Schema.SObjectType.Contact.fields.navpeII_dev18__Last_Touch_Point__c.isUpdateable() && Schema.sObjectType.Contact.fields.navpeII_dev18__Last_Touchpoint_ID__c.isUpdateable()){ // added isUpdateable check for security issue PEv4.7
                            con.navpeII_dev18__Last_Touch_Point__c = contactVsLTPDate.get(strContact);
                            con.navpeII_dev18__Last_Touchpoint_ID__c=contactVsLTPId.get(strContact);// update for last touch point Id 
                        }
                        else if(strContact!=null && Schema.SObjectType.Contact.fields.navpeII_dev18__Last_Touch_Point__c.isUpdateable() && Schema.sObjectType.Contact.fields.navpeII_dev18__Last_Touchpoint_ID__c.isUpdateable()){
                            con.navpeII_dev18__Last_Touch_Point__c = (Date)contactVsLTPDate.get(strContact);
                            con.navpeII_dev18__Last_Touchpoint_ID__c=contactVsLTPId.get(strContact);
                        }
                        updContacts.add(con);
                    }
                    
                    
                    if(updContacts.size() > 0 && Schema.sObjectType.Contact.isUpdateable()) { // added isUpdateable check for security issue PEv4.7
                        update updContacts;
                    }  
                }
                limitExistForQuery  = Limits.getLimitQueryRows() - Limits.getQueryRows();
                List<sObject> dealTeamList=Database.query('Select Id,'+nSpace+'__Deal__c,'+nSpace+'__Deal_Contact__c from '+nSpace+
                                                          '__Deal_Team__c where '+nSpace+'__Deal__r.Active__c=true AND '+nSpace+
                                                          '__Deal_Contact__c IN: conIdsSet WITH SECURITY_ENFORCED Limit:limitExistForQuery');
                for(SObject dt: dealTeamList){
                    if(!contactVsDealIdsMap.containsKey(String.valueOf(dt.get(nSpace+'__Deal_Contact__c')))){
                        String dealIdString='';
                        dealIdString+=','+String.valueOf(dt.get(nSpace+'__Deal__c'));
                        dealIdString.removeStart(',');
                        contactVsDealIdsMap.put(String.valueOf(dt.get(nSpace+'__Deal_Contact__c')),dealIdString);
                    }
                    else{
                        String dealIdString2=contactVsDealIdsMap.get(String.valueOf(dt.get(nSpace+'__Deal_Contact__c')));
                        contactVsDealIdsMap.remove(String.valueOf(dt.get(nSpace+'__Deal_Contact__c')));
                        dealIdString2+=','+String.valueOf(dt.get(nSpace+'__Deal__c'));
                        contactVsDealIdsMap.put(String.valueOf(dt.get(nSpace+'__Deal_Contact__c')),dealIdString2);
                    }
                }
                limitExistForQuery  = Limits.getLimitQueryRows() - Limits.getQueryRows();
                List<sObject> fdrContactList=Database.query('Select '+nSpace+'__Contact__c, '+nSpace+'__Fundraising__c, Id, '+nSpace+
                                                            '__Fundraising__r.'+nSpace+'__Fund_Name__c from '+nSpace+
                                                            '__Fundraising_Contact__c where '+nSpace+'__Fundraising__r.Active__c=true AND '+nSpace+
                                                            '__Contact__c IN: conIdsSet WITH SECURITY_ENFORCED Limit:limitExistForQuery');
                for(SObject fc: fdrContactList){
                    if(!contactVsFdrIdsMap.containsKey(String.valueOf(fc.get(nSpace+'__Contact__c')))){
                        String fdrIdString='';
                        fdrIdString+=','+String.valueOf(fc.get(nSpace+'__Fundraising__c'));
                        fdrIdString.removeStart(',');
                        contactVsFdrIdsMap.put(String.valueOf(fc.get(nSpace+'__Contact__c')),fdrIdString);
                    }
                    else{
                        String fdrIdString2=contactVsFdrIdsMap.get(String.valueOf(fc.get(nSpace+'__Contact__c')));
                        contactVsFdrIdsMap.remove(String.valueOf(fc.get(nSpace+'__Contact__c')));
                        fdrIdString2+=','+String.valueOf(fc.get(nSpace+'__Fundraising__c'));
                        contactVsFdrIdsMap.put(String.valueOf(fc.get(nSpace+'__Contact__c')),fdrIdString2);
                    }
                }
                limitExistForQuery=Limits.getLimitQueryRows()-Limits.getQueryRows();
                for(Task t:[Select Id, navpeII_dev18__Related_Associations__c from Task where Id IN: activityVsContactIdsMap.keySet() WITH SECURITY_ENFORCED Limit:limitExistForQuery]){
                    Set<String> relatedAssociationsDealSet=new Set<String>();
                    Set<String> relatedAssociationsFdrSet=new Set<String>();
                    for(Id i:activityVsContactIdsMap.get(t.Id)){
                        relatedAssociationsDealSet.addAll(contactVsDealIdsMap.get(i)!=null?String.valueOf(contactVsDealIdsMap.get(i)).trim().remove('(').remove(')').split(','):new List<String>());
                        relatedAssociationsFdrSet.addAll(contactVsFdrIdsMap.get(i)!=null?String.valueOf(contactVsFdrIdsMap.get(i)).trim().remove('(').remove(')').split(','):new List<String>());
                    }
                    t.navpeII_dev18__Related_Associations__c=sanitizeAssociations(t.navpeII_dev18__Related_Associations__c,relatedAssociationsDealSet,relatedAssociationsFdrSet);
                    updatedTaskList.add(t);
                }
                if(updatedTaskList.size()>0 && Schema.sObjectType.Task.isUpdateable()){
                    try{
                        update updatedTaskList;
                    }
                    catch(Exception e){
                        System.debug('Error while saving Account record(s): '+e.getMessage());
                    }
                }
            }
            else if(activityIdList!=null && activityIdList.size()>0 && String.valueOf(Id.valueOf(activityIdList[0]).getSObjectType())=='EventRelation'){
             List<Sobject> eventRelationList = new List<Sobject>();
                    eventRelationList = Database.query('Select Id, RelationId, EventId from EventRelation where Id IN: activityIdList WITH SECURITY_ENFORCED Limit 2000');
                for(Sobject ev:eventRelationList){
                    if(String.valueOf(ev.get('RelationId')).startsWith('003')){
                        conIdsSet.add(String.valueof(ev.get('RelationId')));
                        eventIdsSet.add(String.valueof(ev.get('EventId')));
                        //String eventID = string.valueOf(ev.get('EventId'));
                        if(!activityVsContactIdsMap.containsKey(string.valueOf(ev.get('EventId')))){
                            List<Id> eventIdList=new List<Id>();
                            eventIdList.add(String.valueof(ev.get('RelationId')));
                            activityVsContactIdsMap.put(String.valueof(ev.get('EventId')),eventIdList);
                        }
                        else{
                            List<Id> eventIdList2=activityVsContactIdsMap.get(String.valueof(ev.get('EventId')));
                            activityVsContactIdsMap.remove(String.valueof(ev.get('EventId')));
                            eventIdList2.add(String.valueof(ev.get('RelationId')));
                            activityVsContactIdsMap.put(string.valueof(ev.get('EventId')),eventIdList2);
                        }
                    }
                    // else if(String.valueOf(ev.get('RelationId')).startsWith('005')){
                    //     userIdsSet.add(String.valueof(ev.get('RelationId')));
                    //     eventIdsSet.add(String.valueof(ev.get('EventId')));
                    // }
                }
                
                // if(conIdsSet.size()>0 && eventIdsSet.size()>0){
                    //all Tasks of this contact
                    limitExistForQuery  = Limits.getLimitQueryRows() - Limits.getQueryRows();
                        List<Sobject> ewrList = new List<Sobject>();
                    ewrList = Database.query('Select Id, RelationId,EventId from EventRelation where RelationId IN: conIdsSet WITH SECURITY_ENFORCED Limit:limitExistForQuery');
                    for(Sobject ewr:ewrList){
                        if(String.valueOf(ewr.get('RelationId')).startsWith('003')){
                            allEventIdsSet.add(String.valueof(ewr.get('EventId')));
                            //String ewrRelatinoId = String.valueOf(ewr.get('RelationId'));
                            if(!contactVsActIdsMap.containsKey(String.valueOf(ewr.get('RelationId')))){
                                List<String> eventIdStringList=new List<String>();
                                eventIdStringList.add(String.valueof(ewr.get('EventId')));
                                contactVsActIdsMap.put(String.valueOf(ewr.get('RelationId')), eventIdStringList);
                            }
                            else{
                                List<String> eventIdString2List=contactVsActIdsMap.get(String.valueOf(ewr.get('RelationId')));
                                eventIdString2List.add(String.valueof(ewr.get('EventId')));
                                contactVsActIdsMap.remove(String.valueOf(ewr.get('RelationId')));
                                contactVsActIdsMap.put(String.valueOf(ewr.get('RelationId')), eventIdString2List);
                            }
                        }
                    }
                limitExistForQuery  = Limits.getLimitQueryRows() - Limits.getQueryRows();
                    for(Event e: [Select Id, EndDateTime,navpeII_dev18__Is_Touchpoint_New__c from Event where ID IN: allEventIdsSet And EndDateTime <= :DateTime.now() WITH SECURITY_ENFORCED ORDER BY EndDateTime ASC Limit:limitExistForQuery]){//Bug -45613, 45712 By Harshwardhan
                        for(String conIdStr:contactVsActIdsMap.keySet()){
                            if((!e.navpeII_dev18__Is_Touchpoint_New__c || e.EndDateTime == null) && contactVsActIdsMap.get(conIdStr).contains(e.Id)){
                                contactVsActIdsMap.get(conIdStr).remove(contactVsActIdsMap.get(conIdStr).indexOf(e.Id));
                            }
                            else{
                                    if(contactVsActIdsMap.get(conIdStr).contains(e.Id)){//bug 45613 change
                                        contactVsLTPDate.put(conIdStr,e.EndDateTime.date());
                                        contactVsLTPId.put(conIdStr,e.Id);
                                    }
                                }
                                system.debug('@ltp1'+contactVsLTPDate + '@ll '+contactVsLTPId );
                        }
                    }
                if(Schema.getGlobalDescribe().get('TaskWhoRelation') != null){
                    limitExistForQuery  = Limits.getLimitQueryRows() - Limits.getQueryRows();
                        List<Sobject> taskWhoRelationList = new List<Sobject>();
                        taskWhoRelationList = Database.query('Select Id, RelationId,TaskId from TaskWhoRelation where RelationId IN: conIdsSet WITH SECURITY_ENFORCED Limit:limitExistForQuery');
                    for(Sobject twr:taskWhoRelationList){
                        if(String.valueOf(twr.get('RelationId')).startsWith('003')){
                            allTaskIdsSet.add(String.valueof(twr.get('TaskId')));
                            if(!contactVsActIdsMap.containsKey(String.valueof(twr.get('RelationId')))){
                                List<String> taskIdStringList=new List<String>();
                                taskIdStringList.add(String.valueof(twr.get('TaskId')));
                                contactVsActIdsMap.put(String.valueof(twr.get('RelationId')), taskIdStringList);
                            }
                            else{
                                List<String> taskIdString2List=contactVsActIdsMap.get(String.valueof(twr.get('RelationId')));
                                taskIdString2List.add(String.valueof(twr.get('TaskId')));
                                contactVsActIdsMap.remove(String.valueof(twr.get('RelationId')));
                                contactVsActIdsMap.put(String.valueof(twr.get('RelationId')), taskIdString2List);
                        }
                    }
                    }}
                limitExistForQuery  = Limits.getLimitQueryRows() - Limits.getQueryRows();
                    for(Task t: [Select Id, ActivityDate,navpeII_dev18__Is_Touchpoint_New__c from Task where Id IN: allTaskIdsSet And ActivityDate <= :Date.today() ORDER BY ActivityDate ASC Limit:limitExistForQuery]){//Bug-00045613 By Harshwardhan
                        for(String conIdStr:contactVsActIdsMap.keySet()){
                            if((!t.navpeII_dev18__Is_Touchpoint_New__c || t.ActivityDate == null) && contactVsActIdsMap.get(conIdStr).contains(t.Id)){
                                contactVsActIdsMap.get(conIdStr).remove(contactVsActIdsMap.get(conIdStr).indexOf(t.Id));
                            }
                            else{
                                if((contactVsLTPDate.containsKey(conIdStr) && contactVsActIdsMap.get(conIdStr).contains(t.Id) && contactVsLTPDate.get(conIdStr)<t.ActivityDate) || !contactVsLTPDate.containsKey(conIdStr)){//bug 45613,45712 change
                                    contactVsLTPDate.put(conIdStr,t.ActivityDate);
                                    contactVsLTPId.put(conIdStr,t.Id);
                                }
                            }
                        }
                    }
                    //Update ltp when contact's previous past/current call/meeting is changed to future and no other past or current task/meeting is there
                    for(String constr : contactVsActIdsMap.keySet()){
                        if(!contactVsLTPDate.containsKey(constr)){
                            contactVsLTPDate.put(constr,null);
                            contactVsLTPId.put(constr,null);
                        }
                    }
                    List<Contact> updContacts=new List<Contact>();
                    for(String strContact : contactVsLTPDate.keyset())
                    {
                        contact con = new contact(Id=strContact);
                        if(contactVsLTPDate.get(strContact) !=null && contactVsLTPId.get(strContact) != null && Schema.SObjectType.Contact.fields.navpeII_dev18__Last_Touch_Point__c.isUpdateable() && Schema.sObjectType.Contact.fields.Last_Touchpoint_ID__c.isUpdateable()){
                            // added isUpdateable check for security issue PEv4.7
                            con.navpeII_dev18__Last_Touch_Point__c = (Date)contactVsLTPDate.get(strContact);
                            con.Last_Touchpoint_ID__c=contactVsLTPId.get(strContact);// update for last touch point Id 
                        }
                        else if(strContact!=null && Schema.SObjectType.Contact.fields.navpeII_dev18__Last_Touch_Point__c.isUpdateable() && Schema.sObjectType.Contact.fields.Last_Touchpoint_ID__c.isUpdateable()){
                            con.navpeII_dev18__Last_Touch_Point__c = (Date)contactVsLTPDate.get(strContact);
                            con.navpeII_dev18__Last_Touchpoint_ID__c=contactVsLTPId.get(strContact);
                        }
                        updContacts.add(con);
                    }
                    
                    
                    if(updContacts.size() > 0 && Schema.sObjectType.Contact.isUpdateable()) { // added isUpdateable check for security issue PEv4.7
                        update updContacts;
                    }  
                // }
                limitExistForQuery  = Limits.getLimitQueryRows() - Limits.getQueryRows();
                List<sObject> dealTeamList=Database.query('Select Id,'+nSpace+'__Deal__c,'+nSpace+'__Deal_Contact__c from '+nSpace+
                                                          '__Deal_Team__c where '+nSpace+'__Deal__r.Active__c=true AND '+nSpace+
                                                          '__Deal_Contact__c IN: conIdsSet WITH SECURITY_ENFORCED Limit:limitExistForQuery');
                for(SObject dt: dealTeamList){
                    if(!contactVsDealIdsMap.containsKey(String.valueOf(dt.get(nSpace+'__Deal_Contact__c')))){
                        String dealIdString='';
                        dealIdString+=','+String.valueOf(dt.get(nSpace+'__Deal__c'));
                        dealIdString.removeStart(',');
                        contactVsDealIdsMap.put(String.valueOf(dt.get(nSpace+'__Deal_Contact__c')),dealIdString);
                    }
                    else{
                        String dealIdString2=contactVsDealIdsMap.get(String.valueOf(dt.get(nSpace+'__Deal_Contact__c')));
                        contactVsDealIdsMap.remove(String.valueOf(dt.get(nSpace+'__Deal_Contact__c')));
                        dealIdString2+=','+String.valueOf(dt.get(nSpace+'__Deal__c'));
                        contactVsDealIdsMap.put(String.valueOf(dt.get(nSpace+'__Deal_Contact__c')),dealIdString2);
                    }
                }
                limitExistForQuery  = Limits.getLimitQueryRows() - Limits.getQueryRows();
                List<sObject> fdrContactList=Database.query('Select '+nSpace+'__Contact__c, '+nSpace+'__Fundraising__c, Id, '+nSpace+
                                                            '__Fundraising__r.'+nSpace+'__Fund_Name__c from '+nSpace+
                                                            '__Fundraising_Contact__c where '+nSpace+'__Fundraising__r.Active__c=true AND '+nSpace+
                                                            '__Contact__c IN: conIdsSet WITH SECURITY_ENFORCED Limit:limitExistForQuery');
                for(SObject fc: fdrContactList){
                    if(!contactVsFdrIdsMap.containsKey(String.valueOf(fc.get(nSpace+'__Contact__c')))){
                        String fdrIdString='';
                        fdrIdString+=','+String.valueOf(fc.get(nSpace+'__Fundraising__c'));
                        fdrIdString.removeStart(',');
                        contactVsFdrIdsMap.put(String.valueOf(fc.get(nSpace+'__Contact__c')),fdrIdString);
                    }
                    else{
                        String fdrIdString2=contactVsFdrIdsMap.get(String.valueOf(fc.get(nSpace+'__Contact__c')));
                        contactVsFdrIdsMap.remove(String.valueOf(fc.get(nSpace+'__Contact__c')));
                        fdrIdString2+=','+String.valueOf(fc.get(nSpace+'__Fundraising__c'));
                        contactVsFdrIdsMap.put(String.valueOf(fc.get(nSpace+'__Contact__c')),fdrIdString2);
                    }
                }
                limitExistForQuery  = Limits.getLimitQueryRows() - Limits.getQueryRows();
                for(Event e:[Select Id, navpeII_dev18__Related_Associations__c from Event where Id IN: activityVsContactIdsMap.keySet() WITH SECURITY_ENFORCED Limit:limitExistForQuery]){
                    Set<String> relatedAssociationsDealSet=new Set<String>();
                    Set<String> relatedAssociationsFdrSet=new Set<String>();
                    for(Id i:activityVsContactIdsMap.get(e.Id)){
                        relatedAssociationsDealSet.addAll(contactVsDealIdsMap.get(i)!=null?String.valueOf(contactVsDealIdsMap.get(i)).trim().remove('(').remove(')').split(','):new List<String>());
                        relatedAssociationsFdrSet.addAll(contactVsFdrIdsMap.get(i)!=null?String.valueOf(contactVsFdrIdsMap.get(i)).trim().remove('(').remove(')').split(','):new List<String>());
                    }
                    e.navpeII_dev18__Related_Associations__c=sanitizeAssociations(e.navpeII_dev18__Related_Associations__c,relatedAssociationsDealSet,relatedAssociationsFdrSet);
                    updatedEventList.add(e);
                }
                if(updatedEventList.size()>0 && Schema.sObjectType.Event.isUpdateable()){
                    try{
                        update updatedEventList;
                    }
                    catch(Exception e){
                        System.debug('Error while saving Account record(s): '+e.getMessage());
                    }
                }
            }
            
            
        }
        catch(Exception e){
            
        }
    }

/*
Method to Update Last Touch Point and Last Touch Id field on Fundraising and Deal
Bug Id - 44580 added Is_Touchpoint condition in where clause
*/
    global static void onInsrtUpdteRelatedAssociation(List<String> activityIdList){
        try {
         //   List<String> activityIdList = new List<String>();
            Set<String> dealIds = new Set<String>();
            Set<String> frdIds = new Set<String>();
            System.debug('rel trigger @@@@@');
            Map<String,Date> relVsLTPDate = new Map<String,Date>();
            Map<String,String> relVsLTPId = new Map<String,String>();
            if(activityIdList!=null && activityIdList.size()>0 && String.valueOf(Id.valueOf(activityIdList[0]).getSObjectType())=='Task')
            {
                Integer limitExistForQuery=Limits.getLimitQueryRows()-Limits.getQueryRows();
               // navpe3Dev1__Related_Associations__c != null AND navpe3Dev1__Related_Associations__c Like :relAss
                for(Task tk : [SELECT Id, ActivityDate,navpeII_dev18__Related_Associations__c FROM Task WHERE Id IN:activityIdList WITH SECURITY_ENFORCED Limit:limitExistForQuery]){
                    for(String str : tk.navpeII_dev18__Related_Associations__c.split(',')){
                        Id objId = Id.valueOf(str);
                        if(objId.getsobjecttype().getDescribe().getName() == 'navpeII_dev18__Pipeline__c'){
                            dealIds.add('%'+str+'%');
                        }else if(objId.getsobjecttype().getDescribe().getName() == 'navpeII_dev18__Fundraising__c'){
                            frdIds.add('%'+str+'%');
                        }
                    }
                }

                if(dealIds.size() >0){
                    limitExistForQuery  = Limits.getLimitQueryRows() - Limits.getQueryRows();
                    for(Task tk : [SELECT Id, ActivityDate,navpeII_dev18__Related_Associations__c FROM Task WHERE navpeII_dev18__Is_Touchpoint_New__c = true AND navpeII_dev18__Related_Associations__c != null AND navpeII_dev18__Related_Associations__c Like :dealIds WITH SECURITY_ENFORCED Order By ActivityDate ASC Limit:limitExistForQuery]){
                        //System.debug(tk);
                        for(String str : tk.navpeII_dev18__Related_Associations__c.split(',')){
                            Id objId = Id.valueOf(str);
                            if(objId.getsobjecttype().getDescribe().getName() == 'navpeII_dev18__Pipeline__c'){
                                relVsLTPDate.put(str,tk.ActivityDate);
                                relVsLTPId.put(str,tk.Id);
                            }
                        }
                    }

                    limitExistForQuery=Limits.getLimitQueryRows()-Limits.getQueryRows();
                    for(Event e: [SELECT Id, EndDateTime,navpeII_dev18__Is_Touchpoint_New__c, navpeII_dev18__Related_Associations__c FROM Event WHERE navpeII_dev18__Is_Touchpoint_New__c = true AND navpeII_dev18__Related_Associations__c != null AND navpeII_dev18__Related_Associations__c Like :dealIds WITH SECURITY_ENFORCED ORDER BY EndDateTime ASC Limit:limitExistForQuery]){
                        for(String str : e.navpeII_dev18__Related_Associations__c.split(',')){
                            Id objId = Id.valueOf(str);
                            if(objId.getsobjecttype().getDescribe().getName() == 'navpeII_dev18__Pipeline__c' && ((relVsLTPDate.containsKey(str) && relVsLTPDate.get(str)<e.EndDateTime.date()) || (!relVsLTPDate.containsKey(str)))){//Bug fix- 45712
                                relVsLTPDate.put(str,e.EndDateTime.date());
                                relVsLTPId.put(str,e.Id);        
                            }
                        }
                    }
                    
                    //Update ltp when Deal's previous past/current call/meeting is changed to future and there is no other past or current call/meeting 
                    for(String dealIdRec : dealIds){
                        if(!relVsLTPDate.containsKey(dealIdRec.remove('%'))){
                            relVsLTPDate.put(dealIdRec.remove('%'),null);
                            relVsLTPId.put(dealIdRec.remove('%'),null);
                        }
                    }
                    List<navpeII_dev18__Pipeline__c> updateDealLst = new List<navpeII_dev18__Pipeline__c>();
                    for(String strdeal : relVsLTPId.keySet()){
                        navpeII_dev18__Pipeline__c deal = new navpeII_dev18__Pipeline__c(Id=strdeal);
                        
            // Bug Id - 00045806 to fix API name and Label Deepak
                        if (Schema.sObjectType.navpeII_dev18__Pipeline__c.fields.navpeII_dev18__Last_Touchpoint_ID__c.isUpdateable()) {
                            deal.navpeII_dev18__Last_Touchpoint_ID__c = relVsLTPId.get(strdeal);
                        }
                        if (Schema.sObjectType.navpeII_dev18__Pipeline__c.fields.navpeII_dev18__Last_Touch_Point__c.isUpdateable()) {
                            deal.navpeII_dev18__Last_Touch_Point__c = relVsLTPDate.get(strdeal);
                        }
                        updateDealLst.add(deal);
                    }
                    System.debug('rel trigger @@@@@ Deal');
            
                    if(updateDealLst.size() >0 && Schema.sObjectType.navpeII_dev18__Pipeline__c.isUpdateable())
                        Database.SaveResult[] srList=Database.update(updateDealLst);
                      //  update updateDealLst;
                    
                    relVsLTPId.clear();
                    relVsLTPDate.clear();
                }

                if(frdIds.size() >0){
                    for(Task tk : [SELECT Id, ActivityDate,navpeII_dev18__Related_Associations__c FROM Task WHERE navpeII_dev18__Is_Touchpoint_New__c = true AND navpeII_dev18__Related_Associations__c != null AND navpeII_dev18__Related_Associations__c Like :frdIds WITH SECURITY_ENFORCED Order By ActivityDate ASC Limit:limitExistForQuery]){
                        System.debug(tk);
                        for(String str : tk.navpeII_dev18__Related_Associations__c.split(',')){
                            Id objId = Id.valueOf(str);
                            if(objId.getsobjecttype().getDescribe().getName() == 'navpeII_dev18__Fundraising__c'){
                                relVsLTPDate.put(str,tk.ActivityDate);
                                relVsLTPId.put(str,tk.Id);
                            }
                        }
                    }

                    limitExistForQuery=Limits.getLimitQueryRows()-Limits.getQueryRows();
                    for(Event e: [SELECT Id, EndDateTime,navpeII_dev18__Is_Touchpoint_New__c,navpeII_dev18__Related_Associations__c FROM Event WHERE navpeII_dev18__Is_Touchpoint_New__c = true AND navpeII_dev18__Related_Associations__c != null AND navpeII_dev18__Related_Associations__c Like :frdIds WITH SECURITY_ENFORCED ORDER BY EndDateTime ASC Limit:limitExistForQuery]){
                        for(String str : e.navpeII_dev18__Related_Associations__c.split(',')){
                            Id objId = Id.valueOf(str);
                            if(objId.getsobjecttype().getDescribe().getName() == 'navpeII_dev18__Fundraising__c' && ((relVsLTPDate.containsKey(str) && relVsLTPDate.get(str)<e.EndDateTime.date()) || (!relVsLTPDate.containsKey(str)))){//Bug Fix - 45712
                                relVsLTPDate.put(str,e.EndDateTime.date());
                                relVsLTPId.put(str,e.Id);        
                            }
                        }
                    }
                    system.debug('@new11 '+relVsLTPDate);

                    //Update ltp when fundraising's previous past/current call/meeting is changed to future and there is no other past or current call/meeting 
                    for(String frdIdRec : frdIds){
                        if(!relVsLTPDate.containsKey(frdIdRec.remove('%'))){
                            system.debug('@new12 '+relVsLTPDate);
                            relVsLTPDate.put(frdIdRec.remove('%'),null);
                            relVsLTPId.put(frdIdRec.remove('%'),null);
                            system.debug('@new13 '+relVsLTPDate);
                        }
                    }

                    List<navpeII_dev18__Fundraising__c> updatefdrLst = new List<navpeII_dev18__Fundraising__c>();
                    for(String strdeal : relVsLTPId.keySet()){
                        navpeII_dev18__Fundraising__c fdr = new navpeII_dev18__Fundraising__c(Id=strdeal);
                        
            // Bug Id - 00045806 to fix API name and Label Deepak
                        if (Schema.sObjectType.navpeII_dev18__Fundraising__c.fields.navpeII_dev18__Last_Touchpoint_ID__c.isUpdateable()) {
                            fdr.navpeII_dev18__Last_Touchpoint_ID__c = relVsLTPId.get(strdeal);
                        }
                        if (Schema.sObjectType.navpeII_dev18__Fundraising__c.fields.navpeII_dev18__Last_Touch_Point__c.isUpdateable()) {
                            fdr.navpeII_dev18__Last_Touch_Point__c = relVsLTPDate.get(strdeal);
                        }
                        updatefdrLst.add(fdr);
                    }
                    System.debug('rel trigger @@@@@ fdr');
            
                    if(updatefdrLst.size() >0 && Schema.sObjectType.navpeII_dev18__Fundraising__c.isUpdateable())
                        Database.SaveResult[] srList=Database.update(updatefdrLst);
                     //   update updatefdrLst;
                    
                    relVsLTPId.clear();
                    relVsLTPDate.clear();
                }
            }else if(activityIdList!=null && activityIdList.size()>0 && String.valueOf(Id.valueOf(activityIdList[0]).getSObjectType())=='Event')
            {
                Integer limitExistForQuery=Limits.getLimitQueryRows()-Limits.getQueryRows();
               // navpe3Dev1__Related_Associations__c != null AND navpe3Dev1__Related_Associations__c Like :relAss
                for(Event evt : [SELECT Id, ActivityDate,navpeII_dev18__Related_Associations__c FROM Event WHERE Id IN:activityIdList WITH SECURITY_ENFORCED Limit:limitExistForQuery]){
                    for(String str : evt.navpeII_dev18__Related_Associations__c.split(',')){
                        Id objId = Id.valueOf(str);
                        if(objId.getsobjecttype().getDescribe().getName() == 'navpeII_dev18__Pipeline__c'){
                            dealIds.add('%'+str+'%');
                        }else if(objId.getsobjecttype().getDescribe().getName() == 'navpeII_dev18__Fundraising__c'){
                            frdIds.add('%'+str+'%');
                        }
                    }
                }

                if(dealIds.size() >0){
                    limitExistForQuery  = Limits.getLimitQueryRows() - Limits.getQueryRows();
                    for(Event evt : [SELECT Id, EndDateTime,navpeII_dev18__Related_Associations__c FROM Event WHERE navpeII_dev18__Is_Touchpoint_New__c = true AND navpeII_dev18__Related_Associations__c != null AND navpeII_dev18__Related_Associations__c Like :dealIds WITH SECURITY_ENFORCED Order By EndDateTime ASC Limit:limitExistForQuery]){
                        for(String str : evt.navpeII_dev18__Related_Associations__c.split(',')){
                            Id objId = Id.valueOf(str);
                            if(objId.getsobjecttype().getDescribe().getName() == 'navpeII_dev18__Pipeline__c'){
                                relVsLTPDate.put(str,evt.EndDateTime.Date());
                                relVsLTPId.put(str,evt.Id);
                            }
                        }
                    }

                    limitExistForQuery  = Limits.getLimitQueryRows() - Limits.getQueryRows();
                    for(Task tk : [SELECT Id, ActivityDate,navpeII_dev18__Related_Associations__c FROM Task WHERE navpeII_dev18__Is_Touchpoint_New__c = true AND navpeII_dev18__Related_Associations__c != null AND navpeII_dev18__Related_Associations__c Like :dealIds WITH SECURITY_ENFORCED Order By ActivityDate ASC Limit:limitExistForQuery]){
                       // System.debug(tk);
                        for(String str : tk.navpeII_dev18__Related_Associations__c.split(',')){
                            Id objId = Id.valueOf(str);
                            if(objId.getsobjecttype().getDescribe().getName() == 'navpeII_dev18__Pipeline__c' && ((relVsLTPDate.containsKey(str) && relVsLTPDate.get(str)<tk.ActivityDate) || (!relVsLTPDate.containsKey(str)))){//Bug fix - 45712
                                relVsLTPDate.put(str,tk.ActivityDate);
                                relVsLTPId.put(str,tk.Id);       
                            }
                        }
                    }
                     //Update ltp when Deal's previous past/current call/meeting is changed to future and there is no other past or current call/meeting 
                     for(String dealIdRec : dealIds){
                        if(!relVsLTPDate.containsKey(dealIdRec.remove('%'))){
                            relVsLTPDate.put(dealIdRec.remove('%'),null);
                            relVsLTPId.put(dealIdRec.remove('%'),null);
                        }
                    }
                    
                    List<navpeII_dev18__Pipeline__c> updateDealLst = new List<navpeII_dev18__Pipeline__c>();
                    for(String strdeal : relVsLTPId.keySet()){
                        navpeII_dev18__Pipeline__c deal = new navpeII_dev18__Pipeline__c(Id=strdeal);
                        
            // Bug Id - 00045806 to fix API name and Label Deepak
                        if (Schema.sObjectType.navpeII_dev18__Pipeline__c.fields.navpeII_dev18__Last_Touchpoint_ID__c.isUpdateable()) {
                            deal.navpeII_dev18__Last_Touchpoint_ID__c = relVsLTPId.get(strdeal);
                        }
                        if (Schema.sObjectType.navpeII_dev18__Pipeline__c.fields.navpeII_dev18__Last_Touch_Point__c.isUpdateable()) {
                            deal.navpeII_dev18__Last_Touch_Point__c = relVsLTPDate.get(strdeal);
                        }
                        updateDealLst.add(deal);
                    }
                    System.debug('rel trigger @@@@@ Deal');
            
                    if(updateDealLst.size() >0 && Schema.sObjectType.navpeII_dev18__Pipeline__c.isUpdateable())
                        Database.SaveResult[] srList=Database.update(updateDealLst);
    
                    //update updateDealLst;
                    
                    relVsLTPId.clear();
                    relVsLTPDate.clear();
                }

                if(frdIds.size() >0){
                    for(Event evt : [SELECT Id, ActivityDate,EndDateTime,navpeII_dev18__Related_Associations__c FROM Event WHERE navpeII_dev18__Is_Touchpoint_New__c = true AND navpeII_dev18__Related_Associations__c != null AND navpeII_dev18__Related_Associations__c Like :frdIds WITH SECURITY_ENFORCED Order By EndDateTime ASC Limit:limitExistForQuery]){
                        for(String str : evt.navpeII_dev18__Related_Associations__c.split(',')){
                            Id objId = Id.valueOf(str);
                            if(objId.getsobjecttype().getDescribe().getName() == 'navpeII_dev18__Fundraising__c'){
                                relVsLTPDate.put(str,evt.EndDateTime.Date());
                                relVsLTPId.put(str,evt.Id);
                            }
                        }
                    }

                    limitExistForQuery  = Limits.getLimitQueryRows() - Limits.getQueryRows();
                    for(Task tk : [SELECT Id, ActivityDate,navpeII_dev18__Related_Associations__c FROM Task WHERE navpeII_dev18__Is_Touchpoint_New__c = true AND navpeII_dev18__Related_Associations__c != null AND navpeII_dev18__Related_Associations__c Like :frdIds WITH SECURITY_ENFORCED Order By ActivityDate ASC Limit:limitExistForQuery]){
                       // System.debug(tk);
                        for(String str : tk.navpeII_dev18__Related_Associations__c.split(',')){
                            Id objId = Id.valueOf(str);
                            if(objId.getsobjecttype().getDescribe().getName() == 'navpeII_dev18__Fundraising__c' && ((relVsLTPDate.containsKey(str) && relVsLTPDate.get(str)<tk.ActivityDate) || (!relVsLTPDate.containsKey(str)))){//Bug fix - 45712
                                relVsLTPDate.put(str,tk.ActivityDate);
                                relVsLTPId.put(str,tk.Id);       
                            }
                        }
                    }

                    //Update ltp when fundraising's previous past/current call/meeting is changed to future and there is no other past or current call/meeting 
                    for(String frdIdRec : frdIds){
                        if(!relVsLTPDate.containsKey(frdIdRec.remove('%'))){
                            relVsLTPDate.put(frdIdRec.remove('%'),null);
                            relVsLTPId.put(frdIdRec.remove('%'),null);
                        }
                    }

                    List<navpeII_dev18__Fundraising__c> updatefdrLst = new List<navpeII_dev18__Fundraising__c>();
                    for(String strdeal : relVsLTPId.keySet()){
                        navpeII_dev18__Fundraising__c fdr = new navpeII_dev18__Fundraising__c(Id=strdeal);
                        
            // Bug Id - 00045806 to fix API name and Label Deepak
                        if (Schema.sObjectType.navpeII_dev18__Fundraising__c.fields.navpeII_dev18__Last_Touchpoint_ID__c.isUpdateable()) {
                            fdr.navpeII_dev18__Last_Touchpoint_ID__c = relVsLTPId.get(strdeal);
                        }
                        if (Schema.sObjectType.navpeII_dev18__Fundraising__c.fields.navpeII_dev18__Last_Touch_Point__c.isUpdateable()) {
                            fdr.navpeII_dev18__Last_Touch_Point__c = relVsLTPDate.get(strdeal);
                        }
                        updatefdrLst.add(fdr);
                    }
                    System.debug('rel trigger @@@@@ fdr');
            
                    if(updatefdrLst.size() >0 && Schema.sObjectType.navpeII_dev18__Fundraising__c.isUpdateable())
                        Database.SaveResult[] srList=Database.update(updatefdrLst);
    
                  //  update updatefdrLst;
                    
                    relVsLTPId.clear();
                    relVsLTPDate.clear();
                }
            }
            System.debug('deal '+dealIds);
            System.debug('fdr '+frdIds);

            
        } catch (Exception e) {
            System.debug('Error');
        }
    }

    /*
* Purpose : Runs when a Contact is Tagged to the Task
Checks whether all the Deals & Fundraisings are tagged to the Task in Related_Asspciations
if yes, no operation performed
if no, Deals and Fundraisings are tagged to the Task in Related_Associations.
* Returns : nothing
*/
global static void onDeleteActivity(String activityType,Set<Id> actIdsSet,Set<Id> conIdsSet){
        try{
            //Set<Id> conIdsSet=new Set<Id>();
            Set<Id> taskIdsSet=new Set<Id>();
            Set<Id> allTaskIdsSet=new Set<Id>();
            Set<Id> userIdsSet=new Set<Id>();
            Set<Id> eventIdsSet=new Set<Id>();
            Set<Id> allEventIdsSet=new Set<Id>();
            Map<Id,List<Id>> contactVsActIdsMap=new Map<Id,List<Id>>();
            Map<Id,List<Id>> userVsActIdsMap=new Map<Id,List<Id>>();
            Map<Id,Date> contactVsLTPDate= new Map<Id,Date>();
            Map<Id,Id> contactVsLTPId= new Map<Id,Id>();
            Map<Id,Date> userVsLTPDate= new Map<Id,Date>();
            Map<Id,Id> userVsLTPId= new Map<Id,Id>();
            Integer limitExistQuery = 0;
            if(String.isNotBlank(activityType) && activityType=='TaskRelation'){
                taskIdsSet=actIdsSet;
                //conIdsSet=conIdSet;
                // for(String conId:conIdSet){
                //     conIdsSet.add(Id.valueOf(conId));
                // }
                // for(TaskRelation tr:[Select Id, RelationId, TaskId from TaskRelation where Id IN: activityIdList WITH SECURITY_ENFORCED]){
                //     if(String.valueOf(tr.RelationId).startsWith('003')){
                //         conIdsSet.add(tr.RelationId);
                //         taskIdsSet.add(tr.TaskId);
                //     }
                // }
                //if(conIdsSet.size()>0 && taskIdsSet.size()>0){
                //all Tasks of this contact
                if(Schema.getGlobalDescribe().get('TaskWhoRelation') != null){
                    limitExistQuery  = Limits.getLimitQueryRows() - Limits.getQueryRows();
                        List<Sobject> twList = new List<Sobject>();
                        twList = Database.query('Select Id, RelationId,TaskId from TaskWhoRelation where RelationId IN: conIdsSet AND TaskID NOT IN: taskIdsSet WITH SECURITY_ENFORCED Limit 9999');// Suggetion:- on before delete 10000 record will come 
                for(Sobject twr:twList){
                    if(String.valueOf(twr.get('RelationId')).startsWith('003')){
                        allTaskIdsSet.add(String.valueof(twr.get('TaskId')));
                        if(!contactVsActIdsMap.containsKey(String.valueof(twr.get('RelationId')))){
                            List<String> taskIdStringList=new List<String>();
                            taskIdStringList.add(String.valueof(twr.get('TaskId')));
                            contactVsActIdsMap.put(String.valueof(twr.get('RelationId')), taskIdStringList);
                        }
                        else{
                            List<String> taskIdString2List=contactVsActIdsMap.get(String.valueof(twr.get('RelationId')));
                            taskIdString2List.add(String.valueof(twr.get('TaskId')));
                            contactVsActIdsMap.remove(String.valueof(twr.get('RelationId')));
                            contactVsActIdsMap.put(String.valueof(twr.get('RelationId')), taskIdString2List);
                    }
                }
                }}
                limitExistQuery  = Limits.getLimitQueryRows() - Limits.getQueryRows();
                for(Task t: [Select Id, ActivityDate,navpeII_dev18__Is_Touchpoint_New__c from Task where OwnerId IN: conIdsSet OR Id IN: allTaskIdsSet ORDER BY ActivityDate ASC Limit:limitExistQuery]){
                    for(String conIdStr:contactVsActIdsMap.keySet()){
                        if((!t.navpeII_dev18__Is_Touchpoint_New__c || t.ActivityDate == null) && contactVsActIdsMap.get(conIdStr).contains(t.Id)){
                            contactVsActIdsMap.get(conIdStr).remove(contactVsActIdsMap.get(conIdStr).indexOf(t.Id));
                        }
                        else{
                            contactVsLTPDate.put(conIdStr,t.ActivityDate);
                            contactVsLTPId.put(conIdStr,t.Id);
                        }
                    }
                }
                if(Schema.getGlobalDescribe().get('EventRelation') != null){
                        List<Sobject> eventRelationList = new List<Sobject>();
                    eventRelationList = Database.query('Select Id, RelationId,EventId from EventRelation where RelationId IN: conIdsSet WITH SECURITY_ENFORCED Limit 9999'); // Suggestion:- on before delete 10000 record will come  
                for(Sobject ewr:eventRelationList){
                    //if(String.valueOf(ewr.RelationId).startsWith('003')){
                    allEventIdsSet.add(String.valueof(ewr.get('EventId')));
                    String eRelationId = String.valueOf(ewr.get('RelationId'));
                    if(!contactVsActIdsMap.containsKey(eRelationId)){
                        List<String> eventIdStringList=new List<String>();
                        eventIdStringList.add(String.valueof(ewr.get('EventId')));
                        contactVsActIdsMap.put(eRelationId, eventIdStringList);
                    }
                    else{
                        List<String> eventIdString2List=contactVsActIdsMap.get(eRelationId);
                        eventIdString2List.add(String.valueof(ewr.get('EventId')));
                        contactVsActIdsMap.remove(eRelationId);
                        contactVsActIdsMap.put(eRelationId, eventIdString2List);
                    }
                    //}
                    // else if(String.valueOf(ewr.RelationId).startsWith('005')){
                    //     allEventIdsSet.add(ewr.EventId);
                    //     if(!userVsActIdsMap.containsKey(ewr.RelationId)){
                    //         List<String> eventIdStringList=new List<String>();
                    //         eventIdStringList.add(ewr.EventId);
                    //         userVsActIdsMap.put(ewr.RelationId, eventIdStringList);
                    //     }
                    //     else{
                    //         List<String> eventIdString2List=userVsActIdsMap.get(ewr.RelationId);
                    //         eventIdString2List.add(ewr.EventId);
                    //         userVsActIdsMap.remove(ewr.RelationId);
                    //         userVsActIdsMap.put(ewr.RelationId, eventIdString2List);
                    //     }
                    // }
                }
                }
                limitExistQuery  = Limits.getLimitQueryRows() - Limits.getQueryRows();
                for(Event e: [Select Id, EndDateTime,navpeII_dev18__Is_Touchpoint_New__c from Event where OwnerId IN: conIdsSet OR ID IN: allEventIdsSet ORDER BY EndDateTime ASC Limit:limitExistQuery]){
                    for(String conIdStr:contactVsActIdsMap.keySet()){
                        // if((!e.Is_Touchpoint_New__c || e.EndDateTime == null) && contactVsActIdsMap.get(conIdStr).contains(e.Id)){
                        //     contactVsActIdsMap.get(conIdStr).remove(contactVsActIdsMap.get(conIdStr).indexOf(e.Id));
                        // }
                        //else{
                        if(contactVsLTPDate.containsKey(conIdStr) && contactVsLTPDate.get(conIdStr)<e.EndDateTime.date() && e.navpeII_dev18__Is_Touchpoint_New__c){
                            contactVsLTPDate.put(conIdStr,e.EndDateTime.date());
                            contactVsLTPId.put(conIdStr,e.Id);
                        }
                        else if(!contactVsLTPDate.containsKey(conIdStr)){
                            contactVsLTPDate.put(conIdStr,e.EndDateTime.date());
                            contactVsLTPId.put(conIdStr,e.Id);
                        }
                        //}
                    }
                }
                List<Contact> updContacts=new List<Contact>();
                for(String strContact : contactVsLTPDate.keyset())
                {
                    if(strContact!=null){
                        contact con = new contact(Id=strContact);
                        if(contactVsLTPDate.get(strContact) !=null && contactVsLTPDate.get(strContact) != null && Schema.SObjectType.Contact.fields.navpeII_dev18__Last_Touch_Point__c.isUpdateable() && Schema.sObjectType.Contact.fields.navpeII_dev18__Last_Touchpoint_ID__c.isUpdateable()){ // added isUpdateable check for security issue PEv4.7
                            con.navpeII_dev18__Last_Touch_Point__c = contactVsLTPDate.get(strContact);
                            con.navpeII_dev18__Last_Touchpoint_ID__c=contactVsLTPId.get(strContact);// update for last touch point Id 
                            conIdsSet.remove(strContact);
                        }
                        else if(strContact!=null && Schema.SObjectType.Contact.fields.navpeII_dev18__Last_Touch_Point__c.isUpdateable() && Schema.sObjectType.Contact.fields.navpeII_dev18__Last_Touchpoint_ID__c.isUpdateable()){
                            con.navpeII_dev18__Last_Touch_Point__c = (Date)contactVsLTPDate.get(strContact);
                            con.navpeII_dev18__Last_Touchpoint_ID__c=contactVsLTPId.get(strContact);
                            conIdsSet.remove(strContact);
                        }
                        updContacts.add(con);
                    }
                }
                if(conIdsSet.size()>0){
                    for(Id conId:conIdsSet){
                        if(conId!=null){
                            contact con = new contact(Id=conId);
                            con.navpeII_dev18__Last_Touch_Point__c = null;
                            con.navpeII_dev18__Last_Touchpoint_ID__c=null;
                            updContacts.add(con);
                        }
                    }
                }
                
                if(updContacts.size() > 0 && Schema.sObjectType.Contact.isUpdateable()) { // added isUpdateable check for security issue PEv4.7
                    update updContacts;
                }
                //}
            }
            else if(String.isNotBlank(activityType) && activityType=='EventRelation'){
                eventIdsSet=actIdsSet;
                // for(EventRelation ev:[Select Id, RelationId, EventId from EventRelation where Id IN: activityIdList WITH SECURITY_ENFORCED]){
                //     if(String.valueOf(ev.RelationId).startsWith('003')){
                //         conIdsSet.add(ev.RelationId);
                //         eventIdsSet.add(ev.EventId);
                //     }
                //     else if(String.valueOf(ev.RelationId).startsWith('005')){
                //         userIdsSet.add(ev.RelationId);
                //         eventIdsSet.add(ev.EventId);
                //     }
                // }
                //if(conIdsSet.size()>0 && eventIdsSet.size()>0){
                //all Tasks of this contact
                if(Schema.getGlobalDescribe().get('EventRelation') != null){
                    limitExistQuery  = Limits.getLimitQueryRows() - Limits.getQueryRows();
                        List<Sobject> eventRelationList = new List<Sobject>();
                    eventRelationList = Database.query('Select Id, RelationId,EventId from EventRelation where RelationId IN: conIdsSet AND EventId NOT IN: eventIdsSet WITH SECURITY_ENFORCED Limit:limitExistQuery');
                for(Sobject ewr:eventRelationList){
                    // if(String.valueOf(ewr.RelationId).startsWith('003')){
                    allEventIdsSet.add(String.valueof(ewr.get('EventId')));
                    if(!contactVsActIdsMap.containsKey(String.valueof(ewr.get('RelationId')))){
                        List<String> eventIdStringList=new List<String>();
                        eventIdStringList.add(String.valueof(ewr.get('EventId')));
                        contactVsActIdsMap.put(String.valueof(ewr.get('RelationId')), eventIdStringList);
                    }
                    else{
                        List<String> eventIdString2List=contactVsActIdsMap.get(String.valueof(ewr.get('RelationId')));
                        eventIdString2List.add(String.valueof(ewr.get('EventId')));
                        contactVsActIdsMap.remove(String.valueof(ewr.get('RelationId')));
                        contactVsActIdsMap.put(String.valueof(ewr.get('RelationId')), eventIdString2List);
                    }
                    // }
                    // else if(String.valueOf(ewr.RelationId).startsWith('005')){
                    //     allEventIdsSet.add(ewr.EventId);
                    //     if(!userVsActIdsMap.containsKey(ewr.RelationId)){
                    //         List<String> eventIdStringList=new List<String>();
                    //         eventIdStringList.add(ewr.EventId);
                    //         userVsActIdsMap.put(ewr.RelationId, eventIdStringList);
                    //     }
                    //     else{
                    //         List<String> eventIdString2List=userVsActIdsMap.get(ewr.RelationId);
                    //         eventIdString2List.add(ewr.EventId);
                    //         userVsActIdsMap.remove(ewr.RelationId);
                    //         userVsActIdsMap.put(ewr.RelationId, eventIdString2List);
                    //     }
                    // }
                }
                }
                limitExistQuery  = Limits.getLimitQueryRows() - Limits.getQueryRows();
                for(Event e: [Select Id, EndDateTime,navpeII_dev18__Is_Touchpoint_New__c from Event where OwnerId IN: conIdsSet OR ID IN: allEventIdsSet ORDER BY EndDateTime ASC Limit:limitExistQuery]){
                    for(String conIdStr:contactVsActIdsMap.keySet()){
                        if((!e.navpeII_dev18__Is_Touchpoint_New__c || e.EndDateTime == null) && contactVsActIdsMap.get(conIdStr).contains(e.Id)){
                            contactVsActIdsMap.get(conIdStr).remove(contactVsActIdsMap.get(conIdStr).indexOf(e.Id));
                        }
                        else{
                            contactVsLTPDate.put(conIdStr,e.EndDateTime.date());
                            contactVsLTPId.put(conIdStr,e.Id);
                        }
                    }/*LTP User Logic commented
for(String userIdStr:userVsActIdsMap.keySet()){
if((!e.Is_Touchpoint_New__c || e.EndDateTime == null) && userVsActIdsMap.get(userIdStr).contains(e.Id)){
userVsActIdsMap.get(userIdStr).remove(userVsActIdsMap.get(userIdStr).indexOf(e.Id));
}
else{
userVsLTPDate.put(userIdStr,e.EndDateTime);
userVsLTPId.put(userIdStr,e.Id);
}
}*/
                }
                if(Schema.getGlobalDescribe().get('TaskRelation') != null){
                    limitExistQuery  = Limits.getLimitQueryRows() - Limits.getQueryRows();
                        List<Sobject> eventRelationList = new List<Sobject>();
                        eventRelationList = Database.query('Select Id, RelationId,TaskId from TaskRelation where RelationId IN: conIdsSet WITH SECURITY_ENFORCED Limit:limitExistQuery');
                for(Sobject twr:eventRelationList){
                    //if(String.valueOf(twr.RelationId).startsWith('003')){
                    allTaskIdsSet.add(String.valueof(twr.get('TaskId')));
                    if(!contactVsActIdsMap.containsKey(String.valueof(twr.get('RelationId')))){
                        List<String> taskIdStringList=new List<String>();
                        taskIdStringList.add(String.valueof(twr.get('TaskId')));
                        contactVsActIdsMap.put(String.valueof(twr.get('RelationId')), taskIdStringList);
                    }
                    else{
                        List<String> taskIdString2List=contactVsActIdsMap.get(String.valueof(twr.get('RelationId')));
                        taskIdString2List.add(String.valueof(twr.get('TaskId')));
                        contactVsActIdsMap.remove(String.valueof(twr.get('RelationId')));
                        contactVsActIdsMap.put(String.valueof(twr.Get('RelationId')), taskIdString2List);
                    }
                    //}
                }
                }
                limitExistQuery  = Limits.getLimitQueryRows() - Limits.getQueryRows();
                for(Task t: [Select Id, ActivityDate,navpeII_dev18__Is_Touchpoint_New__c from Task where OwnerId IN: conIdsSet OR Id IN: allTaskIdsSet ORDER BY ActivityDate ASC Limit:limitExistQuery]){
                    for(String conIdStr:contactVsActIdsMap.keySet()){
                        // if((!t.Is_Touchpoint_New__c || t.ActivityDate == null) && contactVsActIdsMap.get(conIdStr).contains(t.Id)){
                        //     contactVsActIdsMap.get(conIdStr).remove(contactVsActIdsMap.get(conIdStr).indexOf(t.Id));
                        // }
                        // else{
                        if(contactVsLTPDate.containsKey(conIdStr) && contactVsLTPDate.get(conIdStr)<t.ActivityDate && t.navpeII_dev18__Is_Touchpoint_New__c){
                            contactVsLTPDate.put(conIdStr,t.ActivityDate);
                            contactVsLTPId.put(conIdStr,t.Id);
                        }
                        else if(!contactVsLTPDate.containsKey(conIdStr) && t.navpeII_dev18__Is_Touchpoint_New__c){
                            contactVsLTPDate.put(conIdStr,t.ActivityDate);
                            contactVsLTPId.put(conIdStr,t.Id);
                        }
                        // }
                    }
                }
                List<Contact> updContacts=new List<Contact>();
                for(String strContact : contactVsLTPDate.keyset())
                {
                    if(strContact!=null){
                        contact con = new contact(Id=strContact);
                        if(contactVsLTPDate.get(strContact) !=null && contactVsLTPDate.get(strContact) != null && Schema.SObjectType.Contact.fields.navpeII_dev18__Last_Touch_Point__c.isUpdateable() && Schema.sObjectType.Contact.fields.navpeII_dev18__Last_Touchpoint_ID__c.isUpdateable()){ // added isUpdateable check for security issue PEv4.7
                            con.navpeII_dev18__Last_Touch_Point__c = contactVsLTPDate.get(strContact);
                            con.navpeII_dev18__Last_Touchpoint_ID__c=contactVsLTPId.get(strContact);// update for last touch point Id 
                            conIdsSet.remove(strContact);
                        }
                        else if(strContact!=null && Schema.SObjectType.Contact.fields.navpeII_dev18__Last_Touch_Point__c.isUpdateable() && Schema.sObjectType.Contact.fields.navpeII_dev18__Last_Touchpoint_ID__c.isUpdateable()){
                            con.navpeII_dev18__Last_Touch_Point__c = (Date)contactVsLTPDate.get(strContact);
                            con.navpeII_dev18__Last_Touchpoint_ID__c=contactVsLTPId.get(strContact);
                            conIdsSet.remove(strContact);
                        }
                        updContacts.add(con);
                    }
                }
                if(conIdsSet.size()>0){
                    for(Id conId:conIdsSet){
                        if(conId!=null){
                            contact con = new contact(Id=conId);
                            con.navpeII_dev18__Last_Touch_Point__c = null;
                            con.navpeII_dev18__Last_Touchpoint_ID__c=null;
                            updContacts.add(con);
                        }
                    }
                }
                
                if(updContacts.size() > 0 && Schema.sObjectType.Contact.isUpdateable()) { // added isUpdateable check for security issue PEv4.7
                    update updContacts;
                }  
                //}
                
            }
            //LTP User Logic commented
            /*if(userVsActIdsMap.size()>0){
                List<User> userList=new List<User>();
                for(String userIdStr:userVsActIdsMap.keySet()){
                    User u=new User(Id=useridStr);
                    if(userVsLTPDate!=null && userVsLTPDate.containsKey(userIdStr) && 
                       Schema.SObjectType.User.fields.Last_Touchpoint__c.isUpdateable() && 
                       Schema.sObjectType.User.fields.Last_Touchpoint_ID__c.isUpdateable()){
                           u.Last_Touchpoint__c=userVsLTPDate.get(userIdStr);
                           u.Last_Touchpoint_ID__c=userVsLTPId!=null?userVsLTPId.get(useridStr):null;
                       }
                    else if(Schema.SObjectType.User.fields.Last_Touchpoint__c.isUpdateable() && 
                            Schema.sObjectType.User.fields.Last_Touchpoint_ID__c.isUpdateable()){
                                u.Last_Touchpoint__c=null;
                                u.Last_Touchpoint_ID__c=null;
                            }
                    userList.add(u);
                }
                if(userList.size()>0 && Schema.sObjectType.User.isUpdateable()){
                    update userList;
                }
            }*/
            
        }
        catch(Exception e){
            
        }
    }

    // Added by Sudhanshu
    public static void deleteRichTextField(set<ID> ActivityId){
        try {
            System.debug('ActivityId =>'+ActivityId);
            List<navpeII_dev18__Note__c> lstToDelete = [SELECT navpeII_dev18__Activity_ID__c, navpeII_dev18__Description__c  FROM navpeII_dev18__Note__c where navpeII_dev18__Activity_ID__c IN : ActivityId];
            if(Schema.sObjectType.navpeII_dev18__Note__c.isDeletable())
            {
                System.debug('lstToDelete.size() >'+lstToDelete.size());
                if(lstToDelete.size() > 0)
                {
                    Database.DeleteResult[] drList = Database.delete(lstToDelete, false);
                }
            }
        } catch (DMLException e) {
            System.debug('Error');
        }
    }


    /*
* Purpose : Related_Associations field is sanitized as per the comma separated format recommended
* Returns : Related_Associations field in proper format.
*/
global static String sanitizeAssociations(String oldAssociations,Set<String> strSet1,Set<String> strSet2){
        String str=String.isBlank(oldAssociations)?'':oldAssociations;
        for(String s:strSet1){
            if(String.isNotBlank(s) && !str.contains(s)){
                str+=','+s;
            }
        }
        for(String s:strSet2){
            if(String.isNotBlank(s) && !str.contains(s)){
                str+=','+s;
            }
        }
        return str.trim().removeStart(',').remove('(').remove(')');
    }
    
}