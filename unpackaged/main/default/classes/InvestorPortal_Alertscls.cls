/*  Added Functionality:
    Developer               :   Arjun,Shadab Hussain
    Product Version         :   PE 2.6
    Date of Creation        :   11/25/2013
    Date of Last Update     :   09/17/2014
    Last Updated By         :   Shadab Hussain
    Purpose of Creation     :   Listed below:
                           1.This class is used to redirect user from PE to IP's PE_alerts page which is used to show Activities realted to investors on Home page  .
                             2. This page passes following parameters in Url to IP Side
                                i)Contact Id
                               ii)Organisation's Id
*/

public with sharing class InvestorPortal_Alertscls 
{
    public String session { get; set; }         // to store session Id
    public String url { get; set; }              // to store Url 
    public string orgid{get; set;}                // to store Organisations Id
    public string passhost{get; set;}             // to store host address from URL
    public string error{get;set;}                 // to show error message on page as per value 
    public string LoginUserProfile{get;set;}       //to store Login User Email Id
      
     /* To get the logged In User's detail and pass it to IP Org. Passing Parameters : Session Id and Org Id*/
    public InvestorPortal_Alertscls() 
    {
        error='true';
        session = userinfo.getsessionid();   //Getting Loggedin User's Session Id
        orgid = UserInfo.getOrganizationId();
        //passhost = ApexPages.currentPage().getHeaders().get('Host');
        passhost = CommonUtility.strServerURL(); //fixing for domain name - Sheetal Dagar
        
        
         
        //Querying Users Details        
        List<User> u = new List<User>();
        
        if(Schema.sObjectType.User.isAccessible() && Schema.sObjectType.User.Fields.Authenticate_to_use_investor_portal__c.isAccessible() && 
            Schema.sObjectType.User.Fields.Investor_Portal_Authentication__c.isAccessible() && Schema.sObjectType.User.Fields.firstName.isAccessible() && Schema.sObjectType.User.Fields.Lastname.isAccessible() &&  Schema.sObjectType.User.Fields.Email.isAccessible() && Schema.sObjectType.Profile.isAccessible() && Schema.sObjectType.Profile.Fields.Name.isAccessible()){
            u = [SELECT Id, firstName, Lastname ,Email , Authenticate_to_use_investor_portal__c,Investor_Portal_Authentication__c, Profile.Name FROM User WHERE Id=:userinfo.getUserId() LIMIT 1];
        }
        
        if(u.size() > 0)
        {
            if(u[0].Profile.Name=='System Administrator')        
                LoginUserProfile='Admin';
            else
                LoginUserProfile='User';
            
            if(((u[0].Investor_Portal_Authentication__c == true) && (u[0].Authenticate_to_use_investor_portal__c == true)) || ((u[0].Investor_Portal_Authentication__c == true) && (u[0].Profile.Name == 'System Administrator')))
            error = 'false';
            else if(((u[0].Investor_Portal_Authentication__c == false) && (u[0].Authenticate_to_use_investor_portal__c == true)))
            error = 'msg';        
        }
    }

}