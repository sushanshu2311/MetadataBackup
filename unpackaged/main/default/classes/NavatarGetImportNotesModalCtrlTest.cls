@isTest
private class NavatarGetImportNotesModalCtrlTest {
    @isTest
    static void testGetImportID() {
        // Call the method to get the import ID
        String importId = NavatarGetImportNotesModalCtrl.getImportID();

        // Check if the import ID is not null and has the expected format
        System.assertNotEquals(null, importId);
        System.assertEquals('NavatarImp', importId.substring(0, 10)); // Assuming 'Imp' prefix
        System.assertEquals(18, importId.length()); // Assuming 3 characters for 'Imp' + 8 characters random number
    }

    @isTest
    static void testGetRecord() {
        // Prepare test data
        ContentVersion cv = new ContentVersion();
        cv.Title = 'TestTitle';
        cv.PathOnClient = 'TestPath';
        cv.VersionData = Blob.valueOf('Test Data');
        insert cv;

        ContentDocument cd = [SELECT Id FROM ContentDocument LIMIT 1];
        
        // Call the method to get the record
        String fileContent = NavatarGetImportNotesModalCtrl.getRecord('TestTitle');

        // Check if the file content is not null and matches the inserted test data
        System.assertNotEquals(null, fileContent);
        System.assertEquals('Test Data', fileContent);

        // Check if the ContentDocument record is deleted
        System.assertEquals(0, [SELECT COUNT() FROM ContentDocument WHERE Id = :cd.Id]);
    }
}