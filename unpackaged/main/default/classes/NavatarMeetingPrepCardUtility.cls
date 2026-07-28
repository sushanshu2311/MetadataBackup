/****************************************************************************************************
** Module Name : Meeting Prep Card Utility 1.0 
** Description : Used to Send Error emails to users and admins.
** Organization : Navatar Group
** Product Name & Version : PE Agentforce Baseline 1.0
** Revision History:-
** Version    Date(YYYY-MM-DD)    Author            Description of Action
** 1.0        2026-02-05          Salauddin Sheikh  PE Agentforce Baseline Phase 1
****************************************************************************************************/
public with sharing class NavatarMeetingPrepCardUtility {
    /**
     * Sends an email to all active System Administrators with the given subject and message.
     * @param subject The subject of the email
     * @param body The plain text body of the email
     */
    public static void sendErrorEmailToAdmins(String subject, String body) {
        //Added try catch for R-0000008518
        try{
            List<User> admins = [SELECT Id, Email FROM User WHERE Profile.Name = 'System Administrator' AND IsActive = true AND Email != null WITH USER_MODE];
            List<String> adminEmails = new List<String>();
            for (User u : admins) {
                adminEmails.add(u.Email);
            }
            if (!adminEmails.isEmpty()) {
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                mail.setToAddresses(adminEmails);
                mail.setSubject(subject);
                mail.setHtmlBody(body);
                Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{mail});
            }
        } catch (Exception e) {
            System.debug('Error sending email to admins: ' + e.getMessage());
        }
    }

    /**
     * Sends an email to all active Users with the given subject and message.
     * @param subject The subject of the email
     * @param body The plain text body of the email
     */
    public static void sendErrorEmailToUsers(String subject, String body, Set<Id> userIds) {
        try {
            List<User> users = [SELECT Id, Email FROM User WHERE Id IN :userIds AND IsActive = true AND Email != null WITH USER_MODE];
            List<String> userEmails = new List<String>();
            for (User u : users) {
                userEmails.add(u.Email);
            }

            List<User> admins = [SELECT Id, Email FROM User WHERE Profile.Name = 'System Administrator' AND IsActive = true AND Email != null WITH USER_MODE];
            for (User u : admins) {
                userEmails.add(u.Email);
            }
            if (!userEmails.isEmpty()) {
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                mail.setToAddresses(userEmails);
                mail.setSubject(subject);
                mail.setHtmlBody(body);
                Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{mail});
            }
        } catch (Exception e) {
            System.debug('Error sending email to users: ' + e.getMessage());
        }
        
    }

    /**
     * Sends an email to all active Users with the given subject and message.
     * @param subject The subject of the email
     * @param body The plain text body of the email
     */
    public static void sendErrorEmailToEmailList(String subject, String body, List<String> emailAddresses) {
        
        List<User> admins = [SELECT Id, Email FROM User WHERE Profile.Name = 'System Administrator' AND IsActive = true AND Email != null WITH USER_MODE];
        for (User u : admins) {
            emailAddresses.add(u.Email);
        }
        
        try {
            if (!emailAddresses.isEmpty()) {
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                mail.setToAddresses(emailAddresses);
                mail.setSubject(subject);
                mail.setHtmlBody(body);
                Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{mail});
            }
        } catch (Exception e) {
            System.debug('Error sending email to users: ' + e.getMessage());
        }
        
    }

            /**
     * Sends an email to all active Users with the given subject and message.
     * @param subject The subject of the email
     * @param body The plain text body of the email
     */
    public static void sendErrorEmailToLoggedInUser(String subject, String body) {
        try {
            List<User> users = [SELECT Id, Email FROM User WHERE Id =: UserInfo.getUserId() AND IsActive = true AND Email != null WITH USER_MODE];
            List<String> userEmails = new List<String>();
            for (User u : users) {
                userEmails.add(u.Email);
            }
            if (!userEmails.isEmpty()) {
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                mail.setToAddresses(userEmails);
                mail.setSubject(subject);
                mail.setHtmlBody(body);
                Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{mail});
            }
        } catch (Exception e) {
            System.debug('Error sending email to users: ' + e.getMessage());
        }
        
    }

     
    /**
     * Helper method to call a prompt template by name and input record Id
     */
    public static String callPromptTemplate(String templateName, Id recordId, String topActivitiesJson) {
        // Build prompt input map
        Map<String, ConnectApi.WrappedValue> promptInput = new Map<String, ConnectApi.WrappedValue>();
        Map<String,String> recordMap = new Map<String,String>();
        recordMap.put('id', recordId);
        ConnectApi.WrappedValue recordWrappedValue = new ConnectApi.WrappedValue();
        recordWrappedValue.value = recordMap;
        // Use correct input variable name based on template
        if (templateName == 'Navatar_Contact_Recent_Interactions') {
            promptInput.put('Input:Contact', recordWrappedValue);
            ConnectApi.WrappedValue topActivitiesWrappedValue = new ConnectApi.WrappedValue();
            topActivitiesWrappedValue.value = topActivitiesJson;
            promptInput.put('Input:Recent_Interactions', topActivitiesWrappedValue);
        }else if (templateName == 'Navatar_Firm_Recent_Interactions') {
            promptInput.put('Input:Account', recordWrappedValue);
            ConnectApi.WrappedValue topActivitiesWrappedValue = new ConnectApi.WrappedValue();
            topActivitiesWrappedValue.value = topActivitiesJson;
            promptInput.put('Input:Recent_Interactions', topActivitiesWrappedValue); 
        }
        else if (templateName == 'Navatar_Contact_Overview') {
            promptInput.put('Input:Contact', recordWrappedValue);
        }
        else if(templateName == 'Navatar_Deal_Recent_Interactions') {
            promptInput.put('Input:Deal', recordWrappedValue);
            ConnectApi.WrappedValue topActivitiesWrappedValue = new ConnectApi.WrappedValue();
            topActivitiesWrappedValue.value = topActivitiesJson;
            promptInput.put('Input:Recent_Interactions', topActivitiesWrappedValue);
        }
        else if(templateName == 'Navatar_Deal_Overview') {
            promptInput.put('Input:Deal', recordWrappedValue);
        }
        else if (templateName == 'Navatar_Firm_Overview') {
            promptInput.put('Input:Firm', recordWrappedValue);
        }

        ConnectApi.EinsteinPromptTemplateGenerationsInput input = new ConnectApi.EinsteinPromptTemplateGenerationsInput();
        input.inputParams = promptInput;
        input.isPreview = false;
        input.additionalConfig = new ConnectApi.EinsteinLlmAdditionalConfigInput();
        input.additionalConfig.applicationName = 'PromptBuilderPreview';

        try {
            ConnectApi.EinsteinPromptTemplateGenerationsRepresentation result = ConnectApi.EinsteinLLM.generateMessagesForPromptTemplate(templateName, input);
            if(result.generationErrors != null && !result.generationErrors.isEmpty()) {
                system.debug('Prompt generation errors: ' +result.generationErrors);
                return 'Error generating prompt: ' + result.generationErrors;
            }
            else if (result != null && result.generations != null && !result.generations.isEmpty()) {
                return result.generations[0].text;
            } else {
                system.debug('Prompt generation errors: ' +result);
                return 'No generations returned from the prompt.';
            }
        } catch (Exception e) {
            return 'Error calling prompt: ' + e.getMessage();
        }
    }
    public static Map<Id,List<Map<String, Object>>> getFirm5RecentInteractions(Map<Id,Set<Id>> accountToContactIds){  
        Datetime now = System.now();  
        Map<Id,Set<Id>> accountInteractions = new Map<Id, Set<Id>>();
        Map<Id,Set<Id>> accountInteractionsWithWhatId = new Map<Id, Set<Id>>();
        Map<Id,List<Map<String, Object>>> accountActivityList = new Map<Id, List<Map<String, Object>>>();
        Map<Id,List<Map<String, Object>>> accountTopActivityList = new Map<Id, List<Map<String, Object>>>();
        Set<Id> allInteractionIds = new Set<Id>();
        List<Map<String, Object>> activityList = new List<Map<String, Object>>();
        List<String> associationFilters = new List<String>();
        
        for (Id accountId : accountToContactIds.keySet()) {
            associationFilters.add('navpeII__Related_Associations__c LIKE \'%' + String.escapeSingleQuotes(accountId) + '%\'');
            Set<Id> interactionIds = queryRecentInteractions(accountToContactIds.get(accountId));
            allInteractionIds.addAll(interactionIds);
            accountInteractions.put(accountId, interactionIds);
        }
        String associationWhere = String.join(associationFilters, ' OR ');
        // bug 00051737 fixed by Sudhanshu
        String eventQuery ='SELECT Id, Subject, EventSubtype, ActivityDate, StartDateTime, Description, Owner.Name, navpeII__Related_Associations__c,' +
        '(SELECT RelationId, Relation.Name FROM EventRelations) ' +
        'FROM Event ' +
        'WHERE (Id IN :allInteractionIds OR ' + associationWhere + ') ' +
        'AND StartDateTime <= :now ' +
        'AND IsArchived = false ' +
        'WITH USER_MODE ' +
        'ORDER BY CreatedDate DESC';//Bug Fixing 00051899 FIltering ListEmail Task Salauddin 08042026
        System.debug('eventQuery '+eventQuery);
            // Query Events
        for (Event ev : Database.query(eventQuery)) {//Bug Fixing 00051562 Salauddin 05032026
            Long activityDateAsLong = null;
            if (ev.StartDateTime != null) {
                activityDateAsLong = ev.StartDateTime.getTime();
            }
            // Bug 00051112 fixed by Sudhanshu
            Map<String, Object> rec = new Map<String, Object>{
                'Id' => ev.Id,
                'Subject' => ev.Subject,
                'ActivityDate' => ev.ActivityDate,
                'Description' => ev.Description,
                'OwnerName' => ev.Owner.Name,
                'Subtype' => ev.EventSubtype != null ? ev.EventSubtype : 'Event',
                'activitydateaslong' => activityDateAsLong
            };
            List<String> participants = new List<String>();
            participants.add(ev.Owner.Name);    // Bug 00051681 Fixed by Sudhanshu
            for (EventRelation evr : ev.EventRelations) {
                // bug 00051737 fixed by Sudhanshu
                if(String.valueOf(evr.RelationId).startsWith('003') || String.valueOf(evr.RelationId).startsWith('005')) // Check if RelationId starts with '003' (Contact) or '005' (User)
                {
                    participants.add(evr.Relation.Name);
                }  
                
                
            }                                   
            rec.put('Participants', participants);
            activityList.add(rec); 
            //Bug Fixing 00051558 Salauddin 27022026 
            if(String.isNotBlank(ev.navpeII__Related_Associations__c)){
                List<String> relIds = ev.navpeII__Related_Associations__c.split(',');
                
                for(String relId : relIds){
                    String trimmedId = relId.trim();

                    // validate id length before casting
                    if(trimmedId.length() < 15){
                        continue;
                    }

                    Id recId;
                    try{
                        recId = (Id)trimmedId;
                    }catch(Exception e){
                        continue;
                    }

                    // Only allow Accounts present in accountToContactIds
                    if(accountToContactIds.containsKey(recId)){
                        if(!accountInteractions.containsKey(recId)){
                            accountInteractions.put(recId, new Set<Id>());
                        }

                        accountInteractions.get(recId).add(ev.Id);
                    }
                }
            }
        }
        // bug 00051737 fixed by Sudhanshu
        String taskQuery ='SELECT Id, Subject, TaskSubtype, ActivityDate, Description, Owner.Name, navpeII__Related_Associations__c,' +
        '(SELECT RelationId, Relation.Name FROM TaskRelations) ' +
        'FROM Task ' +
        'WHERE (Id IN :allInteractionIds OR ' + associationWhere + ') ' +
        'AND ActivityDate <= Today ' +
        'AND IsArchived = false ' +
        'WITH USER_MODE ' +
        'ORDER BY CREATEDDATE DESC';
        for (Task ev : Database.query(taskQuery)) {//Bug Fixing 00051562 Salauddin 05032026
            Long activityDateAsLong = null;
            if (ev.ActivityDate != null) {
                DateTime dt = DateTime.newInstance(ev.ActivityDate, Time.newInstance(0, 0, 0, 0));
                activityDateAsLong = dt.getTime();
            }
            // Bug 00051112 fixed by Sudhanshu
            Map<String, Object> rec = new Map<String, Object>{
                'Id' => ev.Id,
                'Subject' => ev.Subject,
                'ActivityDate' => ev.ActivityDate,
                'Description' => ev.Description,
                'OwnerName' => ev.Owner.Name,
                'Subtype' => ev.TaskSubtype != null ? ev.TaskSubtype : 'Task',
                'activitydateaslong' => activityDateAsLong
            };
            List<String> participants = new List<String>();
            participants.add(ev.Owner.Name); // Include Task Owner as a participant
            for (TaskRelation evr : ev.TaskRelations) {
                // bug 00051737 fixed by Sudhanshu
                if(String.valueOf(evr.RelationId).startsWith('003') || String.valueOf(evr.RelationId).startsWith('005')) // Check if RelationId starts with '003' (Contact) or '005' (User)
                {
                    participants.add(evr.Relation.Name);
                }
                
                
            }                                   
            rec.put('Participants', participants);
            activityList.add(rec);  
            //Bug Fixing 00051558 Salauddin 27022026
            if(String.isNotBlank(ev.navpeII__Related_Associations__c)){
                List<String> relIds = ev.navpeII__Related_Associations__c.split(',');
                
                for(String relId : relIds){
                    String trimmedId = relId.trim();

                    // validate id length before casting
                    if(trimmedId.length() < 15){
                        continue;
                    }

                    Id recId;
                    try{
                        recId = (Id)trimmedId;
                    }catch(Exception e){
                        continue;
                    }

                    // Only allow Accounts present in accountToContactIds
                    if(accountToContactIds.containsKey(recId)){
                        if(!accountInteractions.containsKey(recId)){
                            accountInteractions.put(recId, new Set<Id>());
                        }

                        accountInteractions.get(recId).add(ev.Id);
                    }
                }
            }         
        }
        
        
        for (Map<String, Object> activity : activityList) {
            for (Id accId : accountInteractions.keySet()) {
                if (accountInteractions.get(accId).contains((Id)activity.get('Id'))) {
                    if (!accountActivityList.containsKey(accId)) {
                        accountActivityList.put(accId, new List<Map<String, Object>>());
                    }
                    accountActivityList.get(accId).add(activity);
                }
            }
        }
        for (Map<String, Object> activity : activityList) {
            for (Id accId : accountInteractionsWithWhatId.keySet()) {
                if (accountInteractionsWithWhatId.get(accId).contains((Id)activity.get('Id'))) {
                    if (!accountActivityList.containsKey(accId)) {
                        accountActivityList.put(accId, new List<Map<String, Object>>());
                    }
                    accountActivityList.get(accId).add(activity);
                    break;
                }
            }
        }
        for (Id accId : accountActivityList.keySet()) {
            sortByActivityDateDesc(accountActivityList.get(accId));
            
        }
        for (Id accId : accountActivityList.keySet()) {
            List<Map<String, Object>> activityLists = accountActivityList.get(accId);
            Integer limitCount = Math.min(5, activityLists.size());                
            List<Map<String, Object>> topActivities = new List<Map<String, Object>>();
            for (Integer i = 0; i < limitCount; i++) {
                Map<String, Object> rec = activityLists[i];
                topActivities.add(rec);
            }
            accountTopActivityList.put(accId, topActivities);
        }
        return accountTopActivityList;
    }
    private static Set<Id> queryRecentInteractions(Set<Id> contactIds){  
        
        DateTime now = System.now();      
        Set<Id> activityIds = new Set<Id>();
        // Query the 5 most recent interactions for each contact
        String eventAggQuery = 'SELECT EventId FROM EventRelation WHERE RelationId IN :contactIds';
        eventAggQuery += ' AND EventId != null AND Event.StartDateTime <= :now WITH USER_MODE GROUP BY EventId ORDER BY MAX(Event.StartDateTime) DESC LIMIT 5';
        List<AggregateResult> eventAggResults = (List<AggregateResult>)Database.query(eventAggQuery);
        for (AggregateResult ar : eventAggResults) {
            Id eventId = (Id)ar.get('EventId');
            if (eventId != null) {
                activityIds.add(eventId);
            }
        }
        String taskAggQuery = 'SELECT TaskId FROM TaskRelation WHERE RelationId IN :contactIds';
        taskAggQuery += ' AND TaskId != null AND Task.TaskSubType != \'ListEmail\' AND Task.ActivityDate <= TODAY WITH USER_MODE GROUP BY TaskId ORDER BY MAX(Task.ActivityDate) DESC  NULLS FIRST LIMIT 5';//Bug Fixing 00051899 FIltering ListEmail Task Salauddin 08042026
        List<AggregateResult> taskAggResults = (List<AggregateResult>)Database.query(taskAggQuery);
        for (AggregateResult ar : taskAggResults) {
            Id taskId = (Id)ar.get('TaskId');
            if (taskId != null) {
                activityIds.add(taskId);
            }
        }
        return activityIds;
    }
    private static void sortByActivityDateDesc(List<Map<String, Object>> activityList) {
        Integer n = activityList.size();
        for (Integer i = 0; i < n - 1; i++) {
            for (Integer j = 0; j < n - i - 1; j++) {
                //Bug Fixing 00050882, 00050887 
                Long dateJ = (Long)activityList[j].get('activitydateaslong');
                Long dateJ1 = (Long)activityList[j+1].get('activitydateaslong');
                Boolean swap = false;
                if (dateJ == null && dateJ1 != null) {
                    swap = true;
                } else if (dateJ != null && dateJ1 != null && dateJ1 > dateJ) {
                    swap = true;
                }
                if (swap) {
                    Map<String, Object> temp = activityList[j];
                    activityList[j] = activityList[j+1];
                    activityList[j+1] = temp;
                }
            }
        }
    }
    public static Map<Id, String> getFirmFutureMeeting(Map<Id,Set<Id>> accountToContactIds, List<Id> nextEventIds){ 
        
        DateTime now = System.now();
        Set<Id> allContactIds = new Set<Id>();
        Set<Id> eventIds = new Set<Id>();
        Map<Id,Set<Id>> accountInteractions = new Map<Id, Set<Id>>();
        Map<Id,Set<Id>> accountInteractionsWithWhatId = new Map<Id, Set<Id>>();
        Map<Id, String> eventMeetingMap = new Map<Id, String>();
        Map<Id, String> accountMeetingMap = new Map<Id, String>();
        List<String> associationFilters = new List<String>();
        if(accountToContactIds == null || accountToContactIds.isEmpty()){
            return accountMeetingMap;
        }
        //bug fixing to add fix for related association filter in query 00051784 Salauddin 27032026
        for(Id accId : accountToContactIds.keySet()){
            associationFilters.add('navpeII__Related_Associations__c LIKE \'%' + String.escapeSingleQuotes(accId) + '%\'');
            allContactIds.addAll(accountToContactIds.get(accId));
        }
        String associationWhere = String.join(associationFilters, ' OR ');//Bug Fixing https://navatartaskmgmt.atlassian.net/browse/AA-660 Salauddin duplicate Future Meetings 09042026
        // Bug Fixing to avoid child events 00051758 Salauddin 26032026
        for(EventRelation er : [
            SELECT EventId, RelationId
            FROM EventRelation
            WHERE RelationId IN :allContactIds
            AND Event.StartDateTime >= :now
            AND EventId != null
            AND Event.isChild = false
            WITH USER_MODE
        ]) {
            eventIds.add(er.EventId);
            for (Id accId : accountToContactIds.keySet()) {
                if (accountToContactIds.get(accId).contains(er.RelationId)) {
                    if (!accountInteractions.containsKey(accId)) {
                        accountInteractions.put(accId, new Set<Id>());
                    }
                    accountInteractions.get(accId).add(er.EventId);
                }
            }
        }

        if(eventIds.isEmpty()){
            return accountMeetingMap;
        }
        String eventQuery ='SELECT Id, Subject, EventSubtype, ActivityDate, StartDateTime, Description, Owner.Name,WhatId, navpeII__Related_Associations__c,' +
        '(SELECT RelationId, Relation.Name FROM EventRelations) ' +
        'FROM Event ' +
        'WHERE (Id IN :eventIds OR ' + associationWhere + ') ' +//Bug Fixing https://navatartaskmgmt.atlassian.net/browse/AA-660 Salauddin duplicate Future Meetings 09042026
        'AND StartDateTime >= :now ' +
        'AND Id NOT IN :nextEventIds ' +
        'AND IsArchived = false ' +
        'AND isChild = false ' +
        'WITH USER_MODE ' +
        'ORDER BY CREATEDDATE DESC';
        for (Event ev : Database.query(eventQuery)) {
            String futureMeetings ='';
            List<String> participants = new List<String>();
            participants.add(ev.Owner.Name);    // Bug 00051681 Fixed by Sudhanshu
            for (EventRelation evRel : ev.EventRelations) {
                if(String.valueOf(evRel.RelationId).startsWith('003') || String.valueOf(evRel.RelationId).startsWith('005')){ // Only consider Contact and User as participants for future meetings
                    participants.add(evRel.Relation.Name);
                }
            }
            
            futureMeetings += '<li>' + ev.Subject + ', ' + (ev.StartDateTime).format('dd MMM yyyy \'at\' h:mm a') +' '+ (participants.isEmpty() ? '' : 'Participants: ' + String.join(participants, ', ')) + '</li>';
            eventMeetingMap.put(ev.Id, futureMeetings);
            if(String.isNotBlank(ev.navpeII__Related_Associations__c)){
                List<String> relIds = ev.navpeII__Related_Associations__c.split(',');                
                for(String relId : relIds){
                    String trimmedId = relId.trim();

                    // validate id length before casting
                    if(trimmedId.length() < 15){
                        continue;
                    }

                    Id recId;
                    try{
                        recId = (Id)trimmedId;
                    }catch(Exception e){
                        continue;
                    }

                    // Only allow Accounts present in accountToContactIds
                    if(accountToContactIds.containsKey(recId)){
                        if(!accountInteractions.containsKey(recId)){
                            accountInteractions.put(recId, new Set<Id>());
                        }

                        accountInteractions.get(recId).add(ev.Id);
                    }
                }
            }
        }
        for(Id evId:eventMeetingMap.keySet()){
            for(Id accId : accountInteractions.keySet()){
                if(accountInteractions.get(accId).contains(evId)){
                    if(accountMeetingMap.containsKey(accId)){
                        accountMeetingMap.put(accId, accountMeetingMap.get(accId) + eventMeetingMap.get(evId));
                    } else {
                        accountMeetingMap.put(accId, eventMeetingMap.get(evId));
                    }
                }
            }
        }

        return accountMeetingMap;
    }
    public static Map<Id, List<navpeII__Pipeline__c>> getDealsSourced(List<Id> accIds) {
        Map<Id, List<navpeII__Pipeline__c>> accountIdToDealSourced = new Map<Id, List<navpeII__Pipeline__c>>();
        for (navpeII__Pipeline__c pipeline : [SELECT Id, Name, navpeII__Log_In_Date__c, navpeII__Stage__c,navpeII__Source_Company__c,navpeII__Source_Contact__r.name FROM navpeII__Pipeline__c WHERE navpeII__Source_Company__c IN :accIds  WITH USER_MODE ORDER BY navpeII__Log_In_Date__c DESC NULLS LAST]) {
            if (!accountIdToDealSourced.containsKey(pipeline.navpeII__Source_Company__c)) {
                accountIdToDealSourced.put(pipeline.navpeII__Source_Company__c, new List<navpeII__Pipeline__c>());            
            }
            accountIdToDealSourced.get(pipeline.navpeII__Source_Company__c).add(pipeline);
        }
        return accountIdToDealSourced;
    }

    public static Map<Id, List<navpeII__Pipeline__c>> getDealsHistory(List<Id> accIds) {
        Map<Id, List<navpeII__Pipeline__c>> accountIdToDealSourced = new Map<Id, List<navpeII__Pipeline__c>>();
        for (navpeII__Pipeline__c pipeline : [SELECT Id, Name, navpeII__Log_In_Date__c, navpeII__Stage__c,navpeII__Company__c FROM navpeII__Pipeline__c WHERE navpeII__Company__c IN :accIds  WITH USER_MODE ORDER BY navpeII__Log_In_Date__c DESC]) {
            if (!accountIdToDealSourced.containsKey(pipeline.navpeII__Company__c)) {
                accountIdToDealSourced.put(pipeline.navpeII__Company__c, new List<navpeII__Pipeline__c>());            
            }
            accountIdToDealSourced.get(pipeline.navpeII__Company__c).add(pipeline);
        }
        return accountIdToDealSourced;
    }
    public static Map<Id, List<navpeII__Fundraising__c>> getFundRaisingsHistory(List<Id> accIds) {
        Map<Id,List<navpeII__Fundraising__c>> accountIdToFundRaisings = new Map<Id, List<navpeII__Fundraising__c>>();
         for (navpeII__Fundraising__c fundraising : [SELECT Id, Name, navpeII__Fund_Name__r.Name,navpeII__Fund_Name__c, navpeII__Stage__c,navpeII__Target_Close_Date__c, navpeII__Legal_Name__c FROM navpeII__Fundraising__c WHERE navpeII__Legal_Name__c IN :accIds  WITH USER_MODE ORDER BY navpeII__Target_Close_Date__c DESC]) {
            if (!accountIdToFundRaisings.containsKey(fundraising.navpeII__Legal_Name__c)) {
                accountIdToFundRaisings.put(fundraising.navpeII__Legal_Name__c, new List<navpeII__Fundraising__c>());            
            }
            accountIdToFundRaisings.get(fundraising.navpeII__Legal_Name__c).add(fundraising);
        }
        return accountIdToFundRaisings;
    }
    public static Map<Id, List<navpeII__Affiliation__c>> getFormerEmployees(List<Id> accIds) {
        Map<Id, List<navpeII__Affiliation__c>> accountIdToAffiliations = new Map<Id, List<navpeII__Affiliation__c>>();
         for (navpeII__Affiliation__c afiliation : [SELECT Id,navpeII__Contact__r.Name,navpeII__Role__c,navpeII__Contact__r.Account.Name, navpeII__Institution__c,navpeII__Start_Date__c,navpeII__End_Date__c FROM navpeII__Affiliation__c WHERE navpeII__Institution__c IN :accIds WITH USER_MODE]) {
            if (!accountIdToAffiliations.containsKey(afiliation.navpeII__Institution__c)) {
                accountIdToAffiliations.put(afiliation.navpeII__Institution__c, new List<navpeII__Affiliation__c>());            
            }
            accountIdToAffiliations.get(afiliation.navpeII__Institution__c).add(afiliation);
        }
        return accountIdToAffiliations;
    }

     public static Map<Id, List<navpeII__Pipeline__c>> getDealsInvolvedIn(List<Id> conIds) {
        Map<Id, List<navpeII__Pipeline__c>> contactToDealsInvolved = new Map<Id, List<navpeII__Pipeline__c>>();
        for (navpeII__Deal_Team__c dt : [SELECT Id, navpeII__Deal__r.Name, navpeII__Deal__r.navpeII__Log_In_Date__c, navpeII__Deal__r.navpeII__Stage__c,navpeII__Deal_Contact__c FROM navpeII__Deal_Team__c WHERE navpeII__Deal_Contact__c IN :conIds  WITH USER_MODE ORDER BY navpeII__Deal__r.navpeII__Log_In_Date__c DESC]) {
            if (!contactToDealsInvolved.containsKey(dt.navpeII__Deal_Contact__c)) {
                contactToDealsInvolved.put(dt.navpeII__Deal_Contact__c, new List<navpeII__Pipeline__c>());            
            }
            contactToDealsInvolved.get(dt.navpeII__Deal_Contact__c).add(dt.navpeII__Deal__r);
        }
        return contactToDealsInvolved;
    }

    public static Map<Id, List<navpeII__Fundraising__c>> getFundRaisingInvolvedIn(List<Id> conIds) {
        Map<Id, List<navpeII__Fundraising__c>> contactToFundraisingInvolved = new Map<Id, List<navpeII__Fundraising__c>>();
        for (navpeII__Fundraising_Contact__c dt : [SELECT Id, navpeII__Fundraising__r.Name, navpeII__Fundraising__r.navpeII__Target_Close_Date__c,navpeII__Fundraising__r.navpeII__Fund_Name__r.Name, navpeII__Fundraising__r.navpeII__Stage__c,navpeII__Contact__c FROM navpeII__Fundraising_Contact__c WHERE navpeII__Contact__c IN :conIds  WITH USER_MODE ORDER BY navpeII__Fundraising__r.navpeII__Target_Close_Date__c DESC]) {
            if (!contactToFundraisingInvolved.containsKey(dt.navpeII__Contact__c)) {
                contactToFundraisingInvolved.put(dt.navpeII__Contact__c, new List<navpeII__Fundraising__c>());            
            }
            contactToFundraisingInvolved.get(dt.navpeII__Contact__c).add(dt.navpeII__Fundraising__r);
        }
        return contactToFundraisingInvolved;
    }

    public static Map<Id, List<navpeII__Pipeline__c>> getContactDealsSourced(List<Id> conIds) {
        Map<Id, List<navpeII__Pipeline__c>> contactIdToDealSourced = new Map<Id, List<navpeII__Pipeline__c>>();
        for (navpeII__Pipeline__c pipeline : [SELECT Id, Name, navpeII__Log_In_Date__c, navpeII__Stage__c,navpeII__Source_Company__c,navpeII__Source_Contact__r.name FROM navpeII__Pipeline__c WHERE navpeII__Source_Contact__c IN :conIds  WITH USER_MODE ORDER BY navpeII__Log_In_Date__c DESC]) {
            if (!contactIdToDealSourced.containsKey(pipeline.navpeII__Source_Contact__c)) {
                contactIdToDealSourced.put(pipeline.navpeII__Source_Contact__c, new List<navpeII__Pipeline__c>());            
            }
            contactIdToDealSourced.get(pipeline.navpeII__Source_Contact__c).add(pipeline);
        }
        return contactIdToDealSourced;
    }



    public static Map<Id,List<Map<String, Object>>> getContact5RecentInteractions(Set<Id> contactId){    
        Map<Id,Set<Id>> contactInteractions = new Map<Id, Set<Id>>();
        Map<Id,Set<Id>> contactInteractionsWithWhatId = new Map<Id, Set<Id>>();
        Map<Id,List<Map<String, Object>>> contactActivityList = new Map<Id, List<Map<String, Object>>>();
        Map<Id,List<Map<String, Object>>> contactTopActivityList = new Map<Id, List<Map<String, Object>>>();
        Set<Id> allInteractionIds = new Set<Id>();
        List<Map<String, Object>> activityList = new List<Map<String, Object>>();
        for (Id conId : contactId) {
            System.debug('Querying interactions for Contact Id: ' + conId);
            Set<Id> interactionIds = queryRecentInteractions(new Set<Id>{conId});
            allInteractionIds.addAll(interactionIds);
            contactInteractions.put(conId, interactionIds);
        }
        
            // Query Events
        for (Event ev : [SELECT Id, Subject,EventSubtype, ActivityDate, StartDateTime, Description, Owner.Name,WhatId, (SELECT RelationId, Relation.Name FROM EventRelations) FROM Event WHERE (Id IN :allInteractionIds) AND StartDateTime <= :System.now() AND IsArchived = false WITH USER_MODE ORDER BY CREATEDDATE DESC]) {//Bug Fixing 00051562 Salauddin 05032026
            Long activityDateAsLong = null;
            if (ev.StartDateTime != null) {
                activityDateAsLong = ev.StartDateTime.getTime();
            }
            // Bug 00051112 fixed by Sudhanshu
            Map<String, Object> rec = new Map<String, Object>{
                'Id' => ev.Id,
                'Subject' => ev.Subject,
                'ActivityDate' => ev.ActivityDate,
                'Description' => ev.Description,
                'OwnerName' => ev.Owner.Name,
                'Subtype' => ev.EventSubtype != null ? ev.EventSubtype : 'Event',
                'activitydateaslong' => activityDateAsLong
            };
            List<String> participants = new List<String>();
            participants.add(ev.Owner.Name); // Include Event Owner as a participant
            for (EventRelation evr : ev.EventRelations) {
                if(String.valueOf(evr.RelationId).startsWith('003') || String.valueOf(evr.RelationId).startsWith('005')) // Check if RelationId starts with '003' (Contact) or '005' (User)
                {
                    participants.add(evr.Relation.Name);
                }
            }                                     
            rec.put('Participants', participants);
            activityList.add(rec); 
            //Bug Fixing 00051558 Salauddin 27022026 
            if(ev.WhatId != null ){
                if(!contactInteractionsWithWhatId.containsKey(ev.WhatId)){
                    contactInteractionsWithWhatId.put(ev.WhatId, new Set<Id>());
                }
                contactInteractionsWithWhatId.get(ev.WhatId).add(ev.Id);
            }
        }
        for (Task ev : [SELECT Id, Subject,TaskSubtype, ActivityDate, Description, Owner.Name,WhatId, (SELECT RelationId, Relation.Name FROM TaskRelations) FROM Task WHERE (Id IN :allInteractionIds) AND ActivityDate <= Today AND IsArchived = false WITH USER_MODE ORDER BY CREATEDDATE DESC]) {//Bug Fixing 00051562 Salauddin 05032026
            Long activityDateAsLong = null;
            if (ev.ActivityDate != null) {
                DateTime dt = DateTime.newInstance(ev.ActivityDate, Time.newInstance(0, 0, 0, 0));
                activityDateAsLong = dt.getTime();
            }
            // Bug 00051112 fixed by Sudhanshu
            Map<String, Object> rec = new Map<String, Object>{
                'Id' => ev.Id,
                'Subject' => ev.Subject,
                'ActivityDate' => ev.ActivityDate,
                'Description' => ev.Description,
                'OwnerName' => ev.Owner.Name,
                'Subtype' => ev.TaskSubtype != null ? ev.TaskSubtype : 'Task',
                'activitydateaslong' => activityDateAsLong
            };
            List<String> participants = new List<String>();
            participants.add(ev.Owner.Name); // Include Task Owner as a participant
            for (TaskRelation evr : ev.TaskRelations) {
                if(String.valueOf(evr.RelationId).startsWith('003') || String.valueOf(evr.RelationId).startsWith('005')) // Check if RelationId starts with '003' (Contact) or '005' (User)
                {
                    participants.add(evr.Relation.Name);
                }
                
                
            }                                   
            rec.put('Participants', participants);
            activityList.add(rec);  
            //Bug Fixing 00051558 Salauddin 27022026
            if(ev.WhatId != null ){
                if(!contactInteractionsWithWhatId.containsKey(ev.WhatId)){
                    contactInteractionsWithWhatId.put(ev.WhatId, new Set<Id>());
                }
                contactInteractionsWithWhatId.get(ev.WhatId).add(ev.Id);
            }          
        }
        
        
        for (Map<String, Object> activity : activityList) {
            for (Id conId : contactInteractions.keySet()) {
                if (contactInteractions.get(conId).contains((Id)activity.get('Id'))) {
                    if (!contactActivityList.containsKey(conId)) {
                        contactActivityList.put(conId, new List<Map<String, Object>>());
                    }
                    contactActivityList.get(conId).add(activity);
                }
            }
        }
        for (Map<String, Object> activity : activityList) {
            for (Id conId : contactInteractionsWithWhatId.keySet()) {
                if (contactInteractionsWithWhatId.get(conId).contains((Id)activity.get('Id'))) {
                    if (!contactActivityList.containsKey(conId)) {
                        contactActivityList.put(conId, new List<Map<String, Object>>());
                    }
                    contactActivityList.get(conId).add(activity);
                    break;
                }
            }
        }
        for (Id conId : contactActivityList.keySet()) {
            sortByActivityDateDesc(contactActivityList.get(conId));
        }
        for (Id conId : contactActivityList.keySet()) {
            List<Map<String, Object>> activityLists = contactActivityList.get(conId);
            Integer limitCount = Math.min(5, activityLists.size());                
            List<Map<String, Object>> topActivities = new List<Map<String, Object>>();
            for (Integer i = 0; i < limitCount; i++) {
                Map<String, Object> rec = activityLists[i];
                System.debug('top activity : ' + JSON.serialize(rec));
                topActivities.add(rec);
            }
            contactTopActivityList.put(conId, topActivities);
        }
        return contactTopActivityList;
    }


    private static Set<Id> queryContactRecentInteractions(Set<Id> contactIds){  
        
        DateTime now = System.now();      
        Set<Id> activityIds = new Set<Id>();
        // Query the 5 most recent interactions for each contact
        String eventAggQuery = 'SELECT EventId FROM EventRelation WHERE RelationId IN :contactIds';
        eventAggQuery += ' AND EventId != null AND Event.StartDateTime <= :now WITH USER_MODE GROUP BY EventId ORDER BY MAX(Event.StartDateTime) DESC LIMIT 5';
        List<AggregateResult> eventAggResults = (List<AggregateResult>)Database.query(eventAggQuery);
        for (AggregateResult ar : eventAggResults) {
            Id eventId = (Id)ar.get('EventId');
            if (eventId != null) {
                activityIds.add(eventId);
            }
        }
        String taskAggQuery = 'SELECT TaskId FROM TaskRelation WHERE RelationId IN :contactIds';
        taskAggQuery += ' AND TaskId != null AND Task.ActivityDate <= TODAY WITH USER_MODE GROUP BY TaskId ORDER BY MAX(Task.ActivityDate) DESC  NULLS FIRST LIMIT 5';
        List<AggregateResult> taskAggResults = (List<AggregateResult>)Database.query(taskAggQuery);
        for (AggregateResult ar : taskAggResults) {
            Id taskId = (Id)ar.get('TaskId');
            if (taskId != null) {
                activityIds.add(taskId);
            }
        }
        return activityIds;
    }


    public static Map<Id, String> getContactFutureMeeting(Set<Id> contactIds, List<Id> nextEventIds){ 
        
        DateTime now = System.now();
        Set<Id> allContactIds = new Set<Id>();
        Set<Id> eventIds = new Set<Id>();
        Map<Id,Set<Id>> contactInteractions = new Map<Id, Set<Id>>();
        Map<Id,Set<Id>> contactInteractionsWithWhatId = new Map<Id, Set<Id>>();
        Map<Id, String> eventMeetingMap = new Map<Id, String>();
        Map<Id, String> contactMeetingMap = new Map<Id, String>();
        if(contactIds == null || contactIds.isEmpty()){
            return contactMeetingMap;
        }

        for(Id conId : contactIds){
            allContactIds.add(conId);
        }

        // Get future Event Ids
        for(EventRelation er : [
            SELECT EventId, RelationId
            FROM EventRelation
            WHERE RelationId IN :allContactIds
            AND Event.StartDateTime >= :now
            AND EventId != null
            WITH USER_MODE
        ]) {
            eventIds.add(er.EventId);
            for (Id conId : contactIds) {
                if (contactIds.contains(er.RelationId)) {
                    if (!contactInteractions.containsKey(conId)) {
                        contactInteractions.put(conId, new Set<Id>());
                    }
                    contactInteractions.get(conId).add(er.EventId);
                }
            }
        }

        if(eventIds.isEmpty()){
            return contactMeetingMap;
        }
        for (Event ev : [SELECT Id, Subject,EventSubtype, ActivityDate, StartDateTime, Description, Owner.Name,WhatId, (SELECT RelationId, Relation.Name FROM EventRelations ) FROM Event WHERE (Id IN :eventIds ) AND StartDateTime >= :now AND Id NOT IN :nextEventIds AND IsArchived = false WITH USER_MODE ORDER BY CREATEDDATE DESC]) {
            String futureMeetings ='';
            List<String> participants = new List<String>();
            participants.add(ev.Owner.Name); // Include event owner as participant
            for (EventRelation evRel : ev.EventRelations) {
                if(String.valueOf(evRel.RelationId).startsWith('003') || String.valueOf(evRel.RelationId).startsWith('005')){ // Only consider Contact and User as participants for future meetings
                    participants.add(evRel.Relation.Name);
                }
            }
            
            futureMeetings += '<li>' + ev.Subject + ', ' + (ev.StartDateTime).format('dd MMM yyyy \'at\' h:mm a') +' '+ (participants.isEmpty() ? '' : 'Participants: ' + String.join(participants, ', ')) + '</li>';
            eventMeetingMap.put(ev.Id, futureMeetings);
            if(ev.WhatId != null ){
                if(!contactInteractionsWithWhatId.containsKey(ev.WhatId)){
                    contactInteractionsWithWhatId.put(ev.WhatId, new Set<Id>());
                }
                contactInteractionsWithWhatId.get(ev.WhatId).add(ev.Id);
            }
        }
        for(Id evId:eventMeetingMap.keySet()){
            for(Id conId : contactInteractions.keySet()){
                if(contactInteractions.get(conId).contains(evId)){
                    if(contactMeetingMap.containsKey(conId)){
                        contactMeetingMap.put(conId, contactMeetingMap.get(conId) + eventMeetingMap.get(evId));
                    } else {
                        contactMeetingMap.put(conId, eventMeetingMap.get(evId));
                    }
                }
            }
        }
        for(Id evId:eventMeetingMap.keySet()){
            for(Id conId : contactInteractionsWithWhatId.keySet()){
                if(contactInteractionsWithWhatId.get(conId).contains(evId)){
                    if(contactMeetingMap.containsKey(conId)){
                        contactMeetingMap.put(conId, contactMeetingMap.get(conId) + eventMeetingMap.get(evId));
                    } else {
                        contactMeetingMap.put(conId, eventMeetingMap.get(evId));
                    }
                    break;
                }
            }
        }

        return contactMeetingMap;
    }

    public static List<Map<String, Object>> getDeal5RecentInteractions(Id dealId){
        try {          
            DateTime now = System.now();
            List<Map<String, Object>> activityList = new List<Map<String, Object>>();
            String recordIdStr = '%' + String.valueOf(dealId) + '%';
            Set<Id> eventIds = new Set<Id>();
            Set<Id> taskIds = new Set<Id>();
            Map<Id,Set<String>> activityRelatedAssocMap = new Map<Id,Set<String>>();
            Map<Id, List<String>> eventParticipantsMap = new Map<Id, List<String>>();
            Map<Id, List<String>> taskParticipantsMap = new Map<Id, List<String>>();
            // Get top 5 Tasks related to the Deal
            for (Task tk : [SELECT Id, Subject, ActivityDate, Description, Owner.Name, TaskSubtype, navpeII__Related_Associations__c,
            (SELECT TaskId, RelationId,relation.name  FROM TaskRelations) FROM Task WHERE navpeII__Related_Associations__c LIKE :recordIdStr AND ActivityDate <= TODAY AND IsArchived = false WITH USER_MODE ORDER BY ActivityDate DESC NULLS FIRST LIMIT 5]) {
                Long activityDateAsLong = null;
                if (tk.ActivityDate != null) {
                    DateTime dt = DateTime.newInstance(tk.ActivityDate, Time.newInstance(0, 0, 0, 0));
                    activityDateAsLong = dt.getTime();
                }
                Map<String, Object> rec = new Map<String, Object>{
                    'Id' => tk.Id,
                    'Subject' => tk.Subject,
                    'ActivityDate' => tk.ActivityDate,
                    'Description' => tk.Description,
                    'OwnerName' => tk.Owner.Name,
                    'Subtype' => tk.TaskSubtype != null ? tk.TaskSubtype : 'Task',
                    'activitydateaslong' => activityDateAsLong
                };
                activityList.add(rec);
                activityRelatedAssocMap.put(tk.Id, tk.navpeII__Related_Associations__c != null ? new Set<String>(tk.navpeII__Related_Associations__c.split(',')) : new Set<String>());
                taskParticipantsMap.put(tk.Id, new List<String>{tk.Owner.Name}); 
                for(TaskRelation tr : tk.TaskRelations){
                    if(tr.relationId != null && (String.valueOf(tr.RelationId).startsWith('003') || String.valueOf(tr.RelationId).startsWith('005'))) {
                        if (!taskParticipantsMap.containsKey(tr.TaskId)) {
                            taskParticipantsMap.put(tr.TaskId, new List<String>());
                        } 
                        taskParticipantsMap.get(tr.TaskId).add(tr.Relation.Name);
                    }
                }
            }
            // Get top 5 Events related to the Deal
            for (Event ev : [SELECT Id, Subject, ActivityDate, EventSubtype, StartDateTime, Description, Owner.Name,navpeII__Related_Associations__c,
            (SELECT EventId, RelationId, Relation.Name FROM EventRelations) FROM Event WHERE navpeII__Related_Associations__c LIKE :recordIdStr AND StartDateTime <= :now AND IsArchived = false WITH USER_MODE ORDER BY StartDateTime DESC LIMIT 5]) {
                Long activityDateAsLong = null;
                if (ev.StartDateTime != null) {
                    activityDateAsLong = ev.StartDateTime.getTime();
                }
                Map<String, Object> rec = new Map<String, Object>{
                    'Id' => ev.Id,
                    'Subject' => ev.Subject,
                    'ActivityDate' => ev.ActivityDate,
                    'Description' => ev.Description,
                    'OwnerName' => ev.Owner.Name,
                    'Subtype' => ev.EventSubtype != null ? ev.EventSubtype : 'Event',
                    'activitydateaslong' => activityDateAsLong
                };
                activityList.add(rec);
                activityRelatedAssocMap.put(ev.Id, ev.navpeII__Related_Associations__c != null ? new Set<String>(ev.navpeII__Related_Associations__c.split(',')) : new Set<String>());
                eventParticipantsMap.put(ev.Id, new List<String>{ev.Owner.Name}); 
                for(EventRelation er : ev.EventRelations){
                    if(er.relationId != null && (String.valueOf(er.RelationId).startsWith('003') || String.valueOf(er.RelationId).startsWith('005'))) {
                        if (!eventParticipantsMap.containsKey(er.EventId)) {
                            eventParticipantsMap.put(er.EventId, new List<String>());
                        }
                        eventParticipantsMap.get(er.EventId).add(er.Relation.Name);
                    }
                }
            }
            
            
            sortByActivityDateDesc(activityList);
            List<Map<String, Object>> topActivities = new List<Map<String, Object>>();
            Integer limitCount = Math.min(5, activityList.size());
            for (Integer i = 0; i < limitCount; i++) {
                System.debug('activity : ' + JSON.serialize(activityList[i]));
                Map<String, Object> rec = activityList[i];
                topActivities.add(rec);
                if (String.valueOf(rec.get('Id')).startsWith('00U')) {
                    eventIds.add((Id)rec.get('Id'));
                } else { 
                    taskIds.add((Id)rec.get('Id'));
                }
            }
            
            for (Map<String, Object> rec : topActivities) {
                if (String.valueOf(rec.get('Id')).startsWith('00U')) {
                    rec.put('Participants', eventParticipantsMap.containsKey((Id)rec.get('Id')) ? eventParticipantsMap.get((Id)rec.get('Id')) : new List<String>());
                } else if (String.valueOf(rec.get('Id')).startsWith('00T')) {
                    rec.put('Participants', taskParticipantsMap.containsKey((Id)rec.get('Id')) ? taskParticipantsMap.get((Id)rec.get('Id')) : new List<String>());
                }
                System.debug('Participants =>' + JSON.serialize(rec.get('Participants')));
            }
            return topActivities;
        } catch (Exception e) {
            System.debug('Error in getTopActivities: ' + e.getMessage());   
            return new List<Map<String, Object>>();    
        }
    }
    
    public static String getFutureActivities(Id dealId) {
        String recordIdStr = '%' + String.valueOf(dealId) + '%';
        DateTime now = System.now();
        String futureMeetings ='';
        for (Event ev : [SELECT Id, Subject, ActivityDate, StartDateTime, Description, Owner.Name,(SELECT RelationId, Relation.Name FROM EventRelations ) FROM Event WHERE navpeII__Related_Associations__c LIKE :recordIdStr AND StartDateTime > :now AND IsArchived = false WITH USER_MODE ORDER BY StartDateTime DESC]) {
            Long activityDateAsLong = null;
            List<String> participants = new List<String>();
            participants.add(ev.Owner.Name);
            for (EventRelation evRel : ev.EventRelations) {
                if (evRel.RelationId != null && (String.valueOf(evRel.RelationId).startsWith('003') || String.valueOf(evRel.RelationId).startsWith('005'))) {
                    participants.add(evRel.Relation.Name);
                }
            }
            futureMeetings += '<li>' + ev.Subject + ', ' + (ev.StartDateTime).format('dd MMM yyyy \'at\' h:mm a') +' '+ (participants.isEmpty() ? '' : 'Participants: ' + String.join(participants, ', ')) + '</li>';
        }
        
        return futureMeetings;
    }

    public static Map<Id, List<navpeII__Affiliation__c>> getContactFormerEmployees(List<Id> conIds) {
        Map<Id, List<navpeII__Affiliation__c>> contactIdToAffiliations = new Map<Id, List<navpeII__Affiliation__c>>();
         for (navpeII__Affiliation__c afiliation : [SELECT Id,navpeII__Contact__r.Name,navpeII__Role__c,navpeII__Contact__r.Account.Name, navpeII__Institution__c,navpeII__Institution__r.Name,navpeII__Start_Date__c,navpeII__End_Date__c FROM navpeII__Affiliation__c WHERE navpeII__Contact__c IN :conIds WITH USER_MODE]) {
            if (!contactIdToAffiliations.containsKey(afiliation.navpeII__Contact__c)) {
                contactIdToAffiliations.put(afiliation.navpeII__Contact__c, new List<navpeII__Affiliation__c>());            
            }
            contactIdToAffiliations.get(afiliation.navpeII__Contact__c).add(afiliation);
        }
        return contactIdToAffiliations;
    }    
    
}