/****************************************************************************************************
** Module Name : Meeting Prep Card (On Demand Email) 1.0 
** Description : Used to Send Meeting Prep Card on Demand on Email.
** Organization : Navatar Group
** Product Name & Version : PE Agentforce Baseline 1.0
** Revision History:-
** Version    Date(YYYY-MM-DD)    Author            Description of Action
** 1.0        2026-02-05          Salauddin Sheikh  PE Agentforce Baseline Phase 1
****************************************************************************************************/
public with sharing class NavatarMeetingPrepCardSendEmail {
   public class MeetingPrepCardException extends Exception {}

    public class RequestWrapper {
        @InvocableVariable(required=true)
        public String contactId;
    }

    public class ResponseWrapper {
        @InvocableVariable
        public String message;

        public String summary = '';
    }
 
    /**
     * Invocable method to generate Meeting Prep Card summary for a contact, send as email, and return status
     */
    @InvocableMethod(label='Generate Meeting Prep Card On Demand and Email' description='Generates a Meeting Prep Card summary for a contact, sends it as email to the logged-in user, and returns status')
    public static List<ResponseWrapper> generatePrepCardAndEmail(List<RequestWrapper> requests) {
        List<ResponseWrapper> responses = new List<ResponseWrapper>();
        RequestWrapper req = requests[0];
        User currentUser = [SELECT Id, Email,Name FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];
            
        ResponseWrapper resp = new ResponseWrapper();
        
            Set<Id> eventId = new Set<Id>();
            Set<Id> contactIds = new Set<Id>();
            Map<Id, String> accountIdToName = new Map<Id, String>();
            List<String> participantSummaries = new List<String>();
            Set<Id> accountIds = new Set<Id>();
            List<String> businessHistories = new List<String>();            
            String baseUrl = System.Url.getOrgDomainUrl().toExternalForm();
            Id contactId;

            try {
                contactId = (Id) req.contactId;
            } catch (Exception e) {
                resp.summary = 'Error: Provided Id is not a valid Salesforce Id.';
                responses.add(resp);
                return responses;
            }
            // Validate Contact Id 
            if (contactId == null || contactId.getSObjectType() != Contact.SObjectType) {
                resp.summary = 'Error: Provided Id is not a valid Contact Id.';
                responses.add(resp);
                return responses;
            }

        
            // Query next future event directly 
            List<Event> futureEvents = [
                SELECT Id, Subject, StartDateTime
                FROM Event
                WHERE StartDateTime > :System.now()
                AND Id IN (
                    SELECT EventId
                    FROM EventRelation
                    WHERE RelationId = :contactId
                )
                WITH USER_MODE
                ORDER BY StartDateTime ASC
                LIMIT 1
            ];
            
        try {

            if (futureEvents.isEmpty()) {
                resp.summary = 'Error: No future events found for this record. Meeting Prep Card generation was skipped.';//Bug fixing error message 00051774 Salauddin 30032026
                responses.add(resp);
                return responses;
            }
            System.debug('Future Events: ' + futureEvents[0]);
            Event nextEvent = futureEvents[0];

            // Get related contacts in ONE query
            List<Contact> relatedContacts = [
                SELECT Id, Name, AccountId, Account.Name,title,description, Account.navpeII__forTotalDealsShown__c, Account.navpeII__Total_Commitments_USD_mn__c, navpeII__Last_Touch_Point__c,navpeII__Last_Touchpoint_ID__c
                FROM Contact
                WHERE Id IN (
                    SELECT RelationId
                    FROM EventRelation
                    WHERE EventId = :nextEvent.Id
                    AND Relation.Type = 'Contact'
                )
                WITH USER_MODE
            ];

            System.debug('Related Contacts: ' + relatedContacts);
            if (relatedContacts.isEmpty()) {
                resp.summary = 'No contacts attached to the next event.';
                responses.add(resp);
                return responses;
            }
            Set<Id> contactInvolvedId = New Set<Id>();
            Map<Id, Id> accConID = New Map<Id, Id>();
            Set<Id> accRelatedId = New Set<Id>();
            //Bug Fixing Last Interaction date 00051773,00051763,00051772 Salauddin 25032025 Start
            Map<Id, Date> contactLastTouchpointDate = new Map<Id, Date>();
            Map<Id, String> contactLastTouchpointInfo = new Map<Id, String>();
            List<Id> eventIds = new List<Id>();
            List<Id> taskIds = new List<Id>();
            Map<Id,String> activitySubtypeMap = new Map<Id, String>();
            for(Contact con : relatedContacts){
                contactInvolvedId.add(con.id);
                if(con.AccountId != null){
                    accountIds.add(con.AccountId);
                    accountIdToName.put(con.AccountId, con.Account.Name);
                }
                if(con.navpeII__Last_Touchpoint_ID__c != null && con.navpeII__Last_Touch_Point__c != null){
                    if (String.valueOf(con.navpeII__Last_Touchpoint_ID__c).startsWith('00U')) {
                        eventIds.add(con.navpeII__Last_Touchpoint_ID__c);
                    } else if (String.valueOf(con.navpeII__Last_Touchpoint_ID__c).startsWith('00T')) {
                        taskIds.add(con.navpeII__Last_Touchpoint_ID__c);
                    }
                    contactLastTouchpointDate.put(con.Id, con.navpeII__Last_Touch_Point__c);
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
            for(Contact c : relatedContacts){
                if(c.navpeII__Last_Touchpoint_ID__c != null && c.navpeII__Last_Touch_Point__c != null){
                    String subtype = activitySubtypeMap.containsKey(c.navpeII__Last_Touchpoint_ID__c) ? activitySubtypeMap.get(c.navpeII__Last_Touchpoint_ID__c) : '';
                    contactLastTouchpointInfo.put(c.Id, subtype );
                }
                
            }

            Map<Id,Set<Id>> accountToContactIds = new Map<Id, Set<Id>>();    
            //Get all contacts related to the accounts
            for (Contact con : [SELECT Id, AccountId,Account.RecordType.DeveloperName FROM Contact WHERE AccountId IN :accountIds WITH USER_MODE]) {
                if (!accountToContactIds.containsKey(con.AccountId)) {
                    accountToContactIds.put(con.AccountId, new Set<Id>());
                }
                accountToContactIds.get(con.AccountId).add(con.Id);
                accConID.put(con.Id, con.AccountId);
                // Removed the recordType collection
            }
             
            Map<Id, List<navpeII__Pipeline__c>> contactToDealsInvolved = NavatarMeetingPrepCardUtility.getDealsInvolvedIn(new List<Id>(accConID.keySet()));
            Map<Id, List<navpeII__Fundraising__c>> contactToFundraisingInvolved = NavatarMeetingPrepCardUtility.getFundRaisingInvolvedIn(new List<Id>(contactInvolvedId));
            Map<Id, List<navpeII__Pipeline__c>> contactIdToDealSourced = NavatarMeetingPrepCardUtility.getContactDealsSourced(new List<Id>(contactInvolvedId));
            // Process contacts
            for (Contact c : relatedContacts) {
                String conName = c.Name ;
                String conAccountName = c.Account.Name != null ? c.Account.Name : '';
                String conTitle = c.Title != null ? c.Title : 'Not Specified';
                String conDesc = c.Description != null ? NavatarMeetingPrepCardUtility.callPromptTemplate('Navatar_Contact_Overview', c.Id,null) : '';
                String conDealInvolved = contactToDealsInvolved.containsKey(c.Id) ? '<br/> We have Worked with ' + conName + ' on ' + contactToDealsInvolved.get(c.Id).size() + (contactToDealsInvolved.get(c.Id).size() == 1 ? ' deal, on ' : ' deals, the most recent one on ') + (contactToDealsInvolved.get(c.Id)[0].navpeII__Log_In_Date__c != null ? Datetime.newInstance(contactToDealsInvolved.get(c.Id)[0].navpeII__Log_In_Date__c.year(), contactToDealsInvolved.get(c.Id)[0].navpeII__Log_In_Date__c.month(), contactToDealsInvolved.get(c.Id)[0].navpeII__Log_In_Date__c.day()).format('MMMM d') : '') + ', ' + conAccountName +  ' is recognized as one of the target companies.': '';// Bug Fixed 00051875 Salauddin 03042026 Singular/plural fix based on count
                String conFundraisingInvolved = contactToFundraisingInvolved.containsKey(c.Id) ? '<br/> We have Worked with ' + conName + ' on ' + contactToFundraisingInvolved.get(c.Id).size() + (contactToFundraisingInvolved.get(c.Id).size() == 1 ? ' fundraising, on ' : ' fundraisings, the most recent one on ') + (contactToFundraisingInvolved.get(c.Id)[0].navpeII__Target_Close_Date__c != null ? Datetime.newInstance(contactToFundraisingInvolved.get(c.Id)[0].navpeII__Target_Close_Date__c.year(), contactToFundraisingInvolved.get(c.Id)[0].navpeII__Target_Close_Date__c.month(), contactToFundraisingInvolved.get(c.Id)[0].navpeII__Target_Close_Date__c.day()).format('MMMM d') : '') + ' ' + (c.Account.navpeII__Total_Commitments_USD_mn__c != null ? conAccountName + ' has invested ' +  c.Account.navpeII__Total_Commitments_USD_mn__c + ' with us' : '') : '';// Bug Fixed 00051875 Salauddin 03042026 Singular/plural fix based on count
                
                

                String conDealSourced = contactIdToDealSourced.containsKey(c.Id) ?'<br/> '+conName + ' has sourced ' + contactIdToDealSourced.get(c.Id).size() + (contactIdToDealSourced.get(c.Id).size() == 1 ? ' deal, on ' : ' deals, with the most recent being on ') + (contactIdToDealSourced.get(c.Id)[0]?.navpeII__Log_In_Date__c != null ? Datetime.newInstance(contactIdToDealSourced.get(c.Id)[0].navpeII__Log_In_Date__c.year(), contactIdToDealSourced.get(c.Id)[0].navpeII__Log_In_Date__c.month(), contactIdToDealSourced.get(c.Id)[0].navpeII__Log_In_Date__c.day()).format('MMMM d') : '') +'. ' + conAccountName + ' has Sourced ' + c.Account?.navpeII__forTotalDealsShown__c + (c.Account?.navpeII__forTotalDealsShown__c == 1 ? ' deal to us.' : ' deals to us.'): '';// Bug Fixed 00051875 Salauddin 03042026 Singular/plural fix based on count
                String conLastTouchpoint = '';
                if (contactLastTouchpointInfo.containsKey(c.Id)) {
                    String subtype = contactLastTouchpointInfo.get(c.Id);
                    DateTime lastTouchpointDt;
                    if (contactLastTouchpointDate.containsKey(c.Id)) {                        
                        // Convert Date to DateTime at midnight
                        lastTouchpointDt = DateTime.newInstance(contactLastTouchpointDate.get(c.Id), Time.newInstance(0, 0, 0, 0));
                    }
                    String formattedDate = lastTouchpointDt != null ? lastTouchpointDt.format('MMMM d, yyyy') : '';
                    conLastTouchpoint = 'Our last interaction with ' + conName + ' was a ' + subtype + ' on ' + formattedDate + '. ';
                }
                // Bug 00051550 00051553 Fixed by Shiva
                participantSummaries.add(
                    '<li>' + '<a href=' + baseUrl +'/' + c.Id + '>' + conName + '</a>, ' + conTitle + ' at <a href=' + baseUrl +'/' + c.AccountId + '>' + conAccountName + '</a>: ' + conDesc + conLastTouchpoint + conDealInvolved + conFundraisingInvolved + conDealSourced +'</li>'
                );//Bug Fixing 00051693 Salauddin 17032026
                //Bug Fixing Last Interaction date 00051773,00051763,00051772 Salauddin 25032025 End 
                if (c.AccountId != null) {
                    accountIds.add(c.AccountId);
                    accountIdToName.put(c.AccountId, c.Account.Name);
                }
            }

            
            Map<Id,List<Map<String, Object>>> accountTopActivityList = NavatarMeetingPrepCardUtility.getFirm5RecentInteractions(accountToContactIds);   
            system.debug('Account Top Activity List: ' + accountTopActivityList); 
            Map<Id, String> accountFutureMeetingMap = NavatarMeetingPrepCardUtility.getFirmFutureMeeting(accountToContactIds,new List<Id>{nextEvent.Id});   
            Map<Id, List<navpeII__Pipeline__c>> accountIdToDealSourced = new Map<Id, List<navpeII__Pipeline__c>>();

            // Removed the recordType condition
            accountIdToDealSourced = NavatarMeetingPrepCardUtility.getDealsSourced(new List<Id>(accountToContactIds.keySet()));  

            Map<Id, String> accountDealSourced = new Map<Id, String>();
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
                        dealSourced += '<p>' + accountIdToName.get(accId) + ' has sourced ' + pipelines.size() + (pipelines.size() == 1 ? ' deal to us. The last deal sourced was on ' : ' deals to us. The last deal sourced was on ')+ (pipeline.navpeII__Log_In_Date__c != null ? pipeline.navpeII__Log_In_Date__c.format() : 'Unknown Date') +( closedCount == 0 ? '. No deals have been closed.' : '. We closed ' + closedCount + ' of those deals.' )+' The following deals were sourced: </p>'; // Bug Fixed 00051577 by Shiva// Bug Fixed 00051875 Salauddin 03042026 Singular/plural fix based on count
                        dealSourced += '<ul>';
                    }
                    dealSourced += '<li><a href="' + baseUrl + '/' + pipeline.Id + '">' + pipeline.Name + '</a>' + (pipeline.navpeII__Log_In_Date__c != null ? ', '+pipeline.navpeII__Log_In_Date__c.format() : ', Unknown Date') + (pipeline.navpeII__Stage__c != null ? ', '+pipeline.navpeII__Stage__c : '') + (pipeline.navpeII__Source_Contact__r != null ? ', '+pipeline.navpeII__Source_Contact__r.Name : '') + '</li>';
                }
                if (dealSourced != '') {
                    dealSourced += '</ul>';
                }
                accountDealSourced.put(accId, dealSourced);
            }

            Map<Id, String> accountIdToDealInvolved = new Map<Id, String>();
            for (Id conId : contactToDealsInvolved.keySet()) {
                String dealInvolved = '';
                for (navpeII__Pipeline__c pipeline : contactToDealsInvolved.get(conId)) {
                    dealInvolved += '<li><a href="' + baseUrl + '/' + pipeline.Id + '">' + pipeline.Name + '</a>, ' + (pipeline.navpeII__Log_In_Date__c != null ? pipeline.navpeII__Log_In_Date__c.format() + ', ' : '')  + (pipeline.navpeII__Stage__c != null ? pipeline.navpeII__Stage__c : '') +'</li>';
                }
                if (!accountIdToDealInvolved.containsKey(accConID.get(conId))) {
                    accountIdToDealInvolved.put(accConID.get(conId), dealInvolved);
                }else {
                    accountIdToDealInvolved.put(accConID.get(conId), accountIdToDealInvolved.get(accConID.get(conId)) + dealInvolved);
                }
            }
            
            Map<Id, List<navpeII__Pipeline__c>> accountIdToDealHistory = new Map<Id, List<navpeII__Pipeline__c>>();

            // Removed the recordType condition
            accountIdToDealHistory = NavatarMeetingPrepCardUtility.getDealsHistory(new List<Id>(accountToContactIds.keySet()));

            Map<Id, String> accountDealHistory = new Map<Id, String>();
             for(Id accId:accountIdToDealHistory.keySet()){
                List<navpeII__Pipeline__c> pipelines = accountIdToDealHistory.get(accId);
                String dealsHistory = '';
                
                for (navpeII__Pipeline__c pipeline : pipelines) {
                    if (dealsHistory == '') {
                        dealsHistory = '<h3> Deal History</h3>'; // Bug Fixed 00051578 00051574 by Shiva 00051829 Salauddin 27032026
                        dealsHistory += '<p>' + accountIdToName.get(accId) + ' is on our watchlist as a potential investment. The following deals are listed </p>'; // Bug 00051579 Fixed by Shiva
                        dealsHistory += '<ul>';
                    }
                    dealsHistory += '<li><a href="' + baseUrl + '/' + pipeline.Id + '">' + pipeline.Name + '</a>, ' + (pipeline.navpeII__Log_In_Date__c != null ? pipeline.navpeII__Log_In_Date__c.format() : '') + ', ' + (pipeline.navpeII__Stage__c != null ? pipeline.navpeII__Stage__c : '') +'</li>';//Bug Fixing 00051508 Salauddin 25022026
                }
                if (dealsHistory != '') {
                    dealsHistory += '</ul>';
                }
                accountDealHistory.put(accId, dealsHistory);
            }
            Map<Id,List<navpeII__Fundraising__c>> accountIdToFundRaisings = new Map<Id, List<navpeII__Fundraising__c>>();

            // Removed the recordType condition
            accountIdToFundRaisings = NavatarMeetingPrepCardUtility.getFundRaisingsHistory(new List<Id>(accountToContactIds.keySet()));

            Map<Id, String> accountFundRaisingsHistory = new Map<Id, String>();
            for(Id accId:accountIdToFundRaisings.keySet()){
                List<navpeII__Fundraising__c> fundraisings = accountIdToFundRaisings.get(accId);
                String fundRaisingsHistory = '';
                for (navpeII__Fundraising__c fundraising : fundraisings) {
                    if (fundRaisingsHistory == '') {
                        fundRaisingsHistory = '<h3> Fundraising History</h3>'; // Bug Fixed 00051578 by Shiva 00051829 Salauddin 27032026
                        fundRaisingsHistory += '<p>The following fundraisings are listed for ' + accountIdToName.get(accId) + ':</p>';
                        fundRaisingsHistory += '<ul>';
                    }
                    fundRaisingsHistory += '<li><a href="' + baseUrl + '/' + fundraising.Id + '">' + fundraising.Name + '</a>, '+ '<a href="' + baseUrl + '/' + fundraising.navpeII__Fund_Name__c + '">' + fundraising.navpeII__Fund_Name__r.Name + '</a>, ' + (fundraising.navpeII__Stage__c != null ? fundraising.navpeII__Stage__c : '') +  (fundraising.navpeII__Target_Close_Date__c != null ? ', '+fundraising.navpeII__Target_Close_Date__c.format() : '') +'</li>';
                }
                if (fundRaisingsHistory != '') {
                    fundRaisingsHistory += '</ul>';
                }
                accountFundRaisingsHistory.put(accId, fundRaisingsHistory);
            }
            Map<Id, List<navpeII__Affiliation__c>> accountIdToAffiliations = NavatarMeetingPrepCardUtility.getFormerEmployees(new List<Id>(accountIds));
             Map<Id, String> accountFormerEmployees = new Map<Id, String>();
            for(Id accId:accountIdToAffiliations.keySet()){
                List<navpeII__Affiliation__c> affiliations = accountIdToAffiliations.get(accId);
                String formerEmployees = '';
                for (navpeII__Affiliation__c afiliation : affiliations) {
                    if (formerEmployees == '') {
                        formerEmployees = '<h3> Former Employees </h3>'; // Bug Fixed 00051578 by Shiva
                        formerEmployees += '<p>The following former employees are listed for ' + accountIdToName.get(accId) + ':</p>';
                        formerEmployees += '<ul>';
                    }
                    formerEmployees += '<li>' + afiliation.navpeII__Contact__r.Name + ', ' + afiliation.navpeII__Role__c + ' at ' + afiliation.navpeII__Contact__r.Account.Name  +  + (afiliation.navpeII__Start_Date__c != null ? ', Start: ' + Datetime.newInstance(afiliation.navpeII__Start_Date__c.year(), afiliation.navpeII__Start_Date__c.month(), afiliation.navpeII__Start_Date__c.day()).format('MMMM d, yyyy') : '')
                    + (afiliation.navpeII__End_Date__c != null ? ', End: ' + Datetime.newInstance(afiliation.navpeII__End_Date__c.year(), afiliation.navpeII__End_Date__c.month(), afiliation.navpeII__End_Date__c.day()).format('MMMM d, yyyy') : '') + '</li>';//Bug Fixing 00051508 Salauddin 25022026
                }
                if (formerEmployees != '') {
                    formerEmployees += '</ul>';
                }
                accountFormerEmployees.put(accId, formerEmployees);
            }
            for (Id accId : accountIds) {
                String history = '';
                String firmFutureMeeting = '';
                String dealSourced = '';                
                String dealsHistory = '';
                String dealsInvolved = '';
                String fundRaisingsHistory = '';
                String formerEmployees = '';
                String accName = accountIdToName.containsKey(accId) ? accountIdToName.get(accId) : String.valueOf(accId);
                if(accountTopActivityList.containsKey(accId)){
                    history = NavatarMeetingPrepCardUtility.callPromptTemplate('Navatar_Firm_Recent_Interactions', accId,JSON.serialize(accountTopActivityList.get(accId)));
                } 
                if(accountFutureMeetingMap.containsKey(accId)){
                    firmFutureMeeting = '<h3> Future Meetings </h3><ul>' + accountFutureMeetingMap.get(accId) + '</ul>';
                }
                if(accountIdToDealSourced.containsKey(accId)){
                    dealSourced = accountDealSourced.get(accId);
                }
                if(accountIdToDealHistory.containsKey(accId)){
                    dealsHistory = accountDealHistory.get(accId);
                }
                if(accountIdToDealInvolved.containsKey(accId)){
                    dealsInvolved = '<h3>Deals Involved In</h3>' + accName + ' contact is listed as part of the deal team. The following deals are listed: <ul>' + accountIdToDealInvolved.get(accId) +  '</ul>';
                }
                if(accountIdToFundRaisings.containsKey(accId)){
                    fundRaisingsHistory = accountFundRaisingsHistory.get(accId);
                }
                if(accountIdToAffiliations.containsKey(accId)){
                    formerEmployees = accountFormerEmployees.get(accId);
                }
                if(history == '' && firmFutureMeeting == '' && dealSourced == '' && dealsHistory == '' && dealsInvolved == '' && fundRaisingsHistory == '' && formerEmployees == ''){
                    businessHistories.add('<h2>Recent Interactions</h3> There is no record of any conversation with '+accName);//Bug Fixing 00051882 Salauddin 10042026
                    continue;
                }
                //Bug Fixing 00051898 Removed Business history heading Salauddin 08042026
                businessHistories.add('<h2>Recent Interactions & Business History of ' + accName + '</h2><br/>' + (String.isBlank(history) ? '<h2>Recent Interactions</h2> There is no record of any conversation with '+accName : history) + (String.isBlank(firmFutureMeeting) ? '':'<br/>' + firmFutureMeeting) + (String.isBlank(dealSourced) ? '': dealSourced + '<br/>') + (String.isBlank(dealsHistory) ? '':dealsHistory + '<br/>') + (String.isBlank(dealsInvolved) ? '':dealsInvolved + '<br/>') + (String.isBlank(fundRaisingsHistory) ? '':fundRaisingsHistory + '<br/>') + (String.isBlank(formerEmployees) ? '': formerEmployees)); // Bug Fixed 00051578 00051569 by Shiva
            }

            // Send email to logged-in user (HTML body) with dynamic subject and greeting
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setToAddresses(new String[] { currentUser.Email });
            // Merge all responses with new formatting
            //Bug Fix 00051080 02022026
            String eventSubject = (nextEvent.Subject != null) ? nextEvent.Subject : '';
            String eventDateTimeStr = '';
            if (nextEvent.StartDateTime != null) {
                // Format as 'MMM d at hA' (e.g., Dec 8 at 2PM)
                DateTime dt = nextEvent.StartDateTime;
                String month = dt.format('MMM');
                String day = String.valueOf(dt.day());
                Integer hour = dt.hour();
                String ampm = hour >= 12 ? 'pm' : 'am';
                Integer hour12 = Math.mod(hour, 12) == 0 ? 12 : Math.mod(hour, 12);
                eventDateTimeStr = month + ' ' + day + ' at ' + String.valueOf(hour12) + ampm;
            }
            resp.summary += '<h2>Meeting Participants</h2><ul>' + String.join(participantSummaries, '') + '</ul>' +
                String.join(businessHistories, '<br/><br/>');
            String userName = (currentUser != null && currentUser.Name != null) ? currentUser.Name : '';
            String subjectLine = 'Background for meeting ' + eventSubject;
            if (eventDateTimeStr != '') {
                subjectLine += ' on ' + eventDateTimeStr;
            }
            mail.setSubject(subjectLine);
            String greeting = 'Hi ' + userName + ',<br/><br/>Here is the background for your upcoming meeting ' + eventSubject;
            if (eventDateTimeStr != '') {
                greeting += ' on ' + eventDateTimeStr;
            }
            greeting += '<br/><br/>';
            mail.setHtmlBody('<div style="font-family: Calibri, Arial, sans-serif;">' + greeting + resp.summary + '</div>');
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });

            resp.message = 'Success: Meeting Prep Card summary generated and emailed.';
        } catch (Exception e) {
            resp.message = 'Error: ' + e.getMessage();
            // Bug 00050944 Fixed by Sudhanshu
            DateTime dt = futureEvents[0].StartDateTime;
            Set<Id> userIds = new Set<Id>{currentUser.Id};
            // Bug 00050944 Fixed by Sudhanshu
            String emailBody ='The Meeting Prep Card for ‘' + futureEvents[0].Subject+'’ on '+dt.format('dd MMMM yyyy')+ ' could not be generated due to a technical issue or workflow error.<br/><br/>' +
            'Please contact your Navatar Administrator for further assistance.<br/><br/>' +
            '<i>*****This is a system generated email*****</i>';
            // Use utility class to email system admins & requested users with error message
            NavatarMeetingPrepCardUtility.sendErrorEmailToUsers('Meeting Prep Card Generation Failed ' , emailBody, userIds);
        }
        responses.add(resp);
    
        return responses;
    }
}