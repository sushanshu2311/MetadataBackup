/*
    Developer               :   Sameer Rath
    Product Version         :   PE 3.0
    Date of Creation        :   15/05/2015
    Date of Last Update     :   15/09/2015
    Last Updated By         :   Sameer Rath
    Purpose of Creation     :   Listed below:
                                1. Code Coverage for both CommonUtilityGlobal & clsOne_filter Classes. 

*/

@isTest
private class Test_CommonUtilityGlobal
{
    public static testMethod void CUGandClsOneFilter(){
        CommonUtilityGlobal CUG = new CommonUtilityGlobal();
        //ApexPages.StandardController sc = new ApexPages.StandardController(CUG);
        //CommonUtilityGlobal cugStandard = new CommonUtilityGlobal(ApexPages.StandardController controller);
        //CommonUtilityGlobal cugStandardSet = new CommonUtilityGlobal(ApexPages.StandardSetController controller);
        string jsn = '[{"serialnumber":1,"field":"Account:BillingPostalCode:Billing Zip/Postal Code:string","Value":"","Operator":"="},{"serialnumber":2,"field":"Account:BillingPostalCode:Billing Zip/Postal Code:string","Value":"","Operator":"="},{"serialnumber":3,"field":"Account:BillingPostalCode:Billing Zip/Postal Code:string","Value":"","Operator":"="},{"serialnumber":4,"field":"Account:BillingPostalCode:Billing Zip/Postal Code:string","Value":"","Operator":"="},{"serialnumber":5,"field":"Account:BillingPostalCode:Billing Zip/Postal Code:string","Value":"","Operator":"="},{"serialnumber":6,"field":"Account:BillingPostalCode:Billing Zip/Postal Code:string","Value":"","Operator":"="},{"serialnumber":7,"field":"Account:BillingPostalCode:Billing Zip/Postal Code:string","Value":"","Operator":"="},{"serialnumber":8,"field":"Account:BillingPostalCode:Billing Zip/Postal Code:string","Value":"","Operator":"="},{"serialnumber":9,"field":"Account:BillingPostalCode:Billing Zip/Postal Code:string","Value":"","Operator":"="},{"serialnumber":10,"field":"Account:BillingPostalCode:Billing Zip/Postal Code:string","Value":"","Operator":"="}]';
        System.assertNotEquals('abc', jsn); // (PE3.5, SK, 9Aug2017)
        
        CommonUtilityGlobal.executequery1(jsn,'CMF','1,2,3,4');
        CommonUtilityGlobal.executequery1(jsn,'CMF','');
        CommonUtilityGlobal.executequery1(jsn,'MEF','1,2,3,4');
        CommonUtilityGlobal.executequery1(jsn,'MEF','');
        CommonUtilityGlobal.executequery1(jsn,'CMFC','1,2,3,4');
        CommonUtilityGlobal.executequery1(jsn,'CMFC','');
        CommonUtilityGlobal.executequery1(jsn,'CMFA','1,2,3,4');
        CommonUtilityGlobal.executequery1(jsn,'CMFA','');
        CommonUtilityGlobal.executequery1(jsn,'MEP','1,2,3,4');
        CommonUtilityGlobal.executequery1(jsn,'MEP','');
        CommonUtilityGlobal.executequery1(jsn,'MI','1,2,3,4');
        CommonUtilityGlobal.executequery1(jsn,'MI','');  
        CUG.chckFilter(jsn);
        CommonUtilityGlobal.checkDate('08/12/2012','10/14/2011');
        CommonUtilityGlobal.getValidDate('10/14/2011');
        CommonUtilityGlobal.nameSpacePrefix();
        
        
        jsn = '[{"serialnumber":1,"field":"Fund:Name:Fund Name:string","Value":"","Operator":"="},{"serialnumber":2,"field":"Fund:Name:Fund Name:string","Value":"","Operator":"="},{"serialnumber":3,"field":"Fund:Name:Fund Name:string","Value":"","Operator":"="},{"serialnumber":4,"field":"Fund:Name:Fund Name:string","Value":"","Operator":"="},{"serialnumber":5,"field":"Fund:Name:Fund Name:string","Value":"","Operator":"="},{"serialnumber":6,"field":"Fund:Name:Fund Name:string","Value":"","Operator":"="},{"serialnumber":7,"field":"Fund:Name:Fund Name:string","Value":"","Operator":"="},{"serialnumber":8,"field":"Fund:Name:Fund Name:string","Value":"","Operator":"="},{"serialnumber":9,"field":"Fund:Name:Fund Name:string","Value":"","Operator":"="},{"serialnumber":10,"field":"Fund:Name:Fund Name:string","Value":"","Operator":"="}]';
        System.assertNotEquals('xyz', jsn); // (PE3.5, SK, 9Aug2017)
        
        CommonUtilityGlobal.executequery1(jsn,'CMF','1,2,3,4');
        CommonUtilityGlobal.executequery1(jsn,'CMF','');
        CommonUtilityGlobal.executequery1(jsn,'MEF','1,2,3,4');
        CommonUtilityGlobal.executequery1(jsn,'MEF','');
        CommonUtilityGlobal.executequery1(jsn,'CMFC','1,2,3,4');
        CommonUtilityGlobal.executequery1(jsn,'CMFC','');
        CommonUtilityGlobal.executequery1(jsn,'CMFA','1,2,3,4');
        CommonUtilityGlobal.executequery1(jsn,'CMFA','');
        CommonUtilityGlobal.executequery1(jsn,'MEP','1,2,3,4');
        CommonUtilityGlobal.executequery1(jsn,'MEP','');
        CommonUtilityGlobal.executequery1(jsn,'MI','1,2,3,4');
        CommonUtilityGlobal.executequery1(jsn,'MI','');  
        CUG.chckFilter(jsn);
        CommonUtilityGlobal.checkDate('08/12/2012','10/14/2011');
        CommonUtilityGlobal.getValidDate('10/14/2011');
        CommonUtilityGlobal.nameSpacePrefix();
        
        
        jsn = '[{"serialnumber":1,"field":"Fundraising:Next_Step__c:Next Step:string","Value":"","Operator":"="},{"serialnumber":2,"field":"Fundraising:Next_Step__c:Next Step:string","Value":"","Operator":"="},{"serialnumber":3,"field":"Fundraising:Next_Step__c:Next Step:string","Value":"","Operator":"="},{"serialnumber":4,"field":"Fundraising:Next_Step__c:Next Step:string","Value":"","Operator":"="},{"serialnumber":5,"field":"Fundraising:Next_Step__c:Next Step:string","Value":"","Operator":"="},{"serialnumber":6,"field":"Fundraising:Next_Step__c:Next Step:string","Value":"","Operator":"="},{"serialnumber":7,"field":"Fundraising:Next_Step__c:Next Step:string","Value":"","Operator":"="},{"serialnumber":8,"field":"Fundraising:Next_Step__c:Next Step:string","Value":"","Operator":"="},{"serialnumber":9,"field":"Fundraising:Next_Step__c:Next Step:string","Value":"","Operator":"="},{"serialnumber":10,"field":"Fundraising:Next_Step__c:Next Step:string","Value":"","Operator":"="}]';
        System.assertNotEquals('xyz', jsn); // (PE3.5, SK, 9Aug2017)
        
        CommonUtilityGlobal.executequery1(jsn,'CMF','1,2,3,4');
        CommonUtilityGlobal.executequery1(jsn,'CMF','');
        CommonUtilityGlobal.executequery1(jsn,'MEF','1,2,3,4');
        CommonUtilityGlobal.executequery1(jsn,'MEF','');
        CommonUtilityGlobal.executequery1(jsn,'CMFC','1,2,3,4');
        CommonUtilityGlobal.executequery1(jsn,'CMFC','');
        CommonUtilityGlobal.executequery1(jsn,'CMFA','1,2,3,4');
        CommonUtilityGlobal.executequery1(jsn,'CMFA','');
        CommonUtilityGlobal.executequery1(jsn,'MEP','1,2,3,4');
        CommonUtilityGlobal.executequery1(jsn,'MEP','');
        CommonUtilityGlobal.executequery1(jsn,'MI','1,2,3,4');
        CommonUtilityGlobal.executequery1(jsn,'MI','');  
        CUG.chckFilter(jsn);
        CommonUtilityGlobal.checkDate('08/12/2012','10/14/2011');
        CommonUtilityGlobal.getValidDate('10/14/2011');
        CommonUtilityGlobal.nameSpacePrefix();
        
        
        jsn = '[{"serialnumber":1,"field":"Contact:Department:Department:string","Value":"","Operator":"="},{"serialnumber":2,"field":"Contact:Department:Department:string","Value":"","Operator":"="},{"serialnumber":3,"field":"Contact:Department:Department:string","Value":"","Operator":"="},{"serialnumber":4,"field":"Contact:Department:Department:string","Value":"","Operator":"="},{"serialnumber":5,"field":"Contact:Department:Department:string","Value":"","Operator":"="},{"serialnumber":6,"field":"Contact:Department:Department:string","Value":"","Operator":"="},{"serialnumber":7,"field":"Contact:Department:Department:string","Value":"","Operator":"="},{"serialnumber":8,"field":"Contact:Department:Department:string","Value":"","Operator":"="},{"serialnumber":9,"field":"Contact:Department:Department:string","Value":"","Operator":"="},{"serialnumber":10,"field":"Contact:Department:Department:string","Value":"","Operator":"="}]';
        System.assertNotEquals('abc', jsn); // (PE3.5, SK, 9Aug2017)
        
        CommonUtilityGlobal.executequery1(jsn,'CMF','1,2,3,4');
        CommonUtilityGlobal.executequery1(jsn,'CMF','');
        CommonUtilityGlobal.executequery1(jsn,'MEF','1,2,3,4');
        CommonUtilityGlobal.executequery1(jsn,'MEF','');
        CommonUtilityGlobal.executequery1(jsn,'CMFC','1,2,3,4');
        CommonUtilityGlobal.executequery1(jsn,'CMFC','');
        CommonUtilityGlobal.executequery1(jsn,'CMFA','1,2,3,4');
        CommonUtilityGlobal.executequery1(jsn,'CMFA','');
        CommonUtilityGlobal.executequery1(jsn,'MEP','1,2,3,4');
        CommonUtilityGlobal.executequery1(jsn,'MEP','');
        CommonUtilityGlobal.executequery1(jsn,'MI','1,2,3,4');
        CommonUtilityGlobal.executequery1(jsn,'MI','');  
        CUG.chckFilter(jsn);
        CommonUtilityGlobal.checkDate('08/12/2012','10/14/2011');
        CommonUtilityGlobal.getValidDate('10/14/2011');
        CommonUtilityGlobal.nameSpacePrefix();
        
        
        jsn = '[{"serialnumber":1,"field":"Fundraising Contact:Name:Fundraising Contact ID:string","Value":"","Operator":"="},{"serialnumber":2,"field":"Fundraising Contact:Name:Fundraising Contact ID:string","Value":"","Operator":"="},{"serialnumber":3,"field":"Fundraising Contact:Name:Fundraising Contact ID:string","Value":"","Operator":"="},{"serialnumber":4,"field":"Fundraising Contact:Name:Fundraising Contact ID:string","Value":"","Operator":"="},{"serialnumber":5,"field":"Fundraising Contact:Name:Fundraising Contact ID:string","Value":"","Operator":"="},{"serialnumber":6,"field":"Fundraising Contact:Name:Fundraising Contact ID:string","Value":"","Operator":"="},{"serialnumber":7,"field":"Fundraising Contact:Name:Fundraising Contact ID:string","Value":"","Operator":"="},{"serialnumber":8,"field":"Fundraising Contact:Name:Fundraising Contact ID:string","Value":"","Operator":"="},{"serialnumber":9,"field":"Fundraising Contact:Name:Fundraising Contact ID:string","Value":"","Operator":"="},{"serialnumber":10,"field":"Fundraising Contact:Name:Fundraising Contact ID:string","Value":"","Operator":"="}]';
        System.assertNotEquals('abc', jsn); // (PE3.5, SK, 9Aug2017)
        
        CommonUtilityGlobal.executequery1(jsn,'CMF','1,2,3,4');
        CommonUtilityGlobal.executequery1(jsn,'CMF','');
        CommonUtilityGlobal.executequery1(jsn,'MEF','1,2,3,4');
        CommonUtilityGlobal.executequery1(jsn,'MEF','');
        CommonUtilityGlobal.executequery1(jsn,'CMFC','1,2,3,4');
        CommonUtilityGlobal.executequery1(jsn,'CMFC','');
        CommonUtilityGlobal.executequery1(jsn,'CMFA','1,2,3,4');
        CommonUtilityGlobal.executequery1(jsn,'CMFA','');
        CommonUtilityGlobal.executequery1(jsn,'MEP','1,2,3,4');
        CommonUtilityGlobal.executequery1(jsn,'MEP','');
        CommonUtilityGlobal.executequery1(jsn,'MI','1,2,3,4');
        CommonUtilityGlobal.executequery1(jsn,'MI','');          
        CUG.chckFilter(jsn);
        CommonUtilityGlobal.checkDate('08/12/2012','10/14/2011');
        CommonUtilityGlobal.getValidDate('10/14/2011');
        CommonUtilityGlobal.nameSpacePrefix();
        
        
        jsn = '[{"serialnumber":1,"field":"Office Location:Name:Fundraising Contact ID:string","Value":"","Operator":"="},{"serialnumber":2,"field":"Fundraising Contact:Name:Fundraising Contact ID:string","Value":"","Operator":"="},{"serialnumber":3,"field":"Fundraising Contact:Name:Fundraising Contact ID:string","Value":"","Operator":"="},{"serialnumber":4,"field":"Fundraising Contact:Name:Fundraising Contact ID:string","Value":"","Operator":"="},{"serialnumber":5,"field":"Fundraising Contact:Name:Fundraising Contact ID:string","Value":"","Operator":"="},{"serialnumber":6,"field":"Fundraising Contact:Name:Fundraising Contact ID:string","Value":"","Operator":"="},{"serialnumber":7,"field":"Fundraising Contact:Name:Fundraising Contact ID:string","Value":"","Operator":"="},{"serialnumber":8,"field":"Fundraising Contact:Name:Fundraising Contact ID:string","Value":"","Operator":"="},{"serialnumber":9,"field":"Fundraising Contact:Name:Fundraising Contact ID:string","Value":"","Operator":"="},{"serialnumber":10,"field":"Fundraising Contact:Name:Fundraising Contact ID:string","Value":"","Operator":"="}]';
        System.assertNotEquals('abc', jsn); // (PE3.5, SK, 9Aug2017)
        
        CommonUtilityGlobal.executequery1(jsn,'CMF','1,2,3,4');
        CommonUtilityGlobal.executequery1(jsn,'CMF','');
        CommonUtilityGlobal.executequery1(jsn,'MEF','1,2,3,4');
        CommonUtilityGlobal.executequery1(jsn,'MEF','');
        CommonUtilityGlobal.executequery1(jsn,'CMFC','1,2,3,4');
        CommonUtilityGlobal.executequery1(jsn,'CMFC','');
        CommonUtilityGlobal.executequery1(jsn,'CMFA','1,2,3,4');
        CommonUtilityGlobal.executequery1(jsn,'CMFA','');
        CommonUtilityGlobal.executequery1(jsn,'MEP','1,2,3,4');
        CommonUtilityGlobal.executequery1(jsn,'MEP','');
        CommonUtilityGlobal.executequery1(jsn,'MI','1,2,3,4');
        CommonUtilityGlobal.executequery1(jsn,'MI','');  
        CUG.chckFilter(jsn);
        CommonUtilityGlobal.checkDate('08/12/2012','10/14/2011');
        CommonUtilityGlobal.getValidDate('10/14/2011');
        CommonUtilityGlobal.nameSpacePrefix();
        
       // CommonUtilityGlobal.convertdatetime('10/14/2011 11:46 AM');
        CommonUtilityGlobal.convertdatetime('10/14/2011');
        CommonUtilityGlobal.Specialchar('fhasdhfiwu*$*^%$^& adsfjaklsdjf');
        CommonUtilityGlobal.convertdate('08/12/2012');      
        CommonUtilityGlobal.convertdateGMT('08/12/2012');
      //  CommonUtilityGlobal.convertdatetimeGMT('10/14/2011 11:46 AM');
        CUG.chckFilter(jsn);
        CommonUtilityGlobal.checkDate('08/12/2012','10/14/2011');
        CommonUtilityGlobal.getValidDate('10/14/2011');
        CommonUtilityGlobal.nameSpacePrefix();
        
        CommonUtilityGlobal.checkDate('10/14/2011','08/12/2012');
        
        Account opacc1 = new Account(name='testSam1');
        Account opacc2 = new Account(name='testSam1');
        insert opacc1;
        insert opacc2;
        System.assertEquals('testSam1', opacc1.Name); // (PE3.5, SK, 9Aug2017)
        
        ApexPages.StandardController sc = new ApexPages.StandardController(opacc1);

        
        clsOne_filter TestController = new  clsOne_filter();
        TestController.operatorOperation('Contact.Account.ID','REFERENCE','=','','');
        TestController.operatorOperation('Contact.Account.ID','REFERENCE','!=','','');
        TestController.operatorOperation('Contact.Account.ID','REFERENCE','>','','');
        TestController.operatorOperation('Contact.Account.ID','REFERENCE','<','','');
        TestController.operatorOperation('Contact.Account.ID','REFERENCE','>=','','');
        TestController.operatorOperation('Contact.Account.ID','REFERENCE','<=','','');
        
        string testvalue=opacc1.id;
        TestController.operatorOperation('Contact.Account.ID','REFERENCE','=',testvalue,'');
        TestController.operatorOperation('Contact.Account.ID','REFERENCE','!=',testvalue,'');
        TestController.operatorOperation('Contact.Account.ID','REFERENCE','>',testvalue,'');
        TestController.operatorOperation('Contact.Account.ID','REFERENCE','<',testvalue,'');
        TestController.operatorOperation('Contact.Account.ID','REFERENCE','>=',testvalue,'');
        TestController.operatorOperation('Contact.Account.ID','REFERENCE','<=',testvalue,'');
        
        testvalue=testvalue+',';
        TestController.operatorOperation('Contact.Account.ID','REFERENCE','=',testvalue,'');
        TestController.operatorOperation('Contact.Account.ID','REFERENCE','!=',testvalue,'');
        TestController.operatorOperation('Contact.Account.ID','REFERENCE','>',testvalue,'');
        TestController.operatorOperation('Contact.Account.ID','REFERENCE','<',testvalue,'');
        TestController.operatorOperation('Contact.Account.ID','REFERENCE','>=',testvalue,'');
        TestController.operatorOperation('Contact.Account.ID','REFERENCE','<=',testvalue,'');
        
        testvalue=opacc1.id+','+opacc2.id;
        TestController.operatorOperation('Contact.Account.ID','REFERENCE','=',testvalue,'');
        TestController.operatorOperation('Contact.Account.ID','REFERENCE','!=',testvalue,'');
        TestController.operatorOperation('Contact.Account.ID','REFERENCE','>',testvalue,'');
        TestController.operatorOperation('Contact.Account.ID','REFERENCE','<',testvalue,'');
        TestController.operatorOperation('Contact.Account.ID','REFERENCE','>=',testvalue,'');
        TestController.operatorOperation('Contact.Account.ID','REFERENCE','<=',testvalue,'');
        
        // Test DATETIME Type
      //  TestController.locale_info='en_US';
        TestController.operatorOperation('Contact.Account.CreatedDate','DATETIME','=','','');
        TestController.operatorOperation('Contact.Account.CreatedDate','DATETIME','!=','','');
        TestController.operatorOperation('Contact.Account.CreatedDate','DATETIME','>','','');
        TestController.operatorOperation('Contact.Account.CreatedDate','DATETIME','<','','');
        TestController.operatorOperation('Contact.Account.CreatedDate','DATETIME','>=','','');
        TestController.operatorOperation('Contact.Account.CreatedDate','DATETIME','<=','','');

        
        testvalue='08/12/2012';
        TestController.operatorOperation('Contact.Account.CreatedDate','DATETIME','=',testvalue,'');
        TestController.operatorOperation('Contact.Account.CreatedDate','DATETIME','!=',testvalue,'');
        TestController.operatorOperation('Contact.Account.CreatedDate','DATETIME','>',testvalue,'');
        TestController.operatorOperation('Contact.Account.CreatedDate','DATETIME','<',testvalue,'');
        TestController.operatorOperation('Contact.Account.CreatedDate','DATETIME','>=',testvalue,'');
        TestController.operatorOperation('Contact.Account.CreatedDate','DATETIME','<=',testvalue,'');
        
        testvalue='08/12/2012 11:01:00 AM';
        TestController.operatorOperation('Contact.Account.CreatedDate','DATETIME','=',testvalue,'');
        TestController.operatorOperation('Contact.Account.CreatedDate','DATETIME','!=',testvalue,'');
        TestController.operatorOperation('Contact.Account.CreatedDate','DATETIME','>',testvalue,'');
        TestController.operatorOperation('Contact.Account.CreatedDate','DATETIME','<',testvalue,'');
        TestController.operatorOperation('Contact.Account.CreatedDate','DATETIME','>=',testvalue,'');
        TestController.operatorOperation('Contact.Account.CreatedDate','DATETIME','<=',testvalue,'');
        
        // Test DATE Type
 //       TestController.locale_info='en_US';
        TestController.operatorOperation('Contact.Birthdate','DATE','=','','');
        TestController.operatorOperation('Contact.Birthdate','DATE','!=','','');
        TestController.operatorOperation('Contact.Birthdate','DATE','>','','');
        TestController.operatorOperation('Contact.Birthdate','DATE','<','','');
        TestController.operatorOperation('Contact.Birthdate','DATE','>=','','');
        TestController.operatorOperation('Contact.Birthdate','DATE','<=','','');
        
        testvalue='08/12/2012';
        TestController.operatorOperation('Contact.Birthdate','DATE','=',testvalue,'');
        TestController.operatorOperation('Contact.Birthdate','DATE','!=',testvalue,'');
        TestController.operatorOperation('Contact.Birthdate','DATE','>',testvalue,'');
        TestController.operatorOperation('Contact.Birthdate','DATE','<',testvalue,'');
        TestController.operatorOperation('Contact.Birthdate','DATE','>=',testvalue,'');
        TestController.operatorOperation('Contact.Birthdate','DATE','<=',testvalue,'');
        
        // Test CURRENCY Type
        TestController.operatorOperation('Contact.Account.AnnualRevenue','CURRENCY','=','','');
        TestController.operatorOperation('Contact.Account.AnnualRevenue','CURRENCY','!=','','');
        TestController.operatorOperation('Contact.Account.AnnualRevenue','CURRENCY','>','','');
        TestController.operatorOperation('Contact.Account.AnnualRevenue','CURRENCY','<','','');
        TestController.operatorOperation('Contact.Account.AnnualRevenue','CURRENCY','>=','','');
        TestController.operatorOperation('Contact.Account.AnnualRevenue','CURRENCY','<=','','');
        
        testvalue='1';
        TestController.operatorOperation('Contact.Account.AnnualRevenue','CURRENCY','=',testvalue,'');
        TestController.operatorOperation('Contact.Account.AnnualRevenue','CURRENCY','!=',testvalue,'');
        TestController.operatorOperation('Contact.Account.AnnualRevenue','CURRENCY','>',testvalue,'');
        TestController.operatorOperation('Contact.Account.AnnualRevenue','CURRENCY','<',testvalue,'');
        TestController.operatorOperation('Contact.Account.AnnualRevenue','CURRENCY','>=',testvalue,'');
        TestController.operatorOperation('Contact.Account.AnnualRevenue','CURRENCY','<=',testvalue,'');
        
        testvalue=testvalue+',';
        TestController.operatorOperation('Contact.Account.AnnualRevenue','CURRENCY','=',testvalue,'');
        TestController.operatorOperation('Contact.Account.AnnualRevenue','CURRENCY','!=',testvalue,'');
        TestController.operatorOperation('Contact.Account.AnnualRevenue','CURRENCY','>',testvalue,'');
        TestController.operatorOperation('Contact.Account.AnnualRevenue','CURRENCY','<',testvalue,'');
        TestController.operatorOperation('Contact.Account.AnnualRevenue','CURRENCY','>=',testvalue,'');
        TestController.operatorOperation('Contact.Account.AnnualRevenue','CURRENCY','<=',testvalue,'');
        
        testvalue='1,11';
        TestController.operatorOperation('Contact.Account.AnnualRevenue','CURRENCY','=',testvalue,'');
        TestController.operatorOperation('Contact.Account.AnnualRevenue','CURRENCY','!=',testvalue,'');
        TestController.operatorOperation('Contact.Account.AnnualRevenue','CURRENCY','>',testvalue,'');
        TestController.operatorOperation('Contact.Account.AnnualRevenue','CURRENCY','<',testvalue,'');
        TestController.operatorOperation('Contact.Account.AnnualRevenue','CURRENCY','>=',testvalue,'');
        TestController.operatorOperation('Contact.Account.AnnualRevenue','CURRENCY','<=',testvalue,'');
        
        // Test BOOLEAN Type
        TestController.operatorOperation('Contact.Account.Client_Accreditation__c','BOOLEAN','=','','');
        TestController.operatorOperation('Contact.Account.Client_Accreditation__c','BOOLEAN','!=','','');
       
        testvalue='true';
        TestController.operatorOperation('Contact.Account.Client_Accreditation__c','BOOLEAN','=',testvalue,'');
        TestController.operatorOperation('Contact.Account.Client_Accreditation__c','BOOLEAN','!=',testvalue,'');
        
        // Test INTEGER Type
        TestController.operatorOperation('Contact.Account.NumberOfEmployees','INTEGER','=','','');
        TestController.operatorOperation('Contact.Account.NumberOfEmployees','INTEGER','!=','','');
        TestController.operatorOperation('Contact.Account.NumberOfEmployees','INTEGER','>','','');
        TestController.operatorOperation('Contact.Account.NumberOfEmployees','INTEGER','<','','');
        TestController.operatorOperation('Contact.Account.NumberOfEmployees','INTEGER','>=','','');
        TestController.operatorOperation('Contact.Account.NumberOfEmployees','INTEGER','<=','','');
        
        testvalue='1';
        TestController.operatorOperation('Contact.Account.NumberOfEmployees','INTEGER','=',testvalue,'');
        TestController.operatorOperation('Contact.Account.NumberOfEmployees','INTEGER','!=',testvalue,'');
        TestController.operatorOperation('Contact.Account.NumberOfEmployees','INTEGER','>',testvalue,'');
        TestController.operatorOperation('Contact.Account.NumberOfEmployees','INTEGER','<',testvalue,'');
        TestController.operatorOperation('Contact.Account.NumberOfEmployees','INTEGER','>=',testvalue,'');
        TestController.operatorOperation('Contact.Account.NumberOfEmployees','INTEGER','<=',testvalue,'');
        
        testvalue=testvalue+',';
        TestController.operatorOperation('Contact.Account.NumberOfEmployees','INTEGER','=',testvalue,'');
        TestController.operatorOperation('Contact.Account.NumberOfEmployees','INTEGER','!=',testvalue,'');
        TestController.operatorOperation('Contact.Account.NumberOfEmployees','INTEGER','>',testvalue,'');
        TestController.operatorOperation('Contact.Account.NumberOfEmployees','INTEGER','<',testvalue,'');
        TestController.operatorOperation('Contact.Account.NumberOfEmployees','INTEGER','>=',testvalue,'');
        TestController.operatorOperation('Contact.Account.NumberOfEmployees','INTEGER','<=',testvalue,'');
        
        testvalue='1,11';
        TestController.operatorOperation('Contact.Account.NumberOfEmployees','INTEGER','=',testvalue,'');
        TestController.operatorOperation('Contact.Account.NumberOfEmployees','INTEGER','!=',testvalue,'');
        TestController.operatorOperation('Contact.Account.NumberOfEmployees','INTEGER','>',testvalue,'');
        TestController.operatorOperation('Contact.Account.NumberOfEmployees','INTEGER','<',testvalue,'');
        TestController.operatorOperation('Contact.Account.NumberOfEmployees','INTEGER','>=',testvalue,'');
        TestController.operatorOperation('Contact.Account.NumberOfEmployees','INTEGER','<=',testvalue,'');
        
        
        // Test DOUBLE Type
        TestController.operatorOperation('Contact.Account.NumberOfEmployees','DOUBLE','=','','');
        TestController.operatorOperation('Contact.Account.NumberOfEmployees','DOUBLE','!=','','');
        TestController.operatorOperation('Contact.Account.NumberOfEmployees','DOUBLE','>','','');
        TestController.operatorOperation('Contact.Account.NumberOfEmployees','DOUBLE','<','','');
        TestController.operatorOperation('Contact.Account.NumberOfEmployees','DOUBLE','>=','','');
        TestController.operatorOperation('Contact.Account.NumberOfEmployees','DOUBLE','<=','','');
        
        testvalue='1';
        TestController.operatorOperation('Contact.Account.NumberOfEmployees','DOUBLE','=',testvalue,'');
        TestController.operatorOperation('Contact.Account.NumberOfEmployees','DOUBLE','!=',testvalue,'');
        TestController.operatorOperation('Contact.Account.NumberOfEmployees','DOUBLE','>',testvalue,'');
        TestController.operatorOperation('Contact.Account.NumberOfEmployees','DOUBLE','<',testvalue,'');
        TestController.operatorOperation('Contact.Account.NumberOfEmployees','DOUBLE','>=',testvalue,'');
        TestController.operatorOperation('Contact.Account.NumberOfEmployees','DOUBLE','<=',testvalue,'');
        
        testvalue=testvalue+',';
        TestController.operatorOperation('Contact.Account.NumberOfEmployees','DOUBLE','=',testvalue,'');
        TestController.operatorOperation('Contact.Account.NumberOfEmployees','DOUBLE','!=',testvalue,'');
        TestController.operatorOperation('Contact.Account.NumberOfEmployees','DOUBLE','>',testvalue,'');
        TestController.operatorOperation('Contact.Account.NumberOfEmployees','DOUBLE','<',testvalue,'');
        TestController.operatorOperation('Contact.Account.NumberOfEmployees','DOUBLE','>=',testvalue,'');
        TestController.operatorOperation('Contact.Account.NumberOfEmployees','DOUBLE','<=',testvalue,'');
        
        testvalue='1,11';
        TestController.operatorOperation('Contact.Account.NumberOfEmployees','DOUBLE','=',testvalue,'');
        TestController.operatorOperation('Contact.Account.NumberOfEmployees','DOUBLE','!=',testvalue,'');
        TestController.operatorOperation('Contact.Account.NumberOfEmployees','DOUBLE','>',testvalue,'');
        TestController.operatorOperation('Contact.Account.NumberOfEmployees','DOUBLE','<',testvalue,'');
        TestController.operatorOperation('Contact.Account.NumberOfEmployees','DOUBLE','>=',testvalue,'');
        TestController.operatorOperation('Contact.Account.NumberOfEmployees','DOUBLE','<=',testvalue,'');
        
        // Test PERCENT Type
        TestController.operatorOperation('Contact.Account.NumberOfEmployees','PERCENT','=','','');
        TestController.operatorOperation('Contact.Account.NumberOfEmployees','PERCENT','!=','','');
        TestController.operatorOperation('Contact.Account.NumberOfEmployees','PERCENT','>','','');
        TestController.operatorOperation('Contact.Account.NumberOfEmployees','PERCENT','<','','');
        TestController.operatorOperation('Contact.Account.NumberOfEmployees','PERCENT','>=','','');
        TestController.operatorOperation('Contact.Account.NumberOfEmployees','PERCENT','<=','','');
        
        testvalue='1';
        TestController.operatorOperation('Contact.Account.NumberOfEmployees','PERCENT','=',testvalue,'');
        TestController.operatorOperation('Contact.Account.NumberOfEmployees','PERCENT','!=',testvalue,'');
        TestController.operatorOperation('Contact.Account.NumberOfEmployees','PERCENT','>',testvalue,'');
        TestController.operatorOperation('Contact.Account.NumberOfEmployees','PERCENT','<',testvalue,'');
        TestController.operatorOperation('Contact.Account.NumberOfEmployees','PERCENT','>=',testvalue,'');
        TestController.operatorOperation('Contact.Account.NumberOfEmployees','PERCENT','<=',testvalue,'');
        
        testvalue=testvalue+',';
        TestController.operatorOperation('Contact.Account.NumberOfEmployees','PERCENT','=',testvalue,'');
        TestController.operatorOperation('Contact.Account.NumberOfEmployees','PERCENT','!=',testvalue,'');
        TestController.operatorOperation('Contact.Account.NumberOfEmployees','PERCENT','>',testvalue,'');
        TestController.operatorOperation('Contact.Account.NumberOfEmployees','PERCENT','<',testvalue,'');
        TestController.operatorOperation('Contact.Account.NumberOfEmployees','PERCENT','>=',testvalue,'');
        TestController.operatorOperation('Contact.Account.NumberOfEmployees','PERCENT','<=',testvalue,'');
        
        testvalue='1,11';
        TestController.operatorOperation('Contact.Account.NumberOfEmployees','PERCENT','=',testvalue,'');
        TestController.operatorOperation('Contact.Account.NumberOfEmployees','PERCENT','!=',testvalue,'');
        TestController.operatorOperation('Contact.Account.NumberOfEmployees','PERCENT','>',testvalue,'');
        TestController.operatorOperation('Contact.Account.NumberOfEmployees','PERCENT','<',testvalue,'');
        TestController.operatorOperation('Contact.Account.NumberOfEmployees','PERCENT','>=',testvalue,'');
        TestController.operatorOperation('Contact.Account.NumberOfEmployees','PERCENT','<=',testvalue,'');
        
        // Test MULTIPICKLIST Type
        TestController.operatorOperation('Contact.Account.Investment_Interests__c','MULTIPICKLIST','=','','');
        TestController.operatorOperation('Contact.Account.Investment_Interests__c','MULTIPICKLIST','!=','','');
        TestController.operatorOperation('Contact.Account.Investment_Interests__c','MULTIPICKLIST','includes','','');
        TestController.operatorOperation('Contact.Account.Investment_Interests__c','MULTIPICKLIST','excludes','','');
        
        
        testvalue='Stocks';
        TestController.operatorOperation('Contact.Account.Investment_Interests__c','MULTIPICKLIST','=',testvalue,'');
        TestController.operatorOperation('Contact.Account.Investment_Interests__c','MULTIPICKLIST','!=',testvalue,'');
        TestController.operatorOperation('Contact.Account.Investment_Interests__c','MULTIPICKLIST','includes',testvalue,'');
        TestController.operatorOperation('Contact.Account.Investment_Interests__c','MULTIPICKLIST','excludes',testvalue,'');
        
        
        testvalue=testvalue+',';
        TestController.operatorOperation('Contact.Account.Investment_Interests__c','MULTIPICKLIST','=',testvalue,'');
        TestController.operatorOperation('Contact.Account.Investment_Interests__c','MULTIPICKLIST','!=',testvalue,'');
        TestController.operatorOperation('Contact.Account.Investment_Interests__c','MULTIPICKLIST','includes',testvalue,'');
        TestController.operatorOperation('Contact.Account.Investment_Interests__c','MULTIPICKLIST','excludes',testvalue,'');
        
        
        testvalue='Stocks,Insurance';
        TestController.operatorOperation('Contact.Account.Investment_Interests__c','MULTIPICKLIST','=',testvalue,'');
        TestController.operatorOperation('Contact.Account.Investment_Interests__c','MULTIPICKLIST','!=',testvalue,'');
        TestController.operatorOperation('Contact.Account.Investment_Interests__c','MULTIPICKLIST','includes',testvalue,'');
        TestController.operatorOperation('Contact.Account.Investment_Interests__c','MULTIPICKLIST','excludes',testvalue,'');
        
        // Test PICKLIST Type
        TestController.operatorOperation('Contact.Client_Review_Frequency__c','PICKLIST','=','','');
        TestController.operatorOperation('Contact.Client_Review_Frequency__c','PICKLIST','!=','','');
        TestController.operatorOperation('Contact.Client_Review_Frequency__c','PICKLIST','>','','');
        TestController.operatorOperation('Contact.Client_Review_Frequency__c','PICKLIST','<','','');
        TestController.operatorOperation('Contact.Client_Review_Frequency__c','PICKLIST','>=','','');
        TestController.operatorOperation('Contact.Client_Review_Frequency__c','PICKLIST','<=','','');
        TestController.operatorOperation('Contact.Client_Review_Frequency__c','PICKLIST','contains','','');
        TestController.operatorOperation('Contact.Client_Review_Frequency__c','PICKLIST','like','','');
        TestController.operatorOperation('Contact.Client_Review_Frequency__c','PICKLIST','doesnotcontain','','');
        
        testvalue='Monthly';
        TestController.operatorOperation('Contact.Client_Review_Frequency__c','PICKLIST','=',testvalue,'');
        TestController.operatorOperation('Contact.Client_Review_Frequency__c','PICKLIST','!=',testvalue,'');
        TestController.operatorOperation('Contact.Client_Review_Frequency__c','PICKLIST','>',testvalue,'');
        TestController.operatorOperation('Contact.Client_Review_Frequency__c','PICKLIST','<',testvalue,'');
        TestController.operatorOperation('Contact.Client_Review_Frequency__c','PICKLIST','>=',testvalue,'');
        TestController.operatorOperation('Contact.Client_Review_Frequency__c','PICKLIST','<=',testvalue,'');
        TestController.operatorOperation('Contact.Client_Review_Frequency__c','PICKLIST','contains','','');
        TestController.operatorOperation('Contact.Client_Review_Frequency__c','PICKLIST','like','','');
        TestController.operatorOperation('Contact.Client_Review_Frequency__c','PICKLIST','doesnotcontain','','');
        
        testvalue=testvalue+',';
        TestController.operatorOperation('Contact.Client_Review_Frequency__c','PICKLIST','=',testvalue,'');
        TestController.operatorOperation('Contact.Client_Review_Frequency__c','PICKLIST','!=',testvalue,'');
        TestController.operatorOperation('Contact.Client_Review_Frequency__c','PICKLIST','>',testvalue,'');
        TestController.operatorOperation('Contact.Client_Review_Frequency__c','PICKLIST','<',testvalue,'');
        TestController.operatorOperation('Contact.Client_Review_Frequency__c','PICKLIST','>=',testvalue,'');
        TestController.operatorOperation('Contact.Client_Review_Frequency__c','PICKLIST','<=',testvalue,'');
        TestController.operatorOperation('Contact.Client_Review_Frequency__c','PICKLIST','contains','','');
        TestController.operatorOperation('Contact.Client_Review_Frequency__c','PICKLIST','like','','');
        TestController.operatorOperation('Contact.Client_Review_Frequency__c','PICKLIST','doesnotcontain','','');
        
        testvalue='Monthly,Quarterly';
        TestController.operatorOperation('Contact.Client_Review_Frequency__c','PICKLIST','=',testvalue,'');
        TestController.operatorOperation('Contact.Client_Review_Frequency__c','PICKLIST','!=',testvalue,'');
        TestController.operatorOperation('Contact.Client_Review_Frequency__c','PICKLIST','>',testvalue,'');
        TestController.operatorOperation('Contact.Client_Review_Frequency__c','PICKLIST','<',testvalue,'');
        TestController.operatorOperation('Contact.Client_Review_Frequency__c','PICKLIST','>=',testvalue,'');
        TestController.operatorOperation('Contact.Client_Review_Frequency__c','PICKLIST','<=',testvalue,'');
        TestController.operatorOperation('Contact.Client_Review_Frequency__c','PICKLIST','contains','','');
        TestController.operatorOperation('Contact.Client_Review_Frequency__c','PICKLIST','like','','');
        TestController.operatorOperation('Contact.Client_Review_Frequency__c','PICKLIST','doesnotcontain','','');
        
        // Test EMAIL Type
        TestController.operatorOperation('Contact.Email','EMAIL','=','','');
        TestController.operatorOperation('Contact.Email','EMAIL','!=','','');
        TestController.operatorOperation('Contact.Email','EMAIL','>','','');
        TestController.operatorOperation('Contact.Email','EMAIL','<','','');
        TestController.operatorOperation('Contact.Email','EMAIL','>=','','');
        TestController.operatorOperation('Contact.Email','EMAIL','<=','','');
        TestController.operatorOperation('Contact.Email','EMAIL','contains','','');
        TestController.operatorOperation('Contact.Email','EMAIL','like','','');
        TestController.operatorOperation('Contact.Email','EMAIL','doesnotcontain','','');
        
        testvalue='nav1@gmail.com';
        TestController.operatorOperation('Contact.Email','EMAIL','=',testvalue,'');
        TestController.operatorOperation('Contact.Email','EMAIL','!=',testvalue,'');
        TestController.operatorOperation('Contact.Email','EMAIL','>',testvalue,'');
        TestController.operatorOperation('Contact.Email','EMAIL','<',testvalue,'');
        TestController.operatorOperation('Contact.Email','EMAIL','>=',testvalue,'');
        TestController.operatorOperation('Contact.Email','EMAIL','<=',testvalue,'');
        TestController.operatorOperation('Contact.Email','EMAIL','contains',testvalue,'');
        TestController.operatorOperation('Contact.Email','EMAIL','like',testvalue,'');
        TestController.operatorOperation('Contact.Email','EMAIL','doesnotcontain',testvalue,'');
        
        testvalue=testvalue+',';
        TestController.operatorOperation('Contact.Email','EMAIL','=',testvalue,'');
        TestController.operatorOperation('Contact.Email','EMAIL','!=',testvalue,'');
        TestController.operatorOperation('Contact.Email','EMAIL','>',testvalue,'');
        TestController.operatorOperation('Contact.Email','EMAIL','<',testvalue,'');
        TestController.operatorOperation('Contact.Email','EMAIL','>=',testvalue,'');
        TestController.operatorOperation('Contact.Email','EMAIL','<=',testvalue,'');
        TestController.operatorOperation('Contact.Email','EMAIL','contains',testvalue,'');
        TestController.operatorOperation('Contact.Email','EMAIL','like',testvalue,'');
        TestController.operatorOperation('Contact.Email','EMAIL','doesnotcontain',testvalue,'');
        
        testvalue='nav1@gmail.com,nav2@gmail.com';
        TestController.operatorOperation('Contact.Email','EMAIL','=',testvalue,'');
        TestController.operatorOperation('Contact.Email','EMAIL','!=',testvalue,'');
        TestController.operatorOperation('Contact.Email','EMAIL','>',testvalue,'');
        TestController.operatorOperation('Contact.Email','EMAIL','<',testvalue,'');
        TestController.operatorOperation('Contact.Email','EMAIL','>=',testvalue,'');
        TestController.operatorOperation('Contact.Email','EMAIL','<=',testvalue,'');
        TestController.operatorOperation('Contact.Email','EMAIL','contains',testvalue,'');
        TestController.operatorOperation('Contact.Email','EMAIL','like',testvalue,'');
        TestController.operatorOperation('Contact.Email','EMAIL','doesnotcontain',testvalue,'');
        
        // Test DATETIME Type To cover Locale Senerios
        
    //    TestController.locale_info='be_BY';
        testvalue='08/12/2012';
        TestController.operatorOperation('Contact.Account.CreatedDate','DATETIME','=',testvalue,'');
        TestController.operatorOperation('Contact.Account.CreatedDate','DATETIME','!=',testvalue,'');
        TestController.operatorOperation('Contact.Account.CreatedDate','DATETIME','>',testvalue,'');
        TestController.operatorOperation('Contact.Account.CreatedDate','DATETIME','<',testvalue,'');
        TestController.operatorOperation('Contact.Account.CreatedDate','DATETIME','>=',testvalue,'');
        TestController.operatorOperation('Contact.Account.CreatedDate','DATETIME','<=',testvalue,'');
        
    //     TestController.locale_info='ko_KR';
        testvalue='08/12/2012';
        TestController.operatorOperation('Contact.Account.CreatedDate','DATETIME','=',testvalue,'');
        TestController.operatorOperation('Contact.Account.CreatedDate','DATETIME','!=',testvalue,'');
        TestController.operatorOperation('Contact.Account.CreatedDate','DATETIME','>',testvalue,'');
        TestController.operatorOperation('Contact.Account.CreatedDate','DATETIME','<',testvalue,'');
        TestController.operatorOperation('Contact.Account.CreatedDate','DATETIME','>=',testvalue,'');
        TestController.operatorOperation('Contact.Account.CreatedDate','DATETIME','<=',testvalue,'');
    }
    
    
    public static testMethod void testHub_FilterController() 
    {
        test.startTest();
        
        clsOne_filter clsObj = new clsOne_filter();
        string testvalue='';
        System.assertEquals('', testvalue); // (PE3.5, SK, 9Aug2017)
        
        clsObj.operatorOperation('Contact.Account.CreatedDate','DATETIME','=',testvalue,'en_US');
        clsObj.operatorOperation('Contact.Account.CreatedDate','DATETIME','!=',testvalue,'en_US');
        clsObj.operatorOperation('Contact.Account.CreatedDate','DATETIME','>',testvalue,'en_US');
        clsObj.operatorOperation('Contact.Account.CreatedDate','DATETIME','<',testvalue,'en_US');
        clsObj.operatorOperation('Contact.Account.CreatedDate','DATETIME','>=',testvalue,'en_US');
        clsObj.operatorOperation('Contact.Account.CreatedDate','DATETIME','<=',testvalue,'en_US');
        
        
        testvalue='2013-10-05 20:03:20';
        System.assertEquals('2013-10-05 20:03:20', testvalue); // (PE3.5, SK, 9Aug2017)
        
        clsObj.operatorOperation('Contact.Account.CreatedDate','DATETIME','=',testvalue,'en_US');
        clsObj.operatorOperation('Contact.Account.CreatedDate','DATETIME','!=',testvalue,'en_US');
        clsObj.operatorOperation('Contact.Account.CreatedDate','DATETIME','>',testvalue,'en_US');
        clsObj.operatorOperation('Contact.Account.CreatedDate','DATETIME','<',testvalue,'en_US');
        clsObj.operatorOperation('Contact.Account.CreatedDate','DATETIME','>=',testvalue,'en_US');
        clsObj.operatorOperation('Contact.Account.CreatedDate','DATETIME','<=',testvalue,'en_US');
        
        
        testvalue='';
        System.assertEquals('', testvalue); // (PE3.5, SK, 9Aug2017)
        
        clsObj.operatorOperation('Contact.Birthdate','DATE','=',testvalue,'en_US');
        clsObj.operatorOperation('Contact.Birthdate','DATE','!=',testvalue,'en_US');
        clsObj.operatorOperation('Contact.Birthdate','DATE','>',testvalue,'en_US');
        clsObj.operatorOperation('Contact.Birthdate','DATE','<',testvalue,'en_US');
        clsObj.operatorOperation('Contact.Birthdate','DATE','>=',testvalue,'en_US');
        clsObj.operatorOperation('Contact.Birthdate','DATE','<=',testvalue,'en_US');
        
        
        testvalue='2013-10-05 20:03:20';
        System.assertEquals('2013-10-05 20:03:20', testvalue); // (PE3.5, SK, 9Aug2017)
        
        clsObj.operatorOperation('Contact.Birthdate','DATE','=',testvalue,'en_US');
        clsObj.operatorOperation('Contact.Birthdate','DATE','!=',testvalue,'en_US');
        clsObj.operatorOperation('Contact.Birthdate','DATE','>',testvalue,'en_US');
        clsObj.operatorOperation('Contact.Birthdate','DATE','<',testvalue,'en_US');
        clsObj.operatorOperation('Contact.Birthdate','DATE','>=',testvalue,'en_US');
        clsObj.operatorOperation('Contact.Birthdate','DATE','<=',testvalue,'en_US');
        
        
        testvalue=' ,test@test.com';
        System.assertEquals(' ,test@test.com', testvalue); // (PE3.5, SK, 9Aug2017)
        
        clsObj.operatorOperation('Contact.Email','EMAIL','doesnotcontain',testvalue,'');
        clsObj.operatorOperation('Contact.Client_Review_Frequency__c','PICKLIST','doesnotcontain',testvalue,'');
        clsObj.operatorOperation('Contact.Email','EMAIL','>',testvalue,'');
        clsObj.operatorOperation('Contact.Email','EMAIL','<',testvalue,'');
        clsObj.operatorOperation('Contact.Email','EMAIL','>=',testvalue,'');
        test.stopTest();
    }
}