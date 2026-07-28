/****************************************************************************************************
** Module Name : Contact RelationShip Summary 1.0 
** Description : Get the RelationShip Summary for a given Contact.
** Organization : Navatar Group
** Product Name & Version : PE Agentforce Baseline 1.0
** Revision History:-
** Version    Date(YYYY-MM-DD)    Author            Description of Action
** 1.0        2026-03-12          Sudhanshu         PE Agentforce Baseline Phase 1
****************************************************************************************************/
public with sharing class NavatarContactRelationShip {
    public class Request {
        @InvocableVariable(required =true)
        public Contact Contact;
    }

    public class Response {
        @InvocableVariable(required=true)
        public String Prompt;
    }

    @InvocableMethod(label='Contact Relationship Summary' description='Returns relationship summary for a given Contact Id')
    public static List<Response> getContactRelationship(List<Request> requests) {
        List<Response> responses = new List<Response>();
        try{
        
        ID recordId = requests[0].Contact.Id;
        Contact con = [SELECT Id, Name, Email,Title, AccountId, Account.Name,Account.recordType.DeveloperName,Account.navpeII__Total_Commitments_USD_mn__c,
        Account.navpeII__forTotalDealsShown__c,navpeII__forTotalDealsShown__c FROM Contact WHERE Id =: recordId WITH USER_MODE LIMIT 1];
        // Bug 00051824 fixed by Sudhanshu
        String formattedResponse = '<h2>Overview </h2>';
        formattedResponse += '<p>' + con.Name + (con.Title != null ? ', '+con.Title : '') + ' at ' + con.Account.Name + ': </p><br/>'; // bug 00051909 fixed by Sudhanshu
        String contactDescription =  NavatarMeetingPrepCardUtility.callPromptTemplate('Navatar_Contact_Overview', recordId, null);
        System.debug('contactDescription =>'+contactDescription);
        if(contactDescription != null && !contactDescription.contains('Error generating prompt:')) {
            formattedResponse +=  contactDescription;
        }

        if(con.Account.Name != null && con.Account.recordType.developerName != null && con.Account.recordType.developerName == 'Company')
        {
            formattedResponse += '<p>'+con.Account.Name+' is one of our target companies. </p>';
        }

        if(con.Account.recordType.developerName != null && con.Account.recordType.developerName == 'Institution' && con.Account.navpeII__Total_Commitments_USD_mn__c != null )
        {
            formattedResponse += '<p>'+con.Account.Name+' has invested $' + con.Account.navpeII__Total_Commitments_USD_mn__c + ' with us. </p>';
        }

        if(con.Account.recordType.developerName != null && con.Account.recordType.developerName == 'Intermediary' && con.Account.navpeII__forTotalDealsShown__c != null )
        {
            formattedResponse += '<p>'+con.Account.Name+' has sourced ' + con.Account.navpeII__forTotalDealsShown__c +  (con.Account.navpeII__forTotalDealsShown__c == 1 ? ' deal with us. ' : ' deals with us. ') + '</p>'; // Bug Fixed 00051875,00051900 Salauddin 03042026 Singular/plural fix based on count
        }

        Map<Id,List<Map<String, Object>>> contactTopActivityList = NavatarMeetingPrepCardUtility.getContact5RecentInteractions(new Set<Id>{recordId}); 

        System.debug('Top Recent Interactions: ' + JSON.serialize(contactTopActivityList.get(recordId)));

        if(contactTopActivityList.containsKey(recordId))
        {
            System.debug('Top Recent Interactions: ' + JSON.serialize(contactTopActivityList.get(recordId)));
            String result = NavatarMeetingPrepCardUtility.callPromptTemplate('Navatar_Contact_Recent_Interactions', recordId, JSON.serialize(contactTopActivityList.get(recordId)));
            System.debug('result =>'+ result);
            if(result != null && !result.contains('Error generating prompt:')) {
                formattedResponse += '<br/>'+result;
            }
        }else {
                // Bug AA-643 fixed by Sudhanshu
                formattedResponse += '<br/><br/><h2>Recent Interactions</h2><p>There is no record of any conversation with ' + con.Name + '.</p>';
            }

        Map<Id, String> contactFutureMeetingMap = NavatarMeetingPrepCardUtility.getContactFutureMeeting(new Set<Id>{recordId}, new List<Id>());
        System.debug('Contact Future Meetings: ' + JSON.serialize(contactFutureMeetingMap.get(recordId)));
        System.debug('Final Formatted Response: ' + formattedResponse);
        if(contactFutureMeetingMap.containsKey(recordId)){
            // Bug 00051824 fixed by Sudhanshu
            formattedResponse += '<br/><br/><h3> Future Meetings </h3><ul>' + contactFutureMeetingMap.get(recordId) + '</ul>';
        }

        Map<Id, String> contactDealSourced = new Map<Id, String>();
        Map<Id, String> contactDealHistory = new Map<Id, String>();
        Map<Id, String> contactFundRaisingsHistory = new Map<Id, String>();
        Map<Id, String> contactFormerEmployees = new Map<Id, String>();
        Map<Id, String> contactDealsInvolved = new Map<Id, String>();
        Map<Id, List<navpeII__Pipeline__c>> contactToDealsInvolved = NavatarMeetingPrepCardUtility.getDealsInvolvedIn(new List<Id>{recordId});
        Map<Id, List<navpeII__Fundraising__c>> contactToFundraisingInvolved = NavatarMeetingPrepCardUtility.getFundRaisingInvolvedIn(new List<Id>{recordId});
        Map<Id, List<navpeII__Pipeline__c>> contactIdToDealSourced = NavatarMeetingPrepCardUtility.getContactDealsSourced(new List<Id>{recordId});
        String baseUrl = System.Url.getOrgDomainUrl().toExternalForm();
        for(Id conID:contactIdToDealSourced.keySet()){
            List<navpeII__Pipeline__c> pipelines = contactIdToDealSourced.get(conID);
            String dealSourced = '';
            Integer closedCount = 0;
            for(navpeII__Pipeline__c pipeline : pipelines){
                if (pipeline.navpeII__Stage__c == 'Closed') {
                    closedCount++;
                }
            }
            for (navpeII__Pipeline__c pipeline : pipelines) {
                if (dealSourced == '') {
                    dealSourced = '<h3>Deals Sourced</h3>'; 
                    dealSourced += '<p> '+con.Name + ' has sourced ' + contactIdToDealSourced.get(conID).size() + (contactIdToDealSourced.get(conID).size() == 1 ? ' deal to us. The last deal sourced was on ' : ' deals to us. The last deal sourced was on ') + (contactIdToDealSourced.get(conID)[0]?.navpeII__Log_In_Date__c != null ? Datetime.newInstance(contactIdToDealSourced.get(conID)[0].navpeII__Log_In_Date__c.year(), contactIdToDealSourced.get(conID)[0].navpeII__Log_In_Date__c.month(), contactIdToDealSourced.get(conID)[0].navpeII__Log_In_Date__c.day()).format('MMMM d') : '') +'. We closed ' + closedCount + ' of those deals.</p>'; // Bug Fixed 00051875,00051900 Salauddin 03042026 Singular/plural fix based on count
                    dealSourced += '<ul>';
                }
                // Bug 00051793,00051896 fixed by Sudhanshu
                dealSourced += '<li><a href="/' + pipeline.Id + '">' + pipeline.Name + '</a>' + (pipeline.navpeII__Log_In_Date__c != null ? ', '+Datetime.newInstance(pipeline.navpeII__Log_In_Date__c.year(), pipeline.navpeII__Log_In_Date__c.month(), pipeline.navpeII__Log_In_Date__c.day()).format('MMMM d, yyyy') : '') + (pipeline.navpeII__Stage__c != null ? ', '+pipeline.navpeII__Stage__c : '') + '</li>';
            }
            if (dealSourced != '') {
                dealSourced += '</ul>';
            }
            contactDealSourced.put(conID, dealSourced);
        }

        for(Id conId:contactToFundraisingInvolved.keySet()){
            List<navpeII__Fundraising__c> fundraisingsInvolved = contactToFundraisingInvolved.get(conId);
            String fundraisingsInvolvedHistory = '';
            for (navpeII__Fundraising__c fundraising : fundraisingsInvolved) {
                if (fundraisingsInvolvedHistory == '') {
                    fundraisingsInvolvedHistory = '<h3> Fundraisings Involved In </h3>'; // Bug 00051824 fixed by Sudhanshu 
                    fundraisingsInvolvedHistory += '<p>'+con.Name+' has been involved in the following fundraisings: </p>';
                    fundraisingsInvolvedHistory += '<ul>';
                }
                // Bug 00051793,00051896,AA-573 fixed by Sudhanshu
                fundraisingsInvolvedHistory += '<li><a href="/' + fundraising.Id + '">' + fundraising.Name + '</a>' + (fundraising.navpeII__Fund_Name__r != null ? ', <a href="/'+fundraising.navpeII__Fund_Name__r.Id+'">'+fundraising.navpeII__Fund_Name__r.Name+'</a>' : '') + (fundraising.navpeII__Target_Close_Date__c != null ? ', '+Datetime.newInstance(fundraising.navpeII__Target_Close_Date__c.year(), fundraising.navpeII__Target_Close_Date__c.month(), fundraising.navpeII__Target_Close_Date__c.day()).format('MMMM d, yyyy')  : '') + (fundraising.navpeII__Stage__c != null ? ', '+fundraising.navpeII__Stage__c : '') +'</li>';
            }
            if (fundraisingsInvolvedHistory != '') {
                fundraisingsInvolvedHistory += '</ul>';
            }
            contactFundRaisingsHistory.put(conId, fundraisingsInvolvedHistory);
        }


        for(Id conId:contactToDealsInvolved.keySet()){
            List<navpeII__Pipeline__c> dealsInvolved = contactToDealsInvolved.get(conId);
            String dealsInvolvedHistory = '';
            for (navpeII__Pipeline__c deal : dealsInvolved) {
                if (dealsInvolvedHistory == '') {
                    dealsInvolvedHistory = '<h3> Deals Involved In  </h3>'; 
                    dealsInvolvedHistory += '<p>'+con.Name+' has been involved in the following deals: </p>';
                    dealsInvolvedHistory += '<ul>';
                }
                // Bug 00051793,00051896, AA-574 fixed by Sudhanshu
                dealsInvolvedHistory += '<li><a href="/' + deal.Id + '">' + deal.Name + '</a>' + (deal.navpeII__Log_In_Date__c != null ? ', '+Datetime.newInstance(deal.navpeII__Log_In_Date__c.year(), deal.navpeII__Log_In_Date__c.month(), deal.navpeII__Log_In_Date__c.day()).format('MMMM d, yyyy')  : '') + (deal.navpeII__Stage__c != null ? ', '+deal.navpeII__Stage__c : '') +'</li>';
            }
            if (dealsInvolvedHistory != '') {
                dealsInvolvedHistory += '</ul>';
            }
            contactDealsInvolved.put(conId, dealsInvolvedHistory);
        }

        Map<Id, List<navpeII__Affiliation__c>> contactIdToAffiliations = NavatarMeetingPrepCardUtility.getContactFormerEmployees(new List<Id>{recordId});
        for(Id conId:contactIdToAffiliations.keySet()){
            List<navpeII__Affiliation__c> affiliations = contactIdToAffiliations.get(conId);
            String formerEmployees = '';
            for (navpeII__Affiliation__c afiliation : affiliations) {
                if (formerEmployees == '') {
                    formerEmployees = '<h3> Relationship Network  </h3>'; // Bug 00051824 fixed by Sudhanshu 
                    formerEmployees += '<p>'+con.Name+' is also connected with the following firms: </p>';
                    formerEmployees += '<ul>';
                }
                // Bug 00051793 fixed by Sudhanshu
                formerEmployees += '<li> <a href="/' + afiliation.navpeII__Institution__c + '">' + afiliation.navpeII__Institution__r.Name + '</a>, ' + afiliation.navpeII__Role__c + ' at ' + afiliation.navpeII__Contact__r.Account.Name  + (afiliation.navpeII__Start_Date__c != null ? ', Start: '+Datetime.newInstance(afiliation.navpeII__Start_Date__c.year(), afiliation.navpeII__Start_Date__c.month(), afiliation.navpeII__Start_Date__c.day()).format('MMMM d, yyyy')  : '') + (afiliation.navpeII__End_Date__c != null ? ', End: '+Datetime.newInstance(afiliation.navpeII__End_Date__c.year(), afiliation.navpeII__End_Date__c.month(), afiliation.navpeII__End_Date__c.day()).format('MMMM d, yyyy')  : '') +'</li>';
            }
            if (formerEmployees != '') {
                formerEmployees += '</ul>';
            }
            contactFormerEmployees.put(conId, formerEmployees);
        }

        String dealSourced = '';                
        String dealsHistory = '';
        String fundRaisingsHistory = '';
        String formerEmployees = '';
        String dealsInvolvedHistory = '';
        if(contactIdToDealSourced.containsKey(recordId)){
            dealSourced = contactDealSourced.get(recordId);
        }
        if(contactToFundraisingInvolved.containsKey(recordId)){
            fundRaisingsHistory = contactFundRaisingsHistory.get(recordId);
        }
        if(contactIdToAffiliations.containsKey(recordId)){
            formerEmployees = contactFormerEmployees.get(recordId);
        }
        if(contactToDealsInvolved.containsKey(recordId)){
            dealsInvolvedHistory = contactDealsInvolved.get(recordId);
        }
        String businessHistoryHeading ='';

        if(dealSourced != '' || fundRaisingsHistory != '' || formerEmployees != '' || dealsInvolvedHistory != ''){
            businessHistoryHeading = ''; // Bug 00051876 fixed by Sudhanshu
            System.debug('Business History Heading: ' + businessHistoryHeading);
            formattedResponse+= businessHistoryHeading + (String.isBlank(dealSourced) ? '': dealSourced + '<br/>') +(String.isBlank(dealsInvolvedHistory) ? '': dealsInvolvedHistory + '<br/>')+ (String.isBlank(fundRaisingsHistory) ? '':fundRaisingsHistory + '<br/>') + (String.isBlank(formerEmployees) ? '': formerEmployees + '<br/>') ; 
        }




        Response res = new Response();
        res.Prompt = formattedResponse;
        responses.add(res);
    }catch(Exception ex){
        System.debug('Error in getContactRelationship: ' + ex.getMessage());
        Response errorResp = new Response();
        errorResp.Prompt = '';
        responses.add(errorResp);
    }
        return responses;
    }
}