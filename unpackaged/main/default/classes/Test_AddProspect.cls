@isTest (SeeAllData='true')
public class Test_AddProspect
{
    public static testMethod void testAPController() 
    {
        
        Marketing_Initiative__c dummyMI=new Marketing_Initiative__c(Name='MI1 test');
        insert dummyMI;
        System.assertEquals('MI1 test', dummyMI.Name); // (PE3.5, SK, 8Aug2017)
        
        Date endDate = Date.parse('12/16/15');
        String strRecordTypeId = [Select Id From RecordType Where SobjectType = 'Account' and Name = 'company'].Id;
        
        ApexPages.currentPage().getParameters().put('MIID',dummyMI.Id);
        list<Marketing_Initiative__c > lstMI=new List<Marketing_Initiative__c >();
        lstMI.add([Select id,name from Marketing_Initiative__c where id=:dummyMI.Id]);       
        //contact c1=new contact(firstname='vivek',lastname='singh',Fax='12345',Phone='786',MailingCity='nainital',MailingCountry='vik',MailingPostalCode='234567',MailingState='uk',MailingStreet='naya',Description='hello',OtherCity='kanpur',OtherCountry='uks',OtherPostalCode='784',OtherState='asam',OtherStreet='sam');
        // insert c1;
        
        contact con = new contact();
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
        System.assertEquals('test hello how are you', con.Description); // (PE3.5, SK, 8Aug2017)
        
        Profile p=[select id from Profile where Name='System Administrator' Limit 1];
        User us2=new User(UserName='VP@nav.dev1',IsActive=true,LastName='Raj',Email='aj1234@nav.com',Alias='AAgni',TimeZoneSidKey='America/Los_Angeles',LocaleSidKey='en_US',EmailEncodingKey='ISO-8859-1',LanguageLocaleKey='en_US');
        us2.ProfileId=p.id;
        insert us2; 
        
        //System.runAs(us2)
        //{
            test.startTest();
            AddProspect_Ctlr addprosp=new AddProspect_Ctlr(new ApexPages.StandardController(dummyMI));
            addprosp.strCurrencySystembol='usd';
            //addprosp.localeString='Eng';
            //addprosp.locale_info='EN-US';   
            addprosp.namspace='navpeII_dev18';
            addprosp.isCurrency=true;
            addprosp.proptxtdata='return';
            addprosp.errorval='reuw';
            addprosp.propId=dummyMI.id;
            addprosp.getAPID=con.id;
            addprosp.Back();  
            Marketing_Prospect__c objlookup1 =  new Marketing_Prospect__c(Marketing_Initiative__c=dummyMI.id,Contact__c=con.id);
            insert objlookup1; 
            System.assertNotEquals('testing recordHello', objlookup1.Name); // (PE3.5, SK, 8Aug2017)
            
            List <Report> reportList = [SELECT Id,FolderName,Name,DeveloperName FROM Report];
            
            if(reportList.size()>0){
                String reportId = (String)reportList.get(0).get('Id');
                string reportname=(String)reportList.get(0).get('Name');
                addprosp.addprospectmethod(); 
                
                Reports.ReportMetadata reportMetadata = Reports.ReportManager.describeReport(reportId).getReportMetadata();
                addprosp.createreporttree();    
                addprosp.retrievenames();
                // Test.setMock(HttpCalloutMock.class, new MockHttpResponseAddpros());
                AddProspect_Ctlr.reportresponse(reportId,reportname,'{"ID",""}','2');
                AddProspect_Ctlr.reportresponse(reportId,reportname,'{"ID",""}','1');
                AddProspect_Ctlr.reportresponse(reportId,'repist','{"ID",""}','1');
                test.stopTest();
            }
      //  }
    }
    public static testMethod void testAPController2() 
    {
        Marketing_Initiative__c dummyMI=new Marketing_Initiative__c(Name='MI1 test');
        insert dummyMI;
        System.assertEquals('MI1 test', dummyMI.Name); // (PE3.5, SK, 8Aug2017)
        
        ApexPages.currentPage().getParameters().put('MIID',dummyMI.Id);
        list<Marketing_Initiative__c > lstMI=new List<Marketing_Initiative__c >();
        lstMI.add([Select id,name from Marketing_Initiative__c where id=:dummyMI.Id]);       
        //  contact c1=new contact(firstname='vivek',lastname='singh',Fax='12345');
        
        contact c1=new contact(firstname='vivek',lastname='singhh',Fax='12345',Phone='786',MailingCity='nainital',MailingCountry='vik',MailingPostalCode='234567',MailingState='uk',MailingStreet='naya1',Description='hello1',OtherCity='kanpur',OtherCountry='uks',OtherPostalCode='784',OtherState='asam',OtherStreet='sam');
        insert c1;
        System.assertEquals('hello1', c1.Description); // (PE3.5, SK, 8Aug2017)
        
        // contact c2=new contact(firstname='vivek',lastname='singhh',Fax='12345',Phone='786',MailingCity='nainital',MailingCountry='vik',MailingPostalCode='234567',MailingState='uk',MailingStreet='naya1',Description='hello1',OtherCity='kanpur',OtherCountry='uks',OtherPostalCode='784',OtherState='asam',OtherStreet='sam');
        //update c2;
        Marketing_Initiative__c dummyMI2=new Marketing_Initiative__c(Name='MI2 test');
        insert dummyMI2;
        System.assertNotEquals('hello1', dummyMI2.Name); // (PE3.5, SK, 8Aug2017)
        
        Profile p=[select id from Profile where Name='System Administrator' Limit 1];
        User us2=new User(UserName='VP@nav.dev1',IsActive=true,LastName='Raj',Email='aj1234@nav.com',Alias='AAgni',TimeZoneSidKey='America/Los_Angeles',LocaleSidKey='en_US',EmailEncodingKey='ISO-8859-1',LanguageLocaleKey='en_US');
        us2.ProfileId=p.id;
        insert us2; 
        System.assertEquals('VP@nav.dev1', us2.UserName); // (PE3.5, SK, 8Aug2017)
             
        //System.runAs(us2)
        //{
            AddProspect_Ctlr addprosp=new AddProspect_Ctlr(new ApexPages.StandardController(dummyMI));
            addprosp.strCurrencySystembol='usd';
            addprosp.localeString='Eng';
            //addprosp.locale_info='EN-US';   
            addprosp.namspace='navpeII_dev18';
            addprosp.isCurrency=true;
            addprosp.propId=dummyMI.id;
            addprosp.getAPID=c1.id;

            Marketing_Prospect__c objlookup2 = new Marketing_Prospect__c(Marketing_Initiative__c=dummyMI2.id,Contact__c=c1.id);
            insert objlookup2;          
            System.assertNotEquals('VP@nav.dev1', objlookup2.Name); // (PE3.5, SK, 8Aug2017)
            
            addprosp.addprospectmethod();
            addprosp.pageerror();
            addprosp.retrievenames();
            addprosp.createreporttree();
            addprosp.propId='';
            addprosp.addprospectmethod();
            addprosp.propId='adfsf';
            addprosp.Back();
            addprosp.propId=null;
            addprosp.createTrees='123';
            addprosp.pageerror();
            addprosp.Back();
        //}
    }
}