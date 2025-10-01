@isTest
public class Test_Deal_Creation_Ctlr{
    static String sCompanyApi =  CommonUtility.chkmasterLookupInPiplineAPI();

    public static testMethod void Test_DealCreation() {
        
    try {
            System.currentPageReference().getParameters().put('retURL', 'lightning/page/home');
            string np = CommonUtility.strNameSpacePrefix; 
            String strRecordTypeId = [Select Id ,developername From RecordType Where SobjectType = 'Account' and developername = 'Company'].Id;
             
            Navatar_Setup__c navSetup= new Navatar_Setup__c();            
            navSetup.admin_setting__c    =  true;
            navSetup.dcs__c = 'account:accountsource,account:'+np+'aum_in_millions__c,'+np+'pipeline__c:'+np+'source_name__c,account:'+np+'bank_account_number__c;account:'+np+'date_created__c,'+np+'pipeline__c:'+np+'ebit__c,Contact:LastName';
            navSetup.dcs_new_company__c = ''+strRecordTypeId+'';
            navSetup.dcs_new_source_contact__c = 'contact:'+np+'candidate_role__c,contact:'+np+'testdatefield__c,contact:'+np+'fees__c';
            insert navSetup;
                        
            String recdTypeId = [Select id From RecordType Where SobjectType = 'Account' And Name = 'Limited Partner'].Id;
        
            Account parentAccount = new Account();
            parentAccount.Name = 'SunMicro Group';
            insert parentAccount;
            
            Account acc = new Account();
            acc.Name = 'AIS Group';
            //acc.RecordTypeId = recdTypeId;
            acc.ParentId = parentAccount.id;
            insert acc; 
            
            Pipeline__c objPipeline = new Pipeline__c();
            objPipeline.name = 'PipeLine';           
            objPipeline.put(sCompanyApi, acc.id);
            objPipeline.Stage__c = 'LOI';
            objPipeline.Source__c = 'Bank';            
            insert objPipeline;
            
            Deal_Creation_Ctlr dclSetup= new  Deal_Creation_Ctlr();
            Deal_Creation_Ctlr.objectfield objWarp = new Deal_Creation_Ctlr.objectfield();
            dclSetup.openSourceFirmPopup();
           // dclSetup.showMessage();
            dclSetup.openSourceContactPopup();
            dclSetup.strRequiredField = 'Account:Name,Pipeline__c:Name,Pipeline__c:'+ sCompanyApi +',Pipeline__c:Stage__c';
            dclSetup.strSourcePopupReqField = 'Account:Name,Account:Familiar_Name__c,Contact:LastName';
            dclSetup.viewRequiredFieldonPage();
            dclSetup.onCancel();        
            Deal_Creation_Ctlr.getRecorTypeid();
            dclSetup.CreateDeal();
            System.assertEquals('PipeLine',objPipeline.Name);
        } catch (Exception e) {
            //System.assert(false, 'Exception ' + e);
        }
    }    
    
    public static testMethod void Test_DealCreation2() {
        
    try {
            System.currentPageReference().getParameters().put('retURL', 'lightning/page/home');
            string np = CommonUtility.strNameSpacePrefix; 
            String strRecordTypeId = [Select Id ,developername From RecordType Where SobjectType = 'Account' and developername = 'Company'].Id;
             
            Navatar_Setup__c navSetup= new Navatar_Setup__c();
            
            navSetup.admin_setting__c    =  true;           
            navSetup.dcs_new_source_contact__c = 'Source Contact: Source Contact2: Source Contact3';
            navSetup.dcs_new_source_firm__c = '1234;account:accountsource,account:'+np+'locations__c,account:'+np+'bank_account_number__c';
            navSetup.dcs_new_company__c = '12312';
            navSetup.dcs__c = 'account:accountsource,'+np+'pipeline__c:'+np+'source_name__c,account:'+np+'aum_in_millions__c,account:'+np+'bank_account_number__c;account:'+np+'date_created__c,'+np+'pipeline__c:'+np+'ebit__c,Contact:LastName';
           
            navSetup.dcs_new_company__c = ''+strRecordTypeId+'';
            navSetup.dcs_new_source_contact__c = 'contact:'+np+'candidate_role__c,contact:'+np+'testdatefield__c,contact:'+np+'fees__c';
            insert navSetup;
                        
            String recdTypeId = [Select id From RecordType Where SobjectType = 'Account' And Name = 'Limited Partner'].Id;
        
            Account acc = new Account();
            acc.name = 'SunMicro Group';
            acc.bank_account_number__c = 'test';            
            insert acc;
                        
            Pipeline__c objPipeline = new Pipeline__c();
            objPipeline.name = 'PipeLine';           
            objPipeline.put(sCompanyApi, acc.id);
            objPipeline.Stage__c = 'LOI';
            objPipeline.Source__c = 'Bank';            
            insert objPipeline;
            
            Contact cont= new Contact();
            cont.firstname = 'john';
            cont.lastname = 'smith';
            cont.accountid = acc.id;            
            insert cont;
            
            Deal_Creation_Ctlr dclSetup= new  Deal_Creation_Ctlr();
            Deal_Creation_Ctlr.objectfield objWarp = new Deal_Creation_Ctlr.objectfield();
            dclSetup.openSourceFirmPopup();
           // dclSetup.showMessage();
            dclSetup.objSourceAccount = acc;
            dclSetup.objSourceContact = cont;
            dclSetup.strSourceFirmName = 'test';
            dclSetup.strSourceContactName = 'test1';
            dclSetup.openSourceContactPopup();
            dclSetup.strRequiredField = 'Account:Name,Pipeline__c:Name,Pipeline__c:' + sCompanyApi + ',Pipeline__c:Stage__c';
            dclSetup.strSourcePopupReqField = 'Account:Name,Account:Familiar_Name__c,Contact:LastName';
            dclSetup.viewRequiredFieldonPage();
            dclSetup.onCancel();        
            Deal_Creation_Ctlr.getRecorTypeid();
            
            dclSetup.CreateDeal();
            System.assertEquals('PipeLine',objPipeline.Name);
        } catch (Exception e) {
           // System.assert(false, 'Exception ' + e);
        }
    }    
   
}