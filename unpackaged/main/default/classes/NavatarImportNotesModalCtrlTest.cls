@isTest
private class NavatarImportNotesModalCtrlTest {
    @isTest
    static void testDoPost() {
        // Create a test JSON data
        String jsonData = '{"Description":"Test Description","ImportID":"TestImportID","isError":false}';
        Blob jsonDataBlob = Blob.valueOf(jsonData);
        String base64EncodedData = EncodingUtil.base64Encode(jsonDataBlob);
        
        // Call the doPost method
        Test.startTest();
        String result = NavatarImportNotesModalCtrl.doPost(base64EncodedData);
        Test.stopTest();
        
        // Assert the result
        System.assertEquals('OK', result, 'Expected result should be OK');
        
        // Optionally, you can add more assertions based on the behavior of the doPost method
        // For example, you could verify if a ContentVersion record was inserted.
    }
}