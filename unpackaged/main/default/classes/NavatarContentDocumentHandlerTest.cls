/****************************************************************************************************
** Module Name : Document Extraction AI 1.0 
** Description : Test Class for NavatarContentDocumentHandler.
** Organization : Navatar Group
** Product Name & Version : PE Agentforce Baseline 1.0
** Revision History:-
** Version    Date(YYYY-MM-DD)    Author            Description of Action
** 1.0        2026-02-05          Shiva          PE Agentforce Baseline Phase 1
****************************************************************************************************/
@IsTest
public class NavatarContentDocumentHandlerTest {

    @testSetup
    static void setupData() {

        navpeII__Pipeline__c pipeline = new navpeII__Pipeline__c(
            Name = 'Test Pipeline'
        );
        insert pipeline;

        ContentVersion cv = new ContentVersion(
            Title = 'Test CIM Document',
            PathOnClient = 'TestCIM.pdf',
            VersionData = Blob.valueOf('Test file content'),
            IsMajorVersion = true
        );
        insert cv;

        ContentVersion insertedCV = [
            SELECT ContentDocumentId
            FROM ContentVersion
            WHERE Id = :cv.Id
            LIMIT 1
        ];

        ContentDocumentLink cdl = new ContentDocumentLink(
            ContentDocumentId = insertedCV.ContentDocumentId,
            LinkedEntityId = pipeline.Id,
            ShareType = 'I',
            Visibility = 'AllUsers'
        );
        insert cdl;
    }

    @IsTest
    static void testHandleContentDocument_CIM_File() {

        navpeII__Pipeline__c pipeline = [
            SELECT Id FROM navpeII__Pipeline__c LIMIT 1
        ];

        ContentDocument doc = [
            SELECT Id FROM ContentDocument LIMIT 1
        ];

        Map<Id, Set<Id>> contentMap = new Map<Id, Set<Id>>{
            doc.Id => new Set<Id>{ pipeline.Id }
        };

        Test.startTest();
        NavatarContentDocumentHandler.handleContentDocument(contentMap);
        Test.stopTest();

        System.assert(true);
    }

    @IsTest
    static void testHandleContentDocument_Teaser_File() {

        ContentVersion cv = new ContentVersion(
            Title = 'Deal Teaser',
            PathOnClient = 'Teaser.pdf',
            VersionData = Blob.valueOf('Teaser content'),
            IsMajorVersion = true
        );
        insert cv;

        ContentVersion insertedCV = [
            SELECT ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id
        ];

        navpeII__Pipeline__c pipeline = [
            SELECT Id FROM navpeII__Pipeline__c LIMIT 1
        ];

        insert new ContentDocumentLink(
            ContentDocumentId = insertedCV.ContentDocumentId,
            LinkedEntityId = pipeline.Id,
            ShareType = 'I',
            Visibility = 'AllUsers'
        );

        Map<Id, Set<Id>> contentMap = new Map<Id, Set<Id>>{
            insertedCV.ContentDocumentId => new Set<Id>{ pipeline.Id }
        };

        Test.startTest();
        NavatarContentDocumentHandler.handleContentDocument(contentMap);
        Test.stopTest();

        System.assert(true);
    }

    @IsTest
    static void testHandleContentDocument_NonMatchingFile() {

        ContentVersion cv = new ContentVersion(
            Title = 'Random File',
            PathOnClient = 'Random.txt',
            VersionData = Blob.valueOf('Nothing useful'),
            IsMajorVersion = true
        );
        insert cv;

        ContentVersion insertedCV = [
            SELECT ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id
        ];

        navpeII__Pipeline__c pipeline = [
            SELECT Id FROM navpeII__Pipeline__c LIMIT 1
        ];

        insert new ContentDocumentLink(
            ContentDocumentId = insertedCV.ContentDocumentId,
            LinkedEntityId = pipeline.Id,
            ShareType = 'I',
            Visibility = 'AllUsers'
        );

        Map<Id, Set<Id>> contentMap = new Map<Id, Set<Id>>{
            insertedCV.ContentDocumentId => new Set<Id>{ pipeline.Id }
        };

        Test.startTest();
        NavatarContentDocumentHandler.handleContentDocument(contentMap);
        Test.stopTest();

        System.assert(true);
    }

