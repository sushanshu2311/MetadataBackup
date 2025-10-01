/*************************************************
********************************
** Module Name : PipelineStageLog_Ctlr
** Description : This apex class is responsible for following things.
1. Update the Pipeline Stage Log in CMT.
2. Add / Remove Pipeline Stage Log from Pipeline Related List.
** Throws : NA
** Calls : NA
** Test Class :  Not yet**
** Organization : Navatar Group
** Product Name & Version : PE 3.5
** Revision History:-
** Version Date         Author 
** 3.5     18/07/2016   Faiz Ahmed 
*************************************************
********************************/
public with Sharing class PipelineStageLog_Ctlr{
    public boolean strEnableCMTSetup{get;set;}       /*Get updated checkbox value.*/
    public Org_Setting__mdt orgEmailSetting;        /*Record of org Setting saved in the backend.*/
    public boolean ODViewMode{get;set;}             /*False value of this property will hide the edit button & disabled checkbox,and show save & cancel button with enabled checkbox.*/
    public boolean isAdmin {get;set;}               /*Check admin rights.*/
    public String strNameSpace{get;set;}            /*Get NameSpace Dynamically*/
    public String strOrgNameSpace; 
    public String strPageName{get;set;}             /* Pagerefrence */
    
    /*
@Description: Constructor, on load.
*/
    public PipelineStageLog_Ctlr(){
        try{  
            ODViewMode = true; 
            isAdmin = false;
            strNameSpace = CommonUtility.strNameSpacePrefix;
            strOrgNameSpace = CommonUtility.strOrgNameSpacePrefix;
            orgEmailSetting = new Org_Setting__mdt();
            
            // SK: 8Dec2017
            if(Schema.sObjectType.Org_Setting__mdt.isAccessible() && Schema.sObjectType.Org_Setting__mdt.Fields.IsActive__c.isAccessible() && 
                Schema.sObjectType.Org_Setting__mdt.Fields.label.isAccessible() && Schema.sObjectType.Org_Setting__mdt.Fields.developername.isAccessible())
            {
                orgEmailSetting = [SELECT IsActive__c,label,developername FROM Org_Setting__mdt where developername ='Pipeline_Stage' limit 1];
            }
            
            if(orgEmailSetting != null)
                strEnableCMTSetup = orgEmailSetting.IsActive__c;
        } 
        catch(Exception ce){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Exception in PipelineStageLog_Ctlr: '+ce));
        }
    }
    
    /*
@Description: On click of edit button, it checks admin right and grant access.
*/
    public void editPipeLineLogSetup(){ 
        try {
            List<User> loggInUser = [ SELECT id, profile.name from User WHERE id=:userInfo.getUserId() LIMIT 1 ];
            if( loggInUser.size() > 0 && loggInUser[0].profile.name == 'System Administrator' ){
                isAdmin = true;
                ODViewMode = false;
            }
        }
        catch (Exception ce) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Exception in editPipeLineLogSetup: '+ce));
        }
    }
    /*
    Navatar Setup Pagerefrence Method   
    */
    public PageReference redirectpage() 
    {
        PageReference pageRef = new PageReference('/apex/'+strPageName+'');
        pageRef.setRedirect(true);
        return pageRef;
    }
    
    /*
@Description: It updates the org setting as per the checkbox value. And it also Remove / Add the relatedList of Pipeline Stage Log from Pipeline Layout.
@Parameter1: strEnableCMTSetup, checkbox value from page.
*/
    
    
    public void onSavePipeLineLogSetup()
    { 
        try 
        {
            
            if(!test.isrunningTest())
            {
                CustomMetadataService.updateMetadata(new List<SObject> {orgEmailSetting},strEnableCMTSetup);
            }
            ODViewMode = true;
            String strLayoutName = '';
            MetadataService.FileProperties[] fileProperties; 
            list<string> layOutList = new list<string>();
            MetadataService.MetadataPort service1 = new MetadataService.MetadataPort();
            service1.SessionHeader = new MetadataService.SessionHeader_element();
            service1.SessionHeader.sessionId = UserInfo.getSessionId();
            
            /*Add Pipeline Stage Log in the related List of Pipeline.*/
            List< String > pipelineLayouts= new List< String >();
            OfficeLocationsSetup_Ctlr objOffLoc = new OfficeLocationsSetup_Ctlr();
            if(!test.isrunningTest()){ 
               pipelineLayouts.add('Pipeline__c-Pipeline Layout');
               //pipelineLayouts= objOffLoc.getLayoutNameData(strNameSpace+'Pipeline__c');
            }
            else
            {
                pipelineLayouts.add('Account-Account Layout');
                pipelineLayouts.add('Pipeline__c-Pipeline Layout'); 
                
            }
            if(strEnableCMTSetup)
            {
                MetadataService.MetadataPort service = new MetadataService.MetadataPort();
                service.SessionHeader = new MetadataService.SessionHeader_element();
                service.SessionHeader.sessionId = UserInfo.getSessionId();        
                
                MetadataService.RelatedListItem mdsr= new MetadataService.RelatedListItem();
                list<string> strbtn= new list<string>();
                strbtn.add('New');
                mdsr.excludeButtons= null;
                String[] fl= new String[]{''+strNameSpace+'Date_Stage_Changed__c', ''+strNameSpace+'Changed_Stage__c', ''+strNameSpace+'Age__c','CREATEDBY_USER.ALIAS'}; //'LastModifiedBy.Alias' : refrence fields unable to add
                mdsr.fields=fl;
                mdsr.relatedList= ''+strNameSpace+'Pipeline_Stage_Log__c.'+strNameSpace+'Pipeline__c';
                mdsr.sortField=  (strNameSpace+'Date_Stage_Changed__c').replace(''+strOrgNameSpace+'','');
                mdsr.sortOrder= 'Asc';
                
                
                for(string strPipeLineLayoutname: pipelineLayouts){
                    MetadataService.Layout layout;
                    if(!strPipeLineLayoutname.startsWithIgnoreCase(strNameSpace))
                        strPipeLineLayoutname = strNameSpace+strPipeLineLayoutname;
                    if(!test.isrunningTest())
                    {
                        layout = (MetadataService.Layout)service.readMetadata('Layout',new String[] {strPipeLineLayoutname.replace('Pipeline__c-','Pipeline__c-'+strNameSpace)}).getRecords()[0];
                    }
                    else
                    {
                        MetadataService.Layout objLayout = new MetadataService.Layout(); 
                        MetadataService.RelatedListItem[] lstRelatedLists = new list<MetadataService.RelatedListItem>();
                        MetadataService.RelatedListItem objRelatedListItem = new MetadataService.RelatedListItem();                                 
                        String[] lstFields = new list<String>();
                        lstFields.add('Field1');
                        objRelatedListItem.fields = lstFields;
                        lstRelatedLists.add(objRelatedListItem);
                        objLayout.relatedLists = lstRelatedLists;
                        layout = objLayout;
                    }                               
                    if(layout.relatedLists == null)
                        layout.relatedLists= new List<MetadataService.RelatedListItem>();
                    layout.relatedLists.add(mdsr);          
                    List<MetadataService.RelatedListItem> lstMD= layout.relatedLists;
                    
                    for(integer i=0;i<lstMD.size();i++)
                    { 
                        if(lstMD[i].relatedList==''+strNameSpace+'Pipeline_Stage_Log__c.'+strNameSpace+'Pipeline__c'){
                            lstMD[i].excludeButtons= strbtn;
                        }
                        
                        List<String> strlist = new List<String>(); 
                        if(lstMD[i]!= null)
                        {
                            if(lstMD[i].fields!=null)
                            {  
                                for(String str : lstMD[i].fields)
                                {  
                                    str =  str.replace(''+strOrgNameSpace+'','');
                                    strlist.add(str);
                                }
                            }
                        }
                        lstMD[i].fields =  strlist; 
                    } 
                    CustomMetadataService.handleSaveResults(service.updateMetadata(new MetadataService.Metadata[] { layout })[0]);
                }
                
                /*Update Metadata to show/hide relatedList, Logic Ends. */
            }
            
            /*Remove Pipeline Stage Log from the related List of Pipeline.*/
            else
            {
                MetadataService.MetadataPort service = new MetadataService.MetadataPort();
                service.SessionHeader = new MetadataService.SessionHeader_element();
                service.SessionHeader.sessionId = UserInfo.getSessionId();
                for(string strPipeLineLayoutname: pipelineLayouts){
                    if(!strPipeLineLayoutname.startsWithIgnoreCase(strNameSpace))
                        strPipeLineLayoutname = strNameSpace+strPipeLineLayoutname;
                    MetadataService.Layout layout;
                    if(!test.isrunningTest())
                    {
                        layout = (MetadataService.Layout)service.readMetadata('Layout',new String[] {strPipeLineLayoutname.replace('Pipeline__c-','Pipeline__c-'+strNameSpace)}).getRecords()[0];
                    }
                    else
                    {
                        MetadataService.Layout objLayout = new MetadataService.Layout(); 
                        MetadataService.RelatedListItem[] lstRelatedLists = new list<MetadataService.RelatedListItem>();
                        MetadataService.RelatedListItem objRelatedListItem = new MetadataService.RelatedListItem();                                 
                        String[] lstFields = new list<String>();
                        lstFields.add('Field1');
                        //lstFields.add('Field2');
                        //lstFields.add('Field3');
                        objRelatedListItem.fields = lstFields;
                        lstRelatedLists.add(objRelatedListItem);
                        objLayout.relatedLists = lstRelatedLists;
                        layout = objLayout;
                    }
                    List<MetadataService.RelatedListItem> lstMD= new List<MetadataService.RelatedListItem>();
                    
                    if(layout.relatedLists !=null)
                        lstMD= layout.relatedLists;
                    for(integer i=0;i<lstMD.size();i++)
                    {
                        MetadataService.RelatedListItem mdsR= lstMD[i];
                        List<String> strlist = new List<String>();  
                        if(lstMD[i]!= null)
                        {
                            if(lstMD[i].fields!=null)
                            {  
                                for(String str : lstMD[i].fields)
                                {  
                                    str =  str.replace(''+strOrgNameSpace+'','');
                                    strlist.add(str);
                                }
                            }
                        }
                        lstMD[i].fields =  strlist; 
                        if(mdsR.relatedList== ''+strNameSpace+'Pipeline_Stage_Log__c.'+strNameSpace+'Pipeline__c')
                        {
                            layout.relatedLists.remove(i);  
                        } 
                    }
                    MetadataServiceHandler.handleSaveResults(service.updateMetadata(new MetadataService.Metadata[] { layout })[0]);
                }
                
            }
            
        }
        catch (Exception ce) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Exception in onSavePipeLineLogSetup: '+ce));
        }
    }
    
}