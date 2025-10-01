public with sharing class NavatarContactPDFCtrl {
    //Stores the record id vs associated activity ids set
    private static Map<String, Set<String>> objIdVsActIdsMap {get;set;}
    private static Map<String, Set<String>> objIdVsActIdsMap1 {get;set;}
    //Stores set of Accounts with Deals associated to them
    private static Set<String> accIdSet {get;set;}
    public static List<DealWrapper> dealWrapLst{get;set;}
    public List<navpeII_dev18__Deal_Team__c> dealTeamLst{get; set;}
    public static Map<ID,Id> conVSMentnBy{get;set;}
    public String mainTitle {get;set;}
    public String infoDetail1 {get;set;}
    public List<TaggedFirmWrapper> taggedFirmWrapLst{get;set;}
    public List<DealsWrapper> listOfDealWrapper{get;set;}
    
    public String infoDetail2 {get;set;}
    public String infoDetail3 {get;set;}
    public String infoDetail4 {get;set;}
    public String Name{get; set;}
    public String mainContact{get; set;}
    public List<Account> accList{get;set;}
    public List<navpeII_dev18__Pipeline__c> dealsList{get;set;}
    public List<Contact> conList{get;set;}
    public List<Account> refComList{get;set;}
    public List<Contact> refPplList{get;set;}
    public List<navpeII_dev18__Pipeline__c> refDealsList{get;set;}
    public List<Task> taskList{get;set;}
    public List<Event> eventList{get;set;}
    public List<ReferencedPeopleWrapper> refPplWrapList{get; set;}
    public List<String> actIdList{get;set;}
    public List<TaskInteractionWrapper> interactionList{get;set;}
    public List<EventInteractionWrapper> eventInteractionList{get;set;}
    public Map<ID,Set<ID>> evtIdVSConname {get;set;}
    public Map<Id,Set<Id>> taskIdVSConname {get;set;}
    private static Set<String> completeActIdsSet{get;set;}
    private static Set<String> actIdsSet{get;set;}
    public static Map<String,Set<ID>> objNameVSsetId{get;set;}
    private static string accConnectionEndPoint{get;set;}
    private static string storePost{get;set;}
    private static String apiKey{get;set;}
    //store this variable revenue grid api key
    private static string storeApiKey {get;set;}
    //store this variable authorization
    private static string storeAuth{get;set;}
    //store this variable content type
    private static string storeCT {get;set;}
    //store this variable application json format
    private static string storeTPJson{get;set;}
    private static string getUserEndPoint {get;set;}
    private static String subjectDomainName{get;set;}
    private static string storeGet{get;set;}
    private static Map<String,String> userIdVsMBid{get;set;}
    private static Map<String,Integer> userIdVsEmailCount{get;set;}
    private static Map<String, Integer> emailVsCount {get;set;}
    private static Map<String, Set<String>> objIdVsDealIdsMap {get;set;}
    private static Map<String, Set<String>> objIdVsDealIdsMapExternal {get;set;}
    public static List<ResponseWrapper> resWrap {get;set;}
    private static Map<String, LastInteractionInfo> objIdVsLastInteractionInfoMap{get;set;}
    private static string accConQueryEndPoint{get;set;}
    private static string accConActivityEndPoint{get;set;}
    public List<Internal> conInfoWrapper1{get;set;}
    public static String dummy{get;set;}
    //public static String query{get;set;}
    public Map<String,Set<String>> taskNotAccessField{get;set;}
    public Map<String,set<String>> eventNotAccessField{get;set;}
    public SObjectAccessDecision taskAccessList{get;set;}
    public List<External> conInfoWrapperExternal{get;set;}
    public Set<ID> peoplConIDSet{get;set;}
    public String getCtrl {get;set;}
    public NavatarContactPDFCtrl (ApexPages.StandardController ctrl){
        getCtrl = ctrl.getId();
        conVSMentnBy = new Map<Id,Id>();
        peoplConIDSet = new Set<ID>();
        refDealsList = new List<navpeII_dev18__Pipeline__c>();
        // query='Select Id';
        dealWrapLst = new List<DealWrapper>();
        dealTeamLst = new List<navpeII_dev18__Deal_Team__c>();
        taskNotAccessField = new Map<String,Set<String>>();
        eventNotAccessField=new Map<String,set<String>>();
        // taskAccessList = new SObjectAccessDecision();
        completeActIdsSet = new Set<String>();
        conInfoWrapperExternal= new List<external>();
        actIdsSet = new Set<String>();
        dummy= '';
        objIdVsActIdsMap = new Map<String, Set<String>>();
        objIdVsActIdsMap1 = new Map<String, Set<String>>();
        objNameVSsetId = new Map <String,Set<ID>>();
        evtIdVSConname = new Map<ID,Set<ID>>();//contact vs event
        taskIdVSConname = new Map<ID,Set<ID>>();//contact vs task
        objIdVsDealIdsMap =  new Map<String,Set<String>>();
        objIdVsDealIdsMapExternal = new Map<String,Set<String>>();// Resolving critical bug 00039864
        resWrap =new  List<ResponseWrapper>();
        accIdSet = new Set<String>();
        conInfoWrapper1 = new List<Internal>();
        accConnectionEndPoint = RG_Setting__mdt.getInstance('RG_Firm_Contacts').Value__c;
        storePost = 'POST';
        apiKey = [SELECT Value__c FROM RG_Setting__mdt WHERE DeveloperName = 'RG_API_Key'].Value__c;
        storeApiKey = 'ApiKey '+apiKey;
        storeAuth = 'Authorization';
        storeCT = 'Content-Type';
        storeTPJson = 'application/json';
        storeGet = 'GET';
        accConQueryEndPoint = RG_Setting__mdt.getInstance('RG_AddIcon_Contact_Name').Value__c;
        getUserEndPoint = RG_Setting__mdt.getInstance('RG_Link_SF_Outlook').Value__c;
        subjectDomainName = RG_Setting__mdt.getInstance('RG_ActID').Value__c;
        userIdVsMBid = new Map<String,String>();
        userIdVsEmailCount  = new Map<String,Integer>();
        emailVsCount = new Map<String, Integer>();
        accConActivityEndPoint = RG_Setting__mdt.getInstance('RG_Connection_Count').Value__c;
        objIdVsLastInteractionInfoMap = new Map<String, LastInteractionInfo>();
        SObjectAccessDecision securityDecision = 
            Security.stripInaccessible(AccessType.READABLE,
                                       [SELECT ID, Name, Owner.Name,AccountId, FORMAT(navpeII_dev18__Last_Touch_Point__c), Email, Title, Phone, MailingAddress,MailingStreet,MailingCity,MailingPostalCode,MailingState,MailingCountry FROM Contact Where ID =:ctrl.getId() LIMIT :(Limits.getLimitQueryRows() - Limits.getQueryRows())]);
        Contact cont = (Contact) securityDecision.getRecords()[0];
        mainTitle =  securityDecision.getRemovedFields().get('Contact') == null ? (cont.Title!= null ? cont.Name +','+cont.Title : cont.Name) : securityDecision.getRemovedFields().get('Contact').contains('Title') ? cont.Name : (cont.Title!= null ? cont.Name +','+cont.Title : cont.Name);
            infoDetail1 = securityDecision.getRemovedFields().get('Contact') == null ? (cont.Owner.Name != null ? cont.Owner.Name + ', ' : ''):securityDecision.getRemovedFields().get('Contact').contains('Owner.Name')?' ':(cont.Owner.Name != null ? cont.Owner.Name + ', ' : '');//cont.Owner.Name;
                infoDetail2 =securityDecision.getRemovedFields().get('Contact') == null ? (cont.navpeII_dev18__Last_Touch_Point__c != null? String.valueOF(cont.navpeII_dev18__Last_Touch_Point__c.month()+'/'+cont.navpeII_dev18__Last_Touch_Point__c.day()+'/'+cont.navpeII_dev18__Last_Touch_Point__c.year()) : '') : securityDecision.getRemovedFields().get('Contact').contains('navpeII_dev18__Last_Touch_Point__c')?' ':(cont.navpeII_dev18__Last_Touch_Point__c != null? String.valueOF(cont.navpeII_dev18__Last_Touch_Point__c.month()+'/'+cont.navpeII_dev18__Last_Touch_Point__c.day()+'/'+cont.navpeII_dev18__Last_Touch_Point__c.year()) : '');
                    infoDetail3 = '';
        infoDetail3 += securityDecision.getRemovedFields().get('Contact') == null ? (cont.MailingStreet != null ? cont.MailingStreet + ', ' : ''):securityDecision.getRemovedFields().get('Contact').contains('MailingStreet')?' ':(cont.MailingStreet != null ? cont.MailingStreet + ', ' : '');
            infoDetail3 += securityDecision.getRemovedFields().get('Contact') == null ? (cont.MailingCity != null ? cont.MailingCity + ', ' : ''):securityDecision.getRemovedFields().get('Contact').contains('MailingCity')?' ':(cont.MailingCity != null ? cont.MailingCity + ', ' : '');
                infoDetail3 += securityDecision.getRemovedFields().get('Contact') == null ? (cont.MailingPostalCode != null ? cont.MailingPostalCode + ', ' : ''):securityDecision.getRemovedFields().get('Contact').contains('MailingPostalCode')?' ':(cont.MailingPostalCode != null ? cont.MailingPostalCode + ', ' : '');
                    infoDetail3 += securityDecision.getRemovedFields().get('Contact') == null ? (cont.MailingState != null ? cont.MailingState + ', ' : '') :securityDecision.getRemovedFields().get('Contact').contains('MailingState')?' ':(cont.MailingState != null ? cont.MailingState + ', ' : '');
                        infoDetail3 += securityDecision.getRemovedFields().get('Contact') == null ? (cont.MailingCountry != null ? cont.MailingCountry + ', ' : ''):securityDecision.getRemovedFields().get('Contact').contains('MailingCountry')?' ':(cont.MailingCountry != null ? cont.MailingCountry + ', ' : '');
                            infoDetail3=infoDetail3.left(infoDetail3.length()-2);
        infoDetail4 = securityDecision.getRemovedFields().get('Contact') == null ? (cont.Phone):securityDecision.getRemovedFields().get('Contact').contains('Phone')?' ':(cont.Phone);
            String nSpace=getNamespacePrefix();
        List<String> conIdList=new List<String>();
        SObjectAccessDecision contactsAccessList = 
            Security.stripInaccessible(AccessType.READABLE,
                                       [Select Id, Name, Title, navpeII_dev18__forTotalDealsShown__c, navpeII_dev18__Last_Touch_Point__c, Owner.Name from Contact where ID =: ctrl.getId() ]);
        conList=(List<Contact>) contactsAccessList.getRecords();
        for(Contact con:conList){
            conIdList.add(con.Id);
        }
        List<String> actIdList = (fetchRecsToProcess(ctrl.getId(), 'Task', ' WHERE (Task.TaskSubType != \'ListEmail\') AND (RelationId =: recordId)'));
        actIdList.addAll(fetchRecsToProcess(ctrl.getId(), 'Event', ' WHERE RelationId =: recordId'));
        Set<Id> dealId = new Set<Id>();
        if(Schema.sObjectType.navpeII_dev18__Deal_Team__c.isAccessible() && Schema.sObjectType.navpeII_dev18__Pipeline__c.isAccessible()){
            SObjectAccessDecision dealAccessList = 
                Security.stripInaccessible(AccessType.READABLE,[Select id, navpeII_dev18__Deal__c, navpeII_dev18__Deal_Contact__c from navpeII_dev18__Deal_Team__c  where navpeII_dev18__Deal_Contact__c =: ctrl.getId() LIMIT :(Limits.getLimitQueryRows() - Limits.getQueryRows())]);
            List<navpeII_dev18__Deal_Team__c> dealTeamLst =(List<navpeII_dev18__Deal_Team__c>) dealAccessList.getRecords();
            for(navpeII_dev18__Deal_Team__c dealTeam : dealTeamLst){
                if(dealTeam.isSet('navpeII_dev18__Deal__c')){
                    dealId.add(dealTeam.navpeII_dev18__Deal__c);
                }
            }
        }
        //here
        if(Schema.sObjectType.navpeII_dev18__Pipeline__c.isAccessible()){
            SObjectAccessDecision pipelineAccessList = 
                Security.stripInaccessible(AccessType.READABLE,
                                           [Select Id,Name, navpeII_dev18__Stage__c, navpeII_dev18__Log_In_Date__c, navpeII_dev18__Deal_Team_Members__c,navpeII_dev18__Source_Company__c,navpeII_dev18__Source_Company__r.Name, navpeII_dev18__Deal_Description__c, navpeII_dev18__Source_Contact__c, navpeII_dev18__Pipeline_Comments__c from navpeII_dev18__Pipeline__c where navpeII_dev18__Source_Contact__c =: ctrl.getId() OR ID IN:dealId LIMIT :(Limits.getLimitQueryRows() - Limits.getQueryRows())]);
            dealsList=pipelineAccessList.getRecords();
            //dealsList=[Select Id,Name, navpeII_dev18__Stage__c, navpeII_dev18__Log_In_Date__c, navpeII_dev18__Deal_Team_Members__c,navpeII_dev18__Source_Company__r.Name, navpeII_dev18__Deal_Description__c, navpeII_dev18__Source_Contact__c, navpeII_dev18__Pipeline_Comments__c from navpeII_dev18__Pipeline__c where navpeII_dev18__Source_Contact__c =: ctrl.getId() OR ID IN:dealId WITH SECURITY_ENFORCED];
            listOfDealWrapper = new List<DealsWrapper>();
            for(navpeII_dev18__Pipeline__c pl :dealsList){
                DealsWrapper dlWrp = new DealsWrapper();
                dlWrp.name=pl.Name;
                dlWrp.stage=pipelineAccessList.getRemovedFields().get('navpeII_dev18__Pipeline__c')==null?(pl.navpeII_dev18__Stage__c !=null ?pl.navpeII_dev18__Stage__c:'') :pipelineAccessList.getRemovedFields().get('navpeII_dev18__Pipeline__c').contains('navpeII_dev18__Stage__c')?'':(pl.navpeII_dev18__Stage__c !=null ?pl.navpeII_dev18__Stage__c:'');
                    dlWrp.loginDate=pipelineAccessList.getRemovedFields().get('navpeII_dev18__Pipeline__c')==null?(pl.navpeII_dev18__Log_In_Date__c !=null ?String.valueOf(pl.navpeII_dev18__Log_In_Date__c.month()+'/'+pl.navpeII_dev18__Log_In_Date__c.day()+'/'+pl.navpeII_dev18__Log_In_Date__c.year()):'') :pipelineAccessList.getRemovedFields().get('navpeII_dev18__Pipeline__c').contains('navpeII_dev18__Log_In_Date__c')?'':(pl.navpeII_dev18__Log_In_Date__c !=null ?String.valueOf(pl.navpeII_dev18__Log_In_Date__c.month()+'/'+pl.navpeII_dev18__Log_In_Date__c.day()+'/'+pl.navpeII_dev18__Log_In_Date__c.year()):'');//pl.navpeII_dev18__Log_In_Date__c;
                        dlWrp.sourceFirm=pipelineAccessList.getRemovedFields().get('navpeII_dev18__Pipeline__c')==null?(pl.navpeII_dev18__Source_Company__c !=null ?pl.navpeII_dev18__Source_Company__r.Name:'') :pipelineAccessList.getRemovedFields().get('navpeII_dev18__Pipeline__c').contains('navpeII_dev18__Source_Company__c')?'':(pl.navpeII_dev18__Source_Company__c !=null ?pl.navpeII_dev18__Source_Company__r.Name:'');  //pl.navpeII_dev18__Source_Company__r.Name;
                            dlWrp.notes=pipelineAccessList.getRemovedFields().get('navpeII_dev18__Pipeline__c')==null?(pl.navpeII_dev18__Pipeline_Comments__c !=null ?pl.navpeII_dev18__Pipeline_Comments__c:'') :pipelineAccessList.getRemovedFields().get('navpeII_dev18__Pipeline__c').contains('navpeII_dev18__Pipeline_Comments__c')?'':(pl.navpeII_dev18__Pipeline_Comments__c !=null ?pl.navpeII_dev18__Pipeline_Comments__c:'');//pl.navpeII_dev18__Pipeline_Comments__c;
                                listOfDealWrapper.add(dlWrp);
            }
        }
        Set<Id> refComAccSet=new Set<Id>();
        Set<Id> refPplConSet=new Set<Id>();
        Set<Id> refDealIdSet=new Set<Id>();
        Set<Id> interactionActIdSet=new Set<Id>();
        string accValue='AccountId';
        string queryValue='SELECT RelationId, EventId, Event.navpeII_dev18__Related_Associations__c,Event.WhatId,Event.WhoId FROM EventRelation Where EventId IN :actIdList';
        if( Schema.getGlobalDescribe().get('EventRelation').getDescribe().fields.getMap().get('AccountId') != null){
            queryValue='SELECT AccountId, RelationId, EventId, Event.navpeII_dev18__Related_Associations__c,Event.WhatId,Event.WhoId FROM EventRelation Where EventId IN :actIdList';
        }
        SObjectAccessDecision eventRelationAccessRec = 
            Security.stripInaccessible(AccessType.READABLE,
                                       Database.query(queryValue));
        List<SObject> EventRelationRecList = eventRelationAccessRec.getRecords();
        for(SObject er: EventRelationRecList){
            interactionActIdSet.add(eventRelationAccessRec.getRemovedFields().get('EventRelation') == null ?(Id) er.get('EventId'):!eventRelationAccessRec.getRemovedFields().get('EventRelation').contains('EventId')?(Id) er.get('EventId'): null);
            if( Schema.getGlobalDescribe().get('EventRelation').getDescribe().fields.getMap().get('AccountId') != null){
                refComAccSet.add(eventRelationAccessRec.getRemovedFields().get('EventRelation') == null ?(Id) er.get('AccountId'):!eventRelationAccessRec.getRemovedFields().get('EventRelation').contains('AccountId')?(Id) er.get('AccountId'): null);
            }
            if(eventRelationAccessRec.getRemovedFields().get('EventRelation') == null? true:!eventRelationAccessRec.getRemovedFields().get('EventRelation').contains('RelationId')){
                if(String.valueOf((Id) er.get('RelationId')).startsWith('003')){
                    refPplConSet.add((Id) er.get('RelationId'));
                    if(!objNameVSsetId.containsKey(((Id) er.get('RelationId')).getSObjectType().getDescribe().getName())){
                        if((Id) er.get('RelationId')!=ctrl.getId()){
                            
                            Set<ID> objID = new Set<ID>();
                            objID.add((Id)er.get('RelationId'));
                            objNameVSsetId.put(((Id)er.get('RelationId')).getSObjectType().getDescribe().getName(),objID);
                        }
                    }
                    
                    else{
                        Set<ID> getID = objNameVSsetId.get(((Id) er.get('RelationId')).getSObjectType().getDescribe().getName());
                        if((Id)er.get('RelationId')!=ctrl.getId()){
                            getID.add((Id)er.get('RelationId'));
                        }
                        objNameVSsetId.put(((Id)er.get('RelationId')).getSObjectType().getDescribe().getName(),getID);
                    }
                    if(!evtIdVSConname.containsKey((Id)er.get('RelationId'))){
                    Set<Id> eventIdset = new Set<Id>();
                    eventIdset.add(eventRelationAccessRec.getRemovedFields().get('EventRelation') == null ?(Id)er.get('EventId') :!eventRelationAccessRec.getRemovedFields().get('EventRelation').contains('EventId')?(Id)er.get('EventId') :'');
                     evtIdVSConname.put(((Id)er.get('RelationId')),eventIdset);
                }
                else{
                    Set<Id> getEventId = evtIdVSConname.get((Id)er.get('RelationId'));
                    getEventId.add(eventRelationAccessRec.getRemovedFields().get('EventRelation') == null ?(Id)er.get('EventId') :!eventRelationAccessRec.getRemovedFields().get('EventRelation').contains('EventId')?(Id)er.get('EventId') :'');
                     evtIdVSConname.put(((Id)er.get('RelationId')),getEventId);
                }
                  //  evtIdVSConname.put(((Id) er.get('RelationId')),(id)er.get('EventId'));
                }
            }
            
            
            // refComAccSet.add(er.Event.WhatId);
            refPplConSet.add(eventRelationAccessRec.getRemovedFields().get('EventRelation') == null ?((Id) er.getSobject('Event').get('WhoId')): !eventRelationAccessRec.getRemovedFields().get('EventRelation').contains('EventId')?((Id) er.getSobject('Event').get('WhoId')):null);
            /* if(!eventRelationAccessRec.getRemovedFields().get('EventRelation').contains('WhoId')){
refPplConSet.add(er.Event.WhoId);
} */
            if(eventRelationAccessRec.getRemovedFields().get('EventRelation') == null ? true :!eventRelationAccessRec.getRemovedFields().get('EventRelation').contains('navpeII_dev18__Related_Associations__c')){
                if(String.isNotBlank((String)er.getSobject('Event').get('navpeII_dev18__Related_Associations__c')))
                    
                    for(String s:(String.valueOf(er.getSobject('Event').get('navpeII_dev18__Related_Associations__c'))).split(',')){
                        if(s.startsWith('001'))
                            refComAccSet.add(s);
                        //.getSObjectType().getDescribe().getName()
                        else if(String.valueOf(Id.valueOf(s).getSObjectType())=='navpeII_dev18__Pipeline__c')
                            refDealIdSet.add(s);
                    }
            }
        }
        Integer remainingRows = Limits.getLimitQueryRows() - Limits.getQueryRows();
        if( Schema.getGlobalDescribe().get('TaskRelation') != Null){
        SObjectAccessDecision TaskRelationAccessRecList = 
            Security.stripInaccessible(AccessType.READABLE,
                                       Database.query('SELECT AccountId, RelationId, TaskId, Task.navpeII_dev18__Related_Associations__c,Task.WhatId,Task.WhoId FROM TaskRelation WHERE TaskId IN :actIdList'+ ' Limit '+remainingRows));
        List<SObject> taskRelationList = TaskRelationAccessRecList.getRecords();
        for(SObject tr : taskRelationList){
            interactionActIdSet.add(TaskRelationAccessRecList.getRemovedFields().get('TaskRelation') == null ?(Id)tr.get('TaskId') :!TaskRelationAccessRecList.getRemovedFields().get('TaskRelation').contains('TaskId') ?(Id)tr.get('TaskId') : null);
            /* if(!TaskRelationAccessRecList.getRemovedFields().get('TaskRelation').contains('TaskId')){
interactionActIdSet.add(tr.TaskId);
} */
            refComAccSet.add(TaskRelationAccessRecList.getRemovedFields().get('TaskRelation') == null ?(Id) tr.get('AccountId') :!TaskRelationAccessRecList.getRemovedFields().get('TaskRelation').contains('AccountId')?(Id) tr.get('AccountId') :null);
            /* if(!TaskRelationAccessRecList.getRemovedFields().get('TaskRelation').contains('AccountId')){
refComAccSet.add(tr.AccountId);
}*/
            //refComAccSet.add(tr.Task.WhatId);
            if(TaskRelationAccessRecList.getRemovedFields().get('TaskRelation') == null ?true:!TaskRelationAccessRecList.getRemovedFields().get('TaskRelation').contains('RelationId')){
                if(String.valueOf((Id)tr.get('RelationId')).startsWith('003')){
                    refPplConSet.add((Id)tr.get('RelationId'));
                    
                    refPplConSet.add(TaskRelationAccessRecList.getRemovedFields().get('TaskRelation') == null ?  (Id) tr.getSobject('Task').get('WhoId') :!TaskRelationAccessRecList.getRemovedFields().get('TaskRelation').contains('TaskId') ?  (Id) tr.getSobject('Task').get('WhoId') : null);
                    //if(!TaskRelationAccessRecList.getRemovedFields().get('TaskRelation').contains('WhoId')){
                    //refPplConSet.add(tr.Task.WhoId);
                    
                    if(!objNameVSsetId.containsKey(((Id) tr.get('RelationId')).getSObjectType().getDescribe().getName())){
                        // System.debug('myRecordId.getSObjectType().getDescribe().getName()'+tr.RelationId.getSObjectType().getDescribe().getName());
                        if((Id)tr.get('RelationId')!=ctrl.getId()){
                            Set<ID> objID = new Set<ID>();
                            objID.add((Id)tr.get('RelationId'));
                            objNameVSsetId.put(((Id)tr.get('RelationId')).getSObjectType().getDescribe().getName(),objID);
                            
                        }
                    }
                    else{
                        Set<ID> getID = objNameVSsetId.get(((Id) tr.get('RelationId')).getSObjectType().getDescribe().getName());
                        if((Id)tr.get('RelationId')!=ctrl.getId()){
                            getID.add((Id) tr.get('RelationId'));
                        }
                        objNameVSsetId.put(((Id)tr.get('RelationId')).getSObjectType().getDescribe().getName(),getID);
                    }
                    if(!taskIdVSConname.containsKey((Id)tr.get('RelationId'))){//Resolve critical bug 00039861
                    Set<Id> taskidSet = new Set<Id>();
                    taskidSet.add(TaskRelationAccessRecList.getRemovedFields().get('TaskRelation') == null ?(Id)tr.get('taskId') :!TaskRelationAccessRecList.getRemovedFields().get('TaskRelation').contains('taskId')?(Id)tr.get('taskId') :'');
                     taskIdVSConname.put(((Id)tr.get('RelationId')),taskidSet);
                }
                else{
                    Set<Id> getTaskId = taskIdVSConname.get((Id)tr.get('RelationId'));
                    getTaskId.add(TaskRelationAccessRecList.getRemovedFields().get('TaskRelation') == null ?(Id)tr.get('taskId') :!TaskRelationAccessRecList.getRemovedFields().get('TaskRelation').contains('taskId')?(Id)tr.get('taskId') :'');
                     taskIdVSConname.put(((Id)tr.get('RelationId')),getTaskId);
                }
                    
                   // taskIdVSConname.put(((Id)tr.get('RelationId')),TaskRelationAccessRecList.getRemovedFields().get('TaskRelation') == null ?(Id)tr.get('taskId') :!TaskRelationAccessRecList.getRemovedFields().get('TaskRelation').contains('taskId')?(Id)tr.get('taskId') :'');
                }
            }
            if(TaskRelationAccessRecList.getRemovedFields().get('TaskRelation') == null ?true :!TaskRelationAccessRecList.getRemovedFields().get('TaskRelation').contains('navpeII_dev18__Related_Associations__c')){
                if(String.isNotBlank(String.valueOf(tr.getSobject('Task').get('navpeII_dev18__Related_Associations__c'))))
                    for(String s:(String.valueOf(tr.getSobject('Task').get('navpeII_dev18__Related_Associations__c'))).split(',')){
                        if(s.startsWith('001'))
                            refComAccSet.add(s);
                        else if(String.valueOf(Id.valueOf(s).getSObjectType())=='navpeII_dev18__Pipeline__c')
                            refDealIdSet.add(s);
                    }
            } 
        }
        }
        if(securityDecision.getRemovedFields().get('Contact') == null ?true :!securityDecision.getRemovedFields().get('Contact').contains('AccountId')){
            SYstem.debug('inside 280');
            if(refComAccSet.contains(cont.AccountId)){
                refComAccSet.remove(cont.AccountId);
            }
        }
        if(refPplConSet.contains(ctrl.getId()))//to be fixed : should be ref ppl //Bug ID 00035227
            refPplConSet.remove(ctrl.getId());//to be fixed : should be ref ppl //Bug ID 00035227
        for(String s: conIdList){
            refPplConSet.remove(s);
        }
        SObjectAccessDecision refComAccessAccountList = 
            Security.stripInaccessible(AccessType.READABLE,
                                       [select id,Name,navpeII_dev18__Introduced_by__c,Owner.Name,navpeII_dev18__Last_Touchpoint__c from Account where Id IN: refComAccSet LIMIT :(Limits.getLimitQueryRows() - Limits.getQueryRows())]);
        refComList =(List<Account>) refComAccessAccountList.getRecords();
        taggedFirmWrapLst = new List<TaggedFirmWrapper>();
        for(Account acct : refComList){
            TaggedFirmWrapper tggedFirm = new TaggedFirmWrapper();
            tggedFirm.Name = acct.Name;
            tggedFirm.User = '';
            tggedFirm.Participants = '';
            tggedFirm.LastTouchpoint = refComAccessAccountList.getRemovedFields().get('Account')==null ? (acct.navpeII_dev18__Last_Touchpoint__c != null ? String.ValueOf(acct.navpeII_dev18__Last_Touchpoint__c.month()+'/' + acct.navpeII_dev18__Last_Touchpoint__c.day() + '/'+acct.navpeII_dev18__Last_Touchpoint__c.year()) : '') :refComAccessAccountList.getRemovedFields().get('Account').contains('navpeII_dev18__Last_Touchpoint__c') ?'':(acct.navpeII_dev18__Last_Touchpoint__c != null ? String.ValueOf(acct.navpeII_dev18__Last_Touchpoint__c.month()+'/' + acct.navpeII_dev18__Last_Touchpoint__c.day() + '/'+acct.navpeII_dev18__Last_Touchpoint__c.year()) : '');
                taggedFirmWrapLst.add(tggedFirm);
            
        }
        //here
        // refComList = [select id,Name,navpeII_dev18__Introduced_by__c,Owner.Name,Last_Touchpoint__c from Account where Id IN: refComAccSet];
        
        
        if(Schema.sObjectType.navpeII_dev18__Pipeline__c.isAccessible()){
            SObjectAccessDecision refComAccessPipeList = 
                Security.stripInaccessible(AccessType.READABLE,
                                           [Select Id, Name,navpeII_dev18__Source_Contact__c from navpeII_dev18__Pipeline__c where Id IN: refDealIdSet LIMIT :(Limits.getLimitQueryRows() - Limits.getQueryRows())]);
            refDealsList=(List<navpeII_dev18__Pipeline__c>) refComAccessPipeList.getRecords();
            //refDealsList=[Select Id, Name, Owner.Name,navpeII_dev18__Source_Contact__c from navpeII_dev18__Pipeline__c where Id IN: refDealIdSet];
        }
        if(Schema.sObjectType.navpeII_dev18__Deal_Team__c.isAccessible() && Schema.sObjectType.navpeII_dev18__Pipeline__c.isAccessible()){
            SObjectAccessDecision accessDealTeamList = 
                Security.stripInaccessible(AccessType.READABLE,
                                           [SELECT Id, navpeII_dev18__Deal__r.Name,navpeII_dev18__Team_Member__c,navpeII_dev18__Deal__c, navpeII_dev18__Team_Member__r.name FROM navpeII_dev18__Deal_Team__c where navpeII_dev18__Deal__c In:refDealsList LIMIT :(Limits.getLimitQueryRows() - Limits.getQueryRows())]);
            dealTeamLst =(List<navpeII_dev18__Deal_Team__c>) accessDealTeamList.getRecords();
            
            //dealTeamLst =[SELECT Id, navpeII_dev18__Deal__r.Name, navpeII_dev18__Team_Member__r.name FROM navpeII_dev18__Deal_Team__c where navpeII_dev18__Deal__c In:refDealsList];
            Map<ID,String> dealIdVSName = new Map<ID,String>();
            for(navpeII_dev18__Deal_Team__c delTm : dealTeamLst){
                if(accessDealTeamList.getRemovedFields().get('navpeII_dev18__Deal_Team__c') == null ?true :!accessDealTeamList.getRemovedFields().get('navpeII_dev18__Deal_Team__c').contains('navpeII_dev18__Team_Member__c')){
                    if(delTm.navpeII_dev18__Team_Member__c != null){
                        if(accessDealTeamList.getRemovedFields().get('navpeII_dev18__Deal_Team__c') == null ?true:!accessDealTeamList.getRemovedFields().get('navpeII_dev18__Deal_Team__c').contains('navpeII_dev18__Deal__c')){
                            if(!dealIdVSName.containsKey(delTm.navpeII_dev18__Deal__c)){
                                dealIdVSName.put(delTm.navpeII_dev18__Deal__c , delTm.navpeII_dev18__Team_Member__r.Name);
                            }
                            else{
                                dealIdVSName.put(delTm.navpeII_dev18__Deal__c , dealIdVSName.get(delTm.navpeII_dev18__Deal__c)+ ','+ delTm.navpeII_dev18__Team_Member__r.Name);
                            }
                        }
                    }
                }
            }
            
            dealWrapLst = new List<DealWrapper>();
            for(navpeII_dev18__Pipeline__c deal : refDealsList){
                DealWrapper wrap = new DealWrapper();
                //securityDecision.getRemovedFields().get('Contact').contains('MailingStreet')?' ':(cont.MailingStreet != null ? cont.MailingStreet + ', ' : '')
                // wrap.dealName = refComAccessPipeList.getRemovedFields().get('navpeII_dev18__Pipeline__c') == null ?(deal.Name) :refComAccessPipeList.getRemovedFields().get('navpeII_dev18__Pipeline__c').contains('Name')? ' ' :(deal.Name);
                wrap.dealName = deal.Name;
                wrap.dealTeam = dealIdVSName.ContainsKey(deal.Id) ? dealIdVSName.get(deal.id) : '';
                dealWrapLst.add(wrap);
                
            }
        }
        //here
        taskAccessList = Security.stripInaccessible(AccessType.READABLE,[Select Id, Subject, Description, WhatId, Owner.Name, ActivityDate, navpeII_dev18__Related_Associations__c from Task where WhatId=: ctrl.getId() OR Id IN: interactionActIdSet LIMIT :(Limits.getLimitQueryRows() - Limits.getQueryRows())]);
        taskNotAccessField = taskAccessList.getRemovedFields();
        taskList= (List<Task>) taskAccessList.getRecords();
        //taskList=[Select Id, Subject, Description, WhatId, Owner.Name, ActivityDate, Related_Associations__c from Task where WhatId=: ctrl.getId() OR Id IN: interactionActIdSet];
        
        SObjectAccessDecision eventAccessList = 
            Security.stripInaccessible(AccessType.READABLE,
                                       [Select Id, Subject, Description, WhatId, Owner.Name, ActivityDate, navpeII_dev18__Related_Associations__c from Event where WhatId=: ctrl.getId() OR Id IN: interactionActIdSet LIMIT :(Limits.getLimitQueryRows() - Limits.getQueryRows())]);
        eventNotAccessField=eventAccessList.getRemovedFields();
        eventList=(List<Event>) eventAccessList.getRecords();
        //eventList=[Select Id, Subject, Description, WhatId, Owner.Name, ActivityDate, Related_Associations__c from Event where WhatId=: ctrl.getId() OR Id IN: interactionActIdSet];
        Map<String,Integer> actIdVsActCount=new Map<String,Integer>();            
        for(InfoWrapper infoWrap:handlePeopleRefInfo(conIdList,actIdList)){
            actIdVsActCount.put(infoWrap.nameRef.removeStart('/'),infoWrap.count);
        }
        
        Set<ID> taskRelatedAccId = new Set<ID>();
        Set<ID> eventRelatedAccId = new Set<ID>();
        
        if(!taskList.isEmpty()){
            for(Task getTask :taskList){
                if(taskAccessList.getRemovedFields().get('Task') == null ?true :!taskAccessList.getRemovedFields().get('Task').contains('navpeII_dev18__Related_Associations__c')){
                    if( String.isnotBlank(getTask.navpeII_dev18__Related_Associations__c)){
                        if(getTask.navpeII_dev18__Related_Associations__c.contains(',')){
                            for(String str : getTask.navpeII_dev18__Related_Associations__c.split(',')){
                                ID myRecordId = str;
                                if(!objNameVSsetId.containsKey(myRecordId.getSObjectType().getDescribe().getName())){
                                    Set<ID> objID = new Set<ID>();
                                    objID.add(myRecordId);
                                    objNameVSsetId.put(myRecordId.getSObjectType().getDescribe().getName(),objID);
                                }
                                else{
                                    Set<ID> getID = objNameVSsetId.get(myRecordId.getSObjectType().getDescribe().getName());
                                    getID.add(myRecordId);
                                    objNameVSsetId.put(myRecordId.getSObjectType().getDescribe().getName(),getID);
                                }
                                //TO be comment
                                if(str.startsWith('003') ){
                                    taskRelatedAccId.add(str);
                                }
                            } 
                        }
                        else{
                            ID recID = getTask.navpeII_dev18__Related_Associations__c;
                            if(!objNameVSsetId.containsKey(recID.getSObjectType().getDescribe().getName())){
                                Set<ID> objID = new Set<ID>();
                                objID.add(recID);
                                objNameVSsetId.put(recID.getSObjectType().getDescribe().getName(),objID);
                            }
                            else{
                                Set<ID> getID = objNameVSsetId.get(recID.getSObjectType().getDescribe().getName());
                                getID.add(recID);
                                objNameVSsetId.put(recID.getSObjectType().getDescribe().getName(),getID);
                            }
                            //TO be comment
                            taskRelatedAccId.add(getTask.navpeII_dev18__Related_Associations__c);
                        }
                        
                    } 
                }
            }
        }
        
        
        if(!eventList.isEmpty()){
            for(Event getEvent :eventList){
                if(eventAccessList.getRemovedFields().get('Event') == null ?true :!eventAccessList.getRemovedFields().get('Event').contains('navpeII_dev18__Related_Associations__c')){
                    if(String.isnotBlank(getEvent.navpeII_dev18__Related_Associations__c)){
                        if(getEvent.navpeII_dev18__Related_Associations__c.contains(',')){
                            for(String str : getEvent.navpeII_dev18__Related_Associations__c.split(',')){
                                ID myRecordId = str;
                                if(!objNameVSsetId.containsKey(myRecordId.getSObjectType().getDescribe().getName())){
                                    Set<ID> objID = new Set<ID>();
                                    objID.add(myRecordId);
                                    objNameVSsetId.put(myRecordId.getSObjectType().getDescribe().getName(),objID);
                                }
                                else{
                                    Set<ID> getID = objNameVSsetId.get(myRecordId.getSObjectType().getDescribe().getName());
                                    getID.add(myRecordId);
                                    objNameVSsetId.put(myRecordId.getSObjectType().getDescribe().getName(),getID);
                                }
                                if(str.startsWith('003')){
                                    eventRelatedAccId.add(str);
                                }
                            } 
                        }
                        else{
                            ID recID = getEvent.navpeII_dev18__Related_Associations__c;
                            if(!objNameVSsetId.containsKey(recID.getSObjectType().getDescribe().getName())){
                                Set<ID> objID = new Set<ID>();
                                objID.add(recID);
                                objNameVSsetId.put(recID.getSObjectType().getDescribe().getName(),objID);
                            }
                            else{
                                Set<ID> getID = objNameVSsetId.get(recID.getSObjectType().getDescribe().getName());
                                getID.add(recID);
                                objNameVSsetId.put(recID.getSObjectType().getDescribe().getName(),getID);
                            }
                            eventRelatedAccId.add(getEvent.navpeII_dev18__Related_Associations__c);
                        }                        
                    } 
                }
            }
        }
        
        interactionList = getTaskInteractionWrapper(taskRelatedAccId,taskList,objNameVSsetId);
        
        interactionList.addAll(getEventInteractionWrapper(eventRelatedAccId,eventList,objNameVSsetId));
        ResponseWrapper respWrap =  handleOnLoadInfo(ctrl.getId(),'Contact');
        ResponseWrapper processWrap = respWrap!= null ? processConInfo(respWrap.conMap, ctrl.getId(), 'Acuity_Connection_IntTab_Field1', 'Acuity_Connection_IntTab_Field2', respWrap.namespacePrefix, respWrap.contactEmail, respWrap.actIdList,String.isBlank(ctrl.getId()), 'Contact', 'PageLoad', respWrap.parentConIdList) : null;
        if(processWrap != null){
            if(processWrap.conInfoWrapper.size()>0){
                List<Internal> internalLst = new List<Internal>();
                for(ConWrapper wrap:processWrap.conInfoWrapper){
                    Internal interalConnection = new Internal();
                    interalConnection.name = wrap.name;
                    interalConnection.title = wrap.fieldInfo;
                    interalConnection.dealCount = wrap.dealCount;
                    internalLst.add(interalConnection);
                }
                conInfoWrapper1 = internalLst;
            }
        } 
        ResponseWrapper externalwrap = respWrap!= null ? handleExternalConnInfo(ctrl.getId(),'Contact',  respWrap.namespacePrefix,respWrap.contactEmail,respWrap.actIdList) : null;
        if(externalwrap != null){
            if(externalwrap.conInfoWrapper.size()>0){
                List<External> externalLst = new List<External>();
                for(ConWrapper wrap:externalwrap.conInfoWrapper){
                    External interalConnection = new External();
                    interalConnection.name = wrap.name;
                    interalConnection.title = wrap.fieldInfo;
                    interalConnection.dealCount = wrap.dealCount;
                    externalLst.add(interalConnection);
                }
                conInfoWrapperExternal = externalLst;
            }
        }
        List<InfoWrapper> ls = handlePeopleRefInfo1(respWrap.conIdList,respWrap.actIdList);
        for(InfoWrapper ins : ls){
            peoplConIDSet.add(ins.nameRef);
        }
        SObjectAccessDecision refComAccessContactList = 
            Security.stripInaccessible(AccessType.READABLE,
                                       [Select Id, Name, Title, AccountId, Account.Name,navpeII_dev18__Last_Touch_Point__c, Owner.Name,navpeII_dev18__Last_Touchpoint_ID__c from Contact where Id IN: peoplConIDSet LIMIT :(Limits.getLimitQueryRows() - Limits.getQueryRows())]);
        refPplList=(List<Contact>) refComAccessContactList.getRecords();
        //refPplList=[Select Id, Name, Title, AccountId, Account.Name,navpeII_dev18__Last_Touch_Point__c, Owner.Name from Contact where Id IN: peoplConIDSet];        
        refPplWrapList=new List<ReferencedPeopleWrapper>();
        Set<Id> taskLst = new Set<Id>();
        set<Id> eventLst = new  Set<Id>();
        for(Contact con :refPplList){
            if(refComAccessContactList.getRemovedFields().get('Contact')==null? true :!refComAccessContactList.getRemovedFields().get('Contact').contains('navpeII_dev18__Last_Touchpoint_ID__c')){
                if(con.navpeII_dev18__Last_Touchpoint_ID__c != null ){
                    conVSMentnBy.put(con.Id, con.navpeII_dev18__Last_Touchpoint_ID__c);
                    if(con.navpeII_dev18__Last_Touchpoint_ID__c.startswith('00T')){
                        taskLst.add(con.navpeII_dev18__Last_Touchpoint_ID__c);
                    }
                    else if(con.navpeII_dev18__Last_Touchpoint_ID__c.startswith('00U')){ 
                        eventLst.add(con.navpeII_dev18__Last_Touchpoint_ID__c);
                    }  
                }           
            }
        }
        List<Task> intrTskLst = [Select Id,Owner.Name from Task where Id IN : taskLst LIMIT :(Limits.getLimitQueryRows() - Limits.getQueryRows())];
        Map<Id,String> tskIdVsOwName = new Map<ID,String>();
        for(Task tsk:intrTskLst){
            tskIdVsOwName.put(tsk.Id, tsk.Owner.Name);
        }
        List<Event> evtTskLst = [Select Id,Owner.Name from Event where Id IN : eventLst];
        Map<Id,String> evtIdVsOwName = new Map<ID,String>();
        for(event evt:evtTskLst){
            evtIdVsOwName.put(evt.Id, evt.Owner.Name);
        }
        
        for(Contact con:refPplList){
            ReferencedPeopleWrapper refPplWrap=new ReferencedPeopleWrapper();
            refPplWrap.Name=con.Name;//refComAccessContactList.getRemovedFields().get('Contact') == null ?(con.Name) :refComAccessContactList.getRemovedFields().get('Contact').contains('Name') ? '' :con.Name;
            refPplWrap.Title=refComAccessContactList.getRemovedFields().get('Contact') == null ?con.Title :refComAccessContactList.getRemovedFields().get('Contact').contains('Title') ? '' : con.Title;
            refPplWrap.AccountId=refComAccessContactList.getRemovedFields().get('Contact') == null ?(con.Account.Name) :refComAccessContactList.getRemovedFields().get('Contact').contains('AccountId') ? '' :con.Account.Name;
            refPplWrap.actCount=actIdVsActCount.get(String.valueOf(con.Id));
            refPplWrap.Last_Touch_Point=refComAccessContactList.getRemovedFields().get('Contact') == null ?(con.navpeII_dev18__Last_Touch_Point__c!=null?con.navpeII_dev18__Last_Touch_Point__c.format():'') :refComAccessContactList.getRemovedFields().get('Contact').contains('navpeII_dev18__Last_Touch_Point__c') ? ' ' :(con.navpeII_dev18__Last_Touch_Point__c!=null?con.navpeII_dev18__Last_Touch_Point__c.format():'');
                refPplWrap.OwnerId= refComAccessContactList.getRemovedFields().get('Contact') == null ?(con.Last_Touchpoint_ID__c != null ? (con.Last_Touchpoint_ID__c.StartsWith('00T') ? tskIdVsOwName.get(con.navpeII_dev18__Last_Touchpoint_ID__c) : evtIdVsOwName.get(con.navpeII_dev18__Last_Touchpoint_ID__c)) : ''): refComAccessContactList.getRemovedFields().get('Contact').contains('navpeII_dev18__Last_Touchpoint_ID__c') ? ' ' :(con.navpeII_dev18__Last_Touchpoint_ID__c != null ? (con.navpeII_dev18__Last_Touchpoint_ID__c.StartsWith('00T') ? tskIdVsOwName.get(con.navpeII_dev18__Last_Touchpoint_ID__c) : evtIdVsOwName.get(con.navpeII_dev18__Last_Touchpoint_ID__c)) : '');
                    refPplWrapList.add(refPplWrap);
        }
    }
    
    
    /*
* Purpose : Fetches namespace prefix
* Returns : Namespaceprefix to be used as a String
*/
    public static String getNamespacePrefix(){
        try{
            return [SELECT NamespacePrefix FROM ApexClass WHERE Name = 'FileUploaderCtrl' ].NamespacePrefix;
        } catch (Exception e) {
            throw new AuraHandledException('Error Occured While Loading Component : <<' + e.getStackTraceString() + '>>');
        }
    }
    
    /*
* Purpose : Finds activity records to be processed
* Input : conIdList    [List of contacts of the Account to be processed; For Account : CR only]
*         objName      [Activity type (Task/Event)]
*         whereClause  [Where clause to be used in the SOQL query]
* Returns : List<String> containing activity IDs to be processed
*/
    public static List<String> fetchRecsToProcess(List<String> conIdList, String objName, String whereClause){
        try {
            List<String> actIdList = new List<String>();
            Integer remainingRows = Limits.getLimitQueryRows() - Limits.getQueryRows();
            String objRelation = objName+'Relation';
            if(Schema.getGlobalDescribe().get(objRelation) != null){
                for(sObject actRec : Database.query('SELECT ' + objName + 'Id FROM ' + objName + 'Relation' + whereClause+ ' Limit '+remainingRows)){
                    actIdList.add(String.valueOf(actRec.get(objName + 'Id')));
                }
            }
            return actIdList;
        } catch (Exception e) {
            throw new AuraHandledException('Error Occured While Loading Component : <<' + e.getStackTraceString() + '>>');
        }
    }
    
    /*
* Purpose : Finds activity records to be processed
* Input : recordId     [Contact record to be processed; For Contact : CR only]
*         objName      [Activity type (Task/Event)]
*         whereClause  [Where clause to be used in the SOQL query]
* Returns : List<String> containing activity IDs to be processed
*/
    public static List<String> fetchRecsToProcess(String recordId, String objName, String whereClause){
        try {
            List<String> actIdList = new List<String>();
            Integer remainingRows = Limits.getLimitQueryRows() - Limits.getQueryRows();
            String objRelation = objName+'Relation';
            if(Schema.getGlobalDescribe().get(objRelation) != null){
                for(sObject actRec : Database.query('SELECT ' + objName + 'Id FROM ' + objName + 'Relation' + whereClause+ ' Limit '+remainingRows)){
                    actIdList.add(String.valueOf(actRec.get(objName + 'Id')));
                }
            }
            return actIdList;
        } catch (Exception e) {
            throw new AuraHandledException('Error Occured While Loading Component : <<' + e.getStackTraceString() + '>>');
        }
    }
    
    /*
* Purpose : Handles the People Referenced information on Account object
* Input : recordId     [Record ID of the current record (Account)]
*         conIdList    [List of contacts of the Account to be processed]
*         actIdList    [Activity IDs to be processed]
* Returns : List<InfoWrapper> containing info about each record to be displayed under PR data table
*/
    @AuraEnabled
    public static List<InfoWrapper> handlePeopleRefInfo(List<String> conIdList, List<String> actIdList){
        try {
            String refField = Acuity_Setting__mdt.getInstance('Acuity_Tagged_People_Field').Value__c;
            if(String.isBlank(refField)){
                return null;
            } else {
                //Removed previous if else & used same logic of Account on 2022-11-01 to implement Ketan's new CR to not display Contacts associated to same Account in People's tab
                processPRActInfo('Event', conIdList, actIdList, ' WHERE EventId IN :actIdList AND RelationId NOT IN :conIdList');
                processPRActInfo('Task', conIdList, actIdList, ' WHERE TaskId IN :actIdList AND RelationId NOT IN :conIdList');
                return prepareFinalMap('Contact', refField);
            }
        } catch (Exception e) {
            System.debug('Exception e'+e.getLineNumber());
            throw new AuraHandledException('Error Occured While Loading Component : <<' + e.getStackTraceString() + '>>');
        }
    }
    
    @AuraEnabled
    public static List<InfoWrapper> handlePeopleRefInfo1(List<String> conIdList, List<String> actIdList){
        try {
            String refField = Acuity_Setting__mdt.getInstance('Acuity_Tagged_People_Field').Value__c;
            if(String.isBlank(refField)){
                return null;
            } else {
                //Removed previous if else & used same logic of Account on 2022-11-01 to implement Ketan's new CR to not display Contacts associated to same Account in People's tab
                processPRActInfo1('Event', conIdList, actIdList, ' WHERE EventId IN :actIdList AND RelationId NOT IN :conIdList');
                processPRActInfo1('Task', conIdList, actIdList, ' WHERE TaskId IN :actIdList AND RelationId NOT IN :conIdList');
                return prepareFinalMap1('Contact', refField);
            }
        } catch (Exception e) {
            System.debug('Exception e'+e.getLineNumber());
            throw new AuraHandledException('Error Occured While Loading Component : <<' + e.getStackTraceString() + '>>');
        }
    }
    
    /*
* Purpose : Processes the activity relation records
* Input : objName      [Activity type (Task/Event)]
*         conIdList    [List of contacts of the Account to be processed (For Account Record Page only; null for Contact Record Page)]
*         actIdList    [List of activities to be processed]
*         whereClause  [Where clause to be used in the SOQL query]
* Returns : N/A
*/
    public static void processPRActInfo(String objName, List<String> conIdList, List<String> actIdList, String whereClause){
        try {
            String objRelation = objName+'Relation';
            Integer remainingRows = Limits.getLimitQueryRows() - Limits.getQueryRows();
            if(Schema.getGlobalDescribe().get(objRelation) != null){
                for(sObject actRec : Database.query('SELECT RelationId, ' + objName + 'Id FROM ' + objName + 'Relation' + whereClause +' Limit '+remainingRows)){
                    processRelObjIds(String.valueOf(actRec.get('RelationId')), String.valueOf(actRec.get(objName + 'Id')));
                }
            }
        } catch (Exception e) {
            System.debug('Exception e231  '+e.getLineNumber());
            throw new AuraHandledException('Error Occured While Loading Component : <<' + e.getStackTraceString() + '>>');
        }
    }
    public static void processPRActInfo1(String objName, List<String> conIdList, List<String> actIdList, String whereClause){
        try {
            String objRelation = objName+'Relation';
            Integer remainingRows = Limits.getLimitQueryRows() - Limits.getQueryRows();
            if(Schema.getGlobalDescribe().get(objRelation) != null){
                for(sObject actRec : Database.query('SELECT RelationId, ' + objName + 'Id FROM ' + objName + 'Relation' + whereClause + ' Limit '+remainingRows)){
                    processRelObjIds1(String.valueOf(actRec.get('RelationId')), String.valueOf(actRec.get(objName + 'Id')));
                }
            }
        } catch (Exception e) {
            System.debug('Exception e231  '+e.getLineNumber());
            throw new AuraHandledException('Error Occured While Loading Component : <<' + e.getStackTraceString() + '>>');
        }
    }
    /*
* Purpose : Maps related object along side activity IDs set
* Input : ids      [Related Object IDs to be processed]
*         actId    [Activity ID to be mapped]
* Returns : N/A
*/
    public static void processRelObjIds(String ids, ID actId){
        try {
            for(String recId : ids.split(',')){
                Set<String> idSet = new Set<String>();
                if(objIdVsActIdsMap.containsKey(recId)){
                    idSet = objIdVsActIdsMap.get(recId);
                } else {
                    idSet = new Set<String>();
                }
                idSet.add(actId);
                objIdVsActIdsMap.put(recId, idSet);
            }
        } catch (Exception e) {
            System.debug('668 +'+ e.getCause() + e.getLineNumber());
            throw new AuraHandledException('Error Occured While Loading Component : <<' + e.getStackTraceString() + '>>');
        }
    }
    
    public static void processRelObjIds1(String ids, ID actId){
        try {
            for(String recId : ids.split(',')){
                Set<String> idSet = new Set<String>();
                if(objIdVsActIdsMap1.containsKey(recId)){
                    idSet = objIdVsActIdsMap1.get(recId);
                } else {
                    idSet = new Set<String>();
                }
                idSet.add(actId);
                objIdVsActIdsMap1.put(recId, idSet);
            }
        } catch (Exception e) {
            System.debug('686'+e.getLineNumber());
            throw new AuraHandledException('Error Occured While Loading Component : <<' + e.getStackTraceString() + '>>');
        }
    }
    
    /*
* Purpose : Finds activity records to be processed
* Input : actIdSet    [Set of Account Id]
*         tskList      [List of Task]
* Returns : List<TaskInteractionWrapper> list of interactionWrapper
*/
    /*  public List<TaskInteractionWrapper> getTaskInteractionWrapper(Set<ID> accIdSet , List<Task> tskList){
Map<ID,String> accNamemap = new Map<ID,String>();
System.debug('line 164'+164);
List<Contact> accList = [Select Id, Name from Contact where Id IN: accIdSet];
System.debug('accList'+accList);
for(Contact acc : accList){
accNamemap.put(acc.Id, acc.Name);
}
List<TaskInteractionWrapper> intrWrapperLst = new List<TaskInteractionWrapper>();
for(Task getTask :tskList){
TaskInteractionWrapper intwrap = new TaskInteractionWrapper();
intwrap.Subject = getTask.Subject;
intwrap.Description = getTask.Description;
intwrap.OwnerName = getTask.Owner.Name;
intwrap.ActivityDate = String.Valueof(getTask.ActivityDate);
List<String> accNameList = new List<String>();
if(String.isnotBlank(getTask.Related_Associations__c)){
if(getTask.Related_Associations__c.contains(',')){
for(String str : getTask.Related_Associations__c.split(',')){
if(str.startsWith('003') && accNamemap.containskey(str)){
accNameList.add(accNamemap.get(str));

}  
}
}
else{
if(getTask.Related_Associations__c.startsWith('003') && accNamemap.containskey(getTask.Related_Associations__c)){
accNameList.add(accNamemap.get(getTask.Related_Associations__c));

} 
}
}
intwrap.ReferencesName = accNameList.size() > 0 ? String.valueof(accNameList).replace('(','').replace(')','') : '';
intrWrapperLst.add(intwrap);
}
return intrWrapperLst;
} */
    /////////////////////////////////////
    public List<TaskInteractionWrapper> getTaskInteractionWrapper(Set<ID> accIdSet , List<Task> tskList,Map<String, Set<ID>> objVSid){
        Map<ID,String> accNamemap = new Map<ID,String>();//COntact ID vs COntact Nmae
        Map<ID,List<String>> taskIDVsConnameMp = new Map<ID,List<String>>();//tASK ID VS COTACT NAME 
        List<contact> currentConList = [Select Id, name  from contact where  id  =: getCtrl]; //Resolve critical bug 00039861
        for(String objName : objVSid.keySet()){
             if(Schema.getGlobalDescribe().get(objName).getDescribe().isAccessible()){// resolve critical bug 00039972
            Integer remainingRows = Limits.getLimitQueryRows() - Limits.getQueryRows();
            Set<ID> getIdSet = objVSid.get(objName);
            for(sObject objRec : Database.query('SELECT Id, Name'  + ' FROM ' + String.escapeSingleQuotes(objName) + ' WHERE Id IN :getIdSet'+' Limit '+remainingRows)){
                accNamemap.put(String.Valueof(objRec.get('Id')),String.Valueof(objRec.get('Name')));
            }
        }
        }
        for( String getEvent1 :taskIdVSConname.keySet()){
            for(String TaskId : taskIdVSConname.get(getEvent1)){ //Resolve critical bug 00039861
                if(!taskIDVsConnameMp.containsKey(TaskId)){
                    List<String> setConName = new List<String>();
                if(accNamemap.containskey(getEvent1)){
                    setConName.add(accNamemap.get(getEvent1));               
                }   
                String conname = currentConList[0].name;
                setConName.add(conname);
                taskIDVsConnameMp.put(TaskId,setConName);//Task ID Vs LISt CNmame
            }
            else{
                List<String> getConName = taskIDVsConnameMp.get(TaskId);
                if(accNamemap.containskey(getEvent1)){
                    getConName.add(accNamemap.get(getEvent1));               
                }
                taskIDVsConnameMp.put(TaskId,getConName);
            }
            }
        }
        List<TaskInteractionWrapper> intrWrapperLst = new List<TaskInteractionWrapper>();
        for(Task getTask :tskList){
            TaskInteractionWrapper intwrap = new TaskInteractionWrapper();
            intwrap.Subject =getTask.Subject;  //taskNotAccessField.get('Task') == null ?getTask.Subject :taskNotAccessField.get('Task').contains('Subject') ? ' ' : getTask.Subject;
            intwrap.Description = taskNotAccessField.get('Task') == null ?getTask.Description :taskNotAccessField.get('Task').contains('Description') ? ' ' :getTask.Description;
            intwrap.OwnerName = taskNotAccessField.get('Task') == null ?getTask.Owner.Name :taskNotAccessField.get('Task').contains('Owner.Name') ? ' ' :getTask.Owner.Name;
            //getEvent.ActivityDate != null? String.valueOf(getEvent.ActivityDate.month()+'/'+getEvent.ActivityDate.day()+'/'+getEvent.ActivityDate.year()): '';
            intwrap.ActivityDate = taskNotAccessField.get('Task') == null ?(getTask.ActivityDate != null? String.valueOf(getTask.ActivityDate.month()+'/'+getTask.ActivityDate.day()+'/'+getTask.ActivityDate.year()): '') :taskNotAccessField.get('Task').contains('ActivityDate')?'':(getTask.ActivityDate != null? String.valueOf(getTask.ActivityDate.month()+'/'+getTask.ActivityDate.day()+'/'+getTask.ActivityDate.year()): '');
                List<String> accNameList = new List<String>();
            if(taskNotAccessField.get('Task') == null ?true :!taskNotAccessField.get('Task').contains('navpeII_dev18__Related_Associations__c')){
                if(String.isnotBlank(getTask.navpeII_dev18__Related_Associations__c)){
                    if(getTask.navpeII_dev18__Related_Associations__c.contains(',')){
                        for(String str : getTask.navpeII_dev18__Related_Associations__c.split(',')){
                            if( accNamemap.containskey(str)){
                                accNameList.add(accNamemap.get(str));
                                
                            }  
                        }
                    }
                    else{
                        if(accNamemap.containskey(getTask.navpeII_dev18__Related_Associations__c)){
                            accNameList.add(accNamemap.get(getTask.navpeII_dev18__Related_Associations__c));
                            
                        } 
                    }
                }
            }
            intwrap.ReferencesName =  taskIDVsConnameMp.containsKey(getTask.Id)?String.valueof( String.join(accNameList, ', ')) + String.valueof (taskIDVsConnameMp.size()>0 ? ', '+String.join(taskIDVsConnameMp.get(getTask.Id), ', ') :'' ) : String.join(accNameList, ', ');
            intrWrapperLst.add(intwrap);
        }
        return intrWrapperLst;
    }
    
    /*
* Purpose : Prepares final map of the data to be displayed under Referenced Section
* Input : objName  [Relation object to be queries (Account/Contact/Deal)]
*         refField [Referenced field to be used for displaying name kind of data]
* Returns : List<InfoWrapper> containing info about each record to be displayed in data tables under Referenced Section
*/
    public static List<InfoWrapper> prepareFinalMap(String objName, String refField){
        try {
            List<InfoWrapper> infoWrapperList = new List<InfoWrapper>();
            List<String> objIdList = new List<String>();
            objIdList.addAll(objIdVsActIdsMap.keySet());
            Integer remainingRows = Limits.getLimitQueryRows() - Limits.getQueryRows();
            for(sObject objRec : Database.query('SELECT Id, ' + refField + ' FROM ' + String.escapeSingleQuotes(objName) + ' WHERE Id IN :objIdList' + ' Limit '+remainingRows)){
                String recId = String.valueOf(objRec.get('Id'));
                List<String> actIdList = new List<String>();
                actIdList.addAll(objIdVsActIdsMap.get(recId));
                infoWrapperList.add(new InfoWrapper(String.valueOf(objRec.get(refField)), '/' + recId, objIdVsActIdsMap.get(recId).size(), actIdList, accIdSet.contains(recId)));
            }
            return infoWrapperList;
        } catch (Exception e) {
            System.debug('813==='+e.getLineNumber());
            throw new AuraHandledException('Error Occured While Loading Component : <<' + e.getStackTraceString() + '>>');
        }        
    }
    
    public static List<InfoWrapper> prepareFinalMap1(String objName, String refField){
        try {
            List<InfoWrapper> infoWrapperList = new List<InfoWrapper>();
            List<String> objIdList = new List<String>();
            Integer remainingRows = Limits.getLimitQueryRows() - Limits.getQueryRows();
            objIdList.addAll(objIdVsActIdsMap1.keySet());
            for(sObject objRec : Database.query('SELECT Id, ' + refField + ' FROM ' + String.escapeSingleQuotes(objName) + ' WHERE Id IN :objIdList'+ ' Limit '+remainingRows)){
                String recId = String.valueOf(objRec.get('Id'));
                List<String> actIdList = new List<String>();
                actIdList.addAll(objIdVsActIdsMap1.get(recId));
                infoWrapperList.add(new InfoWrapper(String.valueOf(objRec.get(refField)),  recId, objIdVsActIdsMap1.get(recId).size(), actIdList, accIdSet.contains(recId)));
            }
            return infoWrapperList;
        } catch (Exception e) {
            System.debug('831==='+e.getLineNumber());
            throw new AuraHandledException('Error Occured While Loading Component : <<' + e.getStackTraceString() + '>>');
        }        
    }
    ///////////////////////////////////
    public static ResponseWrapper handleOnLoadInfo(String recordId, String objApiName){
        try {
            ResponseWrapper respWrapper = new ResponseWrapper();
            List<String> conIdList = new List<String>();
            respWrapper.conMap = fetchInitInfoToProcess('Acuity_Connection_IntTab_Field1', 'Acuity_Connection_IntTab_Field2', 'User', '', '', null);
            
            SObjectAccessDecision contactAccessRec =Security.stripInaccessible(AccessType.READABLE,
                                                                               [SELECT AccountId, Name, Email FROM Contact WHERE Id = :recordId ]);
            Contact con = (Contact) contactAccessRec.getRecords()[0];
            // Contact con = [SELECT AccountId, Name, Email FROM Contact WHERE Id = :recordId WITH SECURITY_ENFORCED] ;//Modifed by Anshika Ahuja W.R.To Bug #00034852
            //Added below 2 lines on 2022-11-01 to implement Ketan's new CR to not display Contacts associated to same Account in People's tab
            //contactAccessRec.getRemovedFields().get('Contact') == null ?con.AccountId :contactAccessRec.getRemovedFields().get('Contact').contains('AccountId')?null:con.AccountId
            SObjectAccessDecision conAccesRecords = Security.stripInaccessible(AccessType.READABLE,
                                                                               [SELECT Id FROM Contact WHERE AccountId = :contactAccessRec.getRemovedFields().get('Contact') == null ?con.AccountId :contactAccessRec.getRemovedFields().get('Contact').contains('AccountId')?null:con.AccountId]);   
            List<Contact> conList=(List<Contact>) conAccesRecords.getRecords();
            
            for(Contact conRec :conList){
                conIdList.add(conRec.Id);
            }
            respWrapper.conIdList = conIdList;
            respWrapper.recName = contactAccessRec.getRemovedFields().get('Contact') == null ?(con.Name) :contactAccessRec.getRemovedFields().get('Contact').contains('Name') ? ' ' :con.Name;
            //con.Name;
            respWrapper.accId = contactAccessRec.getRemovedFields().get('Contact') == null ?(con.AccountId) :contactAccessRec.getRemovedFields().get('Contact').contains('AccountId') ? null :con.AccountId;
            respWrapper.contactEmail = contactAccessRec.getRemovedFields().get('Contact') == null ?(con.Email) :contactAccessRec.getRemovedFields().get('Contact').contains('Email') ? ' ' :con.Email;
            respWrapper.namespacePrefix = getNamespacePrefix() + '__';
            respWrapper.compsRefInfo = handleCompsRef(recordId, objApiName, new List<String> (), respWrapper.accId, respWrapper.namespacePrefix);
            List<String> actIdList = new List<String>();
            List<String> completeActIdList = new List<String>();
            if(!actIdsSet.isEmpty()){
                actIdList.addAll(actIdsSet);
            }
            if(!completeActIdsSet.isEmpty()){
                completeActIdList.addAll(completeActIdsSet);
            }
            respWrapper.actIdList = actIdList;
            respWrapper.completeActIdList = completeActIdList;
            return respWrapper;
        }
        Catch(Exception e){
            System.debug('696===' + ' : <<' + e.getLineNumber() + '>>');
            throw new AuraHandledException('568' + ' : <<' + e.getStackTraceString() + '>>');
        }
    }
    
    /*
* Purpose : Handles the Companies Referenced information on Account & Contact objects
* Input : recordId         [Record ID of the current record (Account/Contact/Deal/Fund/Fundraising)]
*         objApiName       [API name of the current record (Account/Contact/Deal/Fund/Fundraising)]
*         conIdList        [List of contacts of the Account to be processed; For Account : CR only; Null for Contact : CR]
*         accId            [Account ID of the current contact; For Contact : CR only; Null for Account : CR]
*         namespacePrefix  [Namespaceprefix to be used]
* Returns : List<InfoWrapper> containing info about each record to be displayed under CR data table
*/
    private static List<InfoWrapper> handleCompsRef(String recordId, String objApiName, List<String> conIdList, String accId, String namespacePrefix){
        try {
            String refField = Acuity_Setting__mdt.getInstance('Acuity_Tagged_Firms_Field').Value__c;
            if(String.isBlank(refField)){
                return null;
            } else {
                List<String> actIdList = new List<String>();
                
                if(objApiName.equalsIgnoreCase('Account') || objApiName.equalsIgnoreCase(namespacePrefix + 'Fundraising__c')){
                    //For handling events
                    actIdList = fetchRecsToProcess(conIdList, 'Event', ' WHERE (Relation.Type = \'Contact\') AND ((RelationId IN :conIdList) OR (Event.navpeII_dev18__Related_Associations__c LIKE \'%' + String.escapeSingleQuotes(recordId) + '%\'))');
                    processCRActInfo('Event', actIdList, ' WHERE (EventId IN :actIdList)', conIdList, recordId, objApiName, namespacePrefix);
                    processCRActInfo('Event', '(navpeII_dev18__Related_Associations__c LIKE \'%' + recordId + '%\')');    //For covering the scenario : Empty Name & Accounts in AA field
                    //For handling tasks
                    actIdList = fetchRecsToProcess(conIdList, 'Task', ' WHERE (Task.TaskSubType != \'ListEmail\') AND (Relation.Type = \'Contact\') AND ((RelationId IN :conIdList) OR (Task.navpeII_dev18__Related_Associations__c LIKE \'%' + String.escapeSingleQuotes(recordId) + '%\'))');
                    processCRActInfo('Task', actIdList, ' WHERE (TaskId IN :actIdList)', conIdList, recordId, objApiName, namespacePrefix);
                    processCRActInfo('Task', '(navpeII_dev18__Related_Associations__c LIKE \'%' + recordId + '%\')');    //For covering the scenario : Empty Name & Accounts in AA field
                    objIdVsActIdsMap.remove(recordId);  //To remove current record id from Account
                } else if(objApiName.equalsIgnoreCase('Contact')){
                    //For handling events
                    actIdList = fetchRecsToProcess(recordId, 'Event', ' WHERE RelationId = :recordId');
                    processCRActInfo('Event', actIdList, ' WHERE (EventId IN :actIdList)', null, recordId, objApiName, namespacePrefix);
                    //For handling tasks
                    actIdList = fetchRecsToProcess(recordId, 'Task', ' WHERE (Task.TaskSubType != \'ListEmail\') AND (RelationId = :recordId)');
                    processCRActInfo('Task', actIdList, ' WHERE (TaskId IN :actIdList)', null, recordId, objApiName, namespacePrefix);
                    objIdVsActIdsMap.remove(accId);  //To remove current record id from Contact
                } else if(objApiName.equalsIgnoreCase(namespacePrefix + 'Pipeline__c')){
                    //For handling events
                    actIdList = fetchRecsToProcess('', 'Event', ' WHERE (Relation.Type = \'Contact\') AND (Event.navpeII_dev18__Related_Associations__c LIKE \'%' + String.escapeSingleQuotes(recordId) + '%\')');
                    processCRActInfo('Event', actIdList, ' WHERE (EventId IN :actIdList)', null, recordId, objApiName, namespacePrefix);
                    processCRActInfo('Event', '(navpeII_dev18__Related_Associations__c LIKE \'%' + String.escapeSingleQuotes(recordId) + '%\')');    //For covering the scenario : Empty Name & Accounts in AA field
                    //For handling tasks
                    actIdList = fetchRecsToProcess('', 'Task', ' WHERE (Task.TaskSubType != \'ListEmail\') AND (Relation.Type = \'Contact\') AND (Task.navpeII_dev18__Related_Associations__c LIKE \'%' + String.escapeSingleQuotes(recordId) + '%\')');
                    processCRActInfo('Task', actIdList, ' WHERE (TaskId IN :actIdList)', null, recordId, objApiName, namespacePrefix);
                    processCRActInfo('Task', '(navpeII_dev18__Related_Associations__c LIKE \'%' + String.escapeSingleQuotes(recordId) + '%\')');     //For covering the scenario : Empty Name & Accounts in AA field
                    if(objApiName.equalsIgnoreCase(namespacePrefix + 'Pipeline__c')){
                        objIdVsActIdsMap.remove(accId);     //To remove the Account associated to the current Deal record
                    }
                } else if(objApiName.equalsIgnoreCase(namespacePrefix + 'Fund__c')){
                    String fdrWhereClauseStrEvent = '(Event.navpeII_dev18__Related_Associations__c LIKE \'%' + String.escapeSingleQuotes(recordId) + '%\')';
                    String fdrWhereClauseStrTask = '(Task.navpeII_dev18__Related_Associations__c LIKE \'%' + String.escapeSingleQuotes(recordId) + '%\')';
                    for(String fdrRecId : conIdList){
                        fdrWhereClauseStrEvent += ' OR (Event.navpeII_dev18__Related_Associations__c LIKE \'%' + String.escapeSingleQuotes(fdrRecId) + '%\')';
                        fdrWhereClauseStrTask += ' OR (Task.navpeII_dev18__Related_Associations__c LIKE \'%' + String.escapeSingleQuotes(fdrRecId) + '%\')';
                    }
                    //For handling events
                    actIdList = fetchRecsToProcess('', 'Event', ' WHERE (Relation.Type = \'Contact\') AND (' + fdrWhereClauseStrEvent + ')');
                    processCRActInfo('Event', actIdList, ' WHERE (EventId IN :actIdList)', null, recordId, objApiName, namespacePrefix);
                    processCRActInfo('Event', '(' + fdrWhereClauseStrEvent + ')');    //For covering the scenario : Empty Name & Accounts in AA field
                    //For handling tasks
                    actIdList = fetchRecsToProcess(conIdList, 'Task', ' WHERE (Task.TaskSubType != \'ListEmail\') AND (Relation.Type = \'Contact\') AND (' + fdrWhereClauseStrTask + ')');
                    processCRActInfo('Task', actIdList, ' WHERE (TaskId IN :actIdList)', null, recordId, objApiName, namespacePrefix);
                    processCRActInfo('Task', '(' + fdrWhereClauseStrTask + ')');    //For covering the scenario : Empty Name & Accounts in AA field
                }
                String TOKEN_SOBJECT_NAME = namespacePrefix + 
                    (namespacePrefix.equalsIgnoreCase('navpeII_dev18__')
                     ? 'Pipeline__c'
                     : 'Deal__c');
                processAccAssociatedToDeals(namespacePrefix, TOKEN_SOBJECT_NAME, objIdVsActIdsMap.keySet());
                return prepareFinalMap('Account', refField);
            }
        } catch (Exception e) {
            System.debug('953==='+e.getLineNumber());
            throw new AuraHandledException('632' + ' : <<' + e.getStackTraceString() + '>>');
        }
    }
    
    
    private static void processCRActInfo(String objName, String relAssoClause){
        try {
            
            //Added IsChild = false check on 2022-10-07 to consider only the main copy of the event record
            for(sObject actRec : Database.query('SELECT Id, navpeII_dev18__Related_Associations__c FROM ' + objName + ' WHERE ' + relAssoClause + (objName.equalsIgnoreCase('Event') ? ' AND IsChild = false' : ''))){
                completeActIdsSet.add(String.valueOf(actRec.get('Id')));
                processRelObjIds(String.valueOf(actRec.get('navpeII_dev18__Related_Associations__c')), String.valueOf(actRec.get('Id')));
            }
        } catch(Exception e) {
            // throw new AuraHandledException(ERR_MSG + ' : <<' + e.getStackTraceString() + '>>');
        }
    }
    
    private static void processAccAssociatedToDeals(String namespacePrefix, String objName, Set<String> accountIdSet){
        try {
            Integer remainingRows = Limits.getLimitQueryRows() - Limits.getQueryRows();
            for(sObject objRec : Database.query('SELECT ' + namespacePrefix + 'Company__c FROM ' + objName + ' WHERE ' + namespacePrefix + 'Company__c IN :accountIdSet AND Active__c = true'+ ' Limit '+remainingRows)){
                accIdSet.add(String.valueOf(objRec.get(namespacePrefix + 'Company__c')));
            }
        } catch(Exception e) {
            // throw new AuraHandledException(ERR_MSG + ' : <<' + e.getStackTraceString() + '>>');
        }
    }
    private static void processCRActInfo(String objName, List<String> actIdList, String whereClause, List<String> conIdList, String recordId, String objApiName, String namespacePrefix){
        try {
            String objRelation = objName+'Relation';
            Integer remainingRows = Limits.getLimitQueryRows() - Limits.getQueryRows();
            if(Schema.getGlobalDescribe().get(objRelation) != null){
                for(sObject actRec : Database.query('SELECT AccountId, RelationId, ' + objName + 'Id, ' + objName + '.navpeII_dev18__Related_Associations__c FROM ' + objName + 'Relation' + whereClause+ ' Limit '+remainingRows)){
                    String actId = String.valueOf(actRec.get(objName + 'Id'));
                    String relAssoIds = String.valueOf(actRec.getSobject(objName).get('navpeII_dev18__Related_Associations__c'));
                    if(String.isNotBlank(relAssoIds)){
                        processRelObjIds(relAssoIds, actId);
                    }
                    //If condition for Account Record Page & else condition for Contact Record Page
                    if(objApiName.equalsIgnoreCase('Account')){
                        //For storing activities where contact is referenced
                        if(conIdList.contains(String.valueOf(actRec.get('RelationId')))){
                            actIdsSet.add(actId);
                            completeActIdsSet.add(actId);
                        }
                        //For storing activities where account id is referenced
                        if(String.isNotBlank(relAssoIds) && relAssoIds.contains(recordId)){
                            completeActIdsSet.add(actId);
                        }
                    } else {
                        actIdsSet.add(actId);
                        completeActIdsSet.add(actId);
                    }
                    //Added below code & moved processRelObjIds() inside if condition on 2022-09-23 to not process records with blank AccountId
                    String accountId = String.valueOf(actRec.get('AccountId'));
                    if(String.isNotBlank(accountId)){
                        processRelObjIds(String.valueOf(actRec.get('AccountId')), actId);
                    }
                }
            }
        } catch (Exception e) {
            System.debug('1011--'+e.getLineNumber());
            // throw new AuraHandledException(ERR_MSG + ' : <<' + e.getStackTraceString() + '>>');
        }
    }
    ////////////////////////////////////////////////////////////
    
    
    /*
* Purpose : Finds activity records to be processed
* Input : actIdSet    [Set of Account Id]
*         evntList      [List of Event]
*         whereClause  [Where clause to be used in the SOQL query]
* Returns : List<EventInteractionWrapper> list of interactionWrapper
*/
    /* public List<EventInteractionWrapper> getEventInteractionWrapper(Set<ID> accIdSet , List<Event> evntList){
Map<ID,String> accNamemap = new Map<ID,String>();

List<Contact> accList = [Select Id, Name from Contact where Id IN: accIdSet];
System.debug('accList'+accList);
for(Contact acc : accList){
accNamemap.put(acc.Id, acc.Name);
}

List<EventInteractionWrapper> evntIntrWrapperLst = new List<EventInteractionWrapper>();
for(Event getEvent :evntList){
System.debug('getEvent'+getEvent.ID);
EventInteractionWrapper evntwrap = new EventInteractionWrapper();
evntwrap.Subject = getEvent.Subject;
evntwrap.Description = getEvent.Description;
evntwrap.OwnerName = getEvent.Owner.Name;
evntwrap.ActivityDate = String.Valueof(getEvent.ActivityDate);
List<String> accNameList = new List<String>();
if(String.isnotBlank(getEvent.Related_Associations__c)){
if(getEvent.Related_Associations__c.contains(',')){
for(String str : getEvent.Related_Associations__c.split(',')){
if(str.startsWith('003') && accNamemap.containskey(str)){
accNameList.add(accNamemap.get(str));
}
}
}
else{
if(getEvent.Related_Associations__c.startsWith('003') && accNamemap.containskey(getEvent.Related_Associations__c)){
accNameList.add(accNamemap.get(getEvent.Related_Associations__c));
}
}
}
//accNameList.addAll(taskIDVsConnameMp.get(getEvent.Id));
evntwrap.ReferencesName = accNameList.size() > 0 ? String.valueof(accNameList).replace('(','').replace(')','') : '';
evntIntrWrapperLst.add(evntwrap);
}
return evntIntrWrapperLst;
}*/
    
    ///////////////
    //
    //
    /*
* Purpose : Fetches initial data to be used for further processing
* Input : metadataField1      [Field 1 to process for Contact/Connections Section]
*         otherMetadataFields [Other fields as a comma separated string to process for Contact/Connections Section]
*         objName             [Object to query data from]
*         whereClause         [Where clause to be used in the SOQL query]
*         recordId            [Record ID of the current record (Account/Contact)]
*         idSet               [ID set to be worked upon]
* Returns : Initial data to be used for further processing as a Map<String, sObject>
*/
    private static Map<String, sObject> fetchInitInfoToProcess(String metadataField1, String otherMetadataFields, String objName, String whereClause, String recordId, Set<String> idSet){
        try {
            String refField = Acuity_Setting__mdt.getInstance(metadataField1).Value__c;
            String fieldStr = refField; //Added on 2022-09-26 to create a separate string if values exist in metadata
            if(String.isNotBlank(refField)){
                fieldStr = ', FORMAT(' + refField + ')';
            }
            for(String metadataField : otherMetadataFields.split(',')){
                String refField2 = Acuity_Setting__mdt.getInstance(metadataField).Value__c;
                //Added string comparison case on 2022-09-26 to create a separate string if values exist in metadata
                if(String.isNotBlank(refField) && String.isNotBlank(refField2) && !fieldStr.contains('FORMAT(' + refField2 + ')')){
                    fieldStr += ', FORMAT(' + refField2 + ')';
                }
            }
            /* RG : START */
            if(String.isNotBlank(refField) && !refField.contains('Email') && (objName.equalsIgnoreCase('Contact') || objName.equalsIgnoreCase('User'))){
                fieldStr += ', Email';
                /*if(objName.equalsIgnoreCase('Contact')){//added by shivam
fieldStr+=',AccountId,Account.Name';
} */
            }
            if(String.isNotBlank(refField) && !refField.contains('AccountId') && objName.equalsIgnoreCase('Contact')){//added by shivam
                fieldStr+=',AccountId,Account.Name';
            }
            //Condition for Fundraising Acuity > Fundraising_Contact__c Section
            if(String.isNotBlank(refField) && !refField.contains('navpeII_dev18__Contact__r.Email') && objName.equalsIgnoreCase('navpeII_dev18__Fundraising_Contact__c')){
                fieldStr += ', navpeII_dev18__Contact__r.Email';
            }
            /* RG : END */
            /* Last Interaction : START */
            if(objName.equalsIgnoreCase('Contact') && !fieldStr.contains('navpeII_dev18__Last_Touch_Point__c')){
                fieldStr += ', FORMAT(navpeII_dev18__Last_Touch_Point__c)';
            } /*else if(objName.equalsIgnoreCase('User') && !fieldStr.contains('Last_Touchpoint__c')){
fieldStr += ', FORMAT(Last_Touchpoint__c)';
}*/
            if((objName.equalsIgnoreCase('Contact') /*|| objName.equalsIgnoreCase('User')*/) && !fieldStr.contains('navpeII_dev18__Last_Touchpoint_ID__c')){
                fieldStr += ', navpeII_dev18__Last_Touchpoint_ID__c';
            }
            /* Last Interaction : END */
            return new Map<String, sObject>(Database.query('SELECT Id' + (String.isBlank(fieldStr) ? '' : String.escapeSingleQuotes(fieldStr)) + ' FROM ' + String.escapeSingleQuotes(objName) + String.escapeSingleQuotes(whereClause)));
        } catch (Exception e) {
            throw new AuraHandledException('Error line 795 ' + ' : <<' + e.getStackTraceString() + '>>');
        }    
    }
    
    
    
    
    ////
    public static ResponseWrapper processConInfo(Map<String, sObject> conMap, String recordId, String metadataField1, String otherMetadataFields, String namespacePrefix, String conEmail, List<String> actIdList, Boolean tfVal, String objApiName, String calledFrom, List<String> parentConIdList){
        try {
            ResponseWrapper respWrapper = new ResponseWrapper();
            String refField = Acuity_Setting__mdt.getInstance(metadataField1).Value__c;
            if(String.isBlank(refField)){
                return null;
            } else {
                List<String> fieldList = otherMetadataFields.split(',');
                String refField2 = Acuity_Setting__mdt.getInstance(fieldList.get(0)).Value__c;
                String refField3; //Modifed by Anshika Ahuja W.R.To Bug #00034852
                String refField4;
                if(String.isNotBlank(refField2)){
                    respWrapper.conSecDynFieldHeader = objApiName.equalsIgnoreCase(namespacePrefix + 'Fundraising__c')
                        ? fetchFieldLabel(calledFrom.equalsIgnoreCase('IC') ? 'User' : calledFrom.equalsIgnoreCase('PageLoad') ? namespacePrefix+'Fundraising_Contact__c' : 'Contact', refField2)
                        : fetchFieldLabel(calledFrom.equalsIgnoreCase('PageLoad') || calledFrom.equalsIgnoreCase('EC') ? 'Contact' : 'User', refField2);   
                }
                objIdVsActIdsMap = new Map<String, Set<String>>();
                List<ConWrapper> nonSfConWrapperList = new List<ConWrapper>();
                if(objApiName.equalsIgnoreCase('Account')){
                    //For Meeting Call Datapoint calculation
                    if(calledFrom.equalsIgnoreCase('IC')){
                        processMeetingCallInfo(actIdList, 'Event', recordId, ' WHERE EventId IN :actIdList AND (Relation.Type = \'Contact\' OR Relation.Type = \'User\')');
                        processMeetingCallInfo(actIdList, 'Task', recordId, ' WHERE TaskId IN :actIdList AND Task.TaskSubType = \'Call\'');
                    } else {
                        processMeetingCallInfo(actIdList, 'Event', recordId, ' WHERE EventId IN :actIdList AND Relation.Type = \'Contact\'');
                        processMeetingCallInfo(actIdList, 'Task', recordId, ' WHERE TaskId IN :actIdList AND Task.TaskSubType = \'Call\' AND Relation.Type = \'Contact\'');    
                    }
                    //For Email Datapoint calculation
                    if(calledFrom.equalsIgnoreCase('IC')){// added IC removed tfval==true
                        try {
                            getUsersListOfRecords(conEmail, 'Contact', recordId, namespacePrefix); 
                        } catch(Exception e) {
                            respWrapper.apiError = true;
                        }
                    } else {
                        try {
                            if(calledFrom.equalsIgnoreCase('PageLoad')){ //removed not calledFrom.equalsIgnoreCase('EC') || Shivam
                                nonSfConWrapperList = countInboundAndOutboundMethod(recordId, namespacePrefix, conMap);
                            }
                        } catch(Exception e) {
                            respWrapper.apiError = true;
                        }
                    }
                } else if(objApiName.equalsIgnoreCase('Contact') || objApiName.equalsIgnoreCase(namespacePrefix + 'Pipeline__c')){//fixed critical Shivam bug #00035184
                    //For Meeting Call Datapoint calculation
                    processMeetingCallInfo(actIdList, 'Event', recordId, ' WHERE EventId IN :actIdList AND (Relation.Type = \'Contact\' OR Relation.Type = \'User\')');
                    processMeetingCallInfo(actIdList, 'Task', recordId, ' WHERE TaskId IN :actIdList AND Task.TaskSubType = \'Call\'');
                    //For Email Datapoint calculation
                    try {
                        getUsersListOfRecords(conEmail, 'Contact', recordId, namespacePrefix);
                    } catch(Exception e) {
                        respWrapper.apiError = true;
                    }
                } else if(objApiName.equalsIgnoreCase(namespacePrefix + 'Fundraising__c')){
                    refField3 = (fieldList.size() >= 2)?Acuity_Setting__mdt.getInstance(fieldList.get(1)).Value__c:'';
                    refField4 = (fieldList.size() >= 3)?Acuity_Setting__mdt.getInstance(fieldList.get(2)).Value__c:'';
                    if(String.isNotBlank(refField3)){
                        if(refField3.contains('__r.')){
                            respWrapper.conSecDynFieldHeader2 = fetchFieldLabel('Contact', refField3.split('__r.').get(1));    
                        }
                    }
                    if(String.isNotBlank(refField4)){
                        respWrapper.conSecDynFieldHeader3 = fetchFieldLabel(namespacePrefix+'Fundraising_Contact__c', refField4);
                    }
                    //For Meeting Call Datapoint calculation
                    processMeetingCallInfo(actIdList, 'Event', recordId, ' WHERE EventId IN :actIdList AND (Relation.Type = \'Contact\' OR Relation.Type = \'User\')');// critical resolved by Shivam bug #00035187
                    processMeetingCallInfo(actIdList, 'Task', recordId, ' WHERE TaskId IN :actIdList AND Task.TaskSubType = \'Call\'');
                    //added by Shivam
                    if(calledFrom.equalsIgnoreCase('IC')){
                        try{
                            getUsersListOfRecords(conEmail, 'Contact', recordId, namespacePrefix);
                        } catch(Exception e) {
                            respWrapper.apiError = true;
                        }
                        
                    }
                }
                //For Deal Datapoint calculation
                if(objApiName.equalsIgnoreCase('Account') || objApiName.equalsIgnoreCase('Contact')|| objApiName.equalsIgnoreCase(namespacePrefix + 'Fundraising__c') || objApiName.equalsIgnoreCase(namespacePrefix + 'Pipeline__c')){
                    if(conMap != null){
                        if(calledFrom.equalsIgnoreCase('PageLoad')){
                            getWrapperContactDealInformation(objApiName.equalsIgnoreCase('Account') ? '' : String.escapeSingleQuotes(recordId), String.escapeSingleQuotes(namespacePrefix), conMap.keySet(),calledFrom);
                        }else if(calledFrom.equalsIgnoreCase('IC')){
                         getWrapperContactDealInformation(calledFrom.equalsIgnoreCase('IC') ? String.escapeSingleQuotes(recordId) : '', String.escapeSingleQuotes(namespacePrefix), conMap.keySet(),calledFrom);//added by shivam
                     }
                     else if(calledFrom.equalsIgnoreCase('EC')){
                         getWrapperContactDealInformation( String.escapeSingleQuotes(recordId), String.escapeSingleQuotes(namespacePrefix), conMap.keySet(), calledFrom);//added by shivam
                        }
                    }
                }
                //For Deal Datapoint calculation (Fundraising)
                if(objApiName.equalsIgnoreCase(namespacePrefix + 'Fundraising__c') && calledFrom.equalsIgnoreCase('PageLoad') ){
                    try{
                        handleFundRaisingOnLoad(recordId, calledFrom);
                    } catch(Exception e){}
                }
                /* if((calledFrom.equalsIgnoreCase('IC') || calledFrom.equalsIgnoreCase('EC')) && conMap != null){
processConLastInteractionInfo(calledFrom.equalsIgnoreCase('IC') ? 'User' : 'Contact', conMap);
}*/
                //Modified w.r.to Fundraising contact section with Shivam
                List<ConWrapper> conWrapperList = objApiName.equalsIgnoreCase('Account') || objApiName.equalsIgnoreCase('Contact') || (objApiName.equalsIgnoreCase(namespacePrefix + 'Fundraising__c') && (calledFrom.equalsIgnoreCase('IC') || calledFrom.equalsIgnoreCase('EC'))) || (objApiName.equalsIgnoreCase(namespacePrefix + 'Pipeline__c')) // && calledFrom.equalsIgnoreCase('IC') shivam
                    ? prepareConFinalMap(conMap, refField, refField2, namespacePrefix)
                    :  new List<ConWrapper>();
                if(calledFrom.equalsIgnoreCase('EC')){
             conWrapperList = prepareConFinalMapforExternal(conMap, refField, refField2, namespacePrefix);  
             }
                /* RG : START */
                if(nonSfConWrapperList != null){
                    conWrapperList.addAll(nonSfConWrapperList);
                }
                /* RG : END */
                respWrapper.conInfoWrapper = conWrapperList;
                //added by shivam
                return respWrapper;
            }
        } catch (Exception e) {
            System.debug('1237err'+e.getLineNumber());
            throw new AuraHandledException('' + ' : <<' + e.getStackTraceString() + '>>');
        }
    }
    /*
* Purpose : Prepares final map of the data to be displayed under Referenced Section
* Input : conMap            [Initial info to be used for processing final map]
*         refField          [Referenced field 1 to be used for displaying data in Contacts/Connections section]
*         refField2         [Referenced field 2 to be used for displaying data in Contacts/Connections section]
*         namespacePrefix   [Namespaceprefix to be used]
* Returns : List<InfoWrapper> containing info about each record to be displayed in data tables under Contacts/Connections Section
*/
    private static List<ConWrapper> prepareConFinalMap(Map<String, sObject> conMap, String refField, String refField2, String namespacePrefix){
        try {
            List<ConWrapper> conInfo = new List<ConWrapper>();
            if(conMap != null){
                
                for(String conId : conMap.keySet()){
                    if(conId.startsWith('003') || objIdVsActIdsMap.containsKey(conId) || userIdVsEmailCount.containsKey(conId) || objIdVsDealIdsMap.containsKey(conId)){
                        List<String> actIdList = new List<String>();
                        List<String> dealIdList = new List<String>();
                        ConWrapper conWrapper = new ConWrapper();
                        conWrapper.recId = conId;
                        conWrapper.name = String.valueOf(conMap.get(conId).get(refField));
                        
                        if(String.isNotBlank(refField2)){
                            conWrapper.fieldInfo = String.valueOf((conMap.get(conId).get(refField2)));
                        }
                        /* Meeting Count Handling : Start */
                        conWrapper.meetingCallCount = objIdVsActIdsMap.containsKey(conId)
                            ? objIdVsActIdsMap.get(conId).size()
                            : 0;
                        if(objIdVsActIdsMap.containsKey(conId)){
                            actIdList.addAll(objIdVsActIdsMap.get(conId));
                        }
                        conWrapper.meetingCallIdList = actIdList;
                        if(objIdVsLastInteractionInfoMap.containsKey(conId)){
                            conWrapper.lastInteractionDate = objIdVsLastInteractionInfoMap.get(conId).lastInteractionDate;
                            conWrapper.lastInteractionNote = objIdVsLastInteractionInfoMap.get(conId).lastInteractionNote;
                            conWrapper.lastInteractionId = objIdVsLastInteractionInfoMap.get(conId).lastInteractionId;
                            conWrapper.lastInteractionType = objIdVsLastInteractionInfoMap.get(conId).lastInteractionType;
                        }
                        /* Meeting Count Handling : End */
                        /* RG : START */
                        conWrapper.email = String.valueOf(conMap.get(conId).get('Email'));
                        if(conId.startsWith('003')){
                            conWrapper.nameRef = '/' + conId;
                            conWrapper.emailCount = String.isNotBlank(String.valueOf(conMap.get(conId).get('Email'))) && emailVsCount.containsKey(String.valueOf(conMap.get(conId).get('Email')))
                                ? emailVsCount.get(String.valueOf(conMap.get(conId).get('Email')))
                                : 0;
                            //added by shivam
                            conWrapper.firmRef =  '/'+String.valueOf(conMap.get(conId).get('AccountId'));
                            conWrapper.firmName = conMap.get(conId).get('AccountId')!= null ? String.valueOf(conMap.get(conId).getSobject('Account').get('Name')) : ''; //For resolving critical
                            // ends Shivam 
                        } else if(conId.startsWith('005')) {
                            //Added below line on 2022-10-27 to open user's record view page & not the settings page for logged in user
                            //conWrapper.nameRef = '/lightning/r/User/'+ conId + '/view';
                            conWrapper.emailCount = userIdVsEmailCount.containsKey(String.valueOf(conMap.get(conId).get('Id')))
                                ? userIdVsEmailCount.get(String.valueOf(conMap.get(conId).get('Id')))
                                : 0;
                            conWrapper.mailboxId = String.valueOf(userIdVsMBid.get(String.valueOf(conMap.get(conId).get('Id'))));
                        }
                        /* RG : END */
                        /* Deal Count Handling : Start */
                        conWrapper.dealCount = objIdVsDealIdsMap.containsKey(conId)? objIdVsDealIdsMap.get(conId).size(): 0;
                        if(objIdVsDealIdsMap.containsKey(conId)){
                            dealIdList.addAll(objIdVsDealIdsMap.get(conId));
                        }
                        conWrapper.dealIdList = dealIdList;
                        /* Deal Count Handling : End */
                        conWrapper.totalActCount = conWrapper.meetingCallCount + conWrapper.emailCount + conWrapper.dealCount;
                        conInfo.add(conWrapper);
                    }
                }
            }
            return conInfo;
        } catch (Exception e) {
            System.debug('1050===='+e.getLineNumber()+e.getMessage());
            throw new AuraHandledException('' + ' : <<' + e.getStackTraceString() + '>>');
        }   
    }
    
    private static List<ConWrapper> prepareConFinalMapforExternal(Map<String, sObject> conMap, String refField, String refField2, String namespacePrefix){////Resloving critical 00039864
     try {
         List<ConWrapper> conInfo = new List<ConWrapper>();
         if(conMap != null){
             for(String conId : conMap.keySet()){
                 if(conId.startsWith('003') || objIdVsDealIdsMapExternal.containsKey(conId)){ //Resloving critical 00039864
                     ConWrapper conWrapper = new ConWrapper();
                     conWrapper.recId = conId;
                     conWrapper.name = String.valueOf(conMap.get(conId).get(refField));
                     if(String.isNotBlank(refField2)){// For resolving critical 00040161
                         conWrapper.fieldInfo = String.valueOf(conMap.get(conId).get(refField2));} // For resolving critical 00040161
                      /* RG : START */
                     conWrapper.email = String.valueOf(conMap.get(conId).get('Email'));
                     /* RG : END */
                     /* Deal Count Handling : Start */
    
                     conWrapper.dealCount = objIdVsDealIdsMapExternal.containsKey(conId)? objIdVsDealIdsMapExternal.get(conId).size(): 0;
                     conInfo.add(conWrapper);
                 }
             }
         }
         return conInfo;
     } catch (Exception e) {
         System.debug('1050===='+e.getLineNumber()+e.getMessage());
         throw new AuraHandledException('' + ' : <<' + e.getStackTraceString() + '>>');
     }   
 }
    /*
* Purpose : Prepares final map of the data to be displayed under Referenced Section
* Input : conMap            [Initial info to be used for processing final map]
*         refField          [Referenced field 1 to be used for displaying data in Contacts/Connections section]
*         refField2         [Referenced field 2 to be used for displaying data in Contacts/Connections section]
*         namespacePrefix   [Namespaceprefix to be used]
* Returns : List<InfoWrapper> containing info about each record to be displayed in data tables under Contacts/Connections Section
*/
    /*  private static List<ConWrapper> prepareFdrConFinalMap(Map<String, sObject> conMap, String refField, String refField2, String refField3, String refField4, String namespacePrefix){
try {
List<ConWrapper> conInfo = new List<ConWrapper>();
string recId = '';
String sObjName = '';
Id recordId; 
if(conMap != null){//added by Shivam
for(String conId : conMap.keySet()){
List<String> actIdList = new List<String>();
List<String> dealIdList = new List<String>();
ConWrapper conWrapper = new ConWrapper();
conWrapper.frcId = conId;
if(String.isNotBlank(refField)){
if(refField.contains('__r.')){
recId = String.valueOf((conMap.get(conId).get(refField.split('__r.').get(0)+'__c')));
recordId = (Id)recId;
sObjName = recordId.getSObjectType().getDescribe().getName();
conWrapper.recId = recordId;
conWrapper.name = fetchFieldData(sObjName, recordId, refField.split('__r.').get(1));
conWrapper.nameRef = '/' + recordId;
}
}
if(String.isNotBlank(refField2)){
if(refField2.contains('__r.')){
recId = String.valueOf((conMap.get(conId).get(refField2.split('__r.').get(0)+'__c')));
recordId = (Id)recId;
sObjName = recordId.getSObjectType().getDescribe().getName();
conWrapper.recId2 = recordId;
conWrapper.name2 = fetchFieldData(sObjName, recordId, refField2.split('__r.').get(1));
conWrapper.nameRef2 = '/' + recordId;
}
}
if(String.isNotBlank(refField3)){
if(refField3.contains('__r.')){
recId = String.valueOf((conMap.get(conId).get(refField3.split('__r.').get(0)+'__c')));
recordId = (Id)recId;
sObjName = recordId.getSObjectType().getDescribe().getName();
conWrapper.fieldInfo2 = fetchFieldData(sObjName, recordId, refField3.split('__r.').get(1));
} else {
conWrapper.fieldInfo2 = String.valueOf((conMap.get(conId).get(refField3)));     
}
}
if(String.isNotBlank(refField4)){
if(refField4.contains('__r.')){
recId = String.valueOf((conMap.get(conId).get(refField4.split('__r.').get(0)+'__c')));
recordId = (Id)recId;
sObjName = recordId.getSObjectType().getDescribe().getName();
conWrapper.fieldInfo3 = fetchFieldData(sObjName, recordId, refField4.split('__r.').get(1));    
} else {
conWrapper.fieldInfo3 = String.valueOf((conMap.get(conId).get(refField4)));        
}
}
//Meeting Count Handling : Start 
conWrapper.meetingCallCount = objIdVsActIdsMap.containsKey(String.valueOf(conMap.get(conId).get(namespacePrefix+'Contact__c')))
? objIdVsActIdsMap.get(String.valueOf(conMap.get(conId).get(namespacePrefix+'Contact__c'))).size()
: 0;
conWrapper.meetingCallIdList = objIdVsActIdsMap.containsKey(String.valueOf(conMap.get(conId).get(namespacePrefix+'Contact__c')))
? new List<String>(objIdVsActIdsMap.get(String.valueOf(conMap.get(conId).get(namespacePrefix+'Contact__c'))))
: new List<String>();
if(objIdVsActIdsMap.containsKey(String.valueOf(conMap.get(conId).get(namespacePrefix+'Contact__c')))){
actIdList.addAll(objIdVsActIdsMap.get(String.valueOf(conMap.get(conId).get(namespacePrefix+'Contact__c'))));
}
conWrapper.meetingCallIdList = actIdList;
// Meeting Count Handling : End 

// Deal Count Handling : Start 
conWrapper.dealCount = objIdVsDealIdsMap.containsKey(String.valueOf(conMap.get(conId).get(namespacePrefix+'Contact__c')))
? objIdVsDealIdsMap.get(String.valueOf(conMap.get(conId).get(namespacePrefix+'Contact__c'))).size()
: 0;
if(objIdVsDealIdsMap.containsKey(String.valueOf(conMap.get(conId).get(namespacePrefix+'Contact__c')))){
dealIdList.addAll(objIdVsDealIdsMap.get(String.valueOf(conMap.get(conId).get(namespacePrefix+'Contact__c'))));
}
conWrapper.dealIdList = dealIdList;
//Deal Count Handling : End 
// RG : START 
//Merged with Shivam for Deals and Mails count 15-12-2022
String conEmail = String.valueOf(conMap.get(conId).getSObject(namespacePrefix+'Contact__r').get('Email'));                
conWrapper.email = conEmail;
conWrapper.emailCount = emailVsCount.containsKey(conEmail)
? emailVsCount.get(conEmail)
: 0;
conWrapper.mailboxId = String.valueOf(userIdVsMBid.get(String.valueOf(conMap.get(conId).get('navpeII_dev18__Contact__c'))));
// RG : END 
conWrapper.totalActCount = conWrapper.meetingCallCount + conWrapper.dealCount + conWrapper.emailCount;
conInfo.add(conWrapper);
}
}            
return conInfo;
} catch (Exception e) {
throw new AuraHandledException('' + ' : <<' + e.getStackTraceString() + '>>');
}   
}*/
    /*
* Purpose : To get the record details 
* Input : objectName            [Name of the object - Contact/Institution]
*         recordId          	 [record id]
*         fieldName		     [api name of the referenced field]
* Returns : String				 Returns field value
*/
    /*  private static String fetchFieldData(String objectName, String recordId, String fieldName){
try {
SObject sobjRec = Database.query('SELECT Id, ' + String.escapeSingleQuotes(fieldName) + ' FROM ' + String.escapeSingleQuotes(objectName) + ' WHERE ID=:recordId'); 
return (String.valueOf(sobjRec.get(fieldName)));    
} catch(Exception e) {
throw new AuraHandledException('' + ' : <<' + e.getStackTraceString() + '>>');
}
}*/
    
    /*
* Purpose : Processes last interaction info (Date & Note)
* Input : objName      [Object name (User/Contact)]
*         conIdSet     [Contact ID list to be processed (For Contact only)]
*         actIdList    [Activity ID list to be processed]
* Returns : N/A
*/
    /* private static void processConLastInteractionInfo(String objName, Map<String, sObject> conMap){
try {
//Preparing activity IDs set to be processed
Set<String> actIdSet = new Set<String>();
Set<String> conIdSet = new Set<String>();
if(conMap.keySet().size() > 0){
conIdSet.addAll(conMap.keySet());
}
for(sObject objRec : Database.query('SELECT navpeII_dev18__Last_Touchpoint_ID__c FROM ' + objName + ' WHERE Id IN :conIdSet AND navpeII_dev18__Last_Touchpoint_ID__c != null')){
actIdSet.add(String.valueOf(objRec.get('navpeII_dev18__Last_Touchpoint_ID__c')));
}
//Preparing activity ID vs Description map for the processed activity IDs
Map<String, String> actIdVsNoteMap = new Map<String, String>();
for(sObject actObjRec : Database.query('SELECT Id, Description FROM Task WHERE ID IN :actIdSet')){
actIdVsNoteMap.put(String.valueOf(actObjRec.get('Id')), String.valueOf(actObjRec.get('Description')));
}
for(sObject actObjRec : Database.query('SELECT Id, Description FROM Event WHERE ID IN :actIdSet')){
actIdVsNoteMap.put(String.valueOf(actObjRec.get('Id')), String.valueOf(actObjRec.get('Description')));
}
//Preparing map of the object ID vs Last Interaction Info
String LAST_TOUCHPOINT_REF_FIELD = objName.equalsIgnoreCase('User')
? 'Last_Touchpoint__c'
: 'navpeII_dev18__Last_Touch_Point__c';
for(String recId : conMap.keySet()){
String lastInteractionDate = String.valueOf(conMap.get(recId).get(LAST_TOUCHPOINT_REF_FIELD));
String lastInteractionNote = actIdVsNoteMap.get(String.valueOf(conMap.get(recId).get('Last_Touchpoint_ID__c')));
String lastInteractionId = String.valueOf(conMap.get(recId).get('Last_Touchpoint_ID__c'));
String lastInteractionType = String.isNotBlank(lastInteractionId)
? String.valueOf(Id.valueOf(lastInteractionId).getsobjecttype())
: '';
objIdVsLastInteractionInfoMap.put(String.valueOf(recId), new LastInteractionInfo(lastInteractionDate, lastInteractionNote, lastInteractionId, lastInteractionType));
}
} catch (Exception e) {
throw new AuraHandledException('line 1195 ' + ' : <<' + e.getStackTraceString() + '>>');
}
}*/
    public static void handleFundRaisingOnLoad(String recordId, String calledFrom){
        Set<String> idSet = new Set<String>();
        Map<String, Sobject> conMap = new Map<String, sObject>();
        String namespacePrefix = getNamespacePrefix() + '__';
        try {
            if(recordId != null){
                String queryString = 'Select id, ' + String.escapeSingleQuotes(namespacePrefix) + 'Contact__c From ' + String.escapeSingleQuotes(namespacePrefix) + 'Fundraising_Contact__c Where ' + String.escapeSingleQuotes(namespacePrefix) + 'Contact__c != null AND ' + String.escapeSingleQuotes(namespacePrefix) + 'Fundraising__c =\'' + String.escapeSingleQuotes(recordId) + '\'';
                for(Sobject d: database.query(queryString)){
                    idSet.add(String.valueOf(d.get(String.escapeSingleQuotes(namespacePrefix) + 'Contact__c')));
                }
                if(idSet.size() > 0){
                    conMap = fetchInitInfoToProcess('Acuity_Connection_Field1', 'Acuity_Connection_Field2', 'Contact', ' WHERE id IN :idSet', null, idSet);
                    String refField = Acuity_Setting__mdt.getInstance('Acuity_Connection_Field1').Value__c;
                    String refField2 = Acuity_Setting__mdt.getInstance('Acuity_Connection_Field2').Value__c;
                    getWrapperContactDealInformation('', String.escapeSingleQuotes(namespacePrefix), conMap.keySet(),'');
                    countInboundAndOutboundMethod(null, namespacePrefix, conMap);
                }   
            }
            
        } catch (Exception e){
            throw new AuraHandledException(e.getStackTraceString());
        }
    }
    
    /*
* Purpose : Processes the page load info like Contact Details / User Details to be displayed.
* Input Parameter : AccountId / ContactId.
* Returns : Info to be displayed on page load as a Response Wrapper.
*/
    private static void getWrapperContactDealInformation(String recordId, String namespacePrefix, Set<String> conIdSet, String calledfrom){
        try {
            if(String.isNotBlank(recordId) && (!calledFrom.equalsIgnoreCase('EC'))){
                getWrapperContactUserDealCount(String.escapeSingleQuotes(recordId), namespacePrefix);
            } else if(String.isBlank(recordId)) {
                String dealQueryString = 'Select '+String.escapeSingleQuotes(namespacePrefix)+'Deal_Contact__c, '+String.escapeSingleQuotes(namespacePrefix)+'Deal__c from '+String.escapeSingleQuotes(namespacePrefix)+'Deal_Team__c where '+String.escapeSingleQuotes(namespacePrefix)+'Deal_Contact__c IN :conIdSet AND ' + String.escapeSingleQuotes(namespacePrefix) + 'Deal__c != null';
                List<sObject> lstDealTeams = new List<sObject>();
                lstDealTeams = Database.query(dealQueryString);
                for(sObject thisCase : lstDealTeams){
                    if(thisCase.get(namespacePrefix+'Deal_Contact__c') != null){
                        if(!objIdVsDealIdsMap.containsKey(thisCase.get(namespacePrefix+'Deal_Contact__c').toString())){
                            objIdVsDealIdsMap.put(thisCase.get(namespacePrefix+'Deal_Contact__c').toString(),new Set<String>());
                        }
                        if(!objIdVsDealIdsMap.get(thisCase.get(namespacePrefix+'Deal_Contact__c').toString()).contains(thisCase.get(namespacePrefix+'Deal__c').toString())){
                            objIdVsDealIdsMap.get(thisCase.get(namespacePrefix+'Deal_Contact__c').toString()).add(thisCase.get(namespacePrefix+'Deal__c').toString());
                        }
                    }
                }
            }
            else if(calledFrom.equalsIgnoreCase('EC') && String.isNotBlank(recordId)){
            List<String> dealIds = new List<String>(); 
            for(sObject listDeal : Database.query('Select '+String.escapeSingleQuotes(namespacePrefix)+'Deal__c From '+String.escapeSingleQuotes(namespacePrefix)+'Deal_Team__c Where '+String.escapeSingleQuotes(namespacePrefix)+'Deal_Contact__c = \''+String.escapeSingleQuotes(recordId) + '\' AND ' + String.escapeSingleQuotes(namespacePrefix) + 'Deal__c != null')){
                dealIds.add(listDeal.get(namespacePrefix+'Deal__c').toString());
            }
                for(sObject thisCase : Database.query('Select '+String.escapeSingleQuotes(namespacePrefix)+'Deal_Contact__c, '+String.escapeSingleQuotes(namespacePrefix)+'Deal__c From '+String.escapeSingleQuotes(namespacePrefix)+'Deal_Team__c Where '+String.escapeSingleQuotes(namespacePrefix)+'Deal__c In :dealIds')){
                    if(thisCase.get(namespacePrefix+'Deal_Contact__c') != null){
                        if(!objIdVsDealIdsMapExternal.containsKey(thisCase.get(namespacePrefix+'Deal_Contact__c').toString())){
                            objIdVsDealIdsMapExternal.put(thisCase.get(namespacePrefix+'Deal_Contact__c').toString(),new Set<String>());
                        }
                        if(!objIdVsDealIdsMapExternal.get(thisCase.get(namespacePrefix+'Deal_Contact__c').toString()).contains(thisCase.get(namespacePrefix+'Deal__c').toString())){
                            objIdVsDealIdsMapExternal.get(thisCase.get(namespacePrefix+'Deal_Contact__c').toString()).add(thisCase.get(namespacePrefix+'Deal__c').toString());
                        }
                    }                
                }
            }
            
        } catch(Exception ex){
            throw new AuraHandledException(ex.getStackTraceString());
        }
    }
    /*
* Purpose : Get Dynamic info for User Details to be displayed
* Input Parameter : ContactId
* Returns : Info to be displayed on page load as a Response Wrapper
*/
    @testVisible //Added by Shivam 06-02-2023
    private static void getWrapperContactUserDealCount(String recordId, String namespacePrefix){
        List<ConWrapper> conWrapperUserList = new List<ConWrapper>();
        try {
            String getDealQuery = 'Select '+String.escapeSingleQuotes(namespacePrefix)+'Deal__c From '+String.escapeSingleQuotes(namespacePrefix)+'Deal_Team__c Where '+String.escapeSingleQuotes(namespacePrefix)+'Deal_Contact__c = \''+String.escapeSingleQuotes(recordId) + '\' AND ' + String.escapeSingleQuotes(namespacePrefix) + 'Deal__c != null';
            List<sObject> contactDeals = Database.query(getDealQuery);
            List<String> dealIds = new List<String>();
            for(sObject listDeal : contactDeals){
                dealIds.add(listDeal.get(namespacePrefix+'Deal__c').toString());
            }
            // Bug 00031648/00031643 fixed by Shivam +namespacePrefix+'Team_Member__r.IsActive = true';
            String getUserQuery = 'Select '+String.escapeSingleQuotes(namespacePrefix)+'Team_Member__c, '+String.escapeSingleQuotes(namespacePrefix)+'Team_Member__r.Name, '+String.escapeSingleQuotes(namespacePrefix)+'Team_Member__r.Id, '+String.escapeSingleQuotes(namespacePrefix)+'Team_Member__r.UserRole.Name, '+String.escapeSingleQuotes(namespacePrefix)+'Deal__c From '+String.escapeSingleQuotes(namespacePrefix)+'Deal_Team__c Where '+String.escapeSingleQuotes(namespacePrefix)+'Deal__c In :dealIds';
            List<sObject> dealsUser = Database.query(getUserQuery);
            List<String> userIds = new List<String>();
            for(sObject thisCase : dealsUser){
                if(thisCase.get(namespacePrefix+'Team_Member__c') != null){
                    if(!objIdVsDealIdsMap.containsKey(thisCase.get(namespacePrefix+'Team_Member__c').toString())){
                        objIdVsDealIdsMap.put(thisCase.get(namespacePrefix+'Team_Member__c').toString(),new Set<String>());
                    }
                    if(!objIdVsDealIdsMap.get(thisCase.get(namespacePrefix+'Team_Member__c').toString()).contains(thisCase.get(namespacePrefix+'Deal__c').toString())){
                        objIdVsDealIdsMap.get(thisCase.get(namespacePrefix+'Team_Member__c').toString()).add(thisCase.get(namespacePrefix+'Deal__c').toString());
                    }
                }
            }
        } catch(Exception ex) {
            throw new AuraHandledException(ex.getStackTraceString());
        }
    }
    
    /*
* Purpose : Fetches the field label to be displayed as data table column header
* Input : objName      [Object API name]
*         fieldName    [Field whose label is to be fetched]
* Returns : Field label as a String
*/
    private static String fetchFieldLabel(String objName, String fieldName){
        try {
            String fieldLabel = Schema.getGlobalDescribe().get(objName).getDescribe().fields.getMap().get(fieldName.split('\\.')[0].replace('__r','__c')).getDescribe().getLabel();
            return fieldLabel.equalsIgnoreCase('Legal Name')
                ? 'Firm'
                : fieldLabel;
        } catch (Exception e) {
            throw new AuraHandledException('' + ' : <<' + e.getStackTraceString() + '>>');
        }
    }
    
    /*
* Purpose : Processes info for meeting & calls datapoint
* Input : actIdList    [Activity IDs to be processed]
*         objName      [Activity type (Task/Event)]
*         recordId     [Null in case of Account record Page; Contact record ID in case of Contact Page]
*         whereClause  [Where clause to be used in the SOQL query]
* Returns : N/A
*/
    private static void processMeetingCallInfo(List<String> actIdList, String objName, String recordId, String whereClause){
        try {
            //Modified the for loop on 2022-10-06 to fix the Assigned To issue
         String objRelation = objName+'Relation';
            //Integer remainingRows = Limits.getLimitQueryRows() - Limits.getQueryRows();
            if(Schema.getGlobalDescribe().get(objRelation) != null){
            for(sObject actRec : Database.query('SELECT Id, OwnerId, (SELECT RelationId FROM ' + objName + 'Relations' + whereClause + ') FROM ' + objName + ' WHERE Id IN :actIdList')){
                for(sObject actRelRec : actRec.getSObjects(objName + 'Relations')){
                    processRelObjIds(String.valueOf(actRelRec.get('RelationId')), String.valueOf(actRec.get('Id')));
                    if(String.isNotBlank(recordId)){
                        processRelObjIds(String.valueOf(actRec.get('OwnerId')), String.valueOf(actRec.get('Id')));
                    }
                }
            }
            }
        } catch (Exception e) {
            throw new AuraHandledException('' + ' : <<' + e.getStackTraceString() + '>>');
        }
    }
    /*
* getContacts: count inbound and outbound from revenue grid contacts and show list of contats available in salesforce.
* accId : Account Id
* namespacePrefix : Namespaceprefix to be used
* conMap : Initial info to be used for processing final map
*/
    @testVisible
    private static List<ConWrapper> countInboundAndOutboundMethod(Id accId, String namespacePrefix, Map<String, sObject> conMap){
        try {  
            Set<String> emailDomains = new Set<String>();
            //store existing domain in set of string
            for(String recId : conMap.keySet()){
                if(conMap.get(recId).get('Email') != null) {
                    emailDomains.add(String.valueOf(conMap.get(recId).get('Email')).split('@').get(1));
                }
            }
            List<ConWrapper> cwLst = new List<ConWrapper>();
            List<Object> rawObjLst = new List<Object>();
            if(emailDomains.size()>0){
                //fetch revenuegrid contact api
                HttpRequest req = new HttpRequest();
                //set account contact activity endpoint url
                req.setEndpoint(accConActivityEndPoint);
                req.setMethod(storePost);
                req.setHeader(storeAuth,storeApiKey);
                //store domain name comma seprated string
                String domainStr='';
                for(String e:emailDomains){
                    domainStr+='"'+e+'",';
                }
                String sbody = '{accountId:['+domainStr.removeEnd(',')+']}';
                req.setBody(sbody);
                req.setHeader(storeCT, storeTPJson);
                req.setTimeout(120000);
                Http h = new Http();
                HttpResponse res = h.send(req);
                Integer iStatusCode=res.getStatusCode();                
                if(iStatusCode == 200){ //!=500 || iStatusCode!=401 || iStatusCode!=404					                   
                    String jsonStr = res.getBody();
                    rawObjLst = (List<Object>) JSON.deserializeUntyped(jsonStr);
                    //}                                        
                }else{//added by shivam
                    // IsApiError = true;
                }
            }
            List<String> emailList = new List<String>();
            Set<String> setOfString = new Set<String>();
            //store email address setOfString variable from revenue grid
            if(rawObjLst.size()>0){
                for(Object o:rawObjLst){
                    Map<String, Object> row = (Map<String, Object>)o;
                    emailList.add(String.valueOf(row.get('contact')));
                    if((row.get('activityCategory')=='inboundEmails') || (row.get('activityCategory')=='outboundEmails') || (row.get('activityCategory')=='indirectEmails')){
                        Integer totalCo = 0;
                        if(emailVsCount.containsKey(String.valueOf(row.get('contact')))){
                            totalCo = emailVsCount.get(String.valueOf(row.get('contact')));
                        } else {
                            totalCo = 0;
                        }
                        totalCo += Integer.valueOf(row.get('count'));
                        emailVsCount.put(String.valueOf(row.get('contact')),totalCo);
                    }
                }
                setOfString.addAll(emailList);
            }
            Set<String> checkEmailIsExistOrNot = new Set<String>();
            Set<String> notFoundEmailList = new Set<String>();
            //store in wrapper class get all contact match in api same as salesforce
            //checked email from salesforce if existing or not if not exist store in notFoundEmailList variable
            if(conMap.size()>0){
                Set<String> sfEmailIdSet = new Set<String>();
                for(String recId : conMap.keySet()){
                    String emailId = String.valueOf(conMap.get(recId).get('Email'));
                    if(String.isNotBlank(emailId)){
                        sfEmailIdSet.add(emailId);
                    }
                }
                for(String checkEm:emailVsCount.keySet()){
                    if(!sfEmailIdSet.contains(checkEm)){
                        notFoundEmailList.add(checkEm);
                    }
                }
            }
            // if contact does not exist in salesforce call this api to get fullname from contacts
            if(notFoundEmailList.size()>0){
                map<String,String> emailVsNameFromApi = new map<String,String>();
                HttpRequest newConReq = new HttpRequest();
                newConReq.setEndpoint(accConQueryEndPoint);
                newConReq.setMethod(storePost);
                newConReq.setHeader(storeAuth,storeApiKey);
                //store email comma seprated string
                String nfes='';
                for(String s:notFoundEmailList){
                    nfes+='"'+s+'",';
                }
                String sNewConbody='{EmailAddress:{IN:['+nfes.removeEnd(',')+']}}';
                newConReq.setBody(sNewConbody);
                newConReq.setHeader(storeCT, storeTPJson);
                newConReq.setTimeout(120000);
                Http newConH = new Http();
                HttpResponse newConRes = newConH.send(newConReq);
                Integer iStatusCode = newConRes.getStatusCode();
                List<Object> rawNewConObjLst = new List<Object>();
                
                if(iStatusCode == 200){//!=500 || iStatusCode!=401 || iStatusCode!=404){
                    String jsonNewConStr = newConRes.getBody();
                    rawNewConObjLst = (List<Object>) JSON.deserializeUntyped(jsonNewConStr);
                }else{
                    //IsApiError = true;
                }
                if(rawNewConObjLst.size()>0){
                    for(Object o:rawNewConObjLst){
                        ConWrapper cw =  new ConWrapper();
                        Map<String, Object> row = (Map<String, Object>)o;
                        String removeBrack = '';
                        String finalStr = '';
                        if(String.valueOf(row.get('emailAddresses'))!=null){
                            removeBrack = String.valueOf(row.get('emailAddresses'));
                            finalStr = removeBrack.substring(1,removeBrack.length()-1);
                        }
                        emailVsNameFromApi.put(finalStr,String.valueOf(row.get('fullName')));
                    }
                }
                for(String s : notFoundEmailList){
                    ConWrapper cw =  new ConWrapper();
                    cw.recId = '';
                    if(emailVsNameFromApi.containsKey(s)){
                        cw.name = String.valueOf(emailVsNameFromApi.get(s)) != null ? String.valueOf(emailVsNameFromApi.get(s)) : s;
                    } else{
                        cw.name = s;
                    }
                    cw.nameRef = '/';
                    cw.downloadIcon = 'utility:download';
                    cw.email = s;
                    cw.emailCount = emailVsCount.get(s);
                    cw.meetingCallCount = 0;
                    cw.dealCount = 0;
                    cw.totalActCount = emailVsCount.get(s);
                    cwLst.add(cw);
                }
            }
            //return contact wrapper
            return cwLst;
        }  catch(CalloutException e) {
            //  IsApiError = true;
            throw new AuraHandledException('line 1471');
        } catch(Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    /*
* getUsers: check salesforce id from revenue grid match salesforce user id show user list.
* conEmail : Contact Email
* objectName : Object Api Name
* recordId : Account Id
* namespacePrefix : Namespaceprefix to be used
*/
    @AuraEnabled
    public static List<ConWrapper> getUsersListOfRecords(String conEmail, String objectName, String recordId, String namespacePrefix){
        try {
            List<ConWrapper> uwLst = new List<ConWrapper>();
            List<Object> rawObjLst = new List<Object>();
            Map<String,String> storeMBIds = new Map<String,String>();          
            if(conEmail != ''){
                //fetch revenuegrid contact api
                HttpRequest req = new HttpRequest();
                //set account connection endpoint url
                req.setEndpoint(accConnectionEndPoint);
                req.setMethod(storePost);
                req.setHeader(storeAuth,storeApiKey);        
                String sbody = '{contact:'+'"'+conEmail+'"'+'}';
                req.setBody(sbody);  
                req.setHeader(storeCT, storeTPJson);
                req.setTimeout(120000);
                Http h = new Http();
                HttpResponse res = h.send(req);
                Integer iStatusCode = res.getStatusCode();
                if(iStatusCode == 200){//!=500 || iStatusCode!=401 || iStatusCode!=404
                    String jsonStr = res.getBody();
                    rawObjLst = (List<Object>) JSON.deserializeUntyped(jsonStr);
                }
            }
            Map<String,Integer> mailBoxIdVsCntCount = new Map<String,Integer>();
            if(rawObjLst.size()>0){
                for(Object o:rawObjLst){
                    Map<String, Object> row = (Map<String, Object>)o;
                    if(row.get('activityCategory')=='outboundEmails' || row.get('activityCategory')=='inboundEmails' || row.get('activityCategory')=='indirectEmails'){
                        storeMBIds.put(String.valueOf(row.get('mailboxId')),String.valueOf(row.get('mailboxId')));
                        if(mailBoxIdVsCntCount.containsKey(String.valueOf(row.get('mailboxId')))){
                            Integer count=0;
                            count = mailBoxIdVsCntCount.get(String.valueOf(row.get('mailboxId')));
                            count=count+Integer.valueOf(row.get('count'));
                            mailBoxIdVsCntCount.put(String.valueOf(row.get('mailboxId')),count);
                        }else{
                            Integer count=0;
                            count = Integer.valueOf(row.get('count'));
                            mailBoxIdVsCntCount.put(String.valueOf(row.get('mailboxId')),count);                            
                        }
                    }
                }
            }                                   
            // get list of users from revenue grid api
            HttpRequest ureq = new HttpRequest();  
            //set get user endpoint url
            ureq.setEndpoint(getUserEndPoint);
            ureq.setMethod(storeGet);
            ureq.setHeader(storeAuth,storeApiKey);
            ureq.setHeader(storeCT, storeTPJson);
            ureq.setTimeout(120000);
            Http uh = new Http();
            HttpResponse ures = uh.send(ureq);
            Integer iStatusCode = ures.getStatusCode();
            List<Object> userRawObjLst = new List<Object>();
            if(iStatusCode == 200){//!=500 || iStatusCode!=401 || iStatusCode!=404
                String ujsonStr = ures.getBody();
                userRawObjLst = (List<Object>) JSON.deserializeUntyped(ujsonStr);
            }else{
                //  IsApiError = True;//added by shivam
            }
            
            if(userRawObjLst.size()>0 && userRawObjLst!=null){
                for(Object o:userRawObjLst){
                    Map<String, Object> row = (Map<String, Object>)o;
                    if(storeMBIds.containsKey(String.valueOf(row.get('mailboxId')))){
                        userIdVsMBid.put(String.valueOf(row.get('salesforceId')),String.valueOf(row.get('mailboxId')));
                        userIdVsEmailCount.put(String.valueOf(row.get('salesforceId')),Integer.valueOf(mailBoxIdVsCntCount.get(String.valueOf(row.get('mailboxId')))));
                    }
                }
            }
            //return this uwLst from store users list 
            return uwLst;
        } catch(CalloutException e) {
            // IsApiError = True;//added by shivam
            throw new AuraHandledException('An Error occurred in API');
        } catch(Exception e) {
            throw new AuraHandledException('ERR_MSG' + ' : <<' + e.getStackTraceString() + '>>');
        }
    }
    //////////////////
    public List<TaskInteractionWrapper> getEventInteractionWrapper(Set<ID> accIdSet , List<Event> evntList,Map<String,Set<ID>> objVSid){
        Map<ID,String> accNamemap = new Map<ID,String>();
        Map<ID,List<String>> EvtIDVsConname1 = new Map<ID,List<String>>();//event id vs contname 
        List<contact> currentConList = [Select Id, name  from contact where  id  =: getCtrl];
        for(String objName : objVSid.keySet()){
             if(Schema.getGlobalDescribe().get(objName).getDescribe().isAccessible()){//to resolve critical bug 00039972
            Set<ID> getIdSet = objVSid.get(objName);
            Integer remainingRows = Limits.getLimitQueryRows() - Limits.getQueryRows();
            System.debug('getIdSet 444--->'+getIdSet);
            for(sObject objRec : Database.query('SELECT Id, Name'  + ' FROM ' + String.escapeSingleQuotes(objName) + ' WHERE Id IN :getIdSet'+ ' Limit '+remainingRows)){
                accNamemap.put(String.Valueof(objRec.get('Id')),String.Valueof(objRec.get('Name')));
                System.debug('Line 446'+accNamemap);
            }
        }
        }
        //contact ids
        // try{
        for( String getEvent1 :evtIdVSConname.keySet()){
            for(String getEventId :evtIdVSConname.get(getEvent1) ){
                 if(!EvtIDVsConname1.containsKey(getEventId)){
                    List<String> setConName = new List<String>();
                if(accNamemap.containskey(getEvent1)){
                    setConName.add(accNamemap.get(getEvent1));               
                }  
                String conname = currentConList[0].name;
                setConName.add(conname);
                 EvtIDVsConname1.put(getEventId,setConName);
               // System.debug('getEvent1--->>>'+getEvent1+'taskIdVSConname.get(getEvent1)---->'+taskIdVSConname.get(getEvent1));
            }
            else{
                List<String> getConName = EvtIDVsConname1.get(getEventId);
                if(accNamemap.containskey(getEvent1)){
                    getConName.add(accNamemap.get(getEvent1));               
                }
                //EvtIDVsConname.put(EvtIDVsConname.get(getEvent1),getConName);
                EvtIDVsConname1.put(getEventId,getConName);
                //System.debug('getEvent1--->>>'+getEvent1+'taskIdVSConname.get(getEvent1)---->'+taskIdVSConname.get(getEvent1));
            }
            }
           
        }
        //  }
        /*  catch(Exception e){
System.debug('Error msg====='+e.getMessage() +'Line=='+e.getLineNumber());
}*/
        List<TaskInteractionWrapper> evntIntrWrapperLst = new List<TaskInteractionWrapper>();
        for(Event getEvent :evntList){
            TaskInteractionWrapper evntwrap = new TaskInteractionWrapper();
            evntwrap.Subject = getEvent.Subject;
            evntwrap.Description = eventNotAccessField.get('Event') == null ?getEvent.Description :eventNotAccessField.get('Event').contains('Description') ? '' :getEvent.Description;
            evntwrap.OwnerName = getEvent.Owner.Name;
            //getEvent.ActivityDate != null? String.valueOf(getEvent.ActivityDate.month()+'/'+getEvent.ActivityDate.day()+'/'+getEvent.ActivityDate.year()): '';
            evntwrap.ActivityDate = getEvent.ActivityDate != null? String.valueOf(getEvent.ActivityDate.month()+'/'+getEvent.ActivityDate.day()+'/'+getEvent.ActivityDate.year()): '';
            List<String> accNameList = new List<String>();
            if(String.isnotBlank(getEvent.navpeII_dev18__Related_Associations__c)){
                if(getEvent.navpeII_dev18__Related_Associations__c.contains(',')){
                    for(String str : getEvent.navpeII_dev18__Related_Associations__c.split(',')){
                        accNameList.add(accNamemap.get(str));
                    }
                }
                else{
                    if( accNamemap.containskey(getEvent.navpeII_dev18__Related_Associations__c)){
                        accNameList.add(accNamemap.get(getEvent.navpeII_dev18__Related_Associations__c));
                    }
                }
                
            }
            //System.debug('EvtIDVsConname1.get(getEvent.Id)'+EvtIDVsConname1.get(getEvent.Id));
            //accNameList.addAll(EvtIDVsConname1.get(getEvent.Id));
            evntwrap.ReferencesName = EvtIDVsConname1.containsKey(getEvent.Id)?String.valueof( String.join(accNameList, ', ')) + String.valueof (EvtIDVsConname1.size()>0 ?', '+ String.join(EvtIDVsConname1.get(getEvent.Id), ',  ') :'' ) : String.join(accNameList, ', ');
            //evntwrap.ReferencesName = accNameList.size() > 0 ? String.valueof(accNameList).replace('(','').replace(')','') : '';
            evntIntrWrapperLst.add(evntwrap);
        }
        System.debug('evntIntrWrapperLst====='+evntIntrWrapperLst);
        return evntIntrWrapperLst;
    } 
    
    /*
* Purpose : Handles the External Connections information on Contacts Section of Account & Connections Section of Contact object
* Input : recordId          [Contact record ID]
*         objApiName        [API name of the current record (Account/Contact/Deal/Fund/Fundraising)]
*         namespacePrefix   [Namespaceprefix to be used]
*         email             [Email ID of Contact]
* Returns : Info to be displayed on External Connections popup as a ResponseWrapper
*/
    @AuraEnabled
    public static ResponseWrapper handleExternalConnInfo(String recordId, String objApiName, String namespacePrefix, String email, List<String> actIdList){
        try {
            ResponseWrapper respWrapperNonSf = new ResponseWrapper();
            try{
                respWrapperNonSf = objApiName.equalsIgnoreCase('Account')
                    ? handleExternalConnInfoRG(email, 'Acuity_Connection_ExtTab_Field1', 'Acuity_Connection_ExtTab_Field2')
                    : handleExternalConnInfoRG(email, 'Acuity_Connection_ExtTab_Field1', 'Acuity_Connection_ExtTab_Field2');
            } catch(Exception e){
                System.debug('Inside line 2021---'+e.getLineNumber());
                respWrapperNonSf.apiError = true;
            }
            System.debug('Line nuber 2025--'+respWrapperNonSf);
            if(respWrapperNonSf != null){
                if(respWrapperNonSf.conMap != null){
                    respWrapperNonSf.conMap.putAll(getExternalConnInSf(String.escapeSingleQuotes(recordId), String.escapeSingleQuotes(namespacePrefix),actIdList));
                } else{
                    respWrapperNonSf.conMap = getExternalConnInSf(String.escapeSingleQuotes(recordId), String.escapeSingleQuotes(namespacePrefix), actIdList);
                }
            }
            if(respWrapperNonSf != null){
                List<ConWrapper> conWrapperList = new List<ConWrapper>();
                if(respWrapperNonSf.conInfoWrapper != null){
                    conWrapperList.addAll(respWrapperNonSf.conInfoWrapper);
                }
                List<String> conIdList = new List<String>();
                if(respWrapperNonSf.conMap != null){
                    conIdList.addAll(respWrapperNonSf.conMap.keyset());
                }
                /*
List<String> actIdList = new List<String>();
List<String> taskIdList = new List<String>();
List<String> evIdList = new List<String>();
//For handling events
evIdList = fetchRecsToProcess(conIdList, 'Event', ' WHERE (Relation.Type = \'Contact\') AND (RelationId IN :conIdList)');
//For handling tasks
taskIdList = fetchRecsToProcess(conIdList, 'Task', ' WHERE (Task.TaskSubType != \'ListEmail\') AND (Relation.Type = \'Contact\') AND (RelationId IN :conIdList)');
if(evIdList.size() > 0){
actIdList.addAll(evIdList);
}
if(taskIdList.size() > 0){
actIdList.addAll(taskIdList);
}
*/
                ResponseWrapper respWrapperSf = processConInfo(respWrapperNonSf.conMap, String.escapeSingleQuotes(recordId), 'Acuity_Connection_ExtTab_Field1', 'Acuity_Connection_ExtTab_Field2', String.escapeSingleQuotes(namespacePrefix), email, actIdList, String.isBlank(recordId), objApiName, 'EC', null);
                if(respWrapperSf.conInfoWrapper != null){
                    List<conWrapper> filteredCrossDomainData = filterCrossDomainData(respWrapperSf.conInfoWrapper,email,String.escapeSingleQuotes(recordId));//for resolving critial deal count bug
                    system.debug('shivam'+filteredCrossDomainData.size());
                    if(filteredCrossDomainData != null){
                        conWrapperList.addAll(filteredCrossDomainData);
                    }
                    //conWrapperList.addAll(respWrapperSf.conInfoWrapper);
                }
                // if(conWrapperList != null){
                //     system.debug('sh'+conWrapperList.size());
                //     system.debug('sh1'+respWrapperSf.conInfoWrapper.size());
                respWrapperSf.conInfoWrapper = conWrapperList;
                // }
                return respWrapperSf;
            } else {
                return null;
            }
        } catch (Exception e) {
            System.debug('Line number 2072--'+e.getLinenumber());
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    
    private static List<conWrapper> filterCrossDomainData(List<conWrapper> cnWrapper, String email,String recordId){
        List<ConWrapper> selfRemovedData = new List<ConWrapper>();//For resolving critical
        List<ConWrapper> filteredCrossDomainData = new List<ConWrapper>();
        if(!cnWrapper.isEmpty()){
            for(ConWrapper cw : cnWrapper){
                    if(! cw.recId.equals(recordId)){
                    selfRemovedData.add(cw);}}
            if(String.IsBlank(apiKey) || String.IsBlank(email)){
                return selfRemovedData;
            }else{
                String domain = email.split('@')[1];
                for(ConWrapper cw : selfRemovedData){
                    if(cw.email != null){                           
                        if(! String.valueOf(cw.email.split('@')[1]).equalsIgnoreCase(domain)){                             
                            filteredCrossDomainData.add(cw);}
                    }else{
                        filteredCrossDomainData.add(cw);}}}}
        return filteredCrossDomainData;
    }
    
    /*
* Method to fetch the External tab contacts data
*/
    public static map<String,Sobject> getExternalConnInSf(String recordId, String namespacePrefix, List<String> actIdList){
        try {
            Map<String,sObject> conMap = new Map<String,sObject>();
            Integer remainingRows = Limits.getLimitQueryRows() - Limits.getQueryRows();
            if(String.isNotBlank(recordId)){
                if(Schema.sObjectType.navpeII_dev18__Pipeline__c.isAccessible()){
                    String getDealQuery = 'Select '+String.escapeSingleQuotes(namespacePrefix)+'Deal__c From '+String.escapeSingleQuotes(namespacePrefix)+'Deal_Team__c Where '+String.escapeSingleQuotes(namespacePrefix)+'Deal_Contact__c = \''+String.escapeSingleQuotes(recordId) + '\' AND ' + String.escapeSingleQuotes(namespacePrefix) + 'Deal__c != null'+ ' Limit '+remainingRows;
                    List<sObject> contactDeals = Database.query(getDealQuery);
                    List<String> dealIds = new List<String>();
                    for(sObject listDeal : contactDeals){
                        dealIds.add(listDeal.get(namespacePrefix+'Deal__c').toString());
                    }
                    List<String> conIds = new List<String>();
                    if(!dealIds.isEmpty()) {
                        String getConQuery = 'Select '+String.escapeSingleQuotes(namespacePrefix)+'Deal_Contact__c, '+String.escapeSingleQuotes(namespacePrefix)+'Deal__c From '+String.escapeSingleQuotes(namespacePrefix)+'Deal_Team__c Where '+String.escapeSingleQuotes(namespacePrefix)+'Deal__c In :dealIds';
                        List<sObject> dealsCon = Database.query(getConQuery);                    
                        for(sObject thisCase : dealsCon){
                            if(thisCase.get((namespacePrefix+'Deal_Contact__c')) != null && thisCase.get((namespacePrefix+'Deal_Contact__c')) != recordId){
                                conIds.add(thisCase.get(namespacePrefix+'Deal_Contact__c').toString());
                            }
                        }
                    }               
                    
                    processMeetingCallInfo(actIdList, 'Event', recordId, ' WHERE EventId IN :actIdList AND Relation.Type = \'Contact\'');
                    processMeetingCallInfo(actIdList, 'Task', recordId, ' WHERE TaskId IN :actIdList AND Task.TaskSubType = \'Call\' AND Relation.Type = \'Contact\'');
                    for(string str : objIdVsActIdsMap.keySet()){
                        if(str.startsWith('003') && str != (ID)recordId){//For resolving Critical bug deal count
                            conIds.add(str);
                        }
                    }
                    
                    if(conIds.size() > 0){
                        conMap = new Map<String, sObject>(Database.query('SELECT Id, AccountId, Account.Name, Email,Title,Name,phone ' +', FORMAT(navpeII_dev18__Last_Touch_Point__c), navpeII_dev18__Last_Touchpoint_ID__c FROM Contact WHERE Id IN :conIds LIMIT 50000'));//fixed security issue shivam  
                    }
                }
            }
            return conMap;
            
        } catch(Exception ex) {
            throw new AuraHandledException(ex.getStackTraceString());
        }
    }
    
    /*
* Purpose : Handles the External Connections information on Contacts Section of Account object
* Input : recordId          [Contact record ID]
*         namespacePrefix   [Namespaceprefix to be used]
*         email             [Email ID of Contact]
*         actIdList         [Activity IDs to be processed]
* Returns : Info to be displayed on Internal Connections popup as a ResponseWrapper
*/
    @AuraEnabled
    public static ResponseWrapper handleExternalConnInfoRG(String email, String metadataField1, String metadataField2){
        List<ConWrapper> conWrapperList = new List<ConWrapper>();
        ResponseWrapper respWrapper = new ResponseWrapper();
        //Map<String,Integer> contactVsCount = new Map<String,Integer>();
        try {
            if(String.isBlank(email)){
                return respWrapper;//For resolving critical bug                                 
            } else {
                String requestBody = '{contact :'+'"'+email+'"}';
                String apiUrl = RG_Setting__mdt.getInstance('RG_Ext_Connection_Count').Value__c;
                String rgResponse = getRGApiResponse(apiUrl,requestBody);
                System.debug('rgResponse'+rgResponse);
                List<Object> rgResponseList = (List<Object>)JSON.deserializeUntyped(rgResponse);
                if(rgResponseList.size() > 0){
                    for(object o : rgResponseList){                        
                        Map<String, Object> row = (Map<String, Object>)o;
                        if((row.get('activityCategory')=='inboundEmails') || (row.get('activityCategory')=='outboundEmails') || (row.get('activityCategory')=='indirectEmails')){
                            Integer totalCo = 0;
                            if(emailVsCount.containsKey(String.valueOf(row.get('contact')))){
                                totalCo = emailVsCount.get(String.valueOf(row.get('contact')));
                            } else {
                                totalCo = 0;
                            }
                            totalCo += Integer.valueOf(row.get('count'));                
                            emailVsCount.put(String.valueOf(row.get('contact')),totalCo);
                        }
                    }
                }
            }
            List<String> conEmails = new List<String>(emailVsCount.keyset());
            List<String> nonSfConEmails = new List<String>();
            String refField1 = String.valueOf(Acuity_Setting__mdt.getInstance(metadataField1).Value__c);
            String refField2 = String.valueOf(Acuity_Setting__mdt.getInstance(metadataField2).Value__c);
            Integer remainingRows = Limits.getLimitQueryRows() - Limits.getQueryRows();
            Map<String, sObject> conMap = new Map<String, sObject>(Database.query('SELECT Id, AccountId, Account.Name, Email, ' + string.escapeSingleQuotes(refField1) + ', ' + string.escapeSingleQuotes(refField2) + ', FORMAT(navpeII_dev18__Last_Touch_Point__c), navpeII_dev18__Last_Touchpoint_ID__c FROM Contact WHERE Email IN :conEmails'+ ' Limit '+remainingRows));//fixed security issue shivam
            Map<String,sObject> emailVsCon = new Map<String,sObject>(); 
            for(sObject s : conMap.values()){
                emailVsCon.put(String.valueof(s.get('Email')),s);                
            }
            for(String eml :conEmails){
                if(!emailVsCon.containsKey(eml)){
                    nonSfConEmails.add(eml);
                }
            }
            conWrapperList.addAll(populateDataForNonSfCnt(nonSfConEmails,emailVsCount));
            respWrapper.conMap = conMap;
            respWrapper.conInfoWrapper = conWrapperList;
            return respWrapper;
        } catch (Exception e) {
            System.debug('1841=='+e.getLineNumber() +'Cause=='+e.getCause());
            throw new AuraHandledException(e.getStackTraceString());
        }
    }
    public static List<ConWrapper> populateDataForNonSfCnt(List<String> nonSfCnt,Map<String,Integer> contactVsCount){
        List<ConWrapper> cntWrapperList = new List<ConWrapper>();
        Map<String,String> emailVsNameFromApi = new Map<String,String>(); 
        try{            
            if(nonSfCnt.size() > 0){
                emailVsNameFromApi = getNonSfCntEmailVsName(nonSfCnt);
                for(String eml : nonSfCnt){
                    ConWrapper cw =  new ConWrapper();
                    cw.recId = '';                    
                    if(emailVsNameFromApi.containsKey(eml)){                        
                        cw.name = emailVsNameFromApi.get(eml) != null ? emailVsNameFromApi.get(eml) : eml;                        
                    } else {
                        cw.name = eml;
                    }                    
                    cw.nameRef = '/';
                    cw.downloadIcon = 'utility:download';
                    cw.email = eml;
                    cw.emailCount = contactVsCount.get(eml);
                    cw.meetingCallCount = 0;
                    cw.dealCount = 0;
                    cw.totalActCount = cw.emailCount+cw.meetingCallCount+cw.dealCount;//added by shivam medium bug 00034056
                    cntWrapperList.add(cw);
                }
            }
            return cntWrapperList;
        } catch(Exception e) {
            throw new AuraHandledException(e.getStackTraceString());
        }
    }
    public static Map<String,String> getNonSfCntEmailVsName(List<String> nonSfEmail){
        map<String,String> emailVsNameFromApi = new map<String,String>();
        String sNewConbody;
        try{
            if(nonSfEmail.size() > 0){
                //store email comma seprated string
                String nfes='';
                for(String s:nonSfEmail){
                    nfes+='"'+s+'",';
                }
                sNewConbody='{EmailAddress:{IN:['+nfes.removeEnd(',')+']}}';
            }
            String rgResponse = getRGApiResponse(accConQueryEndPoint,sNewConbody);
            List<Object> rawNewConObjLst = (List<Object>) JSON.deserializeUntyped(rgResponse);
            if(rawNewConObjLst.size()>0){
                for(Object o:rawNewConObjLst){
                    ConWrapper cw =  new ConWrapper();
                    Map<String, Object> row = (Map<String, Object>)o;
                    String removeBrack = '';
                    String finalStr = '';
                    if(String.valueOf(row.get('emailAddresses'))!=null){
                        removeBrack = String.valueOf(row.get('emailAddresses'));  
                        finalStr = removeBrack.substring(1,removeBrack.length()-1);
                    } 
                    emailVsNameFromApi.put(finalStr,String.valueOf(row.get('fullName')));
                }
            }
            return emailVsNameFromApi;  
        }catch(Exception e){
            throw new AuraHandledException(e.getStackTraceString()); 
        }
    }
    /*
* conEmail : contact email
* apiUrl : url of the api
* storeApiKey : apikey for authorization
*/
    @AuraEnabled
    public static String getRGApiResponse(String apiUrl,String requestBody){
        String jsonStr;
        try{
            System.debug('requestBody=='+requestBody);
            if(requestBody!=''){
                HttpRequest req = new HttpRequest();                
                req.setEndpoint(apiUrl);
                req.setMethod(storePost);
                req.setHeader(storeAuth,storeApiKey);
                req.setBody(requestBody);
                req.setHeader(storeCT, storeTPJson);
                req.setTimeout(120000);
                Http h = new Http();
                HttpResponse res = h.send(req);
                Integer iStatusCode = res.getStatusCode();
                if(iStatusCode == 200){//!=500 || iStatusCode!=401
                    jsonStr = res.getBody();
                    System.debug('jsonStr2191'+jsonStr);
                }else{
                    //IsApiError = true;//added by shivam
                    jsonStr = '[]';
                }
            }
            System.debug('jsonStr---'+jsonStr);
            return jsonStr;
        }catch(CalloutException e) {  
            // IsApiError = true;//added by shivam
            throw new AuraHandledException('An Error occurred in API');
        } catch(Exception e) {
            System.debug('1938=='+e.getLineNumber() +'Cause=='+e.getCause());
            throw new AuraHandledException('' + ' : <<' + e.getStackTraceString() + '>>');
        }
    }
    
    public class ReferencedPeopleWrapper{
        public String Name{get; set;}
        public String Title{get; set;}
        public String AccountId{get; set;}
        public String Last_Touch_Point{get; set;}
        public String OwnerId{get; set;}
        public Integer actCount{get; set;}
    }
    
    /*
* Purpose : Wrapper for Referenced Section information
*/
    public class InfoWrapper{
        @AuraEnabled public String name;            //Record Name
        @AuraEnabled public String nameRef;         //Record ID
        @AuraEnabled public Integer count;          //Associated activities count
        @AuraEnabled public List<String> actIdList; //Associated activities list
        @AuraEnabled public Boolean isAssociatedToDeal; //Stores true if company is associated to a deal else, false (For CR only)
        
        public InfoWrapper(String name, String nameRef, Integer count, List<String> actIdList, Boolean isAssociatedToDeal){
            this.name = name;
            this.nameRef = nameRef;
            this.count = count;
            this.actIdList = actIdList;
            this.isAssociatedToDeal = isAssociatedToDeal;
        }
    }
    /*
* Purpose : Wrapper for All Tas Interaction Section information
*/
    public Class TaskInteractionWrapper{
        public String Subject{get;set;}
        public String Description{get;set;}
        public String ReferencesName{get;set;} 
        public String OwnerName{get;set;}
        public String ActivityDate{get;set;}
    }
    public class ResponseWrapper{
        public List<InfoWrapper> compsRefInfo; //Referenced Section : CR Info
        public List<String> conIdList;         //Processed contact IDs info    [Feasible for Account record page]
        public String namespacePrefix;         //Namespaceprefix to be used
        public Map<String, sObject> conMap;    //Stores contact records info
        public List<ConWrapper> conInfoWrapper;//Contacts/Connections Section info
        public String conSecDynFieldHeader;    //Header for dynamic column in Contacts/Connections Section
        public String accId;                   //Account record ID     [Feasible for Account record page]
        public String contactEmail;            //Stores contact's email ID [Feasible for Contact record page]
        public String recName;                 //Record Name of current record page
        public List<String> actIdList;         //Used for Interactions Section & Contacts/Connections Section (W/O AA Field Consideration)
        public List<String> completeActIdList; //Used for Interactions Section & Contacts/Connections Section (With AA Field Consideration)
        public Boolean apiError;               //Used to identify api error if occured on load by Shivam
        public String recType;                 //Used to store record type of Account; Only valid for Account
        public List<String> parentConIdList;   //Used by Anshika to store the Contact of Fdr Contact
        public String conSecDynFieldHeader2;   //2nd Header for dynamic column in Fdr Acuity > Fdr Contact Section
        public String conSecDynFieldHeader3;   //3rd Header for dynamic column in Fdr Acuity > Fdr Contact Section
        // public List<DealTeamWrapper> dealInfoWrapper;  //Firm (PE) Acuity Deal Team Info Wrapper
        public String fieldApiName;			//API NAME of Fields in fundraising column
        public String filterValue;			    //filter value to filter on
        public String conSecDynFieldHeader4;   //4th Header for dynamic column in Fund Acuity > Fdr Section
        public String conSecDynFieldHeader5;   //5th Header for dynamic column in Fund Acuity > Fdr Section
        public String conSecDynFieldHeader6;   //6th Header for dynamic column in Fund Acuity > Fdr Section
        public String conSecDynFieldHeader7;   //7th Header for dynamic column in Fund Acuity > Fdr Section
        // public List<FundraisingWrapper> funInfoWrapper;//fundraising wrapper Section info
    }
    public Class Internal{
        public String name {get;set;}
        public Integer dealCount {get;set;}
        public String title {get;set;}
    }
    public Class External{
        public String name {get;set;}
        public String title {get;set;}
        public Integer dealCount {get;set;}
    }
    public class ConWrapper{
        public String recId;                   //Record ID
        public String name;                    //Record Name
        public String nameRef;                 //Record URL
        public String fieldInfo;               //Dynamic field info
        public Integer meetingCallCount;       //Meeting Call count
        public List<String> meetingCallIdList; //Associated meetings & calls IDs
        public Integer totalActCount;          //Total activities count
        public Integer emailCount;             //Email count
        public String email;                   //Email ID for RG data fetching
        public String downloadIcon;            //Download icon name (Blank if icon isnt to be displayed)
        public String mailboxId;               //Mailbox ID for RG data fetching
        public Integer dealCount;              //Deal count
        
        public List<String> dealIdList;        //Associated deals IDs
        public String lastInteractionDate;     //Last Interaction Date
        public String lastInteractionNote;     //Last Interaction Note
        public String lastInteractionId;       //Last Interaction ID
        public String lastInteractionType;     //Last Interaction Type
        public String frcId;                   //Record ID of Fundraising Contact [Fdr Acuity > Fdr Con Section Only]
        public String recId2;                  //Record ID
        public String name2;                   //Record Name of 2nd field
        public String nameRef2;                //Record URL of 2nd field
        public String fieldInfo2;              //Dynamic field info of 3rd field
        public String fieldInfo3;              //Dynamic field info of 4th field
        public String firmName;                //Company Name
        public String firmRef;					//company name reference
    }
    /*
* Purpose : Last Interaction Info Wrapper
*/
    public class LastInteractionInfo{
        public String lastInteractionDate;
        public String lastInteractionNote;
        public String lastInteractionId;
        public String lastInteractionType;
        
        public LastInteractionInfo(String lastInteractionDate, String lastInteractionNote, String lastInteractionId, String lastInteractionType){
            this.lastInteractionDate = lastInteractionDate;
            this.lastInteractionNote = lastInteractionNote;
            this.lastInteractionId = lastInteractionId;
            this.lastInteractionType = lastInteractionType;
        }
    }
    public class TaggedFirmWrapper{
        public String Name{get;set;}
        public String Participants{get;set;}
        public String User{get;set;}
        public String LastTouchpoint{get;set;}
    }
    
    
    /*
* Purpose : Wrapper for All Event Interaction Section information
*/
    public Class EventInteractionWrapper{
        public String Subject{get;set;}
        public String Description{get;set;}
        public String ReferencesName{get;set;} 
        public String WhatId{get;set;} 
        public String OwnerName{get;set;}
        public String ActivityDate{get;set;}
    }
    public Class DealWrapper{
        public string dealName{get;set;}
        public String dealTeam{get;set;}
    }
    public class DealsWrapper{
        public String name{get;set;}
        public String stage{get;set;}
        public String loginDate{get;set;}
        public String sourceFirm{get;set;}
        public String notes{get;set;}
    }
}