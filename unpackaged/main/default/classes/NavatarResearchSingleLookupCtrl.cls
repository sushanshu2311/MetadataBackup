/****************************************************************************************************

** Module Name :Advance Search

** Description : Used for customlookup component.

** Throws : NA

** Calls : NA

** Organization : Navatar Group

** Product Name & Version : Acuity 2,Advance search phase 2

** Revision History:-

** Version    Date(YYYY-MM-DD)    Author         Description of Action

** 1.0        2022-11-26          Ehatsham

****************************************************************************************************/

public with sharing class NavatarResearchSingleLookupCtrl {

    /****************************************************************************************************
    Purpose : get related data on search

    Input : searchString - inputed string from lwc
            searchObjects - all the setup objects from navatar setup objec used for activity association

    Returns : serialized string of matched reocrds
    ****************************************************************************************************/
    @AuraEnabled(cacheable=true)
    public static List<sObject> getRelatedData(String searchTerm, string myObject) {
        String myQuery = null;
            boolean isObjAccess;
            isObjAccess = Schema.getGlobalDescribe().get(myObject).getDescribe().isAccessible();
            system.debug(isObjAccess + '--'+searchTerm);
            if(searchTerm != null && searchTerm != '' && isObjAccess){
                string sWildCardText = '%' + searchTerm + '%';
                 myQuery = 'Select Id,Name From ' + myObject + ' Where Name Like : sWildCardText order by createdDate DESC LIMIT 5';
               system.debug(myQuery);
                return database.query(String.escapeSingleQuotes(myQuery));
            }
            else {
                return new List<sObject>();
            }
        
    }


    /****************************************************************************************************
    Purpose : get icon aname of object

    Input : sObjectName - object name

    Returns : name of icon 
    ****************************************************************************************************/
    @AuraEnabled(cacheable=true)
    public static String getIconName(String sObjectName){
        system.debug('sObjectName::-------->>>> '+sObjectName);
        if(sObjectName == 'User'){
            return 'standard:user'; 
        }else {
            String u;
            List<Schema.DescribeTabSetResult> tabSetDesc=new List<Schema.DescribeTabSetResult>();
            tabSetDesc= Schema.describeTabs();
            List<Schema.DescribeTabResult> tabDesc = new List<Schema.DescribeTabResult>();
            List<Schema.DescribeIconResult> iconDesc = new List<Schema.DescribeIconResult>();
            //--------------------------------------------------------------------------------------
            String layoutResponse;

            string endpointurl;
            endpointurl='/services/data/v41.0/tabs';
             
            if(!test.isRunningTest()){layoutResponse = NavatarResearchCommonUtility.getDescribeResponse(endpointurl);
            list<FromJSON> layout = (list<FromJSON>)System.JSON.deserialize(layoutResponse ,  list<FromJSON>.class);
            if(sObjectName == 'theme__c' || sObjectName == 'Theme__c'){sObjectName='Themes';}
            string objectName='';
            for(FromJSON tab:layout) {
                /*added profile label check for user by shashank in AA3.0 */
                if((sObjectName == tab.sobjectName || sObjectName == tab.Name ) && tab.label!='Profile'){
                system.debug('objName--->'+sObjectName+'-->'+tab.sobjectName);
                system.debug('tab.sobjectName--->'+tab.sobjectName);
                for(cls_icons icn : tab.icons){
                if(icn.height == 0 && icn.theme== 'theme4' ){
                String objType = icn.url.split('/')[6];String tempName = icn.url.split('/')[7]; objectName = tempName.split('\\.')[0]; 
                u=objType+':'+objectName;
                system.debug('objectName--->'+objectName);
                system.debug('objType--->'+objType);
                }
                }
                }
                
                }

            }else{
                u='Standard:Account';
                string actualData=u+'record1';
                FromJSON tab=new FromJSON();
                Cls_colors colorItem=new Cls_colors();
                colorItem.color='red';    //2ECBBE
                colorItem.context='grey';  //primary
                colorItem.theme='inner';    //theme4
                Cls_colors[] Cls_colorsList = new Cls_colors[10];
                Cls_colorsList.add(colorItem);
                Cls_icons iconItem=new Cls_icons();
                Cls_icons[] iconList = new Cls_icons[10];
                iconItem.contentType='xyz';  //image/png
                iconItem.height=32;  //32
                iconItem.theme='tv screen';    //theme3
                iconItem.url='www.google.com';  //https://activityassociation-dev-ed.my.salesforce.com/img/icon/reports32.png
                iconItem.width=32;   //32
                iconList.add(iconItem);
                tab.colors=Cls_colorsList;
                tab.custom=true;
                tab.icons=iconList;
                tab.label='firm';    //DemoObjects
                tab.Name='accountTab';  
                tab.sobjectName='account';  //DemoObject__c
            }
            //--------------------------------------------------------------------------------------

          /*  for(Schema.DescribeTabSetResult tsr : tabSetDesc) { tabDesc.addAll(tsr.getTabs()); }
            
            for(Schema.DescribeTabResult tr : tabDesc) {
                system.debug(tr.getSobjectName());
                if( sObjectName == tr.getSobjectName() ) {
                    system.debug('@@@@@@@@@@@@@@@@@$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$@@@@@@@@@@@$$$$$$$$$$$$$$$$$$$$$$$$$$');
                    if( tr.isCustom() == true ) {
                        iconDesc.addAll(tr.getIcons());
                    } else {
                        u = 'standard:' + sObjectName.toLowerCase();
                    }
                }
            }
            system.debug(iconDesc);
            for (Schema.DescribeIconResult ir : iconDesc) {
                if (ir.getContentType() == 'image/svg+xml'){
                    u = 'custom:' + ir.getUrl().substringBetween('custom/','.svg').substringBefore('_');
                    break;
                }
            }*/
            system.debug('iconName:: '+u);
            return u;
        }
        
    }

    /****************************************************************************************************
    Purpose : get name of recordId

    Input : recId - recordid
            sObjectName - object name

    Returns : name of icon
    ****************************************************************************************************/
    @AuraEnabled
    public static string getPreSelectedRecordName(String recId, String sObjectName){
        try {
            System.debug('recId=='+recId);
            System.debug('sObjectName=='+sObjectName);
            List<SObject> objList = new List<sobject>();
            objList=database.query(String.escapeSingleQuotes('SELECT Name FROM ' +sObjectName+ ' WHERE id=:recId')); //31827 added by keyur for security review
            return (String)objList[0].get('Name');
            
            
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    
    
    // to store api response
    public class FromJSON{
        @AuraEnabled public cls_colors[] colors;
        @AuraEnabled public boolean custom;
        @AuraEnabled public cls_icons[] icons;
        @AuraEnabled public String label;    //DemoObjects
        @AuraEnabled public String Name;  
        @AuraEnabled public String sobjectName;  //DemoObject__c
        }
    public class Cls_colors {
            @AuraEnabled public String color;    //2ECBBE
            @AuraEnabled public String context;  //primary
            @AuraEnabled public String theme;    //theme4
            }
    public  class Cls_icons {
                @AuraEnabled public String contentType;  //image/png
                @AuraEnabled public Integer height;  //32
                @AuraEnabled public String theme;    //theme3
                @AuraEnabled public String url;  //https://activityassociation-dev-ed.my.salesforce.com/img/icon/reports32.png
                @AuraEnabled public Integer width;   //32
                }
}