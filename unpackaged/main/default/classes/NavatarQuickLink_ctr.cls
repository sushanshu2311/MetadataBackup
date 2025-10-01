/*********************************************************************************
** Module Name : NavatarQuickLink_ctr
** Description : This module is use to display quick links accoding to there settings.
** Throws : NA
** Calls : NA
** Test Class : TestNavatarQuickLink_ctr
**
** Organization : Navatar Group
**
** Revision History:-
** Version   Date        Author       WO#   Description of Action
** 1.5       2016-06-2   Sachin Kumar  NA   To display quick links.
** 2.0       2018-08-02  Qadir         NA   PE v3.7: Summer 18 lightning navigation fix.
*********************************************************************************/

public with sharing class NavatarQuickLink_ctr{
    public boolean bulkEmail{get;set;}
    public boolean newDeal{get;set;}
    public boolean individualInvestor{get;set;} 
    public boolean isFundraising{get;set;}
    public boolean isCommitment{get;set;}
    public string StrRetUrl{get;set;}
    public boolean isLightningModeOff{get;set;}
    public String strPageName{get;set;}
    public String namespace{get;set;}
    
    public NavatarQuickLink_ctr(){
     try{
            isFundraising= true;
            namespace = CommonUtility.strNameSpacePrefix;
            //StrRetUrl='/home/home.jsp';
            strRetUrl ='lightning/page/home'; //PE v3.7: Summer 18 lightning navigation fix.
            if(ApexPages.currentPage().getParameters().get('sdfcIFrameOrigin')!=null)
                StrRetUrl=ApexPages.currentPage().getParameters().get('sdfcIFrameOrigin');
                
                // SK: 8Dec2017
                List<Org_Setting__mdt> lstORGmdt = new List<Org_Setting__mdt>();
                if(Schema.sObjectType.Org_Setting__mdt.isAccessible() && Schema.sObjectType.Org_Setting__mdt.Fields.IsActive__c.isAccessible() && 
                    Schema.sObjectType.Org_Setting__mdt.Fields.DeveloperName.isAccessible() && Schema.sObjectType.Org_Setting__mdt.Fields.Label.isAccessible())
                {
                    lstORGmdt = [SELECT Id, IsActive__c, DeveloperName, Label FROM Org_Setting__mdt LIMIT:(Limits.getLimitQueryRows() - Limits.getQueryRows()) ];
                }
                
                for(Org_Setting__mdt orgSetObj : lstORGmdt){ //(PE3.5, SK, 16Aug2017): added limit clause
                    if(orgSetObj.DeveloperName == 'Bulk_Email_Setting'){
                        bulkEmail= orgSetObj.IsActive__c;
                    }
                    else if(orgSetObj.DeveloperName == 'Deal_Creation'){
                        newDeal= orgSetObj.IsActive__c;
                    }
                    else if(orgSetObj.DeveloperName == 'Ind_Inv_Creation'){
                        individualInvestor= orgSetObj.IsActive__c;
                    }
                    else if(orgSetObj.DeveloperName == 'Commitment_Creation'){
                        isCommitment= orgSetObj.IsActive__c;
                    }
                    
                }
            if(UserInfo.getUiThemeDisplayed() == 'Theme4d')
                isLightningModeOff = false;
            else
                isLightningModeOff = true;
            
            List<Schema.DescribeTabSetResult> tabSetDesc = Schema.describeTabs();
            string strAppLabel = 'Corporate M&A';
                for(Schema.DescribeTabSetResult tsr : tabSetDesc) {
                    if ((tsr.getLabel().toLowerCase() == strAppLabel.toLowerCase()) &&(tsr.isSelected() == true)) {
                          isFundraising= false;
                        break;   
                    }           
                }     
        }
      catch(Exception objExp){
          ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, objExp.getMessage()));
        }
    }
}