@istest
public class TestMyRestResource
{
    
     static testMethod void  test_MyRestResource()
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
         Test.startTest();
             //As Per Best Practice it is important to instantiate the Rest Context
             RestRequest req = new RestRequest();
             RestResponse res = new RestResponse();
                
             req.requestURI = '/services/apexrest/DemoUrl';  //Request URL
             req.httpMethod = 'POST';//HTTP Request Type
            
             RestContext.request = req;
             RestContext.response= res;
             
             MyRestResource resp =new MyRestResource();
             MyRestResource.doPost(); //Call the Method of the Class with Proper       Constructor
             MyRestResource.doGet();
         Test.stopTest();
     }
}