/*   Added Functionality:
    Developer               :   Shadab Hussain
    Product Version         :   PE 2.6
    Date of Creation        :   10/23/2013
    Date of Last Update     :   09/17/2014
    Last Updated By         :   Shadab Hussain
    Purpose of Creation     :   Listed below:
                             1.This class is used to redirect user from PE to IP's PE_Contact_Enabled page which is used to show workspaces on Contact Detail page  .
                             2. This page passes following parameters in Url to IP Side
                                i)Contact Id
                               ii)Session Id 
                              iii)AccountId
*/
public with sharing class Investor_Portal_Contact_Enabled_cls {

    private final Contact tempFund;        // instance to hold current record details
    public string foraccountid{get;set;}    // to store related account Id
    public String session { get; set; }      // to store session ID
    public String url { get; set; }           // to store  URL
    public string orgid{get; set;}            // to store Organization's Id 
    public string passhost{get; set;}          // to store host address from URL
    public string error{get;set;}             // to show error message on page as per value 
    public string conid {get; set;}           // to store contact Id
    
     /* To get the Contact record Id from URL and get its detail and pass it to IP Org. Passing Parameters : contact Id,Session Id and AccountId*/ 
    public Investor_Portal_Contact_Enabled_cls(ApexPages.StandardController controller) 
    {
        
        session = userinfo.getsessionid();   //Getting Loggedin User's Session Id
        error = 'true';
        session = EncodingUtil.urlEncode(session, 'UTF-8');  
        orgid = UserInfo.getOrganizationId();
        orgid = EncodingUtil.urlEncode(orgid, 'UTF-8');
        //passhost = ApexPages.currentPage().getHeaders().get('Host');
        passhost=CommonUtility.strServerURL(); //fixing for domain name - Sheetal Dagar          
        this.tempfund = (Contact)controller.getRecord();
        
        // SK: 7Dec2017
        Contact con2 = new Contact();
        if(Schema.sObjectType.Contact.isAccessible() && Schema.sObjectType.Account.isAccessible()  && Schema.sObjectType.Account.fields.Name.isAccessible()&& Schema.sObjectType.Contact.Fields.Email.isAccessible() && Schema.sObjectType.Contact.Fields.AccountId.isAccessible())
        {
            con2 = [select id, Account.Name,email, AccountId From Contact Where id=:tempfund.id];
        }
        
        conid = con2.id;
        foraccountid = con2.AccountId;
        
         //Getting Users Details
        List<User> u = new List<User>();
        if(Schema.sObjectType.User.isAccessible() && Schema.sObjectType.User.Fields.Authenticate_to_use_investor_portal__c.isAccessible() && 
            Schema.sObjectType.User.Fields.Investor_Portal_Authentication__c.isAccessible() && Schema.sObjectType.User.Fields.firstName.isAccessible() && Schema.sObjectType.User.Fields.Lastname.isAccessible() && Schema.sObjectType.User.Fields.Email.isAccessible() && Schema.sObjectType.Profile.isAccessible() && Schema.sObjectType.Profile.Fields.Name.isAccessible()){
            u = [SELECT Id, firstName, Lastname ,Email , Authenticate_to_use_investor_portal__c,Investor_Portal_Authentication__c, Profile.Name FROM User WHERE Id=:userinfo.getUserId() LIMIT 1];
        }
        
        if(u.size()>0)
        {
            if(con2.email=='' || con2.email==null)
            error = 'noemail'; 
            else if(((u[0].Investor_Portal_Authentication__c == true) && (u[0].Authenticate_to_use_investor_portal__c == true)) || ((u[0].Investor_Portal_Authentication__c == true) && (u[0].Profile.Name == 'System Administrator')))
            error = 'false'; 
            else if(((u[0].Investor_Portal_Authentication__c == false) && (u[0].Authenticate_to_use_investor_portal__c == true)))
            error = 'msg';
         }   
    }

}