/****************************************************************************************************
** Module Name : Document Extraction AI 1.0
** Description : Trigger to update deal record field based on Content document
** Organization : Navatar Group
** Product Name & Version : PE Agentforce Baseline 1.0
** Revision History:-
** Version    Date(YYYY-MM-DD)    Author            Description of Action
** 1.0        2026-02-05          Salauddin Sheikh  PE Agentforce Baseline Phase 1
****************************************************************************************************/
trigger NavatarContentDocumentTrigger on ContentDocumentLink (after insert) {
    if(Trigger.isAfter && Trigger.isInsert) {
        Map<Id,Set<Id>> contentDocumentIdtoLinkedEntityIdsMap = new Map<Id,Set<Id>>();
        Set<Id> linkedEntityIdsSet = new Set<Id>();
        for(ContentDocumentLink cdl : Trigger.new){
            if(cdl.LinkedEntityId != null && !(String.valueOf(cdl.LinkedEntityId).startsWith('005'))){
                if(!contentDocumentIdtoLinkedEntityIdsMap.containsKey(cdl.ContentDocumentId)){
                    contentDocumentIdtoLinkedEntityIdsMap.put(cdl.ContentDocumentId, new Set<Id>());
                }
                contentDocumentIdtoLinkedEntityIdsMap.get(cdl.ContentDocumentId).add(cdl.LinkedEntityId);
            }
        }
        if(!contentDocumentIdtoLinkedEntityIdsMap.isEmpty() && contentDocumentIdtoLinkedEntityIdsMap.keySet().size() == 1) {
            NavatarContentDocumentHandler.handleContentDocument(contentDocumentIdtoLinkedEntityIdsMap);
        }
    }
}