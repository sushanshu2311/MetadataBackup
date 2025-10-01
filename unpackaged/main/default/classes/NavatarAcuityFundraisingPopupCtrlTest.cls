@isTest
public class NavatarAcuityFundraisingPopupCtrlTest {
    
@testSetup 
    static void setup(){
        Id devRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Company').getRecordTypeId();
        //Test class coverage fix by LK on 2024-11-06
        Id iiRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Individual Investor').getRecordTypeId();
        Account acc = new Account();
        acc.RecordTypeId = iiRecordTypeId;
        acc.Name = 'Test Class';
        insert acc;
       
        Account acc1 = new Account();
        acc1.RecordTypeId = iiRecordTypeId;
        acc1.Name = 'Test Class';
        insert acc1;
        
        Contact con = new Contact();
        con.LastName = 'Test Navatar';
        con.AccountId = acc.Id;
        insert con;
        
        navpeII_dev18__Fund__c fund = new navpeII_dev18__Fund__c();
        fund.navpeII_dev18__Investment_Category__c = 'Fund';
        fund.Name = 'TestFund';
        fund.navpeII_dev18__Fund_Type__c = 'Fund';
        insert fund;
        
        navpeII_dev18__Fundraising__c fundRaising = new navpeII_dev18__Fundraising__c();
        fundRaising.Name = 'Test FundRaising';
        fundRaising.navpeII_dev18__Legal_Name__c = acc1.Id;
        fundRaising.navpeII_dev18__Fund_Name__c = fund.Id;
        fundRaising.navpeII_dev18__Stage__c = 'Prospect';
        fundRaising.navpeII_dev18__Closing__c = '1st closing';
        fundRaising.navpeII_dev18__Investment_Likely_Amount_USD_mn__c = 200;
        fundRaising.navpeII_dev18__Closing_Date__c = system.today();
        insert fundRaising;
}
    
    @isTest
    public static void getFundDataTest(){
        NavatarAcuityFundraisingPopupCtrl.referenceWrapper fundWrap = new NavatarAcuityFundraisingPopupCtrl.referenceWrapper();
         List<navpeII_dev18__Fund__c> funds = [select Id,Name,navpeII_dev18__Investment_Category__c from navpeII_dev18__Fund__c limit 1];
         fundWrap = NavatarAcuityFundraisingPopupCtrl.getFundData(funds[0].Id);
         system.assert(fundWrap.labels != null);
    }
    
    @isTest
    public static void getFirmTest(){
       List<Account> acc = [select id,Name from Account limit 1];  
       NavatarAcuityFundraisingPopupCtrl.fundWrapper wrapFund = new NavatarAcuityFundraisingPopupCtrl.fundWrapper();
       wrapFund = NavatarAcuityFundraisingPopupCtrl.getFirm(acc[0].Id);
       //String recordTypeName = NavatarAcuityFundraisingPopupCtrl.getRecordTypeName(acc[0].Id);
       system.assert(wrapFund.firm != null); 
    }
    
    @isTest
    public static void createFundRecordTest(){
       List<navpeII_dev18__Fund__c> funds = [Select Id,Name from navpeII_dev18__Fund__c limit 1]; 
      String fundId =  NavatarAcuityFundraisingPopupCtrl.createFundRecord(funds[0].Name,'Co-investment');
      system.assert(fundId != '');  
    }
    
    @isTest
    public static void createRecordCompanyTest(){
     List<Account> company = [select id,Name from Account limit 1];
     String companyId = NavatarAcuityFundraisingPopupCtrl.createRecordCompany(company[0].Name);  
     system.assert(companyId != '');   
    }
    
    @isTest
    public static void createLegalRecordTest(){
     List<Account> legalAcc = [select id,Name from Account limit 1];
     String legalId = NavatarAcuityFundraisingPopupCtrl.createLegalRecord(legalAcc[0].Name);  
     system.assert(legalId != ''); 
    }
    
    @isTest
    public static void createFundRaisingTest(){
        List<navpeII_dev18__Fund__c> funds = [Select Id,Name,navpeII_dev18__Investment_Category__c from navpeII_dev18__Fund__c limit 1]; 
        navpeII_dev18__Fundraising__c fundraising = [Select Id,Name,navpeII_dev18__Stage__c,navpeII_dev18__Closing__c,
                                                     navpeII_dev18__Investment_Likely_Amount_USD_mn__c,
                                                     navpeII_dev18__Closing_Date__c from navpeII_dev18__Fundraising__c];
        String record = JSON.serialize(fundraising);
        List<Account> legalAcc = [select id,Name from Account limit 1];
        String fundraisingName = funds[0].Name + legalAcc[0].Name;
        sObject sObj = NavatarAcuityFundraisingPopupCtrl.createFundRaising(record,fundraisingName,funds[0].Id,legalAcc[0].Id,'testfundname','','','');
        List<sObject> fundData = NavatarAcuityFundraisingPopupCtrl.getFundRecordDetails(funds[0].Id);
        system.assert(funds[0].navpeII_dev18__Investment_Category__c == 'Fund');
    }
    
 
    

}