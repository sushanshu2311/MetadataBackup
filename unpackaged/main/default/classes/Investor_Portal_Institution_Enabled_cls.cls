/*  Added Functionality:
    Developer               :   Shadab Hussain
    Product Version         :   PE 2.6
    Date of Creation        :   09/24/2013
    Date of Last Update     :   09/17/2014
    Last Updated By         :   Shadab Hussain
    Purpose of Creation     :   Listed below:
                              1.This class is used to redirect user from PE to IP's PE_Institution_Enabled page which is used to show workspaces on Institution Detail page  .
                             2. This page passes following parameters in Url to IP Side
                                i)Account Id
                               ii)Session Id 
                              iii)Record Type
*/

public with sharing class Investor_Portal_Institution_Enabled_cls {

    private final Account tempFund;                // instance to hold current record details
    public string foraccountid{get;set;}           // to store related account Id  
    public string IFrameURL{get;set;}              // to store Iframe URL
    public String SERVER_URL { get; set; }          // to store redirect URL
    public String session { get; set; }            // to store session ID
    public String url { get; set; }                // to store URL
    public string orgid{get; set;}                // to store Organizations Id
    public string passhost{get; set;}              // to store host address from URL
    public string recordtypename {get; set;}       // to store related account's record type name
    
    public string error{get;set;}                   // to show error message on page as per value 
    /* To get the Account record id from URL and get its detail and pass it to IP Org. Passing Parameters : Account Id,Session Id and Record type*/
    public Investor_Portal_Institution_Enabled_cls(ApexPages.StandardController controller) 
    {
        error = 'true';
        session = userinfo.getsessionid();
        orgid = UserInfo.getOrganizationId();
        //passhost = ApexPages.currentPage().getHeaders().get('Host'); 
        passhost=CommonUtility.strServerURL(); //fixing for domain name - Sheetal Dagar          
        this.tempfund = (Account)controller.getRecord();
        foraccountid = tempfund.id;
        
        // SK: 7Dec2017
        Account acc2 = new Account();
        if(Schema.sObjectType.Account.isAccessible() && Schema.sObjectType.RecordType.isAccessible() && 
            Schema.sObjectType.Account.Fields.Name.isAccessible() &&  Schema.sObjectType.RecordType.Fields.Name.isAccessible())
        {
            acc2 = [select Name,Id,recordtype.name from Account where id=:tempfund.id];
        }
        
        recordtypename = acc2.recordtype.name;
        if(recordtypename.tolowercase() == 'Limited Partner'.tolowercase())
        recordtypename='LP';
        else
        recordtypename='Institution';
       
        List<User> u = new List<User>();
        if(Schema.sObjectType.User.isAccessible() && Schema.sObjectType.User.Fields.Authenticate_to_use_investor_portal__c.isAccessible() && 
            Schema.sObjectType.User.Fields.Investor_Portal_Authentication__c.isAccessible() && Schema.sObjectType.User.Fields.firstName.isAccessible() && Schema.sObjectType.User.Fields.Lastname.isAccessible() && Schema.sObjectType.User.Fields.Email.isAccessible() && Schema.sObjectType.Profile.isAccessible() && Schema.sObjectType.Profile.fields.Name.isAccessible()){
            u = [SELECT Id, firstName, Lastname ,Email , Authenticate_to_use_investor_portal__c,Investor_Portal_Authentication__c, Profile.Name FROM User WHERE Id=:userinfo.getUserId() LIMIT 1];
        }
        
        if(u.size()>0)
        {
            if(((u[0].Investor_Portal_Authentication__c == true) && (u[0].Authenticate_to_use_investor_portal__c == true)) || ((u[0].Investor_Portal_Authentication__c == true) && (u[0].Profile.Name == 'System Administrator')))
            error = 'false';        
            else if(((u[0].Investor_Portal_Authentication__c == false) && (u[0].Authenticate_to_use_investor_portal__c == true)))
            error = 'msg';
        }
    }

}