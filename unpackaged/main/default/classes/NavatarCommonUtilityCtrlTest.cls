@isTest
public class NavatarCommonUtilityCtrlTest {
	public static testMethod void CUGandClsOneFilter()
    {
            NavatarCommonUtilityCtrl CUG = new NavatarCommonUtilityCtrl();
            CUG.chckFilter('(1 OR 2) And 3');
            NavatarCommonUtilityCtrl.checkDate('04/19/2017','04/21/2017');
            NavatarCommonUtilityCtrl.getValidDate('04/19/2017');
            NavatarCommonUtilityCtrl.checkDate('fg','sdg');
            NavatarCommonUtilityCtrl.getValidDate('sdg');
            string jsn = '[{"serialnumber":1,"field":"Account:BillingPostalCode:Billing Zip/Postal Code:string","Value":"","Operator":"="},{"serialnumber":2,"field":"Account:BillingPostalCode:Billing Zip/Postal Code:string","Value":"","Operator":"="},{"serialnumber":3,"field":"Account:BillingPostalCode:Billing Zip/Postal Code:string","Value":"","Operator":"="},{"serialnumber":4,"field":"Account:BillingPostalCode:Billing Zip/Postal Code:string","Value":"","Operator":"="},{"serialnumber":5,"field":"Account:BillingPostalCode:Billing Zip/Postal Code:string","Value":"","Operator":"="},{"serialnumber":6,"field":"Account:BillingPostalCode:Billing Zip/Postal Code:string","Value":"","Operator":"="},{"serialnumber":7,"field":"Account:BillingPostalCode:Billing Zip/Postal Code:string","Value":"","Operator":"="},{"serialnumber":8,"field":"Account:BillingPostalCode:Billing Zip/Postal Code:string","Value":"","Operator":"="},{"serialnumber":9,"field":"Account:BillingPostalCode:Billing Zip/Postal Code:string","Value":"","Operator":"="},{"serialnumber":10,"field":"Account:BillingPostalCode:Billing Zip/Postal Code:string","Value":"","Operator":"="}]';
            NavatarCommonUtilityCtrl.executequery(jsn,'CMF');
            NavatarCommonUtilityCtrl.executequery(jsn,'MEF'); 
            /////////////////////////////////////////////////////
            NavatarCommonUtilityCtrl.executequery(jsn,'DAIT_ConRole'); 
            NavatarCommonUtilityCtrl.executequery(jsn,'MI'); 
            NavatarCommonUtilityCtrl.executequery(jsn,'DAIT'); 
            NavatarCommonUtilityCtrl.executequery(jsn,'DAIT_AccContactTab'); 
            NavatarCommonUtilityCtrl.executequery(jsn,'MEP'); 
                        
            jsn = '[{"serialnumber":1,"field":"Fund:Name:Fund Name:string","Value":"","Operator":"="},{"serialnumber":2,"field":"Fund:Name:Fund Name:string","Value":"","Operator":"="},{"serialnumber":3,"field":"Fund:Name:Fund Name:string","Value":"","Operator":"="},{"serialnumber":4,"field":"Fund:Name:Fund Name:string","Value":"","Operator":"="},{"serialnumber":5,"field":"Fund:Name:Fund Name:string","Value":"","Operator":"="},{"serialnumber":6,"field":"Fund:Name:Fund Name:string","Value":"","Operator":"="},{"serialnumber":7,"field":"Fund:Name:Fund Name:string","Value":"","Operator":"="},{"serialnumber":8,"field":"Fund:Name:Fund Name:string","Value":"","Operator":"="},{"serialnumber":9,"field":"Fund:Name:Fund Name:string","Value":"","Operator":"="},{"serialnumber":10,"field":"Fund:Name:Fund Name:string","Value":"","Operator":"="}]';
            NavatarCommonUtilityCtrl.executequery(jsn,'CMF');
            NavatarCommonUtilityCtrl.executequery(jsn,'MEF'); 
            
            NavatarCommonUtilityCtrl.executequery(jsn,'DAIT_ConRole'); 
            NavatarCommonUtilityCtrl.executequery(jsn,'MI'); 
            NavatarCommonUtilityCtrl.executequery(jsn,'DAIT'); 
            NavatarCommonUtilityCtrl.executequery(jsn,'DAIT_AccContactTab'); 
            NavatarCommonUtilityCtrl.executequery(jsn,'MEP'); 
            
            jsn = '[{"serialnumber":1,"field":"Fundraising:Next_Step__c:Next Step:string","Value":"","Operator":"="},{"serialnumber":2,"field":"Fundraising:Next_Step__c:Next Step:string","Value":"","Operator":"="},{"serialnumber":3,"field":"Fundraising:Next_Step__c:Next Step:string","Value":"","Operator":"="},{"serialnumber":4,"field":"Fundraising:Next_Step__c:Next Step:string","Value":"","Operator":"="},{"serialnumber":5,"field":"Fundraising:Next_Step__c:Next Step:string","Value":"","Operator":"="},{"serialnumber":6,"field":"Fundraising:Next_Step__c:Next Step:string","Value":"","Operator":"="},{"serialnumber":7,"field":"Fundraising:Next_Step__c:Next Step:string","Value":"","Operator":"="},{"serialnumber":8,"field":"Fundraising:Next_Step__c:Next Step:string","Value":"","Operator":"="},{"serialnumber":9,"field":"Fundraising:Next_Step__c:Next Step:string","Value":"","Operator":"="},{"serialnumber":10,"field":"Fundraising:Next_Step__c:Next Step:string","Value":"","Operator":"="}]';
            NavatarCommonUtilityCtrl.executequery(jsn,'CMF');
            NavatarCommonUtilityCtrl.executequery(jsn,'MEF'); 
            
            NavatarCommonUtilityCtrl.executequery(jsn,'DAIT_ConRole'); 
            NavatarCommonUtilityCtrl.executequery(jsn,'MI'); 
            NavatarCommonUtilityCtrl.executequery(jsn,'DAIT'); 
            NavatarCommonUtilityCtrl.executequery(jsn,'DAIT_AccContactTab'); 
            NavatarCommonUtilityCtrl.executequery(jsn,'MEP'); 
            
            jsn = '[{"serialnumber":1,"field":"Contact:Department:Department:string","Value":"","Operator":"="},{"serialnumber":2,"field":"Contact:Department:Department:string","Value":"","Operator":"="},{"serialnumber":3,"field":"Contact:Department:Department:string","Value":"","Operator":"="},{"serialnumber":4,"field":"Contact:Department:Department:string","Value":"","Operator":"="},{"serialnumber":5,"field":"Contact:Department:Department:string","Value":"","Operator":"="},{"serialnumber":6,"field":"Contact:Department:Department:string","Value":"","Operator":"="},{"serialnumber":7,"field":"Contact:Department:Department:string","Value":"","Operator":"="},{"serialnumber":8,"field":"Contact:Department:Department:string","Value":"","Operator":"="},{"serialnumber":9,"field":"Contact:Department:Department:string","Value":"","Operator":"="},{"serialnumber":10,"field":"Contact:Department:Department:string","Value":"","Operator":"="}]';
            NavatarCommonUtilityCtrl.executequery(jsn,'MEF');
            
            NavatarCommonUtilityCtrl.executequery(jsn,'DAIT_ConRole'); 
            NavatarCommonUtilityCtrl.executequery(jsn,'MI'); 
            NavatarCommonUtilityCtrl.executequery(jsn,'DAIT'); 
            NavatarCommonUtilityCtrl.executequery(jsn,'DAIT_AccContactTab'); 
            NavatarCommonUtilityCtrl.executequery(jsn,'MEP'); 
        
            jsn = '[{"serialnumber":1,"field":"Fundraising Contact:Name:Fundraising Contact ID:string","Value":"","Operator":"="},{"serialnumber":2,"field":"Fundraising Contact:Name:Fundraising Contact ID:string","Value":"","Operator":"="},{"serialnumber":3,"field":"Fundraising Contact:Name:Fundraising Contact ID:string","Value":"","Operator":"="},{"serialnumber":4,"field":"Fundraising Contact:Name:Fundraising Contact ID:string","Value":"","Operator":"="},{"serialnumber":5,"field":"Fundraising Contact:Name:Fundraising Contact ID:string","Value":"","Operator":"="},{"serialnumber":6,"field":"Fundraising Contact:Name:Fundraising Contact ID:string","Value":"","Operator":"="},{"serialnumber":7,"field":"Fundraising Contact:Name:Fundraising Contact ID:string","Value":"","Operator":"="},{"serialnumber":8,"field":"Fundraising Contact:Name:Fundraising Contact ID:string","Value":"","Operator":"="},{"serialnumber":9,"field":"Fundraising Contact:Name:Fundraising Contact ID:string","Value":"","Operator":"="},{"serialnumber":10,"field":"Fundraising Contact:Name:Fundraising Contact ID:string","Value":"","Operator":"="}]';
            NavatarCommonUtilityCtrl.executequery(jsn,'MEF');            
            
            NavatarCommonUtilityCtrl.executequery(jsn,'DAIT_ConRole'); 
            NavatarCommonUtilityCtrl.executequery(jsn,'MI'); 
            NavatarCommonUtilityCtrl.executequery(jsn,'DAIT'); 
            NavatarCommonUtilityCtrl.executequery(jsn,'DAIT_AccContactTab'); 
            NavatarCommonUtilityCtrl.executequery(jsn,'MEP'); 
        
            
            NavatarCommonUtilityCtrl.Specialchar('fhasdhfiwu*$*^%$^& adsfjaklsdjf');
            /*NavatarCommonUtilityCtrl.convertdatetime('10/14/2011 11:46 AM');
            NavatarCommonUtilityCtrl.convertdatetime('10/14/2011');*/
        
            NavatarCommonUtilityCtrl.convertdate('08/12/2012');
            NavatarCommonUtilityCtrl.convertdateGMT('08/12/2012');
            //NavatarCommonUtilityCtrl.convertdatetimeGMT('10/14/2011 11:46 AM');
        
        
        
        Account opacc1 = new Account(name='testSam1');
        Account opacc2 = new Account(name='testSam1');
        insert opacc1;
        insert opacc2;
        system.assertEquals(opacc1.name,'testSam1');
        NavatarFilterResultsCtrl TestController = new  NavatarFilterResultsCtrl();
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
     public static testMethod void Test1(){
         NavatarCommonUtilityCtrl CUG = new NavatarCommonUtilityCtrl();
            string jsn = '[{"serialnumber":1,"field":"Account:BillingPostalCode:Billing Zip/Postal Code:string","Value":"","Operator":"="},{"serialnumber":2,"field":"Account:BillingPostalCode:Billing Zip/Postal Code:string","Value":"","Operator":"="},{"serialnumber":3,"field":"Account:BillingPostalCode:Billing Zip/Postal Code:string","Value":"","Operator":"="},{"serialnumber":4,"field":"Account:BillingPostalCode:Billing Zip/Postal Code:string","Value":"","Operator":"="},{"serialnumber":5,"field":"Account:BillingPostalCode:Billing Zip/Postal Code:string","Value":"","Operator":"="},{"serialnumber":6,"field":"Account:BillingPostalCode:Billing Zip/Postal Code:string","Value":"","Operator":"="},{"serialnumber":7,"field":"Account:BillingPostalCode:Billing Zip/Postal Code:string","Value":"","Operator":"="},{"serialnumber":8,"field":"Account:BillingPostalCode:Billing Zip/Postal Code:string","Value":"","Operator":"="},{"serialnumber":9,"field":"Account:BillingPostalCode:Billing Zip/Postal Code:string","Value":"","Operator":"="},{"serialnumber":10,"field":"Account:BillingPostalCode:Billing Zip/Postal Code:string","Value":"","Operator":"="}]';
            NavatarCommonUtilityCtrl.executequery1(jsn,'CMF','1 OR 2 OR 3 OR 4 OR 5 OR 6 OR 7 OR 8 OR 9 OR 10');
            NavatarCommonUtilityCtrl.executequery1(jsn,'MEF','1 OR 2 OR 3 OR 4 OR 5 OR 6 OR 7 OR 8 OR 9 OR 10'); 
            /////////////////////////////////////////////////////
            NavatarCommonUtilityCtrl.executequery1(jsn,'DAIT_ConRole','1 OR 2 OR 3 OR 4 OR 5 OR 6 OR 7 OR 8 OR 9 OR 10'); 
            NavatarCommonUtilityCtrl.executequery1(jsn,'MI','1 OR 2 OR 3 OR 4 OR 5 OR 6 OR 7 OR 8 OR 9 OR 10'); 
            NavatarCommonUtilityCtrl.executequery1(jsn,' ','1 OR 2 OR 3 OR 4 OR 5 OR 6 OR 7 OR 8 OR 9 OR 10'); 
            NavatarCommonUtilityCtrl.executequery1(jsn,'DAIT_AccContactTab','1 OR 2 OR 3 OR 4 OR 5 OR 6 OR 7 OR 8 OR 9 OR 10'); 
            NavatarCommonUtilityCtrl.executequery1(jsn,'MEP','1 OR 2 OR 3 OR 4 OR 5 OR 6 OR 7 OR 8 OR 9 OR 10'); 
            
            
            jsn = '[{"serialnumber":1,"field":"Deal:Name:Fund Name:string","Value":"","Operator":"="},{"serialnumber":2,"field":"Deal:Name:Fund Name:string","Value":"","Operator":"="},{"serialnumber":3,"field":"Deal:Name:Fund Name:string","Value":"","Operator":"="},{"serialnumber":4,"field":"Deal:Name:Fund Name:string","Value":"","Operator":"="},{"serialnumber":5,"field":"Deal:Name:Fund Name:string","Value":"","Operator":"="},{"serialnumber":6,"field":"Deal:Name:Fund Name:string","Value":"","Operator":"="},{"serialnumber":7,"field":"Deal:Name:Fund Name:string","Value":"","Operator":"="},{"serialnumber":8,"field":"Deal:Name:Fund Name:string","Value":"","Operator":"="},{"serialnumber":9,"field":"Deal:Name:Fund Name:string","Value":"","Operator":"="},{"serialnumber":10,"field":"Deal:Name:Fund Name:string","Value":"","Operator":"="}]';
            NavatarCommonUtilityCtrl.executequery1(jsn,'CMF','1 OR 2 OR 3 OR 4 OR 5 OR 6 OR 7 OR 8 OR 9 OR 10');
            NavatarCommonUtilityCtrl.executequery1(jsn,'MEF','1 OR 2 OR 3 OR 4 OR 5 OR 6 OR 7 OR 8 OR 9 OR 10'); 
            
            NavatarCommonUtilityCtrl.executequery1(jsn,'DAIT_ConRole','1 OR 2 OR 3 OR 4 OR 5 OR 6 OR 7 OR 8 OR 9 OR 10'); 
            NavatarCommonUtilityCtrl.executequery1(jsn,'MI','1 OR 2 OR 3 OR 4 OR 5 OR 6 OR 7 OR 8 OR 9 OR 10'); 
            NavatarCommonUtilityCtrl.executequery1(jsn,'DAIT','1 OR 2 OR 3 OR 4 OR 5 OR 6 OR 7 OR 8 OR 9 OR 10'); 
            NavatarCommonUtilityCtrl.executequery1(jsn,'DAIT_AccContactTab','1 OR 2 OR 3 OR 4 OR 5 OR 6 OR 7 OR 8 OR 9 OR 10'); 
            NavatarCommonUtilityCtrl.executequery1(jsn,'MEP','1 OR 2 OR 3 OR 4 OR 5 OR 6 OR 7 OR 8 OR 9 OR 10'); 
            
            jsn = '[{"serialnumber":1,"field":"Target:Amount__c:12 Step:string","Value":"","Operator":"="},{"serialnumber":2,"field":"Target:Amount__c:21 Step:string","Value":"","Operator":"="},{"serialnumber":3,"field":"Target:Amount__c:12 Step:string","Value":"","Operator":"="},{"serialnumber":4,"field":"Target:Amount__c:123 Step:string","Value":"","Operator":"="},{"serialnumber":5,"field":"Target:Amount__c:23 Step:string","Value":"","Operator":"="},{"serialnumber":6,"field":"Target:Amount__c:23 Step:string","Value":"","Operator":"="},{"serialnumber":7,"field":"Target:Amount__c:23 Step:string","Value":"","Operator":"="},{"serialnumber":8,"field":"Target:Amount__c:23 Step:string","Value":"","Operator":"="},{"serialnumber":9,"field":"Target:Amount__c:23 Step:string","Value":"","Operator":"="},{"serialnumber":10,"field":"Target:Amount__c:23 Step:string","Value":"","Operator":"="}]';
            NavatarCommonUtilityCtrl.executequery1(jsn,'CMF','');
            NavatarCommonUtilityCtrl.executequery1(jsn,'MEF',''); 
            
            NavatarCommonUtilityCtrl.executequery1(jsn,'DAIT_ConRole',''); 
            NavatarCommonUtilityCtrl.executequery1(jsn,'MI',''); 
            NavatarCommonUtilityCtrl.executequery1(jsn,'DAIT',''); 
            NavatarCommonUtilityCtrl.executequery1(jsn,'DAIT_AccContactTab',''); 
            NavatarCommonUtilityCtrl.executequery1(jsn,'MEP',''); 
            
            jsn = '[{"serialnumber":1,"field":"Contact:Department:Department:string","Value":"","Operator":"="},{"serialnumber":2,"field":"Contact:Department:Department:string","Value":"","Operator":"="},{"serialnumber":3,"field":"Contact:Department:Department:string","Value":"","Operator":"="},{"serialnumber":4,"field":"Contact:Department:Department:string","Value":"","Operator":"="},{"serialnumber":5,"field":"Contact:Department:Department:string","Value":"","Operator":"="},{"serialnumber":6,"field":"Contact:Department:Department:string","Value":"","Operator":"="},{"serialnumber":7,"field":"Contact:Department:Department:string","Value":"","Operator":"="},{"serialnumber":8,"field":"Contact:Department:Department:string","Value":"","Operator":"="},{"serialnumber":9,"field":"Contact:Department:Department:string","Value":"","Operator":"="},{"serialnumber":10,"field":"Contact:Department:Department:string","Value":"","Operator":"="}]';
            NavatarCommonUtilityCtrl.executequery1(jsn,'MEF','1 OR 2 OR 3 OR 4 OR 5 OR 6 OR 7 OR 8 OR 9 OR 10');
            
            NavatarCommonUtilityCtrl.executequery1(jsn,'DAIT_ConRole','1 OR 2 OR 3 OR 4 OR 5 OR 6 OR 7 OR 8 OR 9 OR 10'); 
            NavatarCommonUtilityCtrl.executequery1(jsn,'MI','1 OR 2 OR 3 OR 4 OR 5 OR 6 OR 7 OR 8 OR 9 OR 10'); 
            NavatarCommonUtilityCtrl.executequery1(jsn,'DAIT','1 OR 2 OR 3 OR 4 OR 5 OR 6 OR 7 OR 8 OR 9 OR 10'); 
            NavatarCommonUtilityCtrl.executequery1(jsn,'DAIT_AccContactTab','1 OR 2 OR 3 OR 4 OR 5 OR 6 OR 7 OR 8 OR 9 OR 10'); 
            NavatarCommonUtilityCtrl.executequery1(jsn,'MEP','1 OR 2 OR 3 OR 4 OR 5 OR 6 OR 7 OR 8 OR 9 OR 10'); 
        
            jsn = '[{"serialnumber":1,"field":"Contact Role:Name:Fundraising Contact ID:string","Value":"","Operator":"="},{"serialnumber":2,"field":"Contact Role:Name:Fundraising Contact ID:string","Value":"","Operator":"="},{"serialnumber":3,"field":"Contact Role:Name:Fundraising Contact ID:string","Value":"","Operator":"="},{"serialnumber":4,"field":"Contact Role:Name:Fundraising Contact ID:string","Value":"","Operator":"="},{"serialnumber":5,"field":"Contact Role:Name:Fundraising Contact ID:string","Value":"","Operator":"="},{"serialnumber":6,"field":"Contact Role:Name:Fundraising Contact ID:string","Value":"","Operator":"="},{"serialnumber":7,"field":"Contact Role:Name:Fundraising Contact ID:string","Value":"","Operator":"="},{"serialnumber":8,"field":"Contact Role:Name:Fundraising Contact ID:string","Value":"","Operator":"="},{"serialnumber":9,"field":"Contact Role:Name:Fundraising Contact ID:string","Value":"","Operator":"="},{"serialnumber":10,"field":"Contact Role:Name:Fundraising Contact ID:string","Value":"","Operator":"="}]';
            NavatarCommonUtilityCtrl.executequery(jsn,'MEF');            
            
            NavatarCommonUtilityCtrl.executequery1(jsn,'DAIT_ConRole',''); 
            NavatarCommonUtilityCtrl.executequery1(jsn,'MI',''); 
            NavatarCommonUtilityCtrl.executequery1(jsn,'DAIT',''); 
            NavatarCommonUtilityCtrl.executequery1(jsn,'DAIT_AccContactTab',''); 
            NavatarCommonUtilityCtrl.executequery1(jsn,'MEP',''); 
        
            
            NavatarCommonUtilityCtrl.Specialchar('fhasdhfiwu*$*^%$^& adsfjaklsdjf');
            /*NavatarCommonUtilityCtrl.convertdatetime('10/14/2011 11:46 AM');
            NavatarCommonUtilityCtrl.convertdatetime('10/14/2011');*/
        
            NavatarCommonUtilityCtrl.convertdate('08/12/2012');
            NavatarCommonUtilityCtrl.convertdateGMT('08/12/2012');
            //NavatarCommonUtilityCtrl.convertdatetimeGMT('10/14/2011 11:46 AM');
        
        
        
        Account opacc1 = new Account(name='testSam1');
        Account opacc2 = new Account(name='testSam1');
        insert opacc1;
        insert opacc2;
        system.assertEquals(opacc1.name,'testSam1');
        NavatarFilterResultsCtrl TestController = new  NavatarFilterResultsCtrl();
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
        
        NavatarFilterResultsCtrl clsObj = new NavatarFilterResultsCtrl();
        string testvalue='';
        clsObj.operatorOperation('Contact.Account.CreatedDate','DATETIME','=',testvalue,'en_US');
        clsObj.operatorOperation('Contact.Account.CreatedDate','DATETIME','!=',testvalue,'en_US');
        clsObj.operatorOperation('Contact.Account.CreatedDate','DATETIME','>',testvalue,'en_US');
        clsObj.operatorOperation('Contact.Account.CreatedDate','DATETIME','<',testvalue,'en_US');
        clsObj.operatorOperation('Contact.Account.CreatedDate','DATETIME','>=',testvalue,'en_US');
        clsObj.operatorOperation('Contact.Account.CreatedDate','DATETIME','<=',testvalue,'en_US');
        
        testvalue='2013-10-05 20:03:20';
        clsObj.operatorOperation('Contact.Account.CreatedDate','DATETIME','=',testvalue,'en_US');
        clsObj.operatorOperation('Contact.Account.CreatedDate','DATETIME','!=',testvalue,'en_US');
        clsObj.operatorOperation('Contact.Account.CreatedDate','DATETIME','>',testvalue,'en_US');
        clsObj.operatorOperation('Contact.Account.CreatedDate','DATETIME','<',testvalue,'en_US');
        clsObj.operatorOperation('Contact.Account.CreatedDate','DATETIME','>=',testvalue,'en_US');
        clsObj.operatorOperation('Contact.Account.CreatedDate','DATETIME','<=',testvalue,'en_US');
        
        testvalue='';
        clsObj.operatorOperation('Contact.Birthdate','DATE','=',testvalue,'en_US');
        clsObj.operatorOperation('Contact.Birthdate','DATE','!=',testvalue,'en_US');
        clsObj.operatorOperation('Contact.Birthdate','DATE','>',testvalue,'en_US');
        clsObj.operatorOperation('Contact.Birthdate','DATE','<',testvalue,'en_US');
        clsObj.operatorOperation('Contact.Birthdate','DATE','>=',testvalue,'en_US');
        clsObj.operatorOperation('Contact.Birthdate','DATE','<=',testvalue,'en_US');
        
        testvalue='2013-10-05 20:03:20';
        clsObj.operatorOperation('Contact.Birthdate','DATE','=',testvalue,'en_US');
        clsObj.operatorOperation('Contact.Birthdate','DATE','!=',testvalue,'en_US');
        clsObj.operatorOperation('Contact.Birthdate','DATE','>',testvalue,'en_US');
        clsObj.operatorOperation('Contact.Birthdate','DATE','<',testvalue,'en_US');
        clsObj.operatorOperation('Contact.Birthdate','DATE','>=',testvalue,'en_US');
        clsObj.operatorOperation('Contact.Birthdate','DATE','<=',testvalue,'en_US');
        
         testvalue=' ,test@test.com';
         clsObj.operatorOperation('Contact.Email','EMAIL','doesnotcontain',testvalue,'');
         clsObj.operatorOperation('Contact.Client_Review_Frequency__c','PICKLIST','doesnotcontain',testvalue,'');
        clsObj.operatorOperation('Contact.Email','EMAIL','>',testvalue,'');
        clsObj.operatorOperation('Contact.Email','EMAIL','<',testvalue,'');
        clsObj.operatorOperation('Contact.Email','EMAIL','>=',testvalue,'');
        system.assertEquals('testSam1','testSam1');
         test.stopTest();
    }
    
    
    
    public static testMethod void CUGandClsOneFilter11(){
            NavatarCommonUtilityCtrl CUG = new NavatarCommonUtilityCtrl();
            string jsn = '[{"serialnumber":1,"field":"Account:BillingPostalCode:Billing Zip/Postal Code:string","Value":"","Operator":"="},{"serialnumber":2,"field":"Account:BillingPostalCode:Billing Zip/Postal Code:string","Value":"","Operator":"="},{"serialnumber":3,"field":"Account:BillingPostalCode:Billing Zip/Postal Code:string","Value":"","Operator":"="},{"serialnumber":4,"field":"Account:BillingPostalCode:Billing Zip/Postal Code:string","Value":"","Operator":"="},{"serialnumber":5,"field":"Account:BillingPostalCode:Billing Zip/Postal Code:string","Value":"","Operator":"="},{"serialnumber":6,"field":"Account:BillingPostalCode:Billing Zip/Postal Code:string","Value":"","Operator":"="},{"serialnumber":7,"field":"Account:BillingPostalCode:Billing Zip/Postal Code:string","Value":"","Operator":"="},{"serialnumber":8,"field":"Account:BillingPostalCode:Billing Zip/Postal Code:string","Value":"","Operator":"="},{"serialnumber":9,"field":"Account:BillingPostalCode:Billing Zip/Postal Code:string","Value":"","Operator":"="},{"serialnumber":10,"field":"Account:BillingPostalCode:Billing Zip/Postal Code:string","Value":"","Operator":"="}]';
            NavatarCommonUtilityCtrl.executequery(jsn,'CMF');
            NavatarCommonUtilityCtrl.executequery(jsn,'MEF');
            
            NavatarCommonUtilityCtrl.executequery(jsn,'DAIT_ConRole'); 
            NavatarCommonUtilityCtrl.executequery(jsn,'MI'); 
            NavatarCommonUtilityCtrl.executequery(jsn,'DAIT'); 
            NavatarCommonUtilityCtrl.executequery(jsn,'DAIT_AccContactTab'); 
            NavatarCommonUtilityCtrl.executequery(jsn,'MEP'); 
            
            jsn = '[{"serialnumber":1,"field":"Fund:Name:Fund Name:string","Value":"","Operator":"="},{"serialnumber":2,"field":"Fund:Name:Fund Name:string","Value":"","Operator":"="},{"serialnumber":3,"field":"Fund:Name:Fund Name:string","Value":"","Operator":"="},{"serialnumber":4,"field":"Fund:Name:Fund Name:string","Value":"","Operator":"="},{"serialnumber":5,"field":"Fund:Name:Fund Name:string","Value":"","Operator":"="},{"serialnumber":6,"field":"Fund:Name:Fund Name:string","Value":"","Operator":"="},{"serialnumber":7,"field":"Fund:Name:Fund Name:string","Value":"","Operator":"="},{"serialnumber":8,"field":"Fund:Name:Fund Name:string","Value":"","Operator":"="},{"serialnumber":9,"field":"Fund:Name:Fund Name:string","Value":"","Operator":"="},{"serialnumber":10,"field":"Fund:Name:Fund Name:string","Value":"","Operator":"="}]';
            NavatarCommonUtilityCtrl.executequery(jsn,'CMF');
            
            NavatarCommonUtilityCtrl.executequery(jsn,'DAIT_ConRole'); 
            NavatarCommonUtilityCtrl.executequery(jsn,'MI'); 
            NavatarCommonUtilityCtrl.executequery(jsn,'DAIT'); 
            NavatarCommonUtilityCtrl.executequery(jsn,'DAIT_AccContactTab'); 
            NavatarCommonUtilityCtrl.executequery(jsn,'MEP'); 
            
            jsn = '[{"serialnumber":1,"field":"Fundraising:Next_Step__c:Next Step:string","Value":"","Operator":"="},{"serialnumber":2,"field":"Fundraising:Next_Step__c:Next Step:string","Value":"","Operator":"="},{"serialnumber":3,"field":"Fundraising:Next_Step__c:Next Step:string","Value":"","Operator":"="},{"serialnumber":4,"field":"Fundraising:Next_Step__c:Next Step:string","Value":"","Operator":"="},{"serialnumber":5,"field":"Fundraising:Next_Step__c:Next Step:string","Value":"","Operator":"="},{"serialnumber":6,"field":"Fundraising:Next_Step__c:Next Step:string","Value":"","Operator":"="},{"serialnumber":7,"field":"Fundraising:Next_Step__c:Next Step:string","Value":"","Operator":"="},{"serialnumber":8,"field":"Fundraising:Next_Step__c:Next Step:string","Value":"","Operator":"="},{"serialnumber":9,"field":"Fundraising:Next_Step__c:Next Step:string","Value":"","Operator":"="},{"serialnumber":10,"field":"Fundraising:Next_Step__c:Next Step:string","Value":"","Operator":"="}]';
            NavatarCommonUtilityCtrl.executequery(jsn,'CMF');
            NavatarCommonUtilityCtrl.executequery(jsn,'MEF'); 
            
            NavatarCommonUtilityCtrl.executequery(jsn,'DAIT_ConRole'); 
            NavatarCommonUtilityCtrl.executequery(jsn,'MI'); 
            NavatarCommonUtilityCtrl.executequery(jsn,'DAIT'); 
            NavatarCommonUtilityCtrl.executequery(jsn,'DAIT_AccContactTab'); 
            NavatarCommonUtilityCtrl.executequery(jsn,'MEP'); 
            
            jsn = '[{"serialnumber":1,"field":"Contact:Department:Department:string","Value":"","Operator":"="},{"serialnumber":2,"field":"Contact:Department:Department:string","Value":"","Operator":"="},{"serialnumber":3,"field":"Contact:Department:Department:string","Value":"","Operator":"="},{"serialnumber":4,"field":"Contact:Department:Department:string","Value":"","Operator":"="},{"serialnumber":5,"field":"Contact:Department:Department:string","Value":"","Operator":"="},{"serialnumber":6,"field":"Contact:Department:Department:string","Value":"","Operator":"="},{"serialnumber":7,"field":"Contact:Department:Department:string","Value":"","Operator":"="},{"serialnumber":8,"field":"Contact:Department:Department:string","Value":"","Operator":"="},{"serialnumber":9,"field":"Contact:Department:Department:string","Value":"","Operator":"="},{"serialnumber":10,"field":"Contact:Department:Department:string","Value":"","Operator":"="}]';
            NavatarCommonUtilityCtrl.executequery(jsn,'MEF');            
            
            NavatarCommonUtilityCtrl.executequery(jsn,'DAIT_ConRole'); 
            NavatarCommonUtilityCtrl.executequery(jsn,'MI'); 
            NavatarCommonUtilityCtrl.executequery(jsn,'DAIT'); 
            NavatarCommonUtilityCtrl.executequery(jsn,'DAIT_AccContactTab'); 
            NavatarCommonUtilityCtrl.executequery(jsn,'MEP'); 
        
            jsn = '[{"serialnumber":1,"field":"Fundraising Contact:Name:Fundraising Contact ID:string","Value":"","Operator":"="},{"serialnumber":2,"field":"Fundraising Contact:Name:Fundraising Contact ID:string","Value":"","Operator":"="},{"serialnumber":3,"field":"Fundraising Contact:Name:Fundraising Contact ID:string","Value":"","Operator":"="},{"serialnumber":4,"field":"Fundraising Contact:Name:Fundraising Contact ID:string","Value":"","Operator":"="},{"serialnumber":5,"field":"Fundraising Contact:Name:Fundraising Contact ID:string","Value":"","Operator":"="},{"serialnumber":6,"field":"Fundraising Contact:Name:Fundraising Contact ID:string","Value":"","Operator":"="},{"serialnumber":7,"field":"Fundraising Contact:Name:Fundraising Contact ID:string","Value":"","Operator":"="},{"serialnumber":8,"field":"Fundraising Contact:Name:Fundraising Contact ID:string","Value":"","Operator":"="},{"serialnumber":9,"field":"Fundraising Contact:Name:Fundraising Contact ID:string","Value":"","Operator":"="},{"serialnumber":10,"field":"Fundraising Contact:Name:Fundraising Contact ID:string","Value":"","Operator":"="}]';
            NavatarCommonUtilityCtrl.executequery(jsn,'MEF');            
            
            NavatarCommonUtilityCtrl.executequery(jsn,'DAIT_ConRole'); 
            NavatarCommonUtilityCtrl.executequery(jsn,'MI'); 
            NavatarCommonUtilityCtrl.executequery(jsn,'DAIT'); 
            NavatarCommonUtilityCtrl.executequery(jsn,'DAIT_AccContactTab'); 
            NavatarCommonUtilityCtrl.executequery(jsn,'MEP'); 
        
            
            NavatarCommonUtilityCtrl.Specialchar('fhasdhfiwu*$*^%$^& adsfjaklsdjf');
            /*NavatarCommonUtilityCtrl.convertdatetime('10/14/2011 11:46 AM');
            NavatarCommonUtilityCtrl.convertdatetime('10/14/2011');*/
        
            NavatarCommonUtilityCtrl.convertdate('08/12/2012');
            NavatarCommonUtilityCtrl.convertdateGMT('08/12/2012');
            //NavatarCommonUtilityCtrl.convertdatetimeGMT('10/14/2011 11:46 AM');
        
        
        
        Account opacc1 = new Account(name='testSam1');
        Account opacc2 = new Account(name='testSam1');
        insert opacc1;
        insert opacc2;
        system.assertEquals(opacc1.name,'testSam1');
        NavatarFilterResultsCtrl TestController = new  NavatarFilterResultsCtrl();
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
    public static testMethod void testHub_FilterController22() 
    {
        test.startTest();
        
        NavatarFilterResultsCtrl clsObj = new NavatarFilterResultsCtrl();
        string testvalue='';
        clsObj.operatorOperation('Contact.Account.CreatedDate','DATETIME','=',testvalue,'en_US');
        clsObj.operatorOperation('Contact.Account.CreatedDate','DATETIME','!=',testvalue,'en_US');
        clsObj.operatorOperation('Contact.Account.CreatedDate','DATETIME','>',testvalue,'en_US');
        clsObj.operatorOperation('Contact.Account.CreatedDate','DATETIME','<',testvalue,'en_US');
        clsObj.operatorOperation('Contact.Account.CreatedDate','DATETIME','>=',testvalue,'en_US');
        clsObj.operatorOperation('Contact.Account.CreatedDate','DATETIME','<=',testvalue,'en_US');
        
        testvalue='2013-10-05 20:03:20';
        clsObj.operatorOperation('Contact.Account.CreatedDate','DATETIME','=',testvalue,'en_US');
        clsObj.operatorOperation('Contact.Account.CreatedDate','DATETIME','!=',testvalue,'en_US');
        clsObj.operatorOperation('Contact.Account.CreatedDate','DATETIME','>',testvalue,'en_US');
        clsObj.operatorOperation('Contact.Account.CreatedDate','DATETIME','<',testvalue,'en_US');
        clsObj.operatorOperation('Contact.Account.CreatedDate','DATETIME','>=',testvalue,'en_US');
        clsObj.operatorOperation('Contact.Account.CreatedDate','DATETIME','<=',testvalue,'en_US');
        
        testvalue='';
        clsObj.operatorOperation('Contact.Birthdate','DATE','=',testvalue,'en_US');
        clsObj.operatorOperation('Contact.Birthdate','DATE','!=',testvalue,'en_US');
        clsObj.operatorOperation('Contact.Birthdate','DATE','>',testvalue,'en_US');
        clsObj.operatorOperation('Contact.Birthdate','DATE','<',testvalue,'en_US');
        clsObj.operatorOperation('Contact.Birthdate','DATE','>=',testvalue,'en_US');
        clsObj.operatorOperation('Contact.Birthdate','DATE','<=',testvalue,'en_US');
        
        testvalue='2013-10-05 20:03:20';
        clsObj.operatorOperation('Contact.Birthdate','DATE','=',testvalue,'en_US');
        clsObj.operatorOperation('Contact.Birthdate','DATE','!=',testvalue,'en_US');
        clsObj.operatorOperation('Contact.Birthdate','DATE','>',testvalue,'en_US');
        clsObj.operatorOperation('Contact.Birthdate','DATE','<',testvalue,'en_US');
        clsObj.operatorOperation('Contact.Birthdate','DATE','>=',testvalue,'en_US');
        clsObj.operatorOperation('Contact.Birthdate','DATE','<=',testvalue,'en_US');
        
         testvalue=' ,test@test.com';
         clsObj.operatorOperation('Contact.Email','EMAIL','doesnotcontain',testvalue,'');
         clsObj.operatorOperation('Contact.Client_Review_Frequency__c','PICKLIST','doesnotcontain',testvalue,'');
        clsObj.operatorOperation('Contact.Email','EMAIL','>',testvalue,'');
        clsObj.operatorOperation('Contact.Email','EMAIL','<',testvalue,'');
        clsObj.operatorOperation('Contact.Email','EMAIL','>=',testvalue,'');
        system.assertEquals('testSam1','testSam1');
         test.stopTest();
    }
    public static testMethod void testHub() 
    {
        test.startTest();     
       // Datetime myDateTime = DateTime.parse('11/21/2014 15:20:00');
       // String dtConverted = myDateTime.format('MM/dd/yyyy HH:mm a');
      
        NavatarCommonUtilityCtrl.convertdate(String.valueOf(Date.today().format()));
        NavatarCommonUtilityCtrl.convertdateGMT(String.valueOf(Date.today().format()));
        NavatarCommonUtilityCtrl.convertdatetime(String.valueOf(System.now().format()));
        
        NavatarCommonUtilityCtrl.convertdatetimeGMT(String.valueOf(System.now().format()));
        system.assertEquals('testSam1','testSam1');
        test.stopTest();
    }
    
     public static testMethod void testHub_CATCH() 
    {           
      try 
      {
        system.assertEquals('testSam1','testSam1');  
        NavatarCommonUtilityCtrl.convertdate(''); 
        NavatarCommonUtilityCtrl.convertdatetime('');        
      }
      catch(exception e)
        {
         }
    }
}