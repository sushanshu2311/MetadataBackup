/*  Added Functionality:
    Developer               :   Lalit Rautela,Faiz Ahmed
    Product Version         :   PE 2.6
    Date of Creation        :   12/16/2013
    Date of Last Update     :   06/12/2015
    Last Updated By         :   Sameer Rath
    Purpose of Creation     :   Listed below:
          1.This class is used to redirect user from PE to IP's PE_10_Fund_NothingEnabled page which is used to build and show workspaces on Fund Detail page  .
                             2. This page passes following parameters in Url to IP Side
                                i)Fund Id
                               ii)Session Id 
                              iii)Fund Type
*/

public with sharing class clsPEFundNothingEnabled 
{
    public string sessionID{get; set;}          //to pass session id to IP
    public string hostname{get; set;}           //to pass PE hostname to IP
    public string fundid{get; set;}             //to pass current fund id to IP
    public string fundname{get; set;}           //to pass current fund name to IP
    public string fundtype{get; set;}           //to pass current fund name type
    public string orgid{get; set;}              //to pass current user org id to IP
    public string isAuthorized{get; set;}        // we provide access to user using this variable
    public string useremail{get; set;}           // to store users email id
    public string workspace{get; set;}
    private final Fund__c tempFund;       // instance to hold current record details
    public string pageUrl{get; set;}                // to store the redirect URL
    public string error{get;set;}                // to show error message on page as per value 
    /* To get the fund record id from URL and get its detail and pass it to IP Org. Passing Parameters : Fund Id,Session Id and Fund type*/
    public clsPEFundNothingEnabled (ApexPages.StandardController controller)
    {
                fundname='';       
                error = 'true';       
                hostname='';
                sessionID='';
                fundid='';
                orgid='';
                workspace='';  
                sessionID = UserInfo.getSessionId();  //Getting Loggedin User's Session Id
                // hostname = ApexPages.currentPage().getHeaders().get('Host');             // getting url 
                hostname=CommonUtility.strServerURL(); //fixing for domain name - Sheetal Dagar 
                
                this.tempfund = (Fund__c)controller.getRecord();               //getting current records detail
                fundid = tempfund.id;
                
                //Querying Fund's Details                
                List<Fund__c> fundLst = new List<Fund__c>();
                if(Schema.sObjectType.Fund__c.isAccessible() && Schema.sObjectType.Fund__c.fields.name.isAccessible() && Schema.sObjectType.Fund__c.fields.Investment_Category__c.isAccessible()){
                    fundLst = [select id,name, Investment_Category__c from Fund__c where id=: fundid Limit 1];
                }
                
                if(fundLst.size()>0)
                {
                    fundid = fundLst[0].id;    
                    //fundname= fundLst[0].name;
                    fundname='TestFund';
                    fundtype = fundLst[0].Investment_Category__c;
                    
                }
                orgid = UserInfo.getOrganizationId();
                
                //Querying Users Details
                List<User> user = new list<User>();
                if(Schema.sObjectType.user.isAccessible() && Schema.sObjectType.user.fields.Authenticate_to_use_investor_portal__c.isAccessible() && Schema.sObjectType.user.fields.Investor_Portal_Authentication__c.isAccessible() && Schema.sObjectType.Profile.isAccessible() && Schema.sObjectType.Profile.fields.name.isAccessible())
                    user = [select Authenticate_to_use_investor_portal__c,Investor_Portal_Authentication__c, Profile.Name from User where id=: UserInfo.getUserId() Limit 1];
                if(user.size()>0)
                {
                    if(((user[0].Investor_Portal_Authentication__c == true) && (user[0].Authenticate_to_use_investor_portal__c == true)) || ((user[0].Investor_Portal_Authentication__c == true) && (user[0].Profile.Name == 'System Administrator')))
                    isAuthorized = 'authorized';
                    else
                    isAuthorized = 'unauthorized';
                }

                fundname = fundname.replace('\'','@').replace('&','@').replace('#','@').replace('"','@').replace('>','@').replace('<','@').replace('%','@').replace(',','@');
                
                string param1 = sessionID+'_@_'+hostname+'_@_'+fundid;
                

                param1 = EncodingUtil.urlEncode(param1, 'UTF-8');
                
                //fundname = fundname.replace(' ','%2B');
                
                // removing space because it is creating problem in gateway page of IP.
                fundname = fundname.replace(' ','');
                
                string param3 = orgid+'_@_'+isAuthorized+'_@_'+fundtype;
                
              
                param3 = EncodingUtil.urlEncode(param3, 'UTF-8');
                
                string finalParams = param1+'_@_'+fundname+'_@_'+param3;
                
                pageUrl = '/apex/PE_10_Fund_NothingEnabled?sessionid='+finalParams;   // passing all parameter in URL
                
                 //Querying Users Details
                 List<User> u = new list<User>();
                if(Schema.sObjectType.user.isAccessible() && Schema.sObjectType.user.fields.Authenticate_to_use_investor_portal__c.isAccessible() && Schema.sObjectType.user.fields.Investor_Portal_Authentication__c.isAccessible() && Schema.sObjectType.user.fields.firstName.isAccessible() && Schema.sObjectType.user.fields.Lastname.isAccessible() && Schema.sObjectType.user.fields.Email.isAccessible() && Schema.sObjectType.Profile.isAccessible() && Schema.sObjectType.Profile.fields.name.isAccessible())
                    u = [SELECT Id, firstName, Lastname ,Email , Authenticate_to_use_investor_portal__c,Investor_Portal_Authentication__c, Profile.Name FROM User WHERE Id=:userinfo.getUserId() LIMIT 1];
                if(u.size()>0)
                {
                // IP V1.8 Remove Co-Investment restriction
                // if(fundtype == 'Co-investment')
                //error = 'Co-investment';
                    if(((u[0].Investor_Portal_Authentication__c == true) && (u[0].Authenticate_to_use_investor_portal__c == true)) || ((u[0].Investor_Portal_Authentication__c == true) && (u[0].Profile.Name == 'System Administrator')))
                    error = 'false';  
                    else if(((u[0].Investor_Portal_Authentication__c == false) && (u[0].Authenticate_to_use_investor_portal__c == true)))
                    error = 'msg';
                } 
    }

}