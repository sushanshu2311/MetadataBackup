/*************************************************
********************************
** Module Name : OfficeLocationsSetup_Ctlr
** Description : This apex class is responsible for following things.
    1. Update the Office Location CheckBox in CMT.
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

public with Sharing class OfficeLocationsSetup_Ctlr
{
    public boolean strEnableCMTSetup{get;set;}      /*Handle checkbox value.*/
    public String strErrorMsg{get;set;}             /*To display error message.*/
    public Org_Setting__mdt orgEmailSetting;        /*Contains Org Setting for this page.*/
    public boolean ODViewMode{get;set;}             /*Enable/Disable page values in renderAs.*/
    public boolean isAdmin {get;set;}               /*Check admin rights*/
    public String strNameSpace{get;set;}            /*Get NameSpace Dynamically*/
    public MetadataService.RelatedListItem mdsrTemp;
    public List< String > accLayouts;
    public List< String > conLayouts;
    public String strOrgnizationNameSpace;
    public String strPageName{get;set;}             /* Pagerefrence */
    
    /*
    @Description: Constructor
    */
    public OfficeLocationsSetup_Ctlr()
    {
        try
        {   strNameSpace='';
            accLayouts = new List< String >();
            conLayouts = new List< String >();
            ODViewMode = true; 
            isAdmin = false;
            strNameSpace = CommonUtility.strNameSpacePrefix;
            strOrgnizationNameSpace = CommonUtility.strOrgNameSpacePrefix;       
            orgEmailSetting = new Org_Setting__mdt();
            
            // SK: 8Dec2017
            if(Schema.sObjectType.Org_Setting__mdt.isAccessible() && Schema.sObjectType.Org_Setting__mdt.Fields.IsActive__c.isAccessible() && 
                Schema.sObjectType.Org_Setting__mdt.Fields.label.isAccessible() && Schema.sObjectType.Org_Setting__mdt.Fields.developername.isAccessible())
            {
                orgEmailSetting = [SELECT IsActive__c,label,developername FROM Org_Setting__mdt where developername ='Office_Location_Setting' limit 1];
            }
            
            if(orgEmailSetting != null)
                strEnableCMTSetup = orgEmailSetting.IsActive__c;
        } 
        catch(Exception ce){
             ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Exception in OfficeLocationsSetup: '+ce));
        }
    }
    
    /* Pagerefrence */
    
    public PageReference redirectpage() 
    {
        PageReference pageRef = new PageReference('/apex/'+strPageName+'');
        pageRef.setRedirect(true);
        return pageRef;
    }
    
    public list<string> getLayoutNameData(string objName)
    {
        List< String > strLayoutName = new List< String >();
        MetadataService.MetadataPort service = new MetadataService.MetadataPort();
        service.SessionHeader = new MetadataService.SessionHeader_element();
        service.SessionHeader.sessionId = UserInfo.getSessionId();
        
        List<MetadataService.ListMetadataQuery> queries = new List<MetadataService.ListMetadataQuery>();
        MetadataService.ListMetadataQuery listView = new MetadataService.ListMetadataQuery();
        listView.type_x = 'Layout';
        listView.folder = objName;
        queries.add(listView);
        MetadataService.FileProperties[] fileProperties = service.listMetadata(queries, 25);
        for(MetadataService.FileProperties fileProperty : fileProperties)
        {
            strLayoutName.add(fileProperty.fullname);
        }   
        return strLayoutName;
    }
    
    /*
    @Description: On click of edit button it checks the admin rights and grant access.
    */
    public void editOffLocSetup()
    { 
        try 
        {
            List<User> loggInUser = [ SELECT id, profile.name from User WHERE id=:userInfo.getUserId() LIMIT 1 ];
            if( loggInUser.size() > 0 && loggInUser[0].profile.name == 'System Administrator' )
            {
                isAdmin = true;
                ODViewMode = false;
                accLayouts = getLayoutNameData('Account');
                conLayouts = getLayoutNameData('Contact');
            }
        }
        catch (Exception ce) {
           ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Exception in editOffLocSetup: '+ce));
        }
    }
    
    /*
    @Description: Calls onClick of Save button and update Custom Metadata Types.
    */
    public void onSaveOffLocSetup()
    { 
        try 
        {
            try
            {
                CustomMetadataService.updateMetadata(new List<SObject> {orgEmailSetting},strEnableCMTSetup);
            }
            catch(exception ex)
            {
            }
            ODViewMode = true;            
            
            
            /*Add Pipeline Stage Log in the related List of Pipeline.*/
            if(strEnableCMTSetup)
            {
                MetadataService.MetadataPort service = new MetadataService.MetadataPort();
                service.SessionHeader = new MetadataService.SessionHeader_element();
                service.SessionHeader.sessionId = UserInfo.getSessionId();        
                
                mdsrTemp= new MetadataService.RelatedListItem();
                String[] fl= new String[]{'NAME',''+strNameSpace+'Street__c', ''+strNameSpace+'City__c', ''+strNameSpace+'State__c',''+strNameSpace+'Country__c',''+strNameSpace+'Primary__c'};
                mdsrTemp.excludeButtons= null;
                //String[] fl= new String[]{'NAME'};
                mdsrTemp.fields = fl;
                mdsrTemp.relatedList = ''+strNameSpace+'Office_Location_Info__c.'+strNameSpace+'Organization_Name__c';
                mdsrTemp.sortField= 'NAME';
                mdsrTemp.sortOrder= 'Asc';
                
                for( String objLayout : accLayouts){
                   addRelatedListAct(objLayout.replace('Account-','Account-'+strOrgnizationNameSpace));
                }  
                //addRelatedListAct('Account-Institutions');
                
                for(String objLayout : conLayouts){
                    string layoutName= objLayout.replace('Contact-','Contact-'+strOrgnizationNameSpace);

                    MetadataService.Layout layout = (MetadataService.Layout)service.readMetadata('Layout',new String[] {layoutName}).getRecords()[0];
                    
                    if(layout != null && layout.fullname != null){
                        // Add Layout section, layout, item and field
                        if(layout.layoutSections== null)
                        {
                            layout.layoutSections = new List<MetadataService.LayoutSection>();
                            
                            MetadataService.LayoutSection newLayoutSection = new MetadataService.LayoutSection();
                            newLayoutSection.style = 'TwoColumnsLeftToRight';
                            newLayoutSection.detailHeading= true;
                            newLayoutSection.editHeading= true;
                            
                            MetadataService.LayoutColumn newLayoutColumn = new MetadataService.LayoutColumn();
                            MetadataService.LayoutItem newLayoutItem = new MetadataService.LayoutItem();
                            layout.summaryLayout.summaryLayoutItems = new List<MetadataService.SummaryLayoutItem>();
                            MetadataService.SummaryLayoutItem summaryLayoutItem = new MetadataService.SummaryLayoutItem();
                            
                            newLayoutItem.field = strNameSpace+'Office_Location_Info__c';
                            newLayoutColumn.layoutItems = new List<MetadataService.LayoutItem> { newLayoutItem };
                            newLayoutSection.layoutColumns = new List<MetadataService.LayoutColumn> { newLayoutColumn };
                            layout.layoutSections.add(newLayoutSection);        
                            
                            summaryLayoutItem.posX = 0;
                            summaryLayoutItem.posY = 1;
                            summaryLayoutItem.field = strNameSpace+'Office_Location_Info__c';
                            layout.summaryLayout.summaryLayoutItems.add(summaryLayoutItem);
                            
                            List<MetadataService.RelatedListItem> lstMD= (layout.relatedLists!= null?layout.relatedLists: new List<MetadataService.RelatedListItem>());
                            
                            for(integer i=0;i<lstMD.size();i++)
                            {
                               List<String> strlist = new List<String>();  
                               if(lstMD[i]!= null)
                               {
                                   if(lstMD[i].fields!=null)
                                   {  
                                       for(String str : lstMD[i].fields)
                                       {  
                                           str =  str.replace(''+strOrgnizationNameSpace+'','');
                                           strlist.add(str);
                                       }
                                   }
                               }
                               lstMD[i].fields =  strlist; 
                            } 
                            // Update the Layout
                            MetadataServiceHandler.handleSaveResults(service.updateMetadata(new MetadataService.Metadata[] { layout })[0]);
                        }
                        else
                        {
                            boolean isCreate= true;
                            List<MetadataService.LayoutSection> lstLayoutSection = layout.layoutSections;     
                            for(integer i=0;i<lstLayoutSection.size();i++)
                            {
                                if(lstLayoutSection[i].style != null )
                                {
                                    for(MetadataService.LayoutColumn mst : lstLayoutSection[i].layoutColumns)
                                    {                           
                                        if(mst.layoutItems != null)
                                        {
                                            Integer k=0;
                                            for(MetadataService.LayoutItem abc: mst.layoutItems)
                                            {   
                                                string fieldName= strNameSpace+'Office_Location_Info__c';
                                                if(abc.field == fieldName)
                                                {  
                                                    isCreate = false;
                                                    break;
                                                }   
                                            }                               
                                        }
                                    }
                                }
                            }
                            if(isCreate== true){
                                MetadataService.LayoutSection newLayoutSection = layout.layoutSections[1]; 
                                MetadataService.LayoutColumn newLayoutColumn = new MetadataService.LayoutColumn();
                                List<MetadataService.LayoutColumn> lcs= newLayoutSection.layoutColumns;
                                List<MetadataService.LayoutItem> litm = new List<MetadataService.LayoutItem>();
                                if(lcs.size() > 0 && lcs[0].layoutItems != null){
                                    litm= lcs[0].layoutItems;
                                }                                   
                                else{
                                    newLayoutSection = layout.layoutSections[0];
                                    lcs= newLayoutSection.layoutColumns;
                                    litm= lcs[0].layoutItems;
                                }                               
                                MetadataService.LayoutItem newLayoutItem = new MetadataService.LayoutItem();
                                newLayoutItem.field = strNameSpace+'Office_Location_Info__c';
                                litm.add(newLayoutItem);                        
                                
                                List<MetadataService.RelatedListItem> lstMD= new List<MetadataService.RelatedListItem>();
                                if(layout.relatedLists!=null)
                                    lstMD = layout.relatedLists;
                                for(integer i=0;i<lstMD.size();i++)
                                {
                                   List<String> strlist = new List<String>();  
                                   if(lstMD[i]!= null)
                                   {
                                       if(lstMD[i].fields!=null)
                                       {  
                                           for(String str : lstMD[i].fields)
                                           {   
                                               str =  str.replace(''+strOrgnizationNameSpace+'','');
                                               strlist.add(str);
                                           }
                                       }
                                   }
                                   lstMD[i].fields =  strlist; 
                                } 
                                MetadataServiceHandler.handleSaveResults(service.updateMetadata(new MetadataService.Metadata[] { layout })[0]);  
                            }
                            
                        }
                    }
                }
            }            
            else
            {
                for( String objLayout : accLayouts){
                    removeRelatedListAct(objLayout.replace('Account-','Account-'+strOrgnizationNameSpace));
                }
            
                MetadataService.MetadataPort service = new MetadataService.MetadataPort();
                service.SessionHeader = new MetadataService.SessionHeader_element();
                service.SessionHeader.sessionId = UserInfo.getSessionId();
            
                for(String objLayout : conLayouts){
                   string layoutName= objLayout.replace('Contact-','contact-'+strOrgnizationNameSpace);
                
                    MetadataService.Layout layout = (MetadataService.Layout)service.readMetadata('Layout',new String[] {layoutName}).getRecords()[0];
                    if(layout != null && layout.fullname != null){
                        List<MetadataService.LayoutSection> newLayoutSection = layout.layoutSections;
                        
                        List<MetadataService.LayoutColumn> newLayoutCol= new List<MetadataService.LayoutColumn>();
                        boolean isdelete = false;
                        Integer a=0,b=0,c=0;
                        for(integer i=0;i<newLayoutSection.size();i++)
                        {
                            if(newLayoutSection[i].style != null )
                            {
                                Integer j=0;
                                for(MetadataService.LayoutColumn mst : newLayoutSection[i].layoutColumns)
                                {                           
                                    if(mst.layoutItems != null)
                                    {
                                        Integer k=0;
                                        for(MetadataService.LayoutItem abc: mst.layoutItems)
                                        {   
                                            string fieldName= strNameSpace+'Office_Location_Info__c';
                                            if(abc.field == fieldName)
                                            {  
                                                isdelete = true;
                                                a=i;b=j;c=k;
                                                break;
                                            }                                   
                                            k++;
                                        }                               
                                    }
                                    j++;
                                }
                            }
                        }
                        if(isdelete == true){
                            layout.layoutSections[a].layoutColumns[b].layoutItems.remove(c);
                            List<MetadataService.RelatedListItem> lstMD= new List<MetadataService.RelatedListItem>();
                            if(layout.relatedLists!=null)
                                lstMD = layout.relatedLists;
                            for(integer i=0;i<lstMD.size();i++)
                            {
                                List<String> strlist = new List<String>();  
                                if(lstMD[i]!= null)
                                {
                                    if(lstMD[i].fields!=null)
                                    {  
                                        for(String str : lstMD[i].fields)
                                        {  
                                            str =  str.replace(''+strOrgnizationNameSpace+'','');
                                            strlist.add(str);
                                        }
                                    }
                                }
                                lstMD[i].fields =  strlist; 
                            } 
                            // Update the Layout
                            MetadataServiceHandler.handleSaveResults(service.updateMetadata(new MetadataService.Metadata[] { layout })[0]);
                        }
                    }
                }
            }
        }catch (Exception ex) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Exception in onSaveOffLocSetup: '+ex));
        }
    }
    
    public void addRelatedListAct(string strName)
    {
        try
        {
            MetadataService.MetadataPort service = new MetadataService.MetadataPort();
            service.SessionHeader = new MetadataService.SessionHeader_element();
            service.SessionHeader.sessionId = UserInfo.getSessionId(); 
            
            MetadataService.Layout layout = (MetadataService.Layout)service.readMetadata('Layout',new String[] {strName}).getRecords()[0];
            if(layout.fullname != null){
                if(layout.relatedLists == null)
                    layout.relatedLists= new List<MetadataService.RelatedListItem>();
                layout.relatedLists.add(mdsrTemp);          
                List<MetadataService.RelatedListItem> lstMD= new List<MetadataService.RelatedListItem>();
                    if(layout.relatedLists!=null)
                        lstMD = layout.relatedLists;
                for(integer i=0;i<lstMD.size();i++)
                {
                    List<String> strlist = new List<String>();  
                    if(lstMD[i]!= null)
                    {
                        if(lstMD[i].fields!=null)
                        {  
                            for(String str : lstMD[i].fields)
                            {  
                                str =  str.replace(''+strOrgnizationNameSpace+'','');
                                strlist.add(str);
                            }
                        }
                    }
                    lstMD[i].fields =  strlist; 
                } 
                MetadataServiceHandler.handleSaveResults(service.updateMetadata(new MetadataService.Metadata[] { layout })[0]);
            }
        }Catch(Exception ex){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Exception in onSaveOffLocSetup: '+ex));
        }
    }
    
    public void removeRelatedListAct(string strName)
    {
        try
        {
            MetadataService.MetadataPort service = new MetadataService.MetadataPort();
            service.SessionHeader = new MetadataService.SessionHeader_element();
            service.SessionHeader.sessionId = UserInfo.getSessionId();
            MetadataService.Layout layout = (MetadataService.Layout)service.readMetadata('Layout',new String[] {strName}).getRecords()[0];
            if(layout.fullname != null){
                List<MetadataService.RelatedListItem> lstMD= new List<MetadataService.RelatedListItem>();
                if(layout.relatedLists!=null)
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
                                str =  str.replace(''+strOrgnizationNameSpace+'','');
                                strlist.add(str);
                            }
                        }
                    }
                    lstMD[i].fields =  strlist; 
                    if(mdsR.relatedList == ''+strNameSpace+'Office_Location_Info__c.'+strNameSpace+'Organization_Name__c')
                    {
                        layout.relatedLists.remove(i);  
                    } 
                }
                MetadataServiceHandler.handleSaveResults(service.updateMetadata(new MetadataService.Metadata[] { layout })[0]);
            }
        }Catch(Exception ex){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Exception in onSaveOffLocSetup: '+ex));
        }
    }
}