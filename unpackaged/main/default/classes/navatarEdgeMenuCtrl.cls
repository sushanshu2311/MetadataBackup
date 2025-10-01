/* 
New Implimentation:
Developer       :   Sameeksha Sahu
Project         :   Navigation & SDG 
Date            :   30/July/2019

Description     :   navigationType functionality added to categorised  all navigation record 
Developer       :   Aditya Sharma
Project         :   PE V4.7 
Date            :   20 April 2021

Description     :  Show up in Navigation Menu based on the enable/disable setting on Navatar 
                    Setup
Developer       :   Rahul Kumar Kasaundhan
Project         :   PE V4.7  
Date            :   22/June/2021
Description     :   This class will fetch all navigation record for Utility bar edge menu  

Description     :   Sharing Model Implementation
Developer       :   Lakshya Kanchan
Project         :   PE V5.3 Phase 2
Date            :   18/March/2024
*/
public with sharing class navatarEdgeMenuCtrl{
    Public static map<String,String> mapRecordTypeNameToId = new map<String,String>(); 
    Public static map<String,String> mapListViewNameToId = new map<String,String>(); 
    Public static map<String,String> mapIdToUrl = new map<String,String>(); 
    
	//This method fetch all the parent and child label navigation record and return JSON to component
    @AuraEnabled
    public static responseWrapper getJson(String navigationType){ // addded parameter utilityType by Aditya PEv4.7 20 April 2021
		try{
			string strJson = '';
			List<Navigation> lstNavItems = new List<Navigation>();
			List<Navigation> lstChildNavItems = new List<Navigation>();
			Set<String> navSetuplist = new Set<String>();
			String key = '';
			
			//Create a map of sobject+record type name vs recordtypeid
			for(RecordType rt : [SELECT id,developerName,sobjecttype  FROM RecordType LIMIT 50000]){
				key = rt.sobjectType+'#'+rt.developerName;
				mapRecordTypeNameToId.put(key.toUpperCase(),rt.id);
			}
			//Create a map of sobject+list view name vs id
			for(ListView lv : [SELECT Id, DeveloperName, SobjectType FROM ListView LIMIT 50000]){
				key = lv.sobjectType+'#'+lv.developerName;
				mapListViewNameToId.put(key.toUpperCase(),lv.id);
			}
            
            //start changes for PEv4.7 by Aditya 26 April 2021
            //Added navigationTypeParent, removed else condition & modified if condition by Lakshya on 20210427 [PE v4.7]
            String navQuery = '';
            String strNavigationType = '';
            String navigationTypeParent = '';
            if(String.isNotBlank(navigationType)){
            	strNavigationType = 'WHERE navpeII_dev18__Navigation_Type__c=\'' + String.escapeSingleQuotes(navigationType)+ '\'';
                navigationTypeParent = 'AND navpeII_dev18__Navigation_Type__c=\'' + String.escapeSingleQuotes(navigationType) + '\'';
            }
			navSetuplist = getNavatarSettings(); //get list of page name with Like conditions by RahulK (22-06-2021)
            navQuery = 'SELECT id, Name,navpeII_dev18__Order__c, navpeII_dev18__URL__c, navpeII_dev18__Quick_Create_Object__c, navpeII_dev18__Quick_Create_Record_Type__c, navpeII_dev18__List_View_Object__c, navpeII_dev18__List_View_Name__c, navpeII_dev18__Activities_Button_API_Name__c, navpeII_dev18__Navigation_Type__c,(SELECT id, Name, navpeII_dev18__Order__c, navpeII_dev18__URL__c, navpeII_dev18__Quick_Create_Object__c, navpeII_dev18__Quick_Create_Record_Type__c, navpeII_dev18__List_View_Object__c, navpeII_dev18__List_View_Name__c, navpeII_dev18__Activities_Button_API_Name__c, navpeII_dev18__Navigation_Type__c FROM navpeII_dev18__Parent__r '+ strNavigationType + ' AND (Not navpeII_dev18__URL__c Like :navSetuplist) ORDER By navpeII_dev18__Order__c nulls last) FROM navpeII_dev18__Navigation__c WHERE navpeII_dev18__parent__c = null ' + navigationTypeParent + ' AND (Not navpeII_dev18__URL__c Like :navSetuplist) ORDER By navpeII_dev18__Order__c nulls last';
            system.debug('->'+navQuery);
            List<navpeII_dev18__Navigation__c> navList = Database.query(navQuery);
             system.debug('->'+ navList);
            //end changes for PEv4.7 by Aditya 26 April 2021
            //Phase 3 CR changes: query the Activities_Button_API_Name__c field.
			Map<String, Schema.SObjectType> schemaInfo = Schema.getGlobalDescribe();
			for(navpeII_dev18__Navigation__c objNav : navList)
			{
				//Moved code inside if clause by LK on 2024-03-18 for PE Phase 3.2
				if(schemaInfo.get(objNav.navpeII_dev18__Quick_Create_Object__c).getDescribe().isCreateable()){
					Navigation navObj = new Navigation();
					navObj = updateNodeOnQuickCreate(objNav); 
					navObj.expanded = false;
					lstChildNavItems = new List<Navigation>();
					if(navObj.id!= null){
						for(navpeII_dev18__Navigation__c objNavChild : objNav.navpeII_dev18__Parent__r){
							//Moved code inside if clause by LK on 2024-03-18 for PE Phase 3.2
							if(schemaInfo.get(objNavChild.navpeII_dev18__Quick_Create_Object__c).getDescribe().isCreateable()){
								Navigation navObjchild = updateNodeOnQuickCreate(objNavChild); 
								if(navObjchild.id != null)
									lstChildNavItems.add(navObjchild);
							}
						}
						if(lstChildNavItems.size() > 0){
							navObj.nodes = lstChildNavItems;
						}else{
							navObj.nodes = new List<Navigation>();
						}
						lstNavItems.add(navObj);
						
					}
				}
			}
			responseWrapper objRes = new responseWrapper();
			objRes.jsonStr = JSON.serialize(lstNavItems).replace(',"nodes":[]','');
			objRes.mapIdToUrl = mapIdToUrl;
			return objRes;
		}
		catch(Exception ex) {
            System.debug('Exception....'+ex);
            return null;
        }
    }
    
	//This method prepare node id for tree and check record type is createable or not 
    private static Navigation updateNodeOnQuickCreate(navpeII_dev18__Navigation__c objNav){
        String key = '';
        Navigation navLabel = new Navigation();
        //Check restrict parent action if child exists. Bug id:00028035
		if((objNav.navpeII_dev18__Activities_Button_API_Name__c == Null || objNav.navpeII_dev18__Activities_Button_API_Name__c == '') && (objNav.navpeII_dev18__URL__c == Null || objNav.navpeII_dev18__URL__c == '')){
			navLabel.text = objNav.Name;
			navLabel.id =   'Invoke aura,' + objNav.navpeII_dev18__Quick_Create_Object__c;// Nikita Changes
			//system.debug('navLabel.id'+navLabel.id);
			navLabel.expanded = false;
			navLabel.isLWCInvoked = true;
			return navLabel;
		}
        
        if(String.isNotBlank(objNav.navpeII_dev18__Quick_Create_Object__c) && String.isBlank(objNav.navpeII_dev18__URL__c) && objNav.navpeII_dev18__Parent__r.size() == 0){
            if(Schema.getGlobalDescribe().get(objNav.navpeII_dev18__Quick_Create_Object__c)!= null && (Schema.getGlobalDescribe().get(objNav.navpeII_dev18__Quick_Create_Object__c).getDescribe().isCreateable())){
                navLabel.text = '<span class=\'wordBlockClass\'>'+objNav.Name+'</span>';
                navLabel.id = 'create<@>' + objNav.navpeII_dev18__Quick_Create_Object__c; 
                // Phase 3 CR changes: get the activity button api name.
				if(String.isNotBlank(objNav.navpeII_dev18__Activities_Button_API_Name__c)){
                    navLabel.id += '<btnapi>' + objNav.navpeII_dev18__Activities_Button_API_Name__c+'<objlbl>' +Schema.getGlobalDescribe().get('Task').getDescribe().getLabel(); 
                }				
                key = objNav.navpeII_dev18__Quick_Create_Object__c+'#'+objNav.navpeII_dev18__Quick_Create_Object__c;
                if(String.isNotBlank(objNav.navpeII_dev18__Quick_Create_Object__c) && mapRecordTypeNameToId.containsKey(key.toUpperCase())){
                    navLabel.id += '<RT>' + mapRecordTypeNameToId.get(key.toUpperCase()); 
                }
            }
        }
        else{
            navLabel.text = '<span class=\'wordBlockClass\'>'+objNav.Name+'</span>';
            navLabel.id = objNav.id;
            
        }
        //Check to restrict parent action if child exists. Bug id:00028033
		if(objNav.navpeII_dev18__Parent__r.size() ==0){
			if(String.isNotBlank(objNav.navpeII_dev18__URL__c)){
				mapIdToUrl.put(objNav.id,objNav.navpeII_dev18__URL__c);
			}
			else if(String.isNotBlank(objNav.navpeII_dev18__List_View_Object__c) && String.isBlank(objNav.navpeII_dev18__List_View_Object__c)){
				mapIdToUrl.put(objNav.id,'/lightning/o/'+objNav.navpeII_dev18__List_View_Object__c+'/home');
			}
			else if(String.isNotBlank(objNav.navpeII_dev18__List_View_Object__c) && String.isNotBlank(objNav.navpeII_dev18__List_View_Object__c)){
				key = objNav.navpeII_dev18__List_View_Object__c+'#'+objNav.navpeII_dev18__List_View_Object__c;
				if(mapListViewNameToId.containsKey(key.toUpperCase())){
					mapIdToUrl.put(objNav.id,'/lightning/o/'+objNav.navpeII_dev18__List_View_Object__c+'/list?filterName='+mapListViewNameToId.get(key.toUpperCase()));
				}
			}
		}
        return navLabel;
    }
	/*
	* @Description  : Returns list of page name with Like conditions where  Navatar settings is not enable
	* @Parameter    : No Parameter requreied for this 
    * @Develoepr    : RahulK (22-06-2021)
	*/
    public static set<string> getNavatarSettings(){
        Set<String> navSetuplist = new Set<String>(); 
        try {
            List<navpeII_dev18__Org_Setting__mdt> lstORGmdt = new List<navpeII_dev18__Org_Setting__mdt>();
			
					if(Schema.sObjectType.navpeII_dev18__Org_Setting__mdt.isAccessible() && Schema.sObjectType.navpeII_dev18__Org_Setting__mdt.Fields.navpeII_dev18__IsActive__c.isAccessible() && 
					Schema.sObjectType.navpeII_dev18__Org_Setting__mdt.Fields.DeveloperName.isAccessible() && Schema.sObjectType.navpeII_dev18__Org_Setting__mdt.Fields.Label.isAccessible())
					{
						lstORGmdt = [SELECT Id, navpeII_dev18__IsActive__c, DeveloperName, Label FROM navpeII_dev18__Org_Setting__mdt  where navpeII_dev18__IsActive__c = false LIMIT:(Limits.getLimitQueryRows() - Limits.getQueryRows()) ];
					}

					for(navpeII_dev18__Org_Setting__mdt orgSetObj : lstORGmdt){ 
						if(orgSetObj.DeveloperName.toLowercase() == 'Bulk_Email_Setting'.toLowercase()){
							navSetuplist.add('%/apex/'+CommonUtility_EdgeMenu.strNameSpacePrefix+'Bulk_Email%'); 

						}
						else if(orgSetObj.DeveloperName.toLowercase() == 'Deal_Creation'.toLowercase()){
							navSetuplist.add('%/apex/'+CommonUtility_EdgeMenu.strNameSpacePrefix+'Deal_Creation%'); 
						}
						else if(orgSetObj.DeveloperName.toLowercase() == 'Ind_Inv_Creation'.toLowercase()){
							navSetuplist.add('%/apex/'+CommonUtility_EdgeMenu.strNameSpacePrefix+'IndividualInvestor%'); 
						}
						else if(orgSetObj.DeveloperName.toLowercase() == 'Commitment_Creation'.toLowercase()){
							navSetuplist.add('%/apex/'+CommonUtility_EdgeMenu.strNameSpacePrefix+'CommitmentCreation%');
						}
                        if(Test.isRunningTest()){
                            navSetuplist.add('%/apex/pem_dev__Deal_Creation%');
                        }
					}
            } 
            catch (Exception ex){
                system.debug('getNavatarSettings: Exception: ' +  ex.getLineNumber()+'--'+ex.getMessage() );
            }
        	System.debug('???navSetuplist???????'+navSetuplist);
        	return navSetuplist;

    } 
       
	//wrapper class for navigation
    public class Navigation
    {
        public string text;
        public boolean expanded;
        public List<Navigation> nodes;
        public string id;
        public Boolean isLWCInvoked{get; private set;}
		public Navigation() {
			this.isLWCInvoked = false;
		}
    }
    
    public Class responseWrapper{
        @AuraEnabled public string jsonStr;
        @AuraEnabled public map<String,String> mapIdToUrl;
    }
}