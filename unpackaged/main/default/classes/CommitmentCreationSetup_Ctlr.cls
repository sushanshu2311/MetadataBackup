/*********************************************************************************
** Module Name : Commitment Creation Setup
** Description : This is used for Enable Commitment Creation Setup And add or remove button from Fund related list.
** Throws : NA
** Calls : NA
** Test Class : NA
** Organization : Navatar Group
** Revision History:-
** Version Date(YYYY-MM-DD)       Author  Description of Action
** 1.0     2016-05-25             Pramod  
*********************************************************************************/
public with sharing class CommitmentCreationSetup_Ctlr{  
    public List<Navatar_Setup__c> lstNavSetup;                  //Contains navatar setup record.
    public String strWarningMessage{get;set;}                         //Show error message on page. 
    public Navatar_Setup__c objNavSetup;                        //Used for navatar setup record.  
    public Map<String, String> mapApiVsFieldLabel{get;set;}     //Store sbject fields api and Label.    
    public Map<string, string> FieldLabelVsApi{get;set;}        //Store sbject fields api and Label.    
    public String strFieldApiName{get;set;}                     //Store sbject fields api.  
    public String strNameSpace{get;set;}                        //Store org name space.
    public Boolean strEnableCMTSetup{get;set;}                  //Used for enable commitment functionality
    public Map<String ,String> sObjNameVsIconURL{get;set;}      //It hold the IconURL of sobject.   
    public Boolean isAuthorizeUser{get;set;}                    //Used to check if login user is system admin.      
    public String fundraisingIconUrl{get;set;}                  //It hold the IconURL of fundraising.
    public List<SelectOption> recodTypeOption{get;set;}         //Contaion recordtype.
    public String strRecodType{get;set;}                        //It hold company recordtype name.
    public String strRecodTypeName{get;set;}                      //It hold company recordtype id.    
    public String strAccRecodType{get;set;}                     //It hold the account recordtype.
    public String accountIconUrl{get;set;}                      //It hold the IconURL of account.
    public String commitmentIconUrl{get;set;}                   //It hold the IconURL of commitment.
    public String partnershipIconUrl{get;set;}                  //It hold the IconURL of partnership.
    public Map<String, String> mapRecodtypeNameVsId;            //Used to get recordtype name by id.
    public Map<String, RecordType> mapDeveloperNameVsRecordtype; //Used to get recordtype name by id.
    public List<Org_Setting__mdt> lstOrgSett;                   //get the org setting for commitment setup.
    public String strOrgNameSpace;                              //Used to store org name space.
    public List<RecordType> lstRecodType;                       //Used to query recordtype.
    public List<String> lstDefaultField{get;set;}               //Used to store default field api.
    public boolean showdetailSection{get;set;}                  //Used to show detail section on page.
    public boolean showEditSection{get;set;}                    //Used to show edit section on page.
    public String strOrgnizationNameSpace; 
    public String strPageName{get;set;}
    public String strErrorMessage{get;set;}
    
    public CommitmentCreationSetup_Ctlr(){ 
        try{      
            
            strNameSpace = CommonUtility.strNameSpacePrefix;
            strOrgnizationNameSpace = CommonUtility.strOrgNameSpacePrefix;
            strOrgNameSpace = strNameSpace;
            strNameSpace = strNameSpace.toLowerCase(); 
            strEnableCMTSetup = false; showdetailSection = true; 
            showEditSection = false; strWarningMessage = '';
            mapApiVsFieldLabel = new Map<String, String>();         
            mapRecodtypeNameVsId  = new Map<String, String>();
            mapDeveloperNameVsRecordtype  = new Map<String, RecordType>();
            objNavSetup = new Navatar_Setup__c(); 
            recodTypeOption = new list<SelectOption>(); 
            lstOrgSett = new list<Org_Setting__mdt>();
            //Added for security issues PE 3.5 By Qadir Khan 7 DEC 2017..
            if(Schema.sObjectType.Org_Setting__mdt.isAccessible() && Schema.sObjectType.Org_Setting__mdt.fields.IsActive__c.isAccessible() && Schema.sObjectType.Org_Setting__mdt.fields.label.isAccessible() && Schema.sObjectType.Org_Setting__mdt.fields.developername.isAccessible()){
                lstOrgSett=[SELECT IsActive__c,label,developername FROM Org_Setting__mdt where developername ='Commitment_Creation' limit 1];
            }
            if(lstOrgSett.size()>0 ){
                if(lstOrgSett[0].IsActive__c == true)
                    strEnableCMTSetup = true;
            }
            lstRecodType = new list<RecordType>();    
            //Added for security issues PE 3.5 By Qadir Khan 7 DEC 2017..
            if(Schema.sObjectType.RecordType.isAccessible() && Schema.sObjectType.RecordType.fields.name.isAccessible() && Schema.sObjectType.RecordType.fields.developername.isAccessible() && Schema.sObjectType.RecordType.fields.isActive.isAccessible()){
                lstRecodType =[SELECT id ,name,developername FROM RecordType where SObjectType ='Account' AND isActive = True];
            }
            lstDefaultField = new List<String> {''+strNameSpace+'Fundraising__c:Name',''+strNameSpace+'Fundraising__c:'+strNameSpace+'Legal_Name__c',''+strNameSpace+'Fundraising__c:'+strNameSpace+'Fund_Name__c',''+strNameSpace+'Fundraising__c:'+strNameSpace+'Portfolio_Company__c',''+strNameSpace+'Fundraising__c:'+strNameSpace+'Partner_Type__c','Account:Name',''+strNameSpace+'Partnership__c:'+strNameSpace+'Fund__c',''+strNameSpace+'Partnership__c:Name',''+strNameSpace+'Commitment__c:'+strNameSpace+'Limited_Partner__c',''+strNameSpace+'Commitment__c:'+strNameSpace+'Commitment_Amount_nearest__c',''+strNameSpace+'Commitment__c:'+strNameSpace+'Partnership__c',''+strNameSpace+'Commitment__c:'+strNameSpace+'Final_Commitment_Date__c',''+strNameSpace+'Commitment__c:'+strNameSpace+'Portfolio_Company__c'};
            lstDefaultField.add(''+strNameSpace+'Fundraising__c:ownerid');
            lstDefaultField.add(''+strNameSpace+'Commitment__c:ownerid');            
            for(String sfield: lstDefaultField){
                mapApiVsFieldLabel.put(sfield.toLowerCase(),'');
            }
            //Added for security issues PE 3.5 By Qadir Khan 7 DEC 2017..
            if(Schema.sObjectType.Navatar_Setup__c.isAccessible() && Schema.sObjectType.Navatar_Setup__c.fields.ccs__c.isAccessible() && Schema.sObjectType.Navatar_Setup__c.fields.admin_setting__c.isAccessible() && Schema.sObjectType.Navatar_Setup__c.fields.ccs_fundraising__c.isAccessible() && Schema.sObjectType.Navatar_Setup__c.fields.ccs_new_limited_partner__c.isAccessible() && Schema.sObjectType.Navatar_Setup__c.fields.ccs_partnership__c.isAccessible()){            
                lstNavSetup =[SELECT ccs__c,admin_setting__c,ccs_fundraising__c,ccs_new_limited_partner__c,ccs_partnership__c FROM Navatar_Setup__c where admin_setting__c=true Limit 1];
            }
            describeSObjectSample(); 
            if(lstNavSetup.Size()==0){                  
                strWarningMessage ='Code: 12355. Please contact Navatar Support. System setup improperly.';             
            }else{ 
                objNavSetup = lstNavSetup[0];  
                Set<String> setMapKeset= new Set<String>(); 
                List<String> lstFieldValue = new List<String>();
                for(String strapi: FieldLabelVsApi.keySet()){
                    strapi = strapi.toLowerCase();
                    setMapKeset.add(strapi);
                }
                //get fundrasing fields from navatar setup object 
                if(objNavSetup.ccs_fundraising__c!=null && objNavSetup.ccs_fundraising__c!=''){
                    lstFieldValue = objNavSetup.ccs_fundraising__c.split(';');     
                    for(integer i=0; i<lstFieldValue.Size(); i++){
                        if(i==0){
                            for(String str: lstFieldValue[i].split(',')){ 
                                if(!mapApiVsFieldLabel.keySet().contains(str.toLowerCase())){
                                    if(setMapKeset.contains(str.toLowerCase())==true){                                        
                                        if(string.isBlank(strFieldApiName))                                
                                            strFieldApiName = str;
                                        else
                                            strFieldApiName = strFieldApiName +','+str;
                                    }
                                }
                            }
                            strFieldApiName = strFieldApiName +';'; 
                        }
                        if(i==1){
                            for(String str: lstFieldValue[i].split(',')){  
                                if(!mapApiVsFieldLabel.keySet().contains(str.toLowerCase())){
                                    if(setMapKeset.contains(str.toLowerCase())==true){
                                        if(string.isBlank(strFieldApiName))                               
                                            strFieldApiName = str;
                                        else
                                            strFieldApiName = strFieldApiName+str+',';
                                    }
                                }
                            }                       
                        }                           
                    }
                    strFieldApiName = strFieldApiName.removeEnd(',')+'<~>';
                }
                //get commitment fields from navatar setup object   
                if(objNavSetup.ccs__c!=null && objNavSetup.ccs__c!=''){  
                    lstFieldValue = objNavSetup.ccs__c.split(';');                
                    for(integer i=0; i<lstFieldValue.Size(); i++){
                        if(i==0){
                            for(String str: lstFieldValue[i].split(',')){
                                if(!mapApiVsFieldLabel.keySet().contains(str.toLowerCase())){
                                    if(setMapKeset.contains(str.toLowerCase())==true){
                                        if(string.isBlank(strFieldApiName))                                
                                            strFieldApiName = str+',';
                                        else
                                            strFieldApiName = strFieldApiName +str+',';
                                    } 
                                }
                            }
                            strFieldApiName = strFieldApiName.removeEnd(',') +';'; 
                        }
                        if(i==1){
                            for(String str: lstFieldValue[i].split(',')){   
                                if(!mapApiVsFieldLabel.keySet().contains(str.toLowerCase())){
                                    if(setMapKeset.contains(str.toLowerCase())==true){
                                        if(string.isBlank(strFieldApiName))                               
                                            strFieldApiName = str;
                                        else
                                            strFieldApiName = strFieldApiName+str+',';
                                    }
                                }
                            }                       
                        }                           
                    } 
                    strFieldApiName = strFieldApiName.removeEnd(',')+'<~>';
                }
                //get limited partner fields from navatar setup object   
                if(objNavSetup.ccs_new_limited_partner__c!='' && objNavSetup.ccs_new_limited_partner__c!=null){  
                    lstFieldValue = objNavSetup.ccs_new_limited_partner__c.split(';');      
                    if(!string.valueof(lstFieldValue).contains(',')){
                        lstFieldValue.add(' ');
                    }
                    for(integer i=0; i<lstFieldValue.Size(); i++){
                        if(i==0){
                            strAccRecodType = lstFieldValue[0];
                        }
                        if(i==1){
                            for(String str: lstFieldValue[i].split(',')){                               
                                if(!mapApiVsFieldLabel.keySet().contains(str.toLowerCase())){
                                    if(setMapKeset.contains(str.toLowerCase())==true){
                                        if(string.isBlank(strFieldApiName))                                
                                            strFieldApiName = str;
                                        else
                                            strFieldApiName = strFieldApiName +str+',';
                                    }
                                }
                            }               
                        }                           
                    }
                    strFieldApiName = strFieldApiName.removeEnd(',')+'<~>'; 
                }
                //get partnership fields from navatar setup object   
                if(objNavSetup.ccs_partnership__c!=null && objNavSetup.ccs_partnership__c!=''){   
                    lstFieldValue = objNavSetup.ccs_partnership__c.split(',');      
                    for(String str: lstFieldValue){   
                        if(!mapApiVsFieldLabel.keySet().contains(str.toLowerCase())){
                            if(setMapKeset.contains(str.toLowerCase())==true){
                                if(string.isBlank(strFieldApiName))                                
                                    strFieldApiName = str;
                                else
                                    strFieldApiName = strFieldApiName +str+',';
                            }
                        }
                    }  
                    strFieldApiName = strFieldApiName.removeEnd(',');
                }
                
                for (RecordType rec: lstRecodType)
                {
                    recodTypeOption.add(new SelectOption(rec.id, rec.name));
                    mapRecodtypeNameVsId.put(rec.developername, rec.id);
                    mapDeveloperNameVsRecordtype.put(rec.id,rec);
                }               
                strRecodTypeName = mapRecodtypeNameVsId.get(strAccRecodType); 
                if(strRecodTypeName!=null){
                    if(mapDeveloperNameVsRecordtype.get(strRecodTypeName)!=null)
                        strRecodTypeName = mapDeveloperNameVsRecordtype.get(strRecodTypeName).name;
                }  
                if(String.isBlank(strRecodTypeName))
                    strErrorMessage = 'The assigned record type has either been deleted or is unavailable for use. If no record type is assigned, the commitment will get created with the system default record type.';
            }            
            
        }catch(Exception ex){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Exception in Constructor : '+ex)); 
        }
    }
    
    /*
@Description: Method called on click Edit Commitment Setup.
@Parameter1: variable isAuthorizeUser is used to check if user is system admin and strRecodType for get recordtype name on page
*/  
    public void onEditCommitmentSetup(){ 
        try{
            showdetailSection = false; showEditSection = true;
            Profile usrProfile = new Profile();
            if(Schema.sObjectType.Profile.isAccessible() && Schema.sObjectType.Profile.fields.Name.isAccessible())
                usrProfile = [Select Name from Profile where Id =: userinfo.getProfileid()];
            if(usrProfile!=null){
                if(usrProfile.name=='System Administrator'){                    
                    isAuthorizeUser = true;             
                    strRecodType  = mapRecodtypeNameVsId.get(strAccRecodType); 
                }
                else{
                    //strWarningMessage = 'You do not have permissions to edit this information. Please contact your System Administrator.';
                }
            }
            
        }catch(Exception ex){           
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Exception in onEditCommitmentSetup method : '+ex)); 
        }
    }
    
    /*
@Description: Method called on click Save Commitment Setup.
@Parameter1: variable strFieldApiName value is coming from page 
*/  
    public PageReference onSaveCommitmentSetup(){ 
        try 
        {   
            showdetailSection = true; showEditSection = false;
            if(lstOrgSett.size() >0){               
                if(lstOrgSett[0].IsActive__c != strEnableCMTSetup){                         
                    CustomMetadataService.updateMetadata(new List<SObject> {lstOrgSett[0]},strEnableCMTSetup);
                    updateMetadataMethod(strEnableCMTSetup);
                }
            } 
            if(lstNavSetup.Size()>0){
                List<String> lstStrContent= strFieldApiName.split('<~>');
                if(Schema.sObjectType.Navatar_Setup__c.fields.ccs_fundraising__c.isUpdateable()){
                    objNavSetup.ccs_fundraising__c= lstStrContent[0];
				}
                if(Schema.sObjectType.Navatar_Setup__c.fields.ccs__c.isUpdateable()){
                    objNavSetup.ccs__c= lstStrContent[1];
				}
                if(Schema.sObjectType.Navatar_Setup__c.fields.ccs_new_limited_partner__c.isUpdateable()){
                    objNavSetup.ccs_new_limited_partner__c = strAccRecodType+';'+lstStrContent[2];
				}
                if(Schema.sObjectType.Navatar_Setup__c.fields.ccs_partnership__c.isUpdateable()){    
                    objNavSetup.ccs_partnership__c = lstStrContent[3];
				}
                
                if(Navatar_Setup__c.sObjectType.getDescribe().isUpdateable()){
                    update objNavSetup;
                }
            } 
        }        
        catch (Exception ex) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Exception in onSaveCommitmentSetup method : '+ex)); 
        }        
        PageReference pageRef = new PageReference('/apex/Commitment_Creation_Setup');  
        pageRef.setRedirect(true);
        return pageRef;
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
@Description: Method is Used on Page Load.
@Parameter1: variable FieldLabelVsApi ,sObjNameVsIconURL is used on page to map field api with label and object with icon 
*/ 
    public void describeSObjectSample(){
        try 
        {
            list<string> lstObject = new list<string>();
            sObjNameVsIconURL = new Map<string, string>();
            lstObject.add(''+strNameSpace.toLowerCase()+'commitment__c');
            lstObject.add(''+strNameSpace.toLowerCase()+'fundraising__c');
            lstObject.add('account');
            lstObject.add(''+strNameSpace.toLowerCase()+'partnership__c');
            FieldLabelVsApi = CommonUtility.describeSObject(lstObject);
            lstObject.clear();          
            lstObject.add(''+strNameSpace+'Commitment__c');
            lstObject.add(''+strNameSpace+'Fundraising__c');
            lstObject.add('Account');
            lstObject.add(''+strNameSpace+'Partnership__c');           
            sObjNameVsIconURL = CommonUtility.describeSFTabs(lstObject);
           
            if(sObjNameVsIconURL.size() > 0 )
            {
                if(sObjNameVsIconURL.containsKey('Account'))
                    accountIconUrl = sObjNameVsIconURL.get('Account');
                if(sObjNameVsIconURL.containsKey(''+strNameSpace+'Commitment__c'))
                    commitmentIconUrl = sObjNameVsIconURL.get(''+strNameSpace+'Commitment__c');
                if(sObjNameVsIconURL.containsKey(''+strNameSpace+'Fundraising__c'))
                    fundraisingIconUrl = sObjNameVsIconURL.get(''+strNameSpace+'Fundraising__c');
                if(sObjNameVsIconURL.containsKey(''+strNameSpace+'Partnership__c')){
                    partnershipIconUrl = sObjNameVsIconURL.get(''+strNameSpace+'Partnership__c');                    
                }
                
            }           
        } 
        catch (Exception ex) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Exception in describeSObjectSample method : '+ex)); 
        }
    }
    
    /*
@Description: Method is Used on Onchange RecordType Picklist Value.
@Parameter1: variable strRecodTypeId ,strAccRecodType is used on page to get recordtype id and name on page 
*/ 
    public void displayRecordTypeName(){   
        try{
            
            strRecodTypeName = mapDeveloperNameVsRecordtype.get(strRecodType).name;         
            strAccRecodType = mapDeveloperNameVsRecordtype.get(strRecodType).developername;         
            
        }catch(Exception ex){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Exception in displayRecordTypeName method : '+ex)); 
        }
    }
    
    /*
@Description: Method is Used Reset Default Value.
@Parameter1: variable strNameSpace used to get name space 
*/ 
    public PageReference resetDefaultValue(){ 
        try{
            
            showdetailSection = true; showEditSection = false;
            if(lstNavSetup.Size()>0){
                if(Schema.sObjectType.Navatar_Setup__c.fields.ccs__c.isUpdateable())
                    objNavSetup.ccs__c = ''+strNameSpace+'commitment__c:'+strNameSpace+'partner_type__c,'+strNameSpace+'commitment__c:'+strNameSpace+'tax_forms__c;';
                if(Schema.sObjectType.Navatar_Setup__c.fields.ccs_fundraising__c.isUpdateable())
                    objNavSetup.ccs_fundraising__c = ''+strNameSpace+'fundraising__c:name,'+strNameSpace+'fundraising__c:'+strNameSpace+'legal_name__c;'+strNameSpace+'fundraising__c:'+strNameSpace+'fund_name__c,'+strNameSpace+'fundraising__c:'+strNameSpace+'portfolio_company__c';
                if(Schema.sObjectType.Navatar_Setup__c.fields.ccs_new_limited_partner__c.isUpdateable())
                    objNavSetup.ccs_new_limited_partner__c = 'LimitedPartner;account:name';
                if(Schema.sObjectType.Navatar_Setup__c.fields.ccs_partnership__c.isUpdateable())
                    objNavSetup.ccs_partnership__c = ''+strNameSpace+'partnership__c:'+strNameSpace+'fund__c,'+strNameSpace+'partnership__c:name';
                
                if(Navatar_Setup__c.sObjectType.getDescribe().isUpdateable()){
                    update objNavSetup;
                }
            }           
            
        }catch(Exception ex){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Exception in resetDefaultValue method : '+ex)); 
        }
        PageReference pageRef = new PageReference('/apex/Commitment_Creation_Setup');  
        pageRef.setRedirect(true);
        return pageRef;
    }
    
    /*
@Description: Method called on click cancel button.
@Parameter1: Variable showdetailSection is used to show detail section.
*/
    public PageReference onCancel(){
        showdetailSection= true; showEditSection= false;
        PageReference orderPage = new PageReference('/apex/Commitment_Creation_Setup');
        orderPage.setRedirect(true);
        return orderPage;         
    }
    
    /*
@Description: Method is Used for Update Related List Button on Page Layout.
@Parameter1: variable isEnableSetup is used to check if commitment setup is enable. 
*/ 
    public void updateMetadataMethod(boolean isEnableSetup){
        try{ 
            
            string strNameSpace = CommonUtility.strNameSpacePrefix;
            string strOrgNameSpace = strNameSpace;
            //isEnableSetup = false;
            MetadataService.MetadataPort service = new MetadataService.MetadataPort();
            Service.SessionHeader = new MetadataService.SessionHeader_element();
            Service.SessionHeader.sessionId = UserInfo.getSessionId();        
            ContactTransferSettingsSetup_Ctlr contCtlr= new ContactTransferSettingsSetup_Ctlr();
            for(String strFundrasing : contCtlr.getLayoutNameData(strNameSpace+'Fundraising__c')){ 
                if(!strFundrasing.startsWithIgnoreCase(strNameSpace))
                    strFundrasing = strNameSpace+strFundrasing;
                //Used for update fundraising layout for add "Quick Create Commitments" on detail page.
                MetadataService.Layout layout = (MetadataService.Layout)service.readMetadata('Layout',new String[] {strFundrasing.replace('Fundraising__c-','Fundraising__c-'+strNameSpace)}).getRecords()[0];
                if(layout.fullname != null){
                    List<MetadataService.RelatedListItem> lstMD= new List<MetadataService.RelatedListItem>();
                    if(layout.relatedLists!=null)
                        lstMD = layout.relatedLists;
                    for(integer i=0;i<lstMD.size();i++){                
                        MetadataService.RelatedListItem mdsR= lstMD[i];  
                        List<String> strlist = new List<String>();                    
                        if(lstMD[i]!=null){
                            if(lstMD[i].fields!=null){  
                                for(String str : lstMD[i].fields){ 
                                    str =  str.replace(''+strOrgnizationNameSpace+'','');
                                    strlist.add(str);
                                }
                            }
                        }
                        lstMD[i].fields =  strlist; 
                    }  
                    if(layout.customButtons==null){ 
                        if(isEnableSetup==true){
                            layout.customButtons = new List<String>();
                            layout.customButtons.add(''+strNameSpace+'Quick_Create_Commitments');
                        }
                    }
                    else{ 
                        for(integer i=0;i<(layout.customButtons).size();i++){  
                            if(isEnableSetup==true){
                                if((layout.customButtons).get(i)!=''+strNameSpace+'Quick_Create_Commitments'){    
                                    layout.customButtons = new List<String>();
                                    layout.customButtons.add(''+strNameSpace+'Quick_Create_Commitments');
                                }
                            }else{
                                if((layout.customButtons).get(i)==''+strNameSpace+'Quick_Create_Commitments'){                          
                                    layout.customButtons.remove(0);                         
                                }   
                            }                       
                        }       
                    }       
                    MetadataServiceHandler.handleSaveResults(service.updateMetadata( new MetadataService.Metadata[] { layout })[0]);
                }
            }
            //Used for update account layout for add "Quick Create Commitments" button on Commitment related list.
            for(String strInstitutionLayoutname : contCtlr.getLayoutNameData('Account')){ 
                if(strInstitutionLayoutname.toLowerCase().contains('company') || strInstitutionLayoutname.toLowerCase().contains('property')){
                    MetadataService.Layout layout2 = (MetadataService.Layout)service.readMetadata('Layout',new String[] {strInstitutionLayoutname.replace('Account-','Account-'+strOrgnizationNameSpace)}).getRecords()[0];
                    //MetadataService.Layout layout2 = (MetadataService.Layout)service.readMetadata('Layout',new String[] {'Account-'+strOrgnizationNameSpace+'Company'}).getRecords()[0];
                    if(layout2.fullname != null){
                        List<MetadataService.RelatedListItem> lstMD2= new List<MetadataService.RelatedListItem>();
                        if(layout2.relatedLists!=null)
                            lstMD2 = layout2.relatedLists;
                        for(integer i=0;i<lstMD2.size();i++){                
                            MetadataService.RelatedListItem mdsR= lstMD2[i]; 
                            List<String> strlist = new List<String>();                    
                            if(lstMD2[i]!=null){
                                if(lstMD2[i].fields!=null){  
                                    for(String str : lstMD2[i].fields){  
                                        str =  str.replace(''+strOrgnizationNameSpace+'','');
                                        strlist.add(str);
                                    }
                                }
                            }
                            lstMD2[i].fields =  strlist;                     
                            String[] custButton2= new String[]{''+strNameSpace+'Quick_Create_Commitments'};                
                            if(mdsR.relatedList==''+strNameSpace+'Commitment__c.'+strNameSpace+'Portfolio_Company__c'){
                                if(mdsR.customButtons!= null ){
                                    if(isEnableSetup==false)
                                        mdsR.customButtons= null;                        
                                }else{
                                    if(isEnableSetup==true)
                                        mdsR.customButtons= custButton2;
                                }                           
                            }                
                        }        
                        MetadataServiceHandler.handleSaveResults(service.updateMetadata(new MetadataService.Metadata[] { layout2 })[0]);
                    }
                }
            }
        }
        catch(Exception ex){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Exception in updateMetadataMethod : '+ex)); 
        } 
    }    
}