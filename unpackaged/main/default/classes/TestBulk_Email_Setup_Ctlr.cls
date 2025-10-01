@isTest
public class TestBulk_Email_Setup_Ctlr
{
    @isTest(onInstall=True)
    static void testBulkEmail()
    {
        Bulk_Email_Setup_Ctlr BES = new Bulk_Email_Setup_Ctlr();
        BES.strErrorMsg='XYXYXYX';
        
        System.assertEquals('XYXYXYX', BES.strErrorMsg); // (PE3.5, SK, 8Aug2017)
        
        BES.editBulkEmailSetup();
        BES.onSaveBulkEmailSetup();
    }
}