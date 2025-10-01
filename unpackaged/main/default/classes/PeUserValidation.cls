/*  Added Functionality:
    Developer               :   Bhanu Pratap
    Product Version         :   PE 2.6
    Date of Creation        :   5/26/2014
    Date of Last Update     :   09/17/2014
    Last Updated By         :   Shadab Hussain
    Purpose of Creation     :   Listed below:
                                    1. Using REST Resource for authentication Investor Portal's access to users
*/
 
// Webservice name UserDetail methods Post and Get

@RestResource(urlMapping='/Userdetail/*')
    global with sharing class PeUserValidation 
    {
        // updates user's Authenticatetouseinvestorportal field of selected user's
        @HttpPost
        global static void doPost() 
        {
            RestRequest req = RestContext.request;
            RestResponse res = RestContext.response;
            String accountId = req.requestURI.substring(req.requestURI.lastIndexOf('/')+1);
            List<string> ids = new List<string>();
            ids = accountId.split(',');
            List<user> uu =[select id from user where id in:ids]; // giving access of investorportal to the users 
            
            for(integer i=0; i<uu.size(); i++){
            	if(Schema.sObjectType.User.fields.Authenticate_to_use_investor_portal__c.isUpdateable()){
            		uu[i].Authenticate_to_use_investor_portal__c = true;
            	}
            }
            
            if(Schema.sObjectType.User.isUpdateable()){
            	update uu;
            }
            
            List<user> uu2 =[select id from user where id not in:ids and profile.name = 'PE Standard User']; // Revoking access for other users inactive
            
            for(integer i=0; i<uu2.size(); i++){
            	if(Schema.sObjectType.User.fields.Authenticate_to_use_investor_portal__c.isUpdateable()){
            		uu2[i].Authenticate_to_use_investor_portal__c = false;
            	}
            }
            
            if(Schema.sObjectType.User.isUpdateable()){
            	update uu2;
            }
        }
      
        // return the current logged in user id from session id
        @HttpGet
        global static string doGet() 
        {   
            return Userinfo.getUserId();
        }
    }