/*  Added Functionality:
    Developer               :   Lalit Rautela

    Product Version         :   PE 2.6
    Date of Creation        :   5/14/2014 
    Date of Last Update     :   09/17/2014     

    Purpose of Creation     :   Listed below:
                   1.For Managing CRM User Validation on Gateway Page (not in use now).
*/

@RestResource(urlMapping='/Users1/*')
global with sharing class MyRestResource {
  
  @HttpPost
    global static void doPost() {

      RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        String accountId = req.requestURI.substring(req.requestURI.lastIndexOf('/')+1);
         List<string> ids = new List<string>();
            ids = accountId.split(',');
           List<user> uu =[select id from user where id in:ids];    // getting user ids which matched records from Rest Response
           for(integer i=0; i<uu.size(); i++)
           {
               if(Schema.sObjectType.User.fields.Authenticate_to_use_investor_portal__c.isUpdateable()){
               		uu[i].Authenticate_to_use_investor_portal__c = true;
               }
           }
           
           if(Schema.sObjectType.User.isUpdateable()){
           		update uu;
           }
           
           List<user> uu2 =[select id from user where id not in:ids and profile.name = 'PE Standard User'];
           for(integer i=0; i<uu2.size(); i++)
           {
               if(Schema.sObjectType.User.fields.Authenticate_to_use_investor_portal__c.isUpdateable()){
               		uu2[i].Authenticate_to_use_investor_portal__c = false;
               }
           }
           
           if(Schema.sObjectType.User.isUpdateable()){
           		update uu2;
           }
    }
    
   // @HttpGet
    global static string doGet() 
    {
        return Userinfo.getUserId();
    }
    @HttpGet
    global static void doPost1() 
    {


    }
    



}