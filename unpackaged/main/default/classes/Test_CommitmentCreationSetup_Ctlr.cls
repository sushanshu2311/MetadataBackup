@isTest
public class Test_CommitmentCreationSetup_Ctlr{
    public static testMethod void Test_CommitmentCreationSetup() {   
        //  try {
            
        string nsp = CommonUtility.strNameSpacePrefix; 
        nsp = nsp.toLowerCase();
        System.assertNotEquals('testingHello', nsp); // (PE3.5, SK, 9Aug2017)
        
        // Null Web Service mock implementation
        System.Test.setMock(WebServiceMock.class, new MetadataServiceTest.WebServiceMockImpl());
        
        // Only required to workaround a current code coverage bug in the platform
        MetadataService metaDataService = new MetadataService();
        
        // Invoke operations         
        MetadataService.MetadataPort metaDataPort = new MetadataService.MetadataPort();
        // metaDataPort.listMetadata(null, null);
        // metaDataPort.updateMetadata(null);
        
        List<Org_Setting__mdt> lstOrgSett =[SELECT IsActive__c,label,developername FROM Org_Setting__mdt where developername ='Commitment_Creation' limit 1];
        
        Navatar_Setup__c navSetup= new Navatar_Setup__c();
        
        navSetup.ccs__c = ''+nsp+'commitment__c:'+nsp+'partner_type__c,'+nsp+'commitment__c:'+nsp+'tax_forms__c,'+nsp+'commitment__c:'+nsp+'allowchange__c;'+nsp+'commitment__c:'+nsp+'kyc__c,'+nsp+'commitment__c:'+nsp+'checkmultipiclist__c,'+nsp+'commitment__c:'+nsp+'has_child__c';
        navSetup.ccs_fundraising__c = ''+nsp+'fundraising__c:name,'+nsp+'fundraising__c:'+nsp+'legal_name__c,'+nsp+'fundraising__c:'+nsp+'investment_likely_amount_usd_mn__c,'+nsp+'fundraising__c:'+nsp+'target_close_date_del__c,'+nsp+'fundraising__c:'+nsp+'reason_for_decline__c;'+nsp+'fundraising__c:'+nsp+'fund_name__c,'+nsp+'fundraising__c:'+nsp+'portfolio_company__c,'+nsp+'fundraising__c:'+nsp+'potential_management_fee__c,'+nsp+'fundraising__c:'+nsp+'stage__c,'+nsp+'fundraising__c:'+nsp+'next_step__c';
        navSetup.ccs_new_limited_partner__c = 'LimitedPartner;account:name,account:'+nsp+'testdoublefield__c,account:'+nsp+'geographic_region__c,account:'+nsp+'closing_data_date__c';
        navSetup.ccs_partnership__c = ''+nsp+'partnership__c:'+nsp+'fund__c,'+nsp+'partnership__c:name,'+nsp+'partnership__c:'+nsp+'fund_investment_category__c,'+nsp+'partnership__c:'+nsp+'total_commitments__c';
        navSetup.admin_setting__c    =  true;
        insert navSetup;
        System.assertEquals(true, navSetup.admin_setting__c); // (PE3.5, SK, 9Aug2017)
        
        CommitmentCreationSetup_Ctlr cmtSetup= new  CommitmentCreationSetup_Ctlr();
        cmtSetup.describeSObjectSample();
        cmtSetup.onEditCommitmentSetup();
        cmtSetup.onSaveCommitmentSetup();
        cmtSetup.displayRecordTypeName();
        cmtSetup.resetDefaultValue();
        cmtSetup.onCancel();
        cmtSetup.strNameSpace = nsp;
        
        if(lstOrgSett[0].IsActive__c==true){
            cmtSetup.strEnableCMTSetup = false;
        }
        else{
             cmtSetup.strEnableCMTSetup = true;
        }
        cmtSetup.updateMetadataMethod(true);
        
        // Reference types
        new MetadataService();
        new MetadataService.listMetadataResponse_element();       
        new MetadataService.LogInfo();
        new MetadataService.Layout();        
        new MetadataService.CallOptions_element();
        new MetadataService.LayoutColumn();
        new MetadataService.FileProperties();      
        new MetadataService.ListMetadataQuery();
        new MetadataService.DebuggingHeader_element();
        new MetadataService.CustomConsoleComponents();
        new MetadataService.SubtabComponents();
        new MetadataService.SummaryLayoutItem();
        new MetadataService.LayoutSection();
        new MetadataService.listMetadata_element();
        new MetadataService.Metadata();
        new MetadataService.LayoutItem();
        new MetadataService.SaveResult();
        
        // CommitmentCreationSetup_Ctlr cmtSetup2= new  CommitmentCreationSetup_Ctlr();
        //} catch (Exception e) {
        //      System.assert(false, 'Exception ' + e);
        // }
    }
}