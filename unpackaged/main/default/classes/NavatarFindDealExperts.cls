/****************************************************************************************************
** Module Name : Find Deal Experts
** Description : Apex class to  find deal experts .
** Organization : Navatar Group
** Product Name & Version : PE Agentforce Baseline 1.0
** Revision History:-
** Version    Date(YYYY-MM-DD)    Author            Description of Action
** 1.0        2026-02-05          Sudhanshu         PE Agentforce Baseline Phase 1
****************************************************************************************************/
public with sharing class NavatarFindDealExperts {
    public class Request {
        @InvocableVariable(required=true)
        public Id pipelineId;
    }
    public class Response {
        @InvocableVariable
        public String expertDetails;
        @InvocableVariable
        public String dealId;
    }

    @InvocableMethod(label='Find Deal Experts')
    public static List<Response> findDealExperts(List<Request> requests) {
        List<Response> results = new List<Response>();
        if (requests == null || requests.isEmpty()) return results;
        Request req = requests[0];
        try{
            List<Id> dealIds = new List<Id>();
            navpeII__Pipeline__c inputDeal = [SELECT Id, Name, navpeII__Company__r.Industry, navpeII__Company__r.Name, navpeII__Source_Company__c, navpeII__Transaction_Type__c,
                   navpeII__Deal_Type__c, navpeII__EBITDA__c, navpeII__Revenue__c, navpeII__Investment_Size__c
            FROM navpeII__Pipeline__c
            WHERE Id = :req.pipelineId
            WITH USER_MODE
            LIMIT 1];
            Map<String, Decimal> ranges = new Map<String, Decimal>();
            Decimal ebitda = inputDeal.navpeII__EBITDA__c;
            Decimal revenue = inputDeal.navpeII__Revenue__c;
            Decimal investSize = inputDeal.navpeII__Investment_Size__c;
            ranges.put('ebitdaMin', ebitda != null ? ebitda * 0.85 : null);
            ranges.put('ebitdaMax', ebitda != null ? ebitda * 1.15 : null);
            ranges.put('revenueMin', revenue != null ? revenue * 0.85 : null);
            ranges.put('revenueMax', revenue != null ? revenue * 1.15 : null);
            //Bug Fixing 00051005 30012026
            String baseQuery = 'SELECT Id, Name, navpeII__Company__r.Industry, navpeII__Company__r.Name, navpeII__Source_Company__c, navpeII__Transaction_Type__c,' +
            ' navpeII__Deal_Type__c, navpeII__EBITDA__c, navpeII__Revenue__c, navpeII__Investment_Size__c, CreatedDate' +
            ' FROM navpeII__Pipeline__c WHERE Id != ' +
            ((inputDeal.Id != null) ? '\'' + String.escapeSingleQuotes(String.valueOf(inputDeal.Id)) + '\'' : 'null');

            List<String> conditions = new List<String>();
            // Company (Industry)
            if (inputDeal.navpeII__Company__r.Industry != null) {
                conditions.add('navpeII__Company__r.Industry = \'' + String.escapeSingleQuotes(String.valueOf(inputDeal.navpeII__Company__r.Industry)) + '\'');
            }
            // Stage (Source Firm)
            if (inputDeal.navpeII__Source_Company__c != null) {
                conditions.add('navpeII__Source_Company__c = \'' + String.escapeSingleQuotes(String.valueOf(inputDeal.navpeII__Source_Company__c)) + '\'');
            }
            // Deal Type
            if (inputDeal.navpeII__Deal_Type__c != null) {
                conditions.add('navpeII__Deal_Type__c = \'' + String.escapeSingleQuotes(String.valueOf(inputDeal.navpeII__Deal_Type__c)) + '\'');
            }
            // EBITDA
            Decimal ebitdaMin = ranges.get('ebitdaMin');
            Decimal ebitdaMax = ranges.get('ebitdaMax');
            if (inputDeal.navpeII__EBITDA__c != null && ebitdaMin != null && ebitdaMax != null) {
                conditions.add('(navpeII__EBITDA__c >= ' + ebitdaMin + ' AND navpeII__EBITDA__c <= ' + ebitdaMax + ')');
            }
            // Revenue
            Decimal revenueMin = ranges.get('revenueMin');
            Decimal revenueMax = ranges.get('revenueMax');
            if (inputDeal.navpeII__Revenue__c != null && revenueMin != null && revenueMax != null) {
                conditions.add('(navpeII__Revenue__c >= ' + revenueMin + ' AND navpeII__Revenue__c <= ' + revenueMax + ')');
            }

            String whereClause = '';
            if (!conditions.isEmpty()) {
                whereClause = ' AND (' + String.join(conditions, ' OR ') + ')';
            }
            String fullQuery = baseQuery + whereClause + ' WITH USER_MODE';
            List<navpeII__Pipeline__c> deals = (List<navpeII__Pipeline__c>)Database.query(fullQuery);
            for (navpeII__Pipeline__c c : deals) {
                dealIds.add(c.Id);
            }
            List<navpeII__Deal_Team__c> dealExperts = [
                  SELECT navpeII__Deal__c, 
                      navpeII__Deal_Contact__c, 
                      navpeII__Deal_Contact__r.Name,
                      navpeII__Deal__r.navpeII__Log_In_Date__c
                  FROM navpeII__Deal_Team__c
                  WHERE navpeII__Deal__c IN :dealIds
                     AND navpeII__Deal_Contact__c != null
                  WITH USER_MODE
                  ORDER BY navpeII__Deal__r.navpeII__Log_In_Date__c DESC
                 ];//Bug Fix 00050971 03022026
            if (dealExperts.isEmpty()) {
                Response resp = new Response();
                resp.expertDetails = 'No deal experts found.';
                resp.dealId = req.pipelineId;
                results.add(resp);
                return results;
            
            }
            // Count appearances of each contact
            Map<Id, Integer> contactCount = new Map<Id, Integer>();
            Map<Id, String> contactNameMap = new Map<Id, String>();
            Map<Id, String> contactPeriodMap = new Map<Id, String>();
            //Bug Fixing 00050971 02022026 Start
            Map<Id, Date> conLoginDateMap = new Map<Id, Date>();
            Map<Id,List<Id>> conDealMap = new Map<Id,List<Id>>();
            for (navpeII__Deal_Team__c contact : dealExperts) {
                if (!conDealMap.containsKey(contact.navpeII__Deal_Contact__c)) {
                    conDealMap.put(contact.navpeII__Deal_Contact__c, new List<Id>());
                }
                conLoginDateMap.put(contact.navpeII__Deal_Contact__c, contact.navpeII__Deal__r.navpeII__Log_In_Date__c);
                conDealMap.get(contact.navpeII__Deal_Contact__c).add(contact.navpeII__Deal__c);
                Integer prev = contactCount.containsKey(contact.navpeII__Deal_Contact__c) ? contactCount.get(contact.navpeII__Deal_Contact__c) : 0;
                contactCount.put(contact.navpeII__Deal_Contact__c, prev + 1);
                if (!contactNameMap.containsKey(contact.navpeII__Deal_Contact__c)) contactNameMap.put(contact.navpeII__Deal_Contact__c, contact.navpeII__Deal_Contact__r.Name);                
            }
            // Sort contacts by count desc
            List<Id> sortedContactIds = new List<Id>(contactCount.keySet());
            // Manual sort: descending by count
            for (Integer i = 0; i < sortedContactIds.size(); i++) {
                for (Integer j = i + 1; j < sortedContactIds.size(); j++) {
                    if (contactCount.get(sortedContactIds[j]) > contactCount.get(sortedContactIds[i])) {
                        Id temp = sortedContactIds[i];
                        sortedContactIds[i] = sortedContactIds[j];
                        sortedContactIds[j] = temp;
                    }
                }
            }

            // Calculate date range for similarity reason
            String dealType = inputDeal.navpeII__Deal_Type__c;
            String industry = inputDeal.navpeII__Company__r != null ? inputDeal.navpeII__Company__r.Name : '';
            
            for(Id conId:conDealMap.keySet()){
                Integer days = conLoginDateMap.get(conId) != null ? conLoginDateMap.get(conId).daysBetween(Date.today()) : 0;
                Integer years = days / 365;
                String period = years > 0 ? years + ' year' + (years > 1 ? 's' : '') : days + ' days';
                contactPeriodMap.put(conId, period);
            }
            

            // Build output
            String output = '';
            Integer idx = 1;
            for (Id cid : sortedContactIds) {
                Integer dealsAdvised = contactCount.get(cid);
                output += idx + ') <a href="/' + cid + '">' + contactNameMap.get(cid) + '</a>: Advised on ' + dealsAdvised + ' similar Deal' + (dealsAdvised > 1 ? 's' : '') + ' in the last ' + contactPeriodMap.get(cid) + '.\n';//Bug Fixing 00051005 30012026
                idx++;
            }
            //Bug Fixing 00050971 02022026 End
                // Append user prompt for adding experts
                output += '\nWould you like to add any of these deal experts to ' + inputDeal.Name + '?\nYou can type All, or type specific experts (such as 1 & 3).';

            Response resp = new Response();
            resp.expertDetails = output;
            resp.dealId = req.pipelineId;
            results.add(resp);
        } catch (Exception e) {
            Response resp = new Response();
            resp.expertDetails = 'Error finding deal experts: ' + e.getMessage();
            resp.dealId = req.pipelineId;
            results.add(resp);
        }
        
        return results;
    }
}