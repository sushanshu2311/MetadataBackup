/****************************************************************************************************
** Module Name : Meeting Prep Card (24hr) 1.0 
** Description : Used to Send Meeting Prep Card 24 hr prior to meeting.
** Organization : Navatar Group
** Product Name & Version : PE Agentforce Baseline 1.0
** Revision History:-
** Version    Date(YYYY-MM-DD)    Author            Description of Action
** 1.0        2026-02-05          Salauddin Sheikh  PE Agentforce Baseline Phase 1
****************************************************************************************************/
public with sharing class NavatarEmailMeetingPrepCard {
    // Bug 00050943 Fixed by Sudhanshu
    public class MeetingPrepCardException extends Exception {}

    public class PrepCardWrapper{
        public Set<Id> contactIds = new Set<Id>();
        public Set<Id> userIds = new Set<Id>();
        public List<Id> eventIds = new List<Id>();
        public Map<Id, Set<Id>> eventToContactIds = new Map<Id, Set<Id>>();
        public Map<Id, Set<Id>> eventToUserIds = new Map<Id, Set<Id>>();            
        public Map<Id, Contact> contactsMap = new Map<Id, Contact>();
        public Set<Id> accountIds = new Set<Id>();
        public Map<Id, String> accNameMap = new Map<Id, String>();
        public Map<Id, User> usersMap = new Map<Id, User>();
        public List<Messaging.SingleEmailMessage> emailsToSend = new  List<Messaging.SingleEmailMessage>();
        public Map<Id, String> accountPromptCache = new Map<Id, String>();
        public Map<Id, String> contactPromptCache = new Map<Id, String>();
        public Map<Id, String> promptMap = new Map<Id, String>();
        public Map<Id,Set<Id>> accountToContactIds = new Map<Id, Set<Id>>();
        public Map<Id, String> accountDealSourced = new Map<Id, String>();
        public Map<Id, String> accountDealInvolved = new Map<Id, String>();
        public Map<Id, String> accountDealHistory = new Map<Id, String>();
        public Map<Id, String> accountFundRaisingsHistory = new Map<Id, String>();
        public Map<Id, String> accountFormerEmployees = new Map<Id, String>();
        public Map<Id, List<String>> eventbusinessHistories = new Map<Id, List<String>>();        
        public List<Contact> relatedContacts = new List<Contact>();  
        public Map<Id, Id> contactAccountIdMap = new Map<Id, Id>();
        public Map<Id, List<navpeII__Pipeline__c>> contactToDealsInvolved = new Map<Id, List<navpeII__Pipeline__c>>();
        public Map<Id,List<Map<String, Object>>> accountTopActivityList = new Map<Id,List<Map<String, Object>>>();
        public Map<Id, String> accountFutureMeetingMap = new Map<Id, String>();
        Public String baseUrl = System.Url.getOrgDomainUrl().toExternalForm();
        public Map<Id, Date> contactLastTouchpointDate = new Map<Id, Date>();
        public Map<Id, String> contactLastTouchpointInfo = new Map<Id, String>();
    }

    private static List<Event> getEvents(List<Id> eventIds) {
        return [
            SELECT Id, Subject, Description, StartDateTime, OwnerId, WhoId, (SELECT Id,  
            RelationId FROM EventRelations)
            FROM Event
            WHERE Id IN :eventIds
            AND StartDateTime <= :System.now().addHours(24)
            AND StartDateTime >= :System.now()
            WITH USER_MODE
        ];
    }

    public static void collectRelations(List<Event> events,PrepCardWrapper wrapper) {
        for (Event ev : events) {
            if (ev.OwnerId != null) {
                wrapper.userIds.add(ev.OwnerId);
                wrapper.eventToUserIds.put(ev.Id, new Set<Id>{ev.OwnerId});
            }
            if (ev.WhoId != null && String.valueOf(ev.WhoId).startsWith('003')) {
                wrapper.contactIds.add(ev.WhoId);
                wrapper.eventToContactIds.put(ev.Id, new Set<Id>{ev.WhoId});
            }
            for (EventRelation er : ev.EventRelations) {
                String prefix = String.valueOf(er.RelationId).substring(0, 3);
                if (prefix == '003') {
                    wrapper.contactIds.add(er.RelationId); // Contact
                    if (!wrapper.eventToContactIds.containsKey(ev.Id)) {
                        wrapper.eventToContactIds.put(ev.Id, new Set<Id>());
                    }
                    wrapper.eventToContactIds.get(ev.Id).add(er.RelationId);
                } else if (prefix == '005') {
                    wrapper.userIds.add(er.RelationId); // User
                    if (!wrapper.eventToUserIds.containsKey(ev.Id)) {
                        wrapper.eventToUserIds.put(ev.Id, new Set<Id>());
                    }
                    wrapper.eventToUserIds.get(ev.Id).add(er.RelationId);
                }                    
            }
        }
    }

    public static void loadContacts(PrepCardWrapper wrapper,String type) {
        if (!wrapper.contactIds.isEmpty()  && type == 'RelatedContact' ) {
            wrapper.relatedContacts = [SELECT Id, Name, Email, AccountId,Account.Name,Account.navpeII__Total_Commitments_USD_mn__c, Account.navpeII__forTotalDealsShown__c, Title, Description,navpeII__Last_Touch_Point__c,navpeII__Last_Touchpoint_ID__c FROM Contact WHERE Id IN :wrapper.contactIds WITH USER_MODE];
            for (Contact c : wrapper.relatedContacts) {
                wrapper.contactsMap.put(c.Id, c);
                if (c.AccountId != null) {
                    wrapper.accountIds.add(c.AccountId);
                    wrapper.accNameMap.put(c.AccountId, c.Account.Name);
                }
            }
        }else if (!wrapper.accountIds.isEmpty() && type == 'ALL') {
            for (Contact con : [SELECT Id, AccountId,Account.RecordType.DeveloperName FROM Contact WHERE AccountId IN :wrapper.accountIds WITH USER_MODE]) {
                wrapper.contactAccountIdMap.put(con.Id, con.AccountId);
                if (!wrapper.accountToContactIds.containsKey(con.AccountId)) {
                    wrapper.accountToContactIds.put(con.AccountId, new Set<Id>());
                }
                wrapper.accountToContactIds.get(con.AccountId).add(con.Id);
            }
        }
    }
    // Bug fixing 00051755 last touchpoint date Salauddin 25032026
    public static void getContactsLastTouchPoint(PrepCardWrapper wrapper){
        List<Id> eventIds = new List<Id>();
        List<Id> taskIds = new List<Id>();
        Map<Id,String> activitySubtypeMap = new Map<Id, String>();
        for(Contact c : wrapper.relatedContacts){
            if(c.navpeII__Last_Touchpoint_ID__c != null && c.navpeII__Last_Touch_Point__c != null){
                if (String.valueOf(c.navpeII__Last_Touchpoint_ID__c).startsWith('00U')) {
                    eventIds.add(c.navpeII__Last_Touchpoint_ID__c);
                } else if (String.valueOf(c.navpeII__Last_Touchpoint_ID__c).startsWith('00T') ) {
                    taskIds.add(c.navpeII__Last_Touchpoint_ID__c);                    
                }
                wrapper.contactLastTouchpointDate.put(c.Id, c.navpeII__Last_Touch_Point__c);                
            }
        }
        if (eventIds.size() > 0) {
            for (Event ev : [SELECT Id, EventSubtype FROM Event WHERE Id IN :eventIds WITH USER_MODE]) {
                activitySubtypeMap.put(ev.Id, ev.EventSubtype);
            }            
        }
        if (taskIds.size() > 0) {
            for (Task t : [SELECT Id, TaskSubtype FROM Task WHERE Id IN :taskIds WITH USER_MODE]) {
                activitySubtypeMap.put(t.Id, t.TaskSubtype);
            }            
        }
        for(Contact c : wrapper.relatedContacts){
            if(c.navpeII__Last_Touchpoint_ID__c != null && c.navpeII__Last_Touch_Point__c != null){
                String subtype = activitySubtypeMap.containsKey(c.navpeII__Last_Touchpoint_ID__c) ? activitySubtypeMap.get(c.navpeII__Last_Touchpoint_ID__c) : '';
                wrapper.contactLastTouchpointInfo.put(c.Id, subtype );
            }
            
        }
    }

    public static void prepareParticipantSummaries(PrepCardWrapper wrapper) {
        wrapper.contactToDealsInvolved = NavatarMeetingPrepCardUtility.getDealsInvolvedIn(new List<Id>(wrapper.contactAccountIdMap.keySet()));
        Map<Id, List<navpeII__Fundraising__c>> contactToFundraisingInvolved = NavatarMeetingPrepCardUtility.getFundRaisingInvolvedIn(new List<Id>(wrapper.contactsMap.keySet()));
        Map<Id, List<navpeII__Pipeline__c>> contactIdToDealSourced = NavatarMeetingPrepCardUtility.getContactDealsSourced(new List<Id>(wrapper.contactsMap.keySet()));
        for (Contact c : wrapper.relatedContacts) {
            String conName = c.Name ;
            String conAccountName = c.Account.Name != null ? c.Account.Name : '';
            String conTitle = c.Title != null ? c.Title : 'Not Specified';
            String conDesc = '';
            if (c.Description != null) {
                conDesc = NavatarMeetingPrepCardUtility.callPromptTemplate('Navatar_Contact_Overview', c.Id,null);
                if (conDesc.contains('Error generating prompt:')) {
                    throw new MeetingPrepCardException('Error generating participant summary for contact ');
                }
            }
            //Bug Fixing Date format 00051778,00051769 Salauddin 24032026
            String conDealInvolved = wrapper.contactToDealsInvolved.containsKey(c.Id) ? '<br/> We have Worked with ' + conName + ' on ' + wrapper.contactToDealsInvolved.get(c.Id).size() + (wrapper.contactToDealsInvolved.get(c.Id).size() == 1 ? ' deal, on ' : ' deals, the most recent one on ') +( wrapper.contactToDealsInvolved.get(c.Id)[0].navpeII__Log_In_Date__c != null ?   Datetime.newInstance(wrapper.contactToDealsInvolved.get(c.Id)[0].navpeII__Log_In_Date__c.year(), wrapper.contactToDealsInvolved.get(c.Id)[0].navpeII__Log_In_Date__c.month(), wrapper.contactToDealsInvolved.get(c.Id)[0].navpeII__Log_In_Date__c.day()).format('MMMM d, yyyy'): '') + ' ' + conAccountName +  ' is recognized as one of the target companies': ''; // Bug Fixed 00051875 Salauddin 03042026 Singular/plural fix based on count
            String conFundraisingInvolved = contactToFundraisingInvolved.containsKey(c.Id) ? '<br/> We have Worked with ' + conName + ' on ' + contactToFundraisingInvolved.get(c.Id).size() + (contactToFundraisingInvolved.get(c.Id).size() == 1 ? ' fundraising, on ' : ' fundraisings, the most recent one on ') + (contactToFundraisingInvolved.get(c.Id)[0].navpeII__Target_Close_Date__c != null ? Datetime.newInstance(contactToFundraisingInvolved.get(c.Id)[0].navpeII__Target_Close_Date__c.year(), contactToFundraisingInvolved.get(c.Id)[0].navpeII__Target_Close_Date__c.month(), contactToFundraisingInvolved.get(c.Id)[0].navpeII__Target_Close_Date__c.day()).format('MMMM d, yyyy') : '') + ' ' + (c.Account.navpeII__Total_Commitments_USD_mn__c != null ? conAccountName + ' has invested ' +  c.Account.navpeII__Total_Commitments_USD_mn__c + ' with us' : '') : ''; // Bug Fixed 00051875 Salauddin 03042026 Singular/plural fix based on count
            String conDealSourced = contactIdToDealSourced.containsKey(c.Id) ?'<br/> '+conName + ' has sourced ' + contactIdToDealSourced.get(c.Id).size() + (contactIdToDealSourced.get(c.Id).size() == 1 ? ' deal, on ' : ' deals, with the most recent being on ') + (contactIdToDealSourced.get(c.Id)[0].navpeII__Log_In_Date__c != null ? Datetime.newInstance(contactIdToDealSourced.get(c.Id)[0].navpeII__Log_In_Date__c.year(), contactIdToDealSourced.get(c.Id)[0].navpeII__Log_In_Date__c.month(), contactIdToDealSourced.get(c.Id)[0].navpeII__Log_In_Date__c.day()).format('MMMM d, yyyy') : '') +'. ' + conAccountName + ' has Sourced ' + c.Account.navpeII__forTotalDealsShown__c + (c.Account.navpeII__forTotalDealsShown__c == 1 ? ' deal to us.' : ' deals to us.'): ''; // Bug Fixed 00051875 Salauddin 03042026 Singular/plural fix based on count
            // Bug Fixing Last Interaction date 00051755 Salauddin 25032025 
            String conLastTouchpoint = '';
            if (wrapper.contactLastTouchpointInfo.containsKey(c.Id)) {
                String subtype = wrapper.contactLastTouchpointInfo.get(c.Id);
                DateTime lastTouchpointDt;
                if (wrapper.contactLastTouchpointDate.containsKey(c.Id)) {
                    lastTouchpointDt = DateTime.newInstance(wrapper.contactLastTouchpointDate.get(c.Id), Time.newInstance(0, 0, 0, 0));
                    
                }
                String formattedDate = lastTouchpointDt != null ? lastTouchpointDt.format('MMMM d, yyyy') : '';
                conLastTouchpoint = 'Our last interaction with ' + conName + ' was a ' + subtype + ' on ' + formattedDate + '. ';
            }
            wrapper.contactPromptCache.put(
                c.Id,
                '<li>' + '<a href='+wrapper.baseUrl+'/' + c.Id + '>' + conName + '</a>, ' + conTitle + ' at <a href='+wrapper.baseUrl+'/' + c.AccountId + '>' + conAccountName + '</a>: ' + conDesc + conLastTouchpoint + conDealInvolved + conFundraisingInvolved + conDealSourced + '</li>'
            );// Bug 00051550 00051553 Fixed by Shiva      
        }
    }

    public static void getUserDetails(PrepCardWrapper wrapper) {
        if (!wrapper.userIds.isEmpty()) {
            for (User u : [SELECT Id, Name, Email FROM User WHERE Id IN :wrapper.userIds WITH USER_MODE]) {
                wrapper.usersMap.put(u.Id, u);
            }
        }
    }

    public static void prepareBusinessHistory(PrepCardWrapper wrapper) {
        for (Id conId : wrapper.contactToDealsInvolved.keySet()) {
            String dealInvolved = '';
            for (navpeII__Pipeline__c pipeline : wrapper.contactToDealsInvolved.get(conId)) {
                dealInvolved += '<li><a href="' + wrapper.baseUrl + '/' + pipeline.Id + '">' + pipeline.Name + '</a>, ' + (pipeline.navpeII__Log_In_Date__c != null ? pipeline.navpeII__Log_In_Date__c.format() + ', ' : '')  + (pipeline.navpeII__Stage__c != null ? pipeline.navpeII__Stage__c : '') +'</li>';
            }
            if (!wrapper.accountDealInvolved.containsKey(wrapper.contactAccountIdMap.get(conId))) {
                wrapper.accountDealInvolved.put(wrapper.contactAccountIdMap.get(conId), dealInvolved);
            }else {
                wrapper.accountDealInvolved.put(wrapper.contactAccountIdMap.get(conId), wrapper.accountDealInvolved.get(wrapper.contactAccountIdMap.get(conId)) + dealInvolved);
            }
        } 

        wrapper.accountTopActivityList = NavatarMeetingPrepCardUtility.getFirm5RecentInteractions(wrapper.accountToContactIds); 

        wrapper.accountFutureMeetingMap = NavatarMeetingPrepCardUtility.getFirmFutureMeeting(wrapper.accountToContactIds,wrapper.eventIds);   

        Map<Id, List<navpeII__Pipeline__c>> accountIdToDealSourced = NavatarMeetingPrepCardUtility.getDealsSourced(new List<Id>(wrapper.accountIds));

        for(Id accId:accountIdToDealSourced.keySet()){
            List<navpeII__Pipeline__c> pipelines = accountIdToDealSourced.get(accId);
            String dealSourced = '';
            Integer closedCount = 0;
            for(navpeII__Pipeline__c pipeline : pipelines){
                if (pipeline.navpeII__Stage__c == 'Closed') {
                    closedCount++;
                }
            }
            //Bug Fixing formatting 00051830 Salauddin 30032026
            for (navpeII__Pipeline__c pipeline : pipelines) {
                if (dealSourced == '') {
                    dealSourced = '<h3>Deals Sourced</h3>'; // Bug Fixed 00051578 by Shiva
                    dealSourced += '<p>' + wrapper.accNameMap.get(accId) + ' has sourced ' + pipelines.size() + (pipelines.size() == 1 ? ' deal to us. The last deal sourced was on ' : ' deals to us. The last deal sourced was on ')+ (pipeline.navpeII__Log_In_Date__c != null ? pipeline.navpeII__Log_In_Date__c.format() : '') +( closedCount == 0 ? '. No deals have been closed.' : '. We closed ' + closedCount + ' of those deals.' )+' The following deals were sourced: </p>'; // Bug Fixed 00051577 by Shiva 00051875 00051831 Salauddin
                    dealSourced += '<ul>';
                }
                dealSourced += '<li><a href="' + wrapper.baseUrl + '/' + pipeline.Id + '">' + pipeline.Name + '</a>' + (pipeline.navpeII__Log_In_Date__c != null ? ', '+pipeline.navpeII__Log_In_Date__c.format() : ', ') + (pipeline.navpeII__Stage__c != null ? ', '+pipeline.navpeII__Stage__c : '') + (pipeline.navpeII__Source_Contact__r != null ? ', '+pipeline.navpeII__Source_Contact__r.Name : '') + '</li>';
            }
            if (dealSourced != '') {
                dealSourced += '</ul>';
            }
            wrapper.accountDealSourced.put(accId, dealSourced);
        }

        Map<Id, List<navpeII__Pipeline__c>> accountIdToDealHistory = NavatarMeetingPrepCardUtility.getDealsHistory(new List<Id>(wrapper.accountIds));  

        for(Id accId:accountIdToDealHistory.keySet()){
            List<navpeII__Pipeline__c> pipelines = accountIdToDealHistory.get(accId);
            String dealsHistory = '';
            
            for (navpeII__Pipeline__c pipeline : pipelines) {
                if (dealsHistory == '') {
                    dealsHistory = '<h3> Deal History</h3>'; // Bug Fixed 00051578 00051574 by Shiva 00051829 Salauddin 27032026
                    dealsHistory += '<p>' + wrapper.accNameMap.get(accId) + ' is on our watchlist as a potential investment. The following deals are listed </p>'; // Bug 00051579 Fixed by Shiva
                    dealsHistory += '<ul>';
                }
                dealsHistory += '<li><a href="' + wrapper.baseUrl + '/' + pipeline.Id + '">' + pipeline.Name + '</a>, ' + (pipeline.navpeII__Log_In_Date__c != null ? pipeline.navpeII__Log_In_Date__c.format() : '') + ', ' + (pipeline.navpeII__Stage__c != null ? pipeline.navpeII__Stage__c : '') +'</li>';//Bug Fixing 00051508 Salauddin 25022026
            }
            if (dealsHistory != '') {
                dealsHistory += '</ul>';
            }
            wrapper.accountDealHistory.put(accId, dealsHistory);
        }

        Map<Id,List<navpeII__Fundraising__c>> accountIdToFundRaisings = NavatarMeetingPrepCardUtility.getFundRaisingsHistory(new List<Id>(wrapper.accountIds));   

        for(Id accId:accountIdToFundRaisings.keySet()){
            List<navpeII__Fundraising__c> fundraisings = accountIdToFundRaisings.get(accId);
            String fundRaisingsHistory = '';
            for (navpeII__Fundraising__c fundraising : fundraisings) {
                if (fundRaisingsHistory == '') {
                    fundRaisingsHistory = '<h3> Fundraising History</h3>'; // Bug Fixed 00051578 by Shiva 00051829 Salauddin 27032026
                    fundRaisingsHistory += '<p>The following fundraisings are listed for ' + wrapper.accNameMap.get(accId) + ':</p>';
                    fundRaisingsHistory += '<ul>';
                }
                fundRaisingsHistory += '<li><a href="' + wrapper.baseUrl + '/' + fundraising.Id + '">' + fundraising.Name + '</a>, '+ '<a href="' + wrapper.baseUrl + '/' + fundraising.navpeII__Fund_Name__c + '">' + fundraising.navpeII__Fund_Name__r.Name + '</a>, ' + (fundraising.navpeII__Stage__c != null ? fundraising.navpeII__Stage__c : '') +  (fundraising.navpeII__Target_Close_Date__c != null ? ', '+fundraising.navpeII__Target_Close_Date__c.format() : '') +'</li>';
            }
            if (fundRaisingsHistory != '') {
                fundRaisingsHistory += '</ul>';
            }
            wrapper.accountFundRaisingsHistory.put(accId, fundRaisingsHistory);
        }

        Map<Id, List<navpeII__Affiliation__c>> accountIdToAffiliations = NavatarMeetingPrepCardUtility.getFormerEmployees(new List<Id>(wrapper.accountIds));
        
        for(Id accId:accountIdToAffiliations.keySet()){
            List<navpeII__Affiliation__c> affiliations = accountIdToAffiliations.get(accId);
            String formerEmployees = '';
            for (navpeII__Affiliation__c afiliation : affiliations) {
                if (formerEmployees == '') {
                    formerEmployees = '<h3> Former Employees </h3>'; // Bug Fixed 00051578 by Shiva
                    formerEmployees += '<p>The following former employees are listed for ' + wrapper.accNameMap.get(accId) + ':</p>';
                    formerEmployees += '<ul>';
                }
                formerEmployees += '<li>' + afiliation.navpeII__Contact__r.Name + ', ' + afiliation.navpeII__Role__c + ' at ' + afiliation.navpeII__Contact__r.Account.Name
                    + (afiliation.navpeII__Start_Date__c != null ? ', Start: ' + Datetime.newInstance(afiliation.navpeII__Start_Date__c.year(), afiliation.navpeII__Start_Date__c.month(), afiliation.navpeII__Start_Date__c.day()).format('MMMM d, yyyy') : '')
                    + (afiliation.navpeII__End_Date__c != null ? ', End: ' + Datetime.newInstance(afiliation.navpeII__End_Date__c.year(), afiliation.navpeII__End_Date__c.month(), afiliation.navpeII__End_Date__c.day()).format('MMMM d, yyyy') : '')
                    +'</li>';//Bug Fixing 00051678 Salauddin 13032026
            }
            if (formerEmployees != '') {
                formerEmployees += '</ul>';
            }
            wrapper.accountFormerEmployees.put(accId, formerEmployees);
        }
    }

    public static void prepareEmailsToSend(List<Event> events,PrepCardWrapper wrapper) {
        for (Event ev : events) {
            String summary = '';                
            List<String> participantSummaries = new List<String>();
            List<String> businessHistories = new List<String>();
            Set<Id> eventsAccountIds = new Set<Id>();
            Set<Id> eventContactIds = wrapper.eventToContactIds.containsKey(ev.Id) ? wrapper.eventToContactIds.get(ev.Id) : new Set<Id>(); 
            for (Id conId : eventContactIds) {
                Contact c = wrapper.contactsMap.get(conId);
                if (c != null && c.AccountId != null) {
                    eventsAccountIds.add(c.AccountId);
                }
                participantSummaries.add(wrapper.contactPromptCache.get(conId));
            } 
            for (Id accId : eventsAccountIds) {
                String history = '';
                String firmFutureMeeting = '';
                String dealSourced = '';                
                String dealsHistory = '';             
                String dealsInvolved = '';
                String fundRaisingsHistory = '';
                String formerEmployees = '';
                String accName = wrapper.accNameMap.containsKey(accId) ? wrapper.accNameMap.get(accId) : String.valueOf(accId);
                if(wrapper.accountTopActivityList.containsKey(accId)){
                    if (wrapper.accountPromptCache.containsKey(accId)) {
                        history = wrapper.accountPromptCache.get(accId);  
                                        
                    }else {
                        history = NavatarMeetingPrepCardUtility.callPromptTemplate('Navatar_Firm_Recent_Interactions', accId,JSON.serialize(wrapper.accountTopActivityList.get(accId)));
                        if (history.contains('Error generating prompt:')) {
                            throw new MeetingPrepCardException('Error generating business history for account ' + accName);
                            
                        }                        
                        Pattern p = Pattern.compile('<a\\s+href\\s*=\\s*([\'\"])\\/(.*?)\\1');
                        Matcher m = p.matcher(history);
                        Integer lastEnd = 0;
                        String result = '';
                        while (m.find()) {
                            // Append text before match
                            result += history.substring(lastEnd, m.start());
                            String quote = m.group(1);
                            String path = m.group(2);
                            // Rebuild the anchor tag with wrapper.baseUrl
                            result += '<a href=' + quote + wrapper.baseUrl + '/' + path + quote;
                            lastEnd = m.end();
                        }
                        // Append the rest of the string
                        result += history.substring(lastEnd);
                        history = result; 
                        wrapper.accountPromptCache.put(accId, history);
                    }
                } 
                if(wrapper.accountFutureMeetingMap.containsKey(accId)){
                    firmFutureMeeting = '<h3> Future Meetings </h3><ul>' + wrapper.accountFutureMeetingMap.get(accId) + '</ul>';
                }
                if(wrapper.accountDealSourced.containsKey(accId)){
                    dealSourced = wrapper.accountDealSourced.get(accId);
                }
                if(wrapper.accountDealHistory.containsKey(accId)){
                    dealsHistory = wrapper.accountDealHistory.get(accId);
                }
                if (wrapper.accountDealInvolved.containsKey(accId)) {
                    dealsInvolved = '<h3>Deals Involved In</h3>' + accName + ' contact is listed as part of the deal team. The following deals are listed: <ul>' + wrapper.accountDealInvolved.get(accId) +  '</ul>';
                }
                if(wrapper.accountFundRaisingsHistory.containsKey(accId)){
                    fundRaisingsHistory = wrapper.accountFundRaisingsHistory.get(accId);
                }
                if(wrapper.accountFormerEmployees.containsKey(accId)){
                    formerEmployees = wrapper.accountFormerEmployees.get(accId);
                }
                if(history == '' && firmFutureMeeting == '' && dealSourced == '' && dealsHistory == '' && dealsInvolved == '' && fundRaisingsHistory == '' && formerEmployees == ''){
                    businessHistories.add('<h2>Recent Interactions</h2> There is no record of any conversation with '+accName);//Bug Fixing 00051882 Salauddin 10042026
                    continue;
                }
                //Bug Fixing 00051898 Removed Business history heading Salauddin 08042026
                businessHistories.add('<h2>Recent Interactions & Business History of ' + accName + '</h2><br/>' + (String.isBlank(history) ? '<h2>Recent Interactions</h2> There is no record of any conversation with '+accName : history) + (String.isBlank(firmFutureMeeting) ? '':'<br/>' + firmFutureMeeting) + (String.isBlank(dealSourced) ? '': dealSourced + '<br/>') + (String.isBlank(dealsHistory) ? '':dealsHistory + '<br/>') + (String.isBlank(dealsInvolved) ? '':dealsInvolved + '<br/>') + (String.isBlank(fundRaisingsHistory) ? '':fundRaisingsHistory + '<br/>') + (String.isBlank(formerEmployees) ? '': formerEmployees)); // Bug Fixed 00051578 00051569 by Shiva
            }
            summary += '<h2>Meeting Participants</h2><ul>' + String.join(participantSummaries, '') + '</ul>' + String.join(businessHistories, '<br/><br/>');
            for (Id userId : wrapper.eventToUserIds.get(ev.Id)) {
                User u = wrapper.usersMap.get(userId);
                if (u != null && u.Email != null) {
                    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();

                    // Format: Month day at hour:minute AM/PM
                    String formattedDate = ev.StartDateTime.format('MMMM d \'at\' h:mm a');
                    mail.setToAddresses(new List<String>{u.Email});
                    mail.setSubject('Background for meeting ' + ev.Subject + ' on ' + formattedDate);//Bug Fxing remove " Salauddin 00051797 30032026
                    String greeting = 'Hi ' + (u.Name != null ? u.Name : 'Team') + ',<br/><br/>' +
                        'Here is the background for your upcoming meeting ' + ev.Subject + ' on ' +
                        formattedDate + '.<br/><br/>'; // Bug Fixed 00051596 by Shiva
                    summary = summary.replaceAll('\n', '<br/>');
                    mail.setHtmlBody('<div style="font-family: Calibri, Arial, sans-serif;">' + greeting+summary + '</div><br/><br/>***** This is a system generated email *********');//Bug Fixing 00051752 Salauddin 25032026
                    wrapper.emailsToSend.add(mail);
                }
            }
        }
    }

    @InvocableMethod
    public static void sendEmails(List<Id> eventIds) {
        List<Event> events = new List<Event>();
        PrepCardWrapper wrapper = new PrepCardWrapper();  
        try {
            if (eventIds == null || eventIds.isEmpty()) {
                System.debug('No eventIds provided.');
                return;
            }   
            wrapper.eventIds = eventIds;
            events = getEvents(eventIds);

            if (events.isEmpty()) {
                System.debug('No events found within the next 24 hours.');
                return;
            }

            collectRelations(events, wrapper);
            loadContacts(wrapper,'RelatedContact');
            loadContacts(wrapper, 'ALL');
            getContactsLastTouchPoint(wrapper);
            getUserDetails(wrapper);
            prepareParticipantSummaries(wrapper);
            prepareBusinessHistory(wrapper);  
            prepareEmailsToSend(events,wrapper);

            if (!wrapper.emailsToSend.isEmpty()) {
                Messaging.SendEmailResult[] results = Messaging.sendEmail(wrapper.emailsToSend, false);

                for (Messaging.SendEmailResult res : results) {
                    if (res.isSuccess()) {
                        System.debug('✅ Email sent successfully.');
                    } else {
                        for (Messaging.SendEmailError err : res.getErrors()) {
                            System.debug('❌ Failed to send email: ' + err.getMessage());
                        }
                    }
                }
            } else {
                System.debug('No valid email addresses found.');
            }
        } catch (Exception e) {
            for (Event event : events) {                
                DateTime dt = event.StartDateTime;
                Set<Id> userIds = wrapper.eventToUserIds.containsKey(event.Id) ? wrapper.eventToUserIds.get(event.Id) : new Set<Id>();
                if (userIds.isEmpty()) {
                    continue;
                }
                String emailBody ='The Meeting Prep Card for ‘' + event.Subject+'’ on '+dt.format('dd MMMM yyyy')+ ' could not be generated due to a technical issue or workflow error.<br/><br/>' +
                'Please contact your Navatar Administrator for further assistance.<br/><br/>' +
                '<i>*****This is a system generated email*****</i>';
                // Use utility class to email system admins & requested users with error message
                NavatarMeetingPrepCardUtility.sendErrorEmailToUsers('Meeting Prep Card Generation Failed ' , emailBody, userIds);
            }
            
        }
    }
}