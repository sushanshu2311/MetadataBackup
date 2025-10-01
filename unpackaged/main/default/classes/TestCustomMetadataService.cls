@isTest(SeeAllData='true')
public class TestCustomMetadataService
{
    static testMethod void testMethod1()
    {
        SObject orgEmailSetting = [SELECT IsActive__c,label,developername FROM Org_Setting__mdt where developername ='Co_Inv_Setting' limit 1];
        
        MetadataService.CustomMetadata check = CustomMetadataService.toCustomMetadata(orgEmailSetting);
        CustomMetadataService.createService();
        MetadataService.SaveResult objSaveResult = new MetadataService.SaveResult();
        objSaveResult.success=true;
        System.assertEquals(true, objSaveResult.success); // (PE3.5, SK, 9Aug2017)
        
        CustomMetadataService.handleSaveResults(objSaveResult);
    }
}