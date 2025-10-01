/*********************************************************************************
** Module Name : Deal Creation Setup
** Description : This is used setup page layout for deal creation page.
** Throws : NA
** Calls : NA
** Test Class : NA
** Organization : Navatar Group
** Revision History:-
** Version Date(YYYY-MM-DD)      Author  Description of Action
** 1.0     2016-06-02            Pramod  
*********************************************************************************/
public with Sharing class Deal_Creation_Setup_Ctlr{   
    public string strFieldApiNameDeal{get;set;}         //used to get field api for deal
    public string strFieldApiNameAccount{get;set;}      //used to ger field api for account
    public string strFieldApiNameContact{get;set;}      //used to ger field api for contact
    public string selField{get;set;}                    //used to store input field value   
    public string nameSpace{get;set;}                   //used to get org name space    
    
    public Map<string, string> AccountFieldLabelVsApi{get;set;}     //used to map account field api
    public Map<string, string> ContactFieldLabelVsApi{get;set;}     //used to map contact field api
    public Map<string, string> AccountAndPipelineFieldLabelVsApi{get;set;}    //used to map account and pipeline field api
     
    public string selectedRecorTypeForDeal{get;set;}        //store record type for deal
    public string selectedRecorTypeForAccount{get;set;}     //store record type for account
  
    public boolean showEditSection{get;set;}         //used to show edit section on page
    public boolean showdetailSection{get;set;}       //used to show detail section on page
    public boolean isEnableDealCreation{get;set;}   //used to check is deal creation enable
   
    public List<Navatar_Setup__c> lstNavSetup;      //used to query object api from navatar setup
    public Navatar_Setup__c objNavSetup;            //store navatar setup record
    
    public Map<string, string> mapApiVsFieldLabel{get;set;}   //used to map field label and api
    public string strFieldApiName{get;set;}             //used to store field api
   
    public Boolean isAdminSettingOn{get;set;} 
    public Boolean isUserSystemAdmin{get;set;}  
    
    public string strDealRTDetailPage{get;set;}  //contain deal record type
    public string strFirmRTDetailPage{get;set;}  //contain firm record type
    public List<Org_Setting__mdt> orgSetMdt;     //store deal setting for deal    
    public List<String> lstDefaultField{get;set;}             //contains defaut field which is used on page       
    public String strPageName{get;set;}
    public String strErrorMessage{get;set;}
    public String sCompanyName {get;set;}   // Store Current Company lebel on pipeline in PE v4.5
    
    public Deal_Creation_Setup_Ctlr()
    {
        try
        {           
            showdetailSection= true;  showEditSection= false; isAdminSettingOn = false;
            strFieldApiName=''; isUserSystemAdmin = false;
            strFieldApiNameDeal=''; strFieldApiNameAccount='';strFieldApiNameContact='';
            mapApiVsFieldLabel = new map<string ,string>();
            nameSpace = CommonUtility.strNameSpacePrefix;
			sCompanyName = CommonUtility.chkmasterLookupInPiplineAPI();  // Get Current Company lebel on pipeline in PE v4.5  By Rahulk
            objNavSetup = new Navatar_Setup__c();       
            if(Schema.sObjectType.Navatar_Setup__c.isAccessible() && Schema.sObjectType.Navatar_Setup__c.fields.DCS__c.isAccessible() && Schema.sObjectType.Navatar_Setup__c.fields.admin_setting__c.isAccessible() && Schema.sObjectType.Navatar_Setup__c.fields.DCS_New_Company__c.isAccessible() && Schema.sObjectType.Navatar_Setup__c.fields.DCS_New_Source_Contact__c.isAccessible() && Schema.sObjectType.Navatar_Setup__c.fields.DCS_New_Source_Firm__c.isAccessible()){
                lstNavSetup =[select id,DCS__c,admin_setting__c,DCS_New_Company__c,DCS_New_Source_Contact__c,DCS_New_Source_Firm__c FROM Navatar_Setup__c where admin_setting__c=true Limit 1];
            }
            orgSetMdt = new List<Org_Setting__mdt>();
            if(Schema.sObjectType.Org_Setting__mdt.isAccessible() && Schema.sObjectType.Org_Setting__mdt.fields.IsActive__c.isAccessible() && Schema.sObjectType.Org_Setting__mdt.fields.label.isAccessible() && Schema.sObjectType.Org_Setting__mdt.fields.developername.isAccessible()){
                orgSetMdt =[SELECT IsActive__c,label,developername FROM Org_Setting__mdt where developername ='Deal_Creation' limit 1];
            }
            Profile usrProfile =  new Profile();
            if(Schema.sObjectType.Profile.isAccessible() && Schema.sObjectType.Profile.fields.name.isAccessible())
                usrProfile = [Select Name from Profile where Id =: userinfo.getProfileid()];
            if(usrProfile!=null){
                if(usrProfile.name=='System Administrator'){                    
                    isUserSystemAdmin = true; 
                }
            }
			//Added Dynamic Company Api  in PE v4.5  By Rahulk
			lstDefaultField = new List<String> {''+nameSpace+'Pipeline__c:Name',''+nameSpace+'Pipeline__c:'+nameSpace+'Source__c',''+nameSpace+'pipeline__c:'+nameSpace+sCompanyName,''+nameSpace+'Pipeline__c:'+nameSpace+'Source_Company__c',''+nameSpace+'Pipeline__c:'+nameSpace+'Source_Contact__c',''+nameSpace+'Pipeline__c:'+nameSpace+'Stage__c','Account:Name','Contact:LastName','Contact:AccountId'};
            lstDefaultField.add('Contact:ownerid');
            for(String str: lstDefaultField){           
                mapApiVsFieldLabel.put(str.toLowerCase(),'');
            }            
            describeSObjectSample();
            if(orgSetMdt.size()>0){
                isEnableDealCreation = orgSetMdt[0].IsActive__c;
            }           
            if(lstNavSetup.size()>0){
                objNavSetup= lstNavSetup[0]; isAdminSettingOn = true;
                List<string> lstFieldValue= new List<string>();               
                Set<String> setMapKesetValue = AccountAndPipelineFieldLabelVsApi.keySet();
                
                if(objNavSetup.DCS__c!= null && objNavSetup.DCS__c!= '') {                    
                    lstFieldValue = objNavSetup.DCS__c.toLowerCase().split(';');                    
                    for(integer i=0; i<lstFieldValue.Size(); i++){
                        if(i==0){
                            for(String str: lstFieldValue[i].split(',')){                               
                                if(!mapApiVsFieldLabel.keySet().contains(str)){
                                    if(setMapKesetValue.contains(str)==true){                                        
                                        if(string.isBlank(strFieldApiNameDeal))                                
                                            strFieldApiNameDeal = str;
                                        else
                                            strFieldApiNameDeal = strFieldApiNameDeal +','+str;
                                    }
                                }
                            }
                            strFieldApiNameDeal = strFieldApiNameDeal +';'; 
                        }
                        if(i==1){
                            for(String str: lstFieldValue[i].split(',')){ 
                                if(!mapApiVsFieldLabel.keySet().contains(str)){
                                   if(setMapKesetValue.contains(str)==true){
                                        if(string.isBlank(strFieldApiNameDeal))                               
                                            strFieldApiNameDeal = str;
                                        else
                                            strFieldApiNameDeal = strFieldApiNameDeal+str+',';
                                   }
                                }
                            }                       
                        }                           
                    }
                }
                strFieldApiNameDeal = strFieldApiNameDeal.removeEnd(',');                
                setMapKesetValue = AccountFieldLabelVsApi.keySet();
                if(objNavSetup.DCS_New_Source_Firm__c!= null && objNavSetup.DCS_New_Source_Firm__c!= '') {              
                    lstFieldValue = objNavSetup.DCS_New_Source_Firm__c.toLowerCase().split(';');                    
                    for(integer i=0; i<lstFieldValue.Size(); i++){
                        if(i==0){
                            for(String str: lstFieldValue[i].split(',')){ 
                                if(!mapApiVsFieldLabel.keySet().contains(str)){
                                    if(setMapKesetValue.contains(str)==true){                                        
                                        if(string.isBlank(strFieldApiNameAccount))                                
                                            strFieldApiNameAccount = str;
                                        else
                                            strFieldApiNameAccount = strFieldApiNameAccount +','+str;
                                    }
                                }
                            }
                            strFieldApiNameAccount = strFieldApiNameAccount +';'; 
                        }
                        if(i==1){
                            for(String str: lstFieldValue[i].split(',')){  
                                if(!mapApiVsFieldLabel.keySet().contains(str)){
                                    if(setMapKesetValue.contains(str)==true){
                                        if(string.isBlank(strFieldApiNameAccount))                               
                                            strFieldApiNameAccount = str;
                                        else
                                            strFieldApiNameAccount = strFieldApiNameAccount+str+',';
                                    }
                                }
                            }                       
                        }                           
                    }                   
                }
                strFieldApiNameAccount = strFieldApiNameAccount.removeEnd(',');
                setMapKesetValue = ContactFieldLabelVsApi.keySet();
                if(objNavSetup.DCS_New_Source_Contact__c!= null && objNavSetup.DCS_New_Source_Contact__c!= ''){                 
                    lstFieldValue = objNavSetup.DCS_New_Source_Contact__c.toLowerCase().split(','); 
                    for(String str: lstFieldValue){ 
                        if(!mapApiVsFieldLabel.keySet().contains(str)){
                            if(setMapKesetValue.contains(str)==true){                                        
                                if(string.isBlank(strFieldApiNameContact))                                
                                    strFieldApiNameContact = str;
                                else
                                    strFieldApiNameContact = strFieldApiNameContact +','+str;
                            }
                        }
                    }
                } 
                setRecordType();
            } 
            
        }catch(Exception ex) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Exception in Constructor : '+ex)); 
        }
    }
    Map<string,string> mapOfRT= new Map<string,String>();
    Map<string,string> mapOfRT2= new Map<string,string>();
     
    /*
    @Description: Method is used to get recordtype.
    @Parameter1: variable mapOfRT ,mapOfRT2 is used to map recordtype id and name.
    */  
    public List<SelectOption> getRecordType() {        
        
        List<SelectOption> options = new List<SelectOption>();
        try
        {    
            List<RecordType> accRecTypeList = new List<RecordType>();
            if(Schema.sObjectType.RecordType.isAccessible() && Schema.sObjectType.RecordType.fields.name.isAccessible() && Schema.sObjectType.RecordType.fields.isActive.isAccessible() && Schema.sObjectType.RecordType.fields.DeveloperName.isAccessible()){
                accRecTypeList = [select id,name,isActive,DeveloperName from RecordType where sObjecttype = 'Account' And isActive =true];
            }
            for(RecordType rt: accRecTypeList){
                options.add(new SelectOption(rt.DeveloperName,rt.name));
                mapOfRT.put(rt.DeveloperName,rt.name);
                mapOfRT2.put(rt.DeveloperName,rt.DeveloperName);
            }
        }catch(Exception ex) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Exception in getRecordType : '+ex)); 
        }
        return options;
    }
    
    /*
    @Description: Method is used to set recordtype.
    @Parameter1: variable strDealRTDetailPage ,strFirmRTDetailPage is used to store recordtype id and name.
    */  
    public void setRecordType(){        
        try
        {
            getRecordType(); 
            if(objNavSetup.DCS_New_Company__c!= null && objNavSetup.DCS_New_Source_Firm__c!= null){
                if(mapOfRT.get(objNavSetup.DCS_New_Company__c)!=null)
                strDealRTDetailPage = mapOfRT.get(objNavSetup.DCS_New_Company__c);
                if(objNavSetup.DCS_New_Source_Firm__c!=null)
                strFirmRTDetailPage = mapOfRT.get((objNavSetup.DCS_New_Source_Firm__c).split(';')[0]);  
                if(String.Isblank(strDealRTDetailPage)){
                    strErrorMessage = 'The assigned record type has either been deleted or is unavailable for use. If no record type is assigned, the Deal will get created with the system default record type.';
                }else if(String.Isblank(strFirmRTDetailPage)){
                    strErrorMessage = 'The assigned record type has either been deleted or is unavailable for use. If no record type is assigned, the Deal will get created with the system default record type.';
                }
            } 
        }catch(Exception ex) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Exception in setRecordType method : '+ex)); 
        }        
    }
    
    /*
    @Description: Method called on click save deal creation button.
    @Parameter1: Variable strDealRTDetailPage ,strFirmRTDetailPage is used to store recordtype id and name.
    */  
    public PageReference onclickSaveButton(){     
        try
        {               
            showdetailSection= true; showEditSection= false;  
            lstNavSetup = new List<Navatar_Setup__c>();
            if(Schema.sObjectType.Navatar_Setup__c.isAccessible() && Schema.sObjectType.Navatar_Setup__c.fields.DCS__c.isAccessible() && Schema.sObjectType.Navatar_Setup__c.fields.admin_setting__c.isAccessible() && Schema.sObjectType.Navatar_Setup__c.fields.DCS_New_Company__c.isAccessible() && Schema.sObjectType.Navatar_Setup__c.fields.DCS_New_Source_Contact__c.isAccessible() && Schema.sObjectType.Navatar_Setup__c.fields.DCS_New_Source_Firm__c.isAccessible()){
                lstNavSetup= [SELECT DCS__c,admin_setting__c,DCS_New_Company__c,DCS_New_Source_Contact__c,DCS_New_Source_Firm__c FROM Navatar_Setup__c where admin_setting__c=true Limit 1];
            }
            if(lstNavSetup.Size()>0){ 
                List<String> lstStrContent= strFieldApiName.split('<@>');
                List<String> lstStrFirm= lstStrContent[1].split(';');                
                
                if(lstStrContent[0]!='NA' && Schema.sObjectType.Navatar_Setup__c.fields.DCS__c.isUpdateable()){ 
                    objNavSetup.DCS__c= lstStrContent[0];
				 }
                if(lstStrContent[1]!='NA' && Schema.sObjectType.Navatar_Setup__c.fields.DCS_New_Source_Firm__c.isUpdateable()){ 
                    objNavSetup.DCS_New_Source_Firm__c=  selectedRecorTypeForAccount+';'+lstStrFirm[1];
                }
                if(Schema.sObjectType.Navatar_Setup__c.fields.DCS_New_Source_Contact__c.isUpdateable()){
                    if(lstStrContent[2]!='NA') 
                        objNavSetup.DCS_New_Source_Contact__c= lstStrContent[2];
                    else
                        objNavSetup.DCS_New_Source_Contact__c= '';  
                }
                if(Schema.sObjectType.Navatar_Setup__c.fields.DCS_New_Company__c.isUpdateable()){
                    objNavSetup.DCS_New_Company__c= selectedRecorTypeForDeal;               
                }
                
                if(orgSetMdt.size() >0){           
                    CustomMetadataService.updateMetadata(new List<SObject> {orgSetMdt[0]}, isEnableDealCreation);                
                }
                if(Schema.sObjectType.Navatar_Setup__c.isUpdateable() && objNavSetup!= null ){
                        update objNavSetup;
                    }
                 
            }
              
        }catch(Exception ex) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Exception in onclickSaveButton method : '+ex.getLineNumber())); 
        }
        PageReference orderPage = new PageReference('/apex/Deal_Creation_setup');
        orderPage.setRedirect(true);
        return orderPage;       
    }
    
    /*
    @Description: Method called on click cancel button.
    @Parameter1: Variable showdetailSection is used to show detail section.
    */
    public PageReference onCancel(){
        showdetailSection= true; showEditSection= false;
        PageReference orderPage = new PageReference('/apex/Deal_Creation_setup');
        orderPage.setRedirect(true);
        return orderPage;         
    }
    
    /*
    @Description: Method called on click revert to default button.
    @Parameter1: Variable defaultRecordTypeId is used to store default recordtype id.
    */
    string defaultRecordTypeId;
    public PageReference onRevertToDefault(){         
        try
        {           
            List<Schema.RecordTypeInfo> infos = Schema.SObjectType.Account.RecordTypeInfos;         
            for (Schema.RecordTypeInfo info : infos) {
              if (info.DefaultRecordTypeMapping) { 
                if(Schema.sObjectType.recordtype.isAccessible() && Schema.sObjectType.RecordType.fields.isActive.isAccessible() && Schema.sObjectType.RecordType.fields.DeveloperName.isAccessible()){
                    defaultRecordTypeId = [Select id, developername FROM recordtype where id=:info.RecordTypeId AND isActive=true].developername;
                }
              }
            } 
            
            if(Schema.sObjectType.Navatar_Setup__c.fields.DCS_New_Company__c.isUpdateable()){
                if(mapOfRT2.containsKey('Company')){
                    objNavSetup.DCS_New_Company__c= mapOfRT2.get('Company');
                }           
                else{
                    objNavSetup.DCS_New_Company__c= defaultRecordTypeId; // store default record type           
                }  
            }
            
            if(Schema.sObjectType.Navatar_Setup__c.fields.DCS_New_Source_Firm__c.isUpdateable()){
                if(mapOfRT2.containsKey('Institution')){
                    objNavSetup.DCS_New_Source_Firm__c= string.valueOf(mapOfRT2.get('Institution'))+';';
                }
                else{
                    objNavSetup.DCS_New_Source_Firm__c= defaultRecordTypeId+';'; // store default record type   
                }    
            }
            
            if(Schema.sObjectType.Navatar_Setup__c.fields.DCS_New_Source_Contact__c.isUpdateable()){
                objNavSetup.DCS_New_Source_Contact__c='';
            }
            if(Schema.sObjectType.Navatar_Setup__c.fields.DCS__c.isUpdateable()){
                objNavSetup.DCS__c='';
            }
            if(Schema.sObjectType.Navatar_Setup__c.isUpdateable() && objNavSetup!= null ){
                    update objNavSetup;
             }
            
            
        }catch(Exception ex) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Exception in onRevertToDefault method : '+ex)); 
        }       
        PageReference orderPage = new PageReference('/apex/Deal_Creation_setup');
        orderPage.setRedirect(true);
        return orderPage;
    }
    
    /*
    @Description: Method called on click edit button.
    @Parameter1: Variable showEditSection is used to show detail page.
    */
    public void fetchEditSectionValue(){        
        try
        {   
            showEditSection= true; showdetailSection= false; 
            List<RecordType> rtList= new List<RecordType>();
            lstNavSetup = new List<Navatar_Setup__c>();
            if(Schema.sObjectType.Navatar_Setup__c.isAccessible() && Schema.sObjectType.Navatar_Setup__c.fields.DCS__c.isAccessible() && Schema.sObjectType.Navatar_Setup__c.fields.admin_setting__c.isAccessible() && Schema.sObjectType.Navatar_Setup__c.fields.DCS_New_Company__c.isAccessible() && Schema.sObjectType.Navatar_Setup__c.fields.DCS_New_Source_Contact__c.isAccessible() && Schema.sObjectType.Navatar_Setup__c.fields.DCS_New_Source_Firm__c.isAccessible()){
                lstNavSetup =[select id,DCS__c,admin_setting__c,DCS_New_Company__c,DCS_New_Source_Contact__c,DCS_New_Source_Firm__c FROM Navatar_Setup__c where admin_setting__c=true Limit 1];
            }
            if(lstNavSetup.size()>0){   
                objNavSetup= lstNavSetup[0]; 
            }  
            if(String.Isblank(strDealRTDetailPage)){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'The assigned record type has either been deleted or is unavailable for use. If no record type is assigned, the Deal will get created with the system default record type.'));
            }else if(String.Isblank(strFirmRTDetailPage)){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'The assigned record type has either been deleted or is unavailable for use. If no record type is assigned, the Deal will get created with the system default record type.'));
            }
            selectedRecorTypeForDeal= objNavSetup.DCS_New_Company__c;
            if(Schema.sObjectType.RecordType.isAccessible() && Schema.sObjectType.RecordType.fields.isActive.isAccessible() && Schema.sObjectType.RecordType.fields.DeveloperName.isAccessible() && Schema.sObjectType.RecordType.fields.name.isAccessible()){
                rtList = [SELECT id, name ,developername FROM RecordType where sObjecttype = 'Account' And developername=:selectedRecorTypeForDeal AND isActive = True];
            }
            if(rtList.size()>0){                
                selectedRecorTypeForDeal = rtList[0].developername;
            }else{
                for(Schema.RecordTypeInfo rtInfo : Account.SObjectType.getDescribe().getRecordTypeInfos()){
                    if (rtInfo.isDefaultRecordTypeMapping()) {
                        if(Schema.sObjectType.RecordType.isAccessible() && Schema.sObjectType.RecordType.fields.isActive.isAccessible() && Schema.sObjectType.RecordType.fields.DeveloperName.isAccessible()){                        
                            selectedRecorTypeForDeal = [Select id, developername FROM recordtype where id=:rtInfo.RecordTypeId AND isActive=true].developername; 
                        }
                    }
                }
            }
            rtList.clear();
            if(objNavSetup.DCS_New_Source_Firm__c!=null){
                selectedRecorTypeForAccount= (objNavSetup.DCS_New_Source_Firm__c).split(';')[0]; 
                if(Schema.sObjectType.RecordType.isAccessible() && Schema.sObjectType.RecordType.fields.isActive.isAccessible() && Schema.sObjectType.RecordType.fields.DeveloperName.isAccessible() && Schema.sObjectType.RecordType.fields.name.isAccessible()){
                    rtList = [SELECT id, name ,developername FROM RecordType where sObjecttype = 'Account' And developername=:selectedRecorTypeForAccount AND isActive = True];
                }
                if(rtList.size()>0){                
                    selectedRecorTypeForAccount = rtList[0].developername;
                }else{
                    for(Schema.RecordTypeInfo rtInfo : Account.SObjectType.getDescribe().getRecordTypeInfos()){
                        if (rtInfo.isDefaultRecordTypeMapping()) { 
                            if(Schema.sObjectType.RecordType.isAccessible() && Schema.sObjectType.RecordType.fields.isActive.isAccessible() && Schema.sObjectType.RecordType.fields.DeveloperName.isAccessible()){
                                selectedRecorTypeForAccount =  [Select id, developername FROM recordtype where id=:rtInfo.RecordTypeId AND isActive=true].developername;
                            }
                        }
                    }
                }                     
            }
            
        }catch(Exception ex) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Exception in fetchEditSectionValue method : '+ex)); 
        }
    }
    
    /*
    @Description: Method called on click page name to redirect page.   
    */ 
    public PageReference redirectpage() {
        PageReference pageRef = new PageReference('/apex/'+strPageName+'');
        pageRef.setRedirect(true);
        return pageRef;
    }
    
    /*
    @Description: Method called on page load.
    @Parameter1: Variable AccountFieldLabelVsApi is used to store account field api.
    */
    public void describeSObjectSample() 
    {
        try 
        {        
            AccountFieldLabelVsApi= new Map<string, string>();
            ContactFieldLabelVsApi= new Map<string, string>();
            AccountAndPipelineFieldLabelVsApi= new Map<string, string>();
            List<string> lstAccountandPipeline = new List<string>();
            lstAccountandPipeline.add('account'); 
            lstAccountandPipeline.add(''+nameSpace.toLowerCase()+'pipeline__c'); 
            AccountAndPipelineFieldLabelVsApi= CommonUtility.describeSObject(lstAccountandPipeline);
			// Set Select values option accroding to pipeline Company relationship in PE v4.5 By Rahulk
            if (Schema.getGlobalDescribe().get(nameSpace+'Pipeline__c').getDescribe().fields.getMap().containsKey(nameSpace+CommonUtility.oldAccountPiplineFieldName)) {
                AccountAndPipelineFieldLabelVsApi.remove(nameSpace.toLowerCase()+'pipeline__c:'+nameSpace.toLowerCase()+CommonUtility.newAccountPiplineFieldName.toLowerCase());
            } else {
				AccountAndPipelineFieldLabelVsApi.remove(nameSpace.toLowerCase()+'pipeline__c:'+nameSpace.toLowerCase()+CommonUtility.oldAccountPiplineFieldName.toLowerCase());
            }
            List<String> lstAccount= new List<String>();
            lstAccount.add('account');
            AccountFieldLabelVsApi= CommonUtility.describeSObject(lstAccount); 
            List<String> lstContact= new List<String>();
            lstContact.add('contact');
            ContactFieldLabelVsApi= CommonUtility.describeSObject(lstContact); 
            /*Update Record Type Lable for Bug(00029364) fixing in PE4.5 by Rahulk*/
            if (ContactFieldLabelVsApi.containsKey('contact:recordtypeid') &&  ContactFieldLabelVsApi.get('contact:recordtypeid')=='Contact:Record Type ID' ) {
                ContactFieldLabelVsApi.put('contact:recordtypeid','Contact:Record Type');
            }            
        }catch(Exception ex) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Exception in describeSObjectSample : '+ex)); 
        }
    }
        
}