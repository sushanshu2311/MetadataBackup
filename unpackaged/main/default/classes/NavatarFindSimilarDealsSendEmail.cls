/****************************************************************************************************
** Module Name : Find Similar Deals Email Sender
** Description : Apex class to send email details of find similar deals in the Pipeline based on various criteria.
** Organization : Navatar Group
** Product Name & Version : PE Agentforce Baseline 1.0
** Revision History:-
** Version    Date(YYYY-MM-DD)    Author            Description of Action
** 1.0        2026-02-05          Sudhanshu         PE Agentforce Baseline Phase 1
****************************************************************************************************/

public with sharing class NavatarFindSimilarDealsSendEmail {
    public static String dealName = '';
    public class Request {
        @InvocableVariable(required=true)
        public Id pipelineId;
    }
     public class Response {
        @InvocableVariable
        public String message;
    }

    @InvocableMethod(
        label='Find and Email Similar Deals'
        description='Finds similar deals based on pipeline criteria and emails the results to a specified address.'
    )
    public static List<Response> findSimilarDeals(List<Request> requests) {
        List<Response> results = new List<Response>();
        if (requests == null || requests.isEmpty()) return results;
        try {
            Request req = requests[0]; // Only process the first request for simplicity R-0000008521
            navpeII__Pipeline__c inputDeal = NavatarFindSimilarDeals.getPipelineDeal(req.pipelineId);
            dealName = inputDeal != null && inputDeal.Name != null ? String.valueOf(inputDeal.Name) : '';
            Map<String, Decimal> ranges = NavatarFindSimilarDeals.getDealRanges(inputDeal);
            List<Map<String, Object>> scored = NavatarFindSimilarDeals.scoreSimilarDeals(inputDeal, ranges);
            //Added condition for R-0000008521
            if (scored.isEmpty()) {
                Response resp = new Response();
                resp.message = 'No similar deals found based on the current criteria.';
                results.add(resp);
                return results;                    
            }

            List<Map<String, Object>> sorted = NavatarFindSimilarDeals.sortDealsByScore(scored);
            // Use all sorted deals for the email, not just top 5
            Map<Id, SObject> deals = NavatarFindSimilarDeals.buildDealMap(sorted);
            Map<Id, String> similarDeals = NavatarFindSimilarDeals.buildSimilarDealsMap(sorted);
            
            // Build output for email without the extra message about count
            String output = buildEmailOutput(similarDeals, deals, null, null);
            // Send email with output to the logged-in user
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setToAddresses(new List<String>{UserInfo.getUserEmail()});
            mail.setSubject('Similar Deals Analysis');
            mail.setHtmlBody(output);
            Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{mail});
            Response resp = new Response();
            
                resp.message = 'Success: Email sent.';
            
            results.add(resp);
        
        } catch (Exception e) {
            Response resp = new Response();
            resp.message = 'Error: ' + e.getMessage();
            results.add(resp);
        }
        return results;
    }

    // Build output for email without the extra message about count
    private static String buildEmailOutput(Map<Id, String> similarDeals, Map<Id, SObject> deals, Map<Id, List<Contact>> dealExperts, Map<Id, List<ContentDocumentLink>> dealFiles) {
        // bug 00050948 Fixed by Sudhanshu
        String output = 'Please find below a comprehensive list of deals similar to ' + dealName + ':<br/><br/>'+
    '<b>Similar Deals Identified</b><br/><br/><div style="margin-left:0px;"> <ol>';
        Integer idx = 1;
        for(Id dId : similarDeals.keySet()) {
            SObject dRec = deals.containsKey(dId) ? deals.get(dId) : null;
            output += '<li> <a href=\'/' + dId + '\'>' + (dRec != null && dRec.get('Name') != null ? String.valueOf(dRec.get('Name')) : '') + '</a><br/>\n';
            String reason = similarDeals.get(dId);
            if (!String.isBlank(reason)) {
                List<String> reasonLines = reason.split('\\n');
                for (String r : reasonLines) {
                    output += '&nbsp;&nbsp;&nbsp;-&nbsp;&nbsp;&nbsp;Similarity Reason: ' + r.trim() + '<br/>\n';
                }
            }
            String baseUrl = System.Url.getOrgDomainUrl().toExternalForm();
            Pattern p = Pattern.compile('<a\\s+href\\s*=\\s*([\'\"])\\/(.*?)\\1');
            Matcher m = p.matcher(output);
            Integer lastEnd = 0;
            String result = '';
            while (m.find()) {
                // Append text before match
                result += output.substring(lastEnd, m.start());
                String quote = m.group(1);
                String path = m.group(2);
                // Rebuild the anchor tag with baseUrl
                result += '<a href=' + quote + baseUrl + '/' + path + quote;
                lastEnd = m.end();
            }
            output = result + output.substring(lastEnd);
            output += '</li>';
            // Deal Experts (commented out)
            /*
            output += '    Deal Expert- ';
            List<String> expertLinks = new List<String>();
            if(dealExperts.containsKey(dId) && dealExperts.get(dId) != null && !dealExperts.get(dId).isEmpty()) {
                for(Contact u : dealExperts.get(dId)) {
                    expertLinks.add('<a href=\'/' + u.Id + '\'>' + u.Name + '</a>');
                }
            }
            output += String.join(expertLinks, ', ');
            output += '\n';
            // Files (commented out)
            output += '    Files- ';
            List<String> fileLinks = new List<String>();
            if(dealFiles.containsKey(dId) && dealFiles.get(dId) != null && !dealFiles.get(dId).isEmpty()) {
                for(ContentDocumentLink f : dealFiles.get(dId)) {
                    String fileTitle = (f.ContentDocument != null && f.ContentDocument.Title != null) ? f.ContentDocument.Title : 'File';
                    fileLinks.add('<a href=\'/' + f.ContentDocumentId + '\'>' + fileTitle + '</a>');
                }
            }
            output += String.join(fileLinks, ', ');
            output += '\n';
            */
            idx++;
        }
        // Do NOT add the extra message about count here
        output += '</ol></div><br/><i>*****This is a system generated email*****</i>';
        return output;
    }


}