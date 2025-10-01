/*********************************************************************************
** Module Name : CommitmentCreation_Ctlr
** Description : This module is use to create commitment for a particuler fund and also create the limited partner and partnership for related fund .
** Throws : NA
** Calls : NA
** Test Class : TestCommitmentCreation_Ctlr
**
** Organization : Navatar Group
**
** Revision History:-
** Version   Date        Author       WO#  Description of Action
** 3.5       2016-06-2  Sachin Kumar  NA   to create inserting the commitment.
** 4.7       2021-07-08 Aditya Sharma NA   Show error message in mobile for Vf page
*********************************************************************************/

public with sharing Class CommitmentCreationHelper_Ctlr {
    
    public String strPageSource {
        get;
        set;
    }
    public String strHomeDiv {
        get;
        set;
    }
    public String strMainDiv {
        get;
        set;
    }
    public String strCompanyDiv {
        get;
        set;
    }
    public String strInstanceURL {
        get;
        set;
    }
    public String strServerUrl {
        get;
        set;
    }
    public Commitment__c fundraingLookup {
        get;
        set;
    }
    public Fundraising__c fundLookup {
        get;
        set;
    }
    public Fundraising__c fundCompLookup {
        get;
        set;
    }
    public Commitment__c CompanyLookup {
        get;
        set;
    }
    public Commitment__c CompanyWarningLookup {
        get;
        set;
    }
    public Commitment__c AccountLPLookup {
        get;
        set;
    }
    public Commitment__c AccountLPFundLookup {
        get;
        set;
    }
    public String strRecordId {
        get;
        set;
    }
    public String strCompanyRecordId {
        get;
        set;
    }
    public String strFundraisingRecordId {
        get;
        set;
    }
    public String strSelectedFund {
        get;
        set;
    }
    public String strPopupName {
        get;
        set;
    }
    public String strCompName {
        get;
        set;
    }
    public List < Fundraising__c > lstFundraisingCompData {
        get;
        set;
    }
    public String strFundraisingValue{
        get;
        set;
    }
    public boolean isCoInvestment {
        get;
        set;
    }
    public Navatar_Setup__c strCoInvestmentFundName {
        get;
        set;
    }
    public map < String, String > mapFundSelectOptions {
        get;
        set;
    }
    public boolean isFundPanel {
        get;
        set;
    }
    public boolean isFundrasingPanel {
        get;
        set;
    }
    public boolean isCompanyPanel {
        get;
        set;
    }
    public String strButtonId {
        get;
        set;
    }
    public String strFundrasingName {
        get;
        set;
    }
    public String strLPName {
        get;
        set;
    }
    public String strFundName {
        get;
        set;
    }
    public Id strInstitutionId {
        get;
        set;
    }
    public Id FundId {
        get;
        set;
    }
    public String strCompanyName {
        get;
        set;
    }
    public String strRequiredFieldJson{
        get;
        set;
    }
    public String strRequiredRowId{
        get;
        set;
    }
    public String strRequiredObjectName {
        get;
        set;
    }
    public list < Account > lstFieldLabelVsApi {
        get;
        set;
    }
    public String strRequiredFieldRemove{get;set;}
    public boolean isCoinvestFundDeleted{get;set;}
    public boolean isFieldPermission{get;set;}
    public list<String> arryReadOnlyFields{get; set;}
    public Map < string, string > sObjNameVsIconURL {
        get;
        set;
    } 
    public string contactIconUrl {
        get;
        set;
    } 
    public string accountIconUrl {
        get;
        set;
    } 
    public String strNameSpace {
        get;
        set;
    }
    public List < Navatar_Setup__c > lstNavatarSetup {
        get;
        set;
    }
    public list < Partnership__c > lstPartnershipLabel {
        get;
        set;
    }
    public String strCCSFields {
        get;
        set;
    }
    public String strCCSFundraisindFields {
        get;
        set;
    }
    public String strCCSLPFields {
        get;
        set;
    }
    public String strCCSPTFields {
        get;
        set;
    }
    public boolean isAdminSetting {
        get;
        set;
    }
    public list < ObjectFieldApiwrap > lstLPFieldLabelApi {
        get;
        set;
    }
    public list < ObjectFieldApiwrap > lstPTFieldLabelApi {
        get;
        set;
    }
    public Map<String,String> mapOfRequiredBlankFiled;
    public Account objAccount {
        get;
        set;
    }
    public Partnership__c objPartnership {
        get;
        set;
    }
    public String strCommitmentData {
        get;
        set;
    }
    public Map < String, Schema.SObjectField > mapAccountFields {
        get;
        set;
    }
    public Map < String, Schema.SObjectField > mapPartnershipFields {
        get;
        set;
    }
    public Map < String, Schema.SObjectField > mapCommitmentFields {
        get;
        set;
    }
    public Map < String, Schema.SObjectField > mapFundraisingFields {
        get;
        set;
    }
    public String strNameSpaceActual {
        get;
        set;
    }
    public list < String > arryLeftSideApiName {
        get;
        set;
    }
    public list < String > arryRightSideApiName {
        get;
        set;
    }
    public list < String > arryComtLeftSideApiName {
        get;
        set;
    }
    public list < String > arryComtRightSideApiName {
        get;
        set;
    }
    public Fundraising__c objFundraisingData {
        get;
        set;
    }
    public Commitment__c ObjCommitmentField {
        get;
        set;
    }
    public Fund__c objFundData {
        get;
        set;
    }
    public Account objAccoutLPData {
        get;
        set;
    }
    public Account objAccoutAmount {
        get;
        set;
    }
    public Account objAccoutCompany {
        get;
        set;
    }
    public list < wrapCommitmentFields > lstAddedFields {
        get;
        set;
    }
    public Integer rowCount {
        get;
        set;
    }
    public String strDeletedRowId {
        get;
        set;
    }
    public String strAccountRecordType {
        get;
        set;
    }
    public Fund__c coInvestmentFund {
        get;
        set;
    }
    public String strSelectedCoInvFund;
    public Id companyRTId;
    public boolean isCreateQuery {
        get;
        set;
    }
    public boolean isValidate {
        get;
        set;
    }
    public String strLocalInfo {
        get;
        set;
    }
    public String strSelectedFundraising;
    public boolean isPopUpClose {
        get;
        set;
    }
    public boolean isWrongCompany {
        get;
        set;
    }
    public boolean isWorngInstitution {
        get;
        set;
    }
    public boolean isCompanyFilled {
        get;
        set;
    }
    public boolean isWarningPopup {
        get;
        set;
    }
    public String strFixedFieldsLP {
        get;
        set;
    }
    public String strFixedFieldsPT {
        get;
        set;
    }
    public String[] arryServarUrl;
    public String strSucessUrl;
    public boolean isLimitedPartner {
        get;
        set;
    }
    public boolean isPartnership {
        get;
        set;
    }
    public String strAdditionalInfo {
        get;
        set;
    }
    public boolean isInSufficient {
        get;
        set;
    }
    public boolean isWrongFund {
        get;
        set;
    }
    public String strTotalAmount {
        get;
        set;
    }
    public String strFundCataegory {
        get;
        set;
    }
    public boolean isOrgSetting {
        get;
        set;
    }
    public boolean isCommitmentCreated {
        get;
        set;
    }
    public String strCommitmentTabId;
    public list < Fundraising__c > lstCoInvestmentFundraising {
        get;
        set;
    }
    public String strLimitedPartnerRecordTypeId{
        get;
        set;
    }
    public String strErrorMessage{
        get;
        set;
    }
    public List<String> arrayBlankRequiredFieldData{get;set;}
    public boolean isRequiredFieldEmpty{get;set;}
    public boolean isLPFound{get;set;}
    public boolean isPTFound{get;set;}
    public String strProperty{get;set;} 
    public Map<String,Account> mapOfLPData;
    public Map<String,Partnership__c> mapOfPTData;
    public String strPTRowId{get;set;}
    public String strPTRowName{get;set;}  
    public String strLPRowId{get;set;}
    public String strLPRowName{get;set;}  
    public Boolean isMobile { get; set; } // to check if the device is mobile, added by Aditya PEv4.7 8 July 2021
    
    public CommitmentCreationHelper_Ctlr (ApexPages.StandardSetController controller){}
    
    public CommitmentCreationHelper_Ctlr () {
        try {
            
            strPageSource = ApexPages.CurrentPage().getParameters().get('Source');
            if(strPageSource == null || strPageSource == '')
                strPageSource='Home';
            strServerUrl = ApexPages.currentPage().getHeaders().get('Host');
            strRecordId = ApexPages.currentPage().getParameters().get('id');
            strNameSpaceActual = CommonUtility.strNameSpacePrefix;
            strNameSpace = strNameSpaceActual.toLowerCase();
            fundraingLookup = new Commitment__c();
            fundLookup = new Fundraising__c();
            CompanyLookup = new Commitment__c();
            CompanyWarningLookup = new Commitment__c();
            AccountLPLookup = new Commitment__c();
            fundCompLookup = new Fundraising__c();
            AccountLPFundLookup = new Commitment__c();
            lstFundraisingCompData = new List < Fundraising__c > ();
            objAccount = new Account();
            objAccoutAmount = new Account();
            if(Schema.sObjectType.Account.fields.Potential_Investment__c.isUpdateable())
                objAccoutAmount.Potential_Investment__c = 0;
            objPartnership = new Partnership__c();
            mapOfLPData = new Map<String,Account>();
            mapOfPTData = new Map<String,Partnership__c>();
            strLPRowId = '';
            strPTRowId = '';
            strLPRowName = '';
            strPTRowName = '';
            strSelectedFund = '';
            strRequiredObjectName = '';
            strRequiredRowId = '';
            strRequiredFieldJson = '';
            strPopupName = '';
            strFundrasingName = '';
            strLPName = '';
            strFundName = '';
            strCompanyName = '';
            strRequiredFieldRemove = '';
            mapOfRequiredBlankFiled = new Map<String,String>();
            isFundPanel = false;
            isCoinvestFundDeleted = false;
            isLPFound=false;
            isFundrasingPanel = false;
            isCompanyPanel = false;
            isCoInvestment = false;
            isAdminSetting = false;
            isFieldPermission = false;
            isCommitmentCreated = false;
            strCCSFields = '';
            strCCSFundraisindFields = '';
            strCCSLPFields = '';
            strCompName = '';
            strCCSPTFields = '';
            strCommitmentData = '';
            strCommitmentTabId = '';
            arryLeftSideApiName = new list < String > ();
            arryRightSideApiName = new list < String > ();
            objFundraisingData = new Fundraising__c();
            ObjCommitmentField = new Commitment__c();
            lstAddedFields = new list < wrapCommitmentFields > ();
            mapFundSelectOptions = new map < String, String > ();
            strDeletedRowId = '';
            rowCount = 0;
            arryReadOnlyFields = new list<String>();
            strFundraisingValue = '';
            strSelectedCoInvFund = '';
            strAccountRecordType = '';
            isCreateQuery = false;
            strSelectedFundraising = '';
            isWrongCompany = false;
            isWorngInstitution = false;
            isCompanyFilled = false;
            isWarningPopup = false;
            isInSufficient = false;
            isLimitedPartner = false;
            isPartnership = false;
            isWrongFund = false;
            isOrgSetting = false;
            isPopUpClose = false;
            strTotalAmount = '';
            strErrorMessage = '';
            arrayBlankRequiredFieldData = new List<String>();
            isRequiredFieldEmpty = false;
            strLimitedPartnerRecordTypeId ='';
            strAdditionalInfo = 'none';
            strFixedFieldsLP = 'Name';
            strFixedFieldsPT = 'Name:' + strNameSpace + 'Fund__c';
            strProperty = 'company';
            lstCoInvestmentFundraising = new list < Fundraising__c > ();
            strLocalInfo = UserInfo.getLocale();
            arryServarUrl = strServerUrl.split('\\.');
            strSucessUrl = 'home/home.jsp';
            isMobile = UserInfo.getUiTheme() == 'Theme4t'; // to check if the device is mobile, added by Aditya PEv4.7 8 July 2021
            //Added for security issues PE 3.5 By Qadir Khan 07 DEC 2017..
            if(Schema.sObjectType.Org_Setting__mdt.isAccessible() && Schema.sObjectType.Org_Setting__mdt.fields.IsActive__c.isAccessible() && Schema.sObjectType.Org_Setting__mdt.fields.label.isAccessible() && Schema.sObjectType.Org_Setting__mdt.fields.developername.isAccessible()){
                List < Org_Setting__mdt > lstOrgCommitment = [SELECT IsActive__c, label, developername FROM Org_Setting__mdt where developername = 'Commitment_Creation'
                                                              and IsActive__c = true limit 1
                                                             ];
                if (lstOrgCommitment.size() > 0) {
                    isOrgSetting = lstOrgCommitment[0].IsActive__c;
                    List < Org_Setting__mdt > lstOrgSett = [SELECT IsActive__c, label, developername FROM Org_Setting__mdt where developername = 'Co_Inv_Setting'
                                                            and IsActive__c = true limit 1
                                                           ];
                    if (lstOrgSett.size() > 0) {
                        isCoInvestment = lstOrgSett[0].IsActive__c;
                        
                    }
                    //Added for security issues PE 3.5 By Qadir Khan 07 DEC 2017..
                    if(Schema.sObjectType.Navatar_Setup__c.isAccessible() && Schema.sObjectType.Navatar_Setup__c.fields.CCS__c.isAccessible() && Schema.sObjectType.Navatar_Setup__c.fields.CCS_Fundraising__c.isAccessible() && Schema.sObjectType.Navatar_Setup__c.fields.CCS_New_Limited_Partner__c.isAccessible() && Schema.sObjectType.Navatar_Setup__c.fields.CCS_Partnership__c.isAccessible() && Schema.sObjectType.Navatar_Setup__c.fields.CI_Fund_ID__c.isAccessible() && Schema.sObjectType.Navatar_Setup__c.fields.Admin_Setting__c.isAccessible()){
                        lstNavatarSetup = [Select CCS__c, CCS_Fundraising__c, CCS_New_Limited_Partner__c, CCS_Partnership__c, CI_Fund_ID__c, Admin_Setting__c from Navatar_Setup__c where Admin_Setting__c = true order by CreatedDate ASC limit 1];
                        if (lstNavatarSetup.size() > 0) {
                            isAdminSetting = lstNavatarSetup[0].Admin_Setting__c;
                            strCCSFields = lstNavatarSetup[0].CCS__c;
                            strCCSFundraisindFields = lstNavatarSetup[0].CCS_Fundraising__c;
                            strCCSLPFields = lstNavatarSetup[0].CCS_New_Limited_Partner__c;
                            strCCSPTFields = lstNavatarSetup[0].CCS_Partnership__c;
                            Set<String> SetDevelopername = new Set<String>();
                            SetDevelopername.add('LimitedPartner');
                            SetDevelopername.add('Property');
                            //Added for security issues PE 3.5 By Qadir Khan 07 DEC 2017..
                            if(Schema.sObjectType.recordtype.isAccessible() && Schema.sObjectType.recordtype.fields.developername.isAccessible() && Schema.sObjectType.recordtype.fields.isActive.isAccessible()){
                                list<SObject> lstRecordType = [Select Id,developername From recordtype Where developername IN : SetDevelopername AND isActive = true Limit 1];
                                for(SObject objRecordType : lstRecordType)
                                {
                                    strLimitedPartnerRecordTypeId = (String) objRecordType.get('Id'); 
                                }
                                list<SObject> lstRecordTypeProperty = [Select Id,developername From recordtype Where developername = 'Property' AND isActive = true Limit 1];
                                for(SObject objRecordType : lstRecordTypeProperty)
                                {
                                    strProperty = 'property';
                                }
                            }
                            DescribeSObject();  
                        }
                        if (isAdminSetting) {
                            
                            showPopupData();
                            lstLPFieldLabelApi = getFieldsNameFromApi(strCCSLPFields, 'Account');
                            lstPTFieldLabelApi = getFieldsNameFromApi(strCCSPTFields, strNameSpace + 'Partnership__c');
                            
                            if (lstLPFieldLabelApi.size() > 0) {
                                isLimitedPartner = true;
                            }
                            
                            if (lstPTFieldLabelApi.size() > 0) {
                                isPartnership = true;
                            }
                            
                            
                        }
                    }
                    
                }
            }
            if (strRecordId != '' && strRecordId != null) {
                strInstanceURL =  strRecordId;
                
                
            } else {
                strInstanceURL = ApexPages.CurrentPage().getParameters().get('retURL');
            }
            
            
            
            
        } catch (Exception objExcp) {
            strErrorMessage = objExcp.getMessage();
            //ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, objExcp.getMessage()));
        }
    }
    
    /*
Description : This method is use to showing popup on page after checking wheteher user comes from Home,Fundraising or Comapny. 
Param: NA
Retun Type: void
*/
    public void showPopupData() {
        if (strPageSource == 'Home') {
            strHomeDiv = 'block';
            strMainDiv = 'none';
            strCompanyDiv = 'none';
            isFundrasingPanel = true;
            getCompanyData();
            if (strCommitmentTabId != '' && strCommitmentTabId != null) {
                strSucessUrl =  strCommitmentTabId + '/o';
            }
            
        } else if (strPageSource == 'Company') {
            strHomeDiv = 'block';
            strMainDiv = 'none';
            strCompanyDiv = 'block';
            isFundrasingPanel = true;
            strCompanyRecordId = strRecordId;
            getCompanyData();
            strSucessUrl =   strRecordId;
        } else if (strPageSource == 'Fundraising') {
            strHomeDiv = 'none';
            strMainDiv = 'block';
            strCompanyDiv = 'none';
            isFundrasingPanel = false;
            strFundraisingRecordId = strRecordId;
            getCompanyData();
            strPopupName = 'HomePopup';
            CommitmentData();
            if (strCommitmentTabId != '' && strCommitmentTabId != null) {
                strSucessUrl =    strCommitmentTabId + '/o';
            }
        }
        
    }
    
    /*
Description : This method is use to get Data from selected fundraising,fund,institution and company. 
Param: NA
Retun Type: void
*/
    public void CommitmentData() {
        try {
            isWrongCompany = false;
            isWorngInstitution = false;
            isCompanyFilled = false;
            isWrongFund = false;
            strErrorMessage = '';
            
            if (strPopupName == 'FundPopup') {
                
                String strFundValue = fundLookup.Fund_Name__c;
                FundId = fundLookup.Fund_Name__c;
                isCreateQuery = false;
                strFundCataegory = '';
                String strLPOneValue = AccountLPFundLookup.Limited_Partner__c;
                strInstitutionId = AccountLPFundLookup.Limited_Partner__c;
                String[] arryComitmentLabelApi = getObjectApiLabels('Commitment');
                
                if ((strFundValue != '' && strFundValue != null) && (strLPOneValue != '' && strLPOneValue != null)) {
                    //Added for security issues PE 3.5 By Qadir Khan 07 DEC 2017..
                    if(Schema.sObjectType.Fund__c.isAccessible() && Schema.sObjectType.Fund__c.fields.Name.isAccessible() && Schema.sObjectType.Fund__c.fields.Fund_Type__c.isAccessible() && Schema.sObjectType.Fund__c.fields.Investment_Category__c.isAccessible()){
                        list < Fund__c > lstFundData = [Select Id, Name, Fund_Type__c, Investment_Category__c from Fund__c Where Id = : strFundValue limit 1];
                        if (lstFundData.size() > 0) {
                            strFundCataegory = lstFundData[0].Investment_Category__c;
                        }
                        
                        if (isCoInvestment == true && (strFundValue != strSelectedCoInvFund && strFundCataegory == 'Co-investment')) {
                            isCreateQuery = true;
                        }
                        
                        if (!isCreateQuery) {
                            if(strFundCataegory =='Co-investment'){
                                isCompanyFilled = true;
                            }
                            
                            if (lstFundData.size() > 0) {
                                objFundData = lstFundData[0];
                                strFundName = lstFundData[0].Name;
                            }
                            //Added for security issues PE 3.5 By Qadir Khan 07 DEC 2017..
                            if(Schema.sObjectType.Account.isAccessible() && Schema.sObjectType.Account.fields.name.isAccessible() && Schema.sObjectType.recordtype.isAccessible() && Schema.sObjectType.recordtype.fields.developername.isAccessible()){
                                list < Account > lstAccoutLPData = [Select Id, Name from Account where Id = : strLPOneValue AND (recordtype.developername = 'Institution'
                                                                                                                                 OR recordtype.developername = 'Individual_Investor') limit 1];
                                if (lstAccoutLPData.size() > 0) {
                                    objAccoutLPData = lstAccoutLPData[0];
                                    strLPName = lstAccoutLPData[0].Name;
                                } else {
                                    isWorngInstitution = true;
                                }
                                
                                
                                if (isWorngInstitution == false) {
                                    AutoCompleteData();
                                    AddRow();
                                }
                            }
                        } 
                        else {
                            isWrongFund = true;
                        }
                    }
                }
            } else if (strPopupName == 'HomePopup') {
                
                
                isCreateQuery = false;
                strFundCataegory = '';
                
                if ((strFundraisingRecordId != '' && strFundraisingRecordId != null) && (strPageSource == 'Fundraising')) {
                    strFundraisingValue = strFundraisingRecordId;
                    
                } else if (strPageSource != 'Fundraising') {
                    strFundraisingValue = fundraingLookup.Fundraising__c;
                    
                    strFundraisingValue = strFundraisingValue.subString(0, 15);
                }
                
                
                
                if (strFundraisingValue != '' && strFundraisingValue != null) {
                    //Added for security issues PE 3.5 By Qadir Khan 07 DEC 2017..
                    if(Schema.sObjectType.Fundraising__c.isAccessible() && Schema.sObjectType.Fundraising__c.fields.Fund_Name__c.isAccessible() && Schema.sObjectType.Fund__c.fields.Investment_Category__c.isAccessible()){
                        list < Fundraising__c > lstFundraisingDataCheck = [Select Id, Fund_Name__r.Investment_Category__c from Fundraising__c where Id = : strFundraisingValue];
                        
                        if (lstFundraisingDataCheck.size() > 0) {
                            strFundCataegory = lstFundraisingDataCheck[0].Fund_Name__r.Investment_Category__c;
                        }
                    }
                    if (lstCoInvestmentFundraising.size() > 0) {
                        for (Fundraising__c objFundraisingCoinv: lstCoInvestmentFundraising)
                            if (strFundraisingValue == objFundraisingCoinv.id) {
                                strSelectedFundraising = objFundraisingCoinv.id;
                                strSelectedFundraising = strSelectedFundraising.subString(0, 15);
                            }
                    }
                    
                    if (isCoInvestment == true && (strSelectedFundraising != strFundraisingValue && strFundCataegory == 'Co-investment')) {
                        isCreateQuery = true;
                    }
                    
                    
                    if (!isCreateQuery) {
                        String strQuery = 'Select ID,';
                        String[] arryFundraingLabelApi = getObjectApiLabels('Fundraising');
                        String[] arryComitmentLabelApi = getObjectApiLabels('Commitment');
                        
                        for (Integer i = 0; i < arryFundraingLabelApi.size(); i++) {
                            strQuery = strQuery + arryFundraingLabelApi[i] + ',';
                        }
                        
                        strQuery = strQuery + 'Legal_Name__r.Name,Portfolio_Company__r.Name,Fund_Name__r.Name,Fund_Name__r.Fund_Type__c From Fundraising__c where Id =\'' + String.escapeSingleQuotes(strFundraisingValue) + '\' Limit 1';
                        //Added for security issues PE 3.5 By Qadir Khan 07 DEC 2017..
                        if(Schema.sObjectType.Fundraising__c.isAccessible()){
                            list < Fundraising__c > lstFundraisingData = database.query(strQuery);
                            
                            if (lstFundraisingData.size() > 0) {
                                objFundraisingData = lstFundraisingData[0];
                                
                                FundId = lstFundraisingData[0].Fund_Name__c;
                                strInstitutionId = lstFundraisingData[0].Legal_Name__c;
                                strFundName = lstFundraisingData[0].Fund_Name__r.Name;
                                strLPName = lstFundraisingData[0].Legal_Name__r.Name;
                                strCompanyName = lstFundraisingData[0].Portfolio_Company__r.Name;
                                companyRTId = lstFundraisingData[0].Portfolio_Company__c;
                                if(strFundCataegory =='Co-investment' && companyRTId == null){
                                    isCompanyFilled = true;    
                                }
                                //Added for security issues PE 3.5 By Qadir Khan 07 DEC 2017..
                                if(Schema.sObjectType.Fund__c.isAccessible() && Schema.sObjectType.Fund__c.fields.name.isAccessible()){
                                    list < Fund__c > lstFundData = [Select Id, Name from Fund__c Where Id = : lstFundraisingData[0].Fund_Name__c limit 1];
                                    if (lstFundData.size() > 0) {
                                        objFundData = lstFundData[0];
                                        
                                    }
                                }
                                
                            }
                        }
                        AutoCompleteData();
                        AddRow();
                    } else {
                        isInSufficient = true;
                        strMainDiv = 'none';
                        
                    }
                }
                
            } else if (strPopupName == 'CompanyPopup') {
                
                String strLPValue = AccountLPLookup.Limited_Partner__c;
                strInstitutionId = AccountLPLookup.Limited_Partner__c;
                String strPortCompanyId = CompanyLookup.Portfolio_Company__c;
                String strFundValue = fundCompLookup.Fund_Name__c;
                String[] arryComitmentLabelApi = getObjectApiLabels('Commitment');
                if(strSelectedFund == '' || strSelectedFund == null || strSelectedFund == '--None--' )
                {   
                    if (strFundValue != '' && strFundValue != null) {
                        strSelectedFund = fundCompLookup.Fund_Name__c;
                    } 
                    else if (isCoInvestment) {
                        strSelectedFund = strSelectedCoInvFund;
                    }
                }
                
                if ((strSelectedFund != '' && strSelectedFund != null) && (strLPValue != '' && strLPValue != null)) {
                    String strQuery = '';
                    if (strPortCompanyId != '' && strPortCompanyId != null) {
                        list < Account > lstCompanyId = new list<Account>();
                        //Added for security issues PE 3.5 By Qadir Khan 07 DEC 2017..
                        if(Schema.sObjectType.Account.isAccessible() && Schema.sObjectType.Account.fields.name.isAccessible() && Schema.sObjectType.recordtype.isAccessible() && Schema.sObjectType.recordtype.fields.developername.isAccessible()){
                            //Added condition Portfolio_Company recordtype in PE v4.5 By Hemendra 
                            lstCompanyId = [Select Id, Name from Account where Id = : strPortCompanyId AND (recordtype.developername = 'Company' OR RecordType.DeveloperName = 'Portfolio_Company' OR recordtype.developername = 'Property') limit 1 ];
                        }
                        if (lstCompanyId.size() > 0) {
                            objAccoutCompany = lstCompanyId[0];
                            strCompanyName = lstCompanyId[0].Name;
                            companyRTId = lstCompanyId[0].id;
                            
                        } else {
                            isWrongCompany = true;
                        }
                        
                    }
                    
                    list < Fund__c > lstFundData = new list < Fund__c >();
                    //Added for security issues PE 3.5 By Qadir Khan 07 DEC 2017..
                    if(Schema.sObjectType.Fund__c.isAccessible() && Schema.sObjectType.Fund__c.fields.name.isAccessible() && Schema.sObjectType.Fund__c.fields.Fund_Type__c.isAccessible() && Schema.sObjectType.Fund__c.fields.Investment_Category__c.isAccessible()){
                        lstFundData = [Select Id, Name, Fund_Type__c, Investment_Category__c from Fund__c Where Id = : strSelectedFund limit 1];
                    }
                    
                    
                    if (lstFundData.size() > 0) {
                        objFundData = lstFundData[0];
                        strFundName = lstFundData[0].Name;
                        FundId = lstFundData[0].Id;
                        strFundCataegory = lstFundData[0].Investment_Category__c;
                        if (strFundCataegory =='Co-investment' && (strPortCompanyId == '' || strPortCompanyId == null)) {
                            isCompanyFilled = true;
                        }
                        
                    }
                    list < Account > lstAccoutData = new list<Account>();
                    //Added for security issues PE 3.5 By Qadir Khan 07 DEC 2017..
                    if(Schema.sObjectType.Account.isAccessible() && Schema.sObjectType.Account.fields.name.isAccessible() && Schema.sObjectType.recordtype.isAccessible() && Schema.sObjectType.recordtype.fields.developername.isAccessible()){
                        lstAccoutData = [Select Id, Name from Account where Id = : strLPValue AND (recordtype.developername = 'Institution' OR recordtype.developername = 'Individual_Investor')limit 1];
                    }
                    if (lstAccoutData.size() > 0) {
                        objAccoutLPData = lstAccoutData[0];
                        strLPName = lstAccoutData[0].Name;
                        strInstitutionId = lstAccoutData[0].id;
                    } else {
                        isWorngInstitution = true;
                    }
                   if (isWorngInstitution == false && isWrongCompany == false) {
                    AutoCompleteData();
                    AddRow();
                  } 
                }
                                
                
            }
            
            
            
            
        } catch (Exception objExcp) {
            strErrorMessage = objExcp.getMessage();
            //ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, objExcp.getMessage()));
        }
    }
    /*
Description : This method is use to check the selected company and. 
Param: NA
Retun Type: void
*/
    
    public void getCompanyData() {
        if ((strPageSource == 'Company' || strPageSource == 'Home') && Schema.sObjectType.Commitment__c.fields.Portfolio_Company__c.isUpdateable()) {
            CompanyLookup.Portfolio_Company__c = strCompanyRecordId;
        }
        getFundData();
        
    }
    
    /*
Description : This method is use to assign total commitment amount. 
Param: NA
Retun Type: void
*/
    
    public void TotalCommitmentAmount() {
        try {
            if(Schema.sObjectType.Account.fields.Potential_Investment__c.isUpdateable())
                objAccoutAmount.Potential_Investment__c = Decimal.valueOf(strTotalAmount);
        } catch (Exception objExcp) {
            
            // ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, objExcp.getMessage()));
        }
    }
    
    /*
Description : This method is use get fund data according to coInvestment setting. 
Param: NA
Retun Type: void
*/
    
    public void getFundData() {
        try {
            
            String strCompId;
            strErrorMessage = '';
            if (strPageSource == 'Company' || strPageSource == 'Home') {
                strCompId = CompanyLookup.Portfolio_Company__c;
            }
            mapFundSelectOptions = new map < String, String > ();
            strCoInvestmentFundName = new Navatar_Setup__c();
            String strQuery = '';
            
            if (isCoInvestment) {
                
                if (lstNavatarSetup.size() > 0) {
                    String strCoInvestmentFundId = lstNavatarSetup[0].CI_Fund_ID__c;
                    list < Fund__c > lstCoInvestmentFund =new list<Fund__c>();
                    //Added for security issues PE 3.5 By Qadir Khan 07 DEC 2017..
                    if(Schema.sObjectType.Fund__c.isAccessible() && Schema.sObjectType.Fund__c.fields.Name.isAccessible()){
                        lstCoInvestmentFund = [Select Id, Name from Fund__c where Id = : strCoInvestmentFundId Limit 1];
                    }
                    if (lstCoInvestmentFund.size() > 0) {
                        coInvestmentFund = lstCoInvestmentFund[0];
                        strSelectedCoInvFund = coInvestmentFund.id;
                        
                    }
                    else
                    {
                      isCoinvestFundDeleted = true;
                    }
                    lstCoInvestmentFundraising = new list < Fundraising__c >();
                    //Added for security issues PE 3.5 By Qadir Khan 07 DEC 2017..
                    if(Schema.sObjectType.Fundraising__c.isAccessible() && Schema.sObjectType.Fundraising__c.fields.name.isAccessible() && Schema.sObjectType.Fundraising__c.fields.Fund_Name__c.isAccessible()){
                        lstCoInvestmentFundraising = [Select Id, Name from Fundraising__c where Fund_Name__c = : strCoInvestmentFundId];
                    }
                    
                    
                }
            } else if (strCompId != '' && strCompId != null) {
                strQuery = 'Select Id, Fund_Name__r.Name, Fund_Name__r.Id From Fundraising__c where Portfolio_Company__c =\'' +String.escapeSingleQuotes(strCompId)+ '\'';
                lstFundraisingCompData = new list < Fundraising__c >();
                //Added for security issues PE 3.5 By Qadir Khan 07 DEC 2017..
                if(Schema.sObjectType.Fundraising__c.isAccessible()){
                    lstFundraisingCompData = database.query(strQuery);
                }
                if (lstFundraisingCompData.size() > 0) {
                    for (Fundraising__c objFundraising: lstFundraisingCompData) {
                        mapFundSelectOptions.put(objFundraising.Fund_Name__r.Id, objFundraising.Fund_Name__r.Name);
                    }
                }
                String strComitQuery = 'Select Id, Fund__r.Name, Fund__r.Id From Partnership__c where Id IN (Select Partnership__c from Commitment__c where Portfolio_Company__c =\'' +String.escapeSingleQuotes(strCompId)+ '\')';
                //Added for security issues PE 3.5 By Qadir Khan 07 DEC 2017..
                if(Schema.sObjectType.Partnership__c.isAccessible() && Schema.sObjectType.Commitment__c.isAccessible()){
                    List <Partnership__c> lstPartnershipCompData = database.query(strComitQuery);
                    if (lstPartnershipCompData.size() > 0) {
                        for (Partnership__c objPartnership: lstPartnershipCompData) {
                            mapFundSelectOptions.put(objPartnership.Fund__r.Id, objPartnership.Fund__r.Name);
                        }
                    }
                }
             
                  
            }
        } catch (Exception objExcp) {
            strErrorMessage = objExcp.getMessage();
            //ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, objExcp.getMessage()));
        }
        
    }
    /*
Description : This method is use get Check Required field. 
Param: String
Retun Type: String[]
*/
    
    public void checkRequiredFieldsOnPopup() {
        
        try {
             boolean isRequiredBlankField = false;
             String fieldData = '';
             String strIndentifier = '';
             if(strRequiredFieldJson != '' && strRequiredFieldJson != null)
             {
                
                Map < String, Object > map1 = (Map < String, Object > ) JSON.deserializeUntyped(strRequiredFieldJson);
                Map<String,Sobject> mapFieldData = new Map<String,Sobject>();
                if(strRequiredObjectName == 'Account')
                {
                  mapFieldData = mapOfLPData;
                  strIndentifier = '<¤>';
                          
                }
                else if(strRequiredObjectName == 'Partnership')
                {
                  mapFieldData = mapOfPTData;
                  strIndentifier = '';
                              
                }
                for(String str : map1.KeySet())
                {
                  fieldData = str+strIndentifier;
                  String strApiNameData = String.valueof(map1.get(str));
                  strApiNameData = strApiNameData.subString(1,strApiNameData.length()-1);
                  for(String strRequiredField : strApiNameData.split(','))
                  {
                  if(!mapFieldData.isEmpty() && map1.get(str) != null)
                  {
                  Sobject objRequiredFieldData = mapFieldData.get(str);
                  if(objRequiredFieldData != null)
                   {
                        if(strRequiredField != '' && objRequiredFieldData.get(strRequiredField) == '')
                              {
                                isRequiredBlankField = true;  
                              }
                        
                   }
                               
                  }
                 else if(map1.get(str) != null)
                    {
                       
                            if(strRequiredField != '')
                              {
                                isRequiredBlankField = true;  
                              }
                         
                   
                    }
                                        
                }                    
                }
              if(isRequiredBlankField)
              {
                   
                mapOfRequiredBlankFiled.put(fieldData,strRequiredRowId+'<@>'+strRequiredObjectName);  
              }               
             }
            
            }
        catch(Exception objExcp)
        {
            strErrorMessage = objExcp.getMessage();
        }       
    }
    
    /*
Description : This method is use get field label from given object. 
Param: String
Retun Type: String[]
*/
    
    public String[] getObjectApiLabels(String objectName) {
        arryComtLeftSideApiName = new list < String > ();
        arryComtRightSideApiName = new list < String > ();
        try {
            String[] arrayFundrasingFieldsAPI = new List < String > ();
            String[] arrayTempOne = new List < String > ();
            String[] arrayTempTwo = new List < String > ();
            String[] fundrasingLabelArrayOne = new List < String > ();
            strErrorMessage = '';
            Map < String, Schema.SObjectField > mapOfFields = new Map < String, Schema.SObjectField > ();
            if (objectName == 'Fundraising') {
                fundrasingLabelArrayOne = strCCSFundraisindFields.split(';');
                mapOfFields.putAll(mapFundraisingFields);
            } else if (objectName == 'Commitment') {
                fundrasingLabelArrayOne = strCCSFields.split(';');
                mapOfFields.putAll(mapCommitmentFields);
            }
            
            if (fundrasingLabelArrayOne.size() > 0) {
                String[] fundrasingLabelArrayTwo = fundrasingLabelArrayOne[0].split(',');
                for (Integer j = 0; j < fundrasingLabelArrayTwo.size(); j++) {
                    String[] fundrasingleftApiObject = fundrasingLabelArrayTwo[j].split(':');
                    
                    for (String strFieldKey: mapOfFields.keyset()) {
                        boolean isFieldAvialable = mapOfFields.get(strFieldKey).getDescribe().isAccessible();
                        boolean isReadyOnly = mapOfFields.get(strFieldKey).getDescribe().isUpdateable();
                        SObjectField sobjectFieldName = mapOfFields.get(strFieldKey);
                        String strFieldNameAPi = String.valueOf(sobjectFieldName);
                        if (isFieldAvialable && (strFieldNameAPi.toLowerCase() == fundrasingleftApiObject[1].toLowerCase())) {
                            arrayTempOne.add(fundrasingleftApiObject[1]);
                        }
                        if ((!isReadyOnly) && (strFieldNameAPi.toLowerCase() == fundrasingleftApiObject[1].toLowerCase())) {
                            arryReadOnlyFields.add(fundrasingleftApiObject[1]);
                        }
                    }
                }
                if (fundrasingLabelArrayOne.size() > 1) {
                    String[] fundrasingLabelArrayThree = fundrasingLabelArrayOne[1].split(',');
                    
                    for (Integer k = 0; k < fundrasingLabelArrayThree.size(); k++) {
                        String[] fundrasingrightApiObject = fundrasingLabelArrayThree[k].split(':');
                        for (String strFieldKey: mapOfFields.keyset()) {
                            boolean isFieldAvialable = mapOfFields.get(strFieldKey).getDescribe().isAccessible();
                            boolean isReadyOnly = mapOfFields.get(strFieldKey).getDescribe().isUpdateable();
                            Schema.SObjectField sobjectFieldName = mapOfFields.get(strFieldKey);
                            String strFieldNameAPi = String.valueOf(sobjectFieldName);
                            if (isFieldAvialable && (strFieldNameAPi.toLowerCase() == fundrasingrightApiObject[1].toLowerCase())) {
                                arrayTempTwo.add(fundrasingrightApiObject[1]);
                            }
                            if ((!isReadyOnly) && (strFieldNameAPi.toLowerCase() == fundrasingrightApiObject[1].toLowerCase())) {
                            arryReadOnlyFields.add(fundrasingrightApiObject[1]);
                            }
                        }
                        
                        
                    }
                }
                if (objectName == 'Fundraising') {
                    arryLeftSideApiName.addAll(arrayTempOne);
                    arryRightSideApiName.addAll(arrayTempTwo);
                    
                } else if (objectName == 'Commitment') {
                    arryComtLeftSideApiName.addAll(arrayTempOne);
                    arryComtRightSideApiName.addAll(arrayTempTwo);
                    if (arryComtLeftSideApiName.size() > 0 || arryComtRightSideApiName.size() > 0) {
                        strAdditionalInfo = 'block';
                    }
                }
            }
            
            
            arrayFundrasingFieldsAPI.addAll(arrayTempOne);
            arrayFundrasingFieldsAPI.addAll(arrayTempTwo);
            return arrayFundrasingFieldsAPI;
        } catch (Exception objExcp) {
            strErrorMessage = objExcp.getMessage();
            //ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, objExcp.getMessage()));
            return null;
        }
        
    }
    public List < SelectOption > getFundOptions() {
        try {
            strErrorMessage = '';
            List < SelectOption > options = new List < SelectOption > ();
            if (!isCoInvestment || (strPageSource != 'Company' && strPageSource != 'Home'))
                options.add(new SelectOption('--None--', '--None--'));
            if (mapFundSelectOptions.size() > 0) {
                for (String strFundId: mapFundSelectOptions.keyset()) {
                    options.add(new SelectOption(strFundId, mapFundSelectOptions.get(strFundId)));
                }
            }
            
            
            return options;
        } catch (Exception objExcp) {
            strErrorMessage = objExcp.getMessage();
            //ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, objExcp.getMessage()));
            return null;
        }
    }
    /*
Description : This method is use get fields metadata. 
Param: NA
Retun Type: void
*/
    public void DescribeSObject() {
        try {
            strErrorMessage = '';
            mapAccountFields = Schema.getGlobalDescribe().get('Account').getDescribe().fields.getMap();
            String strPartnershipObj = strNameSpace + 'Partnership__c';
            String strCommitmentObj = strNameSpace + 'Commitment__c';
            String strFundraisingObj = strNameSpace + 'Fundraising__c';
            mapPartnershipFields = Schema.getGlobalDescribe().get(strPartnershipObj.toLowerCase()).getDescribe().fields.getMap();
            mapCommitmentFields = Schema.getGlobalDescribe().get(strCommitmentObj.toLowerCase()).getDescribe().fields.getMap();
            mapFundraisingFields = Schema.getGlobalDescribe().get(strFundraisingObj.toLowerCase()).getDescribe().fields.getMap();
            Schema.DescribeSObjectResult commitmentTabData = Schema.getGlobalDescribe().get(strCommitmentObj.toLowerCase()).getDescribe();
            strCommitmentTabId = commitmentTabData.getKeyPrefix();
             list<String> lstCommitmentFieldsApiName = new List<String>();
            lstCommitmentFieldsApiName.add(strNameSpace+'Fundraising__c');
            lstCommitmentFieldsApiName.add(strNameSpace+'Portfolio_Company__c');
            lstCommitmentFieldsApiName.add(strNameSpace+'Limited_Partner__c');
            for(String commitmentField : lstCommitmentFieldsApiName)
            {   
                boolean isCommitmentFieldAvialable = mapCommitmentFields.get(commitmentField.toLowerCase()).getDescribe().isAccessible();
                boolean isCommitmentFieldReadOnly = mapCommitmentFields.get(commitmentField.toLowerCase()).getDescribe().isUpdateable();
                if((isCommitmentFieldAvialable == false) || (isCommitmentFieldReadOnly== false))
                {
                    isFieldPermission = true;
                }
            }
             String strfundApiNameCheck = strNameSpace+'Fund_Name__c';
             boolean isFundFieldAvialable = mapFundraisingFields.get(strfundApiNameCheck.toLowerCase()).getDescribe().isAccessible();
             boolean isFundFieldReadOnly = mapFundraisingFields.get(strfundApiNameCheck.toLowerCase()).getDescribe().isUpdateable();
              if((isFundFieldAvialable == false) || (isFundFieldReadOnly == false))
                {
                 isFieldPermission = true;            
                }
                
                    
                } catch (Exception objExcp) {
                    strErrorMessage = objExcp.getMessage();
                    //ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, objExcp.getMessage()));
                }
            }
            
    /*
Description : This method is use get values for autocomplete. 
Param: NA
Retun Type: void
*/
    public void AutoCompleteData() {
        try {
            strErrorMessage = '';
            lstFieldLabelVsApi = new list < Account > ();
            lstPartnershipLabel = new list < Partnership__c > ();
            //Added for security issues PE 3.5 By Qadir Khan 07 DEC 2017..
            if(Schema.sObjectType.Account.isAccessible() && Schema.sObjectType.Account.fields.name.isAccessible()  && Schema.sObjectType.Account.fields.ParentId.isAccessible() && Schema.sObjectType.recordtype.isAccessible() && Schema.sObjectType.recordtype.fields.developername.isAccessible()){
                lstFieldLabelVsApi = [Select Id, Name,recordtype.Id From Account Where recordtype.developername = 'LimitedPartner'AND ParentId = : strInstitutionId Order By Name ASC];
            }
            if(Schema.sObjectType.Partnership__c.isAccessible() && Schema.sObjectType.Partnership__c.fields.Name.isAccessible() && Schema.sObjectType.Partnership__c.fields.Fund__c.isAccessible()){
                lstPartnershipLabel = [Select Id, Name From Partnership__c where Fund__c = : FundId Order By Name ASC];
            }
        } catch (Exception objExcp) {
            strErrorMessage = objExcp.getMessage();
            //ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, objExcp.getMessage()));
        }
    }
    /*
Description : This method is use to create final commitment record and insert these records in object. 
Param: NA
Retun Type: pageReference
*/
    public void CreateCommitmentData() {
        Savepoint svPoint = Database.setSavepoint();
        
        try {
            strErrorMessage = '';
            if (strCommitmentData != '' && strCommitmentData != null) {
                
                boolean isLPCreate = false;
                boolean isPTCreate = false;
                Id strLPRecordTypeId;
                List < SObject > lstLimitedPartnerInsert = new List < Account > ();
                List < SObject > lstPartnershipInsert = new List < Partnership__c > ();
                List < SObject > lstCommitmentRecord = new List < Commitment__c > ();
                List < Object > rawObj = (List < Object > ) JSON.deserializeUntyped(strCommitmentData);
                
                
                if (strAccountRecordType != '' && strAccountRecordType != null) {
                    list<RecordType> recordTypeObj = new list<RecordType>();
                    //Added for security issues PE 3.5 By Qadir Khan 07 DEC 2017..
                    if(Schema.sObjectType.RecordType.isAccessible() && Schema.sObjectType.recordtype.fields.developername.isAccessible() && Schema.sObjectType.recordtype.fields.Name.isAccessible() && Schema.sObjectType.recordtype.fields.isActive.isAccessible()){
                        recordTypeObj = [Select id, Name from RecordType where developername = : strAccountRecordType AND isActive = true Limit 1];
                    }
                    if (recordTypeObj.size() > 0) {
                        strLPRecordTypeId = recordTypeObj[0].id;
                    } else {
                        strLPRecordTypeId = getRecordtypeObjectName('Account');
                        
                    }
                }
                list<RecordType> recordTypePartnershipObj = new list<RecordType>();
                if(Schema.sObjectType.RecordType.isAccessible() && Schema.sObjectType.recordtype.fields.Name.isAccessible()){
                    recordTypePartnershipObj = [Select id, name from recordtype where SObjectType = 'Partnership__c'];
                }
                Id partnershipRecordTypeId;
                if (recordTypePartnershipObj.size() > 0) {
                    partnershipRecordTypeId = getRecordtypeObjectName(strNameSpace + 'Partnership__c');
                    
                    
                }
                
                for (Object obj: rawObj) {
                    SObject ObjLPRecord = new Account();
                    SObject ObjPTRecord = new Partnership__c();
                    Commitment__c ObjCommitment = new Commitment__c();
                    Map < String, Object > map1 = (Map < String, Object > ) obj;
                    
                    if (map1.get('limited_partner') != null) {
                        Map < String, Object > map2 = (Map < String, Object > ) map1.get('limited_partner');
                        Map < String, Object > map3 = (Map < String, Object > ) map1.get('partnership');
                        
                        
                        
                        if (map2.containsKey('id') != true) {
                            String AccountLPName = (String) map2.get('Name');
                             boolean checkAccount = false;                          
                            if (lstLimitedPartnerInsert.size() > 0) {
                                
                                for (SObject objAccountLst: lstLimitedPartnerInsert) {
                                    
                                    if (objAccountLst.get('Name') == AccountLPName) {
                                        checkAccount = true;
                                    }
                                }
                                
                            } 
                            if (!checkAccount)  {
                                 if(mapOfLPData.get(AccountLPName) != null)
                                  { 
                                   ObjLPRecord = mapOfLPData.get(AccountLPName);
                                  } 
                                ObjLPRecord.put('Name', AccountLPName);
                                ObjLPRecord.put('ParentId', strInstitutionId);
                                ObjLPRecord.put('RecordTypeId', strLPRecordTypeId);
                                lstLimitedPartnerInsert.add(ObjLPRecord);
                                isLPCreate = true;
                                
                            }
                           
                            
                        }
                        if (map3.containsKey('id') != true) {
                            String partrnershipName = (String) map3.get('Name');
                             boolean checkPartnership = false;
                            if (lstPartnershipInsert.size() > 0) {
                               
                                for (SObject objPartnershipLst: lstPartnershipInsert) {
                                    
                                    if (objPartnershipLst.get('Name') == partrnershipName) {
                                        checkPartnership = true;
                                    }
                                }
                                
                            } 
                             if (!checkPartnership) {
                                    if(mapOfPTData.get(partrnershipName) != null)
                                     {
                                        ObjPTRecord = mapOfPTData.get(partrnershipName);
                                     }  
                                    ObjPTRecord.put('Name', partrnershipName);
                                    ObjPTRecord.put(strNameSpace + 'Fund__c', FundId);
                                    if (partnershipRecordTypeId != '' && partnershipRecordTypeId != null) {
                                        
                                        ObjPTRecord.put('RecordTypeId', partnershipRecordTypeId);
                                        
                                    }
                                    lstPartnershipInsert.add(ObjPTRecord);
                                    isPTCreate = true;
                                    
                                }
                            
                            }
                                                       
                           
                            
                        }
                    }
                
                
                if (isPTCreate || isLPCreate) {
                    if (lstLimitedPartnerInsert.size() > 0) {
                        if(Account.sObjectType.getDescribe().isCreateable()){
                            insert lstLimitedPartnerInsert;
                        }
                    }
                    if (lstPartnershipInsert.size() > 0) {
                        if(Partnership__c.sObjectType.getDescribe().isCreateable()){
                            insert lstPartnershipInsert;
                        }
                    }
                }
                
                for (Object obj: rawObj) {
                    boolean isNewLimitesPartner = false;
                    boolean isNewPartnership = false;
                    SObject ObjCommitment = new Commitment__c();
                    for(Integer i=0; i<arryComtLeftSideApiName.size();i++)
                    {
                        if(mapCommitmentFields.get(arryComtLeftSideApiName[i].toLowerCase()).getDescribe().isUpdateable())
                           ObjCommitment.put(arryComtLeftSideApiName[i],ObjCommitmentField.get(arryComtLeftSideApiName[i]));  
                    } 
                    for(Integer j=0; j<arryComtRightSideApiName.size();j++)
                    {
                        if(mapCommitmentFields.get(arryComtRightSideApiName[j].toLowerCase()).getDescribe().isUpdateable())
                        ObjCommitment.put(arryComtRightSideApiName[j],ObjCommitmentField.get(arryComtRightSideApiName[j]));  
                    }
                      
                    Map < String, Object > map1 = (Map < String, Object > ) obj;
                    if (map1.get('limited_partner') != null && map1.get('partnership') != null) {
                        Map < String, Object > map2 = (Map < String, Object > ) map1.get('limited_partner');
                        Map < String, Object > map3 = (Map < String, Object > ) map1.get('partnership');
                        
                        
                        Map < String, Object > map4 = (Map < String, Object > ) map1.get('additional_Information');
                       if (map2.containsKey('id') != true) {
                           String AccountLPName = (String) map2.get('Name');
                           if (lstLimitedPartnerInsert.size() > 0) {
                                for (SObject objRecordLP: lstLimitedPartnerInsert) {
                                    
                                    if (objRecordLP.get('Name') == AccountLPName) {
                                        isNewLimitesPartner = true;
                                        ObjCommitment.put('Limited_Partner__c', objRecordLP.id);
                                    }
                                }
                            }
                       }
                       if (map3.containsKey('id') != true) {
                          String partrnershipName = (String) map3.get('Name');
                        if (lstPartnershipInsert.size() > 0) {
                            for (SObject objRecordPT: lstPartnershipInsert) {
                                if (objRecordPT.get('Name') == partrnershipName) {
                                    isNewPartnership = true;
                                    ObjCommitment.put('Partnership__c', objRecordPT.id);
                                }
                            }
                        }
                       }
                        if (!isNewLimitesPartner) {
                            ObjCommitment.put('Limited_Partner__c', (Id) map2.get('id'));
                        }
                        if (!isNewPartnership) {
                            ObjCommitment.put('Partnership__c', (Id) map3.get('id'));
                        }
                        if (companyRTId != null) {
                            
                            ObjCommitment.put('Portfolio_Company__c', companyRTId);
                        }
                        if (map1.get('amount') != '' && map1.get('amount') != null)
                            ObjCommitment.put('Commitment_Amount_nearest__c', Decimal.valueOf((String) map1.get('amount')));
                        if (map1.get('Comitdate') != '' && map1.get('Comitdate') != null)
                            ObjCommitment.put('Final_Commitment_Date__c', date.parse((String) map1.get('Comitdate')));
                        if(strFundraisingValue !='' && strFundraisingValue != null)
                        {
                            ObjCommitment.put('Fundraising__c',strFundraisingValue);  
                        }  
                       
                        lstCommitmentRecord.add(ObjCommitment);
                    }
                }
                if (lstCommitmentRecord.size() > 0) {
                    if(Commitment__c.sObjectType.getDescribe().isCreateable()){
                        insert lstCommitmentRecord;
                    }
                    isCommitmentCreated = true;
                }
            }  
                
            
            
        } catch (Exception objExcp) {
            strErrorMessage = objExcp.getMessage();
            
            Database.rollback(svPoint);
            if(strFundCataegory =='Co-investment' && companyRTId == null){
                isCompanyFilled = true;    
            }
            
            // ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, objExcp.getMessage()));
            
        }
        
    }
    /*
Description : This method is use to check company given or not at the time of commitment creation and redirect to previous page. 
Param: NA
Retun Type: pageReference
*/
    public void CreateCompanyPopup() {
        try {
            strErrorMessage = '';
            pageReference pagref;
            isWrongCompany = false;
            isRequiredFieldEmpty = false;
            arrayBlankRequiredFieldData = new List<String>();
            lstNavatarSetup = new List<Navatar_Setup__c>();
            //Added for security issues PE 3.5 By Qadir Khan 07 DEC 2017..
            if(Schema.sObjectType.Navatar_Setup__c.isAccessible() && Schema.sObjectType.Navatar_Setup__c.fields.CCS__c.isAccessible() && Schema.sObjectType.Navatar_Setup__c.fields.CCS_Fundraising__c.isAccessible() && Schema.sObjectType.Navatar_Setup__c.fields.CCS_New_Limited_Partner__c.isAccessible() && Schema.sObjectType.Navatar_Setup__c.fields.CCS_Partnership__c.isAccessible() && Schema.sObjectType.Navatar_Setup__c.fields.CI_Fund_ID__c.isAccessible() && Schema.sObjectType.Navatar_Setup__c.fields.Admin_Setting__c.isAccessible()){
                lstNavatarSetup = [Select CCS__c, CCS_Fundraising__c, CCS_New_Limited_Partner__c, CCS_Partnership__c, CI_Fund_ID__c, Admin_Setting__c from Navatar_Setup__c where Admin_Setting__c = true order by CreatedDate ASC limit 1];
            }
          if (lstNavatarSetup.size() > 0) {          
            if(!mapOfRequiredBlankFiled.isEmpty())
            {
              Map< String, Object> mapRequiredRemove = (Map< String, Object>) JSON.deserializeUntyped(strRequiredFieldRemove);
              for(String objMap : mapOfRequiredBlankFiled.keyset())
              {
                String strFieldRemoved = String.valueOf(mapRequiredRemove.get(mapOfRequiredBlankFiled.get(objMap)));
                strFieldRemoved = strFieldRemoved.subString(1,strFieldRemoved.length()-1);
                if(strFieldRemoved == '' || strFieldRemoved == null)
                {                   
                   arrayBlankRequiredFieldData.add(mapOfRequiredBlankFiled.get(objMap));
                   isRequiredFieldEmpty = true;
                }                  
              }
            }
            if(!isRequiredFieldEmpty)
            {               
             if (isCompanyFilled == false) {
                
                if (strCompName != '' && strCompName != null) {
                    
                    
                    String strCompanyRTId = CompanyWarningLookup.Portfolio_Company__c;
                    if (strCompanyRTId != '' && strCompanyRTId != null) {
                        list < Account > lstCompanyId =  new list < Account >();
                        //Added for security issues PE 3.5 By Qadir Khan 07 DEC 2017..
                        if(Schema.sObjectType.Account.isAccessible() && Schema.sObjectType.Account.fields.name.isAccessible() && Schema.sObjectType.recordtype.isAccessible() && Schema.sObjectType.recordtype.fields.developername.isAccessible()){
                            //Added condition Portfolio_Company recordtype in PE v4.5 By Hemendra 
                            lstCompanyId = [Select Id, Name from Account where Id = : strCompanyRTId AND (recordtype.developername = 'Company' OR RecordType.DeveloperName = 'Portfolio_Company' OR recordtype.developername = 'Property') limit 1];
                        }
                        if (lstCompanyId.size() > 0) {
                            companyRTId = lstCompanyId[0].id;
                            CreateCommitmentData();
                            
                        } else {
                            isWrongCompany = true;
                        }
                        
                        
                    }
                } else {
                    CreateCommitmentData();
                    
                }
                
            }
          }
         else
         {
            isRequiredFieldEmpty = true;
                            
         }           
            
        }
        else
        {
            isAdminSetting = false;
        }           
        } catch (Exception objExcp) {
            strErrorMessage = objExcp.getMessage();
            isCommitmentCreated = false;
            isCompanyFilled = true;
            
        }
        
    }
    
    /*
Description : This method is use to redirect to previous page. 
Param: NA
Retun Type: pageReference
*/
    public pageReference AfterCreateRedirection() {
        pageReference pagref = new pageReference('/'+strSucessUrl);
        pagref.setRedirect(true);
        return pagref;
    }
    
    /*
Description : PE v3.7: Summer 18 lightning navigation fix. 
Param: NA
Retun Type: pageReference
*/
     public pageReference cancel() {
		pageReference pagref;
		pagref = new pageReference(strInstanceURL); 
		if(!(strInstanceURL.startsWith('https://') || strInstanceURL.startsWith('http://'))){ 
			pagref = new pageReference('/' + strInstanceURL); 
		}
         
        pagref.setRedirect(true);
        return pagref;

    }
    
    /*
Description : This method is use to get field name from given api name and object  . 
Param: String,String
Retun Type: list<ObjectFieldApiwrap>
*/
    public list < ObjectFieldApiwrap > getFieldsNameFromApi(String strApinames, String strObjectName) {
        try {
            strErrorMessage = '';
            list < ObjectFieldApiwrap > lstFieldsApi = new list < ObjectFieldApiwrap > ();
            String[] strRTApi = new List < String > ();
            String[] strApis = new List < String > ();
            String[] strFixedApi = new List < String > ();
            Map < String, Schema.SObjectField > mapOfFields = new Map < String, Schema.SObjectField > ();
            
            if (strObjectName == 'Account' && (strApinames != '' && strApinames != null)) {
                strRTApi = strApinames.split(';');
                strAccountRecordType = strRTApi[0];
                strApis = strRTApi[1].split(',');
                strFixedApi = strFixedFieldsLP.split(':');
                
                mapOfFields.putAll(mapAccountFields);
                
            } else if (strApinames != '' && strApinames != null) {
                strApis = strApinames.split(',');
                strFixedApi = strFixedFieldsPT.split(':');
                mapOfFields.putAll(mapPartnershipFields);
            }
            
            for (Integer i = 0; i < strApis.size(); i++) {
                boolean isFixedField = false;
                String[] ArryObjectApis = strApis[i].split(':');
                for (Integer j = 0; j < strFixedApi.size(); j++) {
                    if (strFixedApi[j].toLowerCase() == ArryObjectApis[1].toLowerCase()) {
                        isFixedField = true;
                    }
                }
                if (!isFixedField) {
                    for (String strFieldKey: mapOfFields.keyset()) {
                        boolean isFieldAvialable = mapOfFields.get(strFieldKey).getDescribe().isAccessible();
                        SObjectField sobjectFieldName = mapOfFields.get(strFieldKey);
                        String strFieldNameAPi = String.valueOf(sobjectFieldName);
                        
                        if (isFieldAvialable && (strFieldNameAPi.toLowerCase() == ArryObjectApis[1].toLowerCase())) {
                            ObjectFieldApiwrap objWraper = new ObjectFieldApiwrap();
                            objWraper.objApi = strObjectName;
                            objWraper.fieldApi = ArryObjectApis[1];
                            lstFieldsApi.add(objWraper);
                        }
                    }
                    
                }
            }
            return lstFieldsApi;
        } catch (Exception objExcp) {
            strErrorMessage = objExcp.getMessage();
            return null;
        }
    }
    
    /*
Description : This method is use to check fields data is valid or not . 
Param: NA
Retun Type: void
*/
   
    public void checkDataForLPFields() {
        
        try {
            isPopUpClose = true;
            Account newLPObj = new Account();
            for(Integer i=0; i<lstLPFieldLabelApi.size();i++)
            {   if(mapAccountFields.get(lstLPFieldLabelApi[i].fieldApi.toLowerCase()).getDescribe().isUpdateable())
                  newLPObj.put(lstLPFieldLabelApi[i].fieldApi,objAccount.get(lstLPFieldLabelApi[i].fieldApi));  
            } 
            if(strLPRowName != null && strLPRowName != '')
            { 
                mapOfLPData.put(strLPRowName,newLPObj);
             if(!mapOfRequiredBlankFiled.isEmpty())
               { 
                for(String objMapData : mapOfRequiredBlankFiled.keyset())
                    {
                        String strRowAccount = strLPRowId+'<@>Account';
                        if(mapOfRequiredBlankFiled.get(objMapData).toLowerCase() == strRowAccount.toLowerCase())
                            mapOfRequiredBlankFiled.remove(objMapData);
                    
                    }   
                }   
            }
            

        } catch (Exception objExcp) {
            isPopUpClose = false;
            
        }
     isLPFound = false;  
    }
    public void setLPFieldsData() {
        isLPFound = true;
        try {
            
            if(strLPRowName != null && strLPRowName != '')
            {   
                if(mapOfLPData.get(strLPRowName) != null)
                    objAccount = mapOfLPData.get(strLPRowName);
                else
                    objAccount =new Account();
            }
            
        }
        catch (Exception objExcp) {
            
            strErrorMessage = objExcp.getMessage();
        }
        
    }
     public void checkDataForPTFields() {
        
        try {
            Partnership__c newPTObj = new Partnership__c();
            for(Integer i=0; i<lstPTFieldLabelApi.size();i++)
            {
                if(mapPartnershipFields.get(lstPTFieldLabelApi[i].fieldApi.toLowerCase()).getDescribe().isUpdateable())
                newPTObj.put(lstPTFieldLabelApi[i].fieldApi,objPartnership.get(lstPTFieldLabelApi[i].fieldApi));  
            } 
            
            if(strPTRowName != null && strPTRowName != '')
            { 
              mapOfPTData.put(strPTRowName,newPTObj);
              if(!mapOfRequiredBlankFiled.isEmpty())
                    for(String objMapData : mapOfRequiredBlankFiled.keyset())
                    {
                        String strRowPartnership = strPTRowId+'<@>Partnership';
                        if(mapOfRequiredBlankFiled.get(objMapData).toLowerCase() == strRowPartnership.toLowerCase())
                            mapOfRequiredBlankFiled.remove(objMapData);
                    
                    }                   
            }
            
        } catch (Exception objExcp) {
         strErrorMessage = objExcp.getMessage();
        }
      isPTFound = false;  
    }
    public void setPTFieldsData() {
        isPTFound = true;
        try {
           
            if(strPTRowName != null && strPTRowName != '')
            {   
                if(mapOfPTData.get(strPTRowName) != null)
                    objPartnership = mapOfPTData.get(strPTRowName);
                else
                    objPartnership = new Partnership__c();
            }
            
        } catch (Exception objExcp) {
            strErrorMessage = objExcp.getMessage();   
        }
        
    }
    
    
 
    /*
Description : This method is use to add row. 
Param: NA
Retun Type: void
*/
    
    public void AddRow() {
        
        try {
            strErrorMessage = '';
            wrapCommitmentFields objWrapper = new wrapCommitmentFields();
            objWrapper.rowId = rowCount;
            lstAddedFields.add(objWrapper);
            rowCount = rowCount + 1;
            
            
        } catch (Exception objExcp) {
            strErrorMessage = objExcp.getMessage();
            
            
        }
    }
    
    /*
Description : This method is use to remove row. 
Param: NA
Retun Type: void
*/
    public void RemoveRow() {
        
        try {
            strErrorMessage = ''; 
            Integer lstCount = -1;
            Integer lstIndex = 0;
            if (strDeletedRowId != '' && strDeletedRowId != null) {
                Integer intRowId = Integer.valueOf(strDeletedRowId);
                for (wrapCommitmentFields objWrap: lstAddedFields) {
                    lstCount = lstCount + 1;
                    if (objWrap.rowId == intRowId) {
                        lstIndex = lstCount;
                    }
                }
                
                if (lstIndex > 0) {
                    lstAddedFields.remove(lstIndex);
                    
                }
            }
            
            
        } catch (Exception objExcp) {
            strErrorMessage = objExcp.getMessage();
            
            
        }
    }
    
    /*
Description : This method is use to get default record type ID of given object. 
Param: String
Retun Type: Id
*/
    public Id getRecordtypeObjectName(String objectName) {
        
        try {
            strErrorMessage = '';  
            Id strRecordTypeId;
            String strNameObject = objectName.toLowerCase();
            Schema.DescribeSObjectResult dsr = Schema.getGlobalDescribe().get(strNameObject).getDescribe();
            for (Schema.RecordTypeInfo defaultRecordType: dsr.getRecordTypeInfos()) {
                if (defaultRecordType.isDefaultRecordTypeMapping() && defaultRecordType.isAvailable()) {
                    strRecordTypeId = defaultRecordType.getRecordTypeId();
                    
                }
            }
            
            return strRecordTypeId;
        } catch (Exception objExcp) {
            strErrorMessage = objExcp.getMessage();
            
            return null;
        }
    }
    
   
    public class ObjectFieldApiwrap {
        public String objApi {
            get;
            set;
        }
        public String fieldApi {
            get;
            set;
        }
        
        public ObjectFieldApiwrap() {}
    }
    
    
    
    public class wrapCommitmentFields {
        public String limited_partner {
            get;
            set;
        }
        public String partnership {
            get;
            set;
        }
        public String amount {
            get;
            set;
        }
        public Commitment__c ComitObj {
            get;
            set;
        }
        public Integer rowId {
            get;
            set;
        }
        public wrapCommitmentFields() {
            ComitObj = new Commitment__c();
            
            
        }
        
        
    }
    
    
    
    
}