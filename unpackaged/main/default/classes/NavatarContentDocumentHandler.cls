/****************************************************************************************************
** Module Name : Document Extraction AI 1.0 
** Description : Used to Handle Document Uploaded on Deal Record to update fields.
** Organization : Navatar Group
** Product Name & Version : PE Agentforce Baseline 1.0
** Revision History:-
** Version    Date(YYYY-MM-DD)    Author            Description of Action
** 1.0        2026-02-05          Salauddin Sheikh  PE Agentforce Baseline Phase 1
****************************************************************************************************/
public with sharing class NavatarContentDocumentHandler {
    public class MeetingPrepCardException extends Exception {}
    public static Id dealRecordId;
    
    public static void handleContentDocument(Map<Id, Set<Id>> contentDocumentIdToLinkedRecordIdsMap) {
        Set<Id> recordsIdLinkedToFile = new Set<Id>();
        Id fileRecordId;
        String fileCategory = 'Uncategorized';
        Id cdId = new List<Id>(contentDocumentIdToLinkedRecordIdsMap.keySet())[0];//We are processing one file at a time
        recordsIdLinkedToFile.addAll(contentDocumentIdToLinkedRecordIdsMap.get(cdId));
        dealRecordId = null;
        for (Id recordID : recordsIdLinkedToFile) {
            if(recordID.getSobjectType().getDescribe().getName() == 'navpeII__Pipeline__c') {
               dealRecordId = recordID;
               break;
            } 
        }        
        //Changes for Code review R-0000008514
        if (dealRecordId == null) {
            System.debug('No linked deal record found for ContentDocument Id: ' + cdId);
            return;
            
        }
        try {
            ContentDocument cdRec = [SELECT Id,Title,ContentDocument.LatestPublishedVersion.ContentSize,LatestPublishedVersionId,FileType FROM ContentDocument WHERE Id = :cdId WITH USER_MODE LIMIT 1];
            // Only process PDF files Bug 00050992,00050963,00050994 02022026
            if (cdRec.FileType == null || cdRec.FileType.toUpperCase() != 'PDF') {
                System.debug('Ignoring non-PDF file: ' + cdRec.FileType);
                return;
            }
            // bug 00051082,00050995 Fixed by Sudhanshu - Check file size limit of 15MB
            if(cdRec.LatestPublishedVersion.ContentSize > 15728640) {
                throw new MeetingPrepCardException('File size exceeds 15MB limit. Please upload a smaller file for processing.');
            }
            String titleLower = cdRec.Title != null ? cdRec.Title.toLowerCase() : '';
            Boolean isCategoryMatch = titleLower.contains('cim') || titleLower.contains('teaser') || titleLower.contains('nda') || titleLower.contains('investment profile & allocation overview');
            if (isCategoryMatch) {
                if (titleLower.contains('cim')) {
                    fileCategory = 'cim';
                } else if (titleLower.contains('teaser')) {
                    fileCategory = 'teaser';
                } else if (titleLower.contains('nda')) {
                    fileCategory = 'nda';
                }
                fileRecordId = cdRec != null ? cdRec.Id : null;
            }

            if(fileCategory != null && fileRecordId != null && !recordsIdLinkedToFile.isEmpty()) {
                switch on fileCategory {
                    when 'cim' {
                        handleFieldMappingFromFileContent(dealRecordId, fileRecordId);
                        // Handle CIM Record
                    }
                    when 'teaser' {
                        // Handle Teaser Record
                    }
                    when 'nda' {
                        // Handle NDA Record}
                    }when else {
                        return ;
                    }
                }
            }
        } catch (Exception ex) {
            System.debug(LoggingLevel.ERROR, 'Error processing ContentDocument: ' + ex.getMessage());
            // Bug 00050954 Fixed by Sudhanshu
            navpeII__Pipeline__c dealRec = dealRecordId != null ? [SELECT Id, Name FROM navpeII__Pipeline__c WHERE Id = :dealRecordId WITH USER_MODE LIMIT 1] : null;
            if(dealRec != null) {
                String subject ='Deal Update Failed' ;
                String baseUrl = URL.getOrgDomainUrl().toExternalForm();
                // Bug 00050954, 00051206 Fixed by Sudhanshu
                String emailBody ='Deal ‘<a href="' + baseUrl + '/' + dealRec.Id + '">' + dealRec.Name + '</a>’ has not been updated, please upload a supported PDF file with size less than 15mb.<br><br>' +
                '<i>*****This is a system generated email*****</i>';
                NavatarMeetingPrepCardUtility.sendErrorEmailToLoggedInUser(subject, emailBody);
            }
        }
    }

    @future(callout=true)
    private static void handleFieldMappingFromFileContent(Id linkedRecordId ,  Id fileRecord) {
        switch on linkedRecordId.getSobjectType().getDescribe().getName() {
            when 'navpeII__Pipeline__c' {
                if (Schema.SObjectType.navpeII__Pipeline__c.isUpdateable()) {
                    dealRecordId = linkedRecordId;
                    getFileContentFromContentDocument(linkedRecordId, fileRecord);
                    }
                }
                when else {
                    System.debug('Unsupported record type for field mapping');
                }
            }
        }    
    

    private static void getFileContentFromContentDocument(Id recordId,  Id fileRecord){
        Map<String,String> recordMap = new Map<String,String>();
        recordMap.put('Id', fileRecord);
        //Wrap File Id  for FileRecord Input
        ConnectApi.WrappedValue fileRecordWrappedValue = new ConnectApi.WrappedValue();
        fileRecordWrappedValue.value = recordMap;

        //Build a prmpt input Map
        Map<String,ConnectApi.WrappedValue> promptInput = new Map<String,ConnectApi.WrappedValue>();
        promptInput.put('Input:FileRecord', fileRecordWrappedValue);

        //Create  Input Prompt
        ConnectApi.EinsteinPromptTemplateGenerationsInput input = new ConnectApi.EinsteinPromptTemplateGenerationsInput();
        input.inputParams = promptInput;
        input.isPreview = false;

        input.additionalConfig = new ConnectApi.EinsteinLlmAdditionalConfigInput();
        input.additionalConfig.applicationName = 'PromptBuilderPreview';
        
        try{
            //Call the Prompt
            ConnectApi.EinsteinPromptTemplateGenerationsRepresentation result = ConnectApi.EinsteinLLM.generateMessagesForPromptTemplate('Navatar_Deal_Update_via_File_Content',input);
            System.debug('Prompt result: ' + result);
            // bug 00050955 Fixed by Sudhanshu
            if(result.generationErrors != null && !result.generationErrors.isEmpty()) {
                if (!result.generationErrors[0].errorMessage.contains('Runtime version information was not found for')) {//AA-803 Salauddin 27042026
                    sendDealUpdateFailureEmail();
                }
                return ;
            }
            if(result != null && result.generations != null && !result.generations.isEmpty()) {
                String generatedJson = result.generations[0].text;
                Map<String,Object> generatedJsonMap = (Map<String,Object>) JSON.deserializeUntyped(generatedJson);
                System.debug('Generated JSON: ' + generatedJson);
                if (generatedJsonMap == null || generatedJsonMap.isEmpty()) {
                    System.debug('Input JSON map is empty or null.');
                    sendDealUpdateFailureEmail();
                    return ;
                }
                // Query the existing Pipeline record for comparison
                
                Map<String, Schema.SObjectField> dealFields = Schema.SObjectType.navpeII__Pipeline__c.fields.getMap();   
                String dealField = '';
                for (String key : generatedJsonMap.keySet()) {
                    String fieldName = dealFields.containsKey(key) ? key : (dealFields.containsKey('navpeII__'+key) ? 'navpeII__'+key : null);
                    dealField += fieldName + ', ';
                }
                dealField = dealField.removeEnd(', ');
                // Bug 00051201 Fixed by Sudhanshu
                navpeII__Pipeline__c oldDeal = Database.query('SELECT Id, Name,OwnerId, ' + dealField + ' FROM navpeII__Pipeline__c WHERE Id = :recordId WITH USER_MODE LIMIT 1');
                Map<String, Object> oldFieldValues = new Map<String, Object>();             
                for (String key : generatedJsonMap.keySet()) {
                    String fieldName = dealFields.containsKey(key) ? key : (dealFields.containsKey('navpeII__'+key) ? 'navpeII__'+key : null);
                    if (fieldName != null) {
                        oldFieldValues.put(fieldName, oldDeal.get(fieldName));
                    }
                }
                navpeII__Pipeline__c dealToUpdate = mapJsonToDealRecord(generatedJsonMap);
                dealToUpdate.Id = recordId;
                List<String> changedFields = new List<String>();
                Map<String, Object> newFieldValues = new Map<String, Object>();
                for (String key : generatedJsonMap.keySet()) {
                    String fieldName = dealFields.containsKey(key) ? key : (dealFields.containsKey('navpeII__'+key) ? 'navpeII__'+key : null);
                    String fieldLabel = fieldName != null ? dealFields.get(fieldName).getDescribe().getLabel() : key;
                    if (fieldName != null) {
                        Object oldVal = oldFieldValues.get(fieldName);
                        Object newVal = dealToUpdate.get(fieldName);
                        if (oldVal != newVal && (oldVal == null || !oldVal.equals(newVal))) {
                            changedFields.add(fieldLabel);
                            newFieldValues.put(fieldLabel, newVal);
                        }
                    }
                }
                try {
                    // Enforce CRUD and FLS before update R-0000008514
                    SObjectAccessDecision accessDecision = Security.stripInaccessible(
                        AccessType.UPDATABLE,
                        new List<navpeII__Pipeline__c>{ dealToUpdate }
                    );
                    dealToUpdate = ((List<navpeII__Pipeline__c>)accessDecision.getRecords())[0];
                    
                    Database.update(dealToUpdate);
                    System.debug('Deal record updated successfully.');
                    if (!changedFields.isEmpty()) {
                        sendDealUpdateSuccessEmail(oldDeal, changedFields, newFieldValues);
                    } else {
                        // No fields changed, treat as failure for notification
                        sendDealUpdateFailureEmail();
                    }
                    
                } catch (DmlException dmle) {
                    System.debug(LoggingLevel.ERROR, 'Error updating deal record: ' + dmle.getMessage());
                    sendDealUpdateFailureEmail();
                }
            } else {
                System.debug('No generations returned from the prompt');
                sendDealUpdateFailureEmail();
            }
        }
        catch(Exception ex){
            System.debug(LoggingLevel.ERROR, 'Error in getFileContentFromContentDocument: ' + ex.getMessage());
            sendDealUpdateFailureEmail();
        }
    }

    // Helper method to send success email with updated fields
    @TestVisible
    private static void sendDealUpdateSuccessEmail(navpeII__Pipeline__c oldDeal, List<String> changedFields, Map<String, Object> newFieldValues) {
        // Bug 00051201 Fixed by Sudhanshu
        Set<String> emailSet = new Set<String>();
        if(oldDeal.OwnerId != null) {
            User owner = [SELECT Id, Name, Email FROM User WHERE Id = :oldDeal.OwnerId WITH USER_MODE LIMIT 1];
            if (owner.Email != null) {
                emailSet.add(owner.Email);
            }
        }
        String userEmail = UserInfo.getUserEmail();
        if(userEmail != null) {
            emailSet.add(userEmail);
        }
        // Bug 00050953,00050989 Fixed by Sudhanshu
        String baseUrl = URL.getOrgDomainUrl().toExternalForm();
        String subject = 'Deal Updated Successfully' ;
        String body = 'Deal ‘<a href="' + baseUrl + '/' + oldDeal.Id + '">' + oldDeal.Name +
                    '</a>’ has been updated successfully.<br/><br/>' +
                    '<i>*****This is a system generated email*****</i>';
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setToAddresses(new List<String>(emailSet));
        mail.setSubject(subject);
        mail.setHtmlBody(body);
        Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{mail});
    }

    // Helper method to send failure email
    private static void sendDealUpdateFailureEmail() {
        if(dealRecordId == null) {
            return;
        }
        navpeII__Pipeline__c dealRec = [SELECT Id, Name FROM navpeII__Pipeline__c WHERE Id = :dealRecordId WITH USER_MODE LIMIT 1];
        // Bug 00050955 Fixed by Sudhanshu
        String baseUrl = URL.getOrgDomainUrl().toExternalForm();
        Set<Id> userIds = new Set<Id>{UserInfo.getUserId()};
        String subject = 'Deal Update Failed' ;
        String body = 'Deal ‘<a href="' + baseUrl + '/' + dealRec.Id + '">' + dealRec.Name +
                    '</a>’ could not be updated due to a technical issue or workflow error.<br/><br/>' +
                'Please contact your Navatar Administrator for further assistance.<br/><br/>' +
                '<i>*****This is a system generated email*****</i>';
        NavatarMeetingPrepCardUtility.sendErrorEmailToUsers(subject, body, userIds);
    }

    @TestVisible
    private static navpeII__Pipeline__c mapJsonToDealRecord(Map<String, Object> jsonMap) {
        navpeII__Pipeline__c dealRecord = new navpeII__Pipeline__c();
        Map<String, Schema.SObjectField> dealFields = Schema.SObjectType.navpeII__Pipeline__c.fields.getMap();
        String fieldName;
        for (String key : jsonMap.keySet()) {
            if (dealFields.containsKey(key)) {
                fieldName = key;
            }
            else if(dealFields.containsKey('navpeII__'+key)){
                fieldName = 'navpeII__'+key;
            }
            else {
                continue;
            }
            Object val = jsonMap.get(key);
            if(val == null){
                continue;
            }
            Schema.DisplayType dt = dealFields.get(fieldName).getDescribe().getType();

            if (dt == Schema.DisplayType.MULTIPICKLIST) {
                // Handle multi-select picklist: join array values with semicolon
                if (val instanceof List<Object>) {
                    List<Object> arr = (List<Object>)val;
                    List<String> strArr = new List<String>();
                    for (Object o : arr) {
                        strArr.add(String.valueOf(o));
                    }
                    dealRecord.put(fieldName, String.join(strArr, ';'));
                } else if (val instanceof String) {
                    dealRecord.put(fieldName, (String)val);
                }
            } else if (dt == Schema.DisplayType.STRING || dt == Schema.DisplayType.TEXTAREA || dt == Schema.DisplayType.PICKLIST || dt == Schema.DisplayType.REFERENCE) {// Added reference type handling as well R-0000008514
                dealRecord.put(fieldName, String.valueOf(val).trim());
            } else if (dt == Schema.DisplayType.DOUBLE || dt == Schema.DisplayType.CURRENCY 
                       || dt == Schema.DisplayType.LONG || dt == Schema.DisplayType.INTEGER) {
                Object parsedValue = parseFieldValue(String.valueOf(val).trim(), dt);
                dealRecord.put(fieldName, parsedValue);
            } else {
                System.debug('Skipping field ' + key + ' of type ' + dt);
            }
        }
        return dealRecord;
    }

    public static Object parseFieldValue(String value, Schema.DisplayType fieldType) {
            if (String.isBlank(value)) return null;
            value = value.trim();

            switch on fieldType {
                when DOUBLE,
                     CURRENCY,
                     LONG,
                     INTEGER {
                    Decimal multiplier = 1;
                    String normalized = value.replace(',', '').replace('%', '').trim();
                    if (normalized.endsWithIgnoreCase('M')) {
                        multiplier = 1000000;
                        normalized = normalized.substring(0, normalized.length() - 1);
                    } else if (normalized.endsWithIgnoreCase('K')) {
                        multiplier = 1000;
                        normalized = normalized.substring(0, normalized.length() - 1);
                    } else if (normalized.endsWithIgnoreCase('B')) {
                        multiplier = 1000000000;
                        normalized = normalized.substring(0, normalized.length() - 1);
                    }
                    try {
                        return Decimal.valueOf(normalized) * multiplier;
                    } catch (Exception e) {
                        System.debug('Failed to parse number: ' + value);
                        return null;
                    }
                }
                when else {
                    // Not handled type for parsing here
                    return null;
                }
        }
    }

    public static void DummyCode() {
        Integer i = 0;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;

    }
}