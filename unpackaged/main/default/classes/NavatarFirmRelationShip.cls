/****************************************************************************************************
** Module Name : Firm RelationShip Summary 1.0 
** Description : Get the RelationShip Summary for a given Account.
** Organization : Navatar Group
** Product Name & Version : PE Agentforce Baseline 1.0
** Revision History:-
** Version    Date(YYYY-MM-DD)    Author            Description of Action
** 1.0        2026-03-10          Sudhanshu         PE Agentforce Baseline Phase 1
****************************************************************************************************/

public with sharing class NavatarFirmRelationShip {
    public class Request {
        @InvocableVariable(required =true)
        public Account Account;
    }

    public class Response {
        @InvocableVariable(required=true)
        public String Prompt;
    }

    @InvocableMethod(label='Firm Relationship Summary' description='Returns relationship summary for a given Account Id')
    public static List<Response> getFirmRelationship(List<Request> requests) {
        List<Response> responses = new List<Response>();
        try{
            
            ID recordId = requests[0].Account.Id;
            Account acc = [SELECT Id, Name, Industry, NumberOfEmployees, RecordType.DeveloperName, navpeII__Total_Commitments_USD_mn__c,navpeII__forTotalDealsShown__c,
            (SELECT Id, Name, Title, Email,AccountId FROM Contacts) FROM Account WHERE Id =: recordId WITH USER_MODE LIMIT 1];
            System.debug('Record Details: ' + acc);
            String formattedResponse = '<h2>Overview </h2>';  // bug 00051823 fixed by Sudhanshu
            String firmDescription = NavatarMeetingPrepCardUtility.callPromptTemplate('Navatar_Firm_Overview', recordId, null);
            if(firmDescription != null && !firmDescription.contains('Error generating prompt:')) {
                formattedResponse += '<p>' + firmDescription + '</p>';
            }
            if(acc.recordType.developerName == 'Company')
            {
                if(acc.NumberOfEmployees != null && acc.Industry != null) {
                    formattedResponse += '<p>'+acc.Name+' employs approximately '+acc.NumberOfEmployees+' individuals and operates in the '+acc.Industry+' industry; '+acc.Name+' is a target company for us.</p>';
                }
                else if(acc.NumberOfEmployees != null && acc.Industry == null) {
                    formattedResponse += '<p>'+acc.Name+' employs approximately '+acc.NumberOfEmployees+' individuals; '+acc.Name+' is a target company for us.</p>';
                }
                else if(acc.NumberOfEmployees == null && acc.Industry != null) {
                    formattedResponse += '<p>'+acc.Name+' operates in the '+acc.Industry+' industry; '+acc.Name+' is a target company for us.</p>';
                }
            }
            else if(acc.recordType.developerName == 'Institution')
            {
                if(acc.navpeII__Total_Commitments_USD_mn__c != null) {
                    formattedResponse += '<p>'+acc.Name+' has invested $'+acc.navpeII__Total_Commitments_USD_mn__c+' with us.</p>';
                }
            }
            else if(acc.recordType.developerName == 'Intermediary')
            {
                if(acc.navpeII__forTotalDealsShown__c != null) {
                   formattedResponse += '<p>'+acc.Name+' has sourced '+acc.navpeII__forTotalDealsShown__c+(acc.navpeII__forTotalDealsShown__c == 1 ? ' deal to us.' : ' deals to us.')+'</p>'; // Bug Fixed 00051875,00051900 Salauddin 03042026 Singular/plural fix based on count
                }
            }

            // formattedResponse += '<br/> <b>Contacts</b> <br/>Our Main Contacts: <ul> ';
            // bug 00051823 fixed by Sudhanshu
            String contactHeading = acc.Contacts.size() > 0 ? '<br/> <h2>Contacts</h2> <br/>Our Main Contacts: <ul> ':'';
            formattedResponse += contactHeading;
            Set<Id> contactIds = new Set<Id>();
            Integer minCount = 2;
            Boolean hasActivities = false;
            Map<Id, Contact> contactMap = new Map<Id, Contact>();
            Map<Id, Set<Id>> accountToContactIds = new Map<Id, Set<Id>>();
            Map<Id, String> accountDealSourced = new Map<Id, String>();
            Map<Id, String> accountDealHistory = new Map<Id, String>();
            Map<Id, String> accountFundRaisingsHistory = new Map<Id, String>();
            Map<Id, String> accountFormerEmployees = new Map<Id, String>();
            Map<Id, String> accountDealsInvolved = new Map<Id, String>();
            List<String> businessHistories = new List<String>(); 
            String baseUrl = System.Url.getOrgDomainUrl().toExternalForm();
            accountToContactIds.put(acc.Id, new Set<Id>());
            for(Contact con : acc.Contacts) {
                contactIds.add(con.Id);
                contactMap.put(con.Id, con);
                if (!accountToContactIds.containsKey(con.AccountId)) {
                    accountToContactIds.put(con.AccountId, new Set<Id>());
                }
                accountToContactIds.get(con.AccountId).add(con.Id);
            }

            // Per-contact unique activity sets (to avoid double counting if WhoId + Relation exist for same activity)
            Map<Id, Set<Id>> taskIdsByContact  = new Map<Id, Set<Id>>();
            Map<Id, Set<Id>> eventIdsByContact = new Map<Id, Set<Id>>();

        
            
            // Tasks via TaskRelation (shared activities / additional contacts)
            for (TaskRelation tr : [
                            SELECT TaskId, RelationId
                            FROM TaskRelation
                            WHERE RelationId IN :contactIds
                                AND Task.TaskSubType = 'Call' AND Task.IsDeleted = false WITH SECURITY_ENFORCED LIMIT :(Limits.getLimitQueryRows() - Limits.getQueryRows()) ALL ROWS
                    ]) {
                if (tr.RelationId == null || tr.TaskId == null) continue;
                addToSet(taskIdsByContact, (Id)tr.RelationId, tr.TaskId);
            }

            //  Events via EventRelation (invitees/related contacts)
            for (EventRelation er : [ SELECT EventId, RelationId FROM EventRelation  WHERE RelationId IN :contactIds AND IsDeleted = false WITH USER_MODE LIMIT :(Limits.getLimitQueryRows() - Limits.getQueryRows()) ALL ROWS]) 
            { 
                if (er.RelationId == null || er.EventId == null) continue;
                addToSet(eventIdsByContact, (Id)er.RelationId, er.EventId);
            }

            // Compute totals per contact (unique TaskIds + unique EventIds)
            Map<Id, Integer> totalCountByContact = new Map<Id, Integer>();
            for (Id cId : contactIds) {
                Integer tCount = taskIdsByContact.containsKey(cId) ? taskIdsByContact.get(cId).size() : 0;
                Integer eCount = eventIdsByContact.containsKey(cId) ? eventIdsByContact.get(cId).size() : 0;
                Integer total  = tCount + eCount;
                if (total >= minCount) {
                    totalCountByContact.put(cId, total);
                }
                else {
                    hasActivities = true;
                }
            }

            for (Id cId : totalCountByContact.keySet()) {
                Contact c = contactMap.get(cId);
                if(c != null){
                    formattedResponse += '<li>'+c.Name +(c.Title != null ? ', ' + c.Title : '') +'</li>';
                }
            }
            formattedResponse += '</ul>';
            if(hasActivities == true){
                formattedResponse += '<br/>Though there are contacts listed in the system, there has not been any communication with any, implying that we may not have any relationships.';
            }

            Map<Id,List<Map<String, Object>>> accountTopActivityList = NavatarMeetingPrepCardUtility.getFirm5RecentInteractions(accountToContactIds); 
            
            if(accountTopActivityList.containsKey(recordId))
            {
                System.debug('Top Recent Interactions: ' + JSON.serialize(accountTopActivityList.get(recordId)));
                String result = NavatarMeetingPrepCardUtility.callPromptTemplate('Navatar_Firm_Recent_Interactions', recordId, JSON.serialize(accountTopActivityList.get(recordId)));
                if(result != null && !result.contains('Error generating prompt:')) {
                    formattedResponse += '<br/><br/>'+result;
                }
            }
            else {
                // Bug AA-643 fixed by Sudhanshu
                formattedResponse += '<br/><br/><h2>Recent Interactions</h2><p>There is no record of any conversation with ' + acc.Name + '.</p>';
            }
            List<Id> eventIds = new List<Id>();
            Map<Id, String> accountFutureMeetingMap = NavatarMeetingPrepCardUtility.getFirmFutureMeeting(accountToContactIds,eventIds);   
            if(accountFutureMeetingMap.containsKey(recordId)){
                // bug 00051823 fixed by Sudhanshu
                formattedResponse += '<br/><br/><h3> Future Meetings </h3><ul>' + accountFutureMeetingMap.get(recordId) + '</ul>';
            }

            Map<Id, List<navpeII__Pipeline__c>> accountIdToDealSourced = NavatarMeetingPrepCardUtility.getDealsSourced(new List<Id>{recordId});
            for(Id accId:accountIdToDealSourced.keySet()){
                List<navpeII__Pipeline__c> pipelines = accountIdToDealSourced.get(accId);
                String dealSourced = '';
                Integer closedCount = 0;
                for(navpeII__Pipeline__c pipeline : pipelines){
                    if (pipeline.navpeII__Stage__c == 'Closed') {
                        closedCount++;
                    }
                }
                for (navpeII__Pipeline__c pipeline : pipelines) {
                    if (dealSourced == '') {
                        dealSourced = '<h3>Deals Sourced</h3>'; // bug 00051823 fixed by Sudhanshu 
                        dealSourced += '<p>' + acc.Name + ' has sourced ' + pipelines.size() + (pipelines.size() == 1 ? ' deal to us, with the most recent deal sourced on ' : ' deals to us, with the most recent deal sourced on ') + (pipeline.navpeII__Log_In_Date__c != null ? Datetime.newInstance(pipeline.navpeII__Log_In_Date__c.year(), pipeline.navpeII__Log_In_Date__c.month(), pipeline.navpeII__Log_In_Date__c.day()).format('MMMM d, yyyy') : '') +( closedCount == 0 ? '. No deals have been closed.' : '. We closed ' + closedCount + ' of those deals.' ); // Bug Fixed 00051875,00051900 Salauddin 03042026 Singular/plural fix based on count
                    	dealSourced +='<ul>';
                    }
                     // Bug 00051798 fixed by Sudhanshu
                    dealSourced += '<li><a href="/' + pipeline.Id + '">' + pipeline.Name + '</a>' + (pipeline.navpeII__Log_In_Date__c != null ? ', '+Datetime.newInstance(pipeline.navpeII__Log_In_Date__c.year(), pipeline.navpeII__Log_In_Date__c.month(), pipeline.navpeII__Log_In_Date__c.day()).format('MMMM d, yyyy') : ', ') + (pipeline.navpeII__Stage__c != null ? ', '+pipeline.navpeII__Stage__c : '') + (pipeline.navpeII__Source_Contact__r != null ? ', '+pipeline.navpeII__Source_Contact__r.Name : '') + '</li>';
                }
                if (dealSourced != '') {
                    dealSourced += '</ul>';
                }
                accountDealSourced.put(accId, dealSourced);
            }

            Map<Id, List<navpeII__Pipeline__c>> accountIdToDealHistory = NavatarMeetingPrepCardUtility.getDealsHistory(new List<Id>{recordId});            
            for(Id accId:accountIdToDealHistory.keySet()){
                List<navpeII__Pipeline__c> pipelines = accountIdToDealHistory.get(accId);
                String dealsHistory = '';
                    
                for (navpeII__Pipeline__c pipeline : pipelines) {
                    if (dealsHistory == '') {
                        // Bug 00051822 Fixed by Sudhanshu
                        dealsHistory = '<h3> Deal History</h3>'; // bug 00051823 fixed by Sudhanshu
                        dealsHistory += '<p>' + acc.Name + ' is on our watchlist as a potential investment. The following deals are listed: </p>'; 
                        dealsHistory += '<ul>';
                    }
                    // Bug 00051798 fixed by Sudhanshu
                    dealsHistory += '<li><a href="/' + pipeline.Id + '">' + pipeline.Name + '</a>, ' + (pipeline.navpeII__Log_In_Date__c != null ? Datetime.newInstance(pipeline.navpeII__Log_In_Date__c.year(), pipeline.navpeII__Log_In_Date__c.month(), pipeline.navpeII__Log_In_Date__c.day()).format('MMMM d, yyyy') : '') + ', ' + (pipeline.navpeII__Stage__c != null ? pipeline.navpeII__Stage__c : '') +'</li>';
                }
                if (dealsHistory != '') {
                    dealsHistory += '</ul>';
                }
                accountDealHistory.put(accId, dealsHistory);
            }

            Map<Id,List<navpeII__Fundraising__c>> accountIdToFundRaisings = NavatarMeetingPrepCardUtility.getFundRaisingsHistory(new List<Id>{recordId});            
            for(Id accId:accountIdToFundRaisings.keySet()){
                List<navpeII__Fundraising__c> fundraisings = accountIdToFundRaisings.get(accId);
                String fundRaisingsHistory = '';
                for (navpeII__Fundraising__c fundraising : fundraisings) {
                    if (fundRaisingsHistory == '') {
                        // Bug 00051822 Fixed by Sudhanshu
                        fundRaisingsHistory = '<h3> Fundraising History</h3>'; // bug 00051823 fixed by Sudhanshu 
                        fundRaisingsHistory += '<p>The following fundraisings are listed for ' + acc.Name + ':</p>';
                        fundRaisingsHistory += '<ul>';
                    }
                    // Bug 00051798 fixed by Sudhanshu
                    fundRaisingsHistory += '<li><a href="/' + fundraising.Id + '">' + fundraising.Name + '</a>, '+ '<a href="/' + fundraising.navpeII__Fund_Name__c + '">' + fundraising.navpeII__Fund_Name__r.Name + '</a>, ' + (fundraising.navpeII__Stage__c != null ? fundraising.navpeII__Stage__c : '') +  (fundraising.navpeII__Target_Close_Date__c != null ? ', '+Datetime.newInstance(fundraising.navpeII__Target_Close_Date__c.year(), fundraising.navpeII__Target_Close_Date__c.month(), fundraising.navpeII__Target_Close_Date__c.day()).format('MMMM d, yyyy') : '') +'</li>';
                }
                if (fundRaisingsHistory != '') {
                    fundRaisingsHistory += '</ul>';
                }
                accountFundRaisingsHistory.put(accId, fundRaisingsHistory);
            }

            Map<Id, List<navpeII__Affiliation__c>> accountIdToAffiliations = NavatarMeetingPrepCardUtility.getFormerEmployees(new List<Id>{recordId});
            for(Id accId:accountIdToAffiliations.keySet()){
                List<navpeII__Affiliation__c> affiliations = accountIdToAffiliations.get(accId);
                String formerEmployees = '';
                for (navpeII__Affiliation__c afiliation : affiliations) {
                    if (formerEmployees == '') {
                        formerEmployees = '<h3> Former Employees </h3>'; // bug 00051823 fixed by Sudhanshu
                        formerEmployees += '<p>The following former employees are listed for ' + acc.Name + ':</p>';
                        formerEmployees += '<ul>';
                    }
                    formerEmployees += '<li>' + afiliation.navpeII__Contact__r.Name + ', ' + afiliation.navpeII__Role__c + ' at ' + afiliation.navpeII__Contact__r.Account.Name  + (afiliation.navpeII__Start_Date__c != null ? ', Start: '+Datetime.newInstance(afiliation.navpeII__Start_Date__c.year(), afiliation.navpeII__Start_Date__c.month(), afiliation.navpeII__Start_Date__c.day()).format('MMMM d, yyyy')  : '') + (afiliation.navpeII__End_Date__c != null ? ', End: '+Datetime.newInstance(afiliation.navpeII__End_Date__c.year(), afiliation.navpeII__End_Date__c.month(), afiliation.navpeII__End_Date__c.day()).format('MMMM d, yyyy')  : '') +'</li>';
                }
                if (formerEmployees != '') {
                    formerEmployees += '</ul>';
                }
                accountFormerEmployees.put(accId, formerEmployees);
            }
            // Bug 00051877 fixed by Sudhanshu
            // Map<Id, List<navpeII__Pipeline__c>> accountIdToDealInvolved = NavatarMeetingPrepCardUtility.getDealsInvolvedIn(new List<Id>(contactIds));
            // for(Id conId:accountIdToDealInvolved.keySet()){
            //     List<navpeII__Pipeline__c> dealsInvolved = accountIdToDealInvolved.get(conId);
            //     String dealsInvolvedHistory = '';
            //     for (navpeII__Pipeline__c deal : dealsInvolved) {
            //         if (dealsInvolvedHistory == '') {
            //             dealsInvolvedHistory = '<h3> Deals Involved In  </h3>'; 
            //             dealsInvolvedHistory += '<p>'+acc.Name+'’s contact is listed as part of the deal team. The following deals are listed:</p>';
            //             dealsInvolvedHistory += '<ul>';
            //         }
            //         dealsInvolvedHistory += '<li>' + deal.Name + ', ' + (deal.navpeII__Log_In_Date__c != null ? ', '+Datetime.newInstance(deal.navpeII__Log_In_Date__c.year(), deal.navpeII__Log_In_Date__c.month(), deal.navpeII__Log_In_Date__c.day()).format('MMMM d, yyyy')  : '') + (deal.navpeII__Stage__c != null ? ', '+deal.navpeII__Stage__c : '') +'</li>';
            //     }
            //     if (dealsInvolvedHistory != '') {
            //         dealsInvolvedHistory += '</ul>';
            //     }
            //     accountDealsInvolved.put(conId, dealsInvolvedHistory);
            // }
            // System.debug('Account Deal Sourced: ' + JSON.serialize(accountDealsInvolved));
            String dealSourced = '';                
            String dealsHistory = '';
            String fundRaisingsHistory = '';
            String formerEmployees = '';
            String dealsInvolvedHistory = '';
            if(accountIdToDealSourced.containsKey(recordId)){
                dealSourced = accountDealSourced.get(recordId);
            }
            if(accountIdToDealHistory.containsKey(recordId)){
                dealsHistory = accountDealHistory.get(recordId);
            }
            if(accountIdToFundRaisings.containsKey(recordId)){
                fundRaisingsHistory = accountFundRaisingsHistory.get(recordId);
            }
            if(accountIdToAffiliations.containsKey(recordId)){
                formerEmployees = accountFormerEmployees.get(recordId);
            }
            
            String businessHistoryHeading ='';
            if(dealSourced != '' || dealsHistory != '' || fundRaisingsHistory != '' || formerEmployees != ''){
                businessHistoryHeading = ''; // Bug 00051877 fixed by Sudhanshu
                System.debug('Business History Heading: ' + businessHistoryHeading);
                formattedResponse+= businessHistoryHeading + (String.isBlank(dealSourced) ? '': dealSourced + '<br/>') + (String.isBlank(dealsHistory) ? '':dealsHistory + '<br/>') + (String.isBlank(fundRaisingsHistory) ? '':fundRaisingsHistory + '<br/>') + (String.isBlank(formerEmployees) ? '': formerEmployees + '<br/>'); 
            }

            Response res = new Response();
            res.Prompt = formattedResponse;
            responses.add(res);
        }
        catch(Exception e){
            System.debug('Error in getFirmRelationship: ' + e.getMessage());
            Response res = new Response();
            res.Prompt = '';
            responses.add(res);
        }

        return responses;
    }

    
    // ---- Private helper ----
    private static void addToSet(Map<Id, Set<Id>> mapByKey, Id key, Id valueToAdd) {
        if (key == null || valueToAdd == null) return;
        if (!mapByKey.containsKey(key)) {
            mapByKey.put(key, new Set<Id>());
        }
        mapByKey.get(key).add(valueToAdd);
    }
   
}