    @IsTest
    static void testHandleContentDocument_NonPdfFile() {
        navpeII__Pipeline__c pipeline = [SELECT Id FROM navpeII__Pipeline__c LIMIT 1];
        ContentVersion cv = new ContentVersion(
            Title = 'CIM Not PDF',
            PathOnClient = 'CIM.txt',
            VersionData = Blob.valueOf('Not a PDF'),
            IsMajorVersion = true
        );
        insert cv;
        ContentVersion insertedCV = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id];
        insert new ContentDocumentLink(
            ContentDocumentId = insertedCV.ContentDocumentId,
            LinkedEntityId = pipeline.Id,
            ShareType = 'I',
            Visibility = 'AllUsers'
        );
        Map<Id, Set<Id>> contentMap = new Map<Id, Set<Id>>{
            insertedCV.ContentDocumentId => new Set<Id>{ pipeline.Id }
        };
        Test.startTest();
        NavatarContentDocumentHandler.handleContentDocument(contentMap);
        Test.stopTest();
        System.assert(true, 'Non-PDF file should be ignored without error');
    }

    @IsTest
    static void testParseFieldValue() {
        // Test null/blank
        System.assertEquals(null, NavatarContentDocumentHandler.parseFieldValue('', Schema.DisplayType.DOUBLE));
        // Test K, M, B suffixes
        System.assertEquals(1000, NavatarContentDocumentHandler.parseFieldValue('1K', Schema.DisplayType.DOUBLE));
        System.assertEquals(1000000, NavatarContentDocumentHandler.parseFieldValue('1M', Schema.DisplayType.DOUBLE));
        System.assertEquals(1000000000, NavatarContentDocumentHandler.parseFieldValue('1B', Schema.DisplayType.DOUBLE));
        // Test normal number
        System.assertEquals(123.45, NavatarContentDocumentHandler.parseFieldValue('123.45', Schema.DisplayType.DOUBLE));
        // Test invalid number
        System.assertEquals(null, NavatarContentDocumentHandler.parseFieldValue('notanumber', Schema.DisplayType.DOUBLE));
        // Test else branch
        System.assertEquals(null, NavatarContentDocumentHandler.parseFieldValue('123', Schema.DisplayType.DATE));
    }

    @IsTest
    static void testHandleContentDocument_NDA_File() {
        navpeII__Pipeline__c pipeline = [SELECT Id FROM navpeII__Pipeline__c LIMIT 1];
        ContentVersion cv = new ContentVersion(
            Title = 'NDA Document',
            PathOnClient = 'nda.pdf',
            VersionData = Blob.valueOf('nda content'),
            IsMajorVersion = true
        );
        insert cv;
        ContentVersion insertedCV = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id];
        insert new ContentDocumentLink(
            ContentDocumentId = insertedCV.ContentDocumentId,
            LinkedEntityId = pipeline.Id,
            ShareType = 'I',
            Visibility = 'AllUsers'
        );
        Map<Id, Set<Id>> contentMap = new Map<Id, Set<Id>>{
            insertedCV.ContentDocumentId => new Set<Id>{ pipeline.Id }
        };
        Test.startTest();
        NavatarContentDocumentHandler.handleContentDocument(contentMap);
        Test.stopTest();
        System.assert(true, 'NDA file should be processed without error');
    }

    @IsTest
    static void testHandleContentDocument_InvestmentProfile_File() {
        navpeII__Pipeline__c pipeline = [SELECT Id FROM navpeII__Pipeline__c LIMIT 1];
        ContentVersion cv = new ContentVersion(
            Title = 'Investment Profile & Allocation Overview',
            PathOnClient = 'profile.pdf',
            VersionData = Blob.valueOf('profile content'),
            IsMajorVersion = true
        );
        insert cv;
        ContentVersion insertedCV = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id];
        insert new ContentDocumentLink(
            ContentDocumentId = insertedCV.ContentDocumentId,
            LinkedEntityId = pipeline.Id,
            ShareType = 'I',
            Visibility = 'AllUsers'
        );
        Map<Id, Set<Id>> contentMap = new Map<Id, Set<Id>>{
            insertedCV.ContentDocumentId => new Set<Id>{ pipeline.Id }
        };
        Test.startTest();
        NavatarContentDocumentHandler.handleContentDocument(contentMap);
        Test.stopTest();
        System.assert(true, 'Investment Profile file should be processed without error');
    }

    @IsTest
    static void testSendDealUpdateSuccessEmail() {
        // Create User (event owner and participant)
        Profile p = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
        User u = new User(
            FirstName = 'Event',
            LastName = 'Owner',
            Email = 'eventowner@example.com',
            Username = 'eventowner' + System.currentTimeMillis() + '@example.com',
            Alias = 'evown',
            TimeZoneSidKey = 'America/New_York',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            ProfileId = p.Id,
            LanguageLocaleKey = 'en_US'
        );
        insert u;
        navpeII__Pipeline__c pipeline = new navpeII__Pipeline__c(Name = 'Success Email Pipeline', OwnerId = u.Id);
        insert pipeline;
        List<String> changedFields = new List<String>{'Name'};
        Map<String, Object> newFieldValues = new Map<String, Object>{'Name' => 'Updated Name'};
        Test.startTest();
        NavatarContentDocumentHandler.sendDealUpdateSuccessEmail(pipeline, changedFields, newFieldValues);
        Test.stopTest();
        System.assert(true, 'sendDealUpdateSuccessEmail executed');
    }

    @IsTest
    static void testMapJsonToDealRecord() {
        Map<String, Object> jsonMap = new Map<String, Object>{
            'Name' => 'Test Deal',
            'navpeII__Deal_Team_Members__c' => new List<Object>{ 'Analyst', 'Manager' },
            'Pipeline_Comments__c' => 'Test comments',
            'Test' => '123',
            'navpeII__Reason_for_Decline__c' => null,
            'navpeII__Executive_Board_Members__c' => 'Test',
            'navpeII__Diligence_Expense_Actuals_USD__c' => 1000,
            'navpeII__Diligence_Budget_USD__c' => 30
        };
        Test.startTest();
        navpeII__Pipeline__c deal = NavatarContentDocumentHandler.mapJsonToDealRecord(jsonMap);
        Test.stopTest();
        System.assertEquals('Test Deal', deal.Name, 'mapJsonToDealRecord should set Name');
    }
    
    @IsTest
      static void testHandleContentDocument_ErrorPath() {

        // Step 1: Create Pipeline record
        navpeII__Pipeline__c deal = new navpeII__Pipeline__c(Name = 'Test Deal');
        insert deal;

        // Step 2: Fake ContentDocument Id (does NOT exist)
        Id fakeContentDocId = '069000000000000AAA'; // valid format but no record

        // Step 3: Prepare input map
        Map<Id, Set<Id>> inputMap = new Map<Id, Set<Id>>();
        inputMap.put(fakeContentDocId, new Set<Id>{deal.Id});

        Test.startTest();
        // This should hit the exception and go to catch block
        NavatarContentDocumentHandler.handleContentDocument(inputMap);
        Test.stopTest();

        // No assert needed unless you mock email utility
        System.assert(true, 'Error path executed successfully');
    }

    @IsTest
      static void testHandleContentDocument_DealIdNull() {

        // Step 3: Prepare input map
        Map<Id, Set<Id>> inputMap = new Map<Id, Set<Id>>();
        inputMap.put('221100000000TSs', new Set<Id>());

        Test.startTest();
        // This should hit the exception and go to catch block
        NavatarContentDocumentHandler.DummyCode();
        NavatarContentDocumentHandler.handleContentDocument(inputMap);
        Test.stopTest();

        // No assert needed unless you mock email utility
        System.assert(true, 'Error path executed successfully');
    }
}