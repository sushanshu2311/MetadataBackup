/****************************************************************************************************
** Module Name : Extract and Add Deal Experts
** Description : Apex class to find Extract and Add Deal Experts as per user selection
** Organization : Navatar Group
** Product Name & Version : PE Agentforce Baseline 1.0
** Revision History:-
** Version    Date(YYYY-MM-DD)    Author            Description of Action
** 1.0        2026-02-05          Sudhanshu         PE Agentforce Baseline Phase 1
****************************************************************************************************/


public with sharing class NavatarAddDealExperts {
    // Wrapper for input parameters to the invocable method
    public class RequestWrapper {
        @InvocableVariable(required=true)
        public String formattedText; // The formatted text containing contact links
        @InvocableVariable(required=true)
        public String dealId; 
        @InvocableVariable(required=true)
        public String selectionMode;
        @InvocableVariable
        public String selectedIndexes;
    }

    // Wrapper for output message from the invocable method
    public class ResponseWrapper {
        @InvocableVariable
        public String message; // Success or error message
    }

    /**
     * Invocable method to extract contact IDs from formatted text and add them as deal experts
     * to navpeII__Deal_Team__c for the provided deal. Ensures no duplicate deal-contact pairs.
     */
    @InvocableMethod(label='Extract and Add Deal Experts as per user selection' description='Extracts contact IDs from formatted text and adds them as deal experts to navpeII__Deal_Team__c')
    public static List<ResponseWrapper> extractAndAddDealExperts(List<RequestWrapper> requests) {
        List<ResponseWrapper> responses = new List<ResponseWrapper>();
        RequestWrapper req = requests[0]; // Only process the first request for simplicity R-0000008522
        ResponseWrapper resp = new ResponseWrapper();
        try {
            Set<Id> contactIds = new Set<Id>();
            // Extract all contact IDs in order of appearance
            List<Id> allContactIds = new List<Id>();
            Pattern p = Pattern.compile('/(003[A-Za-z0-9]{12,15})');
            Matcher m = p.matcher(req.formattedText);
            while(m.find()) {
                allContactIds.add((Id)m.group(1));
            }

            if (req.selectionMode == 'ALL') {
                contactIds.addAll(allContactIds);
            } else if (req.selectionMode == 'INDEX' && String.isNotBlank(req.selectedIndexes)) {
                // Parse selectedIndexes (comma-separated, 1-based)
                List<String> indexStrings = req.selectedIndexes.split(',');
                Set<Integer> selectedIdxs = new Set<Integer>();
                for (String idxStr : indexStrings) {
                    Integer idx = null;
                    try {
                        idx = Integer.valueOf(idxStr.trim());
                    } catch (Exception e) {
                        // skip invalid index
                    }
                    if (idx != null && idx > 0 && idx <= allContactIds.size()) {
                        selectedIdxs.add(idx);
                    }
                }
                // Add only contacts at those indexes (1-based)
                Integer i = 1;
                for (Id cid : allContactIds) {
                    if (selectedIdxs.contains(i)) {
                        contactIds.add(cid);
                    }
                    i++;
                }
            }

            // Query existing deal team records for this deal and these contacts, enforcing FLS and sharing
            Map<Id, navpeII__Deal_Team__c> existingMap = new Map<Id, navpeII__Deal_Team__c>();
            if (!contactIds.isEmpty()) {
                for (navpeII__Deal_Team__c dt : [SELECT navpeII__Deal_Contact__c FROM navpeII__Deal_Team__c WHERE navpeII__Deal__c = :req.dealId AND navpeII__Deal_Contact__c IN :contactIds WITH SECURITY_ENFORCED]) {
                    existingMap.put(dt.navpeII__Deal_Contact__c, dt);
                }
            }
            // Prepare new deal team records for contacts not already associated with the deal
            List<navpeII__Deal_Team__c> dealTeamRecords = new List<navpeII__Deal_Team__c>();
            for(Id contactId : contactIds) {
                if (!existingMap.containsKey(contactId)) {
                    dealTeamRecords.add(new navpeII__Deal_Team__c(
                        navpeII__Deal__c = req.dealId,
                        navpeII__Deal_Contact__c = contactId
                    ));
                }
            }
            // Enforce object and field-level security before DML
            if(!dealTeamRecords.isEmpty()) {
                SObjectAccessDecision securityDecision = Security.stripInaccessible(AccessType.CREATABLE, dealTeamRecords);
                List<navpeII__Deal_Team__c> accessibleRecords = (List<navpeII__Deal_Team__c>) securityDecision.getRecords();
                if (!accessibleRecords.isEmpty()) {
                    insert accessibleRecords;
                    resp.message = 'Expert was successfully added to your Deal.';
                } else {
                    resp.message = 'Error: You do not have permission to add experts to this Deal.';
                }
            } else {
                resp.message = 'No new experts to add.';
            }
        } catch(Exception e) {
            resp.message = 'Error: ' + e.getMessage();
        }
        responses.add(resp);
        
        return responses;
    }
}