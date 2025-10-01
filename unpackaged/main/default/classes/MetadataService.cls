public with sharing class MetadataService {
    
    public class SaveResult {
        public MetadataService.Error[] errors;
        public String fullName;
        public Boolean success;
        private String[] errors_type_info = new String[]{'errors','http://soap.sforce.com/2006/04/metadata',null,'0','-1','false'};
        private String[] fullName_type_info = new String[]{'fullName','http://soap.sforce.com/2006/04/metadata',null,'1','1','false'};
        private String[] success_type_info = new String[]{'success','http://soap.sforce.com/2006/04/metadata',null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://soap.sforce.com/2006/04/metadata','true','false'};
        private String[] field_order_type_info = new String[]{'errors','fullName','success'};
    }
    
  
    
    public class MiniLayout {
        public String[] fields;
        public MetadataService.RelatedListItem[] relatedLists;
        private String[] fields_type_info = new String[]{'fields','http://soap.sforce.com/2006/04/metadata',null,'0','-1','false'};
        private String[] relatedLists_type_info = new String[]{'relatedLists','http://soap.sforce.com/2006/04/metadata',null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{'http://soap.sforce.com/2006/04/metadata','true','false'};
        private String[] field_order_type_info = new String[]{'fields','relatedLists'};
    }
    
    
    public class RelatedListItem {
        public String[] customButtons;
        public String[] excludeButtons;
        public String[] fields;
        public String relatedList;
        public String sortField;
        public String sortOrder;
        private String[] customButtons_type_info = new String[]{'customButtons','http://soap.sforce.com/2006/04/metadata',null,'0','-1','false'};
        private String[] excludeButtons_type_info = new String[]{'excludeButtons','http://soap.sforce.com/2006/04/metadata',null,'0','-1','false'};
        private String[] fields_type_info = new String[]{'fields','http://soap.sforce.com/2006/04/metadata',null,'0','-1','false'};
        private String[] relatedList_type_info = new String[]{'relatedList','http://soap.sforce.com/2006/04/metadata',null,'1','1','false'};
        private String[] sortField_type_info = new String[]{'sortField','http://soap.sforce.com/2006/04/metadata',null,'0','1','false'};
        private String[] sortOrder_type_info = new String[]{'sortOrder','http://soap.sforce.com/2006/04/metadata',null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://soap.sforce.com/2006/04/metadata','true','false'};
        private String[] field_order_type_info = new String[]{'customButtons','excludeButtons','fields','relatedList','sortField','sortOrder'};
    }
    
    
    
    
    public class WaveApplication extends Metadata {
        public String type = 'WaveApplication';
        public String fullName;
        private String[] fullName_type_info = new String[]{'fullName','http://soap.sforce.com/2006/04/metadata',null,'0','1','false'};
        public String assetIcon;
        public String description;
        public String folder;
        public String masterLabel;
        public MetadataService.FolderShare[] shares;
        private String[] assetIcon_type_info = new String[]{'assetIcon','http://soap.sforce.com/2006/04/metadata',null,'0','1','false'};
        private String[] description_type_info = new String[]{'description','http://soap.sforce.com/2006/04/metadata',null,'0','1','false'};
        private String[] folder_type_info = new String[]{'folder','http://soap.sforce.com/2006/04/metadata',null,'1','1','false'};
        private String[] masterLabel_type_info = new String[]{'masterLabel','http://soap.sforce.com/2006/04/metadata',null,'1','1','false'};
        private String[] shares_type_info = new String[]{'shares','http://soap.sforce.com/2006/04/metadata',null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{'http://soap.sforce.com/2006/04/metadata','true','false'};
        private String[] type_att_info = new String[]{'xsi:type'};
        private String[] field_order_type_info = new String[]{'fullName', 'assetIcon','description','folder','masterLabel','shares'};
    }

    
    public class AllOrNoneHeader_element {
        public Boolean allOrNone;
        private String[] allOrNone_type_info = new String[]{'allOrNone','http://soap.sforce.com/2006/04/metadata',null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://soap.sforce.com/2006/04/metadata','true','false'};
        private String[] field_order_type_info = new String[]{'allOrNone'};
    }
    
   
    public class listMetadata_element {
        public MetadataService.ListMetadataQuery[] queries;
        public Double asOfVersion;
        private String[] queries_type_info = new String[]{'queries','http://soap.sforce.com/2006/04/metadata',null,'0','-1','false'};
        private String[] asOfVersion_type_info = new String[]{'asOfVersion','http://soap.sforce.com/2006/04/metadata',null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://soap.sforce.com/2006/04/metadata','true','false'};
        private String[] field_order_type_info = new String[]{'queries','asOfVersion'};
    }
    
    
    
    public class Layout extends Metadata {
        public String type = 'Layout';
        public String fullName;
        private String[] fullName_type_info = new String[]{'fullName','http://soap.sforce.com/2006/04/metadata',null,'0','1','false'};
        public String[] customButtons;
        public MetadataService.CustomConsoleComponents customConsoleComponents;
        public Boolean emailDefault;
        public String[] excludeButtons;
        public MetadataService.FeedLayout feedLayout;
        public String[] headers;
        public MetadataService.LayoutSection[] layoutSections;
        public MetadataService.MiniLayout miniLayout;
        public String[] multilineLayoutFields;
        public MetadataService.PlatformActionList platformActionList;
        public MetadataService.QuickActionList quickActionList;
        public MetadataService.RelatedContent relatedContent;
        public MetadataService.RelatedListItem[] relatedLists;
        public String[] relatedObjects;
        public Boolean runAssignmentRulesDefault;
        public Boolean showEmailCheckbox;
        public Boolean showHighlightsPanel;
        public Boolean showInteractionLogPanel;
        public Boolean showKnowledgeComponent;
        public Boolean showRunAssignmentRulesCheckbox;
        public Boolean showSolutionSection;
        public Boolean showSubmitAndAttachButton;
        public MetadataService.SummaryLayout summaryLayout;
        private String[] customButtons_type_info = new String[]{'customButtons','http://soap.sforce.com/2006/04/metadata',null,'0','-1','false'};
        private String[] customConsoleComponents_type_info = new String[]{'customConsoleComponents','http://soap.sforce.com/2006/04/metadata',null,'0','1','false'};
        private String[] emailDefault_type_info = new String[]{'emailDefault','http://soap.sforce.com/2006/04/metadata',null,'0','1','false'};
        private String[] excludeButtons_type_info = new String[]{'excludeButtons','http://soap.sforce.com/2006/04/metadata',null,'0','-1','false'};
        private String[] feedLayout_type_info = new String[]{'feedLayout','http://soap.sforce.com/2006/04/metadata',null,'0','1','false'};
        private String[] headers_type_info = new String[]{'headers','http://soap.sforce.com/2006/04/metadata',null,'0','-1','false'};
        private String[] layoutSections_type_info = new String[]{'layoutSections','http://soap.sforce.com/2006/04/metadata',null,'0','-1','false'};
        private String[] miniLayout_type_info = new String[]{'miniLayout','http://soap.sforce.com/2006/04/metadata',null,'0','1','false'};
        private String[] multilineLayoutFields_type_info = new String[]{'multilineLayoutFields','http://soap.sforce.com/2006/04/metadata',null,'0','-1','false'};
        private String[] platformActionList_type_info = new String[]{'platformActionList','http://soap.sforce.com/2006/04/metadata',null,'0','1','false'};
        private String[] quickActionList_type_info = new String[]{'quickActionList','http://soap.sforce.com/2006/04/metadata',null,'0','1','false'};
        private String[] relatedContent_type_info = new String[]{'relatedContent','http://soap.sforce.com/2006/04/metadata',null,'0','1','false'};
        private String[] relatedLists_type_info = new String[]{'relatedLists','http://soap.sforce.com/2006/04/metadata',null,'0','-1','false'};
        private String[] relatedObjects_type_info = new String[]{'relatedObjects','http://soap.sforce.com/2006/04/metadata',null,'0','-1','false'};
        private String[] runAssignmentRulesDefault_type_info = new String[]{'runAssignmentRulesDefault','http://soap.sforce.com/2006/04/metadata',null,'0','1','false'};
        private String[] showEmailCheckbox_type_info = new String[]{'showEmailCheckbox','http://soap.sforce.com/2006/04/metadata',null,'0','1','false'};
        private String[] showHighlightsPanel_type_info = new String[]{'showHighlightsPanel','http://soap.sforce.com/2006/04/metadata',null,'0','1','false'};
        private String[] showInteractionLogPanel_type_info = new String[]{'showInteractionLogPanel','http://soap.sforce.com/2006/04/metadata',null,'0','1','false'};
        private String[] showKnowledgeComponent_type_info = new String[]{'showKnowledgeComponent','http://soap.sforce.com/2006/04/metadata',null,'0','1','false'};
        private String[] showRunAssignmentRulesCheckbox_type_info = new String[]{'showRunAssignmentRulesCheckbox','http://soap.sforce.com/2006/04/metadata',null,'0','1','false'};
        private String[] showSolutionSection_type_info = new String[]{'showSolutionSection','http://soap.sforce.com/2006/04/metadata',null,'0','1','false'};
        private String[] showSubmitAndAttachButton_type_info = new String[]{'showSubmitAndAttachButton','http://soap.sforce.com/2006/04/metadata',null,'0','1','false'};
        private String[] summaryLayout_type_info = new String[]{'summaryLayout','http://soap.sforce.com/2006/04/metadata',null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://soap.sforce.com/2006/04/metadata','true','false'};
        private String[] type_att_info = new String[]{'xsi:type'};
        private String[] field_order_type_info = new String[]{'fullName', 'customButtons','customConsoleComponents','emailDefault','excludeButtons','feedLayout','headers','layoutSections','miniLayout','multilineLayoutFields','platformActionList','quickActionList','relatedContent','relatedLists','relatedObjects','runAssignmentRulesDefault','showEmailCheckbox','showHighlightsPanel','showInteractionLogPanel','showKnowledgeComponent','showRunAssignmentRulesCheckbox','showSolutionSection','showSubmitAndAttachButton','summaryLayout'};
    }
    
 
    
    public class FeedLayoutFilter {
        public String feedFilterName;
        public String feedFilterType;
        public String feedItemType;
        private String[] feedFilterName_type_info = new String[]{'feedFilterName','http://soap.sforce.com/2006/04/metadata',null,'0','1','false'};
        private String[] feedFilterType_type_info = new String[]{'feedFilterType','http://soap.sforce.com/2006/04/metadata',null,'1','1','false'};
        private String[] feedItemType_type_info = new String[]{'feedItemType','http://soap.sforce.com/2006/04/metadata',null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://soap.sforce.com/2006/04/metadata','true','false'};
        private String[] field_order_type_info = new String[]{'feedFilterName','feedFilterType','feedItemType'};
    }
    
    
    public class CustomMetadata extends Metadata {
        public String type = 'CustomMetadata';
        public String fullName;
        private String[] fullName_type_info = new String[]{'fullName','http://soap.sforce.com/2006/04/metadata',null,'0','1','false'};
        public String description;
        public String label;
        public Boolean protected_x;
        public MetadataService.CustomMetadataValue[] values;
        private String[] description_type_info = new String[]{'description','http://soap.sforce.com/2006/04/metadata',null,'0','1','false'};
        private String[] label_type_info = new String[]{'label','http://soap.sforce.com/2006/04/metadata',null,'0','1','false'};
        private String[] protected_x_type_info = new String[]{'protected','http://soap.sforce.com/2006/04/metadata',null,'0','1','false'};
        private String[] values_type_info = new String[]{'values','http://soap.sforce.com/2006/04/metadata',null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{'http://soap.sforce.com/2006/04/metadata','true','false'};
        private String[] type_att_info = new String[]{'xsi:type'};
        private String[] field_order_type_info = new String[]{'fullName', 'description','label','protected_x','values'};
    }
    
   
    
    public class FileProperties {
        public String createdById;
        public String createdByName;
        public DateTime createdDate;
        public String fileName;
        public String fullName;
        public String id;
        public String lastModifiedById;
        public String lastModifiedByName;
        public DateTime lastModifiedDate;
        public String manageableState;
        public String namespacePrefix;
        public String type_x;
        private String[] createdById_type_info = new String[]{'createdById','http://soap.sforce.com/2006/04/metadata',null,'1','1','false'};
        private String[] createdByName_type_info = new String[]{'createdByName','http://soap.sforce.com/2006/04/metadata',null,'1','1','false'};
        private String[] createdDate_type_info = new String[]{'createdDate','http://soap.sforce.com/2006/04/metadata',null,'1','1','false'};
        private String[] fileName_type_info = new String[]{'fileName','http://soap.sforce.com/2006/04/metadata',null,'1','1','false'};
        private String[] fullName_type_info = new String[]{'fullName','http://soap.sforce.com/2006/04/metadata',null,'1','1','false'};
        private String[] id_type_info = new String[]{'id','http://soap.sforce.com/2006/04/metadata',null,'1','1','false'};
        private String[] lastModifiedById_type_info = new String[]{'lastModifiedById','http://soap.sforce.com/2006/04/metadata',null,'1','1','false'};
        private String[] lastModifiedByName_type_info = new String[]{'lastModifiedByName','http://soap.sforce.com/2006/04/metadata',null,'1','1','false'};
        private String[] lastModifiedDate_type_info = new String[]{'lastModifiedDate','http://soap.sforce.com/2006/04/metadata',null,'1','1','false'};
        private String[] manageableState_type_info = new String[]{'manageableState','http://soap.sforce.com/2006/04/metadata',null,'0','1','false'};
        private String[] namespacePrefix_type_info = new String[]{'namespacePrefix','http://soap.sforce.com/2006/04/metadata',null,'0','1','false'};
        private String[] type_x_type_info = new String[]{'type','http://soap.sforce.com/2006/04/metadata',null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://soap.sforce.com/2006/04/metadata','true','false'};
        private String[] field_order_type_info = new String[]{'createdById','createdByName','createdDate','fileName','fullName','id','lastModifiedById','lastModifiedByName','lastModifiedDate','manageableState','namespacePrefix','type_x'};
    }
    
    
    
    public class CustomConsoleComponents {
        public MetadataService.PrimaryTabComponents primaryTabComponents;
        public MetadataService.SubtabComponents subtabComponents;
        private String[] primaryTabComponents_type_info = new String[]{'primaryTabComponents','http://soap.sforce.com/2006/04/metadata',null,'0','1','false'};
        private String[] subtabComponents_type_info = new String[]{'subtabComponents','http://soap.sforce.com/2006/04/metadata',null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://soap.sforce.com/2006/04/metadata','true','false'};
        private String[] field_order_type_info = new String[]{'primaryTabComponents','subtabComponents'};
    }
    
  
    
    public class DebuggingInfo_element {
        public String debugLog;
        private String[] debugLog_type_info = new String[]{'debugLog','http://soap.sforce.com/2006/04/metadata',null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://soap.sforce.com/2006/04/metadata','true','false'};
        private String[] field_order_type_info = new String[]{'debugLog'};
    }
    

    
    public class ReportChartComponentLayoutItem {
        public Boolean cacheData;
        public String contextFilterableField;
        public String error;
        public Boolean hideOnError;
        public Boolean includeContext;
        public String reportName;
        public Boolean showTitle;
        public String size;
        private String[] cacheData_type_info = new String[]{'cacheData','http://soap.sforce.com/2006/04/metadata',null,'0','1','false'};
        private String[] contextFilterableField_type_info = new String[]{'contextFilterableField','http://soap.sforce.com/2006/04/metadata',null,'0','1','false'};
        private String[] error_type_info = new String[]{'error','http://soap.sforce.com/2006/04/metadata',null,'0','1','false'};
        private String[] hideOnError_type_info = new String[]{'hideOnError','http://soap.sforce.com/2006/04/metadata',null,'0','1','false'};
        private String[] includeContext_type_info = new String[]{'includeContext','http://soap.sforce.com/2006/04/metadata',null,'0','1','false'};
        private String[] reportName_type_info = new String[]{'reportName','http://soap.sforce.com/2006/04/metadata',null,'1','1','false'};
        private String[] showTitle_type_info = new String[]{'showTitle','http://soap.sforce.com/2006/04/metadata',null,'0','1','false'};
        private String[] size_type_info = new String[]{'size','http://soap.sforce.com/2006/04/metadata',null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://soap.sforce.com/2006/04/metadata','true','false'};
        private String[] field_order_type_info = new String[]{'cacheData','contextFilterableField','error','hideOnError','includeContext','reportName','showTitle','size'};
    }
    
    
    
    public class RelatedContentItem {
        public MetadataService.LayoutItem layoutItem;
        private String[] layoutItem_type_info = new String[]{'layoutItem','http://soap.sforce.com/2006/04/metadata',null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://soap.sforce.com/2006/04/metadata','true','false'};
        private String[] field_order_type_info = new String[]{'layoutItem'};
    }
    
    
    public class SummaryLayoutItem {
        public String customLink;
        public String field;
        public Integer posX;
        public Integer posY;
        public Integer posZ;
        private String[] customLink_type_info = new String[]{'customLink','http://soap.sforce.com/2006/04/metadata',null,'0','1','false'};
        private String[] field_type_info = new String[]{'field','http://soap.sforce.com/2006/04/metadata',null,'0','1','false'};
        private String[] posX_type_info = new String[]{'posX','http://soap.sforce.com/2006/04/metadata',null,'1','1','false'};
        private String[] posY_type_info = new String[]{'posY','http://soap.sforce.com/2006/04/metadata',null,'0','1','false'};
        private String[] posZ_type_info = new String[]{'posZ','http://soap.sforce.com/2006/04/metadata',null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://soap.sforce.com/2006/04/metadata','true','false'};
        private String[] field_order_type_info = new String[]{'customLink','field','posX','posY','posZ'};
    }
    
    
    public class PlatformActionList {
        public String actionListContext;
        public MetadataService.PlatformActionListItem[] platformActionListItems;
        public String relatedSourceEntity;
        private String[] actionListContext_type_info = new String[]{'actionListContext','http://soap.sforce.com/2006/04/metadata',null,'1','1','false'};
        private String[] platformActionListItems_type_info = new String[]{'platformActionListItems','http://soap.sforce.com/2006/04/metadata',null,'0','-1','false'};
        private String[] relatedSourceEntity_type_info = new String[]{'relatedSourceEntity','http://soap.sforce.com/2006/04/metadata',null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://soap.sforce.com/2006/04/metadata','true','false'};
        private String[] field_order_type_info = new String[]{'actionListContext','platformActionListItems','relatedSourceEntity'};
    }
    
    
    
    public class SessionHeader_element {
        public String sessionId;
        private String[] sessionId_type_info = new String[]{'sessionId','http://soap.sforce.com/2006/04/metadata',null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://soap.sforce.com/2006/04/metadata','true','false'};
        private String[] field_order_type_info = new String[]{'sessionId'};
    }
    
  
    
    public class RelatedContent {
        public MetadataService.RelatedContentItem[] relatedContentItems;
        private String[] relatedContentItems_type_info = new String[]{'relatedContentItems','http://soap.sforce.com/2006/04/metadata',null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{'http://soap.sforce.com/2006/04/metadata','true','false'};
        private String[] field_order_type_info = new String[]{'relatedContentItems'};
    }
    
   
    
    public class CustomMetadataValue {
        public String field;
        public String value;
        private String[] field_type_info = new String[]{'field','http://soap.sforce.com/2006/04/metadata',null,'1','1','false'};
        private String[] value_type_info = new String[]{'value','http://soap.sforce.com/2006/04/metadata',null,'1','1','true'};
        private String[] apex_schema_type_info = new String[]{'http://soap.sforce.com/2006/04/metadata','true','false'};
        private String[] field_order_type_info = new String[]{'field','value'};
    }
  
    
    public class SubtabComponents {
        public MetadataService.Container[] containers;
        private String[] containers_type_info = new String[]{'containers','http://soap.sforce.com/2006/04/metadata',null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{'http://soap.sforce.com/2006/04/metadata','true','false'};
        private String[] field_order_type_info = new String[]{'containers'};
    }
    

    
    public class LayoutColumn {
        public MetadataService.LayoutItem[] layoutItems;
        public String reserved;
        private String[] layoutItems_type_info = new String[]{'layoutItems','http://soap.sforce.com/2006/04/metadata',null,'0','-1','false'};
        private String[] reserved_type_info = new String[]{'reserved','http://soap.sforce.com/2006/04/metadata',null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://soap.sforce.com/2006/04/metadata','true','false'};
        private String[] field_order_type_info = new String[]{'layoutItems','reserved'};
    }
    
    
    public class Error {
        public String[] fields;
        public String message;
        public String statusCode;
        private String[] fields_type_info = new String[]{'fields','http://soap.sforce.com/2006/04/metadata',null,'0','-1','false'};
        private String[] message_type_info = new String[]{'message','http://soap.sforce.com/2006/04/metadata',null,'1','1','false'};
        private String[] statusCode_type_info = new String[]{'statusCode','http://soap.sforce.com/2006/04/metadata',null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://soap.sforce.com/2006/04/metadata','true','false'};
        private String[] field_order_type_info = new String[]{'fields','message','statusCode'};
    }
    
    
    public class updateMetadata_element {
        public MetadataService.Metadata[] metadata;
        private String[] metadata_type_info = new String[]{'metadata','http://soap.sforce.com/2006/04/metadata',null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{'http://soap.sforce.com/2006/04/metadata','true','false'};
        private String[] field_order_type_info = new String[]{'metadata'};
    }
    

    
    public class PlatformActionListItem {
        public String actionName;
        public String actionType;
        public Integer sortOrder;
        public String subtype;
        private String[] actionName_type_info = new String[]{'actionName','http://soap.sforce.com/2006/04/metadata',null,'1','1','false'};
        private String[] actionType_type_info = new String[]{'actionType','http://soap.sforce.com/2006/04/metadata',null,'1','1','false'};
        private String[] sortOrder_type_info = new String[]{'sortOrder','http://soap.sforce.com/2006/04/metadata',null,'1','1','false'};
        private String[] subtype_type_info = new String[]{'subtype','http://soap.sforce.com/2006/04/metadata',null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://soap.sforce.com/2006/04/metadata','true','false'};
        private String[] field_order_type_info = new String[]{'actionName','actionType','sortOrder','subtype'};
    }
    
    
    public class CallOptions_element {
        public String client;
        private String[] client_type_info = new String[]{'client','http://soap.sforce.com/2006/04/metadata',null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://soap.sforce.com/2006/04/metadata','true','false'};
        private String[] field_order_type_info = new String[]{'client'};
    }
    
  
    
    public virtual class Metadata {
        public String fullName;
    }
    

    public class DebuggingHeader_element {
        public MetadataService.LogInfo[] categories;
        public String debugLevel;
        private String[] categories_type_info = new String[]{'categories','http://soap.sforce.com/2006/04/metadata',null,'0','-1','false'};
        private String[] debugLevel_type_info = new String[]{'debugLevel','http://soap.sforce.com/2006/04/metadata',null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://soap.sforce.com/2006/04/metadata','true','false'};
        private String[] field_order_type_info = new String[]{'categories','debugLevel'};
    }
    
    
    
    public class LayoutItem {
        public MetadataService.AnalyticsCloudComponentLayoutItem analyticsCloudComponent;
        public String behavior;
        public String canvas;
        public String component;
        public String customLink;
        public Boolean emptySpace;
        public String field;
        public Integer height;
        public String page_x;
        public MetadataService.ReportChartComponentLayoutItem reportChartComponent;
        public String scontrol;
        public Boolean showLabel;
        public Boolean showScrollbars;
        public String width;
        private String[] analyticsCloudComponent_type_info = new String[]{'analyticsCloudComponent','http://soap.sforce.com/2006/04/metadata',null,'0','1','false'};
        private String[] behavior_type_info = new String[]{'behavior','http://soap.sforce.com/2006/04/metadata',null,'0','1','false'};
        private String[] canvas_type_info = new String[]{'canvas','http://soap.sforce.com/2006/04/metadata',null,'0','1','false'};
        private String[] component_type_info = new String[]{'component','http://soap.sforce.com/2006/04/metadata',null,'0','1','false'};
        private String[] customLink_type_info = new String[]{'customLink','http://soap.sforce.com/2006/04/metadata',null,'0','1','false'};
        private String[] emptySpace_type_info = new String[]{'emptySpace','http://soap.sforce.com/2006/04/metadata',null,'0','1','false'};
        private String[] field_type_info = new String[]{'field','http://soap.sforce.com/2006/04/metadata',null,'0','1','false'};
        private String[] height_type_info = new String[]{'height','http://soap.sforce.com/2006/04/metadata',null,'0','1','false'};
        private String[] page_x_type_info = new String[]{'page','http://soap.sforce.com/2006/04/metadata',null,'0','1','false'};
        private String[] reportChartComponent_type_info = new String[]{'reportChartComponent','http://soap.sforce.com/2006/04/metadata',null,'0','1','false'};
        private String[] scontrol_type_info = new String[]{'scontrol','http://soap.sforce.com/2006/04/metadata',null,'0','1','false'};
        private String[] showLabel_type_info = new String[]{'showLabel','http://soap.sforce.com/2006/04/metadata',null,'0','1','false'};
        private String[] showScrollbars_type_info = new String[]{'showScrollbars','http://soap.sforce.com/2006/04/metadata',null,'0','1','false'};
        private String[] width_type_info = new String[]{'width','http://soap.sforce.com/2006/04/metadata',null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://soap.sforce.com/2006/04/metadata','true','false'};
        private String[] field_order_type_info = new String[]{'analyticsCloudComponent','behavior','canvas','component','customLink','emptySpace','field','height','page_x','reportChartComponent','scontrol','showLabel','showScrollbars','width'};
    }
    
   
    
    public class ListMetadataQuery {
        public String folder;
        public String type_x;
        private String[] folder_type_info = new String[]{'folder','http://soap.sforce.com/2006/04/metadata',null,'0','1','false'};
        private String[] type_x_type_info = new String[]{'type','http://soap.sforce.com/2006/04/metadata',null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://soap.sforce.com/2006/04/metadata','true','false'};
        private String[] field_order_type_info = new String[]{'folder','type_x'};
    }
   
    
    public class LogInfo {
        public String category;
        public String level;
        private String[] category_type_info = new String[]{'category','http://soap.sforce.com/2006/04/metadata',null,'1','1','false'};
        private String[] level_type_info = new String[]{'level','http://soap.sforce.com/2006/04/metadata',null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://soap.sforce.com/2006/04/metadata','true','false'};
        private String[] field_order_type_info = new String[]{'category','level'};
    }
    
  
    
    public class Container {
        public Integer height;
        public Boolean isContainerAutoSizeEnabled;
        public String region;
        public MetadataService.SidebarComponent[] sidebarComponents;
        public String style;
        public String unit;
        public Integer width;
        private String[] height_type_info = new String[]{'height','http://soap.sforce.com/2006/04/metadata',null,'0','1','false'};
        private String[] isContainerAutoSizeEnabled_type_info = new String[]{'isContainerAutoSizeEnabled','http://soap.sforce.com/2006/04/metadata',null,'1','1','false'};
        private String[] region_type_info = new String[]{'region','http://soap.sforce.com/2006/04/metadata',null,'1','1','false'};
        private String[] sidebarComponents_type_info = new String[]{'sidebarComponents','http://soap.sforce.com/2006/04/metadata',null,'0','-1','false'};
        private String[] style_type_info = new String[]{'style','http://soap.sforce.com/2006/04/metadata',null,'1','1','false'};
        private String[] unit_type_info = new String[]{'unit','http://soap.sforce.com/2006/04/metadata',null,'1','1','false'};
        private String[] width_type_info = new String[]{'width','http://soap.sforce.com/2006/04/metadata',null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://soap.sforce.com/2006/04/metadata','true','false'};
        private String[] field_order_type_info = new String[]{'height','isContainerAutoSizeEnabled','region','sidebarComponents','style','unit','width'};
    }
    
    
    public class FeedLayout {
        public Boolean autocollapsePublisher;
        public Boolean compactFeed;
        public String feedFilterPosition;
        public MetadataService.FeedLayoutFilter[] feedFilters;
        public Boolean fullWidthFeed;
        public Boolean hideSidebar;
        public Boolean highlightExternalFeedItems;
        public MetadataService.FeedLayoutComponent[] leftComponents;
        public MetadataService.FeedLayoutComponent[] rightComponents;
        public Boolean useInlineFiltersInConsole;
        private String[] autocollapsePublisher_type_info = new String[]{'autocollapsePublisher','http://soap.sforce.com/2006/04/metadata',null,'0','1','false'};
        private String[] compactFeed_type_info = new String[]{'compactFeed','http://soap.sforce.com/2006/04/metadata',null,'0','1','false'};
        private String[] feedFilterPosition_type_info = new String[]{'feedFilterPosition','http://soap.sforce.com/2006/04/metadata',null,'0','1','false'};
        private String[] feedFilters_type_info = new String[]{'feedFilters','http://soap.sforce.com/2006/04/metadata',null,'0','-1','false'};
        private String[] fullWidthFeed_type_info = new String[]{'fullWidthFeed','http://soap.sforce.com/2006/04/metadata',null,'0','1','false'};
        private String[] hideSidebar_type_info = new String[]{'hideSidebar','http://soap.sforce.com/2006/04/metadata',null,'0','1','false'};
        private String[] highlightExternalFeedItems_type_info = new String[]{'highlightExternalFeedItems','http://soap.sforce.com/2006/04/metadata',null,'0','1','false'};
        private String[] leftComponents_type_info = new String[]{'leftComponents','http://soap.sforce.com/2006/04/metadata',null,'0','-1','false'};
        private String[] rightComponents_type_info = new String[]{'rightComponents','http://soap.sforce.com/2006/04/metadata',null,'0','-1','false'};
        private String[] useInlineFiltersInConsole_type_info = new String[]{'useInlineFiltersInConsole','http://soap.sforce.com/2006/04/metadata',null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://soap.sforce.com/2006/04/metadata','true','false'};
        private String[] field_order_type_info = new String[]{'autocollapsePublisher','compactFeed','feedFilterPosition','feedFilters','fullWidthFeed','hideSidebar','highlightExternalFeedItems','leftComponents','rightComponents','useInlineFiltersInConsole'};
    }
    
  
    
    public class readMetadata_element {
        public String type_x;
        public String[] fullNames;
        private String[] type_x_type_info = new String[]{'type','http://soap.sforce.com/2006/04/metadata',null,'1','1','false'};
        private String[] fullNames_type_info = new String[]{'fullNames','http://soap.sforce.com/2006/04/metadata',null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{'http://soap.sforce.com/2006/04/metadata','true','false'};
        private String[] field_order_type_info = new String[]{'type_x','fullNames'};
    }
    
    
    public class QuickActionList {
        public MetadataService.QuickActionListItem[] quickActionListItems;
        private String[] quickActionListItems_type_info = new String[]{'quickActionListItems','http://soap.sforce.com/2006/04/metadata',null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{'http://soap.sforce.com/2006/04/metadata','true','false'};
        private String[] field_order_type_info = new String[]{'quickActionListItems'};
    }
    
    
    
    public class PrimaryTabComponents {
        public MetadataService.Container[] containers;
        private String[] containers_type_info = new String[]{'containers','http://soap.sforce.com/2006/04/metadata',null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{'http://soap.sforce.com/2006/04/metadata','true','false'};
        private String[] field_order_type_info = new String[]{'containers'};
    }
    
    
    public class updateMetadataResponse_element {
        public MetadataService.SaveResult[] result;
        private String[] result_type_info = new String[]{'result','http://soap.sforce.com/2006/04/metadata',null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{'http://soap.sforce.com/2006/04/metadata','true','false'};
        private String[] field_order_type_info = new String[]{'result'};
    }
    
    
    public class FolderShare {
        public String accessLevel;
        public String sharedTo;
        public String sharedToType;
        private String[] accessLevel_type_info = new String[]{'accessLevel','http://soap.sforce.com/2006/04/metadata',null,'1','1','false'};
        private String[] sharedTo_type_info = new String[]{'sharedTo','http://soap.sforce.com/2006/04/metadata',null,'1','1','false'};
        private String[] sharedToType_type_info = new String[]{'sharedToType','http://soap.sforce.com/2006/04/metadata',null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://soap.sforce.com/2006/04/metadata','true','false'};
        private String[] field_order_type_info = new String[]{'accessLevel','sharedTo','sharedToType'};
    }
    
    
    public class QuickActionListItem {
        public String quickActionName;
        private String[] quickActionName_type_info = new String[]{'quickActionName','http://soap.sforce.com/2006/04/metadata',null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://soap.sforce.com/2006/04/metadata','true','false'};
        private String[] field_order_type_info = new String[]{'quickActionName'};
    }
    
 
    
    public class RelatedList {
        public Boolean hideOnDetail;
        public String name;
        private String[] hideOnDetail_type_info = new String[]{'hideOnDetail','http://soap.sforce.com/2006/04/metadata',null,'1','1','false'};
        private String[] name_type_info = new String[]{'name','http://soap.sforce.com/2006/04/metadata',null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://soap.sforce.com/2006/04/metadata','true','false'};
        private String[] field_order_type_info = new String[]{'hideOnDetail','name'};
    }
    
    
    public class AnalyticsCloudComponentLayoutItem {
        public String assetType;
        public String devName;
        public String error;
        public String filter;
        public Integer height;
        public Boolean hideOnError;
        public Boolean showTitle;
        public String width;
        private String[] assetType_type_info = new String[]{'assetType','http://soap.sforce.com/2006/04/metadata',null,'1','1','false'};
        private String[] devName_type_info = new String[]{'devName','http://soap.sforce.com/2006/04/metadata',null,'1','1','false'};
        private String[] error_type_info = new String[]{'error','http://soap.sforce.com/2006/04/metadata',null,'0','1','false'};
        private String[] filter_type_info = new String[]{'filter','http://soap.sforce.com/2006/04/metadata',null,'0','1','false'};
        private String[] height_type_info = new String[]{'height','http://soap.sforce.com/2006/04/metadata',null,'0','1','false'};
        private String[] hideOnError_type_info = new String[]{'hideOnError','http://soap.sforce.com/2006/04/metadata',null,'0','1','false'};
        private String[] showTitle_type_info = new String[]{'showTitle','http://soap.sforce.com/2006/04/metadata',null,'0','1','false'};
        private String[] width_type_info = new String[]{'width','http://soap.sforce.com/2006/04/metadata',null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://soap.sforce.com/2006/04/metadata','true','false'};
        private String[] field_order_type_info = new String[]{'assetType','devName','error','filter','height','hideOnError','showTitle','width'};
    }
    
    
    public interface IReadResult {
        MetadataService.Metadata[] getRecords();
    }

    
    public interface IReadResponseElement {
        IReadResult getResult();
    }
    
    
    
    public class ReadLayoutResult implements IReadResult {
        public MetadataService.Layout[] records;
        public MetadataService.Metadata[] getRecords() { return records; }
        private String[] records_type_info = new String[]{'records','http://soap.sforce.com/2006/04/metadata',null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{'http://soap.sforce.com/2006/04/metadata','true','false'};
        private String[] field_order_type_info = new String[]{'records'};
    }
    
    
    public class readLayoutResponse_element implements IReadResponseElement {
        public MetadataService.ReadLayoutResult result;
        public IReadResult getResult() { return result; }
        private String[] result_type_info = new String[]{'result','http://soap.sforce.com/2006/04/metadata',null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://soap.sforce.com/2006/04/metadata','true','false'};
        private String[] field_order_type_info = new String[]{'result'};
    }
    
    
    public class LayoutSection {
        public Boolean customLabel;
        public Boolean detailHeading;
        public Boolean editHeading;
        public String label;
        public MetadataService.LayoutColumn[] layoutColumns;
        public String style;
        private String[] customLabel_type_info = new String[]{'customLabel','http://soap.sforce.com/2006/04/metadata',null,'0','1','false'};
        private String[] detailHeading_type_info = new String[]{'detailHeading','http://soap.sforce.com/2006/04/metadata',null,'0','1','false'};
        private String[] editHeading_type_info = new String[]{'editHeading','http://soap.sforce.com/2006/04/metadata',null,'0','1','false'};
        private String[] label_type_info = new String[]{'label','http://soap.sforce.com/2006/04/metadata',null,'0','1','false'};
        private String[] layoutColumns_type_info = new String[]{'layoutColumns','http://soap.sforce.com/2006/04/metadata',null,'0','-1','false'};
        private String[] style_type_info = new String[]{'style','http://soap.sforce.com/2006/04/metadata',null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://soap.sforce.com/2006/04/metadata','true','false'};
        private String[] field_order_type_info = new String[]{'customLabel','detailHeading','editHeading','label','layoutColumns','style'};
    }
    
    
    public class FeedLayoutComponent {
        public String componentType;
        public Integer height;
        public String page_x;
        private String[] componentType_type_info = new String[]{'componentType','http://soap.sforce.com/2006/04/metadata',null,'1','1','false'};
        private String[] height_type_info = new String[]{'height','http://soap.sforce.com/2006/04/metadata',null,'0','1','false'};
        private String[] page_x_type_info = new String[]{'page','http://soap.sforce.com/2006/04/metadata',null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://soap.sforce.com/2006/04/metadata','true','false'};
        private String[] field_order_type_info = new String[]{'componentType','height','page_x'};
    }
    
    
    
    public class createMetadata_element {
        public MetadataService.Metadata[] metadata;
        private String[] metadata_type_info = new String[]{'metadata','http://soap.sforce.com/2006/04/metadata',null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{'http://soap.sforce.com/2006/04/metadata','true','false'};
        private String[] field_order_type_info = new String[]{'metadata'};
    }
    
   
    
    public class SummaryLayout {
        public String masterLabel;
        public Integer sizeX;
        public Integer sizeY;
        public Integer sizeZ;
        public MetadataService.SummaryLayoutItem[] summaryLayoutItems;
        public String summaryLayoutStyle;
        private String[] masterLabel_type_info = new String[]{'masterLabel','http://soap.sforce.com/2006/04/metadata',null,'1','1','false'};
        private String[] sizeX_type_info = new String[]{'sizeX','http://soap.sforce.com/2006/04/metadata',null,'1','1','false'};
        private String[] sizeY_type_info = new String[]{'sizeY','http://soap.sforce.com/2006/04/metadata',null,'0','1','false'};
        private String[] sizeZ_type_info = new String[]{'sizeZ','http://soap.sforce.com/2006/04/metadata',null,'0','1','false'};
        private String[] summaryLayoutItems_type_info = new String[]{'summaryLayoutItems','http://soap.sforce.com/2006/04/metadata',null,'0','-1','false'};
        private String[] summaryLayoutStyle_type_info = new String[]{'summaryLayoutStyle','http://soap.sforce.com/2006/04/metadata',null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://soap.sforce.com/2006/04/metadata','true','false'};
        private String[] field_order_type_info = new String[]{'masterLabel','sizeX','sizeY','sizeZ','summaryLayoutItems','summaryLayoutStyle'};
    }
    
    
    public class listMetadataResponse_element {
        public MetadataService.FileProperties[] result;
        private String[] result_type_info = new String[]{'result','http://soap.sforce.com/2006/04/metadata',null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{'http://soap.sforce.com/2006/04/metadata','true','false'};
        private String[] field_order_type_info = new String[]{'result'};
    }
 
    
    public class SidebarComponent {
        public String componentType;
        public Integer height;
        public String label;
        public String lookup;
        public String page_x;
        public MetadataService.RelatedList[] relatedLists;
        public String unit;
        public Integer width;
        private String[] componentType_type_info = new String[]{'componentType','http://soap.sforce.com/2006/04/metadata',null,'1','1','false'};
        private String[] height_type_info = new String[]{'height','http://soap.sforce.com/2006/04/metadata',null,'0','1','false'};
        private String[] label_type_info = new String[]{'label','http://soap.sforce.com/2006/04/metadata',null,'0','1','false'};
        private String[] lookup_type_info = new String[]{'lookup','http://soap.sforce.com/2006/04/metadata',null,'0','1','false'};
        private String[] page_x_type_info = new String[]{'page','http://soap.sforce.com/2006/04/metadata',null,'0','1','false'};
        private String[] relatedLists_type_info = new String[]{'relatedLists','http://soap.sforce.com/2006/04/metadata',null,'0','-1','false'};
        private String[] unit_type_info = new String[]{'unit','http://soap.sforce.com/2006/04/metadata',null,'0','1','false'};
        private String[] width_type_info = new String[]{'width','http://soap.sforce.com/2006/04/metadata',null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://soap.sforce.com/2006/04/metadata','true','false'};
        private String[] field_order_type_info = new String[]{'componentType','height','label','lookup','page_x','relatedLists','unit','width'};
    }
    
    
    public class MetadataPort {
        public String endpoint_x = URL.getSalesforceBaseUrl().toExternalForm() + '/services/Soap/m/36.0';
        public Map<String,String> inputHttpHeaders_x;
        public Map<String,String> outputHttpHeaders_x;
        public String clientCertName_x;
        public String clientCert_x;
        public String clientCertPasswd_x;
        public Integer timeout_x;
        public MetadataService.SessionHeader_element SessionHeader;
        public MetadataService.DebuggingInfo_element DebuggingInfo;
        public MetadataService.DebuggingHeader_element DebuggingHeader;
        public MetadataService.CallOptions_element CallOptions;
        public MetadataService.AllOrNoneHeader_element AllOrNoneHeader;
        private String SessionHeader_hns = 'SessionHeader=http://soap.sforce.com/2006/04/metadata';
        private String DebuggingInfo_hns = 'DebuggingInfo=http://soap.sforce.com/2006/04/metadata';
        private String DebuggingHeader_hns = 'DebuggingHeader=http://soap.sforce.com/2006/04/metadata';
        private String CallOptions_hns = 'CallOptions=http://soap.sforce.com/2006/04/metadata';
        private String AllOrNoneHeader_hns = 'AllOrNoneHeader=http://soap.sforce.com/2006/04/metadata';
        private String[] ns_map_type_info = new String[]{'http://soap.sforce.com/2006/04/metadata', 'MetadataService'};
        
   
        
        public MetadataService.SaveResult[] updateMetadata(MetadataService.Metadata[] metadata) {
            MetadataService.updateMetadata_element request_x = new MetadataService.updateMetadata_element();
            request_x.metadata = metadata;
            MetadataService.updateMetadataResponse_element response_x;
            Map<String, MetadataService.updateMetadataResponse_element> response_map_x = new Map<String, MetadataService.updateMetadataResponse_element>();
            response_map_x.put('response_x', response_x);
            WebServiceCallout.invoke(
              this,
              request_x,
              response_map_x,
              new String[]{endpoint_x,
              '',
              'http://soap.sforce.com/2006/04/metadata',
              'updateMetadata',
              'http://soap.sforce.com/2006/04/metadata',
              'updateMetadataResponse',
              'MetadataService.updateMetadataResponse_element'}
            );
            response_x = response_map_x.get('response_x');
            return response_x.result;
        }
        
       
        
        public MetadataService.IReadResult readMetadata(String type_x,String[] fullNames) {
            MetadataService.readMetadata_element request_x = new MetadataService.readMetadata_element();
            request_x.type_x = type_x;
            request_x.fullNames = fullNames;
            MetadataService.IReadResponseElement response_x;
            Map<String, MetadataService.IReadResponseElement> response_map_x = new Map<String, MetadataService.IReadResponseElement>();
            response_map_x.put('response_x', response_x);
            WebServiceCallout.invoke(
              this,
              request_x,
              response_map_x,
              new String[]{endpoint_x,
              '',
              'http://soap.sforce.com/2006/04/metadata',
              'readMetadata',
              'http://soap.sforce.com/2006/04/metadata',
              'readMetadataResponse',
              'MetadataService.read' + type_x + 'Response_element'}
            );
            response_x = response_map_x.get('response_x');
            return response_x.getResult();
        }
        
       
         
        public MetadataService.FileProperties[] listMetadata(MetadataService.ListMetadataQuery[] queries,Double asOfVersion) {
            MetadataService.listMetadata_element request_x = new MetadataService.listMetadata_element();
            request_x.queries = queries;
            request_x.asOfVersion = asOfVersion;
            MetadataService.listMetadataResponse_element response_x;
            Map<String, MetadataService.listMetadataResponse_element> response_map_x = new Map<String, MetadataService.listMetadataResponse_element>();
            response_map_x.put('response_x', response_x);
            WebServiceCallout.invoke(
              this,
              request_x,
              response_map_x,
              new String[]{endpoint_x,
              '',
              'http://soap.sforce.com/2006/04/metadata',
              'listMetadata',
              'http://soap.sforce.com/2006/04/metadata',
              'listMetadataResponse',
              'MetadataService.listMetadataResponse_element'}
            );
            response_x = response_map_x.get('response_x');
            return response_x.result;
        }
       
    }    
}