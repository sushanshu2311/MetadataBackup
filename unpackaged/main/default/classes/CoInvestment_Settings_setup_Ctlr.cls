/*************************************************
********************************
** Module Name : CoInvestment_Settings_setup
** Description : This apex class is responsible for following things.
    1. Update the org_setting in CMT.
    2. Update the fundId in Navatar_Setup.
** Throws : NA
** Calls : NA
** Test Class :  Not yet**
** Organization : Navatar Group
** Product Name & Version : PE 3.5
** Revision History:-
** Version Date         Author 
** 3.5     21/07/2016   Faiz Ahmed 
*************************************************
********************************/

public with Sharing class CoInvestment_Settings_setup_Ctlr
{
    public boolean strEnableCMTSetup{get;set;}                  /*Identify Checkbox true or false on the basis of org_setting value.*/ 
    public boolean ODViewMode{get;set;}                         /*render buttons on the basis of user action.*/
    public Org_Setting__mdt orgEmailSetting;                    /*Org_Setting; it operates checkbox enable & disable.*/
    public boolean isAdmin {get;set;}                           /*Check admin right; true means yes.*/
    public Fundraising__c LkupPopup{get;set;}                   /*It show lookup icon & holds the updated value for the same.*/
    public list<Navatar_Setup__c> lstNavSetup {get;set;}        /*Query Navatar_Setup and contains the whole records.*/
    public String fundName{get; set;}                           /*Hold fundName on the basis of fundId saved in Navatar_Setup sObject.*/
    public boolean showError{get;set;}
    public boolean showConInstmntError{get;set;}
    public Set<String> setCoFund{get;set;}
    public String strPageName{get;set;}             /* Pagerefrence */
    public String strNameSpace{get;set;}                            /*Get NameSpace Dynamically*/
    
    /*
    @Description: Constructor; Execute on page load.
    */
    public CoInvestment_Settings_setup_Ctlr()
    {
        try
        {   
            ODViewMode = true; 
            showError = false;
            strEnableCMTSetup = false;
            showConInstmntError = false;
            LkupPopup = new Fundraising__c();
            isAdmin = false;
            setCoFund = new Set<String>();
            strNameSpace = CommonUtility.strNameSpacePrefix;
            //Added for Security Issue By Qadir Khan..
            if(Schema.sObjectType.fund__c.isAccessible()){
                List<fund__c> lstCoFund2 = Database.query('select id, name, '+strNameSpace+'Investment_Category__c from '+strNameSpace+'Fund__c');
                
                if(lstCoFund2.size() > 0)
                {
                    for(fund__c fnd : lstCoFund2)
                        if(fnd.Investment_Category__c == 'Co-investment')
                            setCoFund.add(fnd.id);
                }
            }
            //Added for Security Issue By Qadir Khan..
            if(Schema.sObjectType.Org_Setting__mdt.isAccessible() && Schema.sObjectType.Org_Setting__mdt.fields.IsActive__c.isAccessible() && Schema.sObjectType.Org_Setting__mdt.fields.label.isAccessible() && Schema.sObjectType.Org_Setting__mdt.fields.developername.isAccessible()){
                orgEmailSetting = new Org_Setting__mdt();
                orgEmailSetting=[SELECT IsActive__c,label,developername FROM Org_Setting__mdt where developername ='Co_Inv_Setting' limit 1];
                if(orgEmailSetting != null)
                    strEnableCMTSetup = orgEmailSetting.IsActive__c;
            }
            //Added for Security Issue By Qadir Khan..
            if(Schema.sObjectType.Navatar_Setup__c.isAccessible() && Schema.sObjectType.Navatar_Setup__c.fields.CI_Fund_ID__c.isAccessible() && Schema.sObjectType.Navatar_Setup__c.fields.admin_setting__c.isAccessible()){
                lstNavSetup = [SELECT CI_Fund_ID__c FROM Navatar_Setup__c where admin_setting__c = true LIMIT 1];
                
                if(lstNavSetup.size() > 0 && !string.isBlank(lstNavSetup[0].CI_Fund_ID__c) )
                {
                    string varGetCheck = lstNavSetup[0].CI_Fund_ID__c;
                    if(Schema.sObjectType.fund__c.isAccessible() && Schema.sObjectType.fund__c.fields.name.isAccessible()){
                        list<fund__c> fundObj = [SELECT id,name from Fund__c WHERE id =: varGetCheck LIMIT 1];
                        if(fundObj.size() > 0)
                        {
                            LkupPopup.Name = fundObj[0].Name;
                            if(Schema.sObjectType.Fundraising__c.fields.Fund_Name__c.isUpdateable())
                                LkupPopup.Fund_Name__c = fundObj[0].id;
                            fundName = fundObj[0].name;
                            
                        }else{
                            showConInstmntError = true;
                        }
                    }
                }
            }
        } 
        catch(Exception ex){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Exception in CoInvestment_Settings_setup_Ctlr : '+ex));
        }
    }
    /*
    Method For PageReference
    */
    public PageReference redirectpage() 
    {
        PageReference pageRef = new PageReference('/apex/'+strPageName+'');
        pageRef.setRedirect(true);
        return pageRef;
    }
    
    /*
    @Description: Action called on click of Edit button; It will check the admin rights and show page in edit mode.
    */
    public void editConInvestmentSetup()
    { 
        try 
        {
            List<User> loggInUser = new  List<User>();
            if(Schema.sObjectType.user.isAccessible() && Schema.sObjectType.profile.isAccessible() && Schema.sObjectType.profile.fields.name.isAccessible())
                loggInUser = [ SELECT id, profile.name from User WHERE id=:userInfo.getUserId() LIMIT 1 ];
            if( loggInUser.size() > 0 && loggInUser[0].profile.name == 'System Administrator' )
                isAdmin = true;
            ODViewMode = false; 
        }
        catch (Exception ce) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Exception in editConInvestmentSetup : '+ce));
        }
    }
    
    /*
    @Description: Action called on click of Save button; It will update the checkbox of org_setting in CMT, and also update the FundId in Navatar_Setup sobject.
    */
    public void onSaveCoInvestmentSetup()
    { 
        try 
        {
            ODViewMode = true;
            showError = false;
            showConInstmntError = false;
            
            if( string.isBlank(LkupPopup.Fund_Name__c) && strEnableCMTSetup == true )
                showError = true;
            else if(strEnableCMTSetup == false)
                showError = false;
            /*Co-Investment Check*/
            if( !string.isBlank(LkupPopup.Fund_Name__c) && !setCoFund.contains(LkupPopup.Fund_Name__c) )
                showConInstmntError = true;
            
            /*If all set then update the record.*/
            if( showError == false && showConInstmntError == false )
            {
                
                //showError = false;
                //showConInstmntError = false;
                CustomMetadataService.updateMetadata(new List<SObject> {orgEmailSetting},strEnableCMTSetup);
                if( Schema.sObjectType.Navatar_Setup__c.fields.CI_Fund_ID__c.isUpdateable() ){
                    lstNavSetup[0].CI_Fund_ID__c = string.valueOf( LkupPopup.Fund_Name__c );
				}
                if( Schema.sObjectType.Navatar_Setup__c.isUpdateable() ){
                    update lstNavSetup;
				}
                
            }
        }
        catch (Exception ce) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Exception in onSaveCoInvestmentSetup : '+ce));
        }
    }
}