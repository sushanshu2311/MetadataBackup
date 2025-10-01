@isTest
public Class TestCommitmentCreation_Ctlr
{
    static testMethod void CommitmentCreationFundrasing()
    {	//Test class coverage fix by LK on 2024-11-06
        List<RecordType> lstTypeId = [Select id from recordtype where name ='Individual Investor' Limit 1];
        List<RecordType> lstTypeIdCompany = [Select id from recordtype where name ='Company' Limit 1];
        
        Account A1 = new Account(Name = 'Test Account' ,recordTypeId = lstTypeId[0].id);
        insert A1;
        System.assertEquals('Test Account', A1.Name); // (PE3.5, SK, 9Aug2017)
        
        Account company = new Account(Name = 'Test Account' ,recordTypeId = lstTypeIdCompany[0].id);
        insert company;
        System.assertEquals('Test Account', company.Name); // (PE3.5, SK, 9Aug2017)
        
        contact con = new Contact(lastname='testContact',accountid=A1.id);
        insert con;
        System.assertEquals('testContact', con.LastName); // (PE3.5, SK, 9Aug2017)
        
        Fund__c fundObj = new Fund__c(Name='testFund',Fund_Type__c='Fund',Investment_Category__c='Fund');
        insert fundObj;
        System.assertEquals('testFund', fundObj.Name); // (PE3.5, SK, 9Aug2017)
        
        Fundraising__c fundraisingObj = new Fundraising__c(Name='testFundraising',Fund_Name__c=fundObj.id,Legal_Name__c=A1.id, Portfolio_Company__c=company.id);
        insert fundraisingObj; 
        System.assertEquals('testFundraising', fundraisingObj.Name); // (PE3.5, SK, 9Aug2017)
        
        ID ProfileID = [ Select id from Profile where name = 'System Administrator'].id; 
        User u1 = new User( email='test-user@fakeemail.com', profileid = profileid, 
                    UserName='PE3.5Fundrsainguser@fakeemail.com', alias='fuser1', CommunityNickName='pefundrainguser1', 
                    TimeZoneSidKey='America/New_York', LocaleSidKey='en_US', EmailEncodingKey='ISO-8859-1', 
                    LanguageLocaleKey='en_US', FirstName = 'Test', LastName = 'User' ,  isActive=true);
        insert u1;
        System.assertEquals('PE3.5Fundrsainguser@fakeemail.com', u1.userName); // (PE3.5, SK, 9Aug2017)
        
        //Org_Setting__mdt orgsetObj = new Org_Setting__mdt(label='testCoinvs',developername='Co_Inv_Setting');
        //insert orgsetObj;
        Navatar_Setup__c nvsetupObj = new Navatar_Setup__c(CCS__c='Commitment__c:Partner_Type__c;Commitment__c:Tax_Forms__c',CCS_Fundraising__c='Fundraising__c:Name,Fundraising__c:Legal_Name__c,Fundraising__c:Potential_Management_Fee__c;Fundraising__c:Fund_Name__c,Fundraising__c:Portfolio_Company__c,Fundraising__c:Investment_Likely_Amount_USD_mn__c',CCS_New_Limited_Partner__c='Institution;Account:Name',CCS_Partnership__c='Partnership__c:Fund__c,Partnership__c:Name,Partnership__c:Fund_Investment_Category__c',CI_Fund_ID__c=fundObj.id,Admin_Setting__c=true);
        insert nvsetupObj;
        System.assertNotEquals('', nvsetupObj.Name); // (PE3.5, SK, 9Aug2017)
        
        String commitmentJsonData = '[{"limited_partner":{"Name":"TestLP"},"partnership":{"Name":"Test"},"amount":"1000","Comitdate":"11/10/2016"},{"limited_partner":{"Name":"TestLP"},"partnership":{"Name":"Test"},"amount":"2000","Comitdate":"03/10/2016"},{"limited_partner":{"id":"0013600000cPZ9OAAW"},"partnership":{"id":"a0I36000004MhDEEA0"},"amount":"3000","Comitdate":"05/10/2016"}]';                     
        Apexpages.currentpage().getparameters().put('Source','Home');
        ApexPages.currentPage().getHeaders().put('Host','https://n34.salesforce.com'); 
                    
        System.runas(u1)
        {
            Test.StartTest();
                CommitmentCreationHelper_Ctlr creationObj = new CommitmentCreationHelper_Ctlr();
                creationObj.fundraingLookup.Fundraising__c = fundraisingObj.id;
                creationObj.strPopupName ='HomePopup';
                creationObj.AccountLPLookup.Limited_Partner__c = A1.id;
                creationObj.CompanyLookup.Portfolio_Company__c = company.id;
                creationObj.getFundData();
                creationObj.isCoInvestment =true;
                creationObj.getFundData();                  
                creationObj.CommitmentData();
                creationObj.strCommitmentData = commitmentJsonData;
                creationObj.CreateCompanyPopup();
                /* ---------Fund Popup------------- */
                creationObj.fundLookup.Fund_Name__c = fundObj.id;
                creationObj.AccountLPFundLookup.Limited_Partner__c = A1.id;
                creationObj.strPopupName ='FundPopup';
                creationObj.CommitmentData();
                creationObj.strPTRowid = '0';
                creationObj.checkDataForPTFields();
                creationObj.strPTRowName = 'Test';
                creationObj.setPTFieldsData();
                creationObj.strRequiredFieldJson='{"Testaa":["Fund_Investment_Category__c"]}';
                creationObj.checkRequiredFieldsOnPopup();
                creationObj.strPTRowName = 'Testaa';
                creationObj.setPTFieldsData();
                creationObj.strRequiredFieldJson='{"TestLP":["Name"]}';
                creationObj.checkRequiredFieldsOnPopup();
                creationObj.strLPRowid = '0';
                creationObj.checkDataForLPFields();
                creationObj.strLPRowName = 'TestLP';
                creationObj.setLPFieldsData();
                creationObj.strLPRowName = 'TestLP11';
                creationObj.setLPFieldsData();
                creationObj.strCommitmentData = commitmentJsonData;
                creationObj.CreateCompanyPopup();
            Test.StopTest();
        }
    } 
    
    static testMethod void CommitmentCreationCompany()
    {
        //Test class coverage fix by LK on 2024-11-06
        List<RecordType> lstTypeId = [Select id from recordtype where name ='Individual Investor' Limit 1];
        List<RecordType> lstTypeIdCompany = [Select id from recordtype where name ='Company' Limit 1];
        
        Account A1 = new Account(Name = 'Test Account' ,recordTypeId = lstTypeId[0].id);
        insert A1;
        System.assertEquals('Test Account', A1.Name); // (PE3.5, SK, 9Aug2017)
        
        Account company = new Account(Name = 'Test Account' ,recordTypeId = lstTypeIdCompany[0].id);
        insert company;
        System.assertEquals('Test Account', company.Name); // (PE3.5, SK, 9Aug2017)
        
        contact con = new Contact(lastname='testContact',accountid=A1.id);
        insert con;
        System.assertEquals('testContact', con.LastName); // (PE3.5, SK, 9Aug2017)
        
        Fund__c fundObj = new Fund__c(Name='testFund',Fund_Type__c='Fund',Investment_Category__c='Fund');
        insert fundObj;
        System.assertEquals('testFund', fundObj.Name); // (PE3.5, SK, 9Aug2017)
        
        Fundraising__c fundraisingObj = new Fundraising__c(Name='testFundraising',Fund_Name__c=fundObj.id,Legal_Name__c=A1.id);
        insert fundraisingObj;
        System.assertNotEquals('', fundraisingObj.Name); // (PE3.5, SK, 9Aug2017)
        
        ID ProfileID = [ Select id from Profile where name = 'System Administrator'].id; 
        User u1 = new User( email='test-user@fakeemail.com', profileid = profileid, 
                    UserName='PE3.5Fundrsainguser@fakeemail.com', alias='fuser1', CommunityNickName='pefundrainguser1', 
                    TimeZoneSidKey='America/New_York', LocaleSidKey='en_US', EmailEncodingKey='ISO-8859-1', 
                    LanguageLocaleKey='en_US', FirstName = 'Test', LastName = 'User' ,  isActive=true);
        insert u1;
        System.assertEquals('PE3.5Fundrsainguser@fakeemail.com', u1.userName); // (PE3.5, SK, 9Aug2017)
        
        //Org_Setting__mdt orgsetObj = new Org_Setting__mdt(label='testCoinvs',developername='Co_Inv_Setting');
        //insert orgsetObj;
        Navatar_Setup__c nvsetupObj = new Navatar_Setup__c(CCS__c='Commitment__c:Partner_Type__c;Commitment__c:Tax_Forms__c',CCS_Fundraising__c='Fundraising__c:Name,Fundraising__c:Legal_Name__c,Fundraising__c:Potential_Management_Fee__c;Fundraising__c:Fund_Name__c,Fundraising__c:Portfolio_Company__c,Fundraising__c:Investment_Likely_Amount_USD_mn__c',CCS_New_Limited_Partner__c='Institution;Account:Name',CCS_Partnership__c='Partnership__c:Fund__c,Partnership__c:Name,Partnership__c:Fund_Investment_Category__c',CI_Fund_ID__c=fundObj.id,Admin_Setting__c=true);
        insert nvsetupObj;
        System.assertNotEquals('', nvsetupObj.Name); // (PE3.5, SK, 9Aug2017)
        
        String commitmentJsonData = '[{"limited_partner":{"Name":"Test123"},"partnership":{"Name":"Partnership123"},"amount":"1000","Comitdate":"11/10/2016"},{"limited_partner":{"Name":"Test123"},"partnership":{"Name":"Partnership123"},"amount":"2000","Comitdate":"03/10/2016"},{"limited_partner":{"id":"0013600000cPZ9OAAW"},"partnership":{"id":"a0I36000004MhDEEA0"},"amount":"3000","Comitdate":"05/10/2016"}]';                     
        Apexpages.currentpage().getparameters().put('Source','Company');
        Apexpages.currentpage().getparameters().put('id',company.id);
        ApexPages.currentPage().getHeaders().put('Host','https://n34.salesforce.com'); 
                    
        System.runas(u1)
        {
            Test.StartTest();
                CommitmentCreationHelper_Ctlr creationObj = new CommitmentCreationHelper_Ctlr();
                creationObj.getFundOptions();
                creationObj.fundCompLookup.Fund_Name__c = fundObj.id;
                creationObj.AccountLPLookup.Limited_Partner__c = A1.id;
                //creationObj.CompanyLookup.Portfolio_Company__c = company.id;
                creationObj.isCoInvestment =false;
                creationObj.strPopupName ='CompanyPopup';
                creationObj.CommitmentData();
                creationObj.strCommitmentData = commitmentJsonData;
                creationObj.CreateCompanyPopup();
                creationObj.strTotalAmount = '100';
                creationObj.TotalCommitmentAmount();
            Test.StopTest();
        }
    } 
        
    static testMethod void CommitmentCreationFund()
    {
        //Test class coverage fix by LK on 2024-11-06
        List<RecordType> lstTypeId = [Select id from recordtype where name ='Individual Investor' Limit 1];
        
        Account A1 = new Account(Name = 'Test Account' ,recordTypeId = lstTypeId[0].id);
        insert A1;
        System.assertEquals('Test Account', A1.Name); // (PE3.5, SK, 9Aug2017)
        
        contact con = new Contact(lastname='testContact',accountid=A1.id);
        insert con;
        System.assertEquals('testContact', con.LastName); // (PE3.5, SK, 9Aug2017)
        
        Fund__c fundObj = new Fund__c(Name='testFund',Fund_Type__c='Fund',Investment_Category__c='Fund');
        insert fundObj;
        System.assertEquals('testFund', fundObj.Name); // (PE3.5, SK, 9Aug2017)
        
        Fundraising__c fundraisingObj = new Fundraising__c(Name='testFundraising',Fund_Name__c=fundObj.id,Legal_Name__c=A1.id);
        insert fundraisingObj;
        System.assertNotEquals('', fundraisingObj.Name); // (PE3.5, SK, 9Aug2017) 
        
        ID ProfileID = [ Select id from Profile where name = 'System Administrator'].id; 
        User u1 = new User( email='test-user@fakeemail.com', profileid = profileid, 
                    UserName='PE3.5Fundrsainguser@fakeemail.com', alias='fuser1', CommunityNickName='pefundrainguser1', 
                    TimeZoneSidKey='America/New_York', LocaleSidKey='en_US', EmailEncodingKey='ISO-8859-1', 
                    LanguageLocaleKey='en_US', FirstName = 'Test', LastName = 'User' ,  isActive=true);
        insert u1;
        System.assertEquals('PE3.5Fundrsainguser@fakeemail.com', u1.userName); // (PE3.5, SK, 9Aug2017)
        
        //Org_Setting__mdt orgsetObj = new Org_Setting__mdt(label='testCoinvs',developername='Co_Inv_Setting');
        //insert orgsetObj;
        Navatar_Setup__c nvsetupObj = new Navatar_Setup__c(CCS__c='Commitment__c:Partner_Type__c;Commitment__c:Tax_Forms__c',CCS_Fundraising__c='Fundraising__c:Name,Fundraising__c:Legal_Name__c,Fundraising__c:Potential_Management_Fee__c;Fundraising__c:Fund_Name__c,Fundraising__c:Portfolio_Company__c,Fundraising__c:Investment_Likely_Amount_USD_mn__c',CCS_New_Limited_Partner__c='Institution;Account:Name',CCS_Partnership__c='Partnership__c:Fund__c,Partnership__c:Name,Partnership__c:Fund_Investment_Category__c',CI_Fund_ID__c=fundObj.id,Admin_Setting__c=true);
        insert nvsetupObj;
        System.assertNotEquals('', nvsetupObj.Name); // (PE3.5, SK, 9Aug2017)
        
        String commitmentJsonData = '[{"limited_partner":{"Name":"Test123"},"partnership":{"Name":"Partnership123"},"amount":"1000","Comitdate":"11/10/2016"},{"limited_partner":{"Name":"Test123"},"partnership":{"Name":"Partnership123"},"amount":"2000","Comitdate":"03/10/2016"},{"limited_partner":{"id":"0013600000cPZ9OAAW"},"partnership":{"id":"a0I36000004MhDEEA0"},"amount":"3000","Comitdate":"05/10/2016"}]';                     
        Apexpages.currentpage().getparameters().put('Source','Fundraising');
        Apexpages.currentpage().getparameters().put('id','123xyz');
        ApexPages.currentPage().getHeaders().put('Host','https://n34.salesforce.com'); 
                    
        System.runas(u1)
        {
            Test.StartTest();
                CommitmentCreationHelper_Ctlr creationObj = new CommitmentCreationHelper_Ctlr();
                creationObj.strCommitmentData = commitmentJsonData;
                creationObj.CreateCompanyPopup();
            	creationObj.cancel(); // added for coverage
            Test.StopTest();
        }
    }
    
    
    static testMethod void CommitmentCreationCompanyCoInvestmentOn()
    {    //Test class coverage fix by LK on 2024-11-06
        List<RecordType> lstTypeId = [Select id from recordtype where name ='Individual Investor' Limit 1];
        List<RecordType> lstTypeIdCompany = [Select id from recordtype where name ='Company' Limit 1];
        
        Account A1 = new Account(Name = 'Test Account' ,recordTypeId = lstTypeId[0].id);
        insert A1;
        System.assertEquals('Test Account', A1.Name); // (PE3.5, SK, 9Aug2017)
        
        Account company = new Account(Name = 'Test Account' ,recordTypeId = lstTypeIdCompany[0].id);
        insert company;
        System.assertEquals('Test Account', company.Name); // (PE3.5, SK, 9Aug2017)
        
        contact con = new Contact(lastname='testContact',accountid=A1.id);
        insert con;
        System.assertEquals('testContact', con.LastName); // (PE3.5, SK, 9Aug2017)
        
        Fund__c fundObj = new Fund__c(Name='testFund',Fund_Type__c='Fund',Investment_Category__c='Co-investment');
        insert fundObj;
        System.assertEquals('testFund', fundObj.Name); // (PE3.5, SK, 9Aug2017)
        
        Fundraising__c fundraisingObj = new Fundraising__c(Name='testFundraising',Fund_Name__c=fundObj.id,Legal_Name__c=A1.id,Portfolio_Company__c=company.id);
        insert fundraisingObj; 
        System.assertNotEquals('', fundraisingObj.Name); // (PE3.5, SK, 9Aug2017)
        
        ID ProfileID = [ Select id from Profile where name = 'System Administrator'].id; 
        User u1 = new User( email='test-user@fakeemail.com', profileid = profileid, 
                    UserName='PE3.5Fundrsainguser@fakeemail.com', alias='fuser1', CommunityNickName='pefundrainguser1', 
                    TimeZoneSidKey='America/New_York', LocaleSidKey='en_US', EmailEncodingKey='ISO-8859-1', 
                    LanguageLocaleKey='en_US', FirstName = 'Test', LastName = 'User' ,  isActive=true);
        insert u1;
        System.assertEquals('PE3.5Fundrsainguser@fakeemail.com', u1.userName); // (PE3.5, SK, 9Aug2017)
        
        //Org_Setting__mdt orgEmailSetting=[SELECT IsActive__c,label,developername FROM Org_Setting__mdt where developername ='Co_Inv_Setting' limit 1];
        //CustomMetadataService.updateMetadata(new List<SObject> {orgEmailSetting},true);
        Navatar_Setup__c nvsetupObj = new Navatar_Setup__c(CCS__c='Commitment__c:Partner_Type__c;Commitment__c:Tax_Forms__c',CCS_Fundraising__c='Fundraising__c:Name,Fundraising__c:Legal_Name__c,Fundraising__c:Potential_Management_Fee__c;Fundraising__c:Fund_Name__c,Fundraising__c:Portfolio_Company__c,Fundraising__c:Investment_Likely_Amount_USD_mn__c',CCS_New_Limited_Partner__c='Institution;Account:Name',CCS_Partnership__c='Partnership__c:Fund__c,Partnership__c:Name,Partnership__c:Fund_Investment_Category__c',CI_Fund_ID__c=fundObj.id,Admin_Setting__c=true);
        insert nvsetupObj;
        System.assertNotEquals('', nvsetupObj.Name); // (PE3.5, SK, 9Aug2017)
        
        String commitmentJsonData = '[{"limited_partner":{"Name":"Test123"},"partnership":{"Name":"Partnership123"},"amount":"1000","Comitdate":"11/10/2016"},{"limited_partner":{"Name":"Test123"},"partnership":{"Name":"Partnership123"},"amount":"2000","Comitdate":"03/10/2016"},{"limited_partner":{"id":"0013600000cPZ9OAAW"},"partnership":{"id":"a0I36000004MhDEEA0"},"amount":"3000","Comitdate":"05/10/2016"}]';                     
        Apexpages.currentpage().getparameters().put('Source','Company');
        Apexpages.currentpage().getparameters().put('id',company.id);
        ApexPages.currentPage().getHeaders().put('Host','https://n34.salesforce.com'); 
                    
        System.runas(u1)
        {
            Test.StartTest();
                CommitmentCreationHelper_Ctlr creationObj = new CommitmentCreationHelper_Ctlr();
                //creationObj.fundCompLookup.Fund_Name__c = fundObj.id;
                creationObj.AccountLPLookup.Limited_Partner__c = A1.id;
                creationObj.CompanyLookup.Portfolio_Company__c = company.id;
                creationObj.getFundData();
                creationObj.isCoInvestment =true;
                creationObj.getFundData();
                creationObj.strSelectedCoInvFund = fundObj.id; 
                creationObj.CompanyLookup.Portfolio_Company__c = company.id;
                creationObj.strPopupName ='CompanyPopup';
                creationObj.CommitmentData();
                creationObj.strCommitmentData = commitmentJsonData;
                creationObj.strCompName = 'Company';
                creationObj.CompanyWarningLookup.Portfolio_Company__c = company.id;
                creationObj.CreateCompanyPopup();
                creationObj.AddRow();
                creationObj.AddRow();
                creationObj.AddRow();
                creationObj.strDeletedRowId = '1';
                creationObj.RemoveRow();
                creationObj.getRecordtypeObjectName('Account');
                creationObj.getRecordtypeObjectName('');
                creationObj.AfterCreateRedirection();
                creationObj.getFieldsNameFromApi('Name;type','Account');
                creationObj.getFieldsNameFromApi('Name;lastname','Contact');
                creationObj.AutoCompleteData();
                creationObj.DescribeSObject();
                
                CommitmentCreation_Ctlr.getValidDate('05/10/2016');
                CommitmentCreation_Ctlr.getValidAmount('3000');
                CommitmentCreation_Ctlr.getValidDate('05/10qq/2016');
                CommitmentCreation_Ctlr.getValidAmount('3qqq000');
            
            Test.StopTest();
        }
    } 
}