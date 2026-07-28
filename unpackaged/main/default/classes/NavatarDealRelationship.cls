/****************************************************************************************************
** Module Name : Deal RelationShip Summary 1.0 
** Description : Get the RelationShip Summary for a given Deal.
** Organization : Navatar Group
** Product Name & Version : PE Agentforce Baseline 1.0
** Revision History:-
** Version    Date(YYYY-MM-DD)    Author            Description of Action
** 1.0        2026-03-13          Sudhanshu         PE Agentforce Baseline Phase 1
****************************************************************************************************/
public with sharing class NavatarDealRelationship {
    public class Request {
        @InvocableVariable(required =true)
        public navpeII__Pipeline__c Deal;
    }

    public class Response {
        @InvocableVariable(required=true)
        public String Prompt;
    }

    @InvocableMethod(label='Deal Relationship Summary' description='Returns relationship summary for a given Deal Id')
    public static List<Response> getDealRelationship(List<Request> requests) {
        List<Response> responses = new List<Response>();
        Id recordId = requests[0].Deal.Id;
        if (recordId == null) {
            return responses;
        }
        navpeII__Pipeline__c deal = [SELECT Id, Name,navpeII__Source_Contact__r.navpeII__forTotalDealsShown__c, navpeII__Log_In_Date__c,navpeII__Stage__c,
        navpeII__Source_Contact__r.name,navpeII__Source_Company__r.Name,navpeII__Revenue__c,navpeII__EBITDA__c,navpeII__Investment_Size__c FROM navpeII__Pipeline__c WHERE Id = :recordId WITH USER_MODE LIMIT 1 ];
        if (deal == null) {
            return responses;
        }
        String formattedResponse = '<h2>Overview</h2>'; // bug 00051825 fixed by Sudhanshu

        if(deal.navpeII__Log_In_Date__c != null){
            formattedResponse += '<p>The ' + deal.Name + ' was received on ' + Datetime.newInstance(deal.navpeII__Log_In_Date__c.year(), deal.navpeII__Log_In_Date__c.month(), deal.navpeII__Log_In_Date__c.day()).format('MMMM d, yyyy') + (deal.navpeII__Stage__c != null ? ', and is currently at the ' + deal.navpeII__Stage__c + ' stage.' : '.') + ' ';
            if(deal.navpeII__Source_Contact__r != null && deal.navpeII__Source_Company__r != null) {
                formattedResponse += 'It was sourced to us by ' + deal.navpeII__Source_Contact__r.name + ' at ' + deal.navpeII__Source_Company__r.Name + '. ';
                formattedResponse += 'We have worked with ' + deal.navpeII__Source_Contact__r.name + ' on ' + deal.navpeII__Source_Contact__r.navpeII__forTotalDealsShown__c + (deal.navpeII__Source_Contact__r.navpeII__forTotalDealsShown__c == 1 ? ' deal. </p>' : ' deals. </p>'); // Bug Fixed 00051875,00051900 Salauddin 03042026 Singular/plural fix based on count
            }
            else {
                formattedResponse += '</p>';
            }
        }
        else {
            formattedResponse += '<p>The ' + deal.Name + ' is currently at the ' + deal.navpeII__Stage__c + ' stage. ';
            if(deal.navpeII__Source_Contact__r != null && deal.navpeII__Source_Company__r != null) {
                formattedResponse += 'It was sourced to us by ' + deal.navpeII__Source_Contact__r.name + ' at ' + deal.navpeII__Source_Company__r.Name + '. ';
                formattedResponse += 'We have worked with ' + deal.navpeII__Source_Contact__r.name + ' on ' + deal.navpeII__Source_Contact__r.navpeII__forTotalDealsShown__c + (deal.navpeII__Source_Contact__r.navpeII__forTotalDealsShown__c == 1 ? ' deal. </p>' : ' deals. </p>'); // Bug Fixed 00051875,00051900 Salauddin 03042026 Singular/plural fix based on count
            }
            else if(deal.navpeII__Source_Contact__r != null && deal.navpeII__Source_Company__r == null) {
                 formattedResponse += 'We have worked with ' + deal.navpeII__Source_Contact__r.name + ' on ' + deal.navpeII__Source_Contact__r.navpeII__forTotalDealsShown__c + (deal.navpeII__Source_Contact__r.navpeII__forTotalDealsShown__c == 1 ? ' deal. </p>' : ' deals. </p>'); // Bug Fixed 00051875,00051900 Salauddin 03042026 Singular/plural fix based on count
            }
            else {
                formattedResponse += '</p>';
            }
        }

        String dealDescription =  NavatarMeetingPrepCardUtility.callPromptTemplate('Navatar_Deal_Overview', recordId, null);
        if(dealDescription != null && !dealDescription.contains('Error generating prompt:')) {
            formattedResponse +=  dealDescription;
        }
        
        formattedResponse += '<p>The company has revenues of $' + (deal.navpeII__Revenue__c != null ? deal.navpeII__Revenue__c : 0) + ' and an EBITDA of $' + (deal.navpeII__EBITDA__c != null ? deal.navpeII__EBITDA__c : 0) + '. We are looking to invest around $' + (deal.navpeII__Investment_Size__c != null ? deal.navpeII__Investment_Size__c : 0) + ' in the deal.</p>';

        List<String> externalMember = new List<String>();
        List<String> internalMember = new List<String>();

        for(navpeII__Deal_Team__c dealTeam : [SELECT Id, Name, navpeII__Deal_Contact__r.Name,navpeII__Deal_Contact__r.Account.Name, navpeII__Team_Member__r.Name FROM navpeII__Deal_Team__c WHERE navpeII__Deal__c = :recordId WITH USER_MODE]) {
            if(dealTeam.navpeII__Deal_Contact__r != null){
                String contactName = dealTeam.navpeII__Deal_Contact__r.Name;
                String accountName = dealTeam.navpeII__Deal_Contact__r.Account != null 
                                    ? dealTeam.navpeII__Deal_Contact__r.Account.Name 
                                    : '';
                externalMember.add(contactName + ' from ' + accountName);
            }

            if(dealTeam.navpeII__Team_Member__r != null){
                internalMember.add(dealTeam.navpeII__Team_Member__r.Name);
            }
        }

        if(!internalMember.isEmpty()){
            formattedResponse += '<p>' + String.join(internalMember, ', ') + ' from our team are involved in the deal.</p>';
        }

        List<Map<String, Object>> dealTopActivityList = NavatarMeetingPrepCardUtility.getDeal5RecentInteractions(recordId); 
        if(dealTopActivityList != null && !dealTopActivityList.isEmpty()){
            String result = NavatarMeetingPrepCardUtility.callPromptTemplate('Navatar_Deal_Recent_Interactions', recordId, JSON.serialize(dealTopActivityList));
            System.debug('result =>'+ result);
            if(result != null && !result.contains('Error generating prompt:')) {
                formattedResponse += '<p>'+result+'</p>';
            }
        }

        String futureMeetings = NavatarMeetingPrepCardUtility.getFutureActivities(recordId);
        if(futureMeetings != null && !String.isEmpty(futureMeetings)){
            formattedResponse += '<p><h3> Future Meetings </h3><ul>' + futureMeetings + '</ul></p>';// bug 00051825 fixed by Sudhanshu
        }

        if(!externalMember.isEmpty()){
            formattedResponse += '<p><h3>External Parties Involved</h3></p>';// bug 00051825 fixed by Sudhanshu
            // Bug 00051883 fixed by Sudhanshu
            formattedResponse += '<p>We are working with ' + String.join(externalMember, ', ') + ' for this deal.</p>';
        }

        Response res = new Response();
        res.Prompt = formattedResponse;
        responses.add(res);
        return responses;
    }
}