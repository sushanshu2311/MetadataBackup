/*  Added Functionality:
    Developer               :   Arjun, Shadab Hussain
    Product Version         :   PE 2.6
    Date of Creation        :   10/24/2013
    Date of Last Update     :   09/17/2014
    Last Updated By         :   Shadab Hussain
    Purpose of Creation     :   Listed below:
                            1.This class is used to redirect user from PE to IP's PE_Commitment_Enabled page which is used to show realted workspace on Commitment Detail page  .
                             2. This page passes following parameters in Url to IP Side
                                i)fund Id,Session Id and account Id, recordtype name
                               ii)Session Id 
                              iii)AccountId
                               iv)Recordtype name
*/

public with sharing class Investor_Portal_Commitment_Enabled_cls {

    private final Commitment__c tempFund;     // instance to hold current record details
    public string fundid{get;set;}                     // to store realted fund id
    public string fundtype{get;set;}                    // to store realted fund type
    public string IFrameURL{get;set;}                    // to store  iframe redirect url 
    public String SERVER_URL { get; set; }               // to store URL
    public String session { get; set; }                 // to store session ID
    public String url { get; set; }                      // to hold url of page
    public string orgid{get; set;}                        // to store Organizations Id
    public string passhost{get; set;}                     // to store host address from URL
    public string accountid{get; set;}                   // to store related account Id
    public string accountname{get; set;}                 // to store related account name
    public string error{get;set;}                        // to show error message on page as per value 
    public string recordtypename {get; set;}              // to store related account's record type name
    
     /* To get the Commitment record id from URL and get its detail and pass it to IP Org. Passing Parameters : fund Id,Session Id and account Id, recordtype name*/
    public Investor_Portal_Commitment_Enabled_cls(ApexPages.StandardController controller) 
    {
        error='true';
        session = userinfo.getsessionid();
        orgid = UserInfo.getOrganizationId();
        //passhost = ApexPages.currentPage().getHeaders().get('Host');      //Getting Loggedin User's Session Id  
        passhost=CommonUtility.strServerURL(); //fixing for domain name - Sheetal Dagar
         
        this.tempfund = (Commitment__c)controller.getRecord();
        
        // SK: 7Dec2017
        Commitment__c con2 = new Commitment__c();
        if(Schema.sObjectType.Commitment__c.isAccessible() && Schema.sObjectType.RecordType.isAccessible() && Schema.sObjectType.RecordType.fields.Name.isAccessible() && Schema.sObjectType.Account.fields.Name.isAccessible() && Schema.sObjectType.Partnership__c.isAccessible() && Schema.sObjectType.Commitment__c.Fields.Limited_Partner__c.isAccessible() && Schema.sObjectType.Commitment__c.Fields.Partnership__c.isAccessible() && Schema.sObjectType.Partnership__c.Fields.Fund__c.isAccessible() && Schema.sObjectType.Fund__c.Fields.Investment_Category__c.isAccessible()){
            con2 = [Select id,Limited_Partner__c, Limited_Partner__r.recordtype.name, Limited_Partner__r.Name, 
                        Partnership__r.Fund__c, Partnership__r.Fund__r.Investment_Category__c 
                        From commitment__c Where id =:tempfund.id];
        }
        
        fundtype=con2.Partnership__r.Fund__r.Investment_Category__c;
        fundid = con2.Partnership__r.Fund__c;
        accountname = con2.Limited_Partner__r.Name;
        accountid = con2.Limited_Partner__c;
        recordtypename = con2.Limited_Partner__r.recordtype.name;
        if(recordtypename.tolowercase() == 'Limited Partner'.tolowercase())
        recordtypename='LP';
        else
        recordtypename='Institution';
        
         //Querying Users Details        
         List<User> u = new List<User>();
         if(Schema.sObjectType.User.isAccessible() && Schema.sObjectType.User.Fields.Authenticate_to_use_investor_portal__c.isAccessible() && Schema.sObjectType.User.Fields.Investor_Portal_Authentication__c.isAccessible() && Schema.sObjectType.User.Fields.firstName.isAccessible() && Schema.sObjectType.User.Fields.Lastname.isAccessible() && Schema.sObjectType.User.Fields.Email.isAccessible() && Schema.sObjectType.Profile.isAccessible() && Schema.sObjectType.Profile.Fields.Name.isAccessible()){
             u = [SELECT Id, firstName, Lastname ,Email , Authenticate_to_use_investor_portal__c,Investor_Portal_Authentication__c, Profile.Name FROM User WHERE Id=:userinfo.getUserId() LIMIT 1];
         }
         
         if(u.size()>0)
         {
             // IP V1.8 Remove Co-Investment restriction
             //if(fundtype == 'Co-investment')
             // error = 'Co-investment'; 
                if(((u[0].Investor_Portal_Authentication__c == true) && (u[0].Authenticate_to_use_investor_portal__c == true)) || ((u[0].Investor_Portal_Authentication__c == true) && (u[0].Profile.Name == 'System Administrator')))
                error = 'false';  
                else if(((u[0].Investor_Portal_Authentication__c == false) && (u[0].Authenticate_to_use_investor_portal__c == true)))
                error = 'msg';
         }
    }

}