/*********************************************************************************
** Module Name : Deal Creation
** Description : This is used for Quick Create Deal.
** Throws : NA
** Calls : NA
** Test Class : NA
** Organization : Navatar Group
** Revision History:-
** Version  Date(YYYY-MM-DD)       Author  Description of Action
** 1.0      2016-06-20             Pramod  
** 2.0      2018-08-03             Qadir    PE v3.7: Summer 18 lightning navigation fix.  
*********************************************************************************/
global with Sharing class Deal_Creation_Ctlr{    
    public Boolean isEditSourceContact{get; set;}               // to check source contact info is edit
    public Boolean isEditSourceFirm{get; set;}                  // to check source firm is edit
    public String inputValue{get; set;}                         // store input value on page 
    public Account objAccount{get;set;}                         // used for insert company record
    public Account objSourceAccount{get;set;}                   // used for insert institution record
    public Pipeline__c objPipeline{get;set;}                    // used for insert pipeline record
    public Pipeline__c objSourcePipeline{get;set;}              // used for get pipeline fields value from page
    public Contact objSourceContact{get;set;}                   // used for get contact fields value from page
    public Contact objContact{get;set;}                         // used for insert company record
    public List<objectfield> leftColumnObjectFieldList{get;set;}    //store deal info left section fields
    public List<objectfield> rightColumnObjectFieldList{get;set;}   //store deal info right section fields
    public List<objectfield> sourceFirmPopuFieldList{get;set;}      //store source firm popup section fields
    public List<objectfield> sourceContactPopuFieldList{get;set;}   //store source contact popup section fields
    public List<Navatar_Setup__c> lstNavSetup{get; set;}        // to get the fields for deal creation from navatar setup object    
    public String strErrorMessage{get; set;}                    // store error message
    public String strSourceFirmName{get; set;}             // store source firm fields
    public String strSourceContactName{get; set;}          // store source contact fields
    public String strNameSpace{get; set;}                       // store name space 
    public Static String strSobjNameSpace{get; set;}            // store name space 
    public Map<String, String> FieldLabelVsApi{get;set;}        //store sbject fields api and Label  
    public String strRecordTypeId{get; set;}                    // store instution recordtype id
    public String strCompanyRecordType{get; set;}               // store company recordtype id
    public Set<String> setPgLayoutRequiredField{get; set;}      // contains required fields
    public Set<String> setSourcePgLayoutReqField{get; set;}      // contains required fields
    public String strRequiredField{get; set;}                   // store required fields
    public List<String> dcsNewSourceContactList;
    public List<String> dcsNewSourceFirm;
    public String strSourcePopupReqField{get; set;}
    public Boolean isEnableDealCreation{get; set;}
    public Static Boolean isContCreateable{get; set;}
    public Static Boolean isContAccessible{get; set;}
    public Static Boolean isPiplnCreateable{get; set;}
    public Static Boolean isAccCreateable{get; set;}
    public Static Schema.DescribeSObjectResult sobjPipeline;
    public Static Schema.DescribeSObjectResult contDescribe;
    public Static Schema.DescribeSObjectResult accDescribe;
    public Static string errormsg{get; set;}
    public Map<string, string> FieldApiVsFieldType{get; set;}
    public Static String errorMessage{get;set;}
    public List<RecordType> rtList;
    public Boolean isAdminSettingOn{get;set;}
    public String strAdminSettingError{get;set;}
    public String strAccountLabel;
    public String strContactLabel;
    public String strPipelineLabel;   
    public String sCompanyName {get;set;}  // Store Current Company lebel on pipeline in PE v4.5
    public Boolean isMasterRTforContact{get;set;} // Store master recordtype availability for Contact  in PE v4.5
    public Boolean isCompanyReq{get;set;} // Store Company is required  or Not for Remove account dependency for Pipeline
    public Deal_Creation_Ctlr(){ 
        List<Org_Setting__mdt> orgSetMdt = new List<Org_Setting__mdt>();
        if(Schema.sObjectType.Navatar_Setup__c.isAccessible() && Schema.sObjectType.Navatar_Setup__c.fields.dcs__c.isAccessible() && Schema.sObjectType.Navatar_Setup__c.fields.dcs_new_company__c.isAccessible() && Schema.sObjectType.Navatar_Setup__c.fields.dcs_new_source_contact__c.isAccessible() && Schema.sObjectType.Navatar_Setup__c.fields.dcs_new_source_firm__c.isAccessible() && Schema.sObjectType.Navatar_Setup__c.fields.admin_setting__c.isAccessible()){
            lstNavSetup =[SELECT dcs__c,dcs_new_company__c,dcs_new_source_contact__c,dcs_new_source_firm__c,admin_setting__c FROM Navatar_Setup__c where admin_setting__c=true Limit 1];
        }
        if(Schema.sObjectType.Org_Setting__mdt.isAccessible() && Schema.sObjectType.Org_Setting__mdt.fields.IsActive__c.isAccessible() && Schema.sObjectType.Org_Setting__mdt.fields.label.isAccessible() && Schema.sObjectType.Org_Setting__mdt.fields.developername.isAccessible()){
            orgSetMdt =[SELECT IsActive__c,label,developername FROM Org_Setting__mdt where developername ='Deal_Creation' limit 1];
        }
        errorMessage=''; errormsg = ''; strAccountLabel ='';
        strContactLabel = ''; strPipelineLabel = '';
        isAdminSettingOn = false; strAdminSettingError ='';
        contDescribe = Contact.sObjectType.getDescribe();
        accDescribe =  Account.sObjectType.getDescribe();           
        sobjPipeline = Pipeline__c.sObjectType.getDescribe();
        isContCreateable = contDescribe.isCreateable(); 
        isContAccessible = contDescribe.isAccessible(); 
        isPiplnCreateable = sobjPipeline.isCreateable();
        isAccCreateable = accDescribe.isCreateable();
        strAccountLabel = accDescribe.getLabel();
        strContactLabel = contDescribe.getLabel();
        strPipelineLabel = sobjPipeline.getLabel();     
        FieldApiVsFieldType = new Map<string, string>();        
        objAccount = new Account();
        objSourceAccount = new Account();
        objPipeline = new Pipeline__c();
        objSourcePipeline = new Pipeline__c();
        objSourceContact = new Contact();
        objContact = new Contact();
        isMasterRTforContact = false;
        isCompanyReq = false;
        leftColumnObjectFieldList = new List<objectfield>();  
        rightColumnObjectFieldList = new List<objectfield>();                  
        strNameSpace = CommonUtility.strNameSpacePrefix; 
        sourceFirmPopuFieldList = new List<objectfield>(); 
        sourceContactPopuFieldList = new List<objectfield>(); 
        List<String> lstObject = new List<String>();        
        lstObject.add('Contact');
        lstObject.add(''+strNameSpace+'Pipeline__c');
        lstObject.add('Account');       
        FieldLabelVsApi = describeSObject(lstObject); //get field lavel and api of sobject fields
        if(lstNavSetup.size()>0){
            isAdminSettingOn = true; 
            if(!string.Isblank(lstNavSetup[0].dcs_new_source_contact__c)){   
                dcsNewSourceContactList = lstNavSetup[0].dcs_new_source_contact__c.split(',');
                if(dcsNewSourceContactList.size()>0)
                    isEditSourceContact = true; 
            }           
            if(!string.Isblank(lstNavSetup[0].dcs_new_source_firm__c)){                         
                dcsNewSourceFirm = lstNavSetup[0].dcs_new_source_firm__c.split(';');
                if(dcsNewSourceFirm.size()>1 && !string.valueof(dcsNewSourceFirm).contains('NA'))
                    isEditSourceFirm = true; 
            }
        }else{
            strAdminSettingError = 'Code: 12355. Please contact Navatar Support. System setup improperly.';
        }
        if(orgSetMdt.size()>0){
            if(orgSetMdt[0].IsActive__c==true){
                isEnableDealCreation = orgSetMdt[0].IsActive__c;
            }    
        }
        // Get Current Company lebel on pipeline in  PE v4.5 By Rahulk
        sCompanyName = CommonUtility.chkmasterLookupInPiplineAPI();
        if(sCompanyName == 'Company_Name__c'){
            isCompanyReq =true;
        }
    }  
   
    /*
    @Description: Method called on click source Firm link.
    @Parameter1: variable sourceFirmPopuFieldList contains source firm field.
    */ 
    public void openSourceFirmPopup(){ 
        try
        { 
            errorMessage = '';
            if(lstNavSetup.size()>0){
                if(isEditSourceFirm== true){                   
                    isEditSourceFirm = false; 
                    
                    for(integer i=0; i<dcsNewSourceFirm.Size(); i++){    
                        if(i==0){
                            for(String strfield: dcsNewSourceFirm[i].split(',')){
                                 strRecordTypeId = strfield;
                            }                
                        }
                        if(i==1){                           
                            for(String strfield: dcsNewSourceFirm[i].toLowerCase().split(',')){
                                String strObjName= '';
                                List<String> fieldApiList = strfield.split(':');
                                for(integer k=0; k<fieldApiList.Size(); k++){ 
                                    if(k==0){                            
                                        strObjName = fieldApiList[k];                                           
                                    }
                                    if(k==1){                                           
                                        objectfield objfld= new objectfield();
                                        objfld.apiname = fieldApiList[k];
                                        if(objfld.apiname!=null){
                                            objfld.apiname = objfld.apiname.toLowerCase();
                                        }   
                                        if(strObjName.contains('account')){
                                            objfld.objectname = objSourceAccount;                                         
                                            if(FieldLabelVsApi.get(strObjName+':'+fieldApiList[k])!=null){
                                                objfld.label = FieldLabelVsApi.get(strObjName+':'+fieldApiList[k]);
                                               
                                                if(FieldApiVsFieldType.get(strObjName+':'+fieldApiList[k])!=null){
                                                    objfld.fieldType = FieldApiVsFieldType.get(strObjName+':'+fieldApiList[k]);
                                                }
                                                
                                                objfld.label = objfld.label.replace(strAccountLabel+':','');
                                                if(setSourcePgLayoutReqField.contains(strObjName.toLowerCase()+':'+objfld.apiname)){
                                                    objfld.isrequired = true;
                                                } 
                                                sourceFirmPopuFieldList.add(objfld);                                                   
                                            }
                                        }
                                        
                                    }
                                }
                            }
                        }
                    }
                    rtList = new list<RecordType>();
                    if(Schema.sObjectType.RecordType.isAccessible() && Schema.sObjectType.RecordType.fields.name.isAccessible() && Schema.sObjectType.RecordType.fields.developername.isAccessible() && Schema.sObjectType.RecordType.fields.isActive.isAccessible()){
                        rtList = [SELECT id, name ,developername FROM RecordType where  sObjecttype = 'Account' AND developername=:strRecordTypeId AND isActive = True];
                    }
                    if(rtList.size()>0 && Schema.sObjectType.Account.fields.recordTypeId.isCreateable()){    
                        objSourceAccount.recordtypeid = rtList[0].id;
                    }
                    else{                     
                        for(Schema.RecordTypeInfo rtInfo : Account.SObjectType.getDescribe().getRecordTypeInfos()){
                            if (rtInfo.isDefaultRecordTypeMapping() && Schema.sObjectType.Account.fields.recordTypeId.isCreateable()) {  
							objSourceAccount.recordtypeid = rtInfo.getRecordTypeId();
                            }
                        } 
                    }
                }
            }
        }catch(Exception ex) {
            errorMessage = ex.getMessage();
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Exception in Constructor : '+ex)); 
        }
    }
      
    /*
    @Description: Method called on click source contact link.
    @Parameter1: variable sourceContactPopuFieldList contains source contact field.
    */ 
    public void openSourceContactPopup(){
        try
        { 
            errorMessage = '';          
            if(lstNavSetup.size()>0){               
                if(isEditSourceContact==true){                    
                    isEditSourceContact = false;
                    for(integer i=0; i<dcsNewSourceContactList.Size(); i++){
                        String strObjName= '';                                                    
                        List<String> fieldApiList = dcsNewSourceContactList[i].toLowerCase().split(':');
                        for(integer j=0; j<fieldApiList.Size(); j++){                             
                            if(j==0){                            
                                strObjName = fieldApiList[j];                                                  
                            }
                            if(j==1){                            
                                objectfield objfld= new objectfield();                                
                                objfld.apiname = fieldApiList[j];
                                if(objfld.apiname!=null){
                                    objfld.apiname = objfld.apiname.toLowerCase();
                                }   
                                if(strObjName.contains('contact')){
                                    objfld.objectname = objSourceContact;
                                    if(FieldLabelVsApi.get(strObjName+':'+fieldApiList[j])!=null){
                                        objfld.label = FieldLabelVsApi.get(strObjName+':'+fieldApiList[j]);
                                        /*Update default Record Type Label for Bug(00029364) fixing in PE4.5 by Rahulk */
                                        if (objfld.apiname.toLowerCase() == 'recordtypeid' && objfld.label =='Contact:Record Type ID') {
											objfld.label ='Record Type';
                                        }                                     
                                        if(FieldApiVsFieldType.get(strObjName+':'+fieldApiList[j])!=null){
                                            objfld.fieldType = FieldApiVsFieldType.get(strObjName+':'+fieldApiList[j]);
                                        }
                                        
                                        objfld.label =objfld.label.replace(strContactLabel+':','');
                                        if(setSourcePgLayoutReqField.contains(strObjName.toLowerCase()+':'+objfld.apiname)){
                                            objfld.isrequired = true;
                                        }  
                                        sourceContactPopuFieldList.add(objfld);
                                    }
                                }
                                
                            }
                        }                           
                    }                      
                }               
            }
            /*issue fixed:- When org have active record type but not assign to user and recordtypeid field added in navatar setup.  By rahulk in PE4.5 27-11-2020*/
            for(Schema.RecordTypeInfo rti : Contact.SObjectType.getDescribe().getRecordTypeInfos()) {
                if(rti.isDefaultRecordTypeMapping()&& rti.isMaster() ) {
                    isMasterRTforContact =true;
                }
                /* Set default recordtype for Contact in PE4.5 for bug(00029387) fixing by RahulK*/
				 if (objSourceContact.getSobjectType().getDescribe().fields.getMap().containsKey('recordTypeId') && rti.isDefaultRecordTypeMapping()) {
                    objSourceContact.put('recordtypeid',rti.getRecordTypeId()); // Contact RecordType Id
                }
            }
        }catch(Exception ex) {
            errorMessage = ex.getMessage();
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Exception in openSourceContactPopup : '+ex)); 
        }
    }
       
    /*
    @Description: Method called on page load to view account,conact and pipeline objects required fields on deal creation page.
    @Parameter1: variable setPgLayoutRequiredField contains required fields.
    */ 
    public void viewRequiredFieldonPage(){
                        
        try{
            setPgLayoutRequiredField = new Set<String>();
            setSourcePgLayoutReqField = new Set<String>();
            errorMessage = '';
            for(String str: strRequiredField.split(',')){
                setPgLayoutRequiredField.add(str.toLowerCase());
            }
            // Check  company field is Required on layout in bug(00029386) fixing in Pe4.5 by Rahulk
             String sCompnayKey = (CommonUtility.strNameSpacePrefix+'Pipeline__c'+':'+CommonUtility.strNameSpacePrefix+sCompanyName).toLowerCase();
			if(setPgLayoutRequiredField.contains(sCompnayKey))
            {
              isCompanyReq = true;  
            }
            for(String str: strSourcePopupReqField.split(',')){
                setSourcePgLayoutReqField.add(str.toLowerCase());
            }
            if(lstNavSetup.size()>0){               
                List<String> dcsInfoList= new List<String>();               
                if(lstNavSetup[0].dcs__c!=null){
                    dcsInfoList = lstNavSetup[0].dcs__c.toLowerCase().split(';');  //get deal creation information fields
                }
                if(lstNavSetup[0].dcs_new_source_firm__c.contains(';')){
                    strRecordTypeId = lstNavSetup[0].dcs_new_source_firm__c.Split(';')[0];
                }
                if(lstNavSetup[0].dcs_new_company__c!=null){
                    strCompanyRecordType = lstNavSetup[0].dcs_new_company__c;
                }  
                Map<String, SObjectField> m = SObjectType.Account.fields.getMap();
                rtList = new list<RecordType>();
                if(Schema.sObjectType.RecordType.isAccessible() && Schema.sObjectType.RecordType.fields.name.isAccessible() && Schema.sObjectType.RecordType.fields.developername.isAccessible() && Schema.sObjectType.RecordType.fields.isActive.isAccessible()){
                    rtList = [SELECT id, name ,developername FROM RecordType where  sObjecttype = 'Account' AND developername=:strCompanyRecordType AND isActive = True];
                }
                if(rtList.size() > 0 && Schema.sObjectType.Account.fields.recordtypeid.isCreateable()){    
                    objAccount.recordtypeid = rtList[0].id;
                }
                else
                {                   
                    for(Schema.RecordTypeInfo rtInfo : Account.SObjectType.getDescribe().getRecordTypeInfos()){
                        if (rtInfo.isDefaultRecordTypeMapping() && Schema.sObjectType.Account.fields.recordtypeid.isCreateable()) {          
                           objAccount.recordtypeid = rtInfo.getRecordTypeId();
                        }
                    } 
                }                
                for(integer i=0; i<dcsInfoList.Size(); i++){ 
                    if(i==0){
                        for(String strfield: dcsInfoList[i].split(',')){    //get deal creation information left section fields
                            String strObjName= '';                                                    
                            List<String> fieldApiList = strfield.split(':');
                            for(integer j=0; j<fieldApiList.Size(); j++){                             
                                if(j==0){                            
                                    strObjName= fieldApiList[j];                                                  
                                }
                                if(j==1){                            
                                    objectfield objfld= new objectfield();  
                                    objfld.apiname = fieldApiList[j];
                                    if(objfld.apiname!=null){
                                        objfld.apiname = objfld.apiname.toLowerCase();
                                    }
                                    if(strObjName.contains('account')){
                                        objfld.objectname = objAccount;
                                        if(FieldLabelVsApi.get(strObjName+':'+fieldApiList[j])!=null){ 
                                            if(FieldApiVsFieldType.get(strObjName+':'+fieldApiList[j])!=null){
                                                objfld.fieldType = FieldApiVsFieldType.get(strObjName+':'+fieldApiList[j]);
                                            }
                                            objfld.label = FieldLabelVsApi.get(strObjName+':'+fieldApiList[j]); 
                                            if(setPgLayoutRequiredField.contains(strObjName.toLowerCase()+':'+objfld.apiname)){
                                                objfld.isrequired = true;                                               
                                            }                                       
                                            objfld.label = objfld.label.replace(strAccountLabel+':','');
                                            leftColumnObjectFieldList.add(objfld);
                                        }
                                    }
                                    if(strObjName.contains('pipeline')){
                                        objfld.objectname = objPipeline;
                                        if(FieldLabelVsApi.get(strObjName+':'+fieldApiList[j])!=null){
                                            objfld.label = FieldLabelVsApi.get(strObjName+':'+fieldApiList[j]); 
                                            if(FieldApiVsFieldType.get(strObjName+':'+fieldApiList[j])!=null){
                                                objfld.fieldType = FieldApiVsFieldType.get(strObjName+':'+fieldApiList[j]);
                                            }
                                            if(setPgLayoutRequiredField.contains(strObjName.toLowerCase()+':'+objfld.apiname)){
                                                objfld.isrequired = true;
                                            }                                         
                                            objfld.label = objfld.label.replace(strPipelineLabel+':','');                                        
                                            leftColumnObjectFieldList.add(objfld); 
                                        }
                                    }
                                }
                            }
                        }                
                    }
                    if(i==1){
                        for(String strfield: dcsInfoList[i].split(',')){      //get deal creation information right section fields
                            String strObjName= '';                                                    
                            List<String> fieldApiList = strfield.split(':');
                            for(integer k=0; k<fieldApiList.Size(); k++){ 
                                if(k==0){                            
                                    strObjName= fieldApiList[k];                                                  
                                }
                                if(k==1){                            
                                    objectfield objfld= new objectfield();
                                    objfld.apiname = fieldApiList[k]; 
                                    if(objfld.apiname!=null){
                                        objfld.apiname = objfld.apiname.toLowerCase();
                                    }                              
                                    if(strObjName.contains('account')){
                                        objfld.objectname = objAccount;
                                        if(FieldLabelVsApi.get(strObjName+':'+fieldApiList[k])!=null){
                                            objfld.label = FieldLabelVsApi.get(strObjName+':'+fieldApiList[k]);
                                            if(FieldApiVsFieldType.get(strObjName+':'+fieldApiList[k])!=null){
                                                objfld.fieldType = FieldApiVsFieldType.get(strObjName+':'+fieldApiList[k]);
                                            }
                                            objfld.label = objfld.label.replace(strAccountLabel+':','');                                                                                 
                                            if(setPgLayoutRequiredField.contains(strObjName.toLowerCase()+':'+objfld.apiname)){                                             
                                                objfld.isrequired = true;
                                            }
                                            rightColumnObjectFieldList.add(objfld); 
                                        }
                                    }
                                    if(strObjName.contains('pipeline')){
                                        objfld.objectname = objPipeline;
                                        if(FieldLabelVsApi.get(strObjName+':'+fieldApiList[k])!=null){
                                            objfld.label = FieldLabelVsApi.get(strObjName+':'+fieldApiList[k]);
                                            if(FieldApiVsFieldType.get(strObjName+':'+fieldApiList[k])!=null){
                                                objfld.fieldType = FieldApiVsFieldType.get(strObjName+':'+fieldApiList[k]);
                                            }
                                            objfld.label =objfld.label.replace(strPipelineLabel+':','');
                                            if(setPgLayoutRequiredField.contains(strObjName.toLowerCase()+':'+objfld.apiname)){
                                                objfld.isrequired = true;
                                            }
                                            rightColumnObjectFieldList.add(objfld);
                                        }
                                    }
                                }
                            }
                        }
                    }
                }  
                  
            }
        }catch(Exception ex) {
            errorMessage = ex.getMessage();
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Exception in viewRequiredFieldonPage : '+ex)); 
        }
    }
    
    /*
    @Description: Method called on click cancel button.   
    */
    public PageReference onCancel(){   
        String strnavigateTo = apexpages.currentpage().getparameters().get('retURL'); //PE v3.7: Summer 18 lightning navigation fix.
        PageReference cancelPage = new PageReference(strnavigateTo);
        cancelPage.setRedirect(true);
        return cancelPage ;         
    }   
    
    /*
    @Description: Method called on page load to get get default recordtype id of objects.
    @Parameter1: variable setPgLayoutRequiredField contains required fields.
    */ 
    @RemoteAction 
    global static String getRecorTypeid() {
        
        contDescribe = Contact.sObjectType.getDescribe();
        accDescribe =  Account.sObjectType.getDescribe();           
        sobjPipeline = Pipeline__c.sObjectType.getDescribe();
        errorMessage = '';        
        String objRecordType='';        
        try{                        
            strSobjNameSpace = CommonUtility.strNameSpacePrefix;
            List<Navatar_Setup__c> lstNavSetup = new List<Navatar_Setup__c>();
            if(Schema.sObjectType.Navatar_Setup__c.isAccessible() && Schema.sObjectType.Navatar_Setup__c.fields.dcs__c.isAccessible() && Schema.sObjectType.Navatar_Setup__c.fields.dcs_new_company__c.isAccessible() && Schema.sObjectType.Navatar_Setup__c.fields.dcs_new_source_contact__c.isAccessible() && Schema.sObjectType.Navatar_Setup__c.fields.dcs_new_source_firm__c.isAccessible() && Schema.sObjectType.Navatar_Setup__c.fields.admin_setting__c.isAccessible()){
                lstNavSetup =[SELECT dcs__c,dcs_new_company__c,dcs_new_source_contact__c,dcs_new_source_firm__c,admin_setting__c FROM Navatar_Setup__c where admin_setting__c=true Limit 1];
            }
            List<RecordType> rtList= new List<RecordType>();
            if(lstNavSetup.Size()>0){
                if(lstNavSetup[0].dcs_new_company__c!=null){
                    if(Schema.sObjectType.RecordType.isAccessible() && Schema.sObjectType.RecordType.fields.name.isAccessible() && Schema.sObjectType.RecordType.fields.developername.isAccessible() && Schema.sObjectType.RecordType.fields.isActive.isAccessible()){
                        rtList = [SELECT id, name ,developername FROM RecordType where sObjecttype = 'Account' AND  developername=:lstNavSetup[0].dcs_new_company__c AND isActive = True];
                    }
                    if(accDescribe.accessible){ 
                        if(rtList.size()>0){    
                            objRecordType = 'Account'+'^'+rtList[0].id;
                        }else{
                            if(!string.isBlank(lstNavSetup[0].dcs_new_company__c))                              
                                errormsg = 'The assigned record type has either been deleted or is unavailable for use. If no record type is assigned, the Deal will get created with the system default record type.';
                            
                            for(Schema.RecordTypeInfo rtInfo : Account.SObjectType.getDescribe().getRecordTypeInfos()){
                                if (rtInfo.isDefaultRecordTypeMapping()) {                        
                                    objRecordType = 'Account'+'^'+rtInfo.getRecordTypeId();
                                }
                            } 
                        }
                    }
                }
                rtList.clear();
                if(lstNavSetup[0].dcs_new_source_firm__c!=null){
                    String sourceFirmRecTypeid='';
                    if(lstNavSetup[0].dcs_new_source_firm__c.contains(';')){
                        sourceFirmRecTypeid = lstNavSetup[0].dcs_new_source_firm__c.Split(';')[0];
                    }
                    if(Schema.sObjectType.RecordType.isAccessible() && Schema.sObjectType.RecordType.fields.name.isAccessible() && Schema.sObjectType.RecordType.fields.developername.isAccessible() && Schema.sObjectType.RecordType.fields.isActive.isAccessible()){
                        rtList = [SELECT id, name ,developername FROM RecordType where sObjecttype = 'Account' AND developername=:sourceFirmRecTypeid AND isActive = True];
                    }                   
                    if(accDescribe.accessible){ 
                        if(rtList.size()>0){                
                            objRecordType = objRecordType +'~'+ 'Institution'+'^'+rtList[0].id;     
                        }else{  
                            if(!string.isBlank(lstNavSetup[0].dcs_new_source_firm__c))  
                                errormsg = 'The assigned record type has either been deleted or is unavailable for use. If no record type is assigned, the Deal will get created with the system default record type.';                            
                            
                            for(Schema.RecordTypeInfo rtInfo : Account.SObjectType.getDescribe().getRecordTypeInfos()){
                                if (rtInfo.isDefaultRecordTypeMapping()) {                        
                                    objRecordType = objRecordType +'~'+ 'Institution'+'^'+rtInfo.getRecordTypeId(); 
                                }
                            }                            
                        }
                    }
                }
                rtList.clear();
                if(Schema.sObjectType.RecordType.isAccessible() && Schema.sObjectType.RecordType.fields.isActive.isAccessible() && Schema.sObjectType.RecordType.fields.developername.isAccessible())
                    rtList=[Select Id, DeveloperName From RecordType where sobjecttype = 'Contact' AND isActive = True];
                if(contDescribe.accessible){            
                    if(rtList.size()>0){                
                            objRecordType = objRecordType +'~'+ 'Contact'+'^'+rtList[0].id;     
                    }else{
                        for(Schema.RecordTypeInfo rtInfo : Contact.SObjectType.getDescribe().getRecordTypeInfos()){
                            if (rtInfo.isDefaultRecordTypeMapping()) {                        
                                objRecordType = objRecordType +'~'+ 'Contact'+'^'+rtInfo.getRecordTypeId(); 
                            }
                        }               
                    }
                }
                rtList.clear(); 
                if(Schema.sObjectType.RecordType.isAccessible() && Schema.sObjectType.RecordType.fields.isActive.isAccessible() && Schema.sObjectType.RecordType.fields.developername.isAccessible()){               
                    rtList=[Select Id, DeveloperName From RecordType where sobjecttype = 'Pipeline' AND isActive = True]; 
                }
                if(sobjPipeline.accessible){
                    if(rtList.size()>0){                
                            objRecordType = objRecordType +'~'+ ''+strSobjNameSpace+'Pipeline__c'+'^'+rtList[0].id;        
                    }else{
                        for(Schema.RecordTypeInfo rtInfo : Pipeline__c.SObjectType.getDescribe().getRecordTypeInfos()){
                            if (rtInfo.isDefaultRecordTypeMapping()) {                        
                                objRecordType = objRecordType +'~'+ ''+strSobjNameSpace+'Pipeline__c'+'^'+rtInfo.getRecordTypeId();    
                            }
                        }               
                    }
                }
                objRecordType = objRecordType +'*?'+errormsg;
            }
        }catch(Exception ex) {
            errorMessage = ex.getMessage();
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Exception in getRecorTypeid : '+ex)); 
        }
        return objRecordType;
    }
       
    /*
    @Description: Method called on page load.
    @Parameter1: variable apiname ,label,isrequired is used for store field apiname and label.
    */ 
    public class objectfield{    
        public String apiname{get;set;}             // for storing apiname of the field
        public String strdatatype{get;set;}         // for storing data type of the field
        public String label{get;set;}               // for storing label of the field
        public Boolean isrequired{get;set;}         // to check if the particular field is required or not
        public Boolean editable{get;set;}           // to check if the particular field is editable or not
        public sobject objectname{get;set;}         // for storing the objectname of the field  
        public String defaultValue{get;set;}
        public String fieldType{get;set;} 
    }        
        
    /*
    @Description: Method called on click create deal button.
    @Parameter1: variable objPipeline ,objAccount ,objSourceContact is used for insert account contact and pipeline records.
    */ 
    public PageReference CreateDeal(){  
        rtList = new List<RecordType>(); 
        isAdminSettingOn = false; errorMessage=''; 
        if(Schema.sObjectType.Navatar_Setup__c.isAccessible() && Schema.sObjectType.Navatar_Setup__c.fields.dcs__c.isAccessible() && Schema.sObjectType.Navatar_Setup__c.fields.dcs_new_company__c.isAccessible() && Schema.sObjectType.Navatar_Setup__c.fields.dcs_new_source_contact__c.isAccessible() && Schema.sObjectType.Navatar_Setup__c.fields.dcs_new_source_firm__c.isAccessible() && Schema.sObjectType.Navatar_Setup__c.fields.admin_setting__c.isAccessible()){
            lstNavSetup =[SELECT dcs__c,dcs_new_company__c,dcs_new_source_contact__c,dcs_new_source_firm__c,admin_setting__c FROM Navatar_Setup__c where admin_setting__c=true Limit 1];
        }
        if(lstNavSetup.size()>0){
            if(Schema.sObjectType.RecordType.isAccessible() && Schema.sObjectType.RecordType.fields.name.isAccessible() && Schema.sObjectType.RecordType.fields.developername.isAccessible() && Schema.sObjectType.RecordType.fields.isActive.isAccessible()){
                rtList=[SELECT id, name ,developername FROM RecordType where sObjecttype = 'Account' AND  developername=:strCompanyRecordType AND isActive = True];
            }
            isAdminSettingOn = true;    
            if(rtList.Size()==0){
                for (Schema.RecordTypeInfo rtInfo : Account.SObjectType.getDescribe().getRecordTypeInfos()) {
                    if (rtInfo.isDefaultRecordTypeMapping()) {                        
                        if( Schema.sObjectType.Account.fields.recordtypeid.isCreateable() ){
                            objAccount.recordtypeid = rtInfo.getRecordTypeId();
                        }
                    }
                }            
            }
            else{              
                if( Schema.sObjectType.Account.fields.recordtypeid.isCreateable() ){
                    objAccount.recordtypeid = rtList[0].id; // Company RecordType Id.                       
                }
            } 
            rtList.clear();
            if(Schema.sObjectType.RecordType.isAccessible() && Schema.sObjectType.RecordType.fields.name.isAccessible() && Schema.sObjectType.RecordType.fields.developername.isAccessible() && Schema.sObjectType.RecordType.fields.isActive.isAccessible()){           
                rtList=[SELECT id, name ,developername FROM RecordType where sObjecttype = 'Account' AND developername=:strRecordTypeId AND isActive = True];
            }
            if(rtList.Size()==0){ 
                for (Schema.RecordTypeInfo rtInfo : Account.SObjectType.getDescribe().getRecordTypeInfos()) {
                    if (rtInfo.isDefaultRecordTypeMapping() && Schema.sObjectType.Account.fields.recordTypeId.isCreateable()) {                        
                        objSourceAccount.recordtypeid = rtInfo.getRecordTypeId();
                    }
                }
                
            }else{ 
                if(Schema.sObjectType.Account.fields.recordTypeId.isCreateable()){
                    objSourceAccount.recordtypeid = rtList[0].id;  // Institution RecordType Id.
                }
            }
            rtList.clear(); 
            if(Schema.sObjectType.RecordType.isAccessible() && Schema.sObjectType.RecordType.fields.isActive.isAccessible() && Schema.sObjectType.RecordType.fields.developername.isAccessible())
                // Conditon added for Contact RecordType in in PE v4.5 By Hemendra 
              if (objSourceContact.getSobjectType().getDescribe().fields.getMap().containsKey('recordTypeId') && objSourceContact.get('recordTypeId') != null) {
                    Id contRecordTypeId = (string)objSourceContact.get('recordTypeId');
                    rtList=[Select Id, DeveloperName From RecordType where sobjecttype = 'Contact' AND isActive = True AND Id = :contRecordTypeId];
                }else {
                    /*rtList=[Select Id, DeveloperName From RecordType where sobjecttype = 'Contact' AND isActive = True];*/
                }
            if(rtList.Size()>0){ 
                objSourceContact.put('recordtypeid',rtList[0].id); // Contact RecordType Id.
            }
            rtList.clear();
            if(Schema.sObjectType.RecordType.isAccessible() && Schema.sObjectType.RecordType.fields.isActive.isAccessible() && Schema.sObjectType.RecordType.fields.developername.isAccessible())
                rtList=[Select Id, DeveloperName From RecordType where sobjecttype = 'Pipeline' AND isActive = True];  
            if(rtList.Size()>0){  
                objPipeline.put('recordtypeid',rtList[0].id); // Pipeline RecordType Id.
            }  
            Savepoint svPoint;
            Pipeline__c objPL;
            try{   
                
                svPoint = Database.setSavepoint();
                objPL = new Pipeline__c();
                
                //insert company record
                Account acc = new Account(); 
                if(Schema.sObjectType.Account.isCreateable()){
                    acc = objAccount; 
                }
                
                if(acc.Id != null){
                    acc.put('Id', null);          
                }
                if(!string.isBlank(acc.name) && Schema.sObjectType.Account.isCreateable()==true){
                     insert acc;
                }
                
                if(Schema.sObjectType.Pipeline__c.fields.Name.isCreateable()){
                    objPipeline.name = objSourcePipeline.name;
                }
                //Set dynamic company Name API in  PE v4.5 By Rahulk 
                if(Schema.getGlobalDescribe().get(CommonUtility.strNameSpacePrefix+'Pipeline__c').getDescribe().fields.getMap().get(CommonUtility.strNameSpacePrefix+sCompanyName).getDescribe().isCreateable()){
                    objPipeline.put(sCompanyName, acc.id);  
                }
                if(Schema.sObjectType.Pipeline__c.fields.Stage__c.isCreateable()){
                    objPipeline.Stage__c = objSourcePipeline.Stage__c;
                }
                if(Schema.sObjectType.Pipeline__c.fields.Source__c.isCreateable()){
                    objPipeline.Source__c = objSourcePipeline.Source__c;   
                }
                if(Schema.sObjectType.Contact.fields.Lastname.isCreateable()){
                    objSourceContact.lastname = objContact.lastname;
                }
                
                //insert source firm record
                Account sourceAcc = new Account();            
                if((!string.isBlank(objSourceAccount.name) || !string.isBlank(strSourceFirmName)) || !string.isBlank(objSourcePipeline.Source_Company__c)){
                    if(!string.isBlank(strSourceFirmName)){ 
                        if(Schema.sObjectType.Account.isCreateable()){
                            sourceAcc = objSourceAccount;
                        }
                        
                        if(Schema.sObjectType.Account.fields.Name.isCreateable()){
                            sourceAcc.name = strSourceFirmName;
                        }
                    } 
                    if(!string.isBlank(sourceAcc.name)){                   
                        if(sourceAcc.Id != null){
                            sourceAcc.put('Id', null);              
                        }
                        if(Schema.sObjectType.Account.isCreateable()==true){
                            insert sourceAcc; 
                        }
                        
                        if(Schema.sObjectType.Pipeline__c.fields.source_company__c.isCreateable()){
                            objPipeline.source_company__c = sourceAcc.id;
                        }
                        if(Schema.sObjectType.Contact.fields.Accountid.isCreateable()){
                            objSourceContact.accountid = sourceAcc.id;  
                        }
                    }
                    else{ 
                        if(!string.isBlank(objSourcePipeline.Source_Company__c) ){ 
                            if( Schema.sObjectType.Pipeline__c.fields.source_company__c.isCreateable() ){
                                objPipeline.source_company__c = objSourcePipeline.Source_Company__c;
                            }
                            if( Schema.sObjectType.Contact.fields.AccountId.isCreateable() ){
                                objSourceContact.accountid = objSourcePipeline.Source_Company__c;  
                            }
                        }
                    }                      
                }
                //insert source contact record
                Contact cont= new Contact();            
                if((!string.isBlank(objSourceContact.LastName) || !string.isBlank(strSourceContactName)) || !string.isBlank(objSourcePipeline.Source_Contact__c)){
                    if(!string.isBlank(strSourceContactName) ){ 
                        if(Schema.sObjectType.Contact.isCreateable()){
                            cont = objSourceContact;    
                        }
                        
                        cont.lastname = strSourceContactName;
                        if(objSourceContact.accountid!=null){
                            if( Schema.sObjectType.Contact.fields.Accountid.isCreateable() ){
                                cont.accountid = objSourceContact.accountid;
                            }
                        }                           
                    }        
                    if(!string.isBlank(cont.lastname)){ 
						if(Schema.sObjectType.Contact.isCreateable()==true){					
							if(cont.Id != null){
								cont.put('Id', null);           
							}
						}
                        if(Schema.sObjectType.Contact.isCreateable()==true){
                            insert cont;
                            
                            if( Schema.sObjectType.Pipeline__c.fields.source_contact__c.isCreateable() ){
                                objPipeline.source_contact__c = cont.id;
                            }
                        }
                    }
                    else
                    {
                        if(!string.isBlank(objSourcePipeline.Source_Contact__c) )
                        { 
                            if( Schema.sObjectType.Pipeline__c.fields.source_contact__c.isCreateable() ){
                                objPipeline.source_contact__c = objSourcePipeline.Source_Contact__c;                        
                            }
                        }                   
                    }    
                }
                //insert pipeline record
                if(Schema.sObjectType.Pipeline__c.isCreateable()){
                    objPL = objPipeline; 
                }
                if(objPL.Id != null){
                    objPL.put('Id', null);              
                } 
                //Remove account dependency for Pipeline creation  in bug(00029386) fixing in Pe4.5 by Rahulk 
                //if(acc.id!=null && Schema.sObjectType.Pipeline__c.isCreateable()==true){
                if(Schema.sObjectType.Pipeline__c.isCreateable()==true){
                    insert objPL;
                }
            }
            catch (Exception e){  
                errorMessage = e.getMessage();
                if(ApexPages.getMessages()== null){
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,''+e.getMessage()));    
                }   
                Database.rollback(svPoint);  // Roll the database back to before we saved ANYTHING. 
                return null;
            }
            if(objPL.id!=null){
                PageReference nextPage = new PageReference('/' + objPL.Id);
                nextPage.setRedirect(true);
                return nextPage;
            }else{
                return null;
            } 
        }else{          
            strAdminSettingError = 'Code: 12365. Please contact Navatar Support. System setup improperly.'; 
            if(!string.isBlank(strSourceFirmName))
                strAdminSettingError = 'Code: 12465. Please contact Navatar Support. System setup improperly.'; 
            return null;
        } 
    }
    
    public  Map<string, string> describeSObject(List<String> lstsObject){
        Map<string, string> FieldLabelVsApi = new Map<string, string>();      
        errorMessage ='';
        Date mydate;
        Date dateTimeValue;
        String dateTimeInString = '';
        String dateInString = '';
        
        try
        {
            for(string objName : lstsObject){   
                List<Schema.DescribeSObjectResult> describeSobjectsResult = Schema.describeSObjects(new List<String>{objName }); // this can accept list of strings, we describe only one object here
                String objectLabel = describeSobjectsResult[0].getLabel();
                Map <String, Schema.SObjectField> fieldMap = new Map <String, Schema.SObjectField>();
                fieldMap = Schema.getGlobalDescribe().get(objName).getDescribe().fields.getMap();
                for(Schema.SObjectField sField : fieldMap.Values()) 
                {
                    schema.DescribeFieldResult dField = sField.getDescribe();                  
                    string strType = string.valueof(dField.getType());
                   
                    if(!String.IsBlank(dfield.getDefaultValueFormula()) && strType=='STRING'){
                        if(objName=='Account'){
                            objAccount.put(dfield.getName(), dfield.getDefaultValueFormula().replaceAll('"','').replaceAll('\'',''));
                            objSourceAccount.put(dfield.getName(), dfield.getDefaultValueFormula().replaceAll('"','').replaceAll('\'',''));
                        }
                        else if(objName=='Contact'){
                            objSourceContact.put(dfield.getName(), dfield.getDefaultValueFormula().replaceAll('"',''));
                        }
                        else if(objName.contains('Pipeline__c')){
                            objPipeline.put(dfield.getName(), dfield.getDefaultValueFormula().replaceAll('"',''));
                        }
                    } 
                    else if(!String.IsBlank(dfield.getDefaultValueFormula()) && (strType=='INTEGER' || strType=='DOUBLE')){  
                        if(objName=='Account'){
                            objAccount.put(dfield.getName(), Integer.valueof(dfield.getDefaultValueFormula()));
                            objSourceAccount.put(dfield.getName(), Integer.valueof(dfield.getDefaultValueFormula()));
                        }
                        else if(objName=='Contact'){
                            objSourceContact.put(dfield.getName(), Integer.valueof(dfield.getDefaultValueFormula()));
                        }
                        else if(objName.contains('Pipeline__c')){
                            objPipeline.put(dfield.getName(), Integer.valueof(dfield.getDefaultValueFormula()));
                        }
                    }                       
                    else if(!String.IsBlank(dfield.getDefaultValueFormula()) && (strType=='CURRENCY' || strType=='PERCENT')){                      
                        if(objName=='Account'){
                            objAccount.put(dfield.getName(), Decimal.valueOf(dfield.getDefaultValueFormula()));
                            objSourceAccount.put(dfield.getName(), Decimal.valueOf(dfield.getDefaultValueFormula()));
                        }
                        else if(objName=='Contact'){
                            objSourceContact.put(dfield.getName(), Decimal.valueOf(dfield.getDefaultValueFormula()));
                        }
                        else if(objName.contains('Pipeline__c')){
                            objPipeline.put(dfield.getName(), Decimal.valueOf(dfield.getDefaultValueFormula()));
                        }                    
                    }                    
                    else if(!String.IsBlank(dfield.getDefaultValueFormula()) && strType=='DATE'){                      
                        if(objName=='Account'){                         
                            dateInString = dfield.getDefaultValueFormula();                            
                            dateInString = dateInString.toLowerCase();
                            string tempDateVal = dateInString.replace('today()', '').replace('now()', '').replaceAll( '\\s+', '');
                            mydate = Date.Valueof(dateInString.replace('today()', ''+System.Today()+'').replace('now()', ''+System.now()+''));                             
                            if(tempDateVal != null && tempDateVal !=''){
                                mydate= mydate.addDays(integer.valueof(tempDateVal));
                            }
                            objAccount.put(dfield.getName(), mydate);
                            objSourceAccount.put(dfield.getName(), mydate);                            
                        }
                        else if(objName=='Contact'){
                            dateInString = dfield.getDefaultValueFormula();                            
                            dateInString = dateInString.toLowerCase();
                            string tempDateVal = dateInString.replace('today()', '').replace('now()', '').replaceAll( '\\s+', '');
                            mydate = Date.Valueof(dateInString.replace('today()', ''+System.Today()+'').replace('now()', ''+System.now()+''));                             
                            if(tempDateVal != null && tempDateVal !=''){
                                mydate= mydate.addDays(integer.valueof(tempDateVal));
                            }
                            objSourceContact.put(dfield.getName(), mydate);
                        }
                        else if(objName.contains('Pipeline__c')){
                            dateInString = dfield.getDefaultValueFormula();                            
                            dateInString = dateInString.toLowerCase();
                            string tempDateVal = dateInString.replace('today()', '').replace('now()', '').replaceAll( '\\s+', '');
                            mydate = Date.Valueof(dateInString.replace('today()', ''+System.Today()+'').replace('now()', ''+System.now()+''));                             
                            if(tempDateVal != null && tempDateVal !=''){
                                mydate= mydate.addDays(integer.valueof(tempDateVal));
                            }
                            objPipeline.put(dfield.getName(), mydate);
                        }                    
                    }
                    else if(!String.IsBlank(dfield.getDefaultValueFormula()) && strType=='DATETIME'){                      
                        if(objName=='Account'){                         
                            dateInString = dfield.getDefaultValueFormula();                            
                            dateInString = dateInString.toLowerCase();
                            string tempDateVal = dateInString.replace('today()', '').replace('now()', '').replaceAll( '\\s+', '');
                            dateTimeValue = Date.Valueof(dateInString.replace('today()', ''+System.Today()+'').replace('now()', ''+System.now()+''));                             
                            if(tempDateVal != null && tempDateVal !=''){
                                dateTimeValue = dateTimeValue.addDays(integer.valueof(tempDateVal));
                            }
                            objAccount.put(dfield.getName(), dateTimeValue);
                            objSourceAccount.put(dfield.getName(), dateTimeValue);                            
                        }
                        else if(objName=='Contact'){
                            dateInString = dfield.getDefaultValueFormula();                            
                            dateInString = dateInString.toLowerCase();
                            string tempDateVal = dateInString.replace('today()', '').replace('now()', '').replaceAll( '\\s+', '');
                            dateTimeValue = Date.Valueof(dateInString.replace('today()', ''+System.Today()+'').replace('now()', ''+System.now()+''));                             
                            if(tempDateVal != null && tempDateVal !=''){
                                dateTimeValue = dateTimeValue.addDays(integer.valueof(tempDateVal));
                            }
                            objSourceContact.put(dfield.getName(), dateTimeValue);
                        }
                        else if(objName.contains('Pipeline__c')){
                            dateInString = dfield.getDefaultValueFormula();                            
                            dateInString = dateInString.toLowerCase();
                            string tempDateVal = dateInString.replace('today()', '').replace('now()', '').replaceAll( '\\s+', '');
                            dateTimeValue = Date.Valueof(dateInString.replace('today()', ''+System.Today()+'').replace('now()', ''+System.now()+''));                             
                            if(tempDateVal != null && tempDateVal !=''){
                                dateTimeValue= dateTimeValue.addDays(integer.valueof(tempDateVal));
                            }
                            objPipeline.put(dfield.getName(), dateTimeValue);
                        }                    
                    }              
                    if(dField.isAccessible()){
                        FieldLabelVsApi.put(objName.toLowerCase() +':'+dfield.getName().toLowerCase(), objectLabel +':'+dfield.getLabel());                        
                        FieldApiVsFieldType.put(objName.toLowerCase() +':'+dfield.getName().toLowerCase(), string.valueof(dField.getType()));
                    }                   
                }               
            }           
        }
        Catch(Exception ex){       
            errorMessage=ex.getMessage();
        }
        return FieldLabelVsApi;
    }
}