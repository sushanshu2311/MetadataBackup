/*************************************************
********************************
** Module Name : Bulk_Email_setup
** Description : This apex class is responsible for following things.
    1. Update the Bulk Email CheckBox in CMT.
** Throws : NA
** Calls : NA
** Test Class :  Not yet**
** Organization : Navatar Group
** Product Name & Version : PE 3.5
** Revision History:-
** Version Date         Author 
** 3.5     24/06/2016   Raghvendra 
*************************************************
********************************/

public with Sharing class Bulk_Email_Setup_Ctlr{
    public boolean strEnableCMTSetup{get;set;}              /*Handle Checkbox value on page. */ 
    public String strErrorMsg{get;set;}                     /*Show error message.*/
    public Org_Setting__mdt orgEmailSetting;                /*Org Setting of bulk email setting.*/  
    public boolean ODViewMode{get;set;}                     /*Enable Disable page value on this property basis. */ 
    public boolean isAdmin {get;set;}                       /*Holds admin access.*/ 
    public String strPageName{get;set;}                     /* Pagerefrence */

    /*
    @Description: Constructor.
    */
    public Bulk_Email_Setup_Ctlr()
    {
        try
        {   
            ODViewMode = true; 
            isAdmin = false;
            if(Schema.sObjectType.Org_Setting__mdt.isAccessible() && Schema.sObjectType.Org_Setting__mdt.fields.IsActive__c.isAccessible() && Schema.sObjectType.Org_Setting__mdt.fields.label.isAccessible() && Schema.sObjectType.Org_Setting__mdt.fields.developername.isAccessible()){
                orgEmailSetting = new Org_Setting__mdt();
                orgEmailSetting=[SELECT IsActive__c,label,developername FROM Org_Setting__mdt where developername ='Bulk_Email_Setting' limit 1];
                strEnableCMTSetup = orgEmailSetting.IsActive__c;
            }
        } 
        catch(Exception ex)
        {
             ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Exception in Bulk_Email_Setup_Ctlr : '+ex));
        }
    }
    
    /* Pagerefrence */
    
    public PageReference redirectpage() 
    {
        PageReference pageRef = new PageReference('/apex/'+strPageName+'');
        pageRef.setRedirect(true);
        return pageRef;
    }
    
    /*
    @Description: On Click of edit button, it grant access to user.
    */
    public void editBulkEmailSetup()
    { 
        try 
        {
            List<User> loggInUser = new List<User>();
            if(Schema.sObjectType.User.isAccessible() && Schema.sObjectType.profile.isAccessible() && Schema.sObjectType.profile.fields.name.isAccessible())          
                loggInUser = [ SELECT id, profile.name from User WHERE id=:userInfo.getUserId() LIMIT 1 ];
            if( loggInUser.size() > 0 && loggInUser[0].profile.name == 'System Administrator' )
            {
                isAdmin = true;
                ODViewMode = false; 
            }
        }
        catch (Exception ce) 
        {
             ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Exception in editBulkEmailSetup : '+ce));
        }
    }
    
    /*
    @Description: on save it updates Metadata Types.
    */
    public void onSaveBulkEmailSetup()
    { 
        try 
        {
            CustomMetadataService.updateMetadata(new List<SObject> {orgEmailSetting},strEnableCMTSetup);
            ODViewMode = true;
        }
        catch (Exception ce) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Exception in onSaveBulkEmailSetup : '+ce));
        }
    }
}