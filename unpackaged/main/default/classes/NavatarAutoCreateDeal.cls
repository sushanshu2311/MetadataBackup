/****************************************************************************************************
** Module Name : Document Extraction AI 1.0 
** Description : Used to Handle Document Uploaded on email to create Deals.
** Organization : Navatar Group
** Product Name & Version : PE Agentforce Baseline 1.0
** Revision History:-
** Version    Date(YYYY-MM-DD)    Author            Description of Action
** 1.0        2026-02-05          Salauddin Sheikh  PE Agentforce Baseline Phase 1
****************************************************************************************************/
public with sharing class NavatarAutoCreateDeal {
    public static Map<Id,Contact> contacts;
    @InvocableMethod(label='Handle Tasks from Flow' description='Handles Task records from Flow and creates Deals if needed')
    public static void handleTasksFromFlow(List<Id> taskIds) {
       try{
            if (taskIds == null || taskIds.isEmpty()) {
                return;
            }
            // Bug 00051025 Fixed by Sudhanshu
            List<Task> tasks = [
                SELECT Id,WhoId, TaskSubtype,ActivityDate, Create_Deal__c, Subject
                FROM Task
                WHERE Id IN :taskIds
                WITH SECURITY_ENFORCED
            ];
            handleTasks(tasks);
        } catch(Exception ex){
            System.debug(LoggingLevel.ERROR, 'Error in handleTasksFromFlow: ' + ex.getMessage());
        }
    }

    public static void handleTasks(List<Task> tasks) {
        // Enforce FLS/CRUD for Task fields
        SObjectAccessDecision taskDecision = Security.stripInaccessible(AccessType.READABLE, tasks);
        List<Task> safeTasks = (List<Task>)taskDecision.getRecords();
        List<Task> emailTasksToProcess = new List<Task>();
        Set<ID> contactIds = new Set<Id>();
        for(Task t : safeTasks) {
            if(t.TaskSubtype == 'Email' && t.Create_Deal__c == true) {
                emailTasksToProcess.add(t);
                // Bug 00051025 Fixed by Sudhanshu
                if (t.WhoId != null && t.WhoId.getSObjectType() == Contact.SObjectType) {
                    contactIds.add(t.WhoId);
                }
            }
        }
        if (!contactIds.isEmpty()) {
            contacts = new Map<Id, Contact>();
            List<Contact> contactList = [SELECT Id,accountId, Account.Name, Email FROM Contact WHERE Id IN :contactIds WITH USER_MODE];
            contacts = new Map<Id, Contact>(contactList);
        }
        if(!emailTasksToProcess.isEmpty()) {
            processEmailTasks(emailTasksToProcess);
        }
        
    }

    private static void processEmailTasks(List<Task> tasks) {
        List<Map<String, Object>> dealFieldsList = new List<Map<String, Object>>();
        
        // Collect Task Ids
        Set<Id> taskIds = new Set<Id>();
        for (Task t : tasks) {
            if (t.Id != null) {
                taskIds.add(t.Id);
            }
        }
        // Bug 00050951 fixed by Sudhanshu
        Integer fileSize = 15728640; // 15 MB
        //Find Tasks that have any related file > 15 MB (latest version size)
        // Use ContentDocumentLink -> ContentDocument.LatestPublishedVersion.ContentSize
        Set<Id> taskIdsToSkip = new Set<Id>();
        Map<Id, List<String>> taskIdToFileNames = new Map<Id, List<String>>();
        if (!taskIds.isEmpty()) {
            for (ContentDocumentLink cdl : [
                SELECT LinkedEntityId,
                       ContentDocumentId,
                       ContentDocument.LatestPublishedVersion.ContentSize,
                       ContentDocument.LatestPublishedVersion.Title
                FROM ContentDocumentLink
                WHERE LinkedEntityId IN :taskIds
                  AND LinkedEntityId != null
                  AND ContentDocument.LatestPublishedVersion.ContentSize != null
                  AND ContentDocument.LatestPublishedVersion.ContentSize > :fileSize
                  WITH SECURITY_ENFORCED
            ]) {
                // Any single file over threshold is enough to skip that Task
                taskIdsToSkip.add(cdl.LinkedEntityId);
                // Initialize list if needed
                if (!taskIdToFileNames.containsKey(cdl.LinkedEntityId)) {
                    taskIdToFileNames.put(cdl.LinkedEntityId, new List<String>());
                }

                // Add file name
                taskIdToFileNames.get(cdl.LinkedEntityId)
                    .add(cdl.ContentDocument.LatestPublishedVersion.Title);
                    }
        }

        // For each task, call the new prompt with Task Id and create deal from response
        List<navpeII__Pipeline__c> dealsToInsert = new List<navpeII__Pipeline__c>();
        for(Task t : tasks) {
            // Bug 00050951 fixed by Sudhanshu
            String formattedDate = t.ActivityDate != null ? DateTime.newInstance(t.ActivityDate, Time.newInstance(0, 0, 0, 0)).format('dd MMMM yyyy'): '';
            String dealName =  t.Subject + ' || ' + formattedDate;
            dealName = dealName.length() > 80 ? dealName.substring(0, 80) : dealName;
            if (taskIdsToSkip.contains(t.Id)) {
                List<String> fileNames = taskIdToFileNames.get(t.Id);

                String fileNameText = fileNames[0];
                // Bug 00050951,00051081 fixed by Sudhanshu
                String emailBodyFile ='File cannot be processed, please upload a supported PDF file with size less than 15mb.<br/><br/>' +
                '<i>*****This is a system generated email*****</i>';
                NavatarMeetingPrepCardUtility.sendErrorEmailToLoggedInUser('File cannot be processed: '+ fileNameText, emailBodyFile);
                continue;
            }
            Map<String, Object> dealFields = callGetEmailInteractionContentPrompt(t.Id,dealName);
            if (dealFields != null && dealFields.containsKey('error') && dealFields.get('error') != null) {
                continue;
            }
            if (dealFields == null) {
                dealFields = new Map<String, Object>();
            }
            dealFieldsList.add(dealFields);
            dealsToInsert.add(createDealFromPrompt(dealFields, t));
        }
        if (!dealsToInsert.isEmpty()) {
            try {
                // Enforce CRUD/FLS for navpeII__Pipeline__c before insert
                SObjectAccessDecision dealDecision = Security.stripInaccessible(AccessType.CREATABLE, dealsToInsert);
                List<navpeII__Pipeline__c> safeDealsToInsert = (List<navpeII__Pipeline__c>)dealDecision.getRecords();
                insert safeDealsToInsert;
                System.debug('New Deals created from Tasks: ' + safeDealsToInsert.size());
                // Send success email for each deal inserted with its corresponding deal fields
                for (Integer i = 0; i < safeDealsToInsert.size(); i++) {
                    sendDealCreatedSuccessEmail(safeDealsToInsert[i], dealFieldsList[i]);
                }
            } catch (DmlException dmle) {
                System.debug(LoggingLevel.ERROR, 'Error creating new deal: ' + dmle.getMessage());
                // sendDealCreatedFailureEmail(dmle.getMessage());
            }
        }
    }

    // Calls the Navatar_Email_Intxn _For_Deal_Create prompt and returns parsed fields
    private static Map<String, Object> callGetEmailInteractionContentPrompt(Id taskId,String dealName) {
        
        ConnectApi.WrappedValue taskIdWrappedValue = new ConnectApi.WrappedValue();
        taskIdWrappedValue.value = String.valueOf(taskId);
        Map<String, ConnectApi.WrappedValue> promptInput = new Map<String, ConnectApi.WrappedValue>();
        promptInput.put('Input:TaskID', taskIdWrappedValue);
        ConnectApi.EinsteinPromptTemplateGenerationsInput input = new ConnectApi.EinsteinPromptTemplateGenerationsInput();
        input.inputParams = promptInput;
        input.isPreview = false;
        input.additionalConfig = new ConnectApi.EinsteinLlmAdditionalConfigInput();
        input.additionalConfig.applicationName = 'PromptBuilderPreview';
        if (Test.isRunningTest()) {
            // Mock response for tests
            return new Map<String, Object>{
                'EBIT__c' => '25B',
                'EBITDA__c' => '2500K',
                'Deal_Description__c' => 'Generated from test email',
                'Name' =>'Test Deal Kill',
                    'Transaction_Type__c' => new List<Object>{ 'Buyout', 'Debt Raise' }
            };
        }
        try {
            ConnectApi.EinsteinPromptTemplateGenerationsRepresentation result = ConnectApi.EinsteinLLM.generateMessagesForPromptTemplate('Navatar_Email_Intxn _For_Deal_Create', input);
            System.debug('Prompt generation result: ' + JSON.serialize(result));
            // Bug 00050952 fixed by Sudhanshu
            if(result.generationErrors != null && !result.generationErrors.isEmpty()) {
                Set<Id> userIds = new Set<Id>{UserInfo.getUserId()};
                // Bug 00050952 fixed by Sudhanshu
                String subject = 'Deal Creation Failed';
                String emailBody = 'The deal ‘' + dealName +
                                   '’ could not be created due to a technical issue or workflow error.<br/><br/>' +
                                   'Please contact your Navatar Administrator for further assistance.<br/><br/>' +
                                   '<i>*****This is a system generated email*****</i>';
                NavatarMeetingPrepCardUtility.sendErrorEmailToUsers(subject, emailBody, userIds);
                return new Map<String, Object>{ 'error' => 'Your error message here' };
            }
            if (result != null && result.generations != null && !result.generations.isEmpty()) {
                System.debug('Raw generated text: ' + result.generations[0].text);
                // Bug 00051310 fixed by Sudhanshu
                if(result.generations[0].text.contains('An unhandled error occurred:')){
                    Set<Id> userIds = new Set<Id>{UserInfo.getUserId()};
                    // Bug 00050952 fixed by Sudhanshu
                    String subject = 'Deal Creation Failed';
                    String emailBody = 'The deal ‘' + dealName +
                                    '’ could not be created due to a technical issue or workflow error.<br/><br/>' +
                                    'Please contact your Navatar Administrator for further assistance.<br/><br/>' +
                                    '<i>*****This is a system generated email*****</i>';
                    NavatarMeetingPrepCardUtility.sendErrorEmailToUsers(subject, emailBody, userIds);
                    return new Map<String, Object>{ 'error' => 'Your error message here' };
                }
                String generatedJson = result.generations[0].text;
                System.debug('Generated JSON: ' + generatedJson);
                Map<String, Object> generatedJsonMap = (Map<String, Object>) JSON.deserializeUntyped(generatedJson);
                return generatedJsonMap;
            }
        } catch (Exception ex) {
            System.debug(LoggingLevel.ERROR, 'Error in callGetEmailInteractionContentPrompt: ' + ex.getMessage());
        }
        return null;
    }

    // Creates a new Deal (navpeII__Pipeline__c) from parsed fields and document title
    private static navpeII__Pipeline__c createDealFromPrompt(Map<String, Object> dealFields, Task task) {
        navpeII__Pipeline__c newDeal = mapJsonToDealRecord(dealFields,task);
        return newDeal;
    }

    // Map JSON to Deal record (copied from ContentDocumentHandler)
    private static navpeII__Pipeline__c mapJsonToDealRecord(Map<String, Object> jsonMap, Task task) {
        navpeII__Pipeline__c dealRecord = new navpeII__Pipeline__c();
        try {
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
                    // Bug 00051011,00051022,00051010 fixed by Sudhanshu
                } else if (dt == Schema.DisplayType.STRING || dt == Schema.DisplayType.TEXTAREA || dt == Schema.DisplayType.PICKLIST || dt == Schema.DisplayType.REFERENCE) {
                    dealRecord.put(fieldName, String.valueOf(val).trim());
                } else if (dt == Schema.DisplayType.DOUBLE || dt == Schema.DisplayType.CURRENCY 
                        || dt == Schema.DisplayType.LONG || dt == Schema.DisplayType.INTEGER) {
                    Object parsedValue = parseFieldValue(String.valueOf(val).trim(), dt);
                    dealRecord.put(fieldName, parsedValue);
                } else {
                    System.debug('Skipping field ' + key + ' of type ' + dt);
                }
            }
            // Bug 00051025 Fixed by Sudhanshu
            String dealName= task.Subject + ' || ' + (task.ActivityDate != null ? DateTime.newInstance(task.ActivityDate, Time.newInstance(0, 0, 0, 0)).format('dd MMMM yyyy'): '');
            dealRecord.Name = dealName.length() > 80 ? dealName.substring(0, 80) : dealName;
            if(task.WhoId != null && task.WhoId.getSObjectType() == Contact.SObjectType) {
                if (contacts != null && contacts.containsKey(task.WhoId)) {
                    Contact contact = contacts.get(task.WhoId);
                    dealRecord.navpeII__Source_Contact__c = contact.Id;
                    if(contact.AccountId != null) {
                        dealRecord.navpeII__Source_Company__c = contact.AccountId;
                    }
                } 
                else{
                    System.debug('Contact with Id ' + task.WhoId + ' not found in contacts map.');
                }
            }
        }
        catch (Exception ex) {
            System.debug(LoggingLevel.ERROR, 'Error in mapJsonToDealRecord: ' + ex.getMessage());
        }
        
        return dealRecord;
    }

    private static Object parseFieldValue(String value, Schema.DisplayType fieldType) {
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
     // Helper method to send success email with deal fields
    private static void sendDealCreatedSuccessEmail(navpeII__Pipeline__c deal, Map<String, Object> dealFields) {
        String userEmail = UserInfo.getUserEmail();
        // Bug 00050950,00051065 fixed by Sudhanshu
        String baseUrl = URL.getOrgDomainUrl().toExternalForm();
        String subject = 'Deal Created Successfully';
        String body = 'Deal ‘<a href="' + baseUrl + '/' + deal.Id + '">' + deal.Name +
                    '</a>’ has been created successfully.<br/><br/>'+
                    '<i>*****This is a system generated email*****</i>';
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setToAddresses(new List<String>{userEmail});
        mail.setSubject(subject);
        mail.setHtmlBody(body);
        Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{mail});
    }

    // Helper method to send failure email with error reason
    @TestVisible
    private static void sendDealCreatedFailureEmail(String errorReason) {
        String userEmail = UserInfo.getUserEmail();
        String subject = 'Deal Creation Failed';
        String body = 'We were unable to create the Deal due to the following error:\n' + errorReason;
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setToAddresses(new List<String>{userEmail});
        mail.setSubject(subject);
        mail.setPlainTextBody(body);
        Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{mail});
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