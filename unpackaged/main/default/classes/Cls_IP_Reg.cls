/*  Added Functionality:
    Developer               :   Ankit Goel
    Product Version         :   PE 2.6
    Date of Creation        :   08/06/2013
    Date of Last Update     :   09/17/2014
    Last Updated By         : Bhanu
    Purpose of Creation     :   Listed below:
                            1.This class is used to redirect user from PE to IP's PE_7_User_FirstLogin_1 page which is used to register PE User to Investor Portal.
                            2.This page passes following parameters in Url to IP Side
                                i)Organisation Id 
                               ii)Custom Url to redirect on PEWorkspaceManager page in IP after users registration 
                              iii)Profile of logged in User
                               iv)Authenticate 
                                v)Email of logged in User
                               vi)Seesion Id
                              vii)First name of logged in User
                             viii)Last name of logged in User
                               ix)User's ID
                          
                           
*/
 
                                    
 
public with sharing class Cls_IP_Reg 
{
    public string IFrameURL{get;set;}  
    public String SERVER_URL { get; set; } 
    public String session { get; set; }
    
    /* To get the Host Details from URL  and pass it to IP Org. 
    Passing Parameters : Organization Id,Session Id and and authorization variable to check for already registered user*/
    
    public Cls_IP_Reg()
    {
        session = userinfo.getsessionid();  //Getting Loggedin User's Session Id
        //SERVER_URL = ApexPages.currentPage().getHeaders().get('Host');
        SERVER_URL=CommonUtility.strServerURL(); //fixing for domain name - Sheetal Dagar 
       
        //Getting Users Details
        List<User> u = new List<User>();
        if(Schema.sObjectType.User.isAccessible() && Schema.sObjectType.User.fields.firstName.isAccessible() && Schema.sObjectType.User.fields.Lastname.isAccessible() && Schema.sObjectType.User.fields.Email.isAccessible() && Schema.sObjectType.User.fields.Authenticate_to_use_investor_portal__c.isAccessible() && Schema.sObjectType.User.fields.Investor_Portal_Authentication__c.isAccessible() && Schema.sObjectType.Profile.isAccessible() && Schema.sObjectType.Profile.fields.name.isAccessible())
            u = [SELECT Id, firstName, Lastname ,Email , Authenticate_to_use_investor_portal__c,Investor_Portal_Authentication__c, Profile.Name FROM User WHERE Id=:userinfo.getUserId() LIMIT 1];
        if(u.size()>0)
        {   
             // Redirct Url for Already resgistered Users
             
             if(((u[0].Investor_Portal_Authentication__c == true) && (u[0].Authenticate_to_use_investor_portal__c == true)) || ((u[0].Investor_Portal_Authentication__c == true) && (u[0].Profile.Name == 'System Administrator')))
            {
                String SERVERURL1 = '/apex/PEWorkspaceManager?sessionid='+session+'_@_'+SERVER_URL+'_@_'+userinfo.getOrganizationId()+'_@_authorized_@_noworkspace'; 
                IFrameURL=system.label.IP_Url+'apex/Gateway?startURL='+SERVERURL1;
            }
            else            // Redirct Url for New Users to Be registered
            {
                Boolean Authenticate = u[0].Authenticate_to_use_investor_portal__c;
                string Profile = u[0].Profile.Name;
                
                string email = u[0].Email;
                email = Encodingutil.urlEncode(email , 'UTF-8');
                string fname = u[0].firstName;
                string lname = u[0].LastName;
                if(fname == null)
                fname = '';
                fname = Encodingutil.urlEncode(fname , 'UTF-8');
                lname = Encodingutil.urlEncode(lname , 'UTF-8');
                IFrameURL=system.label.IP_Url+'PE_7_User_FirstLogin_1?orgid='+userinfo.getOrganizationId()+'&Profile='+Profile+'&SERVERURL='+SERVER_URL+'&Authenticate='+Authenticate+'&Email='+Email+'&session='+session+'&UserID='+u[0].id+'&Fname='+fname+'&Lname='+lname;//+'&sfdctabName='+sfdctabName;
            }
        }
        
    }
}