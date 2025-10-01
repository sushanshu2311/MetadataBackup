/*********************************************************************************
** Module Name : RequireFieldComp_Ctlr
** Description : This module is use to get all the layout name of given object.
** Throws : NA
** Calls : NA
** Test Class : TestRequireFieldComp_Ctlr
**
** Organization : Navatar Group
**
** Revision History:-
** Version   Date        Author        WO#   Description of Action
** 3.5       2016-05-30  Sachin Kumar  NA    To all layout name.
*********************************************************************************/

public With Sharing Class RequireFieldComp_Ctlr{
    
    public String strObjectApiName {get; set;}
    public String strLayoutNameData {get;set;}
    public String fieldApiName {get; set;}
    public String strObjectLayoutName{get;set;}
    public List<String> listRequiredField {get; set;}
    public String strNameSpace{get;set;}
    public String strOrgNameSpace{get;set;}
    
    public RequireFieldComp_Ctlr()
    {
        strObjectApiName = '';
        strLayoutNameData = '';
        strNameSpace = CommonUtility.strNameSpacePrefix;
        strOrgNameSpace = CommonUtility.strOrgNameSpacePrefix;
        
        
        
    }
    public void getLayoutNameData()
    {
        try{
            
            String strLayoutName = '';
            
            MetadataService.MetadataPort service = new MetadataService.MetadataPort();
            service.SessionHeader = new MetadataService.SessionHeader_element();
            service.SessionHeader.sessionId = UserInfo.getSessionId();
            List<MetadataService.ListMetadataQuery> queries = new List<MetadataService.ListMetadataQuery>();
            MetadataService.ListMetadataQuery listView = new MetadataService.ListMetadataQuery();
            listView.type_x = 'Layout';
            listView.folder = strObjectApiName;
            queries.add(listView);
            MetadataService.FileProperties[] fileProperties;
            if(!Test.isRunningTest())
            {
                fileProperties = service.listMetadata(queries, 25);
               
            }
            else
            {
                MetadataService.FileProperties obj1 = new MetadataService.FileProperties();
                obj1.fullName='Account-Account Layout';     
                obj1.id= Id.valueOf('00h4100000153fCAAQ');
                MetadataService.FileProperties obj2 = new MetadataService.FileProperties();
                obj2.fullName='Account-Account %28Sales%29 Layout';     
                obj2.id= Id.valueOf('00h4100000153fAAAQ');
                MetadataService.FileProperties[] arryFileProperty = new list<MetadataService.FileProperties>();
                arryFileProperty.add(obj1);
                arryFileProperty.add(obj2);                     
                fileProperties = arryFileProperty; 
            }           
            for(MetadataService.FileProperties fileProperty : fileProperties)
            {
                strLayoutName = strLayoutName+fileProperty.fullname+'<$$>';
                
                
            }   
            
            strLayoutNameData = strLayoutName.removeEnd('<$$>');
        }
        catch (Exception objExcp) {
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, objExcp.getMessage()));
            
        }       
        
    }
    
    public void getLayoutInformation()
    {
        listRequiredField = new List <String>();
        try{ 
            
            String strlayoutObjectName='';
            if(strObjectApiName.toLowercase() == 'account' || strObjectApiName.toLowercase() == 'contact')
            {
                strlayoutObjectName = strObjectApiName+'-'+strOrgNameSpace+strObjectLayoutName;
            }
            else
            {                   
                strlayoutObjectName = strObjectApiName+'-'+strNameSpace+strObjectLayoutName;
            } 
            MetadataService.MetadataPort service = new MetadataService.MetadataPort();
            service.SessionHeader = new MetadataService.SessionHeader_element();
            service.SessionHeader.sessionId = UserInfo.getSessionId();
            list<string> str= new List<string>();
            MetadataService.Layout layout;
            if(!Test.isRunningTest())
            {
                layout = (MetadataService.Layout)service.readMetadata('Layout',new String[] {strlayoutObjectName}).getRecords()[0];
            }
            else
            {
                MetadataService.LayoutSection[] lstLayoutSections = new list<MetadataService.LayoutSection>();
                MetadataService.LayoutColumn[] lstLayoutColumns = new list<MetadataService.LayoutColumn>();
                MetadataService.LayoutItem[] lstLayoutItems = new list<MetadataService.LayoutItem>();
                MetadataService.LayoutSection objLayoutSection = new MetadataService.LayoutSection();
                MetadataService.LayoutColumn objLayoutColumn = new MetadataService.LayoutColumn();
                MetadataService.LayoutItem objLayoutItem = new MetadataService.LayoutItem();
                objLayoutItem.behavior = 'required';
                objLayoutItem.field = 'Name';
                lstLayoutItems.add(objLayoutItem);
                objLayoutColumn.layoutItems = lstLayoutItems;
                lstLayoutColumns.add(objLayoutColumn);
                objLayoutSection.layoutColumns = lstLayoutColumns;
                lstLayoutSections.add(objLayoutSection);                    
                MetadataService.Layout layoutData = new MetadataService.Layout();
                layoutData.layoutSections = lstLayoutSections;
                layout = layoutData;
            }
            
            List<MetadataService.LayoutSection> newLayoutSection = layout.layoutSections;
            for(integer i=0;i<newLayoutSection.size();i++){
                for(MetadataService.LayoutColumn mst : newLayoutSection[i].layoutColumns){
                   if(mst.layoutItems != null){
                        for(MetadataService.LayoutItem abc: mst.layoutItems){
                            if(abc.field !=null)
                            {   
                                string fieldBehavior = abc.behavior;
                                if(fieldBehavior.toLowercase() == 'required')
                                {
                                    str.add(abc.behavior);
                                    listRequiredField.add(abc.field);
                                    
                                }
                            }
                        }
                    }
                }
                
            }
                    
        }
        
        catch (Exception objExcp) {
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, objExcp.getMessage()));
            
        }       
    }
}