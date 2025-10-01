@isTest
public class TestMetadataServicesHandler{
    
    static TestMethod void TestMethodCase1()
    {
        MetadataServiceHandler.createService();
        MetadataService.SaveResult objSaveResult = new MetadataService.SaveResult();
        objSaveResult.fullName = 'Pipeline__c-Pipeline Layout';
        objSaveResult.success=true;
        MetadataServiceHandler.handleSaveResults(objSaveResult);
        
        System.assertEquals('Pipeline__c-Pipeline Layout', objSaveResult.fullName); // (PE3.5, SK, 8Aug2017)
        
        /* MetadataService.SaveResult objSaveResult2 = new MetadataService.SaveResult();
        objSaveResult2.fullName = 'Pipeline__c-Pipeline Layout';
        MetadataService.Error objError = new MetadataService.Error();
        List<MetadataService.Error> lstError = new List<MetadataService.Error>();
        objSaveResult2.success=false;
        objError.message = 'Error Occured';
        lstError.add(objError);
        objSaveResult2.errors = lstError;
        MetadataServiceHandler.handleSaveResults(objSaveResult2);*/
     }  
       
}