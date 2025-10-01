@isTest
public class Test_Deal_Creation_Setup_Ctlr{
    public static testMethod void Test_DealCreationSetup() {
        
    try {
            string np = CommonUtility.strNameSpacePrefix; 
            String strRecordTypeId = [Select Id ,developername From RecordType Where SobjectType = 'Account' and developername = 'Company'].Id;
            
            Navatar_Setup__c navSetup= new Navatar_Setup__c();           
            navSetup.admin_setting__c    =  true;
            navSetup.DCS_New_Source_Contact__c = 'Source Contact: Source Contact2: Source Contact3';
            navSetup.DCS_New_Source_Firm__c = '01236000000QfDmAAK;account:accountsource,account:'+np+'locations__c,account:'+np+'bank_account_number__c';
            navSetup.dcs_new_company__c = 'New Company';
            navSetup.DCS__c = 'account:accountsource,account:'+np+'aum_in_millions__c,account:'+np+'bank_account_number__c;account:'+np+'date_created__c,'+np+'pipeline__c:'+np+'ebit__c,Contact:LastName';
            navSetup.dcs__c = 'account:accountsource,account:'+np+'aum_in_millions__c,account:'+np+'bank_account_number__c;account:'+np+'date_created__c,'+np+'pipeline__c:'+np+'ebit__c,account:'+np+'test_date_time__c';
            
            navSetup.dcs_new_company__c = ''+strRecordTypeId+'';
            navSetup.dcs_new_source_firm__c = ''+strRecordTypeId+';account:parentid';
            navSetup.dcs_new_source_contact__c = 'contact:'+np+'candidate_role__c,contact:'+np+'testdatefield__c,contact:'+np+'fees__c';
            insert navSetup;
                        
            Deal_Creation_Setup_Ctlr dclSetup= new  Deal_Creation_Setup_Ctlr();
            dclSetup.getRecordType();
            dclSetup.strFieldApiName = 'account:accountnumber;account:accountsource<@>'+strRecordTypeId+';account:accountnumber<@>contact:description<@>'+strRecordTypeId+'';
            dclSetup.setRecordType();
            dclSetup.onclickSaveButton();
            dclSetup.onCancel();
            dclSetup.onRevertToDefault();
            dclSetup.fetchEditSectionValue();
            
        } catch (Exception e) {
            System.assert(false, 'Exception ' + e);
        }
    }
    
    public static testMethod void Test_DealCreationSetup2() {
        
    try {
            string np = CommonUtility.strNameSpacePrefix; 
            String strRecordTypeId = [Select Id ,developername From RecordType Where SobjectType = 'Account' and developername = 'Company'].Id;
            
            Navatar_Setup__c navSetup= new Navatar_Setup__c();           
            navSetup.admin_setting__c    =  true;
            navSetup.DCS_New_Source_Contact__c = 'Source Contact: Source Contact2: Source Contact3';
            navSetup.DCS_New_Source_Firm__c = ''+strRecordTypeId+';account:accountsource,account:'+np+'locations__c,account:'+np+'bank_account_number__c';
            navSetup.dcs_new_company__c = 'New Company';
            navSetup.dcs__c = 'account:accountsource,account:'+np+'aum_in_millions__c,account:'+np+'bank_account_number__c;account:'+np+'date_created__c,'+np+'pipeline__c:'+np+'ebit__c,account:'+np+'test_date_time__c';
            insert navSetup;
                        
            Deal_Creation_Setup_Ctlr dclSetup= new  Deal_Creation_Setup_Ctlr();
            dclSetup.getRecordType();
            dclSetup.strFieldApiName = 'account:accountnumber;account:accountsource<@>'+strRecordTypeId+';account:accountnumber<@>contact:description<@>'+strRecordTypeId+'';
            dclSetup.setRecordType();
            dclSetup.onclickSaveButton();
            dclSetup.onCancel();
            dclSetup.onRevertToDefault();
            dclSetup.fetchEditSectionValue();
            
        } catch (Exception e) {
            System.assert(false, 'Exception ' + e);
        }
    }
 
}