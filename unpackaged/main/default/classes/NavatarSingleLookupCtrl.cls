/****************************************************************************************************

** Module Name : Activity Associations

** Description : Used for customlookup component.

** Throws : NA

** Calls : NA

** Organization : Navatar Group

** Product Name & Version : Activity Associations

** Revision History:-

** Version    Date(YYYY-MM-DD)    Author         Description of Action

** 1.0        2022-08-02          Keyur

****************************************************************************************************/

public with sharing class NavatarSingleLookupCtrl {

    /****************************************************************************************************
    Purpose : get related data on search

    Input : searchString - inputed string from lwc
            searchObjects - all the setup objects from navatar setup objec used for activity association

    Returns : serialized string of matched reocrds
    ****************************************************************************************************/
    @AuraEnabled(cacheable=true)
    public static List<sObject> getRelatedData(String searchTerm, string myObject) {
        String myQuery = null;
        String objectName = ([SELECT NamespacePrefix FROM ApexClass WHERE Name = 'FileUploaderCtrl'].NamespacePrefix)+'__Fund__c'; // Nikita Change
        boolean isObjAccess = Schema.getGlobalDescribe().get(myObject).getDescribe().isAccessible();
        if(searchTerm != null && searchTerm != '' && isObjAccess){
            // myQuery = 'Select Id, Name from '+myObject+' Where LastViewedDate != NULL ORDER BY LastViewedDate DESC LIMIT  5';
            List<sObject> sObjectList=new List<sObject>();
            try{
                myQuery = 'Select Id, Name,RecordType.Name from '+String.escapeSingleQuotes(myObject)+' Where Name Like  \'%' + String.escapeSingleQuotes(searchTerm) + '%\' LIMIT  5';
            	sObjectList=database.query(myQuery);
            }
            catch(Exception e){
                myQuery = 'Select Id, Name from '+String.escapeSingleQuotes(myObject)+' Where Name Like  \'%' + String.escapeSingleQuotes(searchTerm) + '%\' LIMIT  5';
                sObjectList=database.query(myQuery);
            }
            return sObjectList;
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
        system.debug('sObjectName:: '+sObjectName);
        if(sObjectName == 'User'){
            return 'standard:user';
        } else if(sObjectName == 'navpeII_dev18__Theme__c'){
           /* Added by Hema - To return the theme icon - 00035142*/
           return 'custom:custom100';
        }else {
            String iconname = '';
            String layoutResponse;
            string endpointurl ='/services/data/v41.0/tabs';
            layoutResponse = AcuityPECommonUtility.getDescribeResponse(endpointurl);
            list<FromJSON> layout = (list<FromJSON>)System.JSON.deserialize(layoutResponse ,  list<FromJSON>.class);
            string objectName='';  

            for(FromJSON tab:layout) {
                /*added profile label check for user by shashank in AA3.0 */
                if(sObjectName == tab.sobjectName && tab.label!='Profile'){
                    for(cls_icons icn : tab.icons){
                        if(icn.height == 0 && icn.theme== 'theme4' ){
                            String objType = icn.url.split('/')[6]; //standard
                            String tempName = icn.url.split('/')[7]; // account.svg
                            objectName = tempName.split('\\.')[0]; //account
                            iconname = objType+':'+objectName;
                            break;
                        }
                    }
                }
            }
            return iconname;
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
            List<SObject> objList = database.query(String.escapeSingleQuotes('SELECT Name FROM ' +sObjectName+ ' WHERE id=:recId')); //31827 added by keyur for security review
            return (String)objList[0].get('Name');
            
            
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    // to store api response
    public class FromJSON{
        public cls_colors[] colors;
        public boolean custom;
        public cls_icons[] icons;
        public String label;    //DemoObjects
        public String sobjectName;  //DemoObject__c
    }
    class Cls_colors {
        public String color;    //2ECBBE
        public String context;  //primary
        public String theme;    //theme4
    }
    class Cls_icons {
        public String contentType;  //image/png
        public Integer height;  //32
        public String theme;    //theme3
        public String url;  //https://activityassociation-dev-ed.my.salesforce.com/img/icon/reports32.png
        public Integer width;   //32
    }
}