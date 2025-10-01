@istest
public class TestPeUserValidation
{
    
     static testMethod void  test_PeUserValidation()
     {
      
         Account acc=new Account();
         acc.name='Test';
         acc.AccountNumber='1232332';
         acc.Site='site';
         acc.Website='cloudyworlds.blogspot.in';
         insert acc;
         System.assertEquals('Test', acc.Name); // (PE3.5, SK, 9Aug2017)
         System.assertEquals('cloudyworlds.blogspot.in', acc.Website); // (PE3.5, SK, 9Aug2017)
         
         String reqst = acc.id;
         //String JsonMsg=JSON.serialize(reqst);
      
         Test.startTest();
            //As Per Best Practice it is important to instantiate the Rest Context
            RestRequest req = new RestRequest();
            RestResponse res = new RestResponse();
            
            req.requestURI = '/services/apexrest/DemoUrl';  //Request URL
            req.httpMethod = 'POST';//HTTP Request Type
            RestContext.request = req;
            RestContext.response= res;
            
            PeUserValidation resp =new PeUserValidation();
            PeUserValidation.doPost(); //Call the Method of the Class with Proper       Constructor
            PeUserValidation.doGet();
        Test.stopTest();
    }
}