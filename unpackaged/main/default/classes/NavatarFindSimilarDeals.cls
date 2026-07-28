/****************************************************************************************************
** Module Name : Find Similar Deals 
** Description : Apex class to find similar deals in the Pipeline based on various criteria.
** Organization : Navatar Group
** Product Name & Version : PE Agentforce Baseline 1.0
** Revision History:-
** Version    Date(YYYY-MM-DD)    Author            Description of Action
** 1.0        2026-02-05          Sudhanshu         PE Agentforce Baseline Phase 1
****************************************************************************************************/

public with sharing class NavatarFindSimilarDeals {
    public class Request {
        @InvocableVariable(required=true)
        public Id pipelineId;
    }
     public class Response {
        @InvocableVariable
        public String relatedDealDetails;
        @InvocableVariable
        public String dealId;
        @InvocableVariable
        public String top5Deals;
    }

    @InvocableMethod(label='Find Similar Deals')
    public static List<Response> findSimilarDeals(List<Request> requests) {
        
        List<Response> results = new List<Response>();
        Request req = requests[0];
        try{
            if (requests == null || requests.isEmpty()) return results;
                
                navpeII__Pipeline__c inputDeal = getPipelineDeal(req.pipelineId);
                // Check if all fields used in scoreSimilarDeals conditions are null
                String industry = inputDeal.navpeII__Company__r != null ? inputDeal.navpeII__Company__r.Industry : null;
                if (
                    industry == null &&
                    inputDeal.navpeII__Revenue__c == null &&
                    inputDeal.navpeII__EBITDA__c == null &&
                    inputDeal.navpeII__Source_Company__c == null &&
                    inputDeal.navpeII__Deal_Type__c == null
                ) {
                    Response resp = new Response();
                    resp.relatedDealDetails = 'I couldn’t find the required deal parameters to identify similar deals. Please update the deal details or try a different deal.';
                    resp.top5Deals = '';
                    resp.dealId = req.pipelineId;
                    results.add(resp);
                    return results;
                }
                Map<String, Decimal> ranges = getDealRanges(inputDeal);
                List<Map<String, Object>> scored = scoreSimilarDeals(inputDeal, ranges);
                //Added condition for R-0000008520
                if (scored.isEmpty()) {
                    Response resp = new Response();
                    resp.relatedDealDetails = 'No similar deals found based on the current criteria.';
                    resp.top5Deals = '';
                    resp.dealId = req.pipelineId;
                    results.add(resp);
                    return results;
                }
                List<Map<String, Object>> sorted = sortDealsByScore(scored);
                List<Map<String, Object>> topDeals = getTopDeals(sorted, 5);
                Map<Id, SObject> deals = buildDealMap(topDeals);
                Map<Id, String> similarDeals = buildSimilarDealsMap(topDeals);
                
                // Build output for all deals
                Map<Id, SObject> allDeals = buildDealMap(sorted);
                Map<Id, String> allSimilarDeals = buildSimilarDealsMap(sorted);
                String allDealsOutput = buildOutputString(allSimilarDeals, allDeals, sorted.size());

                // Build output for top 5 deals
                String top5DealsOutput = buildOutputString(similarDeals, deals, sorted.size());

                Response resp = new Response();
                resp.relatedDealDetails = allDealsOutput;
                resp.top5Deals = top5DealsOutput;
                resp.dealId = req.pipelineId;
                results.add(resp);
            
            return results;
        } catch (Exception e) {
            // Handle exception if needed
            Response resp = new Response();
            resp.relatedDealDetails = 'An error occurred while finding similar deals. Please try again later.';
            resp.top5Deals = '';
            resp.dealId = req.pipelineId;
            results.add(resp);
            return results;
        }
    }

    // --- Common Private Methods for Reuse ---
    public static navpeII__Pipeline__c getPipelineDeal(Id pipelineId) {
        return [
            SELECT Id, Name, navpeII__Company__r.Industry, navpeII__Company__r.Name, navpeII__Source_Company__c, navpeII__Transaction_Type__c,
                   navpeII__Deal_Type__c, navpeII__EBITDA__c, navpeII__Revenue__c, navpeII__Investment_Size__c
            FROM navpeII__Pipeline__c
            WHERE Id = :pipelineId
            WITH USER_MODE
            LIMIT 1
        ];
    }

    public static Map<String, Decimal> getDealRanges(navpeII__Pipeline__c inputDeal) {
        Map<String, Decimal> ranges = new Map<String, Decimal>();
        Decimal ebitda = inputDeal.navpeII__EBITDA__c;
        Decimal revenue = inputDeal.navpeII__Revenue__c;
        Decimal investSize = inputDeal.navpeII__Investment_Size__c;
        ranges.put('ebitdaMin', ebitda != null ? ebitda * 0.85 : null);
        ranges.put('ebitdaMax', ebitda != null ? ebitda * 1.15 : null);
        ranges.put('revenueMin', revenue != null ? revenue * 0.85 : null);
        ranges.put('revenueMax', revenue != null ? revenue * 1.15 : null);
        ranges.put('investMin', investSize != null ? investSize * 0.85 : null);
        ranges.put('investMax', investSize != null ? investSize * 1.15 : null);
        return ranges;
    }

    public static List<Map<String, Object>> scoreSimilarDeals(navpeII__Pipeline__c inputDeal, Map<String, Decimal> ranges) {
        // NOTE: Assumes navpeII__Company__r.Industry is Industry, navpeII__Revenue__c is Revenue, navpeII__EBITDA__c is EBITDA,
        // navpeII__Deal_Type__c is Deal Type, navpeII__Source_Company__c is Source Firm (adjust field names if needed)
        // Build dynamic SOQL query
        //Bug Fix 00050997,00050967 Salauddin
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
        System.debug('Dynamic Query: ' + fullQuery);
        List<navpeII__Pipeline__c> candidates = (List<navpeII__Pipeline__c>)Database.query(fullQuery);
        List<Map<String, Object>> scored = new List<Map<String, Object>>();
        for (navpeII__Pipeline__c c : candidates) {
            Decimal score = 0;
            List<String> similarityParams = new List<String>();
            // Industry (Company) - 40%
            if (c.navpeII__Company__r.Industry == inputDeal.navpeII__Company__r.Industry && c.navpeII__Company__r.Industry != null) {
                score += 40;
                similarityParams.add('Industry');
            }
            // Revenue (±15%) - 25%
            Decimal revenue = inputDeal.navpeII__Revenue__c;
            if (revenue != null && c.navpeII__Revenue__c != null &&
                c.navpeII__Revenue__c >= ranges.get('revenueMin') && c.navpeII__Revenue__c <= ranges.get('revenueMax')) {
                score += 25;
                similarityParams.add('Revenue (±15%)');
            }
            // EBITDA (±15%) - 25%
            Decimal ebitda = inputDeal.navpeII__EBITDA__c;
            if (ebitda != null && c.navpeII__EBITDA__c != null &&
                c.navpeII__EBITDA__c >= ranges.get('ebitdaMin') && c.navpeII__EBITDA__c <= ranges.get('ebitdaMax')) {
                score += 25;
                similarityParams.add('EBITDA (±15%)');
            }
            // Deal Type - 8%
            if (c.navpeII__Deal_Type__c == inputDeal.navpeII__Deal_Type__c && c.navpeII__Deal_Type__c != null) {
                score += 8;
                similarityParams.add('Deal Type');
            }
            // Source Firm (Stage) - 2%
            if (c.navpeII__Source_Company__c == inputDeal.navpeII__Source_Company__c && c.navpeII__Source_Company__c != null) {
                score += 2;
                similarityParams.add('Source Firm');
            }
            // Bug 00051176 fix by Sudhanshu
            if(score > 50) { // Only consider deals with score > 50 as similar
                Map<String, Object> row = new Map<String, Object>();
                row.put('deal', c);
                row.put('score', score);
                row.put('similarityParams', similarityParams);
                scored.add(row);
            }
        }
        return scored;
    }

    public static List<Map<String, Object>> sortDealsByScore(List<Map<String, Object>> scored) {
        List<Map<String, Object>> sorted = new List<Map<String, Object>>();
        sorted.addAll(scored);
        for (Integer i = 0; i < sorted.size(); i++) {
            for (Integer j = i + 1; j < sorted.size(); j++) {
                Decimal scoreI = (Decimal)sorted[i].get('score');
                Decimal scoreJ = (Decimal)sorted[j].get('score');
                if (scoreJ > scoreI) {
                    Map<String, Object> temp = sorted[i];
                    sorted[i] = sorted[j];
                    sorted[j] = temp;
                }
            }
        }
        return sorted;
    }

    public static List<Map<String, Object>> getTopDeals(List<Map<String, Object>> sorted, Integer maxCount) {
        List<Map<String, Object>> topDeals = new List<Map<String, Object>>();
        Integer maxDeals = sorted.size() > maxCount ? maxCount : sorted.size();
        for (Integer i = 0; i < maxDeals; i++) {
            topDeals.add(sorted[i]);
        }
        return topDeals;
    }

    public static Map<Id, SObject> buildDealMap(List<Map<String, Object>> topDeals) {
        Map<Id, SObject> deals = new Map<Id, SObject>();
        for(Integer i = 0; i < topDeals.size(); i++) {
            navpeII__Pipeline__c dealObj = (navpeII__Pipeline__c)topDeals[i].get('deal');
            Id dealId = dealObj.Id;
            deals.put(dealId, dealObj);
        }
        return deals;
    }

    public static Map<Id, String> buildSimilarDealsMap(List<Map<String, Object>> topDeals) {
        Map<Id, String> similarDeals = new Map<Id, String>();
        for(Integer i = 0; i < topDeals.size(); i++) {
            navpeII__Pipeline__c dealObj = (navpeII__Pipeline__c)topDeals[i].get('deal');
            Id dealId = dealObj.Id;
            similarDeals.put(dealId, String.join((List<String>)topDeals[i].get('similarityParams'), ', '));
        }
        return similarDeals;
    }

    public static String buildOutputString(Map<Id, String> similarDeals, Map<Id, SObject> deals, Integer sortedSize) {
        String output = '';
        Integer idx = 1;
        for(Id dId : similarDeals.keySet()) {
            SObject dRec = deals.containsKey(dId) ? deals.get(dId) : null;
            output += idx + ') <a href=\'/' + dId + '\'>' + (dRec != null && dRec.get('Name') != null ? String.valueOf(dRec.get('Name')) : '') + '</a>\n';
            String reason = similarDeals.get(dId);
            if (!String.isBlank(reason)) {
                output += '    Similarity Reason- ' + reason.trim() + '\n';
            }
            idx++;
        }
        if (sortedSize > 5) {
            output += '\nThere are ' + sortedSize + ' similar deals found. If you want, we can send the full list to your email.';
        }
        return output;
    }

}