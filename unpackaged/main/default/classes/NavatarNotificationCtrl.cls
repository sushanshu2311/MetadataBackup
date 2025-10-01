/****************************************************************************************************
  
    ** Module Name : Connections 2.0 - Custom Notification
    ** Description : Used to handle all the DML & schema related funtionalities of Connections 2.0 Custom Notification.
    ** Throws : NA
    ** Calls : NA
    ** Organization : Navatar Group
    ** Product Name & Version : Connections 2.0
    ** Revision History:-
    ** Version    Date(YYYY-MM-DD)    Author         Description of Action
    ** 1.0        2022-08-02          Priyank        fetch and update event's records
       2.0        2022-09-19          Priyank        fetch  related contact records
       3.0        2022-09-21          Priyank        fixed whoid and Aa\A field related issue
       4.0        2022-09-26          Priyank        AA field related issue
       5.0        2022-11-18          Adil           Phase 2 changes
       6.0        2023-11-06          Anmol          Patch 3 CR (Bug # 00043018)

****************************************************************************************************/
public with sharing class NavatarNotificationCtrl {

    //Adding Namespace variable
    public static string strOrgSpacePrefix = CommonUtility_EdgeMenu.strOrgNameSpacePrefix;
    public static string strPackNameSpacePrefix = CommonUtility_EdgeMenu.strNameSpacePrefix;


    // fetch org domain
    /* Method: fetchOrgDomain
    ** Description: this method for fetch org domain */
    @AuraEnabled
    public static string fetchOrgDomain(){
        try{
            return URL.getSalesforceBaseUrl().toExternalForm();
        }catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    //added by pavani w.r.t security fix
    @AuraEnabled
    public static List<String> checkAccessibility(List<String> feildObj){
        String eventIsUpdateable = '';
        String taskIsUpdateable = '';
        List<String> accessList = new List<String>();
        for(String field:feildObj){
            if(field=='Event'){
                eventIsUpdateable=Schema.SObjectType.Event.isUpdateable()?'eventIsUpdateable':'';
                accessList.add(eventIsUpdateable);
            }
            if(field=='Task'){
                taskIsUpdateable= Schema.SObjectType.Task.isUpdateable()?'taskIsUpdateable':'';
                accessList.add(taskIsUpdateable);
            }
        }
        return accessList;
    }
    // bug No: 00031499
    // fetch related Cotact records
    /* Method: fetchContacts
    ** Description: this method for fetch all related contact for account */
    @AuraEnabled
    public static List<Contact> fetchContacts(string recordId){
        try{
            return [SELECT Id, Name, AccountId FROM Contact Where AccountId = :recordId];
        }catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    // fetch User records
    /* Method: checkNotificationVisibleForuser
    ** Description: this method for fetch user records to check if they have able to see notification popup */
    @AuraEnabled
    public static Boolean checkNotificationVisibleForuser(){
        try{
            boolean result;
//added StripInaccessible for w.r.t Security fix by pavani
            List<User> user = [SELECT Id, Snooze_Notification__c FROM User Where Id = :UserInfo.getUserId()];
            SObjectAccessDecision urDecision = Security.stripInaccessible(AccessType.READABLE,user);
            User u = (User)urDecision.getRecords()[0];
            if(u.isSet('Snooze_Notification__c') && (u.Snooze_Notification__c != null && u.Snooze_Notification__c != system.today()) 
            || u.Snooze_Notification__c == null){			 
                result = true;
            }else{
                result = false;
            }
            return result;
        }catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    // fetch event's data
    /* Method: fetchEventData
    ** Description: this method for fetch all events records for home page which need to add meeting notes for logged in User.*/
    @AuraEnabled
    public static List<NotificationWrapper> fetchEventData(){
        try{
            Map<String , Boolean> notificationSettings = NavatarUtility.isNotificationAllowed();
            Set<String> typeSet = new Set<String>();
            if(notificationSettings.containsKey('action') && notificationSettings.get('action')) {
                if(notificationSettings.containsKey('review') && notificationSettings.get('review')){
                    typeSet.addAll(NavatarConstants.NOTIFICATION_ACTION_TYPE_SET);
                }
                else{
                    typeSet.addAll(NavatarConstants.NOTIFICATION_ADD_NOTE_TYPE_SET);
                }
            } if(notificationSettings.containsKey('info') && notificationSettings.get('info')) {
                typeSet.addAll(NavatarConstants.NOTIFICATION_INFO_TYPE_SET);
            } 

            if(typeSet.isEmpty()) {   
                return null;
            }    

            Set<String> eventIds = new Set<String>();
            Set<String> taskIds = new Set<String>();
            Set<String> accIds = new Set<String>();
            Set<String> clipIds = new Set<String>();
            List<Navatar_Notification__c> notificationList = fetchUserNotification(typeSet , Userinfo.getUserId());

            Map<String , SObject> notificationDetailMap = new Map<String , SObject>();
            if(notificationList!=null && notificationList.size()>0){
            for(Navatar_Notification__c nn : notificationList){
                String objectAPIName = String.isNotBlank(nn.Record_ID__c) ? Id.valueOf(nn.Record_ID__c).getSObjectType().getDescribe().getName() : '';
                if(objectAPIName == 'Event'){
                    eventIds.add(nn.Record_ID__c);
                } else if (objectAPIName == 'Task'){
                    taskIds.add(nn.Record_ID__c);
                } else if (objectAPIName == 'Account'){
                    accIds.add(nn.Record_ID__c);
                } else if (objectAPIName == 'navpeII_dev18__Clip__c'){
                    clipIds.add(nn.Record_ID__c);
                }
            }
            }
            //added stripInaccessible by pavani w.r.t security fix
            for(SObject eve: Security.stripInaccessible(AccessType.READABLE, 
                                                    [SELECT Id, Subject, Description
                            FROM Event 
                                                    WHERE ID IN :eventIds]).getRecords()){
                if(!notificationDetailMap.containsKey(eve.Id) ){
                    notificationDetailMap.put(eve.Id, eve);
                }
            }
            //added stripInaccessible by pavani w.r.t security fix
            for(SObject tsk :Security.stripInaccessible(AccessType.READABLE,[SELECT Id, Subject, Description
                            FROM Task 
                            WHERE ID IN :taskIds]).getRecords()){
                if(!notificationDetailMap.containsKey(tsk.Id) ){
                    notificationDetailMap.put(tsk.Id, tsk);
                }
            }

            for(Account acc :[SELECT Id, Name
                            FROM Account 
                            WHERE ID IN :accIds
                            WITH SECURITY_ENFORCED]){
                if(!notificationDetailMap.containsKey(acc.Id) ){
                    notificationDetailMap.put(acc.Id, acc);
                }
            }

            for(navpeII_dev18__Clip__c clip :[SELECT Id, Name
                            FROM navpeII_dev18__Clip__c 
                            WHERE ID IN :clipIds
                            WITH SECURITY_ENFORCED]){
                if(!notificationDetailMap.containsKey(clip.Id) ){
                    notificationDetailMap.put(clip.Id, clip);
                }
            }

            List<NotificationWrapper> wrapperList = new List<NotificationWrapper>();
            if(notificationList!=null && notificationList.size()>0){
            for(Navatar_Notification__c n : notificationList){
                if(notificationDetailMap.containsKey(n.Record_ID__c)){
                    String objectAPIName = String.isNotBlank(n.Record_ID__c) ? Id.valueOf(n.Record_ID__c).getSObjectType().getDescribe().getName() : '';
                    NotificationWrapper wrapper = new NotificationWrapper();
                    if(n.Type__c == NavatarConstants.ADD_NOTE && objectAPIName == 'Event'){
                        Event e = (Event) notificationDetailMap.get(n.Record_ID__c);
						wrapper.subject = e.subject;
                            //checking if field is set w.r.t security fix
                            wrapper.description = e.isSet('Description')?e.description:'';
						wrapper.sortingOrder = 2;						 
                    } else if(n.Type__c == NavatarConstants.ADD_TAG && objectAPIName == 'Task'){
                        Task t = (Task) notificationDetailMap.get(n.Record_ID__c);
                            //checking if field is set w.r.t security fix
						wrapper.subject = t.subject;
                            wrapper.description = t.isSet('Description')?t.Description:'';
						wrapper.sortingOrder = 2;						 
                    } else if(n.Type__c == NavatarConstants.DEAL_ACTIVITY_INFO && objectAPIName == 'Event'){
                        Event e = (Event) notificationDetailMap.get(n.Record_ID__c);
                        wrapper.subject = e.subject;
						wrapper.description = NavatarConstants.DEAL_INFO_DESCRIPTION;
						wrapper.sortingOrder = 1;						 
                    } else if(n.Type__c == NavatarConstants.THEME_ACTIVITY_INFO && objectAPIName == 'Event'){
                        Event e = (Event) notificationDetailMap.get(n.Record_ID__c);
                        wrapper.subject = e.subject;
                        wrapper.description = NavatarConstants.THEME_INFO_DESCRIPTION;	
						wrapper.sortingOrder = 1;						  
                    } else if(n.Type__c == NavatarConstants.DEAL_ACTIVITY_INFO && objectAPIName == 'Task'){
                        Task t = (Task) notificationDetailMap.get(n.Record_ID__c);
                        wrapper.subject = t.subject;
						wrapper.description = NavatarConstants.DEAL_INFO_DESCRIPTION;
						wrapper.sortingOrder = 1;						 
                    } else if(n.Type__c == NavatarConstants.THEME_ACTIVITY_INFO && objectAPIName == 'Task'){
                        Task t = (Task) notificationDetailMap.get(n.Record_ID__c);
                        wrapper.subject = t.subject;
                        wrapper.description = NavatarConstants.THEME_INFO_DESCRIPTION;	
						wrapper.sortingOrder = 1;						  
                    } else if (n.Type__c == NavatarConstants.ACCOUNT_INFO && n.Type__c == NavatarConstants.ACCOUNT_INFO){
						Account acc = (Account) notificationDetailMap.get(n.Record_ID__c);
						wrapper.subject = acc.Name;
                        wrapper.description = NavatarConstants.ACCOUNT_INFO_DESCRIPTION;
						wrapper.sortingOrder = 1;						 
					} else if (n.Type__c == NavatarConstants.CLIP_INFO && n.Type__c == NavatarConstants.CLIP_INFO){
						Clip__c clip = (Clip__c) notificationDetailMap.get(n.Record_ID__c);
                        wrapper.subject = clip.Name;
                        wrapper.description =  NavatarConstants.CLIP_DESCRIPTION;
						wrapper.sortingOrder = 1;						 
					}

                    wrapper.type = n.Type__c;
                    wrapper.read = n.Read__c;
                    wrapper.id = n.id;
                    wrapper.recordId = n.Record_ID__c;
                    wrapper.recObjType = objectAPIName;
                    wrapperList.add(wrapper);
                }
            }
            }
            return wrapperList; 
        }
        catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }    
    }
     
   
    // fetch event's data
    /* Method: fetchEventDataforAccount
    ** Description: this method for fetch all events records which need to add meeting notes for logged in User.*/
    @AuraEnabled
    public static List<NotificationWrapper> fetchEventDataforRecord(String recordId){
        try{
            List<NotificationWrapper> wrapperList = new List<NotificationWrapper>();
            Map<String , Boolean> notificationSettings = NavatarUtility.isNotificationAllowed();
            Set<String> typeSet = new Set<String>();
            Map<Id , Event> eventMap = new Map<Id , Event>();
            Map<Id , Task> taskMap = new Map<Id , Task>();
            Set<String> eventIds = new Set<String>();
            Set<String> taskIds = new Set<String>();
            Set<String> accIds = new Set<String>();
            Set<String> conIds = new Set<String>();
            String recObjAPIName = String.isNotBlank(recordId) ? Id.valueOf(recordId).getSObjectType().getDescribe().getName() : '';

            if(recObjAPIName == 'Account'){                   
                Map<Id , Account> accountMap = new Map<Id , Account>();
                if(notificationSettings.containsKey('action') && notificationSettings.get('action')) {
                    if(notificationSettings.containsKey('review') && notificationSettings.get('review')){
                        typeSet.add(NavatarConstants.ADD_TAG);
                    }
                    typeSet.add(NavatarConstants.ADD_NOTE);
                } 
                if(notificationSettings.containsKey('info') && notificationSettings.get('info')) {
                    typeSet.add(NavatarConstants.ACCOUNT_INFO);
                }

                if(!typeSet.isEmpty()) {    
                    List<Navatar_Notification__c> notificationList = fetchUserNotification(typeSet , Userinfo.getUserId());
                    //added  by pavani w.r.t security fix
                    if(notificationList!=null && notificationList.size()>0){
                    for(Navatar_Notification__c nn : notificationList){
                        String objectAPIName = String.isNotBlank(nn.Record_ID__c) ? Id.valueOf(nn.Record_ID__c).getSObjectType().getDescribe().getName() : '';
                        if(objectAPIName == 'Event'){
                            eventIds.add(nn.Record_ID__c);
                        } else if (objectAPIName == 'Task'){
                            taskIds.add(nn.Record_ID__c);
                        } else if (objectAPIName == 'Account' && nn.Record_ID__c == recordId){
                            accIds.add(nn.Record_ID__c);
                        } 
                    }     
                    }     

                    Map<Id , Contact> childContacts = new Map<Id , Contact>();
                    for(Contact con : [select id from Contact WHERE AccountId = :recordId]) {
                        childContacts.put(con.id , con);
                        conIds.add(con.id);
                    }

                    accountMap = new Map<Id, Account>([SELECT Id, Name
                                                        FROM Account 
                                                        WHERE ID IN :accIds
                                                        WITH SECURITY_ENFORCED]);
                    //converted to Dynamic query by Pavani w.r.t Packaging issue fix
                     //added stripInaccessible by pavani w.r.t security fix
                    for(SObject e :Security.stripInaccessible(
                                       AccessType.READABLE,
                                       Database.query(String.escapeSingleQuotes('SELECT Id, Subject, Description, navpeII_dev18__Related_Associations__c, WhoId, (SELECT Id, EventId , Event.WhoId, RelationId FROM EventRelations WHERE RelationId IN :conIds) FROM Event WHERE ID IN :eventIds'))).getRecords()){
                          Event eve=(Event)e;
                          
                           if(eve.isSet('navpeII_dev18__Related_Associations__c') && String.isNotBlank(eve.navpeII_dev18__Related_Associations__c) && eve.navpeII_dev18__Related_Associations__c.contains(recordId)
                            ||(childContacts != null && eve.isSet('WhoId') && childContacts.containsKey(eve.WhoId)) 
                            || (eve.getSObjects('EventRelations') != null && eve.getSObjects('EventRelations').isEmpty())) {
                            eventMap.put(eve.Id , eve);
                        }  
                    }
                    //converted to Dynamic query by Pavani w.r.t Packaging issue fix
                    //added stripInaccessible by pavani w.r.t security fix
                    for(SObject t :Security.stripInaccessible(
                                       AccessType.READABLE,
                                       Database.query(String.escapeSingleQuotes('SELECT Id, Subject, Description, navpeII_dev18__Related_Associations__c, WhoId, (SELECT Id, TaskId , Task.WhoId, RelationId FROM TaskRelations WHERE RelationId IN :conIds) FROM Task WHERE ID IN :taskIds'))).getRecords()){
                        Task tsk = (Task)t;
                        if(tsk.isSet('navpeII_dev18__Related_Associations__c') && String.isNotBlank(tsk.navpeII_dev18__Related_Associations__c) && tsk.navpeII_dev18__Related_Associations__c.contains(recordId)
                        || (childContacts != null && tsk.isSet('WhoId') && childContacts.containsKey(tsk.WhoId)) 
                        || (tsk.getSObjects('TaskRelations') != null && !tsk.getSObjects('TaskRelations').isEmpty())) {
                            taskMap.put(tsk.Id, tsk);
                        }  
                    }
                    //added  by pavani w.r.t security fix
                    if(notificationList!=null && notificationList.size()>0){
                    for(Navatar_Notification__c n : notificationList){
                        String objectAPIName = String.isNotBlank(n.Record_ID__c) ? Id.valueOf(n.Record_ID__c).getSObjectType().getDescribe().getName() : '';
                        NotificationWrapper wrapper = new NotificationWrapper();
                        wrapper.type = n.Type__c;
						wrapper.sortingOrder = NavatarConstants.NOTIFICATION_ACTION_TYPE_SET.contains(n.Type__c)?2:1;																							 
                        wrapper.read = n.Read__c;
                        wrapper.id = n.id;
                        wrapper.recordId = n.Record_ID__c;
                        wrapper.recObjType = objectAPIName;
                        if(objectAPIName == 'Event' && eventMap.containsKey(n.Record_ID__c)){
                            Event e = (Event) eventMap.get(n.Record_ID__c);
                            wrapper.subject = e.subject;
                                wrapper.description = e.isSet('Description')?e.description:'';
                            wrapperList.add(wrapper);
                        } else if(objectAPIName == 'Task' && taskMap.containsKey(n.Record_ID__c)){
                            Task t = (Task) taskMap.get(n.Record_ID__c);
                            wrapper.subject = t.subject;
                                wrapper.description = t.isSet('Description')?t.description:'';
                            wrapperList.add(wrapper);
                        } else if (n.Record_ID__c == recordId ){
                            if(accountMap.containsKey(n.Record_ID__c)){
                                Account acc = accountMap.get(n.Record_ID__c);
                                wrapper.subject = acc.Name;
                                wrapper.description = NavatarConstants.ACCOUNT_INFO_DESCRIPTION;
                                wrapperList.add(wrapper);
                            }
                        } 
                    } 
                }
                }
            } else if(recObjAPIName == 'Contact'){
                if(notificationSettings.containsKey('action') && notificationSettings.get('action')) {
                    if(notificationSettings.containsKey('review') && notificationSettings.get('review')){
                        typeSet.add(NavatarConstants.ADD_TAG);
                    }
                    typeSet.add(NavatarConstants.ADD_NOTE);
                } 
                if(!typeSet.isEmpty()) {  
                    List<Navatar_Notification__c> notificationList = fetchUserNotification(typeSet , Userinfo.getUserId());
                    //added  by pavani w.r.t security fix
                    if(notificationList!=null && notificationList.size()>0){
                    for(Navatar_Notification__c nn : notificationList){
                        String objectAPIName = String.isNotBlank(nn.Record_ID__c) ? Id.valueOf(nn.Record_ID__c).getSObjectType().getDescribe().getName() : '';
                        if(objectAPIName == 'Event'){
                            eventIds.add(nn.Record_ID__c);
                        } else if (objectAPIName == 'Task'){
                            taskIds.add(nn.Record_ID__c);
                        } 
                    }     
                    }       
                    //added stripInaccessible by pavani w.r.t security fix
                    for(SObject e :Security.stripInaccessible(
                                       AccessType.READABLE,Database.query(String.escapeSingleQuotes('SELECT Id, Subject, Description, navpeII_dev18__Related_Associations__c, WhoId, (SELECT Id, EventId , Event.WhoId, RelationId FROM EventRelations WHERE RelationId = :recordId) FROM Event WHERE ID IN :eventIds'))).getRecords()){
                        Event eve= (Event)e;
                        if(( eve.isSet('WhoId') && eve.WhoId == recordId) || (eve.getSObjects('EventRelations') != null && !eve.getSObjects('EventRelations').isEmpty())) {
                            eventMap.put(eve.Id , eve);
                        }  
                    }
                    //added stripInaccessible by pavani w.r.t security fix
                    for(SObject t :Security.stripInaccessible(
                                       AccessType.READABLE,Database.query(String.escapeSingleQuotes('SELECT Id, Subject, Description, navpeII_dev18__Related_Associations__c, WhoId, (SELECT Id, TaskId , Task.WhoId, RelationId FROM TaskRelations WHERE  RelationId = :recordId) FROM Task WHERE ID IN :taskIds'))).getRecords()){
                        Task tsk= (Task)t;
                        if(tsk.isSet('WhoId') && (tsk.WhoId == recordId) || (tsk.getSObjects('TaskRelations') != null && !tsk.getSObjects('TaskRelations').isEmpty())) {
                            taskMap.put(tsk.Id, tsk);
                        }  
                    }
                    //added  by pavani w.r.t security fix
                    if(notificationList!=null && notificationList.size()>0){
                    for(Navatar_Notification__c n : notificationList){
                        String objectAPIName = String.isNotBlank(n.Record_ID__c) ? Id.valueOf(n.Record_ID__c).getSObjectType().getDescribe().getName() : '';
                        NotificationWrapper wrapper = new NotificationWrapper();
                        wrapper.type = n.Type__c;
						wrapper.sortingOrder = NavatarConstants.NOTIFICATION_ACTION_TYPE_SET.contains(n.Type__c)?2:1;																							 
                        wrapper.read = n.Read__c;
                        wrapper.id = n.id;
                        wrapper.recordId = n.Record_ID__c;
                        wrapper.recObjType = objectAPIName;
                        if(objectAPIName == 'Event' && eventMap.containsKey(n.Record_ID__c)){
                            Event e = (Event) eventMap.get(n.Record_ID__c);
                            wrapper.subject = e.subject;
                                wrapper.description = e.isSet('Description')?e.description:'';
                            wrapperList.add(wrapper);
                        } else if(objectAPIName == 'Task' && taskMap.containsKey(n.Record_ID__c)){
                            Task t = (Task) taskMap.get(n.Record_ID__c);
                            wrapper.subject = t.subject;
                                wrapper.description = t.isSet('Description')?t.description:'';
                            wrapperList.add(wrapper);
                        } 
                    } 
                }
                }
            }  else if(recObjAPIName == 'navpeII_dev18__Pipeline__c'){
                Map<String, String> dealAccountMap = new Map<String, String>();
                Map<Id , Account> accountMap = new Map<Id , Account>();
                if(notificationSettings.containsKey('action') && notificationSettings.get('action')) {
                    if(notificationSettings.containsKey('review') && notificationSettings.get('review')){
                        typeSet.add(NavatarConstants.ADD_TAG);
                    }
                    typeSet.add(NavatarConstants.ADD_NOTE);
                } 
                if(notificationSettings.containsKey('info') && notificationSettings.get('info')) {
                    typeSet.add(NavatarConstants.ACCOUNT_INFO);
                    typeSet.add(NavatarConstants.DEAL_ACTIVITY_INFO);
                }
                if(!typeSet.isEmpty()) {  
                    List<Navatar_Notification__c> notificationList = fetchUserNotification(typeSet , Userinfo.getUserId());
                    //added  by pavani w.r.t security fix
                    if(notificationList!=null && notificationList.size()>0){
                    for(Navatar_Notification__c nn : notificationList){
                        String objectAPIName = String.isNotBlank(nn.Record_ID__c) ? Id.valueOf(nn.Record_ID__c).getSObjectType().getDescribe().getName() : '';
                        if(objectAPIName == 'Event'){
                            eventIds.add(nn.Record_ID__c);
                        } else if (objectAPIName == 'Task'){
                            taskIds.add(nn.Record_ID__c);
                        } else if (objectAPIName == 'Account'){
                            accIds.add(nn.Record_ID__c);
                        } 
                    }     
                    }
                    accountMap = new Map<Id, Account>([SELECT Id, Name
                                                        FROM Account 
                                                        WHERE ID IN :accIds
                                                        WITH SECURITY_ENFORCED]);
                    //added stripInaccessible by pavani w.r.t security fix
                    for(SObject e :Security.stripInaccessible(
                                       AccessType.READABLE,[SELECT Id, Subject, Description, navpeII_dev18__Related_Associations__c
                                    FROM Event 
                                    WHERE ID IN :eventIds]).getRecords()){
                      Event eve= (Event)e;
                        if(eve.isSet('navpeII_dev18__Related_Associations__c') && String.isNotBlank(eve.navpeII_dev18__Related_Associations__c) && eve.navpeII_dev18__Related_Associations__c.contains(recordId)) {
                            eventMap.put(eve.Id, eve);
                        }  
                    }
                    //added stripInaccessible by pavani w.r.t security fix
                    for(SObject t :Security.stripInaccessible(
                                       AccessType.READABLE,[SELECT Id, Subject, Description, navpeII_dev18__Related_Associations__c
                                    FROM Task 
                                    WHERE ID IN :taskIds]).getRecords()){
                        Task tsk= (Task)t;
                        if(tsk.isSet('navpeII_dev18__Related_Associations__c') && String.isNotBlank(tsk.navpeII_dev18__Related_Associations__c) && tsk.navpeII_dev18__Related_Associations__c.contains(recordId)) {
                            taskMap.put(tsk.Id, tsk);
                        }  
                    }
                    //added access check pavani w.r.t security fix
                    if(Schema.SObjectType.navpeII_dev18__Pipeline__c.isAccessible() && 
                    Schema.SObjectType.navpeII_dev18__Pipeline__c.fields.navpeII_dev18__Company__c.isAccessible()){
                        for(navpeII_dev18__Pipeline__c deal :[SELECT Id, navpeII_dev18__Company__c 
                                                    FROM navpeII_dev18__Pipeline__c 
                                                    WHERE navpeII_dev18__Company__c IN :accIds
                                                WITH SECURITY_ENFORCED]){                              
                            dealAccountMap.put(deal.id , deal.navpeII_dev18__Company__c);
                    }
                    }
                    //added  by pavani w.r.t security fix
                    if(notificationList!=null && notificationList.size()>0){
                    for(Navatar_Notification__c n : notificationList){
                        String objectAPIName = String.isNotBlank(n.Record_ID__c) ? Id.valueOf(n.Record_ID__c).getSObjectType().getDescribe().getName() : '';
                        NotificationWrapper wrapper = new NotificationWrapper();
                        wrapper.type = n.Type__c;
						wrapper.sortingOrder = NavatarConstants.NOTIFICATION_ACTION_TYPE_SET.contains(n.Type__c)?2:1;																							 
                        wrapper.read = n.Read__c;
                        wrapper.id = n.id;
                        wrapper.recordId = n.Record_ID__c;
                        wrapper.recObjType = objectAPIName;
                        if(objectAPIName == 'Event' && eventMap.containsKey(n.Record_ID__c)){
                            Event e = (Event) eventMap.get(n.Record_ID__c);
                            wrapper.subject = e.subject;
                                wrapper.description = typeSet.contains(n.Type__c) && n.Type__c==NavatarConstants.DEAL_ACTIVITY_INFO?NavatarConstants.DEAL_INFO_DESCRIPTION:e.isSet('Description')?e.description:'';
                            wrapperList.add(wrapper);
                        } else if(objectAPIName == 'Task' && taskMap.containsKey(n.Record_ID__c)){
                            Task t = (Task) taskMap.get(n.Record_ID__c);
                            wrapper.subject = t.subject;
                                wrapper.description = typeSet.contains(n.Type__c) && n.Type__c==NavatarConstants.DEAL_ACTIVITY_INFO?NavatarConstants.DEAL_INFO_DESCRIPTION:t.isSet('Description')?t.description:'';
                            wrapperList.add(wrapper);
                            } else if (objectAPIName == 'Account' && dealAccountMap!=null
                                && dealAccountMap.containsKey(recordId) && dealAccountMap.get(recordId) == n.Record_ID__c){
                            if(accountMap.containsKey(n.Record_ID__c)){
                                Account acc = accountMap.get(n.Record_ID__c);
                                wrapper.subject = acc.Name;
                                wrapper.description = NavatarConstants.ACCOUNT_INFO_DESCRIPTION;
                                wrapperList.add(wrapper);
                            }
                        } 
                    } 
                }
                }
            }   else if(recObjAPIName == 'navpeII_dev18__Theme__c'){
                if(notificationSettings.containsKey('action') && notificationSettings.get('action')) {
                    if(notificationSettings.containsKey('review') && notificationSettings.get('review')){
                        typeSet.add(NavatarConstants.ADD_TAG);
                    }
                    typeSet.add(NavatarConstants.ADD_NOTE);
                } 
                if(notificationSettings.containsKey('info') && notificationSettings.get('info')) {
                    typeSet.add(NavatarConstants.THEME_ACTIVITY_INFO);
                }
                if(!typeSet.isEmpty()) {  
                    List<Navatar_Notification__c> notificationList = fetchUserNotification(typeSet , Userinfo.getUserId());
                    //added  by pavani w.r.t security fix
                    if(notificationList!=null && notificationList.size()>0){
                    for(Navatar_Notification__c nn : notificationList){
                        String objectAPIName = String.isNotBlank(nn.Record_ID__c) ? Id.valueOf(nn.Record_ID__c).getSObjectType().getDescribe().getName() : '';
                        if(objectAPIName == 'Event'){
                            eventIds.add(nn.Record_ID__c);
                        } else if (objectAPIName == 'Task'){
                            taskIds.add(nn.Record_ID__c);
                        } 
                    }     
                    }    
                    //added stripInaccessible by pavani w.r.t security fix
                    for(SObject e :Security.stripInaccessible(
                                       AccessType.READABLE,[SELECT Id, Subject, Description, navpeII_dev18__Related_Associations__c
                                    FROM Event 
                                    WHERE ID IN :eventIds]).getRecords()){
                        Event eve= (Event)e;
                        if(eve.isSet('navpeII_dev18__Related_Associations__c') && String.isNotBlank(eve.navpeII_dev18__Related_Associations__c) && eve.navpeII_dev18__Related_Associations__c.contains(recordId)) {
                            eventMap.put(eve.Id , eve);
                        }  
                    }
                    //added stripInaccessible by pavani w.r.t security fix
                    for(SObject t :Security.stripInaccessible(
                                       AccessType.READABLE,[SELECT Id, Subject, Description, navpeII_dev18__Related_Associations__c
                                    FROM Task 
                                    WHERE ID IN :taskIds]).getRecords()){
                        Task tsk= (Task)t;
                        if(tsk.isSet('navpeII_dev18__Related_Associations__c') && String.isNotBlank(tsk.navpeII_dev18__Related_Associations__c) && tsk.navpeII_dev18__Related_Associations__c.contains(recordId)) {
                            taskMap.put(tsk.Id, tsk);
                        }  
                    }
                    //added  by pavani w.r.t security fix
                    if(notificationList!=null && notificationList.size()>0){
                    for(Navatar_Notification__c n : notificationList){
                        String objectAPIName = String.isNotBlank(n.Record_ID__c) ? Id.valueOf(n.Record_ID__c).getSObjectType().getDescribe().getName() : '';
                        NotificationWrapper wrapper = new NotificationWrapper();
                        wrapper.type = n.Type__c;
						wrapper.sortingOrder = NavatarConstants.NOTIFICATION_ACTION_TYPE_SET.contains(n.Type__c)?2:1;																						 
                        wrapper.read = n.Read__c;
                        wrapper.id = n.id;
                        wrapper.recordId = n.Record_ID__c;
                        wrapper.recObjType = objectAPIName;
                        if(objectAPIName == 'Event' && eventMap.containsKey(n.Record_ID__c)){
                            Event e = (Event) eventMap.get(n.Record_ID__c);
                            wrapper.subject = e.subject;
                                wrapper.description = typeSet.contains(n.Type__c) && n.Type__c==NavatarConstants.THEME_ACTIVITY_INFO?NavatarConstants.THEME_INFO_DESCRIPTION:e.isSet('Description')?e.description:'';
                            wrapperList.add(wrapper);
                        } else if(objectAPIName == 'Task' && taskMap.containsKey(n.Record_ID__c)){
                            Task t = (Task) taskMap.get(n.Record_ID__c);
                            wrapper.subject = t.subject;
                                wrapper.description = typeSet.contains(n.Type__c) && n.Type__c==NavatarConstants.THEME_ACTIVITY_INFO?NavatarConstants.THEME_INFO_DESCRIPTION:t.isSet('Description')?t.description:'';
                            wrapperList.add(wrapper);
                        } 
                    } 
                }
                }
            }  else if(recObjAPIName == 'navpeII_dev18__Fund__c' || recObjAPIName ==  'navpeII_dev18__Fundraising__c'){
                Set<String> fundRaisingSet = new Set<String>();
                if(notificationSettings.containsKey('action') && notificationSettings.get('action')) {
                    if(notificationSettings.containsKey('review') && notificationSettings.get('review')){
                     typeSet.add(NavatarConstants.ADD_TAG);
                    }
                    typeSet.add(NavatarConstants.ADD_NOTE);
                } 
                if(!typeSet.isEmpty()) {  
                    List<Navatar_Notification__c> notificationList = fetchUserNotification(typeSet , Userinfo.getUserId());
                    //added  by pavani w.r.t security fix
                    if(notificationList!=null && notificationList.size()>0){
                    for(Navatar_Notification__c nn : notificationList){
                        String objectAPIName = String.isNotBlank(nn.Record_ID__c) ? Id.valueOf(nn.Record_ID__c).getSObjectType().getDescribe().getName() : '';
                        if(objectAPIName == 'Event'){
                            eventIds.add(nn.Record_ID__c);
                        } else if (objectAPIName == 'Task'){
                            taskIds.add(nn.Record_ID__c);
                        } 
                    }     
                    }     
                    //added stripInaccessible by pavani w.r.t security fix
                    if(recObjAPIName == 'navpeII_dev18__Fund__c' && Schema.SObjectType.navpeII_dev18__Fund__c.isAccessible()
                        && Schema.SObjectType.navpeII_dev18__Fundraising__c.isAccessible() && 
                        Schema.SObjectType.navpeII_dev18__Fundraising__c.fields.navpeII_dev18__Fund_Name__c.isAccessible()){
                        for(navpeII_dev18__Fundraising__c fr :[SELECT Id, navpeII_dev18__Fund_Name__c 
                                                        FROM navpeII_dev18__Fundraising__c 
                                                        WHERE navpeII_dev18__Fund_Name__c = :recordId
                                                        WITH SECURITY_ENFORCED]){                              
                            fundRaisingSet.add(fr.id);
                        }
                    }
                    //added stripInaccessible by pavani w.r.t security fix
                    for(SObject e :Security.stripInaccessible(
                                       AccessType.READABLE,[SELECT Id, Subject, Description, Related_Associations__c
                                    FROM Event 
                                    WHERE ID IN :eventIds]).getRecords()){
                        Event eve= (Event)e;
                        if(eve.isSet('Related_Associations__c') && String.isNotBlank(eve.Related_Associations__c)){              
                            if(eve.Related_Associations__c.contains(recordId)) {
                                eventMap.put(eve.Id , eve);
                            }
                            if(fundRaisingSet.size()>0){
                            for(String key : fundRaisingSet) {
                                if(eve.Related_Associations__c.contains(key)) {
                                    eventMap.put(eve.Id, eve);
                                }
                            }
                        }    
                    }
                    }
                    //added stripInaccessible by pavani w.r.t security fix
                    for(SObject t :Security.stripInaccessible(
                                       AccessType.READABLE,[SELECT Id, Subject, Description, Related_Associations__c
                                    FROM Task 
                                    WHERE ID IN :taskIds]).getRecords()){
                        Task tsk= (Task)t;
                        if(tsk.isSet('Related_Associations__c') && String.isNotBlank(tsk.Related_Associations__c)){              
                            if(tsk.Related_Associations__c.contains(recordId)) {
                                taskMap.put(tsk.Id, tsk);
                            }
                            if(fundRaisingSet.size()>0){
                            for(String key : fundRaisingSet) {
                                if(tsk.Related_Associations__c.contains(key)) {
                                    taskMap.put(tsk.Id , tsk);
                                }
                            }
                        }    
                    }
                    }
                    //added  by pavani w.r.t security fix
                    if(notificationList!=null && notificationList.size()>0){
                    for(Navatar_Notification__c n : notificationList){
                        String objectAPIName = String.isNotBlank(n.Record_ID__c) ? Id.valueOf(n.Record_ID__c).getSObjectType().getDescribe().getName() : '';
                        NotificationWrapper wrapper = new NotificationWrapper();
                        wrapper.type = n.Type__c;
						wrapper.sortingOrder = NavatarConstants.NOTIFICATION_ACTION_TYPE_SET.contains(n.Type__c)?2:1;																							 
                        wrapper.read = n.Read__c;
                        wrapper.id = n.id;
                        wrapper.recordId = n.Record_ID__c;
                        wrapper.recObjType = objectAPIName;
						if(objectAPIName == 'Event' && eventMap.containsKey(n.Record_ID__c)){
                            Event e = (Event) eventMap.get(n.Record_ID__c);
                            wrapper.subject = e.subject;
                                wrapper.description = e.isSet('Description')?e.description:'';
                            wrapperList.add(wrapper);
                        } else if(objectAPIName == 'Task' && taskMap.containsKey(n.Record_ID__c)){
                            Task t = (Task) taskMap.get(n.Record_ID__c);
                            wrapper.subject = t.subject;
                                wrapper.description = t.isSet('Description')?t.description:'';
                            wrapperList.add(wrapper);
                        } 
                    } 
                }
            }  
            }  
            return wrapperList; 
        }
        catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }      
    } 
   
    // utility method for fetching user notification
    /* Method: fetchUserNotification
    ** Description: this method for fetching user notification 
    //added FLS check by pavani w.r.t security fix*/
    public static List<Navatar_Notification__c> fetchUserNotification(Set<String> typeSet, String userId){
        
        if(typeSet == null && Schema.SObjectType.Navatar_Notification__c.isAccessible() &&
        Schema.SObjectType.Navatar_Notification__c.fields.Record_ID__c.isAccessible() &&
        Schema.SObjectType.Navatar_Notification__c.fields.Type__c.isAccessible() &&
        Schema.SObjectType.Navatar_Notification__c.fields.User__c.isAccessible() &&
        Schema.SObjectType.Navatar_Notification__c.fields.Read__c.isAccessible()) {
            return  [SELECT Id , Name , Record_ID__c, Type__c, User__c, Read__c
                    FROM Navatar_Notification__c 
                    WHERE User__c = :userId 
                    ORDER BY CreatedDate DESC];
        } else if(Schema.SObjectType.Navatar_Notification__c.isAccessible() &&
        Schema.SObjectType.Navatar_Notification__c.fields.Record_ID__c.isAccessible() &&
        Schema.SObjectType.Navatar_Notification__c.fields.Type__c.isAccessible() &&
        Schema.SObjectType.Navatar_Notification__c.fields.User__c.isAccessible() &&
        Schema.SObjectType.Navatar_Notification__c.fields.Read__c.isAccessible()) {
            return  [SELECT Id , Name , Record_ID__c, Type__c, User__c, Read__c
                    FROM Navatar_Notification__c 
                    WHERE User__c = :userId
                    AND  Type__c IN :typeSet
                    ORDER BY Read__c ASC,CreatedDate DESC];
        }else {
            return null;
        }
    }    
    // snooze notification for today
    /* Method: snoozeNotificationForToday
    ** Description: this method for snooze notification pop up for a day */
    @AuraEnabled
    public static void snoozeNotificationForToday(){
        try{
            User u = New User();
            u.Id = UserInfo.getUserId();
            u.Snooze_Notification__c = system.today();
            
            if(Schema.getGlobalDescribe().get('User').getDescribe().fields.getMap().get('navpeII_dev18__Snooze_Notification__c').getDescribe().isUpdateable()){
                Database.update(u, false);
            }
            
        }catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        
    }

    // dismiss notification
    /* Method: dismisNotification
    ** Description: this method for deleting notification on which dismiss button is clicked */
    @AuraEnabled
    public static Boolean dismisNotification(String notificationId){
        try{
           if(Schema.getGlobalDescribe().get('navpeII_dev18__Navatar_Notification__c').getDescribe().isDeletable()){
                delete [select id from Navatar_Notification__c WHERE Id = :notificationId];
                return true;
           } else {
                return false;
           }    
        }catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }    
    }


    
    public class NotificationWrapper{
        @AuraEnabled public String subject;
        @AuraEnabled public String description;
        @AuraEnabled public String type;
        @AuraEnabled public String recordId;
        @AuraEnabled public String id;
        @AuraEnabled public Boolean read;
        @AuraEnabled public String recObjType;
		@AuraEnabled public Integer sortingOrder;									 
    }
}