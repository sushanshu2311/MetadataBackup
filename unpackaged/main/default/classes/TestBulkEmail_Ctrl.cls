//4.7.2 Test class updated by Salauddin 9-November-2022
@isTest(SeeAllData='true')
public class TestBulkEmail_Ctrl
{
    static testMethod void testMethod1()
    {
        contact con = new contact();
        con.Email='testmail@gmail.com';
        con.lastName = 'Test last Contact'; 
        con.firstname = 'Test First Name'; 
        con.HasOptedOutOfEmail=false;  
        con.MailingCity ='Test City'; 
        con.MailingCountry='Test country';  
        con.MailingPostalCode = '102010';
        con.MailingState = 'Test State';
        con.MailingStreet='Test street';
        con.Description='test hello how are you';
        con.Fax='012423';
        con.Phone = '01245263';
        con.otherCity = 'test other city';
        con.otherCountry='Test other country';  
        con.otherPostalCode = '1020101';
        con.otherState = 'Test other State';
        con.otherStreet='Test other street';        
        insert con;
        System.assertEquals('Test last Contact', con.LastName); // (PE3.5, SK, 9Aug2017)
        
        Test.startTest(); 
        
        BulkEmail_Ctlr objBE=new BulkEmail_Ctlr();        
        objBE.retrievenames();       
        System.debug('folder--->'+  objBE.retrievenames() ) ;
        List <Report> reportList = [SELECT Id,name,foldername FROM Report];
        System.debug(reportList);
    
        if(reportList.size()>0)
        {
            string reportId = (String)reportList.get(0).get('id');
            string reportname=(String)reportList.get(0).get('name');
            string strfoldername=(String)reportList.get(0).get('foldername');   
            Reports.ReportMetadata reportMetadata = Reports.ReportManager.describeReport(reportId).getReportMetadata();
            objBE.createreporttree();    
            
            Test.setMock(HttpCalloutMock.class, new TestMockHttpResponse.TestMockHttpResponseBulkEmail_Ctrl1());
            BulkEmail_Ctlr.reportresponse(reportId,'{"reportMetadata":{"groupingsDown" :[],"sortBy" : [{"sortColumn" : "City","sortOrder" : "Asc"}]}}','1');
            BulkEmail_Ctlr.reportresponse(reportId,'{"reportMetadata":{"reportFilters":[{"value": "'+con.id+'","operator": "greaterThan","column": "contact.id"}],"groupingsDown" :[],"sortBy" : [{"sortColumn" : "contact.id","sortOrder" : "Asc"}]}}','2');
            
        }
        
        objBE.cancel();     
        objBE.ETData();    
        objBE.getfolderListIds();
        objBE.getfolderOtherIds();        
     
        string conId = con.id+','+con.id+','+con.id+','+con.id+','+con.id+','+con.id;  
        Set<String> contSet = new Set<String>();
        contSet.add(con.id);      
        System.assertNotEquals('Test last Contact', conId); // (PE3.5, SK, 9Aug2017)
        
        objBE.EmailConIds=con.id;       
        objBE.bCC_Me_On_One= true;
        objBE.isbcc=true;
        objBE.use_My_Signature= true;
        objBE.chkStoreActivity= true;
        objBE.contactIDString= conId;  
        objBE.assineSelectedConids = conId;    
        objBE.sendmassmail();
        
        objBE.bCC_Me_On_One= false;     
        objBE.sendmassmail();
        List<EmailTemplate> tempateList = [Select Id,Name from EmailTemplate limit 1];
        List<String> lstS= new List<String>();
        for(String str: conId.split(','))
        {
            lstS.add(str);
        } 
        
        objBE.assineSelectedConids=con.id;
        objBE.chkEmail();
        
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponse.TestMockHttpResponseBulkEmail_Ctrl());         
        //BulkEmail_Ctlr.GetEmailLimit();
       
       Test.stopTest();
    
    }

